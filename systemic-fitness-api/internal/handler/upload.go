package handler

import (
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"strings"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type UploadHandler struct {
	uploadService *service.UploadService
	maxSizeMB     int
}

func NewUploadHandler(us *service.UploadService, maxSizeMB int) *UploadHandler {
	return &UploadHandler{uploadService: us, maxSizeMB: maxSizeMB}
}

// POST /api/uploads
func (h *UploadHandler) Upload(w http.ResponseWriter, r *http.Request) {
	// Limit request body size
	maxBytes := int64(h.maxSizeMB) * 1024 * 1024
	r.Body = http.MaxBytesReader(w, r.Body, maxBytes)

	if err := r.ParseMultipartForm(maxBytes); err != nil {
		response.BadRequest(w, fmt.Sprintf("File too large. Maximum size is %dMB", h.maxSizeMB))
		return
	}
	defer r.MultipartForm.RemoveAll()

	file, header, err := r.FormFile("file")
	if err != nil {
		response.BadRequest(w, "Missing or invalid file field")
		return
	}
	defer file.Close()

	// Validate content type
	contentType := header.Header.Get("Content-Type")
	if contentType == "" {
		// Try to detect from first 512 bytes
		buf := make([]byte, 512)
		n, _ := file.Read(buf)
		contentType = http.DetectContentType(buf[:n])
		file.Seek(0, 0)
	}

	if !strings.HasPrefix(contentType, "image/") {
		response.BadRequest(w, "Only image files are allowed (JPEG, PNG, GIF, WebP)")
		return
	}

	userID := middleware.GetUserID(r.Context())

	// Optional entity linking
	entityType := r.FormValue("entity_type")
	entityID := r.FormValue("entity_id")

	input := &service.UploadInput{
		File:     file,
		FileName: header.Filename,
		FileSize: header.Size,
		MimeType: contentType,
		UserID:   userID,
	}
	if entityType != "" {
		input.EntityType = &entityType
	}
	if entityID != "" {
		input.EntityID = &entityID
	}

	upload, err := h.uploadService.Upload(r.Context(), input)
	if err != nil {
		if errors.Is(err, service.ErrFileTooLarge) {
			response.BadRequest(w, fmt.Sprintf("File too large. Maximum size is %dMB", h.maxSizeMB))
			return
		}
		if errors.Is(err, service.ErrUnsupportedFormat) {
			response.BadRequest(w, "Unsupported image format. Allowed: JPEG, PNG, GIF, WebP")
			return
		}
		slog.Error("[Upload] failed", "file", header.Filename, "error", err)
		response.InternalError(w, "Failed to upload file")
		return
	}

	response.Created(w, upload)
}

// GET /api/uploads/{id}
func (h *UploadHandler) GetByID(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	upload, err := h.uploadService.GetByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Upload not found")
			return
		}
		slog.Error("[Upload.GetByID] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to fetch upload")
		return
	}
	response.OK(w, upload)
}

// DELETE /api/uploads/{id}
func (h *UploadHandler) Delete(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	userID := middleware.GetUserID(r.Context())
	role := string(middleware.GetRole(r.Context()))

	if err := h.uploadService.Delete(r.Context(), id, userID, role); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Upload not found")
			return
		}
		if err.Error() == "forbidden" {
			response.Forbidden(w, "You can only delete your own uploads")
			return
		}
		slog.Error("[Upload.Delete] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to delete upload")
		return
	}
	response.SuccessMessage(w, "Upload deleted")
}

// GET /api/uploads/my
func (h *UploadHandler) ListMy(w http.ResponseWriter, r *http.Request) {
	userID := middleware.GetUserID(r.Context())
	params := paginationFromQuery(r)

	uploads, total, err := h.uploadService.ListByUser(r.Context(), userID, params)
	if err != nil {
		slog.Error("[Upload.ListMy] failed", "user_id", userID, "error", err)
		response.InternalError(w, "Failed to fetch uploads")
		return
	}

	meta := model.NewPaginationMeta(params.Page, params.Limit, total)
	response.OKPaginated(w, uploads, meta)
}
