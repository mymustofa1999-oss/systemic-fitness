import { cn } from "@/lib/utils";
import { Check } from "lucide-react";

interface MultiSelectCardProps {
  value: string;
  selectedList: string[];
  label: string;
  onToggle: (val: string) => void;
}

export function MultiSelectCard({
  value,
  selectedList,
  label,
  onToggle,
}: MultiSelectCardProps) {
  const isSelected = selectedList.includes(value);

  return (
    <div
      onClick={() => onToggle(value)}
      className={cn(
        "cursor-pointer rounded-xl border p-4 transition-all duration-200 flex items-start group",
        isSelected
          ? "bg-sf-warmGold/10 border-sf-warmGold dark:bg-sf-warmGold/20"
          : "bg-bg-card border-border-color hover:border-sf-warmGold/50"
      )}
    >
      <div
        className={cn(
          "w-5 h-5 rounded-[6px] border-2 flex items-center justify-center shrink-0 mt-0.5 mr-3 transition-colors",
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
      </div>
    </div>
  );
}
