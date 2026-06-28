"use client";

import { Search, X } from "lucide-react";
import { useEffect, useRef, useState } from "react";

interface SearchInputProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  debounceMs?: number;
}

export function SearchInput({ value, onChange, placeholder = "Search...", debounceMs = 300 }: SearchInputProps) {
  const [local, setLocal] = useState(value);
  const onChangeRef = useRef(onChange);
  onChangeRef.current = onChange;

  useEffect(() => {
    const t = setTimeout(() => onChangeRef.current(local), debounceMs);
    return () => clearTimeout(t);
  }, [local, debounceMs]);

  useEffect(() => { setLocal(value); }, [value]);

  return (
    <div className="relative">
      <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
      <input
        type="text"
        value={local}
        onChange={(e) => setLocal(e.target.value)}
        placeholder={placeholder}
        className="input pl-10 pr-9 w-64"
      />
      {local && (
        <button
          type="button"
          className="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600"
          onClick={() => { setLocal(""); onChangeRef.current(""); }}
        >
          <X className="h-4 w-4" />
        </button>
      )}
    </div>
  );
}
