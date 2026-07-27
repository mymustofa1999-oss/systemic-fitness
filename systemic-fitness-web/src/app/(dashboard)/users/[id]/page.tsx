"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useUser, useUpdateUser, useDeleteUser } from "@/hooks/useUsers";
import { useAuth } from "@/hooks/useAuth";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import {
  ArrowLeft, Mail, Phone, Calendar, MapPin,
  Flame, Dumbbell, TrendingUp, Clock,
  CreditCard, Shield, Edit, Trash2, Power,
  Activity, Target, BarChart3,
} from "lucide-react";
import Link from "next/link";
import { cn, formatDate, formatRelative, getInitials, formatCurrency } from "@/lib/utils";

// ── Badge maps ──────────────────────────────────────────────────

const roleColors: Record<string, string> = {
  owner: "bg-purple-100 text-purple-700", admin: "bg-blue-100 text-blue-700",
  finance: "bg-amber-100 text-amber-700", consultant: "bg-teal-100 text-teal-700",
  trainer: "bg-emerald-100 text-emerald-700", client: "bg-slate-100 text-slate-600",
};

const statusColors: Record<string, string> = {
  active: "bg-emerald-100 text-emerald-700", pending: "bg-amber-100 text-amber-700",
  suspended: "bg-rose-100 text-rose-700", inactive: "bg-slate-100 text-slate-500",
};

// ── Tab type ────────────────────────────────────────────────────

type Tab = "overview" | "programs" | "progress" | "payments";

const tabs: { key: Tab; label: string; icon: typeof Activity }[] = [
  { key: "overview", label: "Overview", icon: Activity },
  { key: "programs", label: "Programs", icon: Target },
  { key: "progress", label: "Progress", icon: BarChart3 },
  { key: "payments", label: "Payments", icon: CreditCard },
];

// ── Page ────────────────────────────────────────────────────────

