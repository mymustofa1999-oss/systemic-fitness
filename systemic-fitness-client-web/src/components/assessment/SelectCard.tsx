import { cn } from "@/lib/utils";
import { Check } from "lucide-react";

interface SelectCardProps<T> {
  value: T;
  groupValue?: T;
  label: string;
  hint?: string;
  onChanged: (val: T) => void;
}

export function SelectCard<T>({
  value,
  groupValue,
  label,
  hint,
  onChanged,
}: SelectCardProps<T>) {
  const isSelected = value === groupValue;

  return (
    <div
      onClick={() => onChanged(value)}
      className={cn(
        "cursor-pointer rounded-xl border p-4 transition-all duration-200 flex items-start group",
        isSelected
          ? "bg-sf-warmGold/10 border-sf-warmGold dark:bg-sf-warmGold/20"
          : "bg-bg-card border-border-color hover:border-sf-warmGold/50"
      )}
    >
      {/* Radio Circle */}
      <div
        className={cn(
          "w-5 h-5 rounded-full border-2 flex items-center justify-center shrink-0 mt-0.5 mr-3 transition-colors",
          isSelected
            ? "border-sf-warmGold bg-sf-warmGold"
            : "border-text-secondary/30 group-hover:border-sf-warmGold/50"
        )}
      >
        {isSelected && <Check size={14} className="text-white" strokeWidth={3} />}
      </div>

      <div className="flex-1">
        <p
          className={cn(
            "text-sm leading-snug transition-colors font-medium",
            isSelected ? "text-sf-warmGoldDark dark:text-sf-warmGold" : "text-text-primary"
          )}
        >
          {label}
        </p>
        {hint && (
          <p
            className={cn(
              "text-xs mt-1 leading-relaxed",
              isSelected ? "text-sf-warmGoldDark/80 dark:text-sf-warmGold/80" : "text-text-secondary"
            )}
          >
            {hint}
          </p>
        )}
      </div>
    </div>
  );
}
