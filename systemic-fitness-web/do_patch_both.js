const fs = require('fs');

function patchHandler() {
	const path = '../systemic-fitness-api/internal/handler/trainer_card.go';
	let content = fs.readFileSync(path, 'utf8');

	const targetFunctionStart = 'func (h *TrainerCardHandler) UpsertCard(w http.ResponseWriter, r *http.Request) {';
	const targetFunctionEnd = '	response.OK(w, card)\n}';

	const startIndex = content.indexOf(targetFunctionStart);
	const endIndex = content.indexOf(targetFunctionEnd, startIndex) + targetFunctionEnd.length;

	// Use String.raw to avoid escape character issues
	const newBody = String.rawunc (h *TrainerCardHandler) UpsertCard(w http.ResponseWriter, r *http.Request) {
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
		Level        string                 + '' + String.rawjson:"level"     validate:"required,min=1,max=30" + '' + String.raw
		Notes        *string                + '' + String.rawjson:"notes,omitempty" + '' + String.raw
		TargetGender *string                + '' + String.rawjson:"target_gender,omitempty" validate:"omitempty,oneof=male female universal" + '' + String.raw
		Sequences    []upsertSequenceInput  + '' + String.rawjson:"sequences" validate:"omitempty,dive" + '' + String.raw
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
};

	content = content.substring(0, startIndex) + newBody + content.substring(endIndex);
	fs.writeFileSync(path, content, 'utf8');
}

