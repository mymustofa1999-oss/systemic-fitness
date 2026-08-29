const fs = require('fs');

// 1. Service
let svc = fs.readFileSync('systemic-fitness-api/internal/service/digital_library_service.go', 'utf8');
const svcMethod = `func (s *DigitalLibraryService) UpdateMenuItem(ctx context.Context, id string, videoUrlMale *string, videoUrlFemale *string) error {
\treturn s.repo.UpdateMenuItem(ctx, id, videoUrlMale, videoUrlFemale)
}

`;
svc = svc.replace('func (s *DigitalLibraryService) DeleteMenuItem', svcMethod + 'func (s *DigitalLibraryService) DeleteMenuItem');
fs.writeFileSync('systemic-fitness-api/internal/service/digital_library_service.go', svc);

// 2. Handler
let hdl = fs.readFileSync('systemic-fitness-api/internal/handler/digital_library.go', 'utf8');
const hdlMethod = `func (h *DigitalLibraryHandler) UpdateMenuItem(w http.ResponseWriter, r *http.Request) {
\tid := chi.URLParam(r, "id")
\tvar req struct {
\t\tVideoUrlMale   *string \`json:"video_url_male"\`
\t\tVideoUrlFemale *string \`json:"video_url_female"\`
\t}
\tif err := json.NewDecoder(r.Body).Decode(&req); err != nil {
\t\tRespondError(w, http.StatusBadRequest, "Invalid request payload")
\t\treturn
\t}

\tif err := h.dls.UpdateMenuItem(r.Context(), id, req.VideoUrlMale, req.VideoUrlFemale); err != nil {
\t\tRespondError(w, http.StatusInternalServerError, "Failed to update menu item")
\t\treturn
\t}

\tRespondJSON(w, http.StatusOK, map[string]string{"status": "success"})
}

`;
hdl = hdl.replace('func (h *DigitalLibraryHandler) DeleteModulCardItem', hdlMethod + 'func (h *DigitalLibraryHandler) DeleteModulCardItem');
fs.writeFileSync('systemic-fitness-api/internal/handler/digital_library.go', hdl);

// 3. Router
let router = fs.readFileSync('systemic-fitness-api/cmd/server/main.go', 'utf8');
const routeMethod = `\t\t\t\t\tr.With(middleware.RequireRole(model.RoleAdmin, model.RoleOwner, model.RoleConsultant)).Put("/menu/{id}", dlHandler.UpdateMenuItem)
\t\t\t\t\tr.With`;
router = router.replace('\t\t\t\t\tr.With(middleware.RequireRole(model.RoleAdmin, model.RoleOwner, model.RoleConsultant)).Delete("/{levelID}/{movementID}", dlHandler.DeleteModulCardItem)', routeMethod + '(middleware.RequireRole(model.RoleAdmin, model.RoleOwner, model.RoleConsultant)).Delete("/{levelID}/{movementID}", dlHandler.DeleteModulCardItem)');
fs.writeFileSync('systemic-fitness-api/cmd/server/main.go', router);

console.log('Backend updated');
