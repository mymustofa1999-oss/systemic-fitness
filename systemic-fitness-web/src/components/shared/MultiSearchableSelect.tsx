"use client";

import { useState, useRef, useEffect } from "react";
import * as Popover from "@radix-ui/react-popover";
import { Search, ChevronDown, X, Check } from "lucide-react";
import { cn } from "@/lib/utils";

export interface SearchableSelectOption {
  value: string;
  label: string;
  sublabel?: string;
  section?: string;
  extractedCategory?: string;
}

interface MultiSearchableSelectProps {
  options: SearchableSelectOption[];
  value: string; // comma separated values
  onChange: (value: string) => void;
  placeholder?: string;
  searchPlaceholder?: string;
  className?: string;
  disabled?: boolean;
}

export function MultiSearchableSelect({
  options,
  value,
  onChange,
  placeholder = "Pilih...",
  searchPlaceholder = "Cari...",
  className,
  disabled,
}: MultiSearchableSelectProps) {
  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState("");
  const inputRef = useRef<HTMLInputElement>(null);

  const selectedValues = value ? value.split(",").map(v => v.trim()).filter(Boolean) : [];
  
  const displayLabels = selectedValues.map(val => {
    const opt = options.find(o => o.value === val);
    return opt ? opt.label : val;
  });
  
  const displayLabel = displayLabels.length > 0 
    ? displayLabels.join(", ")
    : placeholder;

  const filtered = options.filter((o) =>
    o.label.toLowerCase().includes(search.toLowerCase()) ||
    (o.sublabel && o.sublabel.toLowerCase().includes(search.toLowerCase()))
  );

  useEffect(() => {
    if (open) {
      setTimeout(() => inputRef.current?.focus(), 0);
    } else {
      setSearch("");
    }
  }, [open]);

  const toggleValue = (val: string) => {
    if (selectedValues.includes(val)) {
      onChange(selectedValues.filter(v => v !== val).join(", "));
    } else {
      onChange([...selectedValues, val].join(", "));
    }
  };

  return (
    <Popover.Root open={open} onOpenChange={setOpen}>
      <Popover.Trigger asChild disabled={disabled}>
        <button
          type="button"
          className={cn(
            "w-full flex items-center justify-between gap-2 border border-slate-200 rounded-lg px-3 py-2 text-sm bg-white",
            "hover:border-slate-300 focus:outline-none focus:ring-2 focus:ring-sf-warmGold/40 focus:border-sf-deepNavy",
            "transition-colors text-left",
            disabled && "opacity-50 cursor-not-allowed",
            className
          )}
        >
          <span className={cn("truncate", selectedValues.length === 0 && "text-slate-400")}>
            {displayLabel}
          </span>
          <div className="flex items-center gap-1 shrink-0">
            {selectedValues.length > 0 && (
              <span
                role="button"
                onClick={(e) => { e.stopPropagation(); onChange(""); }}
                className="p-0.5 rounded hover:bg-slate-100 text-slate-400 hover:text-slate-600"
              >
                <X className="h-3 w-3" />
              </span>
            )}
            <ChevronDown className={cn("h-3.5 w-3.5 text-slate-400 transition-transform", open && "rotate-180")} />
          </div>
        </button>
      </Popover.Trigger>

      <Popover.Portal>
        <Popover.Content
          align="start"
          sideOffset={4}
          className="z-50 min-w-[var(--radix-popover-trigger-width)] w-[var(--radix-popover-trigger-width)] md:w-auto md:min-w-[260px] bg-white rounded-lg shadow-lg border border-slate-200 overflow-hidden animate-slide-in"
        >
          {/* Search input */}
          <div className="p-2 border-b border-slate-100">
            <div className="relative">
              <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-slate-400" />
              <input
                ref={inputRef}
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="w-full pl-8 pr-3 py-1.5 text-sm border border-slate-200 rounded-md focus:outline-none focus:ring-1 focus:ring-sf-warmGold/40 focus:border-sf-deepNavy"
                placeholder={searchPlaceholder}
              />
            </div>
          </div>

          {/* Options */}
          <div className="max-h-[250px] overflow-y-auto py-1 custom-scrollbar">
            {filtered.length === 0 ? (
              <div className="px-3 py-2 text-sm text-slate-500 text-center">
                Tidak ditemukan
              </div>
            ) : (
              (() => {
                // Group options by section
                const grouped = filtered.reduce((acc, opt) => {
                  const section = opt.section || "";
                  if (!acc[section]) acc[section] = [];
                  acc[section].push(opt);
                  return acc;
                }, {} as Record<string, SearchableSelectOption[]>);
                
                return Object.entries(grouped).map(([section, opts]) => (
                  <div key={section}>
                    {section && (
                      <div className="px-3 py-1 text-[10px] font-bold text-slate-400 uppercase tracking-wider bg-slate-50/50 sticky top-0">
                        {section}
                      </div>
                    )}
                    {opts.map((option) => {
                      const isSelected = selectedValues.includes(option.value);
                      return (
                        <button
                          key={option.value}
                          type="button"
                          onClick={() => toggleValue(option.value)}
                          className={cn(
                            "w-full text-left px-3 py-2 text-sm hover:bg-slate-50 transition-colors flex items-center justify-between",
                            isSelected && "bg-sf-warmGold/10 text-sf-deepNavy font-medium",
                          )}
                        >
                          <div className={cn("flex flex-col", !option.sublabel && "items-start justify-center h-[36px]")}>
                            <span className="truncate w-full">{option.label}</span>
                            {option.sublabel && (
                              <span className="text-[10px] text-slate-500 mt-0.5">{option.sublabel}</span>
                            )}
                          </div>
                          {isSelected && <Check className="h-4 w-4 text-sf-deepNavy" />}
                        </button>
                      );
                    })}
                  </div>
                ));
              })()
            )}
          </div>
        </Popover.Content>
      </Popover.Portal>
    </Popover.Root>
  );
}
