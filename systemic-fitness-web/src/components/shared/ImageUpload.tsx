"use client";

import { useState, useRef, useCallback } from "react";
import { Upload, X, Loader2, ImageIcon } from "lucide-react";
import { cn } from "@/lib/utils";
import api from "@/lib/api";

interface ImageUploadProps {
  value?: string | null;          // current image URL
  onChange: (url: string | null, uploadId: string | null) => void;
  entityType?: string;            // e.g. 'food', 'group', 'challenge'
  entityId?: string;
  className?: string;
  aspectRatio?: "square" | "video" | "banner"; // aspect ratio preset
  placeholder?: string;
}

export function ImageUpload({
  value,
  onChange,
  entityType,
  entityId,
  className,
  aspectRatio = "square",
  placeholder = "Upload image",
}: ImageUploadProps) {
  const [uploading, setUploading] = useState(false);
  const [dragOver, setDragOver] = useState(false);
  const inputRef = useRef<HTMLInputElement>(null);

  const aspectClasses = {
    square: "aspect-square",
    video: "aspect-video",
    banner: "aspect-[3/1]",
  };

  const handleFile = useCallback(
    async (file: File) => {
      if (!file.type.startsWith("image/")) return;
      if (file.size > 5 * 1024 * 1024) {
        alert("File too large. Maximum size is 5MB");
        return;
      }

      setUploading(true);
      try {
        const formData = new FormData();
        formData.append("file", file);
        if (entityType) formData.append("entity_type", entityType);
        if (entityId) formData.append("entity_id", entityId);

        const res = await api.post("/api/uploads", formData, {
          headers: { "Content-Type": "multipart/form-data" },
        });

        const upload = res.data?.data;
        if (upload?.url) {
          onChange(upload.url, upload.id);
        }
      } catch {
        alert("Upload failed. Please try again.");
      } finally {
        setUploading(false);
      }
    },
    [entityType, entityId, onChange]
  );

  const handleDrop = useCallback(
    (e: React.DragEvent) => {
      e.preventDefault();
      setDragOver(false);
      const file = e.dataTransfer.files[0];
      if (file) handleFile(file);
    },
    [handleFile]
  );

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) handleFile(file);
    e.target.value = "";
  };

  const remove = () => {
    onChange(null, null);
  };

  return (
    <div className={cn("relative", className)}>
      {value ? (
        /* Preview */
        <div className={cn("relative rounded-lg overflow-hidden bg-slate-100", aspectClasses[aspectRatio])}>
          <img
            src={value}
            alt="Uploaded"
            className="w-full h-full object-cover"
          />
          <div className="absolute inset-0 bg-black/0 hover:bg-black/30 transition-colors group">
            <button
              type="button"
              onClick={remove}
              className="absolute top-2 right-2 p-1.5 rounded-full bg-black/50 text-white
                         opacity-0 group-hover:opacity-100 transition-opacity hover:bg-black/70"
            >
              <X className="h-4 w-4" />
            </button>
            <button
              type="button"
              onClick={() => inputRef.current?.click()}
              className="absolute bottom-2 right-2 px-3 py-1.5 rounded-lg bg-black/50 text-white text-xs font-medium
                         opacity-0 group-hover:opacity-100 transition-opacity hover:bg-black/70"
            >
              Replace
            </button>
          </div>
        </div>
      ) : (
        /* Upload Zone */
        <div
          onDragOver={(e) => { e.preventDefault(); setDragOver(true); }}
          onDragLeave={() => setDragOver(false)}
          onDrop={handleDrop}
          onClick={() => !uploading && inputRef.current?.click()}
          className={cn(
            "rounded-lg border-2 border-dashed flex flex-col items-center justify-center cursor-pointer transition-colors",
            aspectClasses[aspectRatio],
            dragOver
              ? "border-sf-systemBlue bg-sf-iceBlue"
              : "border-slate-200 bg-slate-50 hover:border-sf-systemBlue/40 hover:bg-sf-iceBlue/50",
            uploading && "pointer-events-none opacity-60"
          )}
        >
          {uploading ? (
            <>
              <Loader2 className="h-8 w-8 text-sf-deepNavy animate-spin" />
              <p className="text-xs text-slate-500 mt-2">Uploading...</p>
            </>
          ) : (
            <>
              <div className="h-10 w-10 rounded-full bg-slate-100 flex items-center justify-center mb-2">
                {dragOver ? (
                  <Upload className="h-5 w-5 text-sf-deepNavy" />
                ) : (
                  <ImageIcon className="h-5 w-5 text-slate-400" />
                )}
              </div>
              <p className="text-sm font-medium text-slate-600">{placeholder}</p>
              <p className="text-xs text-slate-400 mt-1">
                Drag & drop or click to browse
              </p>
              <p className="text-[10px] text-slate-300 mt-0.5">
                JPEG, PNG, GIF, WebP (max 5MB)
              </p>
            </>
          )}
        </div>
      )}

      <input
        ref={inputRef}
        type="file"
        accept="image/jpeg,image/png,image/gif,image/webp"
        onChange={handleInputChange}
        className="hidden"
      />
    </div>
  );
}
