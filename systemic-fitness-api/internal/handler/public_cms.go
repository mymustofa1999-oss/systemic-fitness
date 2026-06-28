package handler

import (
	"errors"
	"net/http"

	"github.com/fitcoach/api/internal/service"
	"github.com/fitcoach/api/pkg/response"
)

// PublicCMSHandler serves the public landing-page payload.
// No auth required — this is what anonymous visitors see.
type PublicCMSHandler struct {
	cms *service.CMSService
}

func NewPublicCMSHandler(cms *service.CMSService) *PublicCMSHandler {
	return &PublicCMSHandler{cms: cms}
}

// GET /api/public/cms/landing?locale=id
func (h *PublicCMSHandler) GetLanding(w http.ResponseWriter, r *http.Request) {
	locale := r.URL.Query().Get("locale")
	if locale == "" {
		locale = "id"
	}

	payload, err := h.cms.GetLanding(r.Context(), locale)
	if err != nil {
		if errors.Is(err, service.ErrInvalidLocale) {
			response.BadRequest(w, "locale must be 'id' or 'en'")
			return
		}
		response.InternalError(w, "failed to load landing content")
		return
	}
	response.OK(w, payload)
}
