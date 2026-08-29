package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

func main() {
	path := "../systemic-fitness-api/internal/handler/trainer_card.go"
	b, err := ioutil.ReadFile(path)
	if err != nil {
		panic(err)
	}
	content := string(b)

	startStr := "func (h *TrainerCardHandler) UpsertCard(w http.ResponseWriter, r *http.Request) {"
	endStr := "	response.OK(w, card)\n}"
	
	startIdx := strings.Index(content, startStr)
	if startIdx == -1 {
		panic("start not found")
	}
	endIdx := strings.Index(content[startIdx:], endStr)
	if endIdx == -1 {
		panic("end not found")
	}
	endIdx += startIdx + len(endStr)

	newBody := startStr + 
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
		Level        string                 + "" + json:"level"     validate:"required,min=1,max=30" + "" + 
		Notes        *string                + "" + json:"notes,omitempty" + "" + 
		TargetGender *string                + "" + json:"target_gender,omitempty" validate:"omitempty,oneof=male female universal" + "" + 
		Sequences    []upsertSequenceInput  + "" + json:"sequences" validate:"omitempty,dive" + "" + 
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

	if updateSequences {
		existingCard, _ := h.cardService.GetTrainingCard(r.Context(), customerID)
		
		for si, seqIn := range input.Sequences {
			seq := repository.TrainerCardSequence{
				ProgramCategoryID: seqIn.ProgramCategoryID,
				Duration:          seqIn.Duration,
				SortOrder:         seqIn.SortOrder,
			}
			if seq.SortOrder == 0 {
				seq.SortOrder = si
			}
			
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
				if set.SortOrder == 0 {
					set.SortOrder = seti
				}
				
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

				for itemi, itemIn := range setIn.Items {
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
					if item.SortOrder == 0 {
						item.SortOrder = itemi
					}
					
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

	if card.Notes != nil && strings.Contains(*card.Notes, "Auto-generated") {
		cleaned := strings.TrimSpace(strings.ReplaceAll(*card.Notes, "Auto-generated upon subscription activation.", ""))
		if cleaned == "" {
			card.Notes = nil
		} else {
			card.Notes = &cleaned
		}
	}

	if err := h.cardService.UpsertCard(r.Context(), card, updateSequences); err != nil {
		slog.Error("[TrainingCard.UpsertCard] failed", "customer_id", customerID, "error", err)
		response.InternalError(w, "Failed to save training card")
		return
	}
	response.OK(w, card)
}

	
	newContent := content[:startIdx] + newBody + content[endIdx:]
	err = ioutil.WriteFile(path, []byte(newContent), 0644)
	if err != nil {
		panic(err)
	}
	fmt.Println("success")
}
