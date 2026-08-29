const fs = require('fs');
const path = '../systemic-fitness-api/internal/handler/trainer_card.go';
let content = fs.readFileSync(path, 'utf8');

const targetFunctionStart = 'func (h *TrainerCardHandler) UpsertCard(w http.ResponseWriter, r *http.Request) {';
const targetFunctionEnd = '	response.OK(w, card)\n}';

const startIndex = content.indexOf(targetFunctionStart);
if (startIndex === -1) throw new Error("Could not find start");
const endIndex = content.indexOf(targetFunctionEnd, startIndex) + targetFunctionEnd.length;
if (content.indexOf(targetFunctionEnd, startIndex) === -1) throw new Error("Could not find end");

const replacement = \unc (h *TrainerCardHandler) UpsertCard(w http.ResponseWriter, r *http.Request) {
	customerID := chi.URLParam(r, "customerId")

	bodyBytes, err := io.ReadAll(r.Body)
	if err != nil {
		response.BadRequest(w, "Invalid request body")
		return
	}
	r.Body = io.NopCloser(bytes.NewBuffer(bodyBytes))

	var raw map[string]any
	json.Unmarshal(bodyBytes, &raw)
	
	seqVal, hasSequences := raw["sequences"]
	explicitNull := hasSequences && seqVal == nil

	var input struct {
		Level        string                \json:"level"     validate:"required,min=1,max=30"\
		Notes        *string               \json:"notes,omitempty"\
		TargetGender *string               \json:"target_gender,omitempty" validate:"omitempty,oneof=male female universal"\
		Sequences    []upsertSequenceInput \json:"sequences" validate:"omitempty,dive"\
	}
	if err := response.DecodeJSON(r, &input); err != nil {
		response.BadRequest(w, "Invalid request body: "+err.Error())
		return
	}
	if errs := validateStruct(&input); errs != nil {
		response.ValidationError(w, errs)
		return
	}

	updateSequences := false
	if hasSequences {
		if explicitNull {
			updateSequences = true
			input.Sequences = nil
		} else if len(input.Sequences) > 0 {
			updateSequences = true
		}
	}

	createdBy := r.Context().Value("user_id")
	var createdByStr *string
	if uid, ok := createdBy.(string); ok {
		createdByStr = &uid
	}

	card := &repository.TrainerCard{
		CustomerID:   customerID,
		Level:        input.Level,
		Notes:        input.Notes,
		CreatedBy:    createdByStr,
		TargetGender: input.TargetGender,
	}

	// ID Matching for granular merge
	if updateSequences {
		existingCard, _ := h.cardService.GetTrainingCard(r.Context(), customerID)
		
		for si, seqIn := range input.Sequences {
			seq := repository.TrainerCardSequence{
				ProgramCategoryID: seqIn.ProgramCategoryID,
				Duration:          seqIn.Duration,
				SortOrder:         seqIn.SortOrder,
			}
			
			// Match existing sequence by ProgramCategoryID
			if existingCard != nil {
				for _, exSeq := range existingCard.Sequences {
					if exSeq.ProgramCategoryID == seq.ProgramCategoryID {
						seq.ID = exSeq.ID
						break
					}
				}
			}

			for seti, setIn := range seqIn.Sets {
				set := repository.TrainerCardSet{
					SetNumber:          setIn.SetNumber,
					Duration:           setIn.Duration,
					EquipmentUpper:     setIn.EquipmentUpper,
					EquipmentLower:     setIn.EquipmentLower,
					Equipment:          setIn.Equipment,
					TypeID:             setIn.TypeID,
					BPM:                setIn.BPM,
					ExtraLoad:          setIn.ExtraLoad,
					Notes:              setIn.Notes,
					SortOrder:          setIn.SortOrder,
					Pattern:            setIn.Pattern,
					BreathingCore:      setIn.BreathingCore,
					BreathingDiaphragm: setIn.BreathingDiaphragm,
				}
				
				// Match existing set by SetNumber
				if existingCard != nil && seq.ID != "" {
					for _, exSeq := range existingCard.Sequences {
						if exSeq.ID == seq.ID {
							for _, exSet := range exSeq.Sets {
								if exSet.SetNumber == set.SetNumber {
									set.ID = exSet.ID
									break
								}
							}
							break
						}
					}
				}

				for ii, itemIn := range setIn.Items {
					item := repository.TrainerCardSetItem{
						MovementID:         itemIn.MovementID,
						MovementName:       itemIn.MovementName,
						BodyPart:           itemIn.BodyPart,
						Equipment:          itemIn.Equipment,
						Reps:               itemIn.Reps,
						SetsCount:          itemIn.SetsCount,
						SortOrder:          itemIn.SortOrder,
						BreathingCore:      itemIn.BreathingCore,
						BreathingDiaphragm: itemIn.BreathingDiaphragm,
						VideoURLSnapshot:   itemIn.VideoURLSnapshot,
					}
					
					// Match existing item by SortOrder
					if existingCard != nil && set.ID != "" {
						for _, exSeq := range existingCard.Sequences {
							if exSeq.ID == seq.ID {
								for _, exSet := range exSeq.Sets {
									if exSet.ID == set.ID {
										for _, exItem := range exSet.Items {
											if exItem.SortOrder == item.SortOrder {
												item.ID = exItem.ID
												break
											}
										}
										break
									}
								}
								break
							}
						}
					}
					
					set.Items = append(set.Items, item)
				}
				seq.Sets = append(seq.Sets, set)
			}
			card.Sequences = append(card.Sequences, seq)
		}
	}

	if err := h.cardService.UpsertCard(r.Context(), card, updateSequences); err != nil {
		slog.Error("[TrainingCard.UpsertCard] failed", "customer_id", customerID, "error", err)
		response.InternalError(w, "Failed to save training card")
		return
	}
	response.OK(w, card)
}\;

content = content.substring(0, startIndex) + replacement + content.substring(endIndex);
fs.writeFileSync(path, content, 'utf8');
console.log("Patched handler successfully");
