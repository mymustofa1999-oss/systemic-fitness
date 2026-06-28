package handler

import (
	"context"
	"log/slog"

	"github.com/fitcoach/api/internal/service"
)

// imageResolver is a shared helper used by handlers to resolve image_id → image_url.
// Handlers that accept both image_id and image_url use this to convert upload IDs to URLs.
type imageResolver struct {
	uploadService *service.UploadService
}

// resolve takes an imageID and an optional imageURL. If imageID is provided, it looks up
// the upload and returns its URL, also linking the upload to the given entity.
// If imageID is empty, it returns imageURL as-is.
func (ir *imageResolver) resolve(ctx context.Context, imageID string, imageURL *string, entityType, entityID string) *string {
	if ir == nil || ir.uploadService == nil {
		return imageURL
	}
	if imageID == "" {
		return imageURL
	}
	url, err := ir.uploadService.ResolveImageURL(ctx, imageID, entityType, entityID)
	if err != nil {
		slog.Warn("[ImageResolver] failed to resolve image_id", "image_id", imageID, "error", err)
		return imageURL // fall back to provided URL
	}
	return &url
}
