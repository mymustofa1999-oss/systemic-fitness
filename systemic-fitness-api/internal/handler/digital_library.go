package handler

import (
	"errors"
	"log/slog"
	"net/http"
	"strconv"
	"strings"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/middleware"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type DigitalLibraryHandler struct {
	dlService     *service.DigitalLibraryService
	uploadService *service.UploadService
}

func NewDigitalLibraryHandler(dls *service.DigitalLibraryService, us *service.UploadService) *DigitalLibraryHandler {
	return &DigitalLibraryHandler{dlService: dls, uploadService: us}
}

// ─── Categories ─────────────────────────────────────────────────

// GET /api/digital-library/categories
func (h *DigitalLibraryHandler) ListCategories(w http.ResponseWriter, r *http.Request) {
	cats, err := h.dlService.ListCategories(r.Context())
	if err != nil {
		slog.Error("[DL.ListCategories] failed", "error", err)
		response.InternalError(w, "Failed to fetch categories")
		return
	}
	response.OK(w, cats)
}

// ─── Levels ─────────────────────────────────────────────────────

// GET /api/digital-library/levels
func (h *DigitalLibraryHandler) ListLevels(w http.ResponseWriter, r *http.Request) {
	levels, err := h.dlService.ListLevels(r.Context())
	if err != nil {
		slog.Error("[DL.ListLevels] failed", "error", err)
		response.InternalError(w, "Failed to fetch levels")
		return
	}
	response.OK(w, levels)
}

// ─── Movements ──────────────────────────────────────────────────

// GET /api/digital-library/movements?body_part=upper&category=fc&search=arm&page=1&limit=20
func (h *DigitalLibraryHandler) ListMovements(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	f := repository.DLMovementFilter{
		BodyPart: queryString(r, "body_part"),
		Category: queryString(r, "category"),
		Search:   params.Search,
	}

	movements, meta, err := h.dlService.ListMovements(r.Context(), params, f)
	if err != nil {
		slog.Error("[DL.ListMovements] failed", "error", err)
		response.InternalError(w, "Failed to fetch movements")
		return
	}
	response.OKPaginated(w, movements, meta)
}

// GET /api/digital-library/movements/{id}
func (h *DigitalLibraryHandler) GetMovement(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	m, err := h.dlService.GetMovement(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Movement not found")
			return
		}
		slog.Error("[DL.GetMovement] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to fetch movement")
		return
	}
	response.OK(w, m)
}

// POST /api/digital-library/movements
func (h *DigitalLibraryHandler) CreateMovement(w http.ResponseWriter, r *http.Request) {
	var input service.CreateMovementInput
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	m, err := h.dlService.CreateMovement(r.Context(), &input)
	if err != nil {
		if errors.Is(err, repository.ErrDuplicateName) {
			response.Conflict(w, "Movement name already exists")
			return
		}
		slog.Error("[DL.CreateMovement] failed", "name", input.Name, "error", err)
		response.InternalError(w, "Failed to create movement")
		return
	}
	response.Created(w, m)
}

// PUT /api/digital-library/movements/{id}
func (h *DigitalLibraryHandler) UpdateMovement(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input service.UpdateMovementInput
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	m, err := h.dlService.UpdateMovement(r.Context(), id, &input)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Movement not found")
			return
		}
		if errors.Is(err, repository.ErrDuplicateName) {
			response.Conflict(w, "Movement name already exists")
			return
		}
		slog.Error("[DL.UpdateMovement] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to update movement")
		return
	}
	response.OK(w, m)
}

// DELETE /api/digital-library/movements/{id}
func (h *DigitalLibraryHandler) DeleteMovement(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.dlService.DeleteMovement(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Movement not found")
			return
		}
		slog.Error("[DL.DeleteMovement] failed", "id", id, "error", err)
		response.InternalError(w, "Failed to delete movement")
		return
	}
	response.SuccessMessage(w, "Movement deleted")
}

// ─── Menu Items ─────────────────────────────────────────────────

// GET /api/digital-library/categories/{code}/menu?level=3
func (h *DigitalLibraryHandler) ListMenuItems(w http.ResponseWriter, r *http.Request) {
	code := chi.URLParam(r, "code")
	var levelNum *int
	if v := r.URL.Query().Get("level"); v != "" {
		n, err := strconv.Atoi(v)
		if err != nil {
			response.BadRequest(w, "Invalid level parameter")
			return
		}
		levelNum = &n
	}

	items, err := h.dlService.ListMenuItems(r.Context(), code, levelNum)
	if err != nil {
		slog.Error("[DL.ListMenuItems] failed", "code", code, "error", err)
		response.InternalError(w, "Failed to fetch menu items")
		return
	}
	response.OK(w, items)
}

