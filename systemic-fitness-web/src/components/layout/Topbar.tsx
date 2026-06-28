"use client";

import { useSession, signOut } from "next-auth/react";
import { usePathname, useRouter } from "next/navigation";
import { Bell, LogOut, User, ChevronRight, Menu } from "lucide-react";
import { getInitials } from "@/lib/utils";
import { useUIStore } from "@/stores/uiStore";
import { useState, useRef, useEffect } from "react";
import { useUser } from "@/hooks/useUsers";

export function Topbar() {
  const { data: session } = useSession();
  const pathname = usePathname();
  const router = useRouter();
  const { sidebarCollapsed, toggleCollapse } = useUIStore();
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Close dropdown on outside click
  useEffect(() => {
    function handleClick(e: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        setDropdownOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClick);
    return () => document.removeEventListener("mousedown", handleClick);
  }, []);

  // Build breadcrumb from pathname
  const segments = pathname.split("/").filter(Boolean);
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  const uuidSegment = segments.find((seg) => uuidRegex.test(seg));

  // Query user info if a UUID segment exists
  const { data: userResp } = useUser(uuidSegment || "");
  const clientName = (userResp?.data as any)?.user?.full_name;

  const breadcrumbs = segments.map((seg, i) => {
    const isUuid = uuidRegex.test(seg);
    return {
      label: isUuid
        ? (clientName || "Loading...")
        : seg.charAt(0).toUpperCase() + seg.slice(1).replace(/-/g, " "),
      href: "/" + segments.slice(0, i + 1).join("/"),
      isLast: i === segments.length - 1,
    };
  });

  return (
    <header className="sticky top-0 z-30 h-16 bg-white/80 backdrop-blur-md border-b border-slate-100 flex items-center justify-between px-6">
      {/* Left: hamburger + breadcrumb */}
      <div className="flex items-center gap-3">
        <button
          onClick={toggleCollapse}
          className="lg:hidden p-2 rounded-lg hover:bg-slate-100"
        >
          <Menu className="h-5 w-5 text-slate-600" />
        </button>

        <nav className="hidden sm:flex items-center text-sm text-slate-500">
          <span className="font-medium text-slate-700">Home</span>
          {breadcrumbs.map((b) => (
            <span key={b.href} className="flex items-center">
              <ChevronRight className="mx-1.5 h-3.5 w-3.5 text-slate-300" />
              <span className={b.isLast ? "font-medium text-slate-900" : "hover:text-slate-700"}>
                {b.label}
              </span>
            </span>
          ))}
        </nav>
      </div>

      {/* Right: notifications + user menu */}
      <div className="flex items-center gap-2">
        <button className="relative p-2.5 rounded-lg hover:bg-slate-100 text-slate-500 transition-colors">
          <Bell className="h-5 w-5" />
          <span className="absolute top-1.5 right-1.5 h-2 w-2 bg-rose-500 rounded-full" />
        </button>

        <div className="relative" ref={dropdownRef}>
          <button
            onClick={() => setDropdownOpen(!dropdownOpen)}
            className="flex items-center gap-3 p-1.5 pr-3 rounded-lg hover:bg-slate-100 transition-colors"
          >
            <div className="h-8 w-8 rounded-full bg-sf-iceBlue text-sf-deepNavy flex items-center justify-center text-xs font-bold">
              {getInitials(session?.user?.name || "U")}
            </div>
            <div className="hidden md:block text-left">
              <p className="text-sm font-medium text-slate-700 leading-tight">
                {session?.user?.name || "User"}
              </p>
              <p className="text-xs text-slate-400 capitalize">{session?.user?.role}</p>
            </div>
          </button>

          {dropdownOpen && (
            <div className="absolute right-0 top-full mt-1 w-56 bg-white rounded-xl shadow-lg border border-slate-100 py-1.5 animate-fade-in">
              <button
                onClick={() => { setDropdownOpen(false); router.push("/settings"); }}
                className="w-full flex items-center gap-2.5 px-4 py-2 text-sm text-slate-600 hover:bg-slate-50"
              >
                <User className="h-4 w-4" /> Profile
              </button>
              <hr className="my-1 border-slate-100" />
              <button
                onClick={() => signOut({ callbackUrl: "/login" })}
                className="w-full flex items-center gap-2.5 px-4 py-2 text-sm text-rose-600 hover:bg-rose-50"
              >
                <LogOut className="h-4 w-4" /> Sign out
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
