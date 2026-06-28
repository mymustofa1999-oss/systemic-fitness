import { cn } from "@/lib/utils";
import { ChevronDown } from "lucide-react";
import React from "react";

interface Option {
  label: string;
  value: string;
}

interface PickerFieldProps extends React.SelectHTMLAttributes<HTMLSelectElement> {
  label: string;
  options: Option[];
  placeholder?: string;
}

export function PickerField({
  label,
  options,
  placeholder,
  className,
  disabled,
  value,
  ...props
}: PickerFieldProps) {
  const hasValue = value !== undefined && value !== null && value !== "";

  return (
    <div className={cn("flex flex-col space-y-1.5", className)}>
      <label className="text-[11px] uppercase tracking-wide font-semibold text-text-secondary">
        {label}
      </label>
      <div className="relative">
        <select
          disabled={disabled}
          value={value}
          className={cn(
            "w-full appearance-none rounded-xl border p-3.5 pr-10 text-sm transition-all focus:outline-none focus:ring-2 focus:ring-sf-warmGold/50",
            disabled
              ? "bg-bg-secondary/50 text-text-secondary cursor-not-allowed opacity-70"
              : "bg-bg-card cursor-pointer",
            hasValue
              ? "border-sf-warmGold text-text-primary font-medium"
              : "border-border-color text-text-secondary font-normal"
          )}
          {...props}
        >
          {placeholder && (
            <option value="" disabled hidden>
              {placeholder}
            </option>
          )}
          {options.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
            </option>
          ))}
        </select>
        <div className="absolute inset-y-0 right-3 flex items-center pointer-events-none">
          <ChevronDown
            size={18}
            className={cn("transition-colors", hasValue ? "text-sf-warmGold" : "text-text-secondary")}
          />
        </div>
      </div>
    </div>
  );
}
