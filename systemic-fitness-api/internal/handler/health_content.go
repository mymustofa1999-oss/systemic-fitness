package handler

import (
	"errors"
	"log/slog"
	"net/http"

	"github.com/go-chi/chi/v5"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

type HealthContentHandler struct {
	healthService *service.HealthContentService
}

func NewHealthContentHandler(hs *service.HealthContentService) *HealthContentHandler {
	return &HealthContentHandler{healthService: hs}
}

// ─── Public Endpoints (Client Web & Mobile App) ───────────────────────

// GET /api/health-news
func (h *HealthContentHandler) ListArticlesPublic(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	articles, meta, err := h.healthService.ListArticles(r.Context(), params, params.Search, true)
	if err != nil {
		slog.Error("[HealthContent.ListArticlesPublic] failed", "error", err)
		response.InternalError(w, "Failed to fetch health news")
		return
	}
	response.OKPaginated(w, articles, meta)
}

// GET /api/doctor-videos
func (h *HealthContentHandler) ListVideosPublic(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	videos, meta, err := h.healthService.ListVideos(r.Context(), params, params.Search, true)
	if err != nil {
		slog.Error("[HealthContent.ListVideosPublic] failed", "error", err)
		response.InternalError(w, "Failed to fetch doctor videos")
		return
	}
	response.OKPaginated(w, videos, meta)
}

// ─── Admin CMS Endpoints ──────────────────────────────────────────────

// GET /api/cms/health-news
func (h *HealthContentHandler) ListArticlesAdmin(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	articles, meta, err := h.healthService.ListArticles(r.Context(), params, params.Search, false)
	if err != nil {
		slog.Error("[HealthContent.ListArticlesAdmin] failed", "error", err)
		response.InternalError(w, "Failed to fetch health news")
		return
	}
	response.OKPaginated(w, articles, meta)
}

// GET /api/cms/health-news/{id}
func (h *HealthContentHandler) GetArticle(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	a, err := h.healthService.GetArticleByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Article not found")
			return
		}
		response.InternalError(w, "Failed to fetch article")
		return
	}
	response.OK(w, a)
}

// POST /api/cms/health-news
func (h *HealthContentHandler) CreateArticle(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Title       string  `json:"title" validate:"required,min=1,max=255"`
		Content     string  `json:"content" validate:"required"`
		ImageURL    string  `json:"image_url" validate:"required,url"`
		Source      string  `json:"source" validate:"required,max=100"`
		IsPublished bool    `json:"is_published"`
		TitleEN     *string `json:"title_en,omitempty"`
		ContentEN   *string `json:"content_en,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	a := &model.HealthArticle{
		Title:       input.Title,
		Content:     input.Content,
		ImageURL:    input.ImageURL,
		Source:      input.Source,
		IsPublished: input.IsPublished,
		TitleEN:     input.TitleEN,
		ContentEN:   input.ContentEN,
	}
	if err := h.healthService.CreateArticle(r.Context(), a); err != nil {
		slog.Error("[HealthContent.CreateArticle] failed", "error", err)
		response.InternalError(w, "Failed to create article")
		return
	}
	response.Created(w, a)
}

// PUT /api/cms/health-news/{id}
func (h *HealthContentHandler) UpdateArticle(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input struct {
		Title       string  `json:"title" validate:"required,min=1,max=255"`
		Content     string  `json:"content" validate:"required"`
		ImageURL    string  `json:"image_url" validate:"required,url"`
		Source      string  `json:"source" validate:"required,max=100"`
		IsPublished bool    `json:"is_published"`
		TitleEN     *string `json:"title_en,omitempty"`
		ContentEN   *string `json:"content_en,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	a := &model.HealthArticle{
		ID:          id,
		Title:       input.Title,
		Content:     input.Content,
		ImageURL:    input.ImageURL,
		Source:      input.Source,
		IsPublished: input.IsPublished,
		TitleEN:     input.TitleEN,
		ContentEN:   input.ContentEN,
	}
	if err := h.healthService.UpdateArticle(r.Context(), a); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Article not found")
			return
		}
		slog.Error("[HealthContent.UpdateArticle] failed", "error", err)
		response.InternalError(w, "Failed to update article")
		return
	}
	response.OK(w, a)
}

