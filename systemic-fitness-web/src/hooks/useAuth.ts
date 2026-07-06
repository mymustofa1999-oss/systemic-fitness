import { useSession } from "next-auth/react";

export function useAuth() {
  const { data: session, status } = useSession();

  const rawRole = session?.user?.role ?? "client";
  const safeRole = rawRole.toLowerCase();

  return {
    user: session?.user ?? null,
    role: rawRole,
    isLoading: status === "loading",
    isAuthenticated: status === "authenticated",
    isOwner: safeRole === "owner",
    isAdmin: ["owner", "admin"].includes(safeRole),
    isFinance: ["owner", "admin", "finance"].includes(safeRole),
    isConsultant: safeRole === "consultant",
    isTrainer: safeRole === "trainer",
    isClient: safeRole === "client",
  };
}
