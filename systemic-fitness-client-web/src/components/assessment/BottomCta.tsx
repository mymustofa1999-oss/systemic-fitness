import { cn } from "@/lib/utils";

interface BottomCtaProps {
  label: string;
  onPressed?: () => void;
  hint?: string | null;
  disabled?: boolean;
}

export function BottomCta({ label, onPressed, hint, disabled }: BottomCtaProps) {
  const isDisabled = disabled || !onPressed;

  return (
    <div className="sticky bottom-0 left-0 right-0 z-40 bg-bg-primary/95 backdrop-blur-md border-t border-border-color pb-safe pt-4 px-5 max-w-lg mx-auto w-full">
      <button
        onClick={onPressed}
        disabled={isDisabled}
        className={cn(
          "w-full py-3.5 rounded-xl text-sm font-bold tracking-wide transition-all",
          isDisabled
            ? "bg-bg-secondary text-text-secondary cursor-not-allowed"
            : "bg-sf-deepNavy text-white hover:bg-sf-deepNavy/90 active:scale-[0.98] shadow-md dark:bg-sf-warmGold dark:text-sf-deepNavy dark:hover:bg-sf-warmGold/90"
        )}
      >
        {label}
      </button>
      {hint && (
        <p className="text-center text-xs text-text-secondary mt-2.5 mb-2 font-medium">
          {hint}
        </p>
      )}
    </div>
  );
}
