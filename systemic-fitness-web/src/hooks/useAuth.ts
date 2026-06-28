import { useSession } from "next-auth/react";

export function useAuth() {
  const { data: session, status } = useSession();

  return {
    user: session?.user ?? null,
    role: session?.user?.role ?? "client",
    isLoading: status === "loading",
    isAuthenticated: status === "authenticated",
    isOwner: session?.user?.role === "owner",
    isAdmin: ["owner", "admin"].includes(session?.user?.role ?? ""),
    isFinance: ["owner", "admin", "finance"].includes(session?.user?.role ?? ""),
    isConsultant: session?.user?.role === "consultant",
    isTrainer: session?.user?.role === "trainer",
    isClient: session?.user?.role === "client",
  };
}
