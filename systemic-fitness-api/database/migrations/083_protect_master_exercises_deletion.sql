-- Up Migration
ALTER TABLE dl_menu_items DROP CONSTRAINT dl_menu_items_movement_id_fkey;
ALTER TABLE dl_menu_items ADD CONSTRAINT dl_menu_items_movement_id_fkey FOREIGN KEY (movement_id) REFERENCES dl_movements(id) ON DELETE RESTRICT;

ALTER TABLE dl_isolate_items DROP CONSTRAINT dl_isolate_items_movement_id_fkey;
ALTER TABLE dl_isolate_items ADD CONSTRAINT dl_isolate_items_movement_id_fkey FOREIGN KEY (movement_id) REFERENCES dl_movements(id) ON DELETE RESTRICT;

ALTER TABLE trainer_card_set_items DROP CONSTRAINT trainer_card_set_items_movement_id_fkey;
ALTER TABLE trainer_card_set_items ADD CONSTRAINT trainer_card_set_items_movement_id_fkey FOREIGN KEY (movement_id) REFERENCES dl_movements(id) ON DELETE RESTRICT;

ALTER TABLE trainer_card_template_set_items DROP CONSTRAINT trainer_card_template_set_items_movement_id_fkey;
ALTER TABLE trainer_card_template_set_items ADD CONSTRAINT trainer_card_template_set_items_movement_id_fkey FOREIGN KEY (movement_id) REFERENCES dl_movements(id) ON DELETE RESTRICT;

-- Down Migration
-- (Omitted for safety)
