package service

import (
	"context"
	"errors"
	"fmt"
	"log/slog"

	"github.com/fitcoach/api/internal/model"
	"github.com/fitcoach/api/internal/repository"
)

// ClinicalNoteService — SF Phase 7b.
//
// Authorship rules:
//   - Author (consultant_id) di-set dari JWT context, BUKAN dari payload.
//   - Update/Delete: hanya author atau owner/admin.
//   - Client (subject) bisa GET note miliknya hanya kalau is_visible_to_client=true.
type ClinicalNoteService struct {
	repo               *repository.ClinicalNoteRepository
	assessmentV2Repo   *repository.AssessmentV2Repository
	logger             *slog.Logger
}

func NewClinicalNoteService(
	repo *repository.ClinicalNoteRepository,
	v2Repo *repository.AssessmentV2Repository,
	logger *slog.Logger,
) *ClinicalNoteService {
	return &ClinicalNoteService{repo: repo, assessmentV2Repo: v2Repo, logger: logger}
}

var (
	ErrClinicalNoteForbidden = errors.New("clinical note: forbidden")
	ErrClinicalNoteInvalid   = errors.New("clinical note: invalid input")
)

func (s *ClinicalNoteService) Create(ctx context.Context, n *repository.ClinicalNote) error {
	if n.ClientID == "" || n.ConsultantID == "" {
		return fmt.Errorf("%w: client_id and consultant_id are required", ErrClinicalNoteInvalid)
	}
	if n.ClientID == n.ConsultantID {
		return fmt.Errorf("%w: consultant cannot write a note about themselves", ErrClinicalNoteInvalid)
	}
	if len(n.Content) == 0 {
		return fmt.Errorf("%w: content cannot be empty", ErrClinicalNoteInvalid)
	}

	// Kalau attached ke assessment_id, validate assessment milik client_id.
	if n.AssessmentID != nil {
		a, err := s.assessmentV2Repo.GetV2ByID(ctx, *n.AssessmentID)
		if err != nil {
			if errors.Is(err, repository.ErrNotFound) {
				return fmt.Errorf("%w: assessment_id not found or not v2", ErrClinicalNoteInvalid)
			}
			return fmt.Errorf("validating assessment: %w", err)
		}
		if a.UserID == nil || *a.UserID != n.ClientID {
			return fmt.Errorf("%w: assessment_id does not belong to client_id", ErrClinicalNoteInvalid)
		}
	}

	if err := s.repo.Create(ctx, n); err != nil {
		s.logger.Error("create clinical note", "consultant_id", n.ConsultantID, "client_id", n.ClientID, "error", err)
		return fmt.Errorf("creating clinical note: %w", err)
	}
	s.logger.Info("clinical note created",
		"id", n.ID, "consultant_id", n.ConsultantID, "client_id", n.ClientID,
		"assessment_id", n.AssessmentID, "is_visible", n.IsVisibleToClient)
	return nil
}

func (s *ClinicalNoteService) Get(ctx context.Context, id string) (*repository.ClinicalNote, error) {
	n, err := s.repo.GetByID(ctx, id)
	if err != nil {
		if !errors.Is(err, repository.ErrNotFound) {
			s.logger.Error("get clinical note", "id", id, "error", err)
		}
		return nil, err
	}
	return n, nil
}

// CanRead enforces:
//   - client (the subject) → only when is_visible_to_client = true.
//   - consultant → unrestricted (any consultant can read any note).
//   - admin/owner/finance → unrestricted.
//   - trainer → forbidden (clinical notes are not in trainer scope).
func (s *ClinicalNoteService) CanRead(
	role model.Role, callerID string, n *repository.ClinicalNote,
) bool {
	switch role {
	case model.RoleOwner, model.RoleAdmin, model.RoleFinance, model.RoleConsultant:
		return true
	case model.RoleClient:
		return n.ClientID == callerID && n.IsVisibleToClient
	default:
		return false
	}
}

func (s *ClinicalNoteService) List(
	ctx context.Context, f repository.ClinicalNoteFilter,
) ([]repository.ClinicalNote, error) {
	out, err := s.repo.List(ctx, f)
	if err != nil {
		s.logger.Error("list clinical notes", "error", err)
		return nil, err
	}
	return out, nil
}

// Update modifies title/content/attachments/is_visible_to_client.
// Caller must be the author or admin/owner.
func (s *ClinicalNoteService) Update(
	ctx context.Context, n *repository.ClinicalNote,
	callerID string, callerRole model.Role,
) error {
	existing, err := s.repo.GetByID(ctx, n.ID)
	if err != nil {
		return err
	}
	if !s.canWrite(callerRole, callerID, existing) {
		return ErrClinicalNoteForbidden
	}
	// preserve immutable fields
	n.ConsultantID = existing.ConsultantID
	n.ClientID = existing.ClientID
	n.AssessmentID = existing.AssessmentID
	if err := s.repo.Update(ctx, n); err != nil {
		s.logger.Error("update clinical note", "id", n.ID, "error", err)
		return err
	}
	return nil
}

func (s *ClinicalNoteService) Delete(
	ctx context.Context, id string, callerID string, callerRole model.Role,
) error {
	existing, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return err
	}
	if !s.canWrite(callerRole, callerID, existing) {
		return ErrClinicalNoteForbidden
	}
	if err := s.repo.SoftDelete(ctx, id); err != nil {
		s.logger.Error("delete clinical note", "id", id, "error", err)
		return err
	}
	return nil
}

func (s *ClinicalNoteService) canWrite(
	role model.Role, callerID string, n *repository.ClinicalNote,
) bool {
	if role == model.RoleOwner || role == model.RoleAdmin {
		return true
	}
	return role == model.RoleConsultant && n.ConsultantID == callerID
}

// ─── Consultant Dashboard aggregations ─────────────────────────────

func (s *ClinicalNoteService) ListClients(
	ctx context.Context, consultantID string,
) ([]repository.ConsultantClient, error) {
	out, err := s.repo.ListClientsForConsultant(ctx, consultantID)
	if err != nil {
		s.logger.Error("list consultant clients", "consultant_id", consultantID, "error", err)
		return nil, err
	}
	return out, nil
}

func (s *ClinicalNoteService) ListPendingReview(
	ctx context.Context, limit int,
) ([]repository.PendingReviewItem, error) {
	out, err := s.assessmentV2Repo.ListPendingClinicalReview(ctx, limit)
	if err != nil {
		s.logger.Error("list pending review", "error", err)
		return nil, err
	}
	return out, nil
}
