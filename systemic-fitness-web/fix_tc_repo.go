package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

func main() {
	path := "../systemic-fitness-api/internal/repository/trainer_card_repo.go"
	b, err := ioutil.ReadFile(path)
	if err != nil {
		panic(err)
	}
	content := string(b)

	startStr := "func (r *TrainerCardRepository) UpsertCard(ctx context.Context, card *TrainerCard) error {"
	
	// Wait, we need to change it to:
	newStartStr := "func (r *TrainerCardRepository) UpsertCard(ctx context.Context, card *TrainerCard, updateSequences bool) error {"
	
	content = strings.Replace(content, startStr, newStartStr, 1)

	// Now replace the DELETE and INSERT batch section.
	deleteStr := "// 2. Delete existing nested data"
	endStr := "if err := batchResults.Close(); err != nil {"
	
	startIdx := strings.Index(content, deleteStr)
	if startIdx == -1 {
		panic("deleteStr not found")
	}
	endIdx := strings.Index(content[startIdx:], endStr)
	if endIdx == -1 {
		panic("endStr not found")
	}
	endIdx += startIdx

	newSection := 	if !updateSequences {
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
		_, err = tx.Exec(ctx,  + "" + DELETE FROM trainer_card_set_items 
			WHERE set_id IN (SELECT id FROM trainer_card_sets WHERE sequence_id IN (SELECT id FROM trainer_card_sequences WHERE trainer_card_id = ))
			AND id <> ALL() + "" + , card.ID, keepItemIDs)
	} else {
		_, err = tx.Exec(ctx,  + "" + DELETE FROM trainer_card_set_items 
			WHERE set_id IN (SELECT id FROM trainer_card_sets WHERE sequence_id IN (SELECT id FROM trainer_card_sequences WHERE trainer_card_id = )) + "" + , card.ID)
	}
	if err != nil { return fmt.Errorf("delete old items: %w", err) }

	if len(keepSetIDs) > 0 {
		_, err = tx.Exec(ctx,  + "" + DELETE FROM trainer_card_sets 
			WHERE sequence_id IN (SELECT id FROM trainer_card_sequences WHERE trainer_card_id = )
			AND id <> ALL() + "" + , card.ID, keepSetIDs)
	} else {
		_, err = tx.Exec(ctx,  + "" + DELETE FROM trainer_card_sets 
			WHERE sequence_id IN (SELECT id FROM trainer_card_sequences WHERE trainer_card_id = ) + "" + , card.ID)
	}
	if err != nil { return fmt.Errorf("delete old sets: %w", err) }

	if len(keepSeqIDs) > 0 {
		_, err = tx.Exec(ctx,  + "" + DELETE FROM trainer_card_sequences WHERE trainer_card_id =  AND id <> ALL() + "" + , card.ID, keepSeqIDs)
	} else {
		_, err = tx.Exec(ctx,  + "" + DELETE FROM trainer_card_sequences WHERE trainer_card_id =  + "" + , card.ID)
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
			 + "" + INSERT INTO trainer_card_sequences (id, trainer_card_id, program_category_id, duration, sort_order)
			 VALUES (, , , , )
			 ON CONFLICT (id) DO UPDATE SET
			    program_category_id = , duration = , sort_order = , updated_at = NOW() + "" + ,
			seq.ID, seq.TrainerCardID, seq.ProgramCategoryID, seq.Duration, seq.SortOrder,
		)

		for seti := range seq.Sets {
			set := &seq.Sets[seti]
			set.SequenceID = seq.ID
			if set.SortOrder == 0 {
				set.SortOrder = seti
			}

			batch.Queue(
				 + "" + INSERT INTO trainer_card_sets
				    (id, sequence_id, set_number, duration, equipment_upper, equipment_lower, equipment,
				     type_id, bpm, extra_load, notes, sort_order,
				     pattern, breathing_core, breathing_diaphragm)
				 VALUES (, , , , , , , , , , , , , , )
				 ON CONFLICT (id) DO UPDATE SET
				     set_number = , duration = , equipment_upper = , equipment_lower = , equipment = ,
				     type_id = , bpm = , extra_load = , notes = , sort_order = ,
				     pattern = , breathing_core = , breathing_diaphragm = , updated_at = NOW() + "" + ,
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
					 + "" + INSERT INTO trainer_card_set_items
					    (id, set_id, movement_id, movement_name, body_part, equipment,
					     reps, sets_count, sort_order,
					     breathing_core, breathing_diaphragm, video_url_snapshot)
					 VALUES (, , , , , , , , , , , )
					 ON CONFLICT (id) DO UPDATE SET
					     movement_id = , movement_name = , body_part = , equipment = ,
					     reps = , sets_count = , sort_order = ,
					     breathing_core = , breathing_diaphragm = , video_url_snapshot = , updated_at = NOW() + "" + ,
					item.ID, item.SetID, item.MovementID, item.MovementName, item.BodyPart, item.Equipment,
					item.Reps, item.SetsCount, item.SortOrder,
					item.BreathingCore, item.BreathingDiaphragm, item.VideoURLSnapshot,
				)
			}
		}
	}

	
	
	newContent := content[:startIdx] + newSection + content[endIdx:]
	err = ioutil.WriteFile(path, []byte(newContent), 0644)
	if err != nil {
		panic(err)
	}
	fmt.Println("success")
}