export default function UserDetailPage({ params }: { params: { id: string } }) {
  const router = useRouter();
  const { isTrainer } = useAuth();
  const { data, isLoading } = useUser(params.id);
  const { mutate: updateUser, isPending: updating } = useUpdateUser();
  const { mutate: deleteUser, isPending: deleting } = useDeleteUser();

  const [activeTab, setActiveTab] = useState<Tab>("overview");
  const [deleteOpen, setDeleteOpen] = useState(false);

  const detail = data?.data as any;
  const user = detail?.user;
  const profile = detail?.profile;
  const stats = detail?.stats;

  // User management is admin-only; trainers have no business here.
  if (isTrainer) {
    return (
      <div className="text-center py-20">
        <Shield className="h-10 w-10 text-slate-300 mx-auto mb-3" />
        <p className="text-slate-600 font-medium">Akses Ditolak</p>
        <p className="text-sm text-slate-400 mt-1">Halaman manajemen user hanya untuk admin/owner.</p>
        <Link href="/" className="text-sf-deepNavy hover:text-sf-deepNavy text-sm mt-3 inline-block">
          Kembali ke Dashboard
        </Link>
      </div>
    );
  }

  if (isLoading) return <DetailSkeleton />;
  if (!user) {
    return (
      <div className="text-center py-20">
        <p className="text-slate-500">User not found</p>
        <Link href="/users" className="text-sf-deepNavy hover:text-sf-deepNavy text-sm mt-2 inline-block">
          Back to Users
        </Link>
      </div>
    );
  }

  const isSuspended = user.status === "suspended";

  function toggleStatus() {
    updateUser({
      id: params.id,
      data: { status: isSuspended ? "active" : "suspended" },
    });
  }

  return (
    <div className="space-y-6">
      <Link href="/users" className="inline-flex items-center gap-1.5 text-sm text-slate-500 hover:text-slate-700">
        <ArrowLeft className="h-4 w-4" /> Back to Users
      </Link>

      {/* ── Layout: Sidebar (1/3) + Content (2/3) ─────────────── */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* ── LEFT SIDEBAR ─────────────────────────────────────── */}
        <div className="space-y-4">
          {/* Profile Card */}
          <div className="card p-6 text-center">
            <div className="h-20 w-20 rounded-2xl bg-sf-iceBlue text-sf-deepNavy flex items-center justify-center text-2xl font-bold mx-auto">
              {getInitials(user.full_name)}
            </div>
            <h2 className="text-lg font-bold text-slate-900 mt-4">{user.full_name}</h2>
            <div className="flex items-center justify-center gap-2 mt-2">
              <span className={cn("px-2.5 py-0.5 rounded-full text-xs font-medium capitalize", roleColors[user.role])}>
                {user.role}
              </span>
              <span className={cn("px-2.5 py-0.5 rounded-full text-xs font-medium capitalize", statusColors[user.status])}>
                {user.status}
              </span>
            </div>

            {/* Contact Info */}
            <div className="mt-5 space-y-2.5 text-left">
              <div className="flex items-center gap-2.5 text-sm text-slate-600">
                <Mail className="h-4 w-4 text-slate-400 shrink-0" />
                <span className="truncate">{user.email}</span>
              </div>
              {user.phone && (
                <div className="flex items-center gap-2.5 text-sm text-slate-600">
                  <Phone className="h-4 w-4 text-slate-400 shrink-0" />
                  <span>{user.phone}</span>
                </div>
              )}
              <div className="flex items-center gap-2.5 text-sm text-slate-600">
                <Calendar className="h-4 w-4 text-slate-400 shrink-0" />
                <span>Joined {formatDate(user.created_at)}</span>
              </div>
              <div className="flex items-center gap-2.5 text-sm text-slate-600">
                <MapPin className="h-4 w-4 text-slate-400 shrink-0" />
                <span>{user.timezone}</span>
              </div>
            </div>

            {/* Actions */}
            <div className="mt-5 space-y-2">
              <button
                onClick={() => router.push(`/users/${params.id}?edit=true`)}
                className="btn-secondary w-full"
              >
                <Edit className="h-4 w-4" /> Edit Profile
              </button>
              <button
                onClick={toggleStatus}
                disabled={updating}
                className={cn("w-full", isSuspended ? "btn-primary" : "btn-secondary text-amber-600 border-amber-200 hover:bg-amber-50")}
              >
                <Power className="h-4 w-4" />
                {isSuspended ? "Reactivate" : "Suspend"}
              </button>
              {user.role !== "owner" && (
                <button onClick={() => setDeleteOpen(true)} className="btn-ghost w-full text-rose-500 hover:bg-rose-50 hover:text-rose-600">
                  <Trash2 className="h-4 w-4" /> Delete Account
                </button>
              )}
            </div>
          </div>

          {/* Quick Stats */}
          {stats && (
            <div className="card p-4 space-y-3">
              <h3 className="text-xs font-semibold text-slate-400 uppercase tracking-wider">Quick Stats</h3>
              {[
                { icon: Dumbbell, label: "Total Workouts", value: stats.total_workouts },
                { icon: Flame, label: "Current Streak", value: `${stats.current_streak_days} days` },
                { icon: TrendingUp, label: "This Week", value: stats.workouts_this_week },
                { icon: Clock, label: "Last Workout", value: stats.last_workout_at ? formatRelative(stats.last_workout_at) : "Never" },
              ].map((s) => (
                <div key={s.label} className="flex items-center justify-between">
                  <span className="flex items-center gap-2 text-sm text-slate-600">
                    <s.icon className="h-3.5 w-3.5 text-slate-400" /> {s.label}
                  </span>
                  <span className="text-sm font-semibold font-mono text-slate-900">{s.value}</span>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* ── RIGHT CONTENT (2/3) ──────────────────────────────── */}
        <div className="lg:col-span-2 space-y-4">
          {/* Tab Bar */}
          <div className="flex border-b border-slate-200">
            {tabs.map((tab) => (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className={cn(
                  "flex items-center gap-2 px-4 py-3 text-sm font-medium border-b-2 -mb-px transition-colors",
                  activeTab === tab.key
                    ? "border-sf-deepNavy text-sf-deepNavy"
                    : "border-transparent text-slate-500 hover:text-slate-700"
                )}
              >
                <tab.icon className="h-4 w-4" />
                {tab.label}
              </button>
            ))}
          </div>

          {/* Tab Content */}
          {activeTab === "overview" && (
            <OverviewTab user={user} profile={profile} stats={stats} />
          )}
          {activeTab === "programs" && <ProgramsTab userId={params.id} stats={stats} />}
          {activeTab === "progress" && <ProgressTab userId={params.id} />}
          {activeTab === "payments" && <PaymentsTab />}
        </div>
      </div>

      {/* Delete Confirm */}
      <ConfirmDialog
        open={deleteOpen}
        onClose={() => setDeleteOpen(false)}
        onConfirm={() => deleteUser(params.id, {
          onSuccess: () => { setDeleteOpen(false); router.push("/users"); },
        })}
        title="Delete User"
        description={`Are you sure you want to delete ${user.full_name}? This action cannot be undone.`}
        confirmLabel="Delete User"
        variant="danger"
        loading={deleting}
      />
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
//  Tab Content Components
// ═══════════════════════════════════════════════════════════════

function OverviewTab({ user, profile, stats }: { user: any; profile: any; stats: any }) {
  return (
    <div className="space-y-4 animate-fade-in">
      {/* Stats row */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        {[
          { label: "Total Workouts", value: stats?.total_workouts ?? 0, color: "text-sf-deepNavy" },
          { label: "Current Streak", value: `${stats?.current_streak_days ?? 0}d`, color: "text-amber-600" },
          { label: "This Week", value: stats?.workouts_this_week ?? 0, color: "text-emerald-600" },
          { label: "This Month", value: stats?.workouts_this_month ?? 0, color: "text-blue-600" },
        ].map((s) => (
          <div key={s.label} className="card p-4 text-center">
            <p className={cn("text-2xl font-bold font-heading", s.color)}>{s.value}</p>
            <p className="text-xs text-slate-500 mt-1">{s.label}</p>
          </div>
        ))}
      </div>

      {/* Active Program */}
      {stats?.active_program_name && (
        <div className="card p-5">
          <h4 className="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-3">Active Program</h4>
          <div className="flex items-center justify-between">
            <div>
              <p className="font-medium text-slate-900">{stats.active_program_name}</p>
              <p className="text-xs text-slate-500 mt-0.5">
                Week {stats?.current_week ?? "?"} · {stats?.program_progress_pct?.toFixed(0) ?? 0}% complete
              </p>
            </div>
            <div className="w-32">
              <div className="h-2 bg-slate-100 rounded-full overflow-hidden">
                <div
                  className="h-full bg-sf-deepNavy rounded-full transition-all duration-700"
                  style={{ width: `${stats?.program_progress_pct ?? 0}%` }}
                />
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Profile Details */}
      {profile && (
        <div className="card p-5">
          <h4 className="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-3">Profile Details</h4>
          <dl className="grid grid-cols-2 md:grid-cols-3 gap-4 text-sm">
            {[
              ["Gender", profile.gender],
              ["Date of Birth", profile.date_of_birth],
              ["Height", profile.height_cm ? `${profile.height_cm} cm` : null],
              ["Weight", profile.weight_kg ? `${profile.weight_kg} kg` : null],
              ["Fitness Goal", profile.fitness_goal?.replace(/_/g, " ")],
              ["Experience", profile.experience_level],
              ["Emergency Contact", profile.emergency_contact],
            ]
              .filter(([, v]) => v)
              .map(([label, value]) => (
                <div key={label as string}>
                  <dt className="text-slate-400 text-xs">{label}</dt>
                  <dd className="font-medium text-slate-700 capitalize mt-0.5">{value}</dd>
                </div>
              ))}
          </dl>
        </div>
      )}
    </div>
  );
}

function ProgramsTab({ userId, stats }: { userId: string; stats: any }) {
  return (
    <div className="space-y-4 animate-fade-in">
      {stats?.active_program_name ? (
        <div className="card p-5">
          <div className="flex items-start justify-between">
            <div>
              <p className="font-medium text-slate-900">{stats.active_program_name}</p>
              <p className="text-sm text-slate-500 mt-0.5">
                Started · {stats.program_progress_pct?.toFixed(0) ?? 0}% complete
              </p>
            </div>
            <span className="px-2.5 py-0.5 rounded-full text-xs font-medium bg-emerald-100 text-emerald-700">
              Active
            </span>
          </div>
          <div className="mt-3 h-2 bg-slate-100 rounded-full overflow-hidden">
            <div
              className="h-full bg-emerald-500 rounded-full transition-all duration-700"
              style={{ width: `${stats.program_progress_pct ?? 0}%` }}
            />
          </div>
        </div>
      ) : (
        <div className="card p-8 text-center">
          <Target className="h-8 w-8 text-slate-300 mx-auto mb-3" />
          <p className="text-sm text-slate-500">No active programs assigned</p>
          <Link href="/programs" className="text-sm text-sf-deepNavy hover:text-sf-deepNavy mt-2 inline-block">
            Browse Programs
          </Link>
        </div>
      )}
    </div>
  );
}

function ProgressTab({ userId }: { userId: string }) {
  return (
    <div className="animate-fade-in">
      <div className="card p-8 text-center">
        <BarChart3 className="h-8 w-8 text-slate-300 mx-auto mb-3" />
        <p className="text-sm text-slate-500 mb-3">Lihat grafik progres detail dan histori sesi</p>
        <Link href={`/progress/${userId}`} className="btn-primary inline-flex">
          <TrendingUp className="h-4 w-4" /> View Full Progress
        </Link>
      </div>
    </div>
  );
}

function PaymentsTab() {
  return (
    <div className="animate-fade-in space-y-4">
      <div className="card p-5">
        <h4 className="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-3">Subscription</h4>
        <div className="flex items-center justify-between">
          <div>
            <p className="font-medium text-slate-900">Pro Plan</p>
            <p className="text-sm text-slate-500">{formatCurrency(499000)} / month</p>
          </div>
          <span className="px-2.5 py-0.5 rounded-full text-xs font-medium bg-emerald-100 text-emerald-700">Active</span>
        </div>
      </div>
      <div className="card p-5">
        <h4 className="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-3">Payment History</h4>
        <p className="text-sm text-slate-400">No payment records to display</p>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
//  Skeleton
// ═══════════════════════════════════════════════════════════════

function DetailSkeleton() {
  return (
    <div className="space-y-6">
      <div className="skeleton h-4 w-28" />
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="card p-6 text-center space-y-4">
          <div className="skeleton h-20 w-20 rounded-2xl mx-auto" />
          <div className="skeleton h-6 w-32 mx-auto" />
          <div className="skeleton h-4 w-48 mx-auto" />
          <div className="space-y-2 text-left">
            {[1, 2, 3, 4].map((i) => <div key={i} className="skeleton h-5 w-full" />)}
          </div>
          <div className="skeleton h-10 w-full" />
        </div>
        <div className="lg:col-span-2 space-y-4">
          <div className="flex gap-4 border-b border-slate-200 pb-3">
            {[1, 2, 3, 4].map((i) => <div key={i} className="skeleton h-5 w-20" />)}
          </div>
          <div className="grid grid-cols-4 gap-3">
            {[1, 2, 3, 4].map((i) => <div key={i} className="card p-4"><div className="skeleton h-8 w-12 mx-auto mb-2" /><div className="skeleton h-3 w-16 mx-auto" /></div>)}
          </div>
          <div className="card p-5 space-y-3">
            <div className="skeleton h-4 w-24" />
            <div className="grid grid-cols-3 gap-4">
              {[1, 2, 3, 4, 5, 6].map((i) => <div key={i} className="skeleton h-10 w-full" />)}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