// ─── Isolate Items ──────────────────────────────────────────────

// GET /api/digital-library/categories/{code}/isolate?position=sit
func (h *DigitalLibraryHandler) ListIsolateItems(w http.ResponseWriter, r *http.Request) {
	code := chi.URLParam(r, "code")
	position := queryString(r, "position")

	items, err := h.dlService.ListIsolateItems(r.Context(), code, position)
	if err != nil {
		slog.Error("[DL.ListIsolateItems] failed", "code", code, "error", err)
		response.InternalError(w, "Failed to fetch isolate items")
		return
	}
	response.OK(w, items)
}

// ─── Dynamic Items ──────────────────────────────────────────────

// GET /api/digital-library/categories/{code}/dynamic
func (h *DigitalLibraryHandler) ListDynamicItems(w http.ResponseWriter, r *http.Request) {
	code := chi.URLParam(r, "code")

	items, err := h.dlService.ListDynamicItems(r.Context(), code)
	if err != nil {
		slog.Error("[DL.ListDynamicItems] failed", "code", code, "error", err)
		response.InternalError(w, "Failed to fetch dynamic items")
		return
	}
	response.OK(w, items)
}

// ─── Program Overview ───────────────────────────────────────────

// GET /api/digital-library/categories/{code}/program
func (h *DigitalLibraryHandler) GetProgramOverview(w http.ResponseWriter, r *http.Request) {
	code := chi.URLParam(r, "code")

	overview, err := h.dlService.GetProgramOverview(r.Context(), code)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Category not found")
			return
		}
		slog.Error("[DL.GetProgramOverview] failed", "code", code, "error", err)
		response.InternalError(w, "Failed to fetch program overview")
		return
	}
	response.OK(w, overview)
}

// ─── Upload Image for Movement ──────────────────────────────────

// POST /api/digital-library/movements/{id}/upload-image
func (h *DigitalLibraryHandler) UploadMovementImage(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")

	// Verify movement exists
	m, err := h.dlService.GetMovement(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Movement not found")
			return
		}
		response.InternalError(w, "Failed to fetch movement")
		return
	}

	// Parse multipart form
	if err := r.ParseMultipartForm(10 << 20); err != nil { // 10MB max
		response.BadRequest(w, "File too large or invalid form data")
		return
	}

	file, header, err := r.FormFile("image")
	if err != nil {
		response.BadRequest(w, "Image file is required")
		return
	}
	defer file.Close()

	// Detect content type
	contentType := header.Header.Get("Content-Type")
	if contentType == "" {
		buf := make([]byte, 512)
		n, _ := file.Read(buf)
		contentType = http.DetectContentType(buf[:n])
		file.Seek(0, 0)
	}
	if !strings.HasPrefix(contentType, "image/") {
		response.BadRequest(w, "Only image files are allowed")
		return
	}

	userID := middleware.GetUserID(r.Context())
	entityType := "dl_movement"
	entityID := m.ID

	uploadInput := &service.UploadInput{
		File:       file,
		FileName:   header.Filename,
		FileSize:   header.Size,
		MimeType:   contentType,
		UserID:     userID,
		EntityType: &entityType,
		EntityID:   &entityID,
	}

	upload, err := h.uploadService.Upload(r.Context(), uploadInput)
	if err != nil {
		slog.Error("[DL.UploadMovementImage] upload failed", "id", id, "error", err)
		response.InternalError(w, "Failed to upload image")
		return
	}

	// Update movement image_url
	imageURL := upload.URL
	updateInput := &service.UpdateMovementInput{
		Name:           m.Name,
		BodyPart:       m.BodyPart,
		VideoURLMale:   m.VideoURLMale,
		VideoURLFemale: m.VideoURLFemale,
		ImageURL:       &imageURL,
		Instructions:   m.Instructions,
		Categories:     m.Categories,
		Type:           m.Type,
		Pattern:        m.Pattern,
		Level:          m.Level,
	}

	updated, err := h.dlService.UpdateMovement(r.Context(), id, updateInput)
	if err != nil {
		slog.Error("[DL.UploadMovementImage] update failed", "id", id, "error", err)
		response.InternalError(w, "Image uploaded but failed to update movement")
		return
	}

	response.OK(w, updated)
}
