"use client";

import { useEffect, useRef, useCallback, useState } from "react";
import { useSession } from "next-auth/react";
import { useQueryClient } from "@tanstack/react-query";

// ═══════════════════════════════════════════════════════════════
//  Types
// ═══════════════════════════════════════════════════════════════

export interface WsEvent {
  type: string;
  data: unknown;
}

export interface WsNewMessage {
  id: string;
  conversation_id: string;
  sender_id: string;
  sender_name?: string;
  content?: string;
  type: string;
  created_at: string;
}

export interface WsTypingEvent {
  conversation_id: string;
  user_id: string;
  user_name?: string;
}

export interface WsOnlineEvent {
  user_id: string;
}

export interface WsReadEvent {
  conversation_id: string;
  count: number;
}

type WsStatus = "connecting" | "connected" | "disconnected";
type EventHandler = (event: WsEvent) => void;

// ═══════════════════════════════════════════════════════════════
//  Hook
// ═══════════════════════════════════════════════════════════════

const MAX_RECONNECT_DELAY = 30_000;
const BASE_RECONNECT_DELAY = 1_000;

export function useWebSocket(options?: { onEvent?: EventHandler }) {
  const { data: session } = useSession();
  const qc = useQueryClient();
  const wsRef = useRef<WebSocket | null>(null);
  const reconnectTimer = useRef<ReturnType<typeof setTimeout>>();
  const reconnectAttempt = useRef(0);
  const [status, setStatus] = useState<WsStatus>("disconnected");
  const [onlineUsers, setOnlineUsers] = useState<Set<string>>(new Set());
  const [typingUsers, setTypingUsers] = useState<Map<string, Set<string>>>(new Map()); // conversationId → set of userIds
  const onEventRef = useRef(options?.onEvent);
  onEventRef.current = options?.onEvent;

  const connect = useCallback(() => {
    const token = session?.accessToken;
    if (!token) return;

    // Don't reconnect if already connected
    if (wsRef.current?.readyState === WebSocket.OPEN) return;

    const baseUrl = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8080";
    const wsUrl = `${baseUrl.replace(/^http/, "ws")}/ws/messages?token=${token}`;

    setStatus("connecting");
    const ws = new WebSocket(wsUrl);
    wsRef.current = ws;

    ws.onopen = () => {
      setStatus("connected");
      reconnectAttempt.current = 0;
    };

    ws.onmessage = (ev) => {
      // Handle batched messages (hub may concatenate with \n)
      const raw = ev.data as string;
      const lines = raw.split("\n").filter(Boolean);

      for (const line of lines) {
        try {
          const event = JSON.parse(line) as WsEvent;
          handleEvent(event);
          onEventRef.current?.(event);
        } catch {
          /* ignore malformed */
        }
      }
    };

    ws.onclose = () => {
      setStatus("disconnected");
      wsRef.current = null;
      scheduleReconnect();
    };

    ws.onerror = () => {
      // onclose will fire after onerror
      ws.close();
    };
  }, [session?.accessToken]); // eslint-disable-line react-hooks/exhaustive-deps

  const scheduleReconnect = useCallback(() => {
    clearTimeout(reconnectTimer.current);
    const delay = Math.min(
      BASE_RECONNECT_DELAY * Math.pow(2, reconnectAttempt.current),
      MAX_RECONNECT_DELAY
    );
    reconnectAttempt.current += 1;
    reconnectTimer.current = setTimeout(connect, delay);
  }, [connect]);

  // ── Event dispatcher ──
  const handleEvent = useCallback(
    (event: WsEvent) => {
      switch (event.type) {
        case "new_message": {
          const msg = event.data as WsNewMessage;
          // Update message list for the conversation
          qc.invalidateQueries({ queryKey: ["messages", msg.conversation_id] });
          // Update conversations list (last message, unread count)
          qc.invalidateQueries({ queryKey: ["conversations"] });
          // Show browser notification if tab not focused
          showNotification(msg);
          break;
        }

        case "messages_read": {
          const data = event.data as WsReadEvent;
          qc.invalidateQueries({ queryKey: ["messages", data.conversation_id] });
          qc.invalidateQueries({ queryKey: ["conversations"] });
          break;
        }

        case "typing_start": {
          const data = event.data as WsTypingEvent;
          setTypingUsers((prev) => {
            const next = new Map(prev);
            const set = new Set(next.get(data.conversation_id) ?? []);
            set.add(data.user_id);
            next.set(data.conversation_id, set);
            return next;
          });
          // Auto-clear after 4 seconds
          setTimeout(() => {
            setTypingUsers((prev) => {
              const next = new Map(prev);
              const set = new Set(next.get(data.conversation_id) ?? []);
              set.delete(data.user_id);
              if (set.size === 0) next.delete(data.conversation_id);
              else next.set(data.conversation_id, set);
              return next;
            });
          }, 4000);
          break;
        }

        case "typing_stop": {
          const data = event.data as WsTypingEvent;
          setTypingUsers((prev) => {
            const next = new Map(prev);
            const set = new Set(next.get(data.conversation_id) ?? []);
            set.delete(data.user_id);
            if (set.size === 0) next.delete(data.conversation_id);
            else next.set(data.conversation_id, set);
            return next;
          });
          break;
        }

        case "user_online": {
          const data = event.data as WsOnlineEvent;
          setOnlineUsers((prev) => {
            const next = new Set(prev);
            next.add(data.user_id);
            return next;
          });
          break;
        }

        case "user_offline": {
          const data = event.data as WsOnlineEvent;
          setOnlineUsers((prev) => {
            const next = new Set(prev);
            next.delete(data.user_id);
            return next;
          });
          break;
        }
      }
    },
    [qc]
  );

  // ── Connect on mount / session change ──
  useEffect(() => {
    if (session?.accessToken) {
      connect();
    }
    return () => {
      clearTimeout(reconnectTimer.current);
      wsRef.current?.close();
      wsRef.current = null;
    };
  }, [session?.accessToken, connect]);

  // ── Send helpers ──
  const sendEvent = useCallback((type: string, data: unknown) => {
    if (wsRef.current?.readyState !== WebSocket.OPEN) return;
    wsRef.current.send(JSON.stringify({ type, data }));
  }, []);

  const sendTypingStart = useCallback(
    (conversationId: string) => {
      sendEvent("typing_start", { conversation_id: conversationId });
    },
    [sendEvent]
  );

  const sendTypingStop = useCallback(
    (conversationId: string) => {
      sendEvent("typing_stop", { conversation_id: conversationId });
    },
    [sendEvent]
  );

  const isUserOnline = useCallback(
    (userId: string) => onlineUsers.has(userId),
    [onlineUsers]
  );

  const getTypingUsers = useCallback(
    (conversationId: string) => typingUsers.get(conversationId) ?? new Set(),
    [typingUsers]
  );

  return {
    status,
    onlineUsers,
    isUserOnline,
    getTypingUsers,
    sendTypingStart,
    sendTypingStop,
    sendEvent,
  };
}

// ═══════════════════════════════════════════════════════════════
//  Browser Notification
// ═══════════════════════════════════════════════════════════════

function showNotification(msg: WsNewMessage) {
  if (typeof window === "undefined") return;
  if (document.hasFocus()) return;
  if (!("Notification" in window)) return;

  if (Notification.permission === "default") {
    Notification.requestPermission();
    return;
  }

  if (Notification.permission !== "granted") return;

  const title = msg.sender_name ?? "New Message";
  const body = msg.content ?? "Sent an attachment";

  try {
    new Notification(title, {
      body,
      icon: "/favicon.ico",
      tag: `msg-${msg.id}`,
    });
  } catch {
    /* mobile browsers may not support Notification constructor */
  }
}
