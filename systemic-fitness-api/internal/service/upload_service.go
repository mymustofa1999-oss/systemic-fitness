package service

import (
	"context"
	"errors"
	"fmt"
	"image"
	_ "image/gif"
	_ "image/jpeg"
	_ "image/png"
	"io"
	"log/slog"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/chai2010/webp"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

var (
	ErrFileTooLarge      = errors.New("file exceeds maximum upload size")
	ErrUnsupportedFormat = errors.New("unsupported image format")
)

var allowedMimeTypes = map[string]bool{
	"image/jpeg": true,
	"image/png":  true,
	"image/gif":  true,
	"image/webp": true,
}

type UploadService struct {
	repo       *repository.UploadRepository
	logger     *slog.Logger
	uploadDir  string
	maxSizeMB  int
	baseURL    string
}

func NewUploadService(
	repo *repository.UploadRepository,
	logger *slog.Logger,
	uploadDir string,
	maxSizeMB int,
	baseURL string,
) *UploadService {
	return &UploadService{
		repo:      repo,
		logger:    logger,
		uploadDir: uploadDir,
		maxSizeMB: maxSizeMB,
		baseURL:   baseURL,
	}
}

type UploadInput struct {
	File       io.ReadSeeker
	FileName   string
	FileSize   int64
	MimeType   string
	UserID     string
	EntityType *string
	EntityID   *string
}

func (s *UploadService) Upload(ctx context.Context, input *UploadInput) (*model.Upload, error) {
	// Validate file size
	maxBytes := int64(s.maxSizeMB) * 1024 * 1024
	if input.FileSize > maxBytes {
		return nil, ErrFileTooLarge
	}

	// Validate MIME type
	if !allowedMimeTypes[input.MimeType] {
		return nil, ErrUnsupportedFormat
	}

	// Ensure upload directory exists
	if err := os.MkdirAll(s.uploadDir, 0755); err != nil {
		return nil, fmt.Errorf("creating upload dir: %w", err)
	}

	// Generate unique stored name
	storedName := fmt.Sprintf("%d_%s.webp", time.Now().UnixNano(), sanitizeFileName(input.FileName))

	fullPath := filepath.Join(s.uploadDir, storedName)

	// Decode source image
	input.File.Seek(0, io.SeekStart)
	img, _, err := image.Decode(input.File)
	if err != nil {
		return nil, fmt.Errorf("decoding image: %w", err)
	}

	// Get dimensions
	bounds := img.Bounds()
	width := bounds.Dx()
	height := bounds.Dy()

	// Encode as WebP and write to disk
	outFile, err := os.Create(fullPath)
	if err != nil {
		return nil, fmt.Errorf("creating output file: %w", err)
	}
	defer outFile.Close()

	if err := webp.Encode(outFile, img, &webp.Options{Quality: 80}); err != nil {
		os.Remove(fullPath)
		return nil, fmt.Errorf("encoding webp: %w", err)
	}

	// Get final file size after conversion
	stat, err := os.Stat(fullPath)
	if err != nil {
		os.Remove(fullPath)
		return nil, fmt.Errorf("stat output file: %w", err)
	}

	upload := &model.Upload{
		OriginalName: input.FileName,
		StoredName:   storedName,
		MimeType:     "image/webp",
		SizeBytes:    stat.Size(),
		Width:        &width,
		Height:       &height,
		Path:         fullPath,
		URL:          s.baseURL + "/uploads/" + storedName,
		UploadedBy:   input.UserID,
		EntityType:   input.EntityType,
		EntityID:     input.EntityID,
	}

	if err := s.repo.Create(ctx, upload); err != nil {
		os.Remove(fullPath)
		return nil, fmt.Errorf("saving upload record: %w", err)
	}

	s.logger.Info("file uploaded",
		"id", upload.ID,
		"original", input.FileName,
		"stored", storedName,
		"size_bytes", stat.Size(),
		"user_id", input.UserID,
	)

	return upload, nil
}

func (s *UploadService) GetByID(ctx context.Context, id string) (*model.Upload, error) {
	return s.repo.GetByID(ctx, id)
}

func (s *UploadService) Delete(ctx context.Context, id, userID, role string) error {
	upload, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return err
	}

	// Only the uploader or admin+ can delete
	if upload.UploadedBy != userID && model.Role(role).Hierarchy() < model.RoleAdmin.Hierarchy() {
		return errors.New("forbidden")
	}

	// Soft-delete from DB
	if err := s.repo.Delete(ctx, id); err != nil {
		return err
	}

	// Remove file from disk
	if err := os.Remove(upload.Path); err != nil && !os.IsNotExist(err) {
		s.logger.Error("failed to remove file from disk", "path", upload.Path, "error", err)
	}

	return nil
}

// ResolveImageURL looks up an upload by ID and returns its URL.
// If entityType and entityID are provided, it also links the upload to that entity.
func (s *UploadService) ResolveImageURL(ctx context.Context, imageID string, entityType, entityID string) (string, error) {
	upload, err := s.repo.GetByID(ctx, imageID)
	if err != nil {
		return "", fmt.Errorf("resolving image %s: %w", imageID, err)
	}
	// Link upload to entity if IDs are available
	if entityType != "" && entityID != "" {
		if linkErr := s.repo.LinkEntity(ctx, imageID, entityType, entityID); linkErr != nil {
			s.logger.Warn("failed to link upload to entity", "upload_id", imageID, "entity", entityType, "error", linkErr)
		}
	}
	return upload.URL, nil
}

func (s *UploadService) ListByEntity(ctx context.Context, entityType, entityID string) ([]model.Upload, error) {
	return s.repo.ListByEntity(ctx, entityType, entityID)
}

func (s *UploadService) ListByUser(ctx context.Context, userID string, params model.PaginationParams) ([]model.Upload, int, error) {
	return s.repo.ListByUser(ctx, userID, params)
}

// sanitizeFileName removes path separators and keeps only the base name without extension.
func sanitizeFileName(name string) string {
	base := filepath.Base(name)
	ext := filepath.Ext(base)
	nameOnly := strings.TrimSuffix(base, ext)
	// Remove non-alphanumeric chars (keep dashes and underscores)
	var sb strings.Builder
	for _, r := range nameOnly {
		if (r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z') || (r >= '0' && r <= '9') || r == '-' || r == '_' {
			sb.WriteRune(r)
		}
	}
	result := sb.String()
	if result == "" {
		return "upload"
	}
	return result
}
