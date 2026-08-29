BEGIN;
DO $$ 
DECLARE
  dup_count INT;
  rem_count INT;
  male_count INT;
  female_count INT;
  rem_dup_count INT;
  null_gender_count INT;
BEGIN
  SELECT COUNT(*) INTO dup_count FROM (
      SELECT id, ROW_NUMBER() OVER (PARTITION BY category_id, level_id, movement_id, target_gender, sort_order, set_name, group_type ORDER BY created_at ASC, id ASC) AS rnum
      FROM dl_menu_items
  ) t WHERE t.rnum > 1;

  IF dup_count != 713 THEN
    RAISE EXCEPTION 'Pre-delete duplicate count % != 713', dup_count;
  END IF;

  DELETE FROM dl_menu_items WHERE id IN (
      SELECT id FROM (
          SELECT id, ROW_NUMBER() OVER (PARTITION BY category_id, level_id, movement_id, target_gender, sort_order, set_name, group_type ORDER BY created_at ASC, id ASC) AS rnum
          FROM dl_menu_items
      ) t WHERE t.rnum > 1
  );

  SELECT COUNT(*) INTO rem_count FROM dl_menu_items;
  IF rem_count != 713 THEN
    RAISE EXCEPTION 'Remaining count % != 713', rem_count;
  END IF;

  SELECT COUNT(*) INTO male_count FROM dl_menu_items WHERE target_gender = 'male';
  SELECT COUNT(*) INTO female_count FROM dl_menu_items WHERE target_gender = 'female';
  IF male_count != 332 OR female_count != 381 THEN
    RAISE EXCEPTION 'Gender counts mismatch: male=% female=%', male_count, female_count;
  END IF;

  SELECT COUNT(*) INTO rem_dup_count FROM (
      SELECT id, ROW_NUMBER() OVER (PARTITION BY category_id, level_id, movement_id, target_gender, sort_order, set_name, group_type) AS rnum
      FROM dl_menu_items
  ) t WHERE t.rnum > 1;

  IF rem_dup_count > 0 THEN
    RAISE EXCEPTION 'Duplicates remaining: %', rem_dup_count;
  END IF;

  SELECT COUNT(*) INTO null_gender_count FROM dl_menu_items WHERE target_gender IS NULL OR target_gender NOT IN ('male', 'female');
  IF null_gender_count > 0 THEN
    RAISE EXCEPTION 'Unexpected or NULL gender count: %', null_gender_count;
  END IF;

END $$;
COMMIT;
