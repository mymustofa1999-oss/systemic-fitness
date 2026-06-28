"use client";

import { useState } from "react";
import { useSession } from "next-auth/react";
import { User, Bell, Shield, Loader2 } from "lucide-react";
import { getInitials } from "@/lib/utils";
import { apiPut } from "@/lib/api";
import { toast } from "@/stores/toastStore";

export default function SettingsPage() {
  const { data: session, update } = useSession();
  const user = session?.user;

  const [fullName, setFullName] = useState(user?.name || "");
  const [saving, setSaving] = useState(false);

  // Change password state
  const [showPwForm, setShowPwForm] = useState(false);
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [changingPw, setChangingPw] = useState(false);

  async function handleSaveProfile() {
    if (!fullName.trim()) {
      toast.error("Name cannot be empty");
      return;
    }
    setSaving(true);
    try {
      await apiPut(`/api/users/${user?.id}`, { full_name: fullName.trim() });
      await update({ name: fullName.trim() });
      toast.success("Profile updated successfully");
    } catch (err: any) {
      toast.error(err.message || "Failed to update profile");
    } finally {
      setSaving(false);
    }
  }

  async function handleChangePassword() {
    if (!currentPassword || !newPassword) {
      toast.error("Please fill in all password fields");
      return;
    }
    if (newPassword.length < 8) {
      toast.error("New password must be at least 8 characters");
      return;
    }
    if (newPassword !== confirmPassword) {
      toast.error("Passwords do not match");
      return;
    }
    setChangingPw(true);
    try {
      await apiPut(`/api/users/${user?.id}/password`, {
        current_password: currentPassword,
        new_password: newPassword,
      });
      toast.success("Password changed successfully");
      setShowPwForm(false);
      setCurrentPassword("");
      setNewPassword("");
      setConfirmPassword("");
    } catch (err: any) {
      toast.error(err.message || "Failed to change password");
    } finally {
      setChangingPw(false);
    }
  }

  return (
    <div className="space-y-6 max-w-3xl">
      <h1 className="text-2xl font-bold text-slate-900">Settings</h1>

      {/* Profile */}
      <div className="card p-6">
        <div className="flex items-center gap-2 mb-4">
          <User className="h-4 w-4 text-slate-400" />
          <h3 className="text-sm font-semibold text-slate-700">Profile</h3>
        </div>
        <div className="flex items-start gap-5">
          <div className="h-16 w-16 rounded-2xl bg-sf-iceBlue text-sf-deepNavy flex items-center justify-center text-xl font-bold">
            {getInitials(user?.name || "U")}
          </div>
          <div className="flex-1 space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="label">Full Name</label>
                <input
                  className="input"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                />
              </div>
              <div>
                <label className="label">Email</label>
                <input className="input" defaultValue={user?.email} disabled />
              </div>
            </div>
            <button
              className="btn-primary"
              disabled={saving}
              onClick={handleSaveProfile}
            >
              {saving && <Loader2 className="h-4 w-4 animate-spin mr-1" />}
              {saving ? "Saving..." : "Save Changes"}
            </button>
          </div>
        </div>
      </div>

      {/* Notifications */}
      <div className="card p-6">
        <div className="flex items-center gap-2 mb-4">
          <Bell className="h-4 w-4 text-slate-400" />
          <h3 className="text-sm font-semibold text-slate-700">Notifications</h3>
        </div>
        <p className="text-sm text-slate-500">Notification preferences are managed from your profile settings.</p>
      </div>

      {/* Security */}
      <div className="card p-6">
        <div className="flex items-center gap-2 mb-4">
          <Shield className="h-4 w-4 text-slate-400" />
          <h3 className="text-sm font-semibold text-slate-700">Security</h3>
        </div>
        {!showPwForm ? (
          <button className="btn-secondary" onClick={() => setShowPwForm(true)}>
            Change Password
          </button>
        ) : (
          <div className="space-y-3 max-w-sm">
            <div>
              <label className="label">Current Password</label>
              <input
                type="password"
                className="input"
                value={currentPassword}
                onChange={(e) => setCurrentPassword(e.target.value)}
              />
            </div>
            <div>
              <label className="label">New Password</label>
              <input
                type="password"
                className="input"
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                placeholder="Min 8 characters"
              />
            </div>
            <div>
              <label className="label">Confirm New Password</label>
              <input
                type="password"
                className="input"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
              />
            </div>
            <div className="flex gap-2">
              <button
                className="btn-primary"
                disabled={changingPw}
                onClick={handleChangePassword}
              >
                {changingPw && <Loader2 className="h-4 w-4 animate-spin mr-1" />}
                {changingPw ? "Changing..." : "Change Password"}
              </button>
              <button
                className="btn-secondary"
                onClick={() => {
                  setShowPwForm(false);
                  setCurrentPassword("");
                  setNewPassword("");
                  setConfirmPassword("");
                }}
              >
                Cancel
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
