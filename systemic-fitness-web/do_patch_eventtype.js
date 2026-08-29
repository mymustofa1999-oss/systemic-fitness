const fs = require('fs');

function patchEventType() {
	const path = '../systemic-fitness-api/internal/handler/scheduling.go';
	let content = fs.readFileSync(path, 'utf8');

	const targetStart = 'func (h *SchedulingHandler) UpdateEventType(w http.ResponseWriter, r *http.Request) {';
	const targetEnd = '\tresponse.OK(w, et)\n}';
	
	const idx1 = content.indexOf(targetStart);
	if (idx1 === -1) throw new Error("Start not found");
	
	let idx2 = content.indexOf(targetEnd, idx1) + targetEnd.length;
	if (content.indexOf(targetEnd, idx1) === -1) throw new Error("End not found");
	
	const newBody = unc (h *SchedulingHandler) UpdateEventType(w http.ResponseWriter, r *http.Request) {
	id := chi.URLParam(r, "id")

	// FETCH existing
	existing, err := h.schedulingService.GetEventType(r.Context(), id)
	if err != nil {
		if errors.Is(err, repository.ErrNotFound) {
			response.NotFound(w, "Event type not found")
			return
		}
		response.InternalError(w, "Failed to fetch event type")
		return
	}

	bodyBytes, err := io.ReadAll(r.Body)
	if err != nil {
		response.BadRequest(w, "Invalid request body")
		return
	}
	r.Body = io.NopCloser(bytes.NewBuffer(bodyBytes))

	var raw map[string]any
	if err := json.Unmarshal(bodyBytes, &raw); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}

	var input struct {
		Name        string  \json:"name"         validate:"omitempty,min=1,max=100"\
		Description *string \json:"description,omitempty"\
		Category    string  \json:"category"     validate:"omitempty,oneof=one_on_one group_class personal"\
		DurationMin int     \json:"duration_min" validate:"omitempty,gt=0"\
		Color       *string \json:"color,omitempty"\
		IsActive    *bool   \json:"is_active,omitempty"\
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	// MERGE
	if _, ok := raw["name"]; ok {
		existing.Name = input.Name
	}
	if v, ok := raw["description"]; ok {
		if v == nil {
			existing.Description = nil
		} else {
			existing.Description = input.Description
		}
	}
	if _, ok := raw["category"]; ok {
		existing.Category = input.Category
	}
	if _, ok := raw["duration_min"]; ok {
		existing.DurationMin = input.DurationMin
	}
	if v, ok := raw["color"]; ok {
		if v == nil {
			existing.Color = nil
		} else {
			existing.Color = input.Color
		}
	}
	if _, ok := raw["is_active"]; ok {
		existing.IsActive = *input.IsActive
	}

	// SAVE
	if err := h.schedulingService.UpdateEventType(r.Context(), existing); err != nil {
		response.InternalError(w, "Failed to update event type")
		return
	}
	response.OK(w, existing)
};

	content = content.substring(0, idx1) + newBody + content.substring(idx2);
	fs.writeFileSync(path, content, 'utf8');
}

patchEventType();
console.log("Patched EventType");
