"use client";

import { useState, useRef, useEffect, useCallback } from "react";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { apiGet, apiPost } from "@/lib/api";
import { useSession } from "next-auth/react";
import { useWebSocket } from "@/hooks/useWebSocket";
import { SearchInput } from "@/components/shared/SearchInput";
import { MessageSquare, Send, Plus, Paperclip, Loader2, Check } from "lucide-react";
import { EmptyState } from "@/components/shared/EmptyState";
import { cn, formatRelative, getInitials } from "@/lib/utils";

export default function MessagesPage() {
  const { data: session } = useSession();
  const qc = useQueryClient();
  const currentUserId = session?.user?.id;

  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [msgInput, setMsgInput] = useState("");
  const [sending, setSending] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const typingTimer = useRef<ReturnType<typeof setTimeout>>();

  // ── WebSocket (handles reconnection, typing, online status) ──
  const { status: wsStatus, isUserOnline, getTypingUsers, sendTypingStart, sendTypingStop } = useWebSocket();

  // ── Conversations ──
  const { data: convosData, isLoading: convosLoading } = useQuery({
    queryKey: ["conversations"],
    queryFn: () => apiGet("/api/messages/conversations", { limit: 50 }),
  });
  const conversations = (convosData?.data ?? []) as any[];
  const filteredConvos = search
    ? conversations.filter((c: any) => (c.name ?? "").toLowerCase().includes(search.toLowerCase()))
    : conversations;

  // ── Messages for selected conversation ──
  const { data: msgsData, isLoading: msgsLoading } = useQuery({
    queryKey: ["messages", selectedId],
    queryFn: () => apiGet(`/api/messages/conversations/${selectedId}`, { limit: 100 }),
    enabled: !!selectedId,
    // Only poll as fallback when WebSocket is disconnected
    refetchInterval: wsStatus === "connected" ? false : 5000,
  });
  const msgPayload = msgsData?.data as Record<string, any> | undefined;
  const messages = ((msgPayload?.messages ?? msgPayload) ?? []) as any[];

  // ── Auto-scroll ──
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages.length]);

  // ── Mark as read on open ──
  useEffect(() => {
    if (!selectedId) return;
    apiPost(`/api/messages/conversations/${selectedId}/read`).catch(() => {});
  }, [selectedId]);

  // ── Typing indicator debounce ──
  const handleInputChange = useCallback(
    (value: string) => {
      setMsgInput(value);
      if (!selectedId) return;

      if (value.trim()) {
        sendTypingStart(selectedId);
        clearTimeout(typingTimer.current);
        typingTimer.current = setTimeout(() => {
          sendTypingStop(selectedId);
        }, 3000);
      } else {
        sendTypingStop(selectedId);
      }
    },
    [selectedId, sendTypingStart, sendTypingStop]
  );

  // ── Send message ──
  const handleSend = useCallback(async () => {
    if (!msgInput.trim() || !selectedId || sending) return;
    setSending(true);
    // Stop typing indicator
    clearTimeout(typingTimer.current);
    sendTypingStop(selectedId);
    try {
      await apiPost("/api/messages/send", {
        conversation_id: selectedId,
        type: "text",
        content: msgInput.trim(),
      });
      setMsgInput("");
      qc.invalidateQueries({ queryKey: ["messages", selectedId] });
      qc.invalidateQueries({ queryKey: ["conversations"] });
    } catch {
      /* toast handled by interceptor */
    }
    setSending(false);
  }, [msgInput, selectedId, sending, qc, sendTypingStop]);

  const selectedConvo = conversations.find((c: any) => c.id === selectedId);
  const typingSet = selectedId ? getTypingUsers(selectedId) : new Set<string>();

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-slate-900">Messages</h1>
        {/* WebSocket status indicator */}
        <div className="flex items-center gap-2 text-xs text-slate-400">
          <span
            className={cn(
              "h-2 w-2 rounded-full",
              wsStatus === "connected" ? "bg-emerald-400" : wsStatus === "connecting" ? "bg-amber-400 animate-pulse" : "bg-slate-300"
            )}
          />
          {wsStatus === "connected" ? "Live" : wsStatus === "connecting" ? "Connecting..." : "Offline"}
        </div>
      </div>

      <div className="card overflow-hidden flex" style={{ height: "calc(100vh - 200px)" }}>
        {/* ── Left Panel: Conversation List ────────────────── */}
        <div className="w-[340px] border-r border-slate-100 flex flex-col shrink-0">
          <div className="p-3 space-y-2 border-b border-slate-100 shrink-0">
            <button className="btn-primary w-full text-sm">
              <Plus className="h-4 w-4" /> New Conversation
            </button>
            <SearchInput value={search} onChange={setSearch} placeholder="Search..." />
          </div>

          <div className="flex-1 overflow-y-auto">
            {convosLoading ? (
              <div className="p-3 space-y-2">
                {Array.from({ length: 8 }).map((_, i) => (
                  <div key={i} className="skeleton h-16 w-full rounded-lg" />
                ))}
              </div>
            ) : filteredConvos.length === 0 ? (
              <div className="py-12 text-center text-sm text-slate-400">
                {search ? "No matches" : "No conversations"}
              </div>
            ) : (
              filteredConvos.map((c: any) => (
                <button
                  key={c.id}
                  onClick={() => setSelectedId(c.id)}
                  className={cn(
                    "w-full text-left px-4 py-3 border-b border-slate-50 hover:bg-slate-50 transition-colors",
                    selectedId === c.id && "bg-sf-iceBlue border-l-2 border-l-brand-600"
                  )}
                >
                  <div className="flex items-center gap-3">
                    <div className="relative">
                      <div className="h-10 w-10 rounded-full bg-sf-iceBlue text-sf-deepNavy flex items-center justify-center text-xs font-bold shrink-0">
                        {getInitials(c.name ?? "DM")}
                      </div>
                      {/* Online dot — show for direct conversations */}
                      {c.type === "direct" && c.other_user_id && isUserOnline(c.other_user_id) && (
                        <span className="absolute -bottom-0.5 -right-0.5 h-3 w-3 rounded-full bg-emerald-400 ring-2 ring-white" />
                      )}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center justify-between">
                        <p className="text-sm font-medium text-slate-900 truncate">{c.name || "Direct Message"}</p>
                        {c.last_message && (
                          <span className="text-[10px] text-slate-400 shrink-0 ml-2">
                            {formatRelative(c.last_message.created_at)}
                          </span>
                        )}
                      </div>
                      {/* Show typing or last message */}
                      {getTypingUsers(c.id).size > 0 ? (
                        <p className="text-xs text-sf-deepNavy font-medium truncate mt-0.5">typing...</p>
                      ) : (
                        <p className="text-xs text-slate-400 truncate mt-0.5">
                          {c.last_message?.sender_name && (
                            <span className="font-medium">{c.last_message.sender_name}: </span>
                          )}
                          {c.last_message?.content || "No messages"}
                        </p>
                      )}
                    </div>
                    {c.unread_count > 0 && (
                      <span className="ml-1 h-5 min-w-[20px] rounded-full bg-sf-deepNavy text-white text-[10px] font-bold flex items-center justify-center px-1.5">
                        {c.unread_count}
                      </span>
                    )}
                  </div>
                </button>
              ))
            )}
          </div>
        </div>

        {/* ── Right Panel: Chat Area ───────────────────────── */}
        <div className="flex-1 flex flex-col min-w-0">
          {!selectedId ? (
            <div className="flex-1 flex items-center justify-center">
              <EmptyState icon={MessageSquare} title="Select a conversation" description="Choose a conversation to start chatting" />
            </div>
          ) : (
            <>
              {/* Chat header */}
              <div className="px-5 py-3 border-b border-slate-100 flex items-center gap-3 shrink-0">
                <div className="h-9 w-9 rounded-full bg-sf-iceBlue text-sf-deepNavy flex items-center justify-center text-xs font-bold">
                  {getInitials(selectedConvo?.name ?? "DM")}
                </div>
                <div>
                  <p className="text-sm font-semibold text-slate-900">{selectedConvo?.name || "Direct Message"}</p>
                  <p className="text-[10px] text-slate-400">
                    {typingSet.size > 0 ? (
                      <span className="text-sf-deepNavy font-medium">typing...</span>
                    ) : (
                      `${selectedConvo?.member_count ?? 2} members`
                    )}
                  </p>
                </div>
              </div>

              {/* Messages */}
              <div className="flex-1 overflow-y-auto px-5 py-4 space-y-3">
                {msgsLoading ? (
                  <div className="space-y-3">
                    {Array.from({ length: 5 }).map((_, i) => (
                      <div key={i} className={cn("skeleton h-10", i % 2 === 0 ? "w-2/3" : "w-1/2 ml-auto")} />
                    ))}
                  </div>
                ) : messages.length === 0 ? (
                  <div className="flex-1 flex items-center justify-center text-sm text-slate-400">
                    No messages yet. Say hello!
                  </div>
                ) : (
                  [...messages].reverse().map((msg: any) => {
                    const isMine = msg.sender_id === currentUserId;
                    return (
                      <div key={msg.id} className={cn("flex gap-2.5", isMine ? "flex-row-reverse" : "flex-row")}>
                        {!isMine && (
                          <div className="h-7 w-7 rounded-full bg-slate-200 text-slate-600 flex items-center justify-center text-[10px] font-bold shrink-0 mt-0.5">
                            {getInitials(msg.sender_name ?? "?")}
                          </div>
                        )}
                        <div className={cn("max-w-[65%]", isMine ? "text-right" : "text-left")}>
                          {!isMine && <p className="text-[10px] text-slate-400 mb-0.5 ml-1">{msg.sender_name}</p>}
                          <div
                            className={cn(
                              "inline-block px-3.5 py-2 rounded-2xl text-sm",
                              isMine ? "bg-sf-deepNavy text-white rounded-br-md" : "bg-slate-100 text-slate-800 rounded-bl-md"
                            )}
                          >
                            {msg.content}
                          </div>
                          <p className={cn("text-[10px] mt-0.5 px-1", isMine ? "text-slate-400" : "text-slate-300")}>
                            {formatRelative(msg.created_at)}
                            {isMine && msg.is_read && <Check className="inline h-3 w-3 ml-1 text-sf-systemBlue" />}
                          </p>
                        </div>
                      </div>
                    );
                  })
                )}
                <div ref={messagesEndRef} />
              </div>

              {/* Input */}
              <div className="px-4 py-3 border-t border-slate-100 flex items-center gap-2 shrink-0">
                <button className="p-2 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-50">
                  <Paperclip className="h-4 w-4" />
                </button>
                <input
                  value={msgInput}
                  onChange={(e) => handleInputChange(e.target.value)}
                  onKeyDown={(e) => {
                    if (e.key === "Enter" && !e.shiftKey) {
                      e.preventDefault();
                      handleSend();
                    }
                  }}
                  className="input flex-1 py-2.5"
                  placeholder="Type a message..."
                />
                <button onClick={handleSend} disabled={!msgInput.trim() || sending} className="btn-primary px-3 py-2.5">
                  {sending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Send className="h-4 w-4" />}
                </button>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
