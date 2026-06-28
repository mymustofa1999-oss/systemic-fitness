import type { NextAuthOptions } from "next-auth";
import CredentialsProvider from "next-auth/providers/credentials";

const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8080";

// Roles allowed to login on the client web app
const ALLOWED_ROLES = ["client", "trainer"];

/**
 * Calls the Go API refresh endpoint to get new tokens.
 * Returns new token data or null if refresh failed.
 */
async function refreshAccessToken(refreshToken: string) {
  try {
    const res = await fetch(`${API_URL}/api/auth/refresh`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refresh_token: refreshToken }),
    });

    const json = await res.json();
    if (!res.ok || !json.success) return null;

    const { tokens } = json.data;
    return {
      accessToken: tokens.access_token as string,
      refreshToken: tokens.refresh_token as string,
      expiresAt: new Date(tokens.expires_at).getTime(),
    };
  } catch {
    return null;
  }
}

export const authOptions: NextAuthOptions = {
  providers: [
    CredentialsProvider({
      name: "credentials",
      credentials: {
        email: { label: "Email", type: "email" },
        password: { label: "Password", type: "password" },
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) return null;

        try {
          const res = await fetch(`${API_URL}/api/auth/login`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              email: credentials.email,
              password: credentials.password,
            }),
          });

          const json = await res.json();
          if (!res.ok || !json.success) return null;

          const { user, tokens } = json.data;
          const { access_token, refresh_token, expires_at } = tokens;

          // Only allow client and trainer roles to login
          if (!ALLOWED_ROLES.includes(user.role)) {
            return null;
          }

          return {
            id: user.id,
            email: user.email,
            name: user.full_name,
            role: user.role,
            image: user.avatar_url,
            accessToken: access_token,
            refreshToken: refresh_token,
            expiresAt: new Date(expires_at).getTime(),
          };
        } catch {
          return null;
        }
      },
    }),
  ],
  callbacks: {
    async jwt({ token, user }) {
      // Initial sign-in: store all token data
      if (user) {
        token.id = user.id;
        token.role = (user as any).role;
        token.accessToken = (user as any).accessToken;
        token.refreshToken = (user as any).refreshToken;
        token.expiresAt = (user as any).expiresAt;
        return token;
      }

      // On subsequent requests: check if access token is still valid
      // Refresh 60 seconds before actual expiry to avoid edge cases
      const expiresAt = (token.expiresAt as number) || 0;
      const shouldRefresh = Date.now() > expiresAt - 60 * 1000;

      if (!shouldRefresh) {
        return token; // token still valid
      }

      // Token expired or about to expire — refresh it
      const refreshed = await refreshAccessToken(token.refreshToken as string);

      if (refreshed) {
        token.accessToken = refreshed.accessToken;
        token.refreshToken = refreshed.refreshToken;
        token.expiresAt = refreshed.expiresAt;
        return token;
      }

      // Refresh failed — mark token as expired so session callback can handle it
      token.error = "RefreshTokenExpired";
      return token;
    },
    async session({ session, token }) {
      session.user.id = token.id as string;
      session.user.role = token.role as string;
      (session as any).accessToken = token.accessToken;
      (session as any).error = token.error; // propagate error to client
      return session;
    },
  },
  pages: {
    signIn: "/login",
    error: "/login",
  },
  session: {
    strategy: "jwt",
    maxAge: 7 * 24 * 60 * 60, // 7 days (matches refresh token lifetime)
  },
};
