"use client";

import { useSession } from "next-auth/react";
import { useEffect } from "react";
import { setAccessToken } from "@/lib/api";

/**
 * Invisible component that syncs the NextAuth session's accessToken
 * into the Axios API client's in-memory store. This avoids calling
 * getSession() from the Axios interceptor, which would trigger
 * /api/auth/session requests and cause re-render loops.
 */
export function SessionSync() {
  const { data: session, status } = useSession();

  useEffect(() => {
    if (status === "authenticated" && session) {
      setAccessToken(
        (session as any).accessToken ?? null,
        (session as any).error ?? null
      );
    } else if (status === "unauthenticated") {
      setAccessToken(null, null);
    }
  }, [session, status]);

  return null;
}