function patchRepo() {
	const path = '../systemic-fitness-api/internal/repository/trainer_card_repo.go';
	let content = fs.readFileSync(path, 'utf8');

	const startStr = 'func (r *TrainerCardRepository) UpsertCard(ctx context.Context, card *TrainerCard) error {';
	const newStartStr = 'func (r *TrainerCardRepository) UpsertCard(ctx context.Context, card *TrainerCard, updateSequences bool) error {';
	content = content.replace(startStr, newStartStr);

	const deleteStr = '\t// 2. Delete existing nested data (cascade will handle sets+items)';
	const endStr = '\treturn tx.Commit(ctx)\n}';

	const idx1 = content.indexOf(deleteStr);
	const idx2 = content.indexOf(endStr, idx1) + endStr.length;

	const newSection = String.raw	if !updateSequences {
		return tx.Commit(ctx)
	}

	var keepSeqIDs []string
	var keepSetIDs []string
	var keepItemIDs []string

	for si := range card.Sequences {
		seq := &card.Sequences[si]
		if seq.ID == "" {
			seq.ID = uuid.New().String()
		}
		keepSeqIDs = append(keepSeqIDs, seq.ID)
		
		for seti := range seq.Sets {
			set := &seq.Sets[seti]
			if set.ID == "" {
				set.ID = uuid.New().String()
			}
			keepSetIDs = append(keepSetIDs, set.ID)
			
			for ii := range set.Items {
				item := &set.Items[ii]
				if item.ID == "" {
					item.ID = uuid.New().String()
				}
				keepItemIDs = append(keepItemIDs, item.ID)
			}
		}
	}

	// Delete items not in payload
	if len(keepItemIDs) > 0 {
		_, err = tx.Exec(ctx,  + '' + String.rawDELETE FROM trainer_card_set_items 
			WHERE set_id IN (SELECT id FROM trainer_card_sets WHERE sequence_id IN (SELECT id FROM trainer_card_sequences WHERE trainer_card_id = ))
			AND NOT (id = ANY()) + '' + String.raw, card.ID, keepItemIDs)
	} else {
		_, err = tx.Exec(ctx,  + '' + String.rawDELETE FROM trainer_card_set_items 
			WHERE set_id IN (SELECT id FROM trainer_card_sets WHERE sequence_id IN (SELECT id FROM trainer_card_sequences WHERE trainer_card_id = )) + '' + String.raw, card.ID)
	}
	if err != nil { return fmt.Errorf("delete old items: %w", err) }

	if len(keepSetIDs) > 0 {
		_, err = tx.Exec(ctx,  + '' + String.rawDELETE FROM trainer_card_sets 
			WHERE sequence_id IN (SELECT id FROM trainer_card_sequences WHERE trainer_card_id = )
			AND NOT (id = ANY()) + '' + String.raw, card.ID, keepSetIDs)
	} else {
		_, err = tx.Exec(ctx,  + '' + String.rawDELETE FROM trainer_card_sets 
			WHERE sequence_id IN (SELECT id FROM trainer_card_sequences WHERE trainer_card_id = ) + '' + String.raw, card.ID)
	}
	if err != nil { return fmt.Errorf("delete old sets: %w", err) }

	if len(keepSeqIDs) > 0 {
		_, err = tx.Exec(ctx,  + '' + String.rawDELETE FROM trainer_card_sequences WHERE trainer_card_id =  AND NOT (id = ANY()) + '' + String.raw, card.ID, keepSeqIDs)
	} else {
		_, err = tx.Exec(ctx,  + '' + String.rawDELETE FROM trainer_card_sequences WHERE trainer_card_id =  + '' + String.raw, card.ID)
	}
	if err != nil { return fmt.Errorf("delete old sequences: %w", err) }

	batch := &pgx.Batch{}

	// 3. Queue sequences + sets + items
	for si := range card.Sequences {
		seq := &card.Sequences[si]
		seq.TrainerCardID = card.ID
		if seq.SortOrder == 0 {
			seq.SortOrder = si
		}

		batch.Queue(
			 + '' + String.rawINSERT INTO trainer_card_sequences (id, trainer_card_id, program_category_id, duration, sort_order)
			 VALUES (, , , , )
			 ON CONFLICT (id) DO UPDATE SET
			    program_category_id = EXCLUDED.program_category_id, duration = EXCLUDED.duration, sort_order = EXCLUDED.sort_order, updated_at = NOW() + '' + String.raw,
			seq.ID, seq.TrainerCardID, seq.ProgramCategoryID, seq.Duration, seq.SortOrder,
		)

		for seti := range seq.Sets {
			set := &seq.Sets[seti]
			set.SequenceID = seq.ID
			if set.SortOrder == 0 {
				set.SortOrder = seti
			}

			batch.Queue(
				 + '' + String.rawINSERT INTO trainer_card_sets
				    (id, sequence_id, set_number, duration, equipment_upper, equipment_lower, equipment,
				     type_id, bpm, extra_load, notes, sort_order,
				     pattern, breathing_core, breathing_diaphragm)
				 VALUES (, , , , , , , , , , , , , , )
				 ON CONFLICT (id) DO UPDATE SET
				     set_number = EXCLUDED.set_number, duration = EXCLUDED.duration, equipment_upper = EXCLUDED.equipment_upper, equipment_lower = EXCLUDED.equipment_lower, equipment = EXCLUDED.equipment,
				     type_id = EXCLUDED.type_id, bpm = EXCLUDED.bpm, extra_load = EXCLUDED.extra_load, notes = EXCLUDED.notes, sort_order = EXCLUDED.sort_order,
				     pattern = EXCLUDED.pattern, breathing_core = EXCLUDED.breathing_core, breathing_diaphragm = EXCLUDED.breathing_diaphragm, updated_at = NOW() + '' + String.raw,
				set.ID, set.SequenceID, set.SetNumber, set.Duration,
				set.EquipmentUpper, set.EquipmentLower, set.Equipment,
				set.TypeID, set.BPM, set.ExtraLoad, set.Notes, set.SortOrder,
				set.Pattern, set.BreathingCore, set.BreathingDiaphragm,
			)

			for ii := range set.Items {
				item := &set.Items[ii]
				item.SetID = set.ID
				if item.SortOrder == 0 {
					item.SortOrder = ii
				}

				batch.Queue(
					 + '' + String.rawINSERT INTO trainer_card_set_items
					    (id, set_id, movement_id, movement_name, body_part, equipment, reps, sets_count, sort_order,
					     breathing_core, breathing_diaphragm, allowed_tiers, video_url_snapshot)
					 VALUES (, , , , , , , , , , , , )
					 ON CONFLICT (id) DO UPDATE SET
					     movement_id = EXCLUDED.movement_id, movement_name = EXCLUDED.movement_name, body_part = EXCLUDED.body_part, equipment = EXCLUDED.equipment,
					     reps = EXCLUDED.reps, sets_count = EXCLUDED.sets_count, sort_order = EXCLUDED.sort_order,
					     breathing_core = EXCLUDED.breathing_core, breathing_diaphragm = EXCLUDED.breathing_diaphragm, allowed_tiers = EXCLUDED.allowed_tiers, video_url_snapshot = EXCLUDED.video_url_snapshot, updated_at = NOW() + '' + String.raw,
					item.ID, item.SetID, item.MovementID, item.MovementName,
					item.BodyPart, item.Equipment, item.Reps, item.SetsCount, item.SortOrder,
					item.BreathingCore, item.BreathingDiaphragm, nonNilTiers(item.AllowedTiers), item.VideoURLSnapshot,
				)
			}
		}
	}

	if batch.Len() > 0 {
		br := tx.SendBatch(ctx, batch)
		// We need to consume all results otherwise commit fails
		for i := 0; i < batch.Len(); i++ {
			if _, err := br.Exec(); err != nil {
				br.Close()
				return fmt.Errorf("batch execute at idx %d: %w", i, err)
			}
		}
		if err := br.Close(); err != nil {
			return fmt.Errorf("close batch: %w", err)
		}
	}

	return tx.Commit(ctx)
};

	content = content.substring(0, idx1) + newSection + content.substring(idx2);
	fs.writeFileSync(path, content, 'utf8');
}

patchHandler();
patchRepo();
console.log("Patched successfully");