// DELETE /api/cms/health-news/{id}
func (h *HealthContentHandler) DeleteArticle(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.healthService.DeleteArticle(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Article not found")
			return
		}
		response.InternalError(w, "Failed to delete article")
		return
	}
	response.SuccessMessage(w, "Article deleted")
}

// GET /api/cms/doctor-videos
func (h *HealthContentHandler) ListVideosAdmin(w http.ResponseWriter, r *http.Request) {
	params := paginationFromQuery(r)
	videos, meta, err := h.healthService.ListVideos(r.Context(), params, params.Search, false)
	if err != nil {
		slog.Error("[HealthContent.ListVideosAdmin] failed", "error", err)
		response.InternalError(w, "Failed to fetch doctor videos")
		return
	}
	response.OKPaginated(w, videos, meta)
}

// GET /api/cms/doctor-videos/{id}
func (h *HealthContentHandler) GetVideo(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	v, err := h.healthService.GetVideoByID(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Video not found")
			return
		}
		response.InternalError(w, "Failed to fetch video")
		return
	}
	response.OK(w, v)
}

// POST /api/cms/doctor-videos
func (h *HealthContentHandler) CreateVideo(w http.ResponseWriter, r *http.Request) {
	var input struct {
		Title           string  `json:"title" validate:"required,min=1,max=255"`
		Description     string  `json:"description"`
		VideoURL        string  `json:"video_url" validate:"required,url"`
		ThumbnailURL    string  `json:"thumbnail_url" validate:"required,url"`
		DoctorName      string  `json:"doctor_name" validate:"required,max=100"`
		DoctorSpecialty string  `json:"doctor_specialty" validate:"required,max=100"`
		IsPublished     bool    `json:"is_published"`
		TitleEN         *string `json:"title_en,omitempty"`
		DescriptionEN   *string `json:"description_en,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	v := &model.DoctorVideo{
		Title:           input.Title,
		Description:     input.Description,
		VideoURL:        input.VideoURL,
		ThumbnailURL:    input.ThumbnailURL,
		DoctorName:      input.DoctorName,
		DoctorSpecialty: input.DoctorSpecialty,
		IsPublished:     input.IsPublished,
		TitleEN:         input.TitleEN,
		DescriptionEN:   input.DescriptionEN,
	}
	if err := h.healthService.CreateVideo(r.Context(), v); err != nil {
		slog.Error("[HealthContent.CreateVideo] failed", "error", err)
		response.InternalError(w, "Failed to create video")
		return
	}
	response.Created(w, v)
}

// PUT /api/cms/doctor-videos/{id}
func (h *HealthContentHandler) UpdateVideo(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	var input struct {
		Title           string  `json:"title" validate:"required,min=1,max=255"`
		Description     string  `json:"description"`
		VideoURL        string  `json:"video_url" validate:"required,url"`
		ThumbnailURL    string  `json:"thumbnail_url" validate:"required,url"`
		DoctorName      string  `json:"doctor_name" validate:"required,max=100"`
		DoctorSpecialty string  `json:"doctor_specialty" validate:"required,max=100"`
		IsPublished     bool    `json:"is_published"`
		TitleEN         *string `json:"title_en,omitempty"`
		DescriptionEN   *string `json:"description_en,omitempty"`
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	v := &model.DoctorVideo{
		ID:              id,
		Title:           input.Title,
		Description:     input.Description,
		VideoURL:        input.VideoURL,
		ThumbnailURL:    input.ThumbnailURL,
		DoctorName:      input.DoctorName,
		DoctorSpecialty: input.DoctorSpecialty,
		IsPublished:     input.IsPublished,
		TitleEN:         input.TitleEN,
		DescriptionEN:   input.DescriptionEN,
	}
	if err := h.healthService.UpdateVideo(r.Context(), v); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Video not found")
			return
		}
		slog.Error("[HealthContent.UpdateVideo] failed", "error", err)
		response.InternalError(w, "Failed to update video")
		return
	}
	response.OK(w, v)
}

// DELETE /api/cms/doctor-videos/{id}
func (h *HealthContentHandler) DeleteVideo(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")
	if err := h.healthService.DeleteVideo(r.Context(), id); err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Video not found")
			return
		}
		response.InternalError(w, "Failed to delete video")
		return
	}
	response.SuccessMessage(w, "Video deleted")
}
