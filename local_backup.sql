--
-- PostgreSQL database dump
--

\restrict fL2Er7hN90jKe2jyVWCMPpeyF3DshOPlQqkMcH21bEh9Ph3Qgl8zfgUatjHvB2H

-- Dumped from database version 17.10
-- Dumped by pg_dump version 17.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.workouts DROP CONSTRAINT IF EXISTS workouts_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.workout_session_logs DROP CONSTRAINT IF EXISTS workout_session_logs_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.workout_session_logs DROP CONSTRAINT IF EXISTS workout_session_logs_trainer_card_id_fkey;
ALTER TABLE IF EXISTS ONLY public.workout_reminders DROP CONSTRAINT IF EXISTS workout_reminders_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.workout_exercises DROP CONSTRAINT IF EXISTS workout_exercises_workout_id_fkey;
ALTER TABLE IF EXISTS ONLY public.workout_exercises DROP CONSTRAINT IF EXISTS workout_exercises_exercise_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_programs DROP CONSTRAINT IF EXISTS user_programs_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_programs DROP CONSTRAINT IF EXISTS user_programs_program_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_programs DROP CONSTRAINT IF EXISTS user_programs_assigned_by_fkey;
ALTER TABLE IF EXISTS ONLY public.user_profiles DROP CONSTRAINT IF EXISTS user_profiles_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.uploads DROP CONSTRAINT IF EXISTS uploads_uploaded_by_fkey;
ALTER TABLE IF EXISTS ONLY public.training_sessions DROP CONSTRAINT IF EXISTS training_sessions_trainer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.training_sessions DROP CONSTRAINT IF EXISTS training_sessions_substituted_by_fkey;
ALTER TABLE IF EXISTS ONLY public.training_sessions DROP CONSTRAINT IF EXISTS training_sessions_schedule_id_fkey;
ALTER TABLE IF EXISTS ONLY public.training_sessions DROP CONSTRAINT IF EXISTS training_sessions_original_trainer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.training_sessions DROP CONSTRAINT IF EXISTS training_sessions_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.training_sessions DROP CONSTRAINT IF EXISTS training_sessions_client_id_fkey;
ALTER TABLE IF EXISTS ONLY public.training_schedules DROP CONSTRAINT IF EXISTS training_schedules_trainer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.training_schedules DROP CONSTRAINT IF EXISTS training_schedules_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.training_schedules DROP CONSTRAINT IF EXISTS training_schedules_client_id_fkey;
ALTER TABLE IF EXISTS ONLY public.trainer_clients DROP CONSTRAINT IF EXISTS trainer_clients_trainer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.trainer_clients DROP CONSTRAINT IF EXISTS trainer_clients_client_id_fkey;
ALTER TABLE IF EXISTS ONLY public.trainer_cards DROP CONSTRAINT IF EXISTS trainer_cards_customer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.trainer_cards DROP CONSTRAINT IF EXISTS trainer_cards_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.trainer_card_template_sets DROP CONSTRAINT IF EXISTS trainer_card_template_sets_type_id_fkey;
ALTER TABLE IF EXISTS ONLY public.trainer_card_template_sets DROP CONSTRAINT IF EXISTS trainer_card_template_sets_sequence_id_fkey;
ALTER TABLE IF EXISTS ONLY public.trainer_card_template_set_items DROP CONSTRAINT IF EXISTS trainer_card_template_set_items_set_id_fkey;
ALTER TABLE IF EXISTS ONLY public.trainer_card_template_set_items DROP CONSTRAINT IF EXISTS trainer_card_template_set_items_movement_id_fkey;
ALTER TABLE IF EXISTS ONLY public.trainer_card_template_sequences DROP CONSTRAINT IF EXISTS trainer_card_template_sequences_template_id_fkey;
ALTER TABLE IF EXISTS ONLY public.trainer_card_template_sequences DROP CONSTRAINT IF EXISTS trainer_card_template_sequences_program_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.trainer_card_sets DROP CONSTRAINT IF EXISTS trainer_card_sets_type_id_fkey;
ALTER TABLE IF EXISTS ONLY public.trainer_card_sets DROP CONSTRAINT IF EXISTS trainer_card_sets_sequence_id_fkey;
ALTER TABLE IF EXISTS ONLY public.trainer_card_set_items DROP CONSTRAINT IF EXISTS trainer_card_set_items_set_id_fkey;
ALTER TABLE IF EXISTS ONLY public.trainer_card_set_items DROP CONSTRAINT IF EXISTS trainer_card_set_items_movement_id_fkey;
ALTER TABLE IF EXISTS ONLY public.trainer_card_sequences DROP CONSTRAINT IF EXISTS trainer_card_sequences_trainer_card_id_fkey;
ALTER TABLE IF EXISTS ONLY public.trainer_card_sequences DROP CONSTRAINT IF EXISTS trainer_card_sequences_program_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.trainer_availability DROP CONSTRAINT IF EXISTS trainer_availability_trainer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tier4_waitlist_entries DROP CONSTRAINT IF EXISTS tier4_waitlist_entries_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.tier4_waitlist_entries DROP CONSTRAINT IF EXISTS tier4_waitlist_entries_assessment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.system_score_weights DROP CONSTRAINT IF EXISTS system_score_weights_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.subscriptions DROP CONSTRAINT IF EXISTS subscriptions_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.subscriptions DROP CONSTRAINT IF EXISTS subscriptions_plan_id_fkey;
ALTER TABLE IF EXISTS ONLY public.specific_conditions DROP CONSTRAINT IF EXISTS specific_conditions_classification_id_fkey;
ALTER TABLE IF EXISTS ONLY public.session_vitals DROP CONSTRAINT IF EXISTS session_vitals_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.session_medicines DROP CONSTRAINT IF EXISTS session_medicines_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.session_medicines DROP CONSTRAINT IF EXISTS session_medicines_medicine_id_fkey;
ALTER TABLE IF EXISTS ONLY public.session_meals DROP CONSTRAINT IF EXISTS session_meals_session_id_fkey;
ALTER TABLE IF EXISTS ONLY public.session_meals DROP CONSTRAINT IF EXISTS session_meals_food_id_fkey;
ALTER TABLE IF EXISTS ONLY public.promotions DROP CONSTRAINT IF EXISTS promotions_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.progress_logs DROP CONSTRAINT IF EXISTS progress_logs_workout_id_fkey;
ALTER TABLE IF EXISTS ONLY public.progress_logs DROP CONSTRAINT IF EXISTS progress_logs_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.progress_logs DROP CONSTRAINT IF EXISTS progress_logs_exercise_id_fkey;
ALTER TABLE IF EXISTS ONLY public.programs DROP CONSTRAINT IF EXISTS programs_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.program_days DROP CONSTRAINT IF EXISTS program_days_workout_id_fkey;
ALTER TABLE IF EXISTS ONLY public.program_days DROP CONSTRAINT IF EXISTS program_days_program_id_fkey;
ALTER TABLE IF EXISTS ONLY public.program_categories DROP CONSTRAINT IF EXISTS program_categories_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.payment_status_logs DROP CONSTRAINT IF EXISTS payment_status_logs_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.payment_status_logs DROP CONSTRAINT IF EXISTS payment_status_logs_subscription_id_fkey;
ALTER TABLE IF EXISTS ONLY public.payment_status_logs DROP CONSTRAINT IF EXISTS payment_status_logs_payment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.payment_status_logs DROP CONSTRAINT IF EXISTS payment_status_logs_changed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.payment_records DROP CONSTRAINT IF EXISTS payment_records_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.payment_records DROP CONSTRAINT IF EXISTS payment_records_subscription_id_fkey;
ALTER TABLE IF EXISTS ONLY public.payment_records DROP CONSTRAINT IF EXISTS payment_records_bank_account_id_fkey;
ALTER TABLE IF EXISTS ONLY public.nutrition_logs DROP CONSTRAINT IF EXISTS nutrition_logs_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.nutrition_health_profiles DROP CONSTRAINT IF EXISTS nutrition_health_profiles_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.nutrition_daily_logs DROP CONSTRAINT IF EXISTS nutrition_daily_logs_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.notifications DROP CONSTRAINT IF EXISTS notifications_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.messages DROP CONSTRAINT IF EXISTS messages_sender_id_fkey;
ALTER TABLE IF EXISTS ONLY public.messages DROP CONSTRAINT IF EXISTS messages_conversation_id_fkey;
ALTER TABLE IF EXISTS ONLY public.menus DROP CONSTRAINT IF EXISTS menus_parent_id_fkey;
ALTER TABLE IF EXISTS ONLY public.menu_role_privileges DROP CONSTRAINT IF EXISTS menu_role_privileges_menu_id_fkey;
ALTER TABLE IF EXISTS ONLY public.medicines DROP CONSTRAINT IF EXISTS medicines_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.meal_plans DROP CONSTRAINT IF EXISTS meal_plans_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.meal_plan_items DROP CONSTRAINT IF EXISTS meal_plan_items_meal_plan_id_fkey;
ALTER TABLE IF EXISTS ONLY public.lab_consultations DROP CONSTRAINT IF EXISTS lab_consultations_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.lab_consultations DROP CONSTRAINT IF EXISTS lab_consultations_payment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.lab_consultations DROP CONSTRAINT IF EXISTS lab_consultations_consultant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.lab_consultations DROP CONSTRAINT IF EXISTS lab_consultations_assessment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.habits DROP CONSTRAINT IF EXISTS habits_folder_id_fkey;
ALTER TABLE IF EXISTS ONLY public.habits DROP CONSTRAINT IF EXISTS habits_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.habit_logs DROP CONSTRAINT IF EXISTS habit_logs_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.habit_logs DROP CONSTRAINT IF EXISTS habit_logs_habit_id_fkey;
ALTER TABLE IF EXISTS ONLY public.habit_folders DROP CONSTRAINT IF EXISTS habit_folders_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.groups DROP CONSTRAINT IF EXISTS groups_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.group_members DROP CONSTRAINT IF EXISTS group_members_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.group_members DROP CONSTRAINT IF EXISTS group_members_group_id_fkey;
ALTER TABLE IF EXISTS ONLY public.forms DROP CONSTRAINT IF EXISTS forms_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.form_responses DROP CONSTRAINT IF EXISTS form_responses_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.form_responses DROP CONSTRAINT IF EXISTS form_responses_form_id_fkey;
ALTER TABLE IF EXISTS ONLY public.form_fields DROP CONSTRAINT IF EXISTS form_fields_form_id_fkey;
ALTER TABLE IF EXISTS ONLY public.foods DROP CONSTRAINT IF EXISTS foods_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.exercises DROP CONSTRAINT IF EXISTS exercises_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.event_types DROP CONSTRAINT IF EXISTS event_types_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.event_participants DROP CONSTRAINT IF EXISTS event_participants_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.event_participants DROP CONSTRAINT IF EXISTS event_participants_event_id_fkey;
ALTER TABLE IF EXISTS ONLY public.equipments DROP CONSTRAINT IF EXISTS equipments_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.dl_menu_items DROP CONSTRAINT IF EXISTS dl_menu_items_movement_id_fkey;
ALTER TABLE IF EXISTS ONLY public.dl_menu_items DROP CONSTRAINT IF EXISTS dl_menu_items_level_id_fkey;
ALTER TABLE IF EXISTS ONLY public.dl_menu_items DROP CONSTRAINT IF EXISTS dl_menu_items_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.dl_isolate_items DROP CONSTRAINT IF EXISTS dl_isolate_items_movement_id_fkey;
ALTER TABLE IF EXISTS ONLY public.dl_isolate_items DROP CONSTRAINT IF EXISTS dl_isolate_items_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.dl_dynamic_items DROP CONSTRAINT IF EXISTS dl_dynamic_items_upper_movement_id_fkey;
ALTER TABLE IF EXISTS ONLY public.dl_dynamic_items DROP CONSTRAINT IF EXISTS dl_dynamic_items_lower_movement_id_fkey;
ALTER TABLE IF EXISTS ONLY public.dl_dynamic_items DROP CONSTRAINT IF EXISTS dl_dynamic_items_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.device_tokens DROP CONSTRAINT IF EXISTS device_tokens_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.daily_journal_sessions DROP CONSTRAINT IF EXISTS daily_journal_sessions_customer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.daily_journal_sessions DROP CONSTRAINT IF EXISTS daily_journal_sessions_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.customer_program_assignments DROP CONSTRAINT IF EXISTS customer_program_assignments_program_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.customer_program_assignments DROP CONSTRAINT IF EXISTS customer_program_assignments_customer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.customer_medicines DROP CONSTRAINT IF EXISTS customer_medicines_medicine_id_fkey;
ALTER TABLE IF EXISTS ONLY public.customer_medicines DROP CONSTRAINT IF EXISTS customer_medicines_customer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.customer_hr_zones DROP CONSTRAINT IF EXISTS customer_hr_zones_customer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.conversation_members DROP CONSTRAINT IF EXISTS conversation_members_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.conversation_members DROP CONSTRAINT IF EXISTS conversation_members_conversation_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cms_testimonials DROP CONSTRAINT IF EXISTS cms_testimonials_image_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cms_settings DROP CONSTRAINT IF EXISTS cms_settings_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY public.cms_programs DROP CONSTRAINT IF EXISTS cms_programs_image_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cms_media DROP CONSTRAINT IF EXISTS cms_media_uploaded_by_fkey;
ALTER TABLE IF EXISTS ONLY public.cms_content DROP CONSTRAINT IF EXISTS cms_content_updated_by_fkey;
ALTER TABLE IF EXISTS ONLY public.clinical_notes DROP CONSTRAINT IF EXISTS clinical_notes_consultant_id_fkey;
ALTER TABLE IF EXISTS ONLY public.clinical_notes DROP CONSTRAINT IF EXISTS clinical_notes_client_id_fkey;
ALTER TABLE IF EXISTS ONLY public.clinical_notes DROP CONSTRAINT IF EXISTS clinical_notes_assessment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.challenges DROP CONSTRAINT IF EXISTS challenges_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.challenge_participants DROP CONSTRAINT IF EXISTS challenge_participants_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.challenge_participants DROP CONSTRAINT IF EXISTS challenge_participants_challenge_id_fkey;
ALTER TABLE IF EXISTS ONLY public.calendar_events DROP CONSTRAINT IF EXISTS calendar_events_event_type_id_fkey;
ALTER TABLE IF EXISTS ONLY public.calendar_events DROP CONSTRAINT IF EXISTS calendar_events_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.broadcast_notifications DROP CONSTRAINT IF EXISTS broadcast_notifications_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.body_metrics DROP CONSTRAINT IF EXISTS body_metrics_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.automations DROP CONSTRAINT IF EXISTS automations_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.automation_logs DROP CONSTRAINT IF EXISTS automation_logs_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.automation_logs DROP CONSTRAINT IF EXISTS automation_logs_automation_id_fkey;
ALTER TABLE IF EXISTS ONLY public.assessments DROP CONSTRAINT IF EXISTS assessments_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.assessments DROP CONSTRAINT IF EXISTS assessments_specific_condition_id_fkey;
ALTER TABLE IF EXISTS ONLY public.assessments DROP CONSTRAINT IF EXISTS assessments_reviewed_by_fkey;
ALTER TABLE IF EXISTS ONLY public.assessments DROP CONSTRAINT IF EXISTS assessments_classification_id_fkey;
ALTER TABLE IF EXISTS ONLY public.announcements DROP CONSTRAINT IF EXISTS announcements_created_by_fkey;
ALTER TABLE IF EXISTS ONLY public.announcement_reads DROP CONSTRAINT IF EXISTS announcement_reads_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.announcement_reads DROP CONSTRAINT IF EXISTS announcement_reads_announcement_id_fkey;
DROP TRIGGER IF EXISTS trg_workouts_updated_at ON public.workouts;
DROP TRIGGER IF EXISTS trg_users_updated_at ON public.users;
DROP TRIGGER IF EXISTS trg_user_programs_updated_at ON public.user_programs;
DROP TRIGGER IF EXISTS trg_user_profiles_updated_at ON public.user_profiles;
DROP TRIGGER IF EXISTS trg_training_sessions_updated_at ON public.training_sessions;
DROP TRIGGER IF EXISTS trg_training_schedules_updated_at ON public.training_schedules;
DROP TRIGGER IF EXISTS trg_trainer_cards_updated_at ON public.trainer_cards;
DROP TRIGGER IF EXISTS trg_trainer_card_types_updated_at ON public.trainer_card_types;
DROP TRIGGER IF EXISTS trg_trainer_card_templates_updated_at ON public.trainer_card_templates;
DROP TRIGGER IF EXISTS trg_trainer_card_template_sets_updated_at ON public.trainer_card_template_sets;
DROP TRIGGER IF EXISTS trg_trainer_card_template_set_items_updated_at ON public.trainer_card_template_set_items;
DROP TRIGGER IF EXISTS trg_trainer_card_template_sequences_updated_at ON public.trainer_card_template_sequences;
DROP TRIGGER IF EXISTS trg_trainer_card_sets_updated_at ON public.trainer_card_sets;
DROP TRIGGER IF EXISTS trg_trainer_card_set_items_updated_at ON public.trainer_card_set_items;
DROP TRIGGER IF EXISTS trg_trainer_card_sequences_updated_at ON public.trainer_card_sequences;
DROP TRIGGER IF EXISTS trg_subscriptions_updated_at ON public.subscriptions;
DROP TRIGGER IF EXISTS trg_programs_updated_at ON public.programs;
DROP TRIGGER IF EXISTS trg_payment_records_updated_at ON public.payment_records;
DROP TRIGGER IF EXISTS trg_payment_plans_updated_at ON public.payment_plans;
DROP TRIGGER IF EXISTS trg_messages_update_conversation ON public.messages;
DROP TRIGGER IF EXISTS trg_menus_updated_at ON public.menus;
DROP TRIGGER IF EXISTS trg_meal_plans_updated_at ON public.meal_plans;
DROP TRIGGER IF EXISTS trg_habits_updated_at ON public.habits;
DROP TRIGGER IF EXISTS trg_habit_folders_updated_at ON public.habit_folders;
DROP TRIGGER IF EXISTS trg_groups_updated_at ON public.groups;
DROP TRIGGER IF EXISTS trg_forms_updated_at ON public.forms;
DROP TRIGGER IF EXISTS trg_foods_updated_at ON public.foods;
DROP TRIGGER IF EXISTS trg_exercises_updated_at ON public.exercises;
DROP TRIGGER IF EXISTS trg_event_types_updated_at ON public.event_types;
DROP TRIGGER IF EXISTS trg_dl_movements_updated_at ON public.dl_movements;
DROP TRIGGER IF EXISTS trg_dl_menu_items_updated_at ON public.dl_menu_items;
DROP TRIGGER IF EXISTS trg_dl_levels_updated_at ON public.dl_levels;
DROP TRIGGER IF EXISTS trg_dl_isolate_items_updated_at ON public.dl_isolate_items;
DROP TRIGGER IF EXISTS trg_dl_dynamic_items_updated_at ON public.dl_dynamic_items;
DROP TRIGGER IF EXISTS trg_dl_categories_updated_at ON public.dl_categories;
DROP TRIGGER IF EXISTS trg_device_tokens_updated ON public.device_tokens;
DROP TRIGGER IF EXISTS trg_conversations_updated_at ON public.conversations;
DROP TRIGGER IF EXISTS trg_challenges_updated_at ON public.challenges;
DROP TRIGGER IF EXISTS trg_calendar_events_updated_at ON public.calendar_events;
DROP TRIGGER IF EXISTS trg_bank_accounts_updated_at ON public.bank_accounts;
DROP TRIGGER IF EXISTS trg_automations_updated_at ON public.automations;
DROP TRIGGER IF EXISTS trg_assessments_updated_at ON public.assessments;
DROP TRIGGER IF EXISTS trg_announcements_updated_at ON public.announcements;
DROP TRIGGER IF EXISTS set_tier4_waitlist_entries_updated_at ON public.tier4_waitlist_entries;
DROP TRIGGER IF EXISTS set_system_score_weights_updated_at ON public.system_score_weights;
DROP TRIGGER IF EXISTS set_specific_conditions_updated_at ON public.specific_conditions;
DROP TRIGGER IF EXISTS set_program_categories_updated_at ON public.program_categories;
DROP TRIGGER IF EXISTS set_physical_status_levels_updated_at ON public.physical_status_levels;
DROP TRIGGER IF EXISTS set_medicines_updated_at ON public.medicines;
DROP TRIGGER IF EXISTS set_lab_consultations_updated_at ON public.lab_consultations;
DROP TRIGGER IF EXISTS set_equipments_updated_at ON public.equipments;
DROP TRIGGER IF EXISTS set_daily_journal_sessions_updated_at ON public.daily_journal_sessions;
DROP TRIGGER IF EXISTS set_customer_program_assignments_updated_at ON public.customer_program_assignments;
DROP TRIGGER IF EXISTS set_customer_hr_zones_updated_at ON public.customer_hr_zones;
DROP TRIGGER IF EXISTS set_condition_classifications_updated_at ON public.condition_classifications;
DROP TRIGGER IF EXISTS set_clinical_notes_updated_at ON public.clinical_notes;
DROP INDEX IF EXISTS public.uq_users_email_active;
DROP INDEX IF EXISTS public.idx_workouts_type;
DROP INDEX IF EXISTS public.idx_workouts_is_template;
DROP INDEX IF EXISTS public.idx_workouts_created_by;
DROP INDEX IF EXISTS public.idx_workout_session_logs_user_type;
DROP INDEX IF EXISTS public.idx_workout_session_logs_user_completed;
DROP INDEX IF EXISTS public.idx_workout_reminders_enabled;
DROP INDEX IF EXISTS public.idx_workout_exercises_workout;
DROP INDEX IF EXISTS public.idx_workout_exercises_exercise;
DROP INDEX IF EXISTS public.idx_users_status;
DROP INDEX IF EXISTS public.idx_users_role;
DROP INDEX IF EXISTS public.idx_users_deleted_at;
DROP INDEX IF EXISTS public.idx_users_created_at;
DROP INDEX IF EXISTS public.idx_user_programs_user_status;
DROP INDEX IF EXISTS public.idx_user_programs_user;
DROP INDEX IF EXISTS public.idx_user_programs_program;
DROP INDEX IF EXISTS public.idx_user_programs_assigned_by;
DROP INDEX IF EXISTS public.idx_uploads_uploaded_by;
DROP INDEX IF EXISTS public.idx_uploads_entity;
DROP INDEX IF EXISTS public.idx_training_sessions_trainer;
DROP INDEX IF EXISTS public.idx_training_sessions_substituted_by;
DROP INDEX IF EXISTS public.idx_training_sessions_substitute;
DROP INDEX IF EXISTS public.idx_training_sessions_status;
DROP INDEX IF EXISTS public.idx_training_sessions_schedule;
DROP INDEX IF EXISTS public.idx_training_sessions_date;
DROP INDEX IF EXISTS public.idx_training_sessions_client;
DROP INDEX IF EXISTS public.idx_training_schedules_trainer;
DROP INDEX IF EXISTS public.idx_training_schedules_day;
DROP INDEX IF EXISTS public.idx_training_schedules_client;
DROP INDEX IF EXISTS public.idx_training_schedules_active;
DROP INDEX IF EXISTS public.idx_trainer_clients_status;
DROP INDEX IF EXISTS public.idx_trainer_clients_client;
DROP INDEX IF EXISTS public.idx_trainer_cards_customer;
DROP INDEX IF EXISTS public.idx_trainer_cards_created_by;
DROP INDEX IF EXISTS public.idx_trainer_card_template_sets_sequence;
DROP INDEX IF EXISTS public.idx_trainer_card_template_set_items_set;
DROP INDEX IF EXISTS public.idx_trainer_card_template_set_items_movement;
DROP INDEX IF EXISTS public.idx_trainer_card_template_sequences_tmpl;
DROP INDEX IF EXISTS public.idx_trainer_card_sets_sequence;
DROP INDEX IF EXISTS public.idx_trainer_card_set_items_set;
DROP INDEX IF EXISTS public.idx_trainer_card_set_items_movement;
DROP INDEX IF EXISTS public.idx_trainer_card_sequences_card;
DROP INDEX IF EXISTS public.idx_trainer_availability;
DROP INDEX IF EXISTS public.idx_tier4_waitlist_user;
DROP INDEX IF EXISTS public.idx_tier4_waitlist_status_created;
DROP INDEX IF EXISTS public.idx_tier4_waitlist_email;
DROP INDEX IF EXISTS public.idx_system_score_weights_active;
DROP INDEX IF EXISTS public.idx_subscriptions_user_status;
DROP INDEX IF EXISTS public.idx_subscriptions_user;
DROP INDEX IF EXISTS public.idx_subscriptions_status;
DROP INDEX IF EXISTS public.idx_subscriptions_plan;
DROP INDEX IF EXISTS public.idx_subscriptions_expires;
DROP INDEX IF EXISTS public.idx_specific_conditions_classification;
DROP INDEX IF EXISTS public.idx_session_vitals_session;
DROP INDEX IF EXISTS public.idx_session_medicines_session;
DROP INDEX IF EXISTS public.idx_session_meals_session;
DROP INDEX IF EXISTS public.idx_promotions_status;
DROP INDEX IF EXISTS public.idx_promotions_active;
DROP INDEX IF EXISTS public.idx_progress_logs_workout;
DROP INDEX IF EXISTS public.idx_progress_logs_user_logged;
DROP INDEX IF EXISTS public.idx_progress_logs_user_exercise;
DROP INDEX IF EXISTS public.idx_progress_logs_logged_at;
DROP INDEX IF EXISTS public.idx_progress_logs_exercise;
DROP INDEX IF EXISTS public.idx_programs_is_template;
DROP INDEX IF EXISTS public.idx_programs_difficulty;
DROP INDEX IF EXISTS public.idx_programs_created_by;
DROP INDEX IF EXISTS public.idx_program_days_workout;
DROP INDEX IF EXISTS public.idx_program_days_program;
DROP INDEX IF EXISTS public.idx_program_categories_name_trgm;
DROP INDEX IF EXISTS public.idx_program_categories_code;
DROP INDEX IF EXISTS public.idx_physical_status_levels_active_sort;
DROP INDEX IF EXISTS public.idx_payment_status_logs_user;
DROP INDEX IF EXISTS public.idx_payment_status_logs_payment;
DROP INDEX IF EXISTS public.idx_payment_status_logs_created;
DROP INDEX IF EXISTS public.idx_payment_status_logs_changed_by;
DROP INDEX IF EXISTS public.idx_payment_records_user;
DROP INDEX IF EXISTS public.idx_payment_records_subscription;
DROP INDEX IF EXISTS public.idx_payment_records_status;
DROP INDEX IF EXISTS public.idx_payment_records_proof;
DROP INDEX IF EXISTS public.idx_payment_records_paid_at;
DROP INDEX IF EXISTS public.idx_payment_records_gateway_status;
DROP INDEX IF EXISTS public.idx_payment_records_external;
DROP INDEX IF EXISTS public.idx_payment_plans_tier;
DROP INDEX IF EXISTS public.idx_payment_plans_sort;
DROP INDEX IF EXISTS public.idx_payment_plans_active;
DROP INDEX IF EXISTS public.idx_nutrition_logs_user_logged;
DROP INDEX IF EXISTS public.idx_nutrition_daily_logs_user_date;
DROP INDEX IF EXISTS public.idx_notifications_user_status;
DROP INDEX IF EXISTS public.idx_notifications_user_created;
DROP INDEX IF EXISTS public.idx_messages_unread;
DROP INDEX IF EXISTS public.idx_messages_sender;
DROP INDEX IF EXISTS public.idx_messages_conversation_created;
DROP INDEX IF EXISTS public.idx_menus_sort_order;
DROP INDEX IF EXISTS public.idx_menus_parent_id;
DROP INDEX IF EXISTS public.idx_menus_is_active;
DROP INDEX IF EXISTS public.idx_menu_role_priv_role;
DROP INDEX IF EXISTS public.idx_menu_role_priv_menu_id;
DROP INDEX IF EXISTS public.idx_medicines_name_trgm;
DROP INDEX IF EXISTS public.idx_medicines_category;
DROP INDEX IF EXISTS public.idx_meal_plans_created_by;
DROP INDEX IF EXISTS public.idx_meal_plan_items_plan;
DROP INDEX IF EXISTS public.idx_meal_plan_items_day_meal;
DROP INDEX IF EXISTS public.idx_lab_consultations_user;
DROP INDEX IF EXISTS public.idx_lab_consultations_status;
DROP INDEX IF EXISTS public.idx_lab_consultations_consultant;
DROP INDEX IF EXISTS public.idx_health_articles_published_created;
DROP INDEX IF EXISTS public.idx_habits_name;
DROP INDEX IF EXISTS public.idx_habits_is_system;
DROP INDEX IF EXISTS public.idx_habits_folder;
DROP INDEX IF EXISTS public.idx_habit_logs_user;
DROP INDEX IF EXISTS public.idx_habit_logs_habit;
DROP INDEX IF EXISTS public.idx_habit_folders_sort;
DROP INDEX IF EXISTS public.idx_groups_created_by;
DROP INDEX IF EXISTS public.idx_group_members_user;
DROP INDEX IF EXISTS public.idx_group_members_group;
DROP INDEX IF EXISTS public.idx_forms_status;
DROP INDEX IF EXISTS public.idx_forms_created_by;
DROP INDEX IF EXISTS public.idx_form_responses_user;
DROP INDEX IF EXISTS public.idx_form_responses_form;
DROP INDEX IF EXISTS public.idx_form_fields_form;
DROP INDEX IF EXISTS public.idx_foods_name;
DROP INDEX IF EXISTS public.idx_foods_meal_types;
DROP INDEX IF EXISTS public.idx_foods_is_system;
DROP INDEX IF EXISTS public.idx_foods_created_by;
DROP INDEX IF EXISTS public.idx_exercises_name_trgm;
DROP INDEX IF EXISTS public.idx_exercises_muscle_group;
DROP INDEX IF EXISTS public.idx_exercises_is_system;
DROP INDEX IF EXISTS public.idx_exercises_difficulty;
DROP INDEX IF EXISTS public.idx_exercises_created_by;
DROP INDEX IF EXISTS public.idx_event_types_category;
DROP INDEX IF EXISTS public.idx_event_participants_user;
DROP INDEX IF EXISTS public.idx_event_participants_event;
DROP INDEX IF EXISTS public.idx_equipments_is_active;
DROP INDEX IF EXISTS public.idx_equipments_category;
DROP INDEX IF EXISTS public.idx_doctor_videos_published_created;
DROP INDEX IF EXISTS public.idx_dl_movements_name_trgm;
DROP INDEX IF EXISTS public.idx_dl_movements_categories;
DROP INDEX IF EXISTS public.idx_dl_movements_body_part;
DROP INDEX IF EXISTS public.idx_dl_menu_movement;
DROP INDEX IF EXISTS public.idx_dl_menu_cat_level;
DROP INDEX IF EXISTS public.idx_dl_isolate_cat_pos;
DROP INDEX IF EXISTS public.idx_dl_dynamic_category;
DROP INDEX IF EXISTS public.idx_device_tokens_user;
DROP INDEX IF EXISTS public.idx_device_tokens_token;
DROP INDEX IF EXISTS public.idx_daily_journal_sessions_month;
DROP INDEX IF EXISTS public.idx_daily_journal_sessions_customer;
DROP INDEX IF EXISTS public.idx_customer_program_assignments_customer;
DROP INDEX IF EXISTS public.idx_customer_medicines_customer;
DROP INDEX IF EXISTS public.idx_conversation_members_user;
DROP INDEX IF EXISTS public.idx_condition_classifications_active_sort;
DROP INDEX IF EXISTS public.idx_cms_testimonials_locale_active_order;
DROP INDEX IF EXISTS public.idx_cms_programs_locale_active_order;
DROP INDEX IF EXISTS public.idx_cms_pricing_tiers_locale_active_order;
DROP INDEX IF EXISTS public.idx_cms_media_tag_created;
DROP INDEX IF EXISTS public.idx_clinical_notes_consultant_created;
DROP INDEX IF EXISTS public.idx_clinical_notes_client_created;
DROP INDEX IF EXISTS public.idx_clinical_notes_assessment;
DROP INDEX IF EXISTS public.idx_challenges_status;
DROP INDEX IF EXISTS public.idx_challenges_dates;
DROP INDEX IF EXISTS public.idx_challenges_creator;
DROP INDEX IF EXISTS public.idx_challenge_participants_user;
DROP INDEX IF EXISTS public.idx_challenge_participants_challenge;
DROP INDEX IF EXISTS public.idx_calendar_events_status;
DROP INDEX IF EXISTS public.idx_calendar_events_start;
DROP INDEX IF EXISTS public.idx_calendar_events_range;
DROP INDEX IF EXISTS public.idx_calendar_events_creator;
DROP INDEX IF EXISTS public.idx_body_metrics_user_logged;
DROP INDEX IF EXISTS public.idx_bank_accounts_active;
DROP INDEX IF EXISTS public.idx_automations_trigger_type;
DROP INDEX IF EXISTS public.idx_automations_is_active;
DROP INDEX IF EXISTS public.idx_automations_created_by;
DROP INDEX IF EXISTS public.idx_automation_logs_user;
DROP INDEX IF EXISTS public.idx_automation_logs_triggered;
DROP INDEX IF EXISTS public.idx_automation_logs_status;
DROP INDEX IF EXISTS public.idx_automation_logs_automation;
DROP INDEX IF EXISTS public.idx_assessments_version_v2;
DROP INDEX IF EXISTS public.idx_assessments_user_created;
DROP INDEX IF EXISTS public.idx_assessments_tier;
DROP INDEX IF EXISTS public.idx_assessments_status;
DROP INDEX IF EXISTS public.idx_assessments_pending_review;
DROP INDEX IF EXISTS public.idx_assessments_classification;
DROP INDEX IF EXISTS public.idx_announcements_status;
DROP INDEX IF EXISTS public.idx_announcements_published;
DROP INDEX IF EXISTS public.idx_announcements_creator;
DROP INDEX IF EXISTS public.idx_announcement_reads_user;
DROP INDEX IF EXISTS public.idx_announcement_reads_announcement;
ALTER TABLE IF EXISTS ONLY public.workouts DROP CONSTRAINT IF EXISTS workouts_pkey;
ALTER TABLE IF EXISTS ONLY public.workout_session_logs DROP CONSTRAINT IF EXISTS workout_session_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.workout_reminders DROP CONSTRAINT IF EXISTS workout_reminders_user_id_key;
ALTER TABLE IF EXISTS ONLY public.workout_reminders DROP CONSTRAINT IF EXISTS workout_reminders_pkey;
ALTER TABLE IF EXISTS ONLY public.workout_exercises DROP CONSTRAINT IF EXISTS workout_exercises_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.user_programs DROP CONSTRAINT IF EXISTS user_programs_pkey;
ALTER TABLE IF EXISTS ONLY public.user_profiles DROP CONSTRAINT IF EXISTS user_profiles_pkey;
ALTER TABLE IF EXISTS ONLY public.workout_exercises DROP CONSTRAINT IF EXISTS uq_workout_exercise_order;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS uq_users_email;
ALTER TABLE IF EXISTS ONLY public.trainer_cards DROP CONSTRAINT IF EXISTS uq_trainer_cards_customer;
ALTER TABLE IF EXISTS ONLY public.trainer_card_template_sequences DROP CONSTRAINT IF EXISTS uq_trainer_card_template_sequence;
ALTER TABLE IF EXISTS ONLY public.trainer_card_sequences DROP CONSTRAINT IF EXISTS uq_trainer_card_sequence;
ALTER TABLE IF EXISTS ONLY public.program_days DROP CONSTRAINT IF EXISTS uq_program_day;
ALTER TABLE IF EXISTS ONLY public.habit_logs DROP CONSTRAINT IF EXISTS uq_habit_logs_user_habit_date;
ALTER TABLE IF EXISTS ONLY public.group_members DROP CONSTRAINT IF EXISTS uq_group_members;
ALTER TABLE IF EXISTS ONLY public.event_participants DROP CONSTRAINT IF EXISTS uq_event_participants;
ALTER TABLE IF EXISTS ONLY public.challenge_participants DROP CONSTRAINT IF EXISTS uq_challenge_participants;
ALTER TABLE IF EXISTS ONLY public.announcement_reads DROP CONSTRAINT IF EXISTS uq_announcement_reads;
ALTER TABLE IF EXISTS ONLY public.uploads DROP CONSTRAINT IF EXISTS uploads_pkey;
ALTER TABLE IF EXISTS ONLY public.training_sessions DROP CONSTRAINT IF EXISTS training_sessions_pkey;
ALTER TABLE IF EXISTS ONLY public.training_schedules DROP CONSTRAINT IF EXISTS training_schedules_pkey;
ALTER TABLE IF EXISTS ONLY public.trainer_clients DROP CONSTRAINT IF EXISTS trainer_clients_pkey;
ALTER TABLE IF EXISTS ONLY public.trainer_cards DROP CONSTRAINT IF EXISTS trainer_cards_pkey;
ALTER TABLE IF EXISTS ONLY public.trainer_card_types DROP CONSTRAINT IF EXISTS trainer_card_types_pkey;
ALTER TABLE IF EXISTS ONLY public.trainer_card_types DROP CONSTRAINT IF EXISTS trainer_card_types_name_key;
ALTER TABLE IF EXISTS ONLY public.trainer_card_templates DROP CONSTRAINT IF EXISTS trainer_card_templates_pkey;
ALTER TABLE IF EXISTS ONLY public.trainer_card_templates DROP CONSTRAINT IF EXISTS trainer_card_templates_level_key;
ALTER TABLE IF EXISTS ONLY public.trainer_card_template_sets DROP CONSTRAINT IF EXISTS trainer_card_template_sets_pkey;
ALTER TABLE IF EXISTS ONLY public.trainer_card_template_set_items DROP CONSTRAINT IF EXISTS trainer_card_template_set_items_pkey;
ALTER TABLE IF EXISTS ONLY public.trainer_card_template_sequences DROP CONSTRAINT IF EXISTS trainer_card_template_sequences_pkey;
ALTER TABLE IF EXISTS ONLY public.trainer_card_sets DROP CONSTRAINT IF EXISTS trainer_card_sets_pkey;
ALTER TABLE IF EXISTS ONLY public.trainer_card_set_items DROP CONSTRAINT IF EXISTS trainer_card_set_items_pkey;
ALTER TABLE IF EXISTS ONLY public.trainer_card_sequences DROP CONSTRAINT IF EXISTS trainer_card_sequences_pkey;
ALTER TABLE IF EXISTS ONLY public.trainer_availability DROP CONSTRAINT IF EXISTS trainer_availability_pkey;
ALTER TABLE IF EXISTS ONLY public.tier4_waitlist_entries DROP CONSTRAINT IF EXISTS tier4_waitlist_entries_pkey;
ALTER TABLE IF EXISTS ONLY public.system_score_weights DROP CONSTRAINT IF EXISTS system_score_weights_pkey;
ALTER TABLE IF EXISTS ONLY public.subscriptions DROP CONSTRAINT IF EXISTS subscriptions_pkey;
ALTER TABLE IF EXISTS ONLY public.specific_conditions DROP CONSTRAINT IF EXISTS specific_conditions_slug_key;
ALTER TABLE IF EXISTS ONLY public.specific_conditions DROP CONSTRAINT IF EXISTS specific_conditions_pkey;
ALTER TABLE IF EXISTS ONLY public.session_vitals DROP CONSTRAINT IF EXISTS session_vitals_session_id_measurement_type_key;
ALTER TABLE IF EXISTS ONLY public.session_vitals DROP CONSTRAINT IF EXISTS session_vitals_pkey;
ALTER TABLE IF EXISTS ONLY public.session_medicines DROP CONSTRAINT IF EXISTS session_medicines_session_id_medicine_id_key;
ALTER TABLE IF EXISTS ONLY public.session_medicines DROP CONSTRAINT IF EXISTS session_medicines_pkey;
ALTER TABLE IF EXISTS ONLY public.session_meals DROP CONSTRAINT IF EXISTS session_meals_pkey;
ALTER TABLE IF EXISTS ONLY public.promotions DROP CONSTRAINT IF EXISTS promotions_pkey;
ALTER TABLE IF EXISTS ONLY public.progress_logs DROP CONSTRAINT IF EXISTS progress_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.programs DROP CONSTRAINT IF EXISTS programs_pkey;
ALTER TABLE IF EXISTS ONLY public.program_days DROP CONSTRAINT IF EXISTS program_days_pkey;
ALTER TABLE IF EXISTS ONLY public.program_categories DROP CONSTRAINT IF EXISTS program_categories_pkey;
ALTER TABLE IF EXISTS ONLY public.program_categories DROP CONSTRAINT IF EXISTS program_categories_code_key;
ALTER TABLE IF EXISTS ONLY public.physical_status_levels DROP CONSTRAINT IF EXISTS physical_status_levels_slug_key;
ALTER TABLE IF EXISTS ONLY public.physical_status_levels DROP CONSTRAINT IF EXISTS physical_status_levels_pkey;
ALTER TABLE IF EXISTS ONLY public.payment_status_logs DROP CONSTRAINT IF EXISTS payment_status_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.payment_records DROP CONSTRAINT IF EXISTS payment_records_pkey;
ALTER TABLE IF EXISTS ONLY public.payment_plans DROP CONSTRAINT IF EXISTS payment_plans_pkey;
ALTER TABLE IF EXISTS ONLY public.nutrition_logs DROP CONSTRAINT IF EXISTS nutrition_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.nutrition_health_profiles DROP CONSTRAINT IF EXISTS nutrition_health_profiles_pkey;
ALTER TABLE IF EXISTS ONLY public.nutrition_daily_logs DROP CONSTRAINT IF EXISTS nutrition_daily_logs_user_id_log_date_key;
ALTER TABLE IF EXISTS ONLY public.nutrition_daily_logs DROP CONSTRAINT IF EXISTS nutrition_daily_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.notifications DROP CONSTRAINT IF EXISTS notifications_pkey;
ALTER TABLE IF EXISTS ONLY public.messages DROP CONSTRAINT IF EXISTS messages_pkey;
ALTER TABLE IF EXISTS ONLY public.menus DROP CONSTRAINT IF EXISTS menus_pkey;
ALTER TABLE IF EXISTS ONLY public.menus DROP CONSTRAINT IF EXISTS menus_code_key;
ALTER TABLE IF EXISTS ONLY public.menu_role_privileges DROP CONSTRAINT IF EXISTS menu_role_privileges_pkey;
ALTER TABLE IF EXISTS ONLY public.menu_role_privileges DROP CONSTRAINT IF EXISTS menu_role_privileges_menu_id_role_key;
ALTER TABLE IF EXISTS ONLY public.medicines DROP CONSTRAINT IF EXISTS medicines_pkey;
ALTER TABLE IF EXISTS ONLY public.meal_plans DROP CONSTRAINT IF EXISTS meal_plans_pkey;
ALTER TABLE IF EXISTS ONLY public.meal_plan_items DROP CONSTRAINT IF EXISTS meal_plan_items_pkey;
ALTER TABLE IF EXISTS ONLY public.lab_consultations DROP CONSTRAINT IF EXISTS lab_consultations_pkey;
ALTER TABLE IF EXISTS ONLY public.health_articles DROP CONSTRAINT IF EXISTS health_articles_pkey;
ALTER TABLE IF EXISTS ONLY public.habits DROP CONSTRAINT IF EXISTS habits_pkey;
ALTER TABLE IF EXISTS ONLY public.habit_logs DROP CONSTRAINT IF EXISTS habit_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.habit_folders DROP CONSTRAINT IF EXISTS habit_folders_pkey;
ALTER TABLE IF EXISTS ONLY public.groups DROP CONSTRAINT IF EXISTS groups_pkey;
ALTER TABLE IF EXISTS ONLY public.group_members DROP CONSTRAINT IF EXISTS group_members_pkey;
ALTER TABLE IF EXISTS ONLY public.forms DROP CONSTRAINT IF EXISTS forms_pkey;
ALTER TABLE IF EXISTS ONLY public.form_responses DROP CONSTRAINT IF EXISTS form_responses_pkey;
ALTER TABLE IF EXISTS ONLY public.form_fields DROP CONSTRAINT IF EXISTS form_fields_pkey;
ALTER TABLE IF EXISTS ONLY public.foods DROP CONSTRAINT IF EXISTS foods_pkey;
ALTER TABLE IF EXISTS ONLY public.exercises DROP CONSTRAINT IF EXISTS exercises_pkey;
ALTER TABLE IF EXISTS ONLY public.event_types DROP CONSTRAINT IF EXISTS event_types_pkey;
ALTER TABLE IF EXISTS ONLY public.event_participants DROP CONSTRAINT IF EXISTS event_participants_pkey;
ALTER TABLE IF EXISTS ONLY public.equipments DROP CONSTRAINT IF EXISTS equipments_pkey;
ALTER TABLE IF EXISTS ONLY public.doctor_videos DROP CONSTRAINT IF EXISTS doctor_videos_pkey;
ALTER TABLE IF EXISTS ONLY public.dl_movements DROP CONSTRAINT IF EXISTS dl_movements_pkey;
ALTER TABLE IF EXISTS ONLY public.dl_movements DROP CONSTRAINT IF EXISTS dl_movements_name_key;
ALTER TABLE IF EXISTS ONLY public.dl_menu_items DROP CONSTRAINT IF EXISTS dl_menu_items_pkey;
ALTER TABLE IF EXISTS ONLY public.dl_levels DROP CONSTRAINT IF EXISTS dl_levels_pkey;
ALTER TABLE IF EXISTS ONLY public.dl_levels DROP CONSTRAINT IF EXISTS dl_levels_level_number_key;
ALTER TABLE IF EXISTS ONLY public.dl_isolate_items DROP CONSTRAINT IF EXISTS dl_isolate_items_pkey;
ALTER TABLE IF EXISTS ONLY public.dl_dynamic_items DROP CONSTRAINT IF EXISTS dl_dynamic_items_pkey;
ALTER TABLE IF EXISTS ONLY public.dl_categories DROP CONSTRAINT IF EXISTS dl_categories_pkey;
ALTER TABLE IF EXISTS ONLY public.dl_categories DROP CONSTRAINT IF EXISTS dl_categories_code_key;
ALTER TABLE IF EXISTS ONLY public.device_tokens DROP CONSTRAINT IF EXISTS device_tokens_pkey;
ALTER TABLE IF EXISTS ONLY public.daily_journal_sessions DROP CONSTRAINT IF EXISTS daily_journal_sessions_pkey;
ALTER TABLE IF EXISTS ONLY public.daily_journal_sessions DROP CONSTRAINT IF EXISTS daily_journal_sessions_customer_id_session_date_key;
ALTER TABLE IF EXISTS ONLY public.customer_program_assignments DROP CONSTRAINT IF EXISTS customer_program_assignments_pkey;
ALTER TABLE IF EXISTS ONLY public.customer_program_assignments DROP CONSTRAINT IF EXISTS customer_program_assignments_customer_id_program_category_i_key;
ALTER TABLE IF EXISTS ONLY public.customer_medicines DROP CONSTRAINT IF EXISTS customer_medicines_pkey;
ALTER TABLE IF EXISTS ONLY public.customer_medicines DROP CONSTRAINT IF EXISTS customer_medicines_customer_id_medicine_id_key;
ALTER TABLE IF EXISTS ONLY public.customer_hr_zones DROP CONSTRAINT IF EXISTS customer_hr_zones_pkey;
ALTER TABLE IF EXISTS ONLY public.customer_hr_zones DROP CONSTRAINT IF EXISTS customer_hr_zones_customer_id_key;
ALTER TABLE IF EXISTS ONLY public.conversations DROP CONSTRAINT IF EXISTS conversations_pkey;
ALTER TABLE IF EXISTS ONLY public.conversation_members DROP CONSTRAINT IF EXISTS conversation_members_pkey;
ALTER TABLE IF EXISTS ONLY public.condition_classifications DROP CONSTRAINT IF EXISTS condition_classifications_slug_key;
ALTER TABLE IF EXISTS ONLY public.condition_classifications DROP CONSTRAINT IF EXISTS condition_classifications_pkey;
ALTER TABLE IF EXISTS ONLY public.cms_testimonials DROP CONSTRAINT IF EXISTS cms_testimonials_pkey;
ALTER TABLE IF EXISTS ONLY public.cms_settings DROP CONSTRAINT IF EXISTS cms_settings_pkey;
ALTER TABLE IF EXISTS ONLY public.cms_programs DROP CONSTRAINT IF EXISTS cms_programs_pkey;
ALTER TABLE IF EXISTS ONLY public.cms_pricing_tiers DROP CONSTRAINT IF EXISTS cms_pricing_tiers_pkey;
ALTER TABLE IF EXISTS ONLY public.cms_media DROP CONSTRAINT IF EXISTS cms_media_pkey;
ALTER TABLE IF EXISTS ONLY public.cms_content DROP CONSTRAINT IF EXISTS cms_content_pkey;
ALTER TABLE IF EXISTS ONLY public.clinical_notes DROP CONSTRAINT IF EXISTS clinical_notes_pkey;
ALTER TABLE IF EXISTS ONLY public.challenges DROP CONSTRAINT IF EXISTS challenges_pkey;
ALTER TABLE IF EXISTS ONLY public.challenge_participants DROP CONSTRAINT IF EXISTS challenge_participants_pkey;
ALTER TABLE IF EXISTS ONLY public.calendar_events DROP CONSTRAINT IF EXISTS calendar_events_pkey;
ALTER TABLE IF EXISTS ONLY public.broadcast_notifications DROP CONSTRAINT IF EXISTS broadcast_notifications_pkey;
ALTER TABLE IF EXISTS ONLY public.body_metrics DROP CONSTRAINT IF EXISTS body_metrics_pkey;
ALTER TABLE IF EXISTS ONLY public.bank_accounts DROP CONSTRAINT IF EXISTS bank_accounts_pkey;
ALTER TABLE IF EXISTS ONLY public.automations DROP CONSTRAINT IF EXISTS automations_pkey;
ALTER TABLE IF EXISTS ONLY public.automation_logs DROP CONSTRAINT IF EXISTS automation_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.assessments DROP CONSTRAINT IF EXISTS assessments_pkey;
ALTER TABLE IF EXISTS ONLY public.announcements DROP CONSTRAINT IF EXISTS announcements_pkey;
ALTER TABLE IF EXISTS ONLY public.announcement_reads DROP CONSTRAINT IF EXISTS announcement_reads_pkey;
DROP TABLE IF EXISTS public.workouts;
DROP TABLE IF EXISTS public.workout_session_logs;
DROP TABLE IF EXISTS public.workout_reminders;
DROP TABLE IF EXISTS public.workout_exercises;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.user_programs;
DROP TABLE IF EXISTS public.user_profiles;
DROP TABLE IF EXISTS public.uploads;
DROP TABLE IF EXISTS public.training_sessions;
DROP TABLE IF EXISTS public.training_schedules;
DROP TABLE IF EXISTS public.trainer_clients;
DROP TABLE IF EXISTS public.trainer_cards;
DROP TABLE IF EXISTS public.trainer_card_types;
DROP TABLE IF EXISTS public.trainer_card_templates;
DROP TABLE IF EXISTS public.trainer_card_template_sets;
DROP TABLE IF EXISTS public.trainer_card_template_set_items;
DROP TABLE IF EXISTS public.trainer_card_template_sequences;
DROP TABLE IF EXISTS public.trainer_card_sets;
DROP TABLE IF EXISTS public.trainer_card_set_items;
DROP TABLE IF EXISTS public.trainer_card_sequences;
DROP TABLE IF EXISTS public.trainer_availability;
DROP TABLE IF EXISTS public.tier4_waitlist_entries;
DROP TABLE IF EXISTS public.system_score_weights;
DROP TABLE IF EXISTS public.subscriptions;
DROP TABLE IF EXISTS public.specific_conditions;
DROP TABLE IF EXISTS public.session_vitals;
DROP TABLE IF EXISTS public.session_medicines;
DROP TABLE IF EXISTS public.session_meals;
DROP TABLE IF EXISTS public.promotions;
DROP TABLE IF EXISTS public.progress_logs;
DROP TABLE IF EXISTS public.programs;
DROP TABLE IF EXISTS public.program_days;
DROP TABLE IF EXISTS public.program_categories;
DROP TABLE IF EXISTS public.physical_status_levels;
DROP TABLE IF EXISTS public.payment_status_logs;
DROP TABLE IF EXISTS public.payment_records;
DROP TABLE IF EXISTS public.payment_plans;
DROP TABLE IF EXISTS public.nutrition_logs;
DROP TABLE IF EXISTS public.nutrition_health_profiles;
DROP TABLE IF EXISTS public.nutrition_daily_logs;
DROP TABLE IF EXISTS public.notifications;
DROP TABLE IF EXISTS public.messages;
DROP TABLE IF EXISTS public.menus;
DROP TABLE IF EXISTS public.menu_role_privileges;
DROP TABLE IF EXISTS public.medicines;
DROP TABLE IF EXISTS public.meal_plans;
DROP TABLE IF EXISTS public.meal_plan_items;
DROP TABLE IF EXISTS public.lab_consultations;
DROP TABLE IF EXISTS public.health_articles;
DROP TABLE IF EXISTS public.habits;
DROP TABLE IF EXISTS public.habit_logs;
DROP TABLE IF EXISTS public.habit_folders;
DROP TABLE IF EXISTS public.groups;
DROP TABLE IF EXISTS public.group_members;
DROP TABLE IF EXISTS public.forms;
DROP TABLE IF EXISTS public.form_responses;
DROP TABLE IF EXISTS public.form_fields;
DROP TABLE IF EXISTS public.foods;
DROP TABLE IF EXISTS public.exercises;
DROP TABLE IF EXISTS public.event_types;
DROP TABLE IF EXISTS public.event_participants;
DROP TABLE IF EXISTS public.equipments;
DROP TABLE IF EXISTS public.doctor_videos;
DROP TABLE IF EXISTS public.dl_movements;
DROP TABLE IF EXISTS public.dl_menu_items;
DROP TABLE IF EXISTS public.dl_levels;
DROP TABLE IF EXISTS public.dl_isolate_items;
DROP TABLE IF EXISTS public.dl_dynamic_items;
DROP TABLE IF EXISTS public.dl_categories;
DROP TABLE IF EXISTS public.device_tokens;
DROP TABLE IF EXISTS public.daily_journal_sessions;
DROP TABLE IF EXISTS public.customer_program_assignments;
DROP TABLE IF EXISTS public.customer_medicines;
DROP TABLE IF EXISTS public.customer_hr_zones;
DROP TABLE IF EXISTS public.conversations;
DROP TABLE IF EXISTS public.conversation_members;
DROP TABLE IF EXISTS public.condition_classifications;
DROP TABLE IF EXISTS public.cms_testimonials;
DROP TABLE IF EXISTS public.cms_settings;
DROP TABLE IF EXISTS public.cms_programs;
DROP TABLE IF EXISTS public.cms_pricing_tiers;
DROP TABLE IF EXISTS public.cms_media;
DROP TABLE IF EXISTS public.cms_content;
DROP TABLE IF EXISTS public.clinical_notes;
DROP TABLE IF EXISTS public.challenges;
DROP TABLE IF EXISTS public.challenge_participants;
DROP TABLE IF EXISTS public.calendar_events;
DROP TABLE IF EXISTS public.broadcast_notifications;
DROP TABLE IF EXISTS public.body_metrics;
DROP TABLE IF EXISTS public.bank_accounts;
DROP TABLE IF EXISTS public.automations;
DROP TABLE IF EXISTS public.automation_logs;
DROP TABLE IF EXISTS public.assessments;
DROP TABLE IF EXISTS public.announcements;
DROP TABLE IF EXISTS public.announcement_reads;
DROP FUNCTION IF EXISTS public.fn_set_updated_at();
DROP FUNCTION IF EXISTS public.fn_message_update_conversation();
DROP TYPE IF EXISTS public.workout_type;
DROP TYPE IF EXISTS public.user_status;
DROP TYPE IF EXISTS public.user_role;
DROP TYPE IF EXISTS public.trigger_type;
DROP TYPE IF EXISTS public.training_session_status;
DROP TYPE IF EXISTS public.training_phase;
DROP TYPE IF EXISTS public.training_category;
DROP TYPE IF EXISTS public.subscription_status;
DROP TYPE IF EXISTS public.program_goal;
DROP TYPE IF EXISTS public.payment_status;
DROP TYPE IF EXISTS public.notification_status;
DROP TYPE IF EXISTS public.mood_type;
DROP TYPE IF EXISTS public.message_type;
DROP TYPE IF EXISTS public.meal_type;
DROP TYPE IF EXISTS public.gender_type;
DROP TYPE IF EXISTS public.form_status;
DROP TYPE IF EXISTS public.form_field_type;
DROP TYPE IF EXISTS public.focus_pillar;
DROP TYPE IF EXISTS public.fitness_goal;
DROP TYPE IF EXISTS public.experience_level;
DROP TYPE IF EXISTS public.event_status;
DROP TYPE IF EXISTS public.event_category;
DROP TYPE IF EXISTS public.dl_position;
DROP TYPE IF EXISTS public.dl_body_part;
DROP TYPE IF EXISTS public.difficulty_level;
DROP TYPE IF EXISTS public.conversation_type;
DROP TYPE IF EXISTS public.conversation_role;
DROP TYPE IF EXISTS public.challenge_status;
DROP TYPE IF EXISTS public.automation_log_status;
DROP TYPE IF EXISTS public.assignment_status;
DROP TYPE IF EXISTS public.assessment_tier;
DROP TYPE IF EXISTS public.assessment_status;
DROP TYPE IF EXISTS public.assessment_classification;
DROP TYPE IF EXISTS public.announcement_status;
DROP TYPE IF EXISTS public.action_type;
DROP EXTENSION IF EXISTS pgcrypto;
DROP EXTENSION IF EXISTS pg_trgm;
--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: action_type; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.action_type AS ENUM (
    'send_message',
    'assign_program',
    'send_reminder',
    'send_notification',
    'send_email'
);


ALTER TYPE public.action_type OWNER TO fitcoach;

--
-- Name: announcement_status; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.announcement_status AS ENUM (
    'draft',
    'published',
    'archived'
);


ALTER TYPE public.announcement_status OWNER TO fitcoach;

--
-- Name: assessment_classification; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.assessment_classification AS ENUM (
    'optimal',
    'compromised',
    'critical',
    'stable',
    'compensation',
    'dysfunction',
    'efficient',
    'at_risk',
    'dysregulated'
);


ALTER TYPE public.assessment_classification OWNER TO fitcoach;

--
-- Name: assessment_status; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.assessment_status AS ENUM (
    'submitted',
    'verified',
    'revised'
);


ALTER TYPE public.assessment_status OWNER TO fitcoach;

--
-- Name: assessment_tier; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.assessment_tier AS ENUM (
    'free',
    'paid'
);


ALTER TYPE public.assessment_tier OWNER TO fitcoach;

--
-- Name: assignment_status; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.assignment_status AS ENUM (
    'active',
    'paused',
    'completed',
    'cancelled'
);


ALTER TYPE public.assignment_status OWNER TO fitcoach;

--
-- Name: automation_log_status; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.automation_log_status AS ENUM (
    'success',
    'failed',
    'skipped'
);


ALTER TYPE public.automation_log_status OWNER TO fitcoach;

--
-- Name: challenge_status; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.challenge_status AS ENUM (
    'draft',
    'active',
    'completed',
    'cancelled'
);


ALTER TYPE public.challenge_status OWNER TO fitcoach;

--
-- Name: conversation_role; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.conversation_role AS ENUM (
    'member',
    'admin'
);


ALTER TYPE public.conversation_role OWNER TO fitcoach;

--
-- Name: conversation_type; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.conversation_type AS ENUM (
    'direct',
    'group'
);


ALTER TYPE public.conversation_type OWNER TO fitcoach;

--
-- Name: difficulty_level; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.difficulty_level AS ENUM (
    'beginner',
    'intermediate',
    'advanced'
);


ALTER TYPE public.difficulty_level OWNER TO fitcoach;

--
-- Name: dl_body_part; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.dl_body_part AS ENUM (
    'upper',
    'lower',
    'core',
    'whole body'
);


ALTER TYPE public.dl_body_part OWNER TO fitcoach;

--
-- Name: dl_position; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.dl_position AS ENUM (
    'sit',
    'stand',
    'mat'
);


ALTER TYPE public.dl_position OWNER TO fitcoach;

--
-- Name: event_category; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.event_category AS ENUM (
    'one_on_one',
    'group_class',
    'personal'
);


ALTER TYPE public.event_category OWNER TO fitcoach;

--
-- Name: event_status; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.event_status AS ENUM (
    'scheduled',
    'cancelled',
    'completed'
);


ALTER TYPE public.event_status OWNER TO fitcoach;

--
-- Name: experience_level; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.experience_level AS ENUM (
    'beginner',
    'intermediate',
    'advanced'
);


ALTER TYPE public.experience_level OWNER TO fitcoach;

--
-- Name: fitness_goal; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.fitness_goal AS ENUM (
    'lose_weight',
    'gain_muscle',
    'maintain',
    'improve_endurance',
    'flexibility'
);


ALTER TYPE public.fitness_goal OWNER TO fitcoach;

--
-- Name: focus_pillar; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.focus_pillar AS ENUM (
    'FC',
    'CC',
    'MC'
);


ALTER TYPE public.focus_pillar OWNER TO fitcoach;

--
-- Name: form_field_type; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.form_field_type AS ENUM (
    'text',
    'textarea',
    'number',
    'select',
    'multi_select',
    'checkbox',
    'radio',
    'date',
    'rating',
    'file_upload'
);


ALTER TYPE public.form_field_type OWNER TO fitcoach;

--
-- Name: form_status; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.form_status AS ENUM (
    'draft',
    'published',
    'archived'
);


ALTER TYPE public.form_status OWNER TO fitcoach;

--
-- Name: gender_type; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.gender_type AS ENUM (
    'male',
    'female',
    'other'
);


ALTER TYPE public.gender_type OWNER TO fitcoach;

--
-- Name: meal_type; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.meal_type AS ENUM (
    'breakfast',
    'lunch',
    'dinner',
    'snack'
);


ALTER TYPE public.meal_type OWNER TO fitcoach;

--
-- Name: message_type; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.message_type AS ENUM (
    'text',
    'image',
    'voice',
    'system'
);


ALTER TYPE public.message_type OWNER TO fitcoach;

--
-- Name: mood_type; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.mood_type AS ENUM (
    'great',
    'good',
    'okay',
    'tired',
    'bad'
);


ALTER TYPE public.mood_type OWNER TO fitcoach;

--
-- Name: notification_status; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.notification_status AS ENUM (
    'unread',
    'read',
    'dismissed'
);


ALTER TYPE public.notification_status OWNER TO fitcoach;

--
-- Name: payment_status; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.payment_status AS ENUM (
    'pending',
    'completed',
    'failed',
    'refunded'
);


ALTER TYPE public.payment_status OWNER TO fitcoach;

--
-- Name: program_goal; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.program_goal AS ENUM (
    'lose_weight',
    'gain_muscle',
    'maintain',
    'general_fitness'
);


ALTER TYPE public.program_goal OWNER TO fitcoach;

--
-- Name: subscription_status; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.subscription_status AS ENUM (
    'pending',
    'active',
    'cancelled',
    'expired',
    'past_due'
);


ALTER TYPE public.subscription_status OWNER TO fitcoach;

--
-- Name: training_category; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.training_category AS ENUM (
    'fc',
    'cc',
    'mc'
);


ALTER TYPE public.training_category OWNER TO fitcoach;

--
-- Name: training_phase; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.training_phase AS ENUM (
    'menu',
    'isolate',
    'dynamic'
);


ALTER TYPE public.training_phase OWNER TO fitcoach;

--
-- Name: training_session_status; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.training_session_status AS ENUM (
    'scheduled',
    'completed',
    'cancelled',
    'substituted'
);


ALTER TYPE public.training_session_status OWNER TO fitcoach;

--
-- Name: trigger_type; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.trigger_type AS ENUM (
    'on_signup',
    'on_program_complete',
    'on_inactive_days',
    'scheduled',
    'on_milestone'
);


ALTER TYPE public.trigger_type OWNER TO fitcoach;

--
-- Name: user_role; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.user_role AS ENUM (
    'owner',
    'admin',
    'finance',
    'trainer',
    'consultant',
    'client'
);


ALTER TYPE public.user_role OWNER TO fitcoach;

--
-- Name: user_status; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.user_status AS ENUM (
    'active',
    'inactive',
    'suspended',
    'pending'
);


ALTER TYPE public.user_status OWNER TO fitcoach;

--
-- Name: workout_type; Type: TYPE; Schema: public; Owner: fitcoach
--

CREATE TYPE public.workout_type AS ENUM (
    'strength',
    'cardio',
    'hiit',
    'flexibility',
    'custom'
);


ALTER TYPE public.workout_type OWNER TO fitcoach;

--
-- Name: fn_message_update_conversation(); Type: FUNCTION; Schema: public; Owner: fitcoach
--

CREATE FUNCTION public.fn_message_update_conversation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE conversations
    SET updated_at = NOW()
    WHERE id = NEW.conversation_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_message_update_conversation() OWNER TO fitcoach;

--
-- Name: fn_set_updated_at(); Type: FUNCTION; Schema: public; Owner: fitcoach
--

CREATE FUNCTION public.fn_set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_set_updated_at() OWNER TO fitcoach;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: announcement_reads; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.announcement_reads (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    announcement_id uuid NOT NULL,
    user_id uuid NOT NULL,
    read_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.announcement_reads OWNER TO fitcoach;

--
-- Name: announcements; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.announcements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title character varying(200) NOT NULL,
    body text NOT NULL,
    image_url text,
    status public.announcement_status DEFAULT 'draft'::public.announcement_status NOT NULL,
    target_roles public.user_role[] DEFAULT '{}'::public.user_role[] NOT NULL,
    published_at timestamp with time zone,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_announcements_title CHECK ((char_length((title)::text) >= 1))
);


ALTER TABLE public.announcements OWNER TO fitcoach;

--
-- Name: assessments; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.assessments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    tier public.assessment_tier NOT NULL,
    status public.assessment_status DEFAULT 'submitted'::public.assessment_status NOT NULL,
    sleep_input jsonb,
    movement_input jsonb,
    metabolic_input jsonb,
    sleep_score smallint,
    recovery_score smallint,
    movement_score smallint,
    metabolic_score smallint,
    system_score smallint,
    sleep_class public.assessment_classification,
    movement_class public.assessment_classification,
    metabolic_class public.assessment_classification,
    flags text[] DEFAULT '{}'::text[] NOT NULL,
    insight text,
    recommendations text[] DEFAULT '{}'::text[] NOT NULL,
    reviewed_by uuid,
    reviewed_at timestamp with time zone,
    reviewer_notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    version character varying(8) DEFAULT 'v1'::character varying NOT NULL,
    phase_a_payload jsonb,
    phase_b_payload jsonb,
    phase_c_payload jsonb,
    rest_score numeric(5,2),
    nutrition_score numeric(5,2),
    movement_score_v2 numeric(5,2),
    system_score_v2 numeric(5,2),
    chronobiology_window jsonb,
    classification_id uuid,
    specific_condition_id uuid,
    physical_status_level character varying(16),
    program_type character varying(40),
    program_map_payload jsonb,
    CONSTRAINT chk_assessments_paid_metabolic CHECK (((tier <> 'paid'::public.assessment_tier) OR (metabolic_input IS NOT NULL))),
    CONSTRAINT chk_assessments_program_type CHECK (((program_type IS NULL) OR ((program_type)::text = ANY ((ARRAY['condition_specific'::character varying, 'preventive'::character varying, 'performance_women_35_45'::character varying, 'performance_women_46_60'::character varying, 'performance_men_35_45'::character varying, 'performance_men_46_60'::character varying, 'waitlist'::character varying])::text[])))),
    CONSTRAINT chk_assessments_version_payload CHECK (((((version)::text = 'v1'::text) AND (sleep_input IS NOT NULL) AND (movement_input IS NOT NULL)) OR (((version)::text = 'v2'::text) AND (phase_a_payload IS NOT NULL))))
);


ALTER TABLE public.assessments OWNER TO fitcoach;

--
-- Name: automation_logs; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.automation_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    automation_id uuid NOT NULL,
    user_id uuid,
    triggered_at timestamp with time zone DEFAULT now() NOT NULL,
    status public.automation_log_status NOT NULL,
    result jsonb DEFAULT '{}'::jsonb,
    error_message text
);


ALTER TABLE public.automation_logs OWNER TO fitcoach;

--
-- Name: automations; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.automations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    trigger_type public.trigger_type NOT NULL,
    trigger_config jsonb DEFAULT '{}'::jsonb NOT NULL,
    action_type public.action_type NOT NULL,
    action_config jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_automations_name CHECK ((char_length((name)::text) >= 1))
);


ALTER TABLE public.automations OWNER TO fitcoach;

--
-- Name: COLUMN automations.trigger_config; Type: COMMENT; Schema: public; Owner: fitcoach
--

COMMENT ON COLUMN public.automations.trigger_config IS 'Trigger-specific config. Examples:
     on_inactive_days: {"inactive_days": 3}
     scheduled: {"cron": "0 8 * * 1"}
     on_milestone: {"milestone": "100_workouts"}';


--
-- Name: COLUMN automations.action_config; Type: COMMENT; Schema: public; Owner: fitcoach
--

COMMENT ON COLUMN public.automations.action_config IS 'Action-specific config. Examples:
     send_message: {"message": "Hey {{user.name}}!"}
     assign_program: {"program_id": "uuid-here"}
     send_email: {"template": "welcome", "subject": "Welcome!"}';


--
-- Name: bank_accounts; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.bank_accounts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bank_name character varying(100) NOT NULL,
    account_number character varying(50) NOT NULL,
    account_holder character varying(100) NOT NULL,
    branch character varying(100),
    notes text,
    is_active boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_bank_accounts_account_holder CHECK ((char_length((account_holder)::text) >= 1)),
    CONSTRAINT chk_bank_accounts_account_number CHECK ((char_length((account_number)::text) >= 1)),
    CONSTRAINT chk_bank_accounts_bank_name CHECK ((char_length((bank_name)::text) >= 1))
);


ALTER TABLE public.bank_accounts OWNER TO fitcoach;

--
-- Name: TABLE bank_accounts; Type: COMMENT; Schema: public; Owner: fitcoach
--

COMMENT ON TABLE public.bank_accounts IS 'Bank accounts customers transfer to for manual payments. Managed by admin.';


--
-- Name: body_metrics; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.body_metrics (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    logged_at timestamp with time zone DEFAULT now() NOT NULL,
    weight_kg numeric(5,1),
    body_fat_pct numeric(4,1),
    muscle_mass_kg numeric(5,1),
    photo_urls text[] DEFAULT '{}'::text[],
    notes text,
    CONSTRAINT body_metrics_body_fat_pct_check CHECK (((body_fat_pct >= (0)::numeric) AND (body_fat_pct <= (100)::numeric))),
    CONSTRAINT body_metrics_muscle_mass_kg_check CHECK ((muscle_mass_kg >= (0)::numeric)),
    CONSTRAINT body_metrics_weight_kg_check CHECK (((weight_kg > (0)::numeric) AND (weight_kg < (500)::numeric))),
    CONSTRAINT chk_body_metrics_has_data CHECK (((weight_kg IS NOT NULL) OR (body_fat_pct IS NOT NULL) OR (muscle_mass_kg IS NOT NULL) OR (array_length(photo_urls, 1) > 0)))
);


ALTER TABLE public.body_metrics OWNER TO fitcoach;

--
-- Name: broadcast_notifications; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.broadcast_notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title character varying(200) NOT NULL,
    body text NOT NULL,
    type character varying(50) DEFAULT 'promo'::character varying NOT NULL,
    data jsonb,
    target_roles text[],
    image_url text,
    scheduled_at timestamp with time zone,
    sent_at timestamp with time zone,
    sent_count integer DEFAULT 0,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.broadcast_notifications OWNER TO fitcoach;

--
-- Name: calendar_events; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.calendar_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_type_id uuid,
    title character varying(200) NOT NULL,
    description text,
    category public.event_category DEFAULT 'one_on_one'::public.event_category NOT NULL,
    status public.event_status DEFAULT 'scheduled'::public.event_status NOT NULL,
    start_at timestamp with time zone NOT NULL,
    end_at timestamp with time zone NOT NULL,
    location character varying(200),
    max_participants integer,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT calendar_events_max_participants_check CHECK ((max_participants > 0)),
    CONSTRAINT chk_calendar_events_times CHECK ((end_at > start_at)),
    CONSTRAINT chk_calendar_events_title CHECK ((char_length((title)::text) >= 1))
);


ALTER TABLE public.calendar_events OWNER TO fitcoach;

--
-- Name: challenge_participants; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.challenge_participants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    challenge_id uuid NOT NULL,
    user_id uuid NOT NULL,
    progress_value numeric(10,2) DEFAULT 0 NOT NULL,
    joined_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone
);


ALTER TABLE public.challenge_participants OWNER TO fitcoach;

--
-- Name: challenges; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.challenges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(150) NOT NULL,
    description text,
    image_url text,
    status public.challenge_status DEFAULT 'draft'::public.challenge_status NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    goal_type character varying(50),
    goal_value numeric(10,2),
    max_participants integer,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT challenges_max_participants_check CHECK ((max_participants > 0)),
    CONSTRAINT chk_challenges_dates CHECK ((end_date >= start_date)),
    CONSTRAINT chk_challenges_name CHECK ((char_length((name)::text) >= 1))
);


ALTER TABLE public.challenges OWNER TO fitcoach;

--
-- Name: clinical_notes; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.clinical_notes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    assessment_id uuid,
    client_id uuid NOT NULL,
    consultant_id uuid NOT NULL,
    title character varying(160) DEFAULT ''::character varying NOT NULL,
    content text NOT NULL,
    attachments jsonb DEFAULT '[]'::jsonb NOT NULL,
    is_visible_to_client boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT chk_clinical_notes_not_self CHECK ((client_id <> consultant_id))
);


ALTER TABLE public.clinical_notes OWNER TO fitcoach;

--
-- Name: cms_content; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.cms_content (
    section_key character varying(64) NOT NULL,
    locale character varying(8) NOT NULL,
    draft_data jsonb DEFAULT '{}'::jsonb NOT NULL,
    published_data jsonb,
    published_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by uuid
);


ALTER TABLE public.cms_content OWNER TO fitcoach;

--
-- Name: cms_media; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.cms_media (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    filename text NOT NULL,
    url text NOT NULL,
    mime character varying(64) NOT NULL,
    width integer,
    height integer,
    size_bytes bigint DEFAULT 0 NOT NULL,
    alt text,
    tag character varying(64),
    uploaded_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.cms_media OWNER TO fitcoach;

--
-- Name: cms_pricing_tiers; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.cms_pricing_tiers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    locale character varying(8) NOT NULL,
    order_index integer DEFAULT 0 NOT NULL,
    name text NOT NULL,
    for_whom text NOT NULL,
    amount_monthly text NOT NULL,
    per_monthly text NOT NULL,
    amount_yearly text,
    per_yearly text,
    equiv_yearly text,
    original_yearly text,
    savings_yearly text,
    features jsonb DEFAULT '[]'::jsonb NOT NULL,
    cta_label text NOT NULL,
    cta_style character varying(16) DEFAULT 'solid'::character varying NOT NULL,
    is_featured boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.cms_pricing_tiers OWNER TO fitcoach;

--
-- Name: cms_programs; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.cms_programs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    locale character varying(8) NOT NULL,
    order_index integer DEFAULT 0 NOT NULL,
    tier_label text NOT NULL,
    tier_color character varying(16) DEFAULT ''::character varying NOT NULL,
    name text NOT NULL,
    description text NOT NULL,
    features jsonb DEFAULT '[]'::jsonb NOT NULL,
    meta jsonb DEFAULT '[]'::jsonb NOT NULL,
    image_id uuid,
    image_url text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.cms_programs OWNER TO fitcoach;

--
-- Name: cms_settings; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.cms_settings (
    key character varying(64) NOT NULL,
    value jsonb NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by uuid
);


ALTER TABLE public.cms_settings OWNER TO fitcoach;

--
-- Name: cms_testimonials; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.cms_testimonials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    locale character varying(8) NOT NULL,
    order_index integer DEFAULT 0 NOT NULL,
    name text NOT NULL,
    role text NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    rating smallint DEFAULT 5 NOT NULL,
    image_id uuid,
    image_url text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.cms_testimonials OWNER TO fitcoach;

--
-- Name: condition_classifications; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.condition_classifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    slug character varying(64) NOT NULL,
    label character varying(120) NOT NULL,
    description text,
    focus_pillar public.focus_pillar NOT NULL,
    full_program_formula jsonb DEFAULT '{}'::jsonb NOT NULL,
    daily_reset_formula jsonb DEFAULT '{}'::jsonb NOT NULL,
    sort_order smallint DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.condition_classifications OWNER TO fitcoach;

--
-- Name: conversation_members; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.conversation_members (
    conversation_id uuid NOT NULL,
    user_id uuid NOT NULL,
    joined_at timestamp with time zone DEFAULT now() NOT NULL,
    role public.conversation_role DEFAULT 'member'::public.conversation_role NOT NULL,
    is_muted boolean DEFAULT false NOT NULL,
    last_read_at timestamp with time zone
);


ALTER TABLE public.conversation_members OWNER TO fitcoach;

--
-- Name: conversations; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.conversations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    type public.conversation_type DEFAULT 'direct'::public.conversation_type NOT NULL,
    name character varying(100),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_conversations_group_name CHECK (((type = 'direct'::public.conversation_type) OR ((type = 'group'::public.conversation_type) AND (name IS NOT NULL))))
);


ALTER TABLE public.conversations OWNER TO fitcoach;

--
-- Name: customer_hr_zones; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.customer_hr_zones (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    customer_id uuid NOT NULL,
    max_hr_upper integer,
    max_hr_lower integer,
    zone5_upper integer,
    zone5_lower integer,
    zone4_upper integer,
    zone4_lower integer,
    zone3_upper integer,
    zone3_lower integer,
    zone2_upper integer,
    zone2_lower integer,
    zone1_upper integer,
    zone1_lower integer,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    priority text
);


ALTER TABLE public.customer_hr_zones OWNER TO fitcoach;

--
-- Name: customer_medicines; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.customer_medicines (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    customer_id uuid NOT NULL,
    medicine_id uuid NOT NULL,
    notes text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.customer_medicines OWNER TO fitcoach;

--
-- Name: customer_program_assignments; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.customer_program_assignments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    customer_id uuid NOT NULL,
    program_category_id uuid NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    bpm_upper integer,
    bpm_lower integer,
    has_beban_upper boolean DEFAULT false NOT NULL,
    has_beban_lower boolean DEFAULT false NOT NULL,
    has_resistance boolean DEFAULT false NOT NULL,
    parameter_notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    beban_upper_value numeric(5,1),
    beban_lower_value numeric(5,1)
);


ALTER TABLE public.customer_program_assignments OWNER TO fitcoach;

--
-- Name: daily_journal_sessions; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.daily_journal_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    customer_id uuid NOT NULL,
    session_number integer NOT NULL,
    session_date date NOT NULL,
    month_year character varying(7),
    notes text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.daily_journal_sessions OWNER TO fitcoach;

--
-- Name: device_tokens; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.device_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    token text NOT NULL,
    platform character varying(20) DEFAULT 'android'::character varying NOT NULL,
    device_name character varying(100),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.device_tokens OWNER TO fitcoach;

--
-- Name: dl_categories; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.dl_categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    code public.training_category NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.dl_categories OWNER TO fitcoach;

--
-- Name: dl_dynamic_items; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.dl_dynamic_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    category_id uuid NOT NULL,
    upper_movement_id uuid,
    lower_movement_id uuid,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_dl_dynamic_has_movement CHECK (((upper_movement_id IS NOT NULL) OR (lower_movement_id IS NOT NULL)))
);


ALTER TABLE public.dl_dynamic_items OWNER TO fitcoach;

--
-- Name: dl_isolate_items; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.dl_isolate_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    category_id uuid NOT NULL,
    movement_id uuid NOT NULL,
    "position" public.dl_position NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.dl_isolate_items OWNER TO fitcoach;

--
-- Name: dl_levels; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.dl_levels (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    level_number integer NOT NULL,
    name character varying(100) NOT NULL,
    name_id character varying(100) NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT dl_levels_level_number_check CHECK (((level_number >= 0) AND (level_number <= 5)))
);


ALTER TABLE public.dl_levels OWNER TO fitcoach;

--
-- Name: dl_menu_items; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.dl_menu_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    category_id uuid NOT NULL,
    level_id uuid NOT NULL,
    movement_id uuid NOT NULL,
    body_part public.dl_body_part NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.dl_menu_items OWNER TO fitcoach;

--
-- Name: dl_movements; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.dl_movements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(150) NOT NULL,
    body_part public.dl_body_part NOT NULL,
    video_url_male text,
    video_url_female text,
    image_url text,
    instructions text[] DEFAULT '{}'::text[],
    categories public.training_category[] DEFAULT '{}'::public.training_category[] NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    type public.dl_position,
    pattern character varying(50),
    level integer,
    name_en character varying(150),
    instructions_en text[] DEFAULT '{}'::text[],
    description_en text
);


ALTER TABLE public.dl_movements OWNER TO fitcoach;

--
-- Name: doctor_videos; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.doctor_videos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    video_url text NOT NULL,
    thumbnail_url text NOT NULL,
    doctor_name text NOT NULL,
    doctor_specialty text DEFAULT 'Spesialis Kesehatan'::text NOT NULL,
    is_published boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    title_en text,
    description_en text
);


ALTER TABLE public.doctor_videos OWNER TO fitcoach;

--
-- Name: equipments; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.equipments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    category character varying(10) NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT equipments_category_check CHECK (((category)::text = ANY ((ARRAY['upper'::character varying, 'lower'::character varying])::text[])))
);


ALTER TABLE public.equipments OWNER TO fitcoach;

--
-- Name: event_participants; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.event_participants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid NOT NULL,
    user_id uuid NOT NULL,
    rsvp_status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    joined_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_rsvp_status CHECK (((rsvp_status)::text = ANY ((ARRAY['pending'::character varying, 'accepted'::character varying, 'declined'::character varying])::text[])))
);


ALTER TABLE public.event_participants OWNER TO fitcoach;

--
-- Name: event_types; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.event_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    category public.event_category DEFAULT 'one_on_one'::public.event_category NOT NULL,
    duration_min integer DEFAULT 60 NOT NULL,
    color character varying(20),
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_event_types_name CHECK ((char_length((name)::text) >= 1)),
    CONSTRAINT event_types_duration_min_check CHECK ((duration_min > 0))
);


ALTER TABLE public.event_types OWNER TO fitcoach;

--
-- Name: exercises; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.exercises (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    muscle_group character varying(50)[] DEFAULT '{}'::character varying[] NOT NULL,
    equipment character varying(50),
    difficulty public.difficulty_level DEFAULT 'beginner'::public.difficulty_level NOT NULL,
    video_url text,
    thumbnail_url text,
    instructions text[] DEFAULT '{}'::text[],
    created_by uuid,
    is_system boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_exercises_muscle_group CHECK (((array_length(muscle_group, 1) > 0) OR (muscle_group = '{}'::character varying[]))),
    CONSTRAINT chk_exercises_name CHECK ((char_length((name)::text) >= 1))
);


ALTER TABLE public.exercises OWNER TO fitcoach;

--
-- Name: foods; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.foods (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(150) NOT NULL,
    description text,
    image_url text,
    meal_types public.meal_type[] DEFAULT '{}'::public.meal_type[] NOT NULL,
    calories integer,
    protein_g numeric(6,1),
    carbs_g numeric(6,1),
    fat_g numeric(6,1),
    fiber_g numeric(6,1),
    serving_size character varying(50),
    serving_unit character varying(30),
    is_system boolean DEFAULT false NOT NULL,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_foods_name CHECK ((char_length((name)::text) >= 1)),
    CONSTRAINT foods_calories_check CHECK ((calories >= 0)),
    CONSTRAINT foods_carbs_g_check CHECK ((carbs_g >= (0)::numeric)),
    CONSTRAINT foods_fat_g_check CHECK ((fat_g >= (0)::numeric)),
    CONSTRAINT foods_fiber_g_check CHECK ((fiber_g >= (0)::numeric)),
    CONSTRAINT foods_protein_g_check CHECK ((protein_g >= (0)::numeric))
);


ALTER TABLE public.foods OWNER TO fitcoach;

--
-- Name: form_fields; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.form_fields (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    form_id uuid NOT NULL,
    label character varying(200) NOT NULL,
    field_type public.form_field_type NOT NULL,
    required boolean DEFAULT false NOT NULL,
    options jsonb,
    sort_order integer DEFAULT 0 NOT NULL,
    CONSTRAINT chk_form_fields_label CHECK ((char_length((label)::text) >= 1))
);


ALTER TABLE public.form_fields OWNER TO fitcoach;

--
-- Name: form_responses; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.form_responses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    form_id uuid NOT NULL,
    user_id uuid NOT NULL,
    answers jsonb DEFAULT '{}'::jsonb NOT NULL,
    submitted_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.form_responses OWNER TO fitcoach;

--
-- Name: forms; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.forms (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(150) NOT NULL,
    description text,
    status public.form_status DEFAULT 'draft'::public.form_status NOT NULL,
    is_system boolean DEFAULT false NOT NULL,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_forms_name CHECK ((char_length((name)::text) >= 1))
);


ALTER TABLE public.forms OWNER TO fitcoach;

--
-- Name: group_members; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.group_members (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    group_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role character varying(20) DEFAULT 'member'::character varying NOT NULL,
    joined_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_group_member_role CHECK (((role)::text = ANY ((ARRAY['admin'::character varying, 'member'::character varying])::text[])))
);


ALTER TABLE public.group_members OWNER TO fitcoach;

--
-- Name: groups; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.groups (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    image_url text,
    max_members integer,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_groups_name CHECK ((char_length((name)::text) >= 1)),
    CONSTRAINT groups_max_members_check CHECK ((max_members > 0))
);


ALTER TABLE public.groups OWNER TO fitcoach;

--
-- Name: habit_folders; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.habit_folders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_habit_folders_name CHECK ((char_length((name)::text) >= 1))
);


ALTER TABLE public.habit_folders OWNER TO fitcoach;

--
-- Name: habit_logs; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.habit_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    habit_id uuid NOT NULL,
    logged_at date DEFAULT CURRENT_DATE NOT NULL,
    completed boolean DEFAULT true NOT NULL,
    notes text
);


ALTER TABLE public.habit_logs OWNER TO fitcoach;

--
-- Name: habits; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.habits (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    folder_id uuid,
    name character varying(150) NOT NULL,
    description text,
    icon character varying(50),
    is_system boolean DEFAULT false NOT NULL,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_habits_name CHECK ((char_length((name)::text) >= 1))
);


ALTER TABLE public.habits OWNER TO fitcoach;

--
-- Name: health_articles; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.health_articles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title text NOT NULL,
    content text NOT NULL,
    image_url text NOT NULL,
    source text DEFAULT 'Systemic Fitness'::text NOT NULL,
    is_published boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    title_en text,
    content_en text
);


ALTER TABLE public.health_articles OWNER TO fitcoach;

--
-- Name: lab_consultations; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.lab_consultations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    consultant_id uuid,
    assessment_id uuid,
    payment_id uuid,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    fee_amount numeric(12,2) DEFAULT 350000 NOT NULL,
    booking_note text,
    preferred_at timestamp with time zone,
    scheduled_at timestamp with time zone,
    completed_at timestamp with time zone,
    result_summary text,
    result_payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT lab_consultations_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'scheduled'::character varying, 'completed'::character varying, 'cancelled'::character varying, 'no_show'::character varying])::text[])))
);


ALTER TABLE public.lab_consultations OWNER TO fitcoach;

--
-- Name: meal_plan_items; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.meal_plan_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    meal_plan_id uuid NOT NULL,
    meal_type public.meal_type NOT NULL,
    day_of_week integer,
    food_name character varying(100) NOT NULL,
    portion character varying(50),
    calories integer,
    protein_g numeric(6,1),
    carbs_g numeric(6,1),
    fat_g numeric(6,1),
    CONSTRAINT chk_meal_plan_items_food CHECK ((char_length((food_name)::text) >= 1)),
    CONSTRAINT meal_plan_items_calories_check CHECK ((calories >= 0)),
    CONSTRAINT meal_plan_items_carbs_g_check CHECK ((carbs_g >= (0)::numeric)),
    CONSTRAINT meal_plan_items_day_of_week_check CHECK (((day_of_week >= 0) AND (day_of_week <= 6))),
    CONSTRAINT meal_plan_items_fat_g_check CHECK ((fat_g >= (0)::numeric)),
    CONSTRAINT meal_plan_items_protein_g_check CHECK ((protein_g >= (0)::numeric))
);


ALTER TABLE public.meal_plan_items OWNER TO fitcoach;

--
-- Name: meal_plans; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.meal_plans (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    daily_calories integer,
    protein_g integer,
    carbs_g integer,
    fat_g integer,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_meal_plans_name CHECK ((char_length((name)::text) >= 1)),
    CONSTRAINT meal_plans_carbs_g_check CHECK ((carbs_g >= 0)),
    CONSTRAINT meal_plans_daily_calories_check CHECK ((daily_calories > 0)),
    CONSTRAINT meal_plans_fat_g_check CHECK ((fat_g >= 0)),
    CONSTRAINT meal_plans_protein_g_check CHECK ((protein_g >= 0))
);


ALTER TABLE public.meal_plans OWNER TO fitcoach;

--
-- Name: medicines; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.medicines (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(200) NOT NULL,
    category character varying(200),
    main_function text,
    side_effects text,
    detail_url character varying(500),
    image_url character varying(500),
    is_system boolean DEFAULT false NOT NULL,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.medicines OWNER TO fitcoach;

--
-- Name: menu_role_privileges; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.menu_role_privileges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    menu_id uuid NOT NULL,
    role public.user_role NOT NULL,
    can_access boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.menu_role_privileges OWNER TO fitcoach;

--
-- Name: menus; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.menus (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    parent_id uuid,
    code character varying(50) NOT NULL,
    label character varying(100) NOT NULL,
    icon character varying(50),
    href character varying(255),
    sort_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.menus OWNER TO fitcoach;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    conversation_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    content text,
    type public.message_type DEFAULT 'text'::public.message_type NOT NULL,
    media_url text,
    is_read boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_messages_content CHECK ((((type = 'text'::public.message_type) AND (content IS NOT NULL) AND (char_length(content) > 0)) OR ((type = ANY (ARRAY['image'::public.message_type, 'voice'::public.message_type])) AND (media_url IS NOT NULL)) OR ((type = 'system'::public.message_type) AND (content IS NOT NULL))))
);


ALTER TABLE public.messages OWNER TO fitcoach;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    title character varying(200) NOT NULL,
    body text NOT NULL,
    type character varying(50) DEFAULT 'general'::character varying NOT NULL,
    data jsonb,
    status public.notification_status DEFAULT 'unread'::public.notification_status NOT NULL,
    sent_via_push boolean DEFAULT false NOT NULL,
    push_sent_at timestamp with time zone,
    read_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.notifications OWNER TO fitcoach;

--
-- Name: nutrition_daily_logs; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.nutrition_daily_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    log_date date NOT NULL,
    vegetable_intake boolean DEFAULT false NOT NULL,
    protein_intake boolean DEFAULT false NOT NULL,
    hydration_ok boolean DEFAULT false NOT NULL,
    sugar_excess boolean DEFAULT false NOT NULL,
    diet_violation boolean DEFAULT false NOT NULL,
    score integer DEFAULT 0 NOT NULL,
    status text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT nutrition_daily_logs_status_check CHECK ((status = ANY (ARRAY['stable'::text, 'warning'::text, 'risk'::text])))
);


ALTER TABLE public.nutrition_daily_logs OWNER TO fitcoach;

--
-- Name: nutrition_health_profiles; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.nutrition_health_profiles (
    user_id uuid NOT NULL,
    gender text NOT NULL,
    age_group text NOT NULL,
    female_condition text,
    goal text NOT NULL,
    weight_kg numeric(5,2) DEFAULT 0 NOT NULL,
    allergies text[] DEFAULT '{}'::text[] NOT NULL,
    conditions text[] DEFAULT '{}'::text[] NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT nutrition_health_profiles_age_group_check CHECK ((age_group = ANY (ARRAY['under_18'::text, '18_40'::text, '41_60'::text, 'over_60'::text]))),
    CONSTRAINT nutrition_health_profiles_female_condition_check CHECK ((female_condition = ANY (ARRAY['normal'::text, 'pregnant'::text, 'menopause'::text]))),
    CONSTRAINT nutrition_health_profiles_gender_check CHECK ((gender = ANY (ARRAY['male'::text, 'female'::text]))),
    CONSTRAINT nutrition_health_profiles_goal_check CHECK ((goal = ANY (ARRAY['maintenance'::text, 'fat_loss'::text, 'recovery'::text])))
);


ALTER TABLE public.nutrition_health_profiles OWNER TO fitcoach;

--
-- Name: nutrition_logs; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.nutrition_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    logged_at timestamp with time zone DEFAULT now() NOT NULL,
    meal_type public.meal_type NOT NULL,
    food_name character varying(100) NOT NULL,
    calories integer,
    protein_g numeric(6,1),
    carbs_g numeric(6,1),
    fat_g numeric(6,1),
    photo_url text,
    CONSTRAINT chk_nutrition_logs_food CHECK ((char_length((food_name)::text) >= 1)),
    CONSTRAINT nutrition_logs_calories_check CHECK ((calories >= 0)),
    CONSTRAINT nutrition_logs_carbs_g_check CHECK ((carbs_g >= (0)::numeric)),
    CONSTRAINT nutrition_logs_fat_g_check CHECK ((fat_g >= (0)::numeric)),
    CONSTRAINT nutrition_logs_protein_g_check CHECK ((protein_g >= (0)::numeric))
);


ALTER TABLE public.nutrition_logs OWNER TO fitcoach;

--
-- Name: payment_plans; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.payment_plans (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    price numeric(12,2) NOT NULL,
    currency character varying(3) DEFAULT 'IDR'::character varying NOT NULL,
    duration_months integer NOT NULL,
    features jsonb DEFAULT '[]'::jsonb NOT NULL,
    max_clients integer,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    tier character varying(20),
    billing_period character varying(20) DEFAULT 'monthly'::character varying,
    original_price numeric(12,2),
    discount_pct integer DEFAULT 0,
    is_popular boolean DEFAULT false NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    is_legacy boolean DEFAULT false NOT NULL,
    CONSTRAINT chk_payment_plans_currency CHECK ((char_length((currency)::text) = 3)),
    CONSTRAINT chk_payment_plans_name CHECK ((char_length((name)::text) >= 1)),
    CONSTRAINT payment_plans_discount_pct_check CHECK (((discount_pct >= 0) AND (discount_pct <= 100))),
    CONSTRAINT payment_plans_duration_months_check CHECK ((duration_months >= 1)),
    CONSTRAINT payment_plans_max_clients_check CHECK ((max_clients > 0)),
    CONSTRAINT payment_plans_price_check CHECK ((price >= (0)::numeric))
);


ALTER TABLE public.payment_plans OWNER TO fitcoach;

--
-- Name: COLUMN payment_plans.features; Type: COMMENT; Schema: public; Owner: fitcoach
--

COMMENT ON COLUMN public.payment_plans.features IS 'JSON array of feature strings, e.g. ["Unlimited workouts", "Nutrition plans", "1-on-1 messaging"]';


--
-- Name: COLUMN payment_plans.tier; Type: COMMENT; Schema: public; Owner: fitcoach
--

COMMENT ON COLUMN public.payment_plans.tier IS 'Subscription tier: basic, pro, elite';


--
-- Name: COLUMN payment_plans.billing_period; Type: COMMENT; Schema: public; Owner: fitcoach
--

COMMENT ON COLUMN public.payment_plans.billing_period IS 'Billing cycle: monthly or annual';


--
-- Name: COLUMN payment_plans.original_price; Type: COMMENT; Schema: public; Owner: fitcoach
--

COMMENT ON COLUMN public.payment_plans.original_price IS 'Original price before discount (used for annual plans to show savings)';


--
-- Name: COLUMN payment_plans.discount_pct; Type: COMMENT; Schema: public; Owner: fitcoach
--

COMMENT ON COLUMN public.payment_plans.discount_pct IS 'Discount percentage for annual plans (e.g. 20 = 20%% off)';


--
-- Name: COLUMN payment_plans.is_popular; Type: COMMENT; Schema: public; Owner: fitcoach
--

COMMENT ON COLUMN public.payment_plans.is_popular IS 'Whether to highlight this plan as recommended/most popular';


--
-- Name: COLUMN payment_plans.is_legacy; Type: COMMENT; Schema: public; Owner: fitcoach
--

COMMENT ON COLUMN public.payment_plans.is_legacy IS 'TRUE = plan lama (pre-SF v2), tidak muncul di subscription page baru.';


--
-- Name: payment_records; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.payment_records (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    subscription_id uuid NOT NULL,
    user_id uuid NOT NULL,
    amount numeric(12,2) NOT NULL,
    currency character varying(3) DEFAULT 'IDR'::character varying NOT NULL,
    status public.payment_status DEFAULT 'pending'::public.payment_status NOT NULL,
    payment_method character varying(50),
    external_id character varying(255),
    paid_at timestamp with time zone,
    failed_at timestamp with time zone,
    refunded_at timestamp with time zone,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    payment_type character varying(30),
    bank_account_id uuid,
    proof_image_url text,
    proof_uploaded_at timestamp with time zone,
    snap_token character varying(255),
    snap_redirect_url text,
    gateway_status character varying(50),
    gateway_response jsonb,
    CONSTRAINT chk_payment_records_currency CHECK ((char_length((currency)::text) = 3)),
    CONSTRAINT payment_records_amount_check CHECK ((amount >= (0)::numeric))
);


ALTER TABLE public.payment_records OWNER TO fitcoach;

--
-- Name: COLUMN payment_records.external_id; Type: COMMENT; Schema: public; Owner: fitcoach
--

COMMENT ON COLUMN public.payment_records.external_id IS 'Payment gateway transaction ID (Midtrans, Stripe, etc.)';


--
-- Name: COLUMN payment_records.payment_type; Type: COMMENT; Schema: public; Owner: fitcoach
--

COMMENT ON COLUMN public.payment_records.payment_type IS 'Payment flow type: manual_transfer | midtrans_snap | midtrans_va | midtrans_qris | midtrans_ewallet';


--
-- Name: COLUMN payment_records.proof_image_url; Type: COMMENT; Schema: public; Owner: fitcoach
--

COMMENT ON COLUMN public.payment_records.proof_image_url IS 'Manual transfer: URL of uploaded transfer receipt image (uploads service).';


--
-- Name: COLUMN payment_records.snap_token; Type: COMMENT; Schema: public; Owner: fitcoach
--

COMMENT ON COLUMN public.payment_records.snap_token IS 'Midtrans Snap: unique token for the transaction (frontend uses this).';


--
-- Name: COLUMN payment_records.snap_redirect_url; Type: COMMENT; Schema: public; Owner: fitcoach
--

COMMENT ON COLUMN public.payment_records.snap_redirect_url IS 'Midtrans Snap: full redirect URL where user completes the payment.';


--
-- Name: COLUMN payment_records.gateway_status; Type: COMMENT; Schema: public; Owner: fitcoach
--

COMMENT ON COLUMN public.payment_records.gateway_status IS 'Midtrans transaction_status: pending | settlement | capture | deny | cancel | expire | refund | chargeback';


--
-- Name: COLUMN payment_records.gateway_response; Type: COMMENT; Schema: public; Owner: fitcoach
--

COMMENT ON COLUMN public.payment_records.gateway_response IS 'Last raw webhook payload from Midtrans (for debugging & audit).';


--
-- Name: payment_status_logs; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.payment_status_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    payment_id uuid NOT NULL,
    user_id uuid NOT NULL,
    old_status public.payment_status,
    new_status public.payment_status NOT NULL,
    changed_by uuid NOT NULL,
    changed_by_name character varying(100),
    reason text,
    subscription_id uuid,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.payment_status_logs OWNER TO fitcoach;

--
-- Name: physical_status_levels; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.physical_status_levels (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    slug character varying(32) NOT NULL,
    label character varying(160) NOT NULL,
    description text,
    routing character varying(32) NOT NULL,
    waitlist_message text,
    sort_order smallint DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.physical_status_levels OWNER TO fitcoach;

--
-- Name: program_categories; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.program_categories (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(200) NOT NULL,
    code character varying(50) NOT NULL,
    description text,
    parameter_template jsonb DEFAULT '{}'::jsonb,
    display_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    is_system boolean DEFAULT false NOT NULL,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.program_categories OWNER TO fitcoach;

--
-- Name: program_days; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.program_days (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    program_id uuid NOT NULL,
    week_number integer NOT NULL,
    day_of_week integer NOT NULL,
    workout_id uuid,
    is_rest_day boolean DEFAULT false NOT NULL,
    CONSTRAINT chk_program_days_rest CHECK ((((is_rest_day = true) AND (workout_id IS NULL)) OR (is_rest_day = false))),
    CONSTRAINT program_days_day_of_week_check CHECK (((day_of_week >= 0) AND (day_of_week <= 6))),
    CONSTRAINT program_days_week_number_check CHECK ((week_number >= 1))
);


ALTER TABLE public.program_days OWNER TO fitcoach;

--
-- Name: programs; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.programs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    duration_weeks integer NOT NULL,
    difficulty public.difficulty_level DEFAULT 'beginner'::public.difficulty_level NOT NULL,
    goal public.program_goal DEFAULT 'general_fitness'::public.program_goal NOT NULL,
    created_by uuid,
    is_template boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_programs_name CHECK ((char_length((name)::text) >= 1)),
    CONSTRAINT programs_duration_weeks_check CHECK (((duration_weeks >= 1) AND (duration_weeks <= 52)))
);


ALTER TABLE public.programs OWNER TO fitcoach;

--
-- Name: progress_logs; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.progress_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    exercise_id uuid NOT NULL,
    workout_id uuid,
    logged_at timestamp with time zone DEFAULT now() NOT NULL,
    sets jsonb NOT NULL,
    notes text,
    mood public.mood_type,
    CONSTRAINT chk_progress_sets_array CHECK (((jsonb_typeof(sets) = 'array'::text) AND (jsonb_array_length(sets) > 0)))
);


ALTER TABLE public.progress_logs OWNER TO fitcoach;

--
-- Name: COLUMN progress_logs.sets; Type: COMMENT; Schema: public; Owner: fitcoach
--

COMMENT ON COLUMN public.progress_logs.sets IS 'Array of set objects: [{set_number, reps, weight_kg, duration_sec, rpe, completed}]';


--
-- Name: promotions; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.promotions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title character varying(200) NOT NULL,
    description text,
    image_url text,
    badge character varying(50),
    route character varying(200),
    status character varying(20) DEFAULT 'active'::character varying NOT NULL,
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    sort_order integer DEFAULT 0 NOT NULL,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.promotions OWNER TO fitcoach;

--
-- Name: session_meals; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.session_meals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid NOT NULL,
    meal_time time without time zone,
    food_description text,
    food_id uuid,
    notes text
);


ALTER TABLE public.session_meals OWNER TO fitcoach;

--
-- Name: session_medicines; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.session_medicines (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid NOT NULL,
    medicine_id uuid NOT NULL,
    notes text
);


ALTER TABLE public.session_medicines OWNER TO fitcoach;

--
-- Name: session_vitals; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.session_vitals (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid NOT NULL,
    measurement_type character varying(20) NOT NULL,
    systolic integer,
    diastolic integer,
    heartrate integer,
    notes text,
    CONSTRAINT chk_session_vitals_type CHECK (((measurement_type)::text = ANY ((ARRAY['pre_workout'::character varying, 'post_workout'::character varying])::text[])))
);


ALTER TABLE public.session_vitals OWNER TO fitcoach;

--
-- Name: specific_conditions; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.specific_conditions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    classification_id uuid NOT NULL,
    slug character varying(80) NOT NULL,
    label character varying(160) NOT NULL,
    description text,
    severity_default character varying(16),
    notes jsonb DEFAULT '{}'::jsonb NOT NULL,
    sort_order smallint DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.specific_conditions OWNER TO fitcoach;

--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.subscriptions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    plan_id uuid NOT NULL,
    status public.subscription_status DEFAULT 'active'::public.subscription_status NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    cancelled_at timestamp with time zone,
    payment_method character varying(50),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_subscriptions_dates CHECK ((expires_at > started_at))
);


ALTER TABLE public.subscriptions OWNER TO fitcoach;

--
-- Name: system_score_weights; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.system_score_weights (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(80) NOT NULL,
    movement_pct smallint NOT NULL,
    nutrition_pct smallint NOT NULL,
    rest_pct smallint NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    notes text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_score_weights_nonneg CHECK (((movement_pct >= 0) AND (nutrition_pct >= 0) AND (rest_pct >= 0))),
    CONSTRAINT chk_score_weights_sum CHECK ((((movement_pct + nutrition_pct) + rest_pct) = 100))
);


ALTER TABLE public.system_score_weights OWNER TO fitcoach;

--
-- Name: tier4_waitlist_entries; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.tier4_waitlist_entries (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    full_name character varying(120) NOT NULL,
    email character varying(255) NOT NULL,
    phone character varying(32),
    city character varying(80),
    source character varying(32) DEFAULT 'tier4'::character varying NOT NULL,
    assessment_id uuid,
    note text,
    status character varying(20) DEFAULT 'new'::character varying NOT NULL,
    admin_note text,
    contacted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_tier4_waitlist_email CHECK (((email)::text ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text)),
    CONSTRAINT tier4_waitlist_entries_source_check CHECK (((source)::text = ANY ((ARRAY['tier4'::character varying, 'level_0_3'::character varying, 'other'::character varying])::text[]))),
    CONSTRAINT tier4_waitlist_entries_status_check CHECK (((status)::text = ANY ((ARRAY['new'::character varying, 'contacted'::character varying, 'converted'::character varying, 'closed'::character varying])::text[])))
);


ALTER TABLE public.tier4_waitlist_entries OWNER TO fitcoach;

--
-- Name: trainer_availability; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.trainer_availability (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    trainer_id uuid NOT NULL,
    day_of_week integer NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT chk_availability_times CHECK ((end_time > start_time)),
    CONSTRAINT trainer_availability_day_of_week_check CHECK (((day_of_week >= 0) AND (day_of_week <= 6)))
);


ALTER TABLE public.trainer_availability OWNER TO fitcoach;

--
-- Name: trainer_card_sequences; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.trainer_card_sequences (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    trainer_card_id uuid NOT NULL,
    program_category_id uuid NOT NULL,
    duration character varying(20),
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.trainer_card_sequences OWNER TO fitcoach;

--
-- Name: trainer_card_set_items; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.trainer_card_set_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    set_id uuid NOT NULL,
    movement_id uuid,
    movement_name character varying(150),
    body_part character varying(10) NOT NULL,
    equipment character varying(200),
    reps integer,
    sets_count integer DEFAULT 1,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    breathing_core character varying(100),
    breathing_diaphragm character varying(100),
    allowed_tiers text[] DEFAULT '{}'::text[] NOT NULL,
    CONSTRAINT chk_trainer_card_set_items_body_part CHECK (((body_part)::text = ANY ((ARRAY['upper'::character varying, 'lower'::character varying, 'core'::character varying])::text[])))
);


ALTER TABLE public.trainer_card_set_items OWNER TO fitcoach;

--
-- Name: trainer_card_sets; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.trainer_card_sets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sequence_id uuid NOT NULL,
    set_number integer NOT NULL,
    duration character varying(20),
    equipment_upper character varying(200),
    equipment_lower character varying(200),
    type_id uuid,
    bpm character varying(30),
    extra_load character varying(100),
    notes text,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    pattern character varying(150),
    breathing_core character varying(100),
    breathing_diaphragm character varying(100)
);


ALTER TABLE public.trainer_card_sets OWNER TO fitcoach;

--
-- Name: trainer_card_template_sequences; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.trainer_card_template_sequences (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    template_id uuid NOT NULL,
    program_category_id uuid NOT NULL,
    duration character varying(20),
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.trainer_card_template_sequences OWNER TO fitcoach;

--
-- Name: trainer_card_template_set_items; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.trainer_card_template_set_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    set_id uuid NOT NULL,
    movement_id uuid,
    movement_name character varying(150),
    body_part character varying(10) NOT NULL,
    equipment character varying(200),
    reps integer,
    sets_count integer DEFAULT 1,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    breathing_core character varying(100),
    breathing_diaphragm character varying(100),
    allowed_tiers text[] DEFAULT '{}'::text[] NOT NULL,
    CONSTRAINT chk_trainer_card_template_set_items_body_part CHECK (((body_part)::text = ANY ((ARRAY['upper'::character varying, 'lower'::character varying, 'core'::character varying])::text[])))
);


ALTER TABLE public.trainer_card_template_set_items OWNER TO fitcoach;

--
-- Name: trainer_card_template_sets; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.trainer_card_template_sets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    sequence_id uuid NOT NULL,
    set_number integer NOT NULL,
    duration character varying(20),
    equipment_upper character varying(200),
    equipment_lower character varying(200),
    type_id uuid,
    bpm character varying(30),
    extra_load character varying(100),
    notes text,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    pattern character varying(150),
    breathing_core character varying(100),
    breathing_diaphragm character varying(100)
);


ALTER TABLE public.trainer_card_template_sets OWNER TO fitcoach;

--
-- Name: trainer_card_templates; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.trainer_card_templates (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    level character varying(10) NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.trainer_card_templates OWNER TO fitcoach;

--
-- Name: trainer_card_types; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.trainer_card_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(50) NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.trainer_card_types OWNER TO fitcoach;

--
-- Name: trainer_cards; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.trainer_cards (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    customer_id uuid NOT NULL,
    level character varying(10) NOT NULL,
    notes text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.trainer_cards OWNER TO fitcoach;

--
-- Name: trainer_clients; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.trainer_clients (
    trainer_id uuid NOT NULL,
    client_id uuid NOT NULL,
    assigned_at timestamp with time zone DEFAULT now() NOT NULL,
    status public.assignment_status DEFAULT 'active'::public.assignment_status NOT NULL,
    role_type character varying(20) DEFAULT 'trainer'::character varying NOT NULL,
    CONSTRAINT chk_trainer_clients_not_self CHECK ((trainer_id <> client_id)),
    CONSTRAINT chk_trainer_clients_role_type CHECK (((role_type)::text = ANY ((ARRAY['trainer'::character varying, 'consultant'::character varying])::text[])))
);


ALTER TABLE public.trainer_clients OWNER TO fitcoach;

--
-- Name: training_schedules; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.training_schedules (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    client_id uuid NOT NULL,
    trainer_id uuid NOT NULL,
    day_of_week integer NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    location character varying(200),
    notes text,
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_schedule_time CHECK ((end_time > start_time)),
    CONSTRAINT training_schedules_day_of_week_check CHECK (((day_of_week >= 0) AND (day_of_week <= 6)))
);


ALTER TABLE public.training_schedules OWNER TO fitcoach;

--
-- Name: training_sessions; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.training_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    schedule_id uuid,
    client_id uuid NOT NULL,
    trainer_id uuid NOT NULL,
    session_date date NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    status public.training_session_status DEFAULT 'scheduled'::public.training_session_status NOT NULL,
    location character varying(200),
    notes text,
    is_substitute boolean DEFAULT false NOT NULL,
    original_trainer_id uuid,
    substitute_reason text,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    substituted_by uuid,
    substituted_at timestamp with time zone,
    CONSTRAINT chk_session_time CHECK ((end_time > start_time))
);


ALTER TABLE public.training_sessions OWNER TO fitcoach;

--
-- Name: uploads; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.uploads (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    original_name text NOT NULL,
    stored_name text NOT NULL,
    mime_type text NOT NULL,
    size_bytes bigint NOT NULL,
    width integer,
    height integer,
    path text NOT NULL,
    url text NOT NULL,
    uploaded_by uuid NOT NULL,
    entity_type text,
    entity_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.uploads OWNER TO fitcoach;

--
-- Name: user_profiles; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.user_profiles (
    user_id uuid NOT NULL,
    date_of_birth date,
    gender public.gender_type,
    height_cm numeric(5,1),
    weight_kg numeric(5,1),
    fitness_goal public.fitness_goal,
    experience_level public.experience_level,
    medical_notes text,
    emergency_contact character varying(100),
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT user_profiles_height_cm_check CHECK (((height_cm > (0)::numeric) AND (height_cm < (300)::numeric))),
    CONSTRAINT user_profiles_weight_kg_check CHECK (((weight_kg > (0)::numeric) AND (weight_kg < (500)::numeric)))
);


ALTER TABLE public.user_profiles OWNER TO fitcoach;

--
-- Name: user_programs; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.user_programs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    program_id uuid NOT NULL,
    assigned_by uuid,
    start_date date NOT NULL,
    end_date date,
    status public.assignment_status DEFAULT 'active'::public.assignment_status NOT NULL,
    current_week integer DEFAULT 1 NOT NULL,
    current_day integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_user_programs_dates CHECK (((end_date IS NULL) OR (end_date >= start_date))),
    CONSTRAINT user_programs_current_day_check CHECK (((current_day >= 0) AND (current_day <= 6))),
    CONSTRAINT user_programs_current_week_check CHECK ((current_week >= 1))
);


ALTER TABLE public.user_programs OWNER TO fitcoach;

--
-- Name: users; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    full_name character varying(100) NOT NULL,
    phone character varying(20),
    avatar_url text,
    role public.user_role DEFAULT 'client'::public.user_role NOT NULL,
    status public.user_status DEFAULT 'pending'::public.user_status NOT NULL,
    timezone character varying(50) DEFAULT 'Asia/Jakarta'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT chk_users_email CHECK (((email)::text ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'::text))
);


ALTER TABLE public.users OWNER TO fitcoach;

--
-- Name: workout_exercises; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.workout_exercises (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workout_id uuid NOT NULL,
    exercise_id uuid NOT NULL,
    order_index integer NOT NULL,
    sets integer,
    reps character varying(20),
    weight_kg numeric(5,1),
    rest_seconds integer,
    notes text,
    superset_group integer,
    CONSTRAINT workout_exercises_rest_seconds_check CHECK ((rest_seconds >= 0)),
    CONSTRAINT workout_exercises_sets_check CHECK ((sets > 0)),
    CONSTRAINT workout_exercises_weight_kg_check CHECK ((weight_kg >= (0)::numeric))
);


ALTER TABLE public.workout_exercises OWNER TO fitcoach;

--
-- Name: workout_reminders; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.workout_reminders (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    days_of_week character varying(32) DEFAULT ''::character varying NOT NULL,
    remind_at character varying(5) DEFAULT '07:00'::character varying NOT NULL,
    timezone character varying(64) DEFAULT 'Asia/Jakarta'::character varying NOT NULL,
    last_sent_on date,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.workout_reminders OWNER TO fitcoach;

--
-- Name: workout_session_logs; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.workout_session_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    trainer_card_id uuid,
    session_type character varying(10) DEFAULT 'full'::character varying NOT NULL,
    level character varying(10) DEFAULT ''::character varying NOT NULL,
    duration_seconds integer DEFAULT 0 NOT NULL,
    completed_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT workout_session_logs_duration_seconds_check CHECK ((duration_seconds >= 0)),
    CONSTRAINT workout_session_logs_session_type_check CHECK (((session_type)::text = ANY ((ARRAY['full'::character varying, 'daily'::character varying])::text[])))
);


ALTER TABLE public.workout_session_logs OWNER TO fitcoach;

--
-- Name: workouts; Type: TABLE; Schema: public; Owner: fitcoach
--

CREATE TABLE public.workouts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    type public.workout_type DEFAULT 'custom'::public.workout_type NOT NULL,
    estimated_duration_min integer,
    created_by uuid,
    is_template boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT chk_workouts_name CHECK ((char_length((name)::text) >= 1)),
    CONSTRAINT workouts_estimated_duration_min_check CHECK ((estimated_duration_min > 0))
);


ALTER TABLE public.workouts OWNER TO fitcoach;

--
-- Data for Name: announcement_reads; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.announcement_reads (id, announcement_id, user_id, read_at) FROM stdin;
\.


--
-- Data for Name: announcements; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.announcements (id, title, body, image_url, status, target_roles, published_at, created_by, created_at, updated_at) FROM stdin;
f7ffbd26-87ce-4da9-94ba-c99a09e1868e	New Feature: Habit Tracking	We have added habit tracking to help you build consistent daily routines. Check out the Habits section in your dashboard to get started.	\N	published	{client,trainer}	2026-06-23 23:13:37.417422+07	f8f2faed-9a96-4fdc-8ac6-f6ae466b0a93	2026-06-26 23:13:37.417422+07	2026-06-26 23:13:37.417422+07
77a49076-7233-40e6-9077-e7979fb2419d	System Maintenance Notice	Scheduled maintenance will occur this weekend between 2-4 AM. Services may be briefly unavailable.	\N	draft	{client,trainer,admin,finance}	\N	f8f2faed-9a96-4fdc-8ac6-f6ae466b0a93	2026-06-26 23:13:37.417422+07	2026-06-26 23:13:37.417422+07
e0f1cb25-5a2c-4f85-8d58-f681f4533cde	Trainer Workshop: Advanced Programming	All trainers are invited to the advanced programming workshop next Monday at 2 PM. Topics include periodization and progressive overload strategies.	\N	published	{trainer}	2026-06-26 23:13:37.417422+07	f8f2faed-9a96-4fdc-8ac6-f6ae466b0a93	2026-06-26 23:13:37.417422+07	2026-06-26 23:13:37.417422+07
c1eacb24-fc1e-4878-ab01-dbd4de0e0bb9	Holiday Schedule Update	Please note that gym hours will be reduced during the upcoming holiday period. Check the calendar for updated class schedules.	\N	published	{client,trainer,admin}	2026-06-25 23:13:37.417422+07	f8f2faed-9a96-4fdc-8ac6-f6ae466b0a93	2026-06-26 23:13:37.417422+07	2026-06-26 23:13:37.417422+07
4b288a6b-9fee-44e1-a0ab-ad733cf6b3eb	Welcome to Systemic Fitness!	We are excited to launch our new fitness platform. Explore workouts, programs, and track your progress all in one place. Let's get started on your fitness journey!	\N	published	{client,trainer}	2026-06-19 23:13:37.417422+07	f8f2faed-9a96-4fdc-8ac6-f6ae466b0a93	2026-06-26 23:13:37.417422+07	2026-06-26 23:13:37.417422+07
\.


--
-- Data for Name: assessments; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.assessments (id, user_id, tier, status, sleep_input, movement_input, metabolic_input, sleep_score, recovery_score, movement_score, metabolic_score, system_score, sleep_class, movement_class, metabolic_class, flags, insight, recommendations, reviewed_by, reviewed_at, reviewer_notes, created_at, updated_at, version, phase_a_payload, phase_b_payload, phase_c_payload, rest_score, nutrition_score, movement_score_v2, system_score_v2, chronobiology_window, classification_id, specific_condition_id, physical_status_level, program_type, program_map_payload) FROM stdin;
\.


--
-- Data for Name: automation_logs; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.automation_logs (id, automation_id, user_id, triggered_at, status, result, error_message) FROM stdin;
\.


--
-- Data for Name: automations; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.automations (id, name, description, trigger_type, trigger_config, action_type, action_config, is_active, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: bank_accounts; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.bank_accounts (id, bank_name, account_number, account_holder, branch, notes, is_active, sort_order, created_at, updated_at) FROM stdin;
cbc93c6b-4d53-4788-9d37-9434927c01b1	BCA	0000000000	PT FitCoach Indonesia	KCP Jakarta Pusat	\N	t	1	2026-06-26 22:34:21.065465+07	2026-06-26 22:34:21.065465+07
\.


--
-- Data for Name: body_metrics; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.body_metrics (id, user_id, logged_at, weight_kg, body_fat_pct, muscle_mass_kg, photo_urls, notes) FROM stdin;
\.


--
-- Data for Name: broadcast_notifications; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.broadcast_notifications (id, title, body, type, data, target_roles, image_url, scheduled_at, sent_at, sent_count, created_by, created_at) FROM stdin;
\.


--
-- Data for Name: calendar_events; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.calendar_events (id, event_type_id, title, description, category, status, start_at, end_at, location, max_participants, created_by, created_at, updated_at) FROM stdin;
5c1d2f8c-6927-4ff4-ba1d-3eda0acc5252	09eb1471-ae88-4ed3-b50e-1159c8f972d3	Afternoon PT - Client B	Personal training session	one_on_one	scheduled	2026-06-28 14:00:00+07	2026-06-28 15:00:00+07	Studio B	\N	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	2026-06-26 22:34:26.263696+07	2026-06-26 22:34:26.263696+07
4bd694af-f217-4926-ab4d-25f489284fe5	1cd0e3a5-70ac-4756-a038-a03f8dd57d82	Online Consultation	Video call with remote client	one_on_one	scheduled	2026-06-29 10:00:00+07	2026-06-29 10:30:00+07	Zoom	\N	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	2026-06-26 22:34:26.263696+07	2026-06-26 22:34:26.263696+07
b47c6316-9dcd-4a7e-9190-81f6be985b16	09eb1471-ae88-4ed3-b50e-1159c8f972d3	Morning PT - Client A	Personal training session	one_on_one	scheduled	2026-06-27 07:00:00+07	2026-06-27 08:00:00+07	Studio A	\N	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	2026-06-26 22:34:26.263696+07	2026-06-26 22:34:26.263696+07
5be075ee-0aea-4ab7-aae0-188d1ea2c008	c047b303-71c1-471e-a83b-fa1251961f0f	Yoga & Stretch	Evening yoga session	group_class	scheduled	2026-06-28 17:00:00+07	2026-06-28 18:00:00+07	Yoga Room	15	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	2026-06-26 22:34:26.263696+07	2026-06-26 22:34:26.263696+07
3d5adc57-441a-4c97-a561-4bc3f37917d9	07891dd2-39b7-4e75-af78-c08f75d154ec	Group Fitness Class	Full body workout class	group_class	scheduled	2026-06-30 08:00:00+07	2026-06-30 08:45:00+07	Main Floor	12	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	2026-06-26 22:34:26.263696+07	2026-06-26 22:34:26.263696+07
7832423a-1391-4d2a-83d4-16eea0a35098	472128b0-8411-46d0-862f-5571b9969048	HIIT Boot Camp	High intensity group class	group_class	scheduled	2026-06-27 09:00:00+07	2026-06-27 09:45:00+07	Main Floor	12	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	2026-06-26 22:34:26.263696+07	2026-06-26 22:34:26.263696+07
\.


--
-- Data for Name: challenge_participants; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.challenge_participants (id, challenge_id, user_id, progress_value, joined_at, completed_at) FROM stdin;
\.


--
-- Data for Name: challenges; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.challenges (id, name, description, image_url, status, start_date, end_date, goal_type, goal_value, max_participants, created_by, created_at, updated_at) FROM stdin;
f1812fbb-a632-49dc-8c75-bd2a580d712b	Body Transformation 90 Days	Complete 90-day body transformation program. Track your progress weekly!	\N	active	2026-06-26	2026-09-24	body_fat_pct	5.00	30	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	2026-06-26 22:34:26.287905+07	2026-06-26 22:34:26.287905+07
b3d4d6aa-a41e-4494-b85b-8d408d98d02f	10K Steps Daily	Walk at least 10,000 steps every day for 21 days straight.	\N	active	2026-06-26	2026-07-17	daily_steps	10000.00	100	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	2026-06-26 22:34:26.287905+07	2026-06-26 22:34:26.287905+07
6f6f8349-d5ef-4d0a-b31e-0eef85ad8381	Hydration Challenge	Drink at least 3 liters of water every day for 14 days.	\N	draft	2026-07-03	2026-07-17	daily_water_ml	3000.00	\N	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	2026-06-26 22:34:26.287905+07	2026-06-26 22:34:26.287905+07
0dbdd785-d395-4382-a627-e8e7e55d9de5	30 Day Push-Up Challenge	Complete 3000 push-ups in 30 days. Start with 50 per day and increase gradually!	\N	active	2026-06-26	2026-07-26	total_reps	3000.00	50	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	2026-06-26 22:34:26.287905+07	2026-06-26 22:34:26.287905+07
\.


--
-- Data for Name: clinical_notes; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.clinical_notes (id, assessment_id, client_id, consultant_id, title, content, attachments, is_visible_to_client, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: cms_content; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.cms_content (section_key, locale, draft_data, published_data, published_at, updated_at, updated_by) FROM stdin;
meta	id	{"title": "Systemic Fitness â€” Human System Optimization", "description": "Prescripsi gerakan berbasis kondisi medis â€” dikalibrasi terhadap 4 variabel spesifik untuk tubuhmu."}	{"title": "Systemic Fitness â€” Human System Optimization", "description": "Prescripsi gerakan berbasis kondisi medis â€” dikalibrasi terhadap 4 variabel spesifik untuk tubuhmu."}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.619461+07	\N
meta	en	{"title": "Systemic Fitness â€” Human System Optimization", "description": "A condition-based movement prescription â€” calibrated against 4 specific variables for your body."}	{"title": "Systemic Fitness â€” Human System Optimization", "description": "A condition-based movement prescription â€” calibrated against 4 specific variables for your body."}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.619461+07	\N
nav	id	{"cta": "Mulai Assessment", "method": "Metode", "partner": "Kemitraan", "pricing": "Harga", "programs": "Program"}	{"cta": "Mulai Assessment", "method": "Metode", "partner": "Kemitraan", "pricing": "Harga", "programs": "Program"}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.623826+07	\N
nav	en	{"cta": "Start Assessment", "method": "Method", "partner": "Partnership", "pricing": "Pricing", "programs": "Programs"}	{"cta": "Start Assessment", "method": "Method", "partner": "Partnership", "pricing": "Pricing", "programs": "Programs"}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.623826+07	\N
hero	id	{"sub": "Bukan program olahraga generik. Systemic Fitness adalah prescripsi gerakan berbasis kondisi medis â€” dikalibrasi terhadap 4 variabel spesifik, disampaikan melalui sistem yang bekerja untuk tubuhmu secara personal.", "badge": "HUMAN SYSTEM OPTIMIZATION PLATFORM", "metrics": {"m1Num": "4", "m2Num": "3", "m3Num": "23+", "m1Label": "Variabel fisiologis\\nper sesi", "m2Label": "Program berbeda\\nsatu assessment", "m3Label": "Kondisi kesehatan\\nyang ditangani"}, "headline1": "Tubuhmu adalah sistem.", "headline2": "Kami", "ctaPrimary": "Mulai Assessment Gratis â†’", "headlineEm": "mengoptimalkannya.", "ctaSecondary": "Pelajari Metodenya"}	{"sub": "Bukan program olahraga generik. Systemic Fitness adalah prescripsi gerakan berbasis kondisi medis â€” dikalibrasi terhadap 4 variabel spesifik, disampaikan melalui sistem yang bekerja untuk tubuhmu secara personal.", "badge": "HUMAN SYSTEM OPTIMIZATION PLATFORM", "metrics": {"m1Num": "4", "m2Num": "3", "m3Num": "23+", "m1Label": "Variabel fisiologis\\nper sesi", "m2Label": "Program berbeda\\nsatu assessment", "m3Label": "Kondisi kesehatan\\nyang ditangani"}, "headline1": "Tubuhmu adalah sistem.", "headline2": "Kami", "ctaPrimary": "Mulai Assessment Gratis â†’", "headlineEm": "mengoptimalkannya.", "ctaSecondary": "Pelajari Metodenya"}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.624518+07	\N
hero	en	{"sub": "Not a generic workout program. Systemic Fitness is a movement prescription based on medical conditions â€” calibrated against 4 specific variables, delivered through a system built for your body, personally.", "badge": "HUMAN SYSTEM OPTIMIZATION PLATFORM", "metrics": {"m1Num": "4", "m2Num": "3", "m3Num": "23+", "m1Label": "Physiological variables\\nper session", "m2Label": "Distinct programs\\none assessment", "m3Label": "Health conditions\\naddressed"}, "headline1": "Your body is a system.", "headline2": "We", "ctaPrimary": "Start Free Assessment â†’", "headlineEm": "optimize it.", "ctaSecondary": "Learn the Method"}	{"sub": "Not a generic workout program. Systemic Fitness is a movement prescription based on medical conditions â€” calibrated against 4 specific variables, delivered through a system built for your body, personally.", "badge": "HUMAN SYSTEM OPTIMIZATION PLATFORM", "metrics": {"m1Num": "4", "m2Num": "3", "m3Num": "23+", "m1Label": "Physiological variables\\nper session", "m2Label": "Distinct programs\\none assessment", "m3Label": "Health conditions\\naddressed"}, "headline1": "Your body is a system.", "headline2": "We", "ctaPrimary": "Start Free Assessment â†’", "headlineEm": "optimize it.", "ctaSecondary": "Learn the Method"}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.624518+07	\N
signals	id	{"sub": "Jika salah satu dari ini terdengar familiar, kamu sudah di tempat yang tepat.", "tag": "SIAPA YANG DATANG KE SINI", "cards": {"c1Desc": "Angka laboratorium mulai bergerak ke arah yang tidak diinginkan. Masih bisa diintervensi â€” dengan cara yang tepat.", "c2Desc": "Kondisi aktif yang butuh program gerakan yang diprescribe secara presisi, bukan gerakan generik yang bisa memperburuk.", "c3Desc": "Sistem hormonal yang terganggu merespons sangat spesifik terhadap jenis, waktu, dan intensitas gerakan yang tepat.", "c4Desc": "Masih aktif, tidak ada kondisi medis â€” tapi tahu ada potensi yang belum sepenuhnya dimanfaatkan dari sistem tubuh.", "c1Title": "Tensi, kolesterol, atau gula darah mulai tidak optimal", "c2Title": "Ada keluhan yang mengganggu â€” sendi, asam urat, imun, atau kondisi kronis", "c3Title": "Hormonal tidak seimbang â€” PCOS, tiroid, atau perimenopause", "c4Title": "Ingin optimalkan performa â€” stamina, kekuatan, dan vitalitas yang lebih konsisten"}, "headline1": "Sinyal yang sering", "headline2": "diabaikan â€” tapi nyata."}	{"sub": "Jika salah satu dari ini terdengar familiar, kamu sudah di tempat yang tepat.", "tag": "SIAPA YANG DATANG KE SINI", "cards": {"c1Desc": "Angka laboratorium mulai bergerak ke arah yang tidak diinginkan. Masih bisa diintervensi â€” dengan cara yang tepat.", "c2Desc": "Kondisi aktif yang butuh program gerakan yang diprescribe secara presisi, bukan gerakan generik yang bisa memperburuk.", "c3Desc": "Sistem hormonal yang terganggu merespons sangat spesifik terhadap jenis, waktu, dan intensitas gerakan yang tepat.", "c4Desc": "Masih aktif, tidak ada kondisi medis â€” tapi tahu ada potensi yang belum sepenuhnya dimanfaatkan dari sistem tubuh.", "c1Title": "Tensi, kolesterol, atau gula darah mulai tidak optimal", "c2Title": "Ada keluhan yang mengganggu â€” sendi, asam urat, imun, atau kondisi kronis", "c3Title": "Hormonal tidak seimbang â€” PCOS, tiroid, atau perimenopause", "c4Title": "Ingin optimalkan performa â€” stamina, kekuatan, dan vitalitas yang lebih konsisten"}, "headline1": "Sinyal yang sering", "headline2": "diabaikan â€” tapi nyata."}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.625182+07	\N
signals	en	{"sub": "If any of these sound familiar, you're already in the right place.", "tag": "WHO COMES HERE", "cards": {"c1Desc": "Lab numbers moving in the wrong direction. Still reversible â€” with the right intervention.", "c2Desc": "An active condition that needs precisely prescribed movement, not generic exercises that can make it worse.", "c3Desc": "A disrupted hormonal system responds very specifically to the right type, timing, and intensity of movement.", "c4Desc": "Still active, no medical condition â€” but aware there's untapped potential in how your body's system performs.", "c1Title": "Blood pressure, cholesterol, or blood sugar drifting out of range", "c2Title": "A nagging issue â€” joints, uric acid, immunity, or a chronic condition", "c3Title": "Hormonal imbalance â€” PCOS, thyroid, or perimenopause", "c4Title": "Want to optimize performance â€” more consistent stamina, strength, and vitality"}, "headline1": "Signals that are often", "headline2": "overlooked â€” but real."}	{"sub": "If any of these sound familiar, you're already in the right place.", "tag": "WHO COMES HERE", "cards": {"c1Desc": "Lab numbers moving in the wrong direction. Still reversible â€” with the right intervention.", "c2Desc": "An active condition that needs precisely prescribed movement, not generic exercises that can make it worse.", "c3Desc": "A disrupted hormonal system responds very specifically to the right type, timing, and intensity of movement.", "c4Desc": "Still active, no medical condition â€” but aware there's untapped potential in how your body's system performs.", "c1Title": "Blood pressure, cholesterol, or blood sugar drifting out of range", "c2Title": "A nagging issue â€” joints, uric acid, immunity, or a chronic condition", "c3Title": "Hormonal imbalance â€” PCOS, thyroid, or perimenopause", "c4Title": "Want to optimize performance â€” more consistent stamina, strength, and vitality"}, "headline1": "Signals that are often", "headline2": "overlooked â€” but real."}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.625182+07	\N
method	id	{"sub": "Setiap sesi dikontrol oleh 4 variabel yang, ketika dikalibrasi terhadap kondisi spesifik, menghasilkan respons fisiologis yang ditargetkan â€” bukan sekadar peningkatan kebugaran umum.", "tag": "METODE SYSTEMIC FITNESS", "quote": "\\"We don't train bodies. We optimize systems.\\"", "pillars": {"cc": "Cardiorespiratory\\nConditioning", "fc": "Functional\\nConditioning", "mc": "Metabolic\\nConditioning"}, "headline1": "Bukan olahraga.", "headline2": "Prescripsi fisiologis.", "variables": {"v1Desc": "Beban mekanis yang tepat mengaktifkan mekanotransduksi selular dan sintesis protein otot", "v1Name": "Load", "v2Desc": "Pola gerakan yang dipilih menentukan sistem fisiologis mana yang diaktifkan dalam sesi", "v2Name": "Movement Pattern", "v3Desc": "Ritme jantung yang dikendalikan menentukan respons otonom, termogenesis, dan adaptasi kardiak", "v3Name": "Tempo / BPM", "v4Desc": "Pola napas mengatur tonus vagal, kadar kortisol, dan optimasi pengiriman oksigen selular", "v4Name": "Breathing Pattern"}, "quoteAuthor": "â€” Citra Hann, Founder & Human System Optimization Advisor"}	{"sub": "Setiap sesi dikontrol oleh 4 variabel yang, ketika dikalibrasi terhadap kondisi spesifik, menghasilkan respons fisiologis yang ditargetkan â€” bukan sekadar peningkatan kebugaran umum.", "tag": "METODE SYSTEMIC FITNESS", "quote": "\\"We don't train bodies. We optimize systems.\\"", "pillars": {"cc": "Cardiorespiratory\\nConditioning", "fc": "Functional\\nConditioning", "mc": "Metabolic\\nConditioning"}, "headline1": "Bukan olahraga.", "headline2": "Prescripsi fisiologis.", "variables": {"v1Desc": "Beban mekanis yang tepat mengaktifkan mekanotransduksi selular dan sintesis protein otot", "v1Name": "Load", "v2Desc": "Pola gerakan yang dipilih menentukan sistem fisiologis mana yang diaktifkan dalam sesi", "v2Name": "Movement Pattern", "v3Desc": "Ritme jantung yang dikendalikan menentukan respons otonom, termogenesis, dan adaptasi kardiak", "v3Name": "Tempo / BPM", "v4Desc": "Pola napas mengatur tonus vagal, kadar kortisol, dan optimasi pengiriman oksigen selular", "v4Name": "Breathing Pattern"}, "quoteAuthor": "â€” Citra Hann, Founder & Human System Optimization Advisor"}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.62593+07	\N
method	en	{"sub": "Every session is governed by 4 variables that, when calibrated to a specific condition, produce a targeted physiological response â€” not just general fitness.", "tag": "THE SYSTEMIC FITNESS METHOD", "quote": "\\"We don't train bodies. We optimize systems.\\"", "pillars": {"cc": "Cardiorespiratory\\nConditioning", "fc": "Functional\\nConditioning", "mc": "Metabolic\\nConditioning"}, "headline1": "Not exercise.", "headline2": "A physiological prescription.", "variables": {"v1Desc": "The right mechanical load activates cellular mechanotransduction and muscle protein synthesis", "v1Name": "Load", "v2Desc": "The chosen movement pattern determines which physiological system is activated in the session", "v2Name": "Movement Pattern", "v3Desc": "A controlled cardiac rhythm governs autonomic response, thermogenesis, and cardiac adaptation", "v3Name": "Tempo / BPM", "v4Desc": "Breathing patterns regulate vagal tone, cortisol levels, and cellular oxygen delivery", "v4Name": "Breathing Pattern"}, "quoteAuthor": "â€” Citra Hann, Founder & Human System Optimization Advisor"}	{"sub": "Every session is governed by 4 variables that, when calibrated to a specific condition, produce a targeted physiological response â€” not just general fitness.", "tag": "THE SYSTEMIC FITNESS METHOD", "quote": "\\"We don't train bodies. We optimize systems.\\"", "pillars": {"cc": "Cardiorespiratory\\nConditioning", "fc": "Functional\\nConditioning", "mc": "Metabolic\\nConditioning"}, "headline1": "Not exercise.", "headline2": "A physiological prescription.", "variables": {"v1Desc": "The right mechanical load activates cellular mechanotransduction and muscle protein synthesis", "v1Name": "Load", "v2Desc": "The chosen movement pattern determines which physiological system is activated in the session", "v2Name": "Movement Pattern", "v3Desc": "A controlled cardiac rhythm governs autonomic response, thermogenesis, and cardiac adaptation", "v3Name": "Tempo / BPM", "v4Desc": "Breathing patterns regulate vagal tone, cortisol levels, and cellular oxygen delivery", "v4Name": "Breathing Pattern"}, "quoteAuthor": "â€” Citra Hann, Founder & Human System Optimization Advisor"}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.62593+07	\N
programs	id	{"sub": "Assessment menentukan program mana yang tepat untukmu. Tidak ada overlap, tidak ada tebakan.", "tag": "TIGA PROGRAM â€” SATU ASSESSMENT", "headline1": "Program yang lahir", "headline2": "dari kondisimu."}	{"sub": "Assessment menentukan program mana yang tepat untukmu. Tidak ada overlap, tidak ada tebakan.", "tag": "TIGA PROGRAM â€” SATU ASSESSMENT", "headline1": "Program yang lahir", "headline2": "dari kondisimu."}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.626472+07	\N
programs	en	{"sub": "The assessment determines which program is right for you. No overlap, no guesswork.", "tag": "THREE PROGRAMS â€” ONE ASSESSMENT", "headline1": "Programs born", "headline2": "from your condition."}	{"sub": "The assessment determines which program is right for you. No overlap, no guesswork.", "tag": "THREE PROGRAMS â€” ONE ASSESSMENT", "headline1": "Programs born", "headline2": "from your condition."}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.626472+07	\N
finalCta	en	{"cta": "Start Free Assessment â†’", "sub": "A 25-question assessment. No credit card required. No commitment. Just honest data about the current state of your body's system.", "tag": "START HERE", "note": "Available on app and web Â· Free forever for System Check", "download": "Download the app", "headline1": "Discover your body", "headline2": "system's condition â€”", "headlineEm": "free."}	{"cta": "Start Free Assessment â†’", "sub": "A 25-question assessment. No credit card required. No commitment. Just honest data about the current state of your body's system.", "tag": "START HERE", "note": "Available on app and web Â· Free forever for System Check", "download": "Download the app", "headline1": "Discover your body", "headline2": "system's condition â€”", "headlineEm": "free."}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.631735+07	\N
footer	id	{"copy": "Â© 2026 Systemic Fitness Pte. Ltd.", "tagline": "Human System Optimization"}	{"copy": "Â© 2026 Systemic Fitness Pte. Ltd.", "tagline": "Human System Optimization"}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.632202+07	\N
footer	en	{"copy": "Â© 2026 Systemic Fitness Pte. Ltd.", "tagline": "Human System Optimization"}	{"copy": "Â© 2026 Systemic Fitness Pte. Ltd.", "tagline": "Human System Optimization"}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.632202+07	\N
score	id	{"cta": "Lihat System Score-mu â†’", "sub": "Bukan motivasi. Bukan estimasi. System Score adalah angka nyata yang lahir dari keseimbangan tiga domain fisiologis yang paling menentukan kualitas hidupmu.", "tag": "SYSTEM SCORE", "word": "OPTIMAL", "barMove": "Gerak", "barRest": "Istirahat", "headline1": "Tubuhmu punya skor.", "headline2": "Dari 3 dimensi nyata.", "domainRest": "Istirahat", "formulaTop": "Olahraga 35% + Nutrisi 35% + Istirahat 30% = System Score", "barNutrition": "Nutrisi", "domainUpdate": "Update", "formulaBottom": "Diukur dari assessment awal dan diperbarui setiap sesi selesai.", "domainExercise": "Olahraga", "domainRestDesc": "30% bobot skor", "domainNutrition": "Nutrisi", "domainUpdateDesc": "Setiap sesi selesai", "domainExerciseDesc": "35% bobot skor", "domainNutritionDesc": "35% bobot skor"}	{"cta": "Lihat System Score-mu â†’", "sub": "Bukan motivasi. Bukan estimasi. System Score adalah angka nyata yang lahir dari keseimbangan tiga domain fisiologis yang paling menentukan kualitas hidupmu.", "tag": "SYSTEM SCORE", "word": "OPTIMAL", "barMove": "Gerak", "barRest": "Istirahat", "headline1": "Tubuhmu punya skor.", "headline2": "Dari 3 dimensi nyata.", "domainRest": "Istirahat", "formulaTop": "Olahraga 35% + Nutrisi 35% + Istirahat 30% = System Score", "barNutrition": "Nutrisi", "domainUpdate": "Update", "formulaBottom": "Diukur dari assessment awal dan diperbarui setiap sesi selesai.", "domainExercise": "Olahraga", "domainRestDesc": "30% bobot skor", "domainNutrition": "Nutrisi", "domainUpdateDesc": "Setiap sesi selesai", "domainExerciseDesc": "35% bobot skor", "domainNutritionDesc": "35% bobot skor"}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.627589+07	\N
score	en	{"cta": "See Your System Score â†’", "sub": "Not motivation. Not estimation. The System Score is a real number that emerges from the balance of the three physiological domains that most shape your quality of life.", "tag": "SYSTEM SCORE", "word": "OPTIMAL", "barMove": "Move", "barRest": "Rest", "headline1": "Your body has a score.", "headline2": "From 3 real dimensions.", "domainRest": "Rest", "formulaTop": "Exercise 35% + Nutrition 35% + Rest 30% = System Score", "barNutrition": "Nutrition", "domainUpdate": "Update", "formulaBottom": "Measured at the initial assessment and updated after every completed session.", "domainExercise": "Exercise", "domainRestDesc": "30% score weight", "domainNutrition": "Nutrition", "domainUpdateDesc": "After every session", "domainExerciseDesc": "35% score weight", "domainNutritionDesc": "35% score weight"}	{"cta": "See Your System Score â†’", "sub": "Not motivation. Not estimation. The System Score is a real number that emerges from the balance of the three physiological domains that most shape your quality of life.", "tag": "SYSTEM SCORE", "word": "OPTIMAL", "barMove": "Move", "barRest": "Rest", "headline1": "Your body has a score.", "headline2": "From 3 real dimensions.", "domainRest": "Rest", "formulaTop": "Exercise 35% + Nutrition 35% + Rest 30% = System Score", "barNutrition": "Nutrition", "domainUpdate": "Update", "formulaBottom": "Measured at the initial assessment and updated after every completed session.", "domainExercise": "Exercise", "domainRestDesc": "30% score weight", "domainNutrition": "Nutrition", "domainUpdateDesc": "After every session", "domainExerciseDesc": "35% score weight", "domainNutritionDesc": "35% score weight"}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.627589+07	\N
pricing	en	{"sub": "Every paid plan includes the System Assessment, System Score, and Nutrition Guidance. 3-month minimum commitment.", "tag": "SUBSCRIPTION PLANS", "popular": "MOST POPULAR", "headline1": "Start with what fits", "headline2": "your condition and needs.", "saveBadge": "Save 20%", "toggleYearly": "Yearly", "toggleMonthly": "Monthly", "discountBanner": "Pay yearly, save up to 20% â€” 2 months free", "toggleYearlyBadge": "â€“20%"}	{"sub": "Every paid plan includes the System Assessment, System Score, and Nutrition Guidance. 3-month minimum commitment.", "tag": "SUBSCRIPTION PLANS", "popular": "MOST POPULAR", "headline1": "Start with what fits", "headline2": "your condition and needs.", "saveBadge": "Save 20%", "toggleYearly": "Yearly", "toggleMonthly": "Monthly", "discountBanner": "Pay yearly, save up to 20% â€” 2 months free", "toggleYearlyBadge": "â€“20%"}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.631177+07	\N
how	id	{"tag": "CARA KERJA", "steps": {"s1Desc": "25 pertanyaan tentang kondisi gerak, kesehatan, pola tidur, dan nutrisi. Gratis, 10 menit.", "s2Desc": "Platform menghitung level, program yang tepat, dan window sesi optimal berdasarkan kronobiologimu.", "s3Desc": "Session Card siap â€” dengan variabel yang sudah dikalibrasi khusus untuk kondisi dan jadwal hidupmu.", "s4Desc": "System Score diperbarui setiap sesi. Program berkembang seiring kondisi tubuhmu membaik.", "s1Title": "Assessment", "s2Title": "System Score", "s3Title": "Program Aktif", "s4Title": "Progres Terukur"}, "headline1": "Dari assessment", "headline2": "ke program aktif."}	{"tag": "CARA KERJA", "steps": {"s1Desc": "25 pertanyaan tentang kondisi gerak, kesehatan, pola tidur, dan nutrisi. Gratis, 10 menit.", "s2Desc": "Platform menghitung level, program yang tepat, dan window sesi optimal berdasarkan kronobiologimu.", "s3Desc": "Session Card siap â€” dengan variabel yang sudah dikalibrasi khusus untuk kondisi dan jadwal hidupmu.", "s4Desc": "System Score diperbarui setiap sesi. Program berkembang seiring kondisi tubuhmu membaik.", "s1Title": "Assessment", "s2Title": "System Score", "s3Title": "Program Aktif", "s4Title": "Progres Terukur"}, "headline1": "Dari assessment", "headline2": "ke program aktif."}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.628978+07	\N
how	en	{"tag": "HOW IT WORKS", "steps": {"s1Desc": "25 questions on movement, health, sleep patterns, and nutrition. Free, 10 minutes.", "s2Desc": "The platform calculates your level, the right program, and the optimal session window based on your chronobiology.", "s3Desc": "Your Session Card is ready â€” with variables calibrated to your specific condition and schedule.", "s4Desc": "The System Score updates after every session. The program evolves as your body improves.", "s1Title": "Assessment", "s2Title": "System Score", "s3Title": "Active Program", "s4Title": "Measured Progress"}, "headline1": "From assessment", "headline2": "to an active program."}	{"tag": "HOW IT WORKS", "steps": {"s1Desc": "25 questions on movement, health, sleep patterns, and nutrition. Free, 10 minutes.", "s2Desc": "The platform calculates your level, the right program, and the optimal session window based on your chronobiology.", "s3Desc": "Your Session Card is ready â€” with variables calibrated to your specific condition and schedule.", "s4Desc": "The System Score updates after every session. The program evolves as your body improves.", "s1Title": "Assessment", "s2Title": "System Score", "s3Title": "Active Program", "s4Title": "Measured Progress"}, "headline1": "From assessment", "headline2": "to an active program."}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.628978+07	\N
testimonials	id	{"sub": "Cerita nyata dari klien Systemic Fitness yang menjalani program presisi berbasis kondisi.", "tag": "TESTIMONI KLIEN", "headline1": "Mereka sudah mulai,", "headline2": "dan sudah merasakan.", "ratingLabel": "5 dari 5"}	{"sub": "Cerita nyata dari klien Systemic Fitness yang menjalani program presisi berbasis kondisi.", "tag": "TESTIMONI KLIEN", "headline1": "Mereka sudah mulai,", "headline2": "dan sudah merasakan.", "ratingLabel": "5 dari 5"}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.629777+07	\N
testimonials	en	{"sub": "Real stories from Systemic Fitness clients running a condition-based, precision program.", "tag": "CLIENT TESTIMONIALS", "headline1": "They started â€”", "headline2": "and already feel the shift.", "ratingLabel": "5 out of 5"}	{"sub": "Real stories from Systemic Fitness clients running a condition-based, precision program.", "tag": "CLIENT TESTIMONIALS", "headline1": "They started â€”", "headline2": "and already feel the shift.", "ratingLabel": "5 out of 5"}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.629777+07	\N
partner	id	{"sub": "Systemic Fitness memperpanjang jangkauan klinis Anda ke dalam kehidupan harian pasien â€” dengan protokol keamanan, pemantauan real-time, dan data yang kembali kepada Anda.", "tag": "UNTUK MITRA MEDIS & KORPORAT", "items": {"i1Desc": "Clinical Advisor atau Health Educator Partner. Prescribe outcome, pantau progres klien, eskalasi kasus kompleks.", "i2Desc": "Program kesehatan berbasis kondisi karyawan â€” bukan program fitness generik yang tidak terukur hasilnya.", "i3Desc": "Bergabung sebagai eksekutor program dengan Session Card yang sudah diprescribe â€” jalankan dengan presisi.", "i1Title": "Untuk Dokter & Spesialis", "i2Title": "Untuk Program Corporate Wellness", "i3Title": "Untuk Certified Trainer"}, "ctaBtn": "Hubungi Kami", "ctaSub": "Kami mengundang percakapan ilmiah â€” bukan komitmen langsung.", "ctaText": "Tertarik berdiskusi?", "quoteTag": "PERSPEKTIF PENDIRI", "headline1": "Jangkauan klinis", "headline2": "yang lebih luas.", "quoteName": "Citra Hann", "quoteRole": "Founder & Human System Optimization Advisor", "quoteText": "\\"Dokter tahu bahwa pasien perlu bergerak. Gap terbesar selalu ada di antara pengetahuan itu dan eksekusi yang aman dan presisi di kehidupan sehari-hari pasien.\\"", "quoteCompany": "Systemic Fitness Pte. Ltd."}	{"sub": "Systemic Fitness memperpanjang jangkauan klinis Anda ke dalam kehidupan harian pasien â€” dengan protokol keamanan, pemantauan real-time, dan data yang kembali kepada Anda.", "tag": "UNTUK MITRA MEDIS & KORPORAT", "items": {"i1Desc": "Clinical Advisor atau Health Educator Partner. Prescribe outcome, pantau progres klien, eskalasi kasus kompleks.", "i2Desc": "Program kesehatan berbasis kondisi karyawan â€” bukan program fitness generik yang tidak terukur hasilnya.", "i3Desc": "Bergabung sebagai eksekutor program dengan Session Card yang sudah diprescribe â€” jalankan dengan presisi.", "i1Title": "Untuk Dokter & Spesialis", "i2Title": "Untuk Program Corporate Wellness", "i3Title": "Untuk Certified Trainer"}, "ctaBtn": "Hubungi Kami", "ctaSub": "Kami mengundang percakapan ilmiah â€” bukan komitmen langsung.", "ctaText": "Tertarik berdiskusi?", "quoteTag": "PERSPEKTIF PENDIRI", "headline1": "Jangkauan klinis", "headline2": "yang lebih luas.", "quoteName": "Citra Hann", "quoteRole": "Founder & Human System Optimization Advisor", "quoteText": "\\"Dokter tahu bahwa pasien perlu bergerak. Gap terbesar selalu ada di antara pengetahuan itu dan eksekusi yang aman dan presisi di kehidupan sehari-hari pasien.\\"", "quoteCompany": "Systemic Fitness Pte. Ltd."}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.630516+07	\N
partner	en	{"sub": "Systemic Fitness extends your clinical reach into your patients' daily lives â€” with safety protocols, real-time monitoring, and data that flows back to you.", "tag": "FOR MEDICAL & CORPORATE PARTNERS", "items": {"i1Desc": "As a Clinical Advisor or Health Educator Partner. Prescribe outcomes, monitor client progress, and escalate complex cases.", "i2Desc": "A health program built around employee conditions â€” not a generic fitness program with unmeasurable outcomes.", "i3Desc": "Join as a program executor with pre-prescribed Session Cards â€” run them with precision.", "i1Title": "For Doctors & Specialists", "i2Title": "For Corporate Wellness Programs", "i3Title": "For Certified Trainers"}, "ctaBtn": "Contact Us", "ctaSub": "We invite a scientific conversation â€” not an immediate commitment.", "ctaText": "Interested in a conversation?", "quoteTag": "FOUNDER'S PERSPECTIVE", "headline1": "Broader clinical", "headline2": "reach.", "quoteName": "Citra Hann", "quoteRole": "Founder & Human System Optimization Advisor", "quoteText": "\\"Doctors know their patients need to move. The biggest gap has always been between that knowledge and safe, precise execution in the patient's day-to-day life.\\"", "quoteCompany": "Systemic Fitness Pte. Ltd."}	{"sub": "Systemic Fitness extends your clinical reach into your patients' daily lives â€” with safety protocols, real-time monitoring, and data that flows back to you.", "tag": "FOR MEDICAL & CORPORATE PARTNERS", "items": {"i1Desc": "As a Clinical Advisor or Health Educator Partner. Prescribe outcomes, monitor client progress, and escalate complex cases.", "i2Desc": "A health program built around employee conditions â€” not a generic fitness program with unmeasurable outcomes.", "i3Desc": "Join as a program executor with pre-prescribed Session Cards â€” run them with precision.", "i1Title": "For Doctors & Specialists", "i2Title": "For Corporate Wellness Programs", "i3Title": "For Certified Trainers"}, "ctaBtn": "Contact Us", "ctaSub": "We invite a scientific conversation â€” not an immediate commitment.", "ctaText": "Interested in a conversation?", "quoteTag": "FOUNDER'S PERSPECTIVE", "headline1": "Broader clinical", "headline2": "reach.", "quoteName": "Citra Hann", "quoteRole": "Founder & Human System Optimization Advisor", "quoteText": "\\"Doctors know their patients need to move. The biggest gap has always been between that knowledge and safe, precise execution in the patient's day-to-day life.\\"", "quoteCompany": "Systemic Fitness Pte. Ltd."}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.630516+07	\N
pricing	id	{"sub": "Semua paket berbayar dilengkapi System Assessment, System Score, dan Nutrition Guidance. Minimum komitmen 3 bulan.", "tag": "PAKET LANGGANAN", "popular": "PALING POPULER", "headline1": "Mulai sesuai", "headline2": "kondisi dan kebutuhanmu.", "saveBadge": "Hemat 20%", "toggleYearly": "Tahunan", "toggleMonthly": "Bulanan", "discountBanner": "Bayar tahunan, hemat hingga 20% â€” 2 bulan gratis", "toggleYearlyBadge": "â€“20%"}	{"sub": "Semua paket berbayar dilengkapi System Assessment, System Score, dan Nutrition Guidance. Minimum komitmen 3 bulan.", "tag": "PAKET LANGGANAN", "popular": "PALING POPULER", "headline1": "Mulai sesuai", "headline2": "kondisi dan kebutuhanmu.", "saveBadge": "Hemat 20%", "toggleYearly": "Tahunan", "toggleMonthly": "Bulanan", "discountBanner": "Bayar tahunan, hemat hingga 20% â€” 2 bulan gratis", "toggleYearlyBadge": "â€“20%"}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.631177+07	\N
finalCta	id	{"cta": "Mulai Assessment Gratis â†’", "sub": "Assessment 25 pertanyaan. Tidak butuh kartu kredit. Tidak ada komitmen. Hanya data yang jujur tentang kondisi sistem tubuhmu saat ini.", "tag": "MULAI DI SINI", "note": "Tersedia di app dan web Â· Gratis selamanya untuk System Check", "download": "Unduh aplikasinya", "headline1": "Temukan kondisi", "headline2": "sistem tubuhmu â€”", "headlineEm": "gratis."}	{"cta": "Mulai Assessment Gratis â†’", "sub": "Assessment 25 pertanyaan. Tidak butuh kartu kredit. Tidak ada komitmen. Hanya data yang jujur tentang kondisi sistem tubuhmu saat ini.", "tag": "MULAI DI SINI", "note": "Tersedia di app dan web Â· Gratis selamanya untuk System Check", "download": "Unduh aplikasinya", "headline1": "Temukan kondisi", "headline2": "sistem tubuhmu â€”", "headlineEm": "gratis."}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.631735+07	\N
language	id	{"switchTo": "EN"}	{"switchTo": "EN"}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.632604+07	\N
language	en	{"switchTo": "ID"}	{"switchTo": "ID"}	2026-06-26 22:34:21.6432+07	2026-06-26 22:34:21.632604+07	\N
\.


--
-- Data for Name: cms_media; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.cms_media (id, filename, url, mime, width, height, size_bytes, alt, tag, uploaded_by, created_at) FROM stdin;
\.


--
-- Data for Name: cms_pricing_tiers; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.cms_pricing_tiers (id, locale, order_index, name, for_whom, amount_monthly, per_monthly, amount_yearly, per_yearly, equiv_yearly, original_yearly, savings_yearly, features, cta_label, cta_style, is_featured, is_active, created_at, updated_at) FROM stdin;
81e92460-2fdc-4b74-ada2-f2aaca341d64	id	0	System Check	Kenali kondisi sistemmu dulu	Gratis	/ selamanya	\N	\N	\N	\N	\N	["SF System Assessment (25Q)", "System Score awal", "Chronobiology Window", "Akses modul dasar"]	Mulai Gratis	outline	f	t	2026-06-26 22:34:21.63937+07	2026-06-26 22:34:21.63937+07
89d5014c-50a6-46b8-a5ef-d10ba493b3e9	id	1	Preventive Auto	Level 5 â€” tanpa kondisi medis	399K	/ bulan	3.830K	/ tahun	setara 319K/bulan	4.788K	Hemat Rp 958rb/tahun	["Program otomatis penuh", "Full Program + Daily Reset", "Session Card + video", "Nutrition Guidance"]	Mulai Assessment	solid	f	t	2026-06-26 22:34:21.63937+07	2026-06-26 22:34:21.63937+07
e84b3e4f-d02f-44e4-a1ee-03f86bd2424d	id	2	Performance	Pria atau wanita 35â€“60	499K	/ bulan	4.790K	/ tahun	setara 399K/bulan	5.988K	Hemat Rp 1,2jt/tahun	["Women's atau Men's Program", "Sub-program spesifik usia", "Hormonal optimization guide", "Monthly program progression"]	Mulai Assessment	solid	t	t	2026-06-26 22:34:21.63937+07	2026-06-26 22:34:21.63937+07
d7337719-57b9-451b-8f73-549b5efb5e45	id	3	System Active	Level 4â€“5 dengan kondisi medis	799K	/ bulan	7.670K	/ tahun	setara 639K/bulan	9.588K	Hemat Rp 1,9jt/tahun	["Health Consultant penuh", "Program dikurasi manual", "Medical Flag monitoring", "Lab Consultation (wajib, 350K)"]	Mulai Assessment	gold	f	t	2026-06-26 22:34:21.63937+07	2026-06-26 22:34:21.63937+07
74322a7b-969d-45d7-9569-6b4faeefbcac	en	0	System Check	Know your system first	Free	/ forever	\N	\N	\N	\N	\N	["SF System Assessment (25Q)", "Initial System Score", "Chronobiology Window", "Access to base modules"]	Start Free	outline	f	t	2026-06-26 22:34:21.63937+07	2026-06-26 22:34:21.63937+07
4ea9179d-f042-4f51-8b4f-3cf2bfd61ce5	en	1	Preventive Auto	Level 5 â€” no medical condition	399K	/ month	3,830K	/ year	equiv. 319K/month	4,788K	Save Rp 958K/year	["Fully automated program", "Full Program + Daily Reset", "Session Card + video", "Nutrition Guidance"]	Start Assessment	solid	f	t	2026-06-26 22:34:21.63937+07	2026-06-26 22:34:21.63937+07
23a7512d-1f8b-479b-a365-0f63ccf378de	en	2	Performance	Men or women 35â€“60	499K	/ month	4,790K	/ year	equiv. 399K/month	5,988K	Save Rp 1.2M/year	["Women's or Men's Program", "Age-specific sub-program", "Hormonal optimization guide", "Monthly program progression"]	Start Assessment	solid	t	t	2026-06-26 22:34:21.63937+07	2026-06-26 22:34:21.63937+07
b4aea278-46f4-469a-8228-e58f294235b8	en	3	System Active	Level 4â€“5 with medical condition	799K	/ month	7,670K	/ year	equiv. 639K/month	9,588K	Save Rp 1.9M/year	["Full Health Consultant support", "Manually curated program", "Medical Flag monitoring", "Lab Consultation (required, 350K)"]	Start Assessment	gold	f	t	2026-06-26 22:34:21.63937+07	2026-06-26 22:34:21.63937+07
\.


--
-- Data for Name: cms_programs; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.cms_programs (id, locale, order_index, tier_label, tier_color, name, description, features, meta, image_id, image_url, is_active, created_at, updated_at) FROM stdin;
45896c86-b1a1-42b9-b700-3f447d6af159	id	0	LEVEL 4â€“5		Condition-Specific Program	Untuk kondisi medis aktif yang masih bisa bergerak mandiri. Program dikurasi oleh Health Consultant berdasarkan kondisi spesifik.	["Health Consultant mengkurasi setiap Session Card", "Prescripsi outcome berbasis kondisi medis", "Chronobiology window per kondisi", "Nutrition guidance spesifik kondisi"]	[{"span": "Full 2Ã—/minggu", "strong": "60 mnt"}, {"span": "Reset 2â€“3Ã—/minggu", "strong": "30 mnt"}, {"span": "Kurasi manual", "strong": "Konsultan"}]	\N	\N	t	2026-06-26 22:34:21.63645+07	2026-06-26 22:34:21.63645+07
a2847df5-61da-421c-8975-723b864b6865	id	1	LEVEL 5		Preventive Optimization	Tanpa kondisi medis aktif. Program otomatis penuh untuk mempertahankan dan mengoptimalkan kapasitas sistem tubuh.	["Fully automated â€” tidak perlu Consultant", "Session Card berbasis movement test awal", "Chronobiology window personal", "Performance diet guidance"]	[{"span": "Full 2Ã—/minggu", "strong": "60 mnt"}, {"span": "Reset 2â€“3Ã—/minggu", "strong": "30 mnt"}, {"span": "Self-guided", "strong": "Otomatis"}]	\N	\N	t	2026-06-26 22:34:21.63645+07	2026-06-26 22:34:21.63645+07
6e9c6f8b-4281-42e9-a17c-980308695fc7	id	2	ADVANCED		Performance 35â€“60	Optimasi hormonal dan performa untuk pria atau wanita usia 35â€“60. Sub-program spesifik usia, gender, dan profil hormonal.	["Women's Program: 35â€“45 dan 46â€“60", "Men's Program: 35â€“45 dan 46â€“60", "Window sesi berbasis hormonal peak", "Hormonal optimization diet guidance"]	[{"span": "35â€“45 / 46â€“60", "strong": "Women's"}, {"span": "35â€“45 / 46â€“60", "strong": "Men's"}, {"span": "Gender-specific", "strong": "Otomatis"}]	\N	\N	t	2026-06-26 22:34:21.63645+07	2026-06-26 22:34:21.63645+07
fc307b4d-2580-4335-96d3-cb981653f43a	en	0	LEVEL 4â€“5		Condition-Specific Program	For active medical conditions where independent movement is still possible. Programs are curated by a Health Consultant based on the specific condition.	["Health Consultant curates every Session Card", "Outcome-based prescription for the medical condition", "Chronobiology window per condition", "Condition-specific nutrition guidance"]	[{"span": "Full 2Ã—/week", "strong": "60 min"}, {"span": "Reset 2â€“3Ã—/week", "strong": "30 min"}, {"span": "Manual curation", "strong": "Consultant"}]	\N	\N	t	2026-06-26 22:34:21.63645+07	2026-06-26 22:34:21.63645+07
1fc652f2-fdf1-4c7a-bc26-3b7101577690	en	1	LEVEL 5		Preventive Optimization	No active medical condition. A fully automated program to maintain and optimize your body's system capacity.	["Fully automated â€” no Consultant needed", "Session Cards based on initial movement test", "Personal chronobiology window", "Performance diet guidance"]	[{"span": "Full 2Ã—/week", "strong": "60 min"}, {"span": "Reset 2â€“3Ã—/week", "strong": "30 min"}, {"span": "Self-guided", "strong": "Automated"}]	\N	\N	t	2026-06-26 22:34:21.63645+07	2026-06-26 22:34:21.63645+07
7f21d6a7-5938-42ad-a289-09f8513ed15a	en	2	ADVANCED		Performance 35â€“60	Hormonal and performance optimization for men or women aged 35â€“60. Sub-programs specific to age, gender, and hormonal profile.	["Women's Program: 35â€“45 and 46â€“60", "Men's Program: 35â€“45 and 46â€“60", "Session window based on hormonal peak", "Hormonal optimization diet guidance"]	[{"span": "35â€“45 / 46â€“60", "strong": "Women's"}, {"span": "35â€“45 / 46â€“60", "strong": "Men's"}, {"span": "Gender-specific", "strong": "Automated"}]	\N	\N	t	2026-06-26 22:34:21.63645+07	2026-06-26 22:34:21.63645+07
\.


--
-- Data for Name: cms_settings; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.cms_settings (key, value, updated_at, updated_by) FROM stdin;
\.


--
-- Data for Name: cms_testimonials; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.cms_testimonials (id, locale, order_index, name, role, title, description, rating, image_id, image_url, is_active, created_at, updated_at) FROM stdin;
c5093eb0-2f90-4038-bcfb-dd56542fe687	id	0	Arya Pramudita	Direktur, 52 tahun	Tensi stabil tanpa tambahan obat.	Setelah 3 bulan program Condition-Specific, tekanan darah dan kolesterol saya turun signifikan. Yang berbeda: setiap sesi dikalibrasi ke kondisi saya, bukan target generik.	5	\N	testimonial-1-arya.webp	t	2026-06-26 22:34:21.633115+07	2026-06-26 22:34:21.633115+07
75405c00-26ac-46a1-b8a5-13a3ad263920	id	1	Rini Saputra	Founder, 47 tahun	Hormonal saya akhirnya seimbang.	5 tahun saya coba berbagai pendekatan untuk perimenopause. Systemic Fitness adalah yang pertama mengerti bahwa hormon butuh window gerakan dan intensitas yang spesifik.	5	\N	testimonial-2-rini.webp	t	2026-06-26 22:34:21.633115+07	2026-06-26 22:34:21.633115+07
4305370c-88e7-4e7b-9fd7-a0564cee3df4	id	2	dr. Dharma Wijaya	Spesialis Penyakit Dalam, 45 tahun	Metode yang akhirnya presisi.	Sebagai dokter, saya kritis terhadap klaim fitness. Pendekatan 4 variabel ini konsisten dengan literatur fisiologi olahraga â€” dan saya rasakan sendiri hasilnya.	5	\N	testimonial-3-dharma.webp	t	2026-06-26 22:34:21.633115+07	2026-06-26 22:34:21.633115+07
45adc487-4647-40e5-b4c2-7c6d6ce22989	en	0	Arya Pramudita	Director, age 52	Blood pressure stable â€” without adding medication.	After 3 months on the Condition-Specific program, my blood pressure and cholesterol dropped meaningfully. What's different: every session is calibrated to my condition, not to a generic target.	5	\N	testimonial-1-arya.webp	t	2026-06-26 22:34:21.633115+07	2026-06-26 22:34:21.633115+07
e51c00b9-bed1-4f8a-84fb-a4866a5a2290	en	1	Rini Saputra	Founder, age 47	My hormones finally came back into balance.	For 5 years I tried every approach for perimenopause. Systemic Fitness was the first to understand that hormones need a specific movement window and intensity.	5	\N	testimonial-2-rini.webp	t	2026-06-26 22:34:21.633115+07	2026-06-26 22:34:21.633115+07
1ef9e15f-24fe-4912-8736-098a4daa163f	en	2	Dr. Dharma Wijaya	Internal Medicine Specialist, age 45	A method that's finally precise.	As a physician I'm critical of fitness claims. This 4-variable approach is consistent with the exercise physiology literature â€” and I've felt the result myself.	5	\N	testimonial-3-dharma.webp	t	2026-06-26 22:34:21.633115+07	2026-06-26 22:34:21.633115+07
\.


--
-- Data for Name: condition_classifications; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.condition_classifications (id, slug, label, description, focus_pillar, full_program_formula, daily_reset_formula, sort_order, is_active, created_at, updated_at) FROM stdin;
2a6ef936-8d13-4db1-bf6c-4e7afa244bba	imun-inflamasi	Imun & Inflamasi	Autoimun, alergi kronis, inflamasi sistemik, kista, tumor jinak, fibromyalgia. Pilar dominan: Functional Conditioning.	FC	{"CC": 15, "FC": 35, "MC": 10}	{"CC": 10, "FC": 20}	1	t	2026-06-26 22:34:21.770735+07	2026-06-26 22:34:21.770735+07
80afc103-42c4-4beb-afdb-8f5d6f1c0fc3	renal-uric	Renal & Uric System	Gangguan ginjal (CKD 1â€“3), batu ginjal, asam urat / gout, hiperkalemia ringan. Pilar dominan: Cardiorespiratory Conditioning.	CC	{"CC": 35, "FC": 10, "MC": 15}	{"CC": 20, "FC": 10}	2	t	2026-06-26 22:34:21.770735+07	2026-06-26 22:34:21.770735+07
79650160-ecd0-4564-ac3f-e78e5a62ea83	cardiorespiratory	Cardiorespiratory	Hipertensi (stadium 1â€“2), penyakit jantung koroner stabil, aritmia ringan, asma terkontrol, PPOK ringan, kolesterol tinggi, gangguan syaraf pusat. Pilar dominan: Cardiorespiratory Conditioning.	CC	{"CC": 35, "FC": 10, "MC": 15}	{"CC": 20, "MC": 10}	3	t	2026-06-26 22:34:21.770735+07	2026-06-26 22:34:21.770735+07
5884abe4-0575-407f-a263-97794aeef2a4	metabolic	Metabolic	Diabetes Tipe 2 (terkontrol), pre-diabetes, PCOS, gangguan tiroid, resistensi insulin, obesitas metabolik. Pilar dominan: Metabolic Conditioning.	MC	{"CC": 15, "FC": 10, "MC": 35}	{"CC": 10, "MC": 20}	4	t	2026-06-26 22:34:21.770735+07	2026-06-26 22:34:21.770735+07
587d2fd5-f8ca-4ab0-8700-b57fb3c2220b	musculoskeletal	Musculoskeletal	Osteoarthritis, osteoporosis, HNP, spondylosis, frozen shoulder, skoliosis, neuropati perifer, kelemahan otot pasca imobilisasi. Pilar dominan: Metabolic Conditioning.	MC	{"CC": 15, "FC": 10, "MC": 35}	{"FC": 10, "MC": 20}	5	t	2026-06-26 22:34:21.770735+07	2026-06-26 22:34:21.770735+07
\.


--
-- Data for Name: conversation_members; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.conversation_members (conversation_id, user_id, joined_at, role, is_muted, last_read_at) FROM stdin;
\.


--
-- Data for Name: conversations; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.conversations (id, type, name, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: customer_hr_zones; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.customer_hr_zones (id, customer_id, max_hr_upper, max_hr_lower, zone5_upper, zone5_lower, zone4_upper, zone4_lower, zone3_upper, zone3_lower, zone2_upper, zone2_lower, zone1_upper, zone1_lower, notes, created_at, updated_at, priority) FROM stdin;
\.


--
-- Data for Name: customer_medicines; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.customer_medicines (id, customer_id, medicine_id, notes, is_active, created_at) FROM stdin;
\.


--
-- Data for Name: customer_program_assignments; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.customer_program_assignments (id, customer_id, program_category_id, is_active, bpm_upper, bpm_lower, has_beban_upper, has_beban_lower, has_resistance, parameter_notes, created_at, updated_at, beban_upper_value, beban_lower_value) FROM stdin;
008a5d14-0da6-49bc-8aeb-12f660b679d4	248a8cb1-9d52-41f8-94b2-1ff93098b3ec	664c2d1f-3cc4-41fa-9119-16b5f5b16d67	t	\N	\N	f	f	f	\N	2026-06-29 05:11:19.432723+07	2026-06-29 05:11:19.432723+07	\N	\N
be61f3f2-c74c-4242-bbe5-7cecd0c64053	248a8cb1-9d52-41f8-94b2-1ff93098b3ec	05f41810-2f08-4646-bc46-0a5a40f104d8	t	\N	\N	f	f	f	\N	2026-06-29 05:11:19.453066+07	2026-06-29 05:11:19.453066+07	\N	\N
c5131957-6167-4066-b511-9a3b83815e02	248a8cb1-9d52-41f8-94b2-1ff93098b3ec	5385cb84-7c3e-43b5-8268-f31015d6a4bd	t	\N	\N	f	f	f	\N	2026-06-29 05:11:19.454375+07	2026-06-29 05:11:19.454375+07	\N	\N
\.


--
-- Data for Name: daily_journal_sessions; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.daily_journal_sessions (id, customer_id, session_number, session_date, month_year, notes, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: device_tokens; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.device_tokens (id, user_id, token, platform, device_name, is_active, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: dl_categories; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.dl_categories (id, code, name, description, created_at, updated_at) FROM stdin;
d032524e-10df-417f-b51a-6966d46cb502	fc	Functional Conditioning	Functional movement patterns for rehabilitation and conditioning. Focuses on basic movement quality, joint stability, and progressive mobility from bed-bound to full dynamic movement.	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
aae69106-90e2-4803-a4f5-6a7841f6ce34	cc	Cardio Conditioning	Cardiovascular conditioning movements designed to improve heart rate response, endurance, and aerobic capacity progressively from seated to full dynamic training.	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	mc	Metabolic Conditioning	Metabolic and muscle-building movements using resistance bands and bodyweight. Targets muscle hypertrophy, metabolic rate improvement, and core stability.	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
\.


--
-- Data for Name: dl_dynamic_items; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.dl_dynamic_items (id, category_id, upper_movement_id, lower_movement_id, sort_order, created_at, updated_at) FROM stdin;
25bcd0e5-7e5a-44a2-b99e-8b85f0cebb42	d032524e-10df-417f-b51a-6966d46cb502	c7c8affc-dcdb-4aff-a939-fa66fc08bebf	c9a344b5-3874-4b87-9e26-74dc9fe2e5cd	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
26d6dfe4-4700-48e9-b043-b49d24051590	d032524e-10df-417f-b51a-6966d46cb502	d6e261d0-faf1-45f5-912c-0cd831b7522e	c9a344b5-3874-4b87-9e26-74dc9fe2e5cd	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
554bbb3e-b9f6-4be2-bec6-638104622e93	d032524e-10df-417f-b51a-6966d46cb502	8428a6d4-1a1b-4692-bea3-a577dfa6a811	c9a344b5-3874-4b87-9e26-74dc9fe2e5cd	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
01d46838-e66b-4a8c-9278-a2a54212574c	d032524e-10df-417f-b51a-6966d46cb502	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	c9a344b5-3874-4b87-9e26-74dc9fe2e5cd	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
f7cbe781-9d3c-4e08-af48-6b2d0021b0ae	d032524e-10df-417f-b51a-6966d46cb502	8428a6d4-1a1b-4692-bea3-a577dfa6a811	1b29430e-2226-4bb6-8a3e-2e1e87e948bb	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
1a52fd8b-1510-4f6c-baba-e5e40b5224ce	d032524e-10df-417f-b51a-6966d46cb502	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	1b29430e-2226-4bb6-8a3e-2e1e87e948bb	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
712b0cdb-3313-4fe8-b029-6c9a461e8a0e	d032524e-10df-417f-b51a-6966d46cb502	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	1b29430e-2226-4bb6-8a3e-2e1e87e948bb	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
6633d5de-2adc-404b-96c1-f0fdce77cfb1	d032524e-10df-417f-b51a-6966d46cb502	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	7ea08c97-c22e-4839-b097-d6b50633f91a	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
36dd07d5-a54a-40e6-a5c5-bb11edd23bc7	d032524e-10df-417f-b51a-6966d46cb502	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	7ea08c97-c22e-4839-b097-d6b50633f91a	9	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
3c115a52-945b-4c77-b8d8-9792583c11de	d032524e-10df-417f-b51a-6966d46cb502	f2398444-bbe5-4642-8320-981250a60830	7ea08c97-c22e-4839-b097-d6b50633f91a	10	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
13b69254-92da-46c5-b858-8523421e36eb	d032524e-10df-417f-b51a-6966d46cb502	d6e261d0-faf1-45f5-912c-0cd831b7522e	9dc772a5-dc6f-4227-a4b5-2a3b7f749346	11	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
99fe8d46-d437-41c6-bcbe-997a147ddf7d	d032524e-10df-417f-b51a-6966d46cb502	e3cdfd81-2ea1-4841-b959-010c0de70cfa	63a6a666-a584-4d06-9d50-123f8416d5fa	12	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
5f66edab-1e64-4c7c-804b-f6861c848200	d032524e-10df-417f-b51a-6966d46cb502	f2398444-bbe5-4642-8320-981250a60830	db796cdf-63d0-48eb-9fdb-3606f9193979	13	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
de948b33-89a9-4916-8914-d55e2a30ccad	d032524e-10df-417f-b51a-6966d46cb502	aafde125-051f-4ce0-aaed-bf2e99a97372	db796cdf-63d0-48eb-9fdb-3606f9193979	14	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
fdb3503d-bfe4-4183-a392-54eb981588db	d032524e-10df-417f-b51a-6966d46cb502	cfc843cd-d86d-45c5-b973-3115f382c168	db796cdf-63d0-48eb-9fdb-3606f9193979	15	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
3398aec5-11a2-433a-ad47-feb8664acec6	d032524e-10df-417f-b51a-6966d46cb502	cfc843cd-d86d-45c5-b973-3115f382c168	c4556c38-bdaa-46f6-a028-34bfa47d1b03	16	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
6a40ed75-2e0c-4ccb-a52e-c5dfd33008cd	d032524e-10df-417f-b51a-6966d46cb502	\N	05defb2e-fb85-45b2-95f8-3599770e5e91	17	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
7198838d-886d-475a-bceb-74778a5f60d8	d032524e-10df-417f-b51a-6966d46cb502	\N	9935cb34-904b-4213-9143-0b27365fee6b	18	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
ae1b3aad-8f2f-4e8c-98ab-3f22744b4177	d032524e-10df-417f-b51a-6966d46cb502	\N	87857153-fc40-495f-aeec-c0dfe041a736	19	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
38b5e884-dc21-49e8-b2d6-ea517200cfc0	d032524e-10df-417f-b51a-6966d46cb502	\N	51f3d882-7ac7-44e8-8253-7764916ce2f4	20	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
aacb403f-ca0c-44d9-8562-f32458f4b2dc	d032524e-10df-417f-b51a-6966d46cb502	\N	15d5324e-f356-4b97-b49e-8151578dff23	21	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
6cc90995-ae03-4a5b-bc67-c1116e47f6bf	d032524e-10df-417f-b51a-6966d46cb502	\N	85b1b505-0ef3-4982-b046-4fbe098c7fe4	22	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
45f03967-f67e-4c28-a32b-9e7ce51d026e	d032524e-10df-417f-b51a-6966d46cb502	\N	3c80c5d3-045c-49f2-93eb-5bf137808878	23	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
0adf0374-c284-4222-a512-fecbd94beaaa	d032524e-10df-417f-b51a-6966d46cb502	\N	f142aa48-3c52-4818-b4e4-863e1ef6e0e3	24	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
9b877114-695d-475b-a314-743e2a39f423	d032524e-10df-417f-b51a-6966d46cb502	\N	ac2557b4-8e09-4195-a6f1-eac7105975a4	25	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
f3b00729-0ca7-4ec0-a083-a6cb1ffd0a42	d032524e-10df-417f-b51a-6966d46cb502	\N	4b6d2e84-9a13-4bfb-9605-9b754440f9d2	26	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
896985e7-247e-4c58-8e96-8d34de983140	d032524e-10df-417f-b51a-6966d46cb502	\N	894ca941-f68d-4938-9b9c-679871952f5d	27	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
f79ac7c9-33c8-4210-b69f-527f7445e5f9	d032524e-10df-417f-b51a-6966d46cb502	\N	0eba8dcf-fb6d-4250-95ab-9e4f61d757b7	28	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
4c89ffd2-70ea-491a-9c90-b038e6955597	aae69106-90e2-4803-a4f5-6a7841f6ce34	c7c8affc-dcdb-4aff-a939-fa66fc08bebf	c9a344b5-3874-4b87-9e26-74dc9fe2e5cd	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
b02d0917-2651-4a43-84e8-4f75a4098a20	aae69106-90e2-4803-a4f5-6a7841f6ce34	8428a6d4-1a1b-4692-bea3-a577dfa6a811	c9a344b5-3874-4b87-9e26-74dc9fe2e5cd	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
0de96cb6-2989-47a6-a2a9-37d2e62648d4	aae69106-90e2-4803-a4f5-6a7841f6ce34	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	c9a344b5-3874-4b87-9e26-74dc9fe2e5cd	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
d01f6ca7-5f0c-4dd8-a4e2-bf9a67794a5b	aae69106-90e2-4803-a4f5-6a7841f6ce34	9139bf83-aa03-46bd-b796-129f11f78d06	c9a344b5-3874-4b87-9e26-74dc9fe2e5cd	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
71154ec5-e163-43fd-b2fc-ed5ea3aa0ebd	aae69106-90e2-4803-a4f5-6a7841f6ce34	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	c840bc04-8c76-402d-bc8d-73346d736c06	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
5cd5fcf0-5d2d-49b7-811d-bafb0e66c5ae	aae69106-90e2-4803-a4f5-6a7841f6ce34	f2398444-bbe5-4642-8320-981250a60830	c840bc04-8c76-402d-bc8d-73346d736c06	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
943ac027-cd96-4977-bda9-bef25ecef1f7	aae69106-90e2-4803-a4f5-6a7841f6ce34	aafde125-051f-4ce0-aaed-bf2e99a97372	833089c8-da19-43e4-a612-fbff2c1f101c	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
568f7128-d7a8-4abd-8e55-afac416e190e	aae69106-90e2-4803-a4f5-6a7841f6ce34	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	833089c8-da19-43e4-a612-fbff2c1f101c	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
73f4d0aa-c770-4360-8331-98566c472fdc	aae69106-90e2-4803-a4f5-6a7841f6ce34	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	833089c8-da19-43e4-a612-fbff2c1f101c	9	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
5cae0f54-2189-4c71-b438-c8489405d1e7	aae69106-90e2-4803-a4f5-6a7841f6ce34	8428a6d4-1a1b-4692-bea3-a577dfa6a811	833089c8-da19-43e4-a612-fbff2c1f101c	10	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
324d0537-e904-4b82-b4f5-b0a0b71c0cc4	aae69106-90e2-4803-a4f5-6a7841f6ce34	8428a6d4-1a1b-4692-bea3-a577dfa6a811	1b29430e-2226-4bb6-8a3e-2e1e87e948bb	11	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
87794121-6883-4f9b-9d32-c6f0c0ecfb00	aae69106-90e2-4803-a4f5-6a7841f6ce34	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	1b29430e-2226-4bb6-8a3e-2e1e87e948bb	12	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
bb93ffc4-7e1a-4d19-b890-be5d968dce3e	aae69106-90e2-4803-a4f5-6a7841f6ce34	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	1b29430e-2226-4bb6-8a3e-2e1e87e948bb	13	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
fab65c29-3130-4fe3-be77-16446b48831c	aae69106-90e2-4803-a4f5-6a7841f6ce34	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	7ea08c97-c22e-4839-b097-d6b50633f91a	14	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
bb444acf-f603-4bbc-93af-c6c8288ac519	aae69106-90e2-4803-a4f5-6a7841f6ce34	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	7ea08c97-c22e-4839-b097-d6b50633f91a	15	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
9c8bc8ee-75ea-41c9-a922-919343d4fc3d	aae69106-90e2-4803-a4f5-6a7841f6ce34	f2398444-bbe5-4642-8320-981250a60830	7ea08c97-c22e-4839-b097-d6b50633f91a	16	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
84b52cfd-9e49-4e73-8e11-e568ee5c0e9a	aae69106-90e2-4803-a4f5-6a7841f6ce34	d6e261d0-faf1-45f5-912c-0cd831b7522e	9dc772a5-dc6f-4227-a4b5-2a3b7f749346	17	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
3685f25f-61af-497a-9221-f6f6d2d2087e	aae69106-90e2-4803-a4f5-6a7841f6ce34	e3cdfd81-2ea1-4841-b959-010c0de70cfa	63a6a666-a584-4d06-9d50-123f8416d5fa	18	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
0c8d56fe-7b43-438e-9802-95cec9b85c44	aae69106-90e2-4803-a4f5-6a7841f6ce34	f2398444-bbe5-4642-8320-981250a60830	db796cdf-63d0-48eb-9fdb-3606f9193979	19	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
51df8ef9-d75a-489c-86c1-0f8b836634ec	aae69106-90e2-4803-a4f5-6a7841f6ce34	aafde125-051f-4ce0-aaed-bf2e99a97372	db796cdf-63d0-48eb-9fdb-3606f9193979	20	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
542f05a2-e97d-481e-bb6c-910827735961	aae69106-90e2-4803-a4f5-6a7841f6ce34	cfc843cd-d86d-45c5-b973-3115f382c168	db796cdf-63d0-48eb-9fdb-3606f9193979	21	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
ffb32839-da44-4a8c-8d6e-14d3198deb75	aae69106-90e2-4803-a4f5-6a7841f6ce34	cfc843cd-d86d-45c5-b973-3115f382c168	c4556c38-bdaa-46f6-a028-34bfa47d1b03	22	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
63fec0a8-4caa-4a85-9acb-b8eee5af5b9a	aae69106-90e2-4803-a4f5-6a7841f6ce34	8428a6d4-1a1b-4692-bea3-a577dfa6a811	c4556c38-bdaa-46f6-a028-34bfa47d1b03	23	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
24b36c75-023a-4212-99f8-385b29d6bfe5	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	8428a6d4-1a1b-4692-bea3-a577dfa6a811	\N	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
63772db8-12ca-4641-abb7-12062188f5c8	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	\N	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
c3fab987-0d88-439a-af60-65912808c796	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	\N	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
df340f8e-c2bf-49c2-819e-47183bdcfd7f	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	\N	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
56a15ec1-7279-4602-a0c2-64e1944c1592	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	0b6e7914-54d4-42a0-aec8-05b7c7234872	\N	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
9fb98052-3c35-4943-84a5-3ce7989e1a10	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	aafde125-051f-4ce0-aaed-bf2e99a97372	\N	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
851fb215-e6a4-4f5b-8c44-def006f57825	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	5ba18970-1774-4a6a-8456-c19bab92671d	\N	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
4f3142d0-93aa-45b3-a408-d6704467968d	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	521a2b77-234b-44f4-a482-1f1ce3abf3f1	\N	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
f15ec71d-3e05-48e3-bb32-bfcaaf41c785	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	f614af5f-c633-44c2-b92c-be9ca507cfd7	\N	9	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
aebc1b46-88b1-4e1f-a0f1-8b3cdebbf858	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	ae70796b-d9aa-4ea4-b795-89165bfb8029	\N	10	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
50fbb61b-fc13-4560-865d-880c3dea0627	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	789b9947-e362-4948-8d6a-7b6b3f43b246	\N	11	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
a1b1a4d0-8c77-4ee1-bce6-7e997d6c211f	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	47057f8e-9f03-4cf8-87ef-4f587d856f19	\N	12	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
de0ee856-544d-4eae-a1ab-4a5f44a6de9b	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	9160e1a2-13fe-4ca6-9040-4e4d0f78c030	\N	13	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
098c0d46-14fd-4db3-a450-c1783f7aae19	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	74f13017-e0ed-4cc5-aa05-b513ea6cf24f	\N	14	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
b0307ea0-04f6-4838-a4d8-daab3a0fcd33	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	61ee0d3d-f5b5-433c-9408-473d7e8a32df	\N	15	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
57e61120-304c-40b6-89ca-a26bd86960b1	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	\N	d4ac99a4-3ce1-4483-9cb3-d35cbb42c950	16	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
4d519c45-00de-41e5-b692-5d09c7f3d3ce	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	\N	4daf5ce2-89ee-416e-92cd-69594d1c5a14	17	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
91f2cdd0-f2a6-4a5a-83c1-a5f6078328a4	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	\N	9dc772a5-dc6f-4227-a4b5-2a3b7f749346	18	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
6f31a48a-bcf8-4483-afa2-87e0b5ce2d81	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	\N	27ca566a-bd2e-4d13-a8a3-49eccc0f7bf8	19	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
c8cde074-569a-447d-99e7-a83ca4f80645	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	\N	44f65fd4-2aaf-49fe-befb-3fef93739677	20	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
11e66474-ce17-4385-b961-444a422ec921	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	\N	37edd988-e4fe-4abe-b016-3ad8d88ff60a	21	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
a8cd25a3-02a7-4747-80cc-0fca1f476f67	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	\N	abb6395e-9d40-43b3-9dcd-85416c240ab8	22	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
\.


--
-- Data for Name: dl_isolate_items; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.dl_isolate_items (id, category_id, movement_id, "position", sort_order, created_at, updated_at) FROM stdin;
5501f47a-072a-4ca2-bbe4-a584d51a07c2	d032524e-10df-417f-b51a-6966d46cb502	c7c8affc-dcdb-4aff-a939-fa66fc08bebf	sit	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
ec593731-733a-4f34-b162-4a381b0f0862	d032524e-10df-417f-b51a-6966d46cb502	8428a6d4-1a1b-4692-bea3-a577dfa6a811	sit	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
b2d038b1-1b8a-4ea4-b839-afac3b7c10e9	d032524e-10df-417f-b51a-6966d46cb502	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	sit	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
a2036965-53ad-4c19-97fa-fa463f979ff4	d032524e-10df-417f-b51a-6966d46cb502	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	sit	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
f5abc0fd-e973-40af-a9d3-04d6cd4f5b24	d032524e-10df-417f-b51a-6966d46cb502	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	sit	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
3cb65dc3-10b2-49cd-99cc-b363b9336476	d032524e-10df-417f-b51a-6966d46cb502	f2398444-bbe5-4642-8320-981250a60830	sit	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
6cf15e76-0fdc-4b49-b0d8-a478191bab28	d032524e-10df-417f-b51a-6966d46cb502	d036485a-87a4-4399-b5f3-b5f617d679b9	sit	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
a1625ae6-5b67-470b-8e67-d6c6d89e15e5	d032524e-10df-417f-b51a-6966d46cb502	70a2edb9-cb34-4cbe-ad6a-683114cc77e7	sit	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
15fa3f52-5a76-4b21-9114-8174ed2a5737	d032524e-10df-417f-b51a-6966d46cb502	50b7bc06-2f6c-4ee7-9183-f9ec1eae7d40	sit	9	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
51ffbc56-e349-4955-b7b6-84c80b22a7cf	d032524e-10df-417f-b51a-6966d46cb502	8f6c1c2f-0d36-41c0-be60-d4de938e81f8	sit	10	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
639713c2-06ff-4190-b53d-0f4d2b8791d1	d032524e-10df-417f-b51a-6966d46cb502	c7c8affc-dcdb-4aff-a939-fa66fc08bebf	stand	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
a5fc4145-957c-4d62-8507-21d6f04588c9	d032524e-10df-417f-b51a-6966d46cb502	8428a6d4-1a1b-4692-bea3-a577dfa6a811	stand	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
0ec78c9b-e671-43cf-93c8-df9c22a55bf4	d032524e-10df-417f-b51a-6966d46cb502	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	stand	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
4a6d6df7-1777-4f3d-9cca-97f7ed32cd12	d032524e-10df-417f-b51a-6966d46cb502	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	stand	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
5a11b5ac-d6ef-4e93-a3ca-a3f2ba81da6d	d032524e-10df-417f-b51a-6966d46cb502	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	stand	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
353eaf72-5570-4a83-9d5a-3daf8414e7bd	d032524e-10df-417f-b51a-6966d46cb502	f2398444-bbe5-4642-8320-981250a60830	stand	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
c9e295df-a4e0-44e1-91a6-5e407d2e0301	d032524e-10df-417f-b51a-6966d46cb502	4574f322-2ac5-4ba4-b422-9d71fbf39408	stand	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
1f868387-5c6b-4351-b639-9b2a28de7869	d032524e-10df-417f-b51a-6966d46cb502	4af59389-3f46-49b1-8783-d4816706d02b	stand	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
5c6541ee-eacb-4d88-b32b-4d2b5570b35d	d032524e-10df-417f-b51a-6966d46cb502	b438a3a2-bc18-449d-8ba7-08bf1690a3e2	stand	9	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
d6527ef9-90f8-4301-a019-b2e4dae3afb5	d032524e-10df-417f-b51a-6966d46cb502	ba1c2a86-1612-44e6-aee8-d80be806d487	stand	10	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
69244710-5458-49da-887c-e813a4d34f96	d032524e-10df-417f-b51a-6966d46cb502	ff9be11c-43c3-4383-ba31-94fab9fcd453	stand	11	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
1a6f1d21-fd53-4ac5-b3ed-113d5fe3b0c9	d032524e-10df-417f-b51a-6966d46cb502	4b77ac6b-96d8-43cc-8128-806471103cb3	stand	12	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
58ba3e28-0913-4cc1-92e7-b7bf70405272	d032524e-10df-417f-b51a-6966d46cb502	18f544bf-7ea0-46f3-b699-0df77d345ebe	stand	13	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
2ffb503e-0295-4c05-8fd0-bac642dc5cd3	d032524e-10df-417f-b51a-6966d46cb502	6b794bbb-4265-4785-8402-0c686cc0e1ca	stand	14	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
9337e773-8d87-4efb-ba20-747caf9a8b78	d032524e-10df-417f-b51a-6966d46cb502	db2f510f-b6de-48fd-942e-2fd9fa41d7b3	stand	15	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
b18e04c1-1f78-4dfe-a001-b6d74000e376	d032524e-10df-417f-b51a-6966d46cb502	42b48539-518c-41ea-8381-d3b5b07f27b6	stand	16	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
4eb69176-c6df-4edf-a140-ff786b84a23f	d032524e-10df-417f-b51a-6966d46cb502	51f3d882-7ac7-44e8-8253-7764916ce2f4	stand	17	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
c10e5f5e-21db-4ece-8906-df551ffa87b2	d032524e-10df-417f-b51a-6966d46cb502	725322db-77dd-4f6f-aab4-b53726e25752	stand	18	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
e311d596-8d5e-4f20-97bd-1f0795f6741a	aae69106-90e2-4803-a4f5-6a7841f6ce34	c7c8affc-dcdb-4aff-a939-fa66fc08bebf	sit	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
7c833fad-ed16-4802-b148-1b5a30b937e4	aae69106-90e2-4803-a4f5-6a7841f6ce34	8428a6d4-1a1b-4692-bea3-a577dfa6a811	sit	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
0b24483a-575c-4818-8f9b-6dace1d3dbd8	aae69106-90e2-4803-a4f5-6a7841f6ce34	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	sit	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
4e0cdaf8-0530-408d-8004-da9bc9beea25	aae69106-90e2-4803-a4f5-6a7841f6ce34	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	sit	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
c572dc49-95e0-45b4-a988-9711d4a1453c	aae69106-90e2-4803-a4f5-6a7841f6ce34	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	sit	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
e7ba6f3b-96dc-46ba-a1ec-20c61c95b36e	aae69106-90e2-4803-a4f5-6a7841f6ce34	f2398444-bbe5-4642-8320-981250a60830	sit	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
45320253-49f9-4723-8d9d-cb79b7d5d726	aae69106-90e2-4803-a4f5-6a7841f6ce34	d036485a-87a4-4399-b5f3-b5f617d679b9	sit	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
b109a500-5400-4d94-b4bd-f78188ec83e2	aae69106-90e2-4803-a4f5-6a7841f6ce34	70a2edb9-cb34-4cbe-ad6a-683114cc77e7	sit	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
4dbf73d7-d097-48d3-b452-49f18818fd22	aae69106-90e2-4803-a4f5-6a7841f6ce34	50b7bc06-2f6c-4ee7-9183-f9ec1eae7d40	sit	9	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
bfbf69af-1f3e-48ac-9709-3207e2cdcc43	aae69106-90e2-4803-a4f5-6a7841f6ce34	8f6c1c2f-0d36-41c0-be60-d4de938e81f8	sit	10	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
5dc8f23e-4559-4173-8e5e-e84d7ac5e4f5	aae69106-90e2-4803-a4f5-6a7841f6ce34	c7c8affc-dcdb-4aff-a939-fa66fc08bebf	stand	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
72fb5cf6-5b1e-464d-8a79-b8fd3c3237f0	aae69106-90e2-4803-a4f5-6a7841f6ce34	8428a6d4-1a1b-4692-bea3-a577dfa6a811	stand	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
ff2b3797-f733-4344-9325-259a174be8fe	aae69106-90e2-4803-a4f5-6a7841f6ce34	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	stand	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
df3c857e-5393-4026-bf22-8ba8f8b56eee	aae69106-90e2-4803-a4f5-6a7841f6ce34	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	stand	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
de2b0284-503d-469a-be9f-3662226f796d	aae69106-90e2-4803-a4f5-6a7841f6ce34	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	stand	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
e8e002aa-5631-4a9a-bcb4-9e2af6b7d929	aae69106-90e2-4803-a4f5-6a7841f6ce34	f2398444-bbe5-4642-8320-981250a60830	stand	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
9588aa07-7b71-473a-93a6-1787842283d8	aae69106-90e2-4803-a4f5-6a7841f6ce34	4574f322-2ac5-4ba4-b422-9d71fbf39408	stand	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
50858efd-e2cc-45b5-b4fc-74af8d541d0e	aae69106-90e2-4803-a4f5-6a7841f6ce34	4af59389-3f46-49b1-8783-d4816706d02b	stand	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
1f80dc01-f155-495b-99ce-9c5839eb0517	aae69106-90e2-4803-a4f5-6a7841f6ce34	b438a3a2-bc18-449d-8ba7-08bf1690a3e2	stand	9	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
6b22a2c6-7237-4c9e-8a1c-baccc361ff37	aae69106-90e2-4803-a4f5-6a7841f6ce34	ba1c2a86-1612-44e6-aee8-d80be806d487	stand	10	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
84e4c3c3-9d67-4c2b-aa57-1f0b6b2a5619	aae69106-90e2-4803-a4f5-6a7841f6ce34	ff9be11c-43c3-4383-ba31-94fab9fcd453	stand	11	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
96ec10b6-7c0d-45cb-8b62-60d8132b2de4	aae69106-90e2-4803-a4f5-6a7841f6ce34	4b77ac6b-96d8-43cc-8128-806471103cb3	stand	12	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
2fd79683-d151-4d63-be41-0953123e26fb	aae69106-90e2-4803-a4f5-6a7841f6ce34	18f544bf-7ea0-46f3-b699-0df77d345ebe	stand	13	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
60254152-9c55-4d6a-87a2-754f5c4976de	aae69106-90e2-4803-a4f5-6a7841f6ce34	6b794bbb-4265-4785-8402-0c686cc0e1ca	stand	14	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
57e897a8-f3a1-4150-9929-93e0f44386b0	aae69106-90e2-4803-a4f5-6a7841f6ce34	db2f510f-b6de-48fd-942e-2fd9fa41d7b3	stand	15	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
26b1d6e1-49d0-4246-95ef-d68da8979e86	aae69106-90e2-4803-a4f5-6a7841f6ce34	42b48539-518c-41ea-8381-d3b5b07f27b6	stand	16	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
7d96c7a2-46a0-4cf7-8687-cabbaa8025f4	aae69106-90e2-4803-a4f5-6a7841f6ce34	51f3d882-7ac7-44e8-8253-7764916ce2f4	stand	17	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
05f7d078-54a6-4a27-8ccf-e38b659523a2	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	8428a6d4-1a1b-4692-bea3-a577dfa6a811	sit	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
4af7e11d-1a7d-4d2d-a5a6-be69132bd78c	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	sit	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
81daaff1-5010-4706-b0db-73819bcdf64d	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	sit	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
90f4c979-d8d9-42a5-8278-a6ff4b3ae137	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	sit	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
d5bc33e1-975e-4566-9978-1725912c29a0	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	0b6e7914-54d4-42a0-aec8-05b7c7234872	sit	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
d4eb799c-df0d-4004-9bb1-353c40656850	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	aafde125-051f-4ce0-aaed-bf2e99a97372	sit	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
9a9c99a5-2be9-4bdf-8787-c09f66dcc713	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	27ca566a-bd2e-4d13-a8a3-49eccc0f7bf8	sit	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
5415e862-3b21-4402-97b2-8c58e2ea4f52	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	8428a6d4-1a1b-4692-bea3-a577dfa6a811	stand	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
036a0a12-375c-409e-b077-77ec4d51b881	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	stand	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
998046ea-e43e-41d4-876a-a7e81e84a856	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	stand	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
44c14d73-100d-49f6-9df1-4535036f7602	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	stand	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
a886de16-7b46-414a-a979-1e107bf1079d	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	0b6e7914-54d4-42a0-aec8-05b7c7234872	stand	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
6cbab623-de21-4c2e-a1f7-82f6de067570	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	aafde125-051f-4ce0-aaed-bf2e99a97372	stand	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
3621bedc-15dc-400e-a87b-42fd6fe5d9b5	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	27ca566a-bd2e-4d13-a8a3-49eccc0f7bf8	stand	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
1002a929-5a12-4d27-857c-e49e86a9f9e1	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	9dc772a5-dc6f-4227-a4b5-2a3b7f749346	stand	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
c9ec7f72-7975-4a10-8c41-60aca95750d6	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	d4ac99a4-3ce1-4483-9cb3-d35cbb42c950	stand	9	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
ecb74e17-e89f-4e7b-b58d-96a1805004db	d032524e-10df-417f-b51a-6966d46cb502	c7c8affc-dcdb-4aff-a939-fa66fc08bebf	sit	0	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
1f357b31-dcf5-4970-897d-36b03d9db83f	d032524e-10df-417f-b51a-6966d46cb502	8428a6d4-1a1b-4692-bea3-a577dfa6a811	sit	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
c76d372d-c082-49da-8fe0-f3530ca25b8d	d032524e-10df-417f-b51a-6966d46cb502	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	sit	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
476b6fc0-0e9a-4af1-93a2-b24cc856c883	d032524e-10df-417f-b51a-6966d46cb502	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	sit	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
e645a0b7-8131-437f-b634-3ce2768697a6	d032524e-10df-417f-b51a-6966d46cb502	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	sit	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
7111211d-0a52-4159-aa7d-37ee4102d9cb	d032524e-10df-417f-b51a-6966d46cb502	f2398444-bbe5-4642-8320-981250a60830	sit	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
5869e051-54fb-419a-8679-cf8c25440b75	d032524e-10df-417f-b51a-6966d46cb502	d036485a-87a4-4399-b5f3-b5f617d679b9	sit	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
9abea713-18a3-42be-bedb-32470579c74c	d032524e-10df-417f-b51a-6966d46cb502	70a2edb9-cb34-4cbe-ad6a-683114cc77e7	sit	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
3c575e81-1428-443b-b9e2-b2881cc3bbb7	d032524e-10df-417f-b51a-6966d46cb502	50b7bc06-2f6c-4ee7-9183-f9ec1eae7d40	sit	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
aa7bcf31-a4b9-4418-8818-a5711f7a0057	d032524e-10df-417f-b51a-6966d46cb502	8f6c1c2f-0d36-41c0-be60-d4de938e81f8	sit	9	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
05be61ae-46aa-432c-9aec-f06d8ac42928	d032524e-10df-417f-b51a-6966d46cb502	c7c8affc-dcdb-4aff-a939-fa66fc08bebf	stand	10	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
7270d19d-fcaa-4f56-989b-48315b815a9e	d032524e-10df-417f-b51a-6966d46cb502	8428a6d4-1a1b-4692-bea3-a577dfa6a811	stand	11	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
56774529-68d8-4754-a8e5-a8c4703e989f	d032524e-10df-417f-b51a-6966d46cb502	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	stand	12	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
a0b5868d-0472-4be4-9096-4dc405db247b	d032524e-10df-417f-b51a-6966d46cb502	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	stand	13	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
a40fc887-3a5a-4b28-a0f3-7fd23d26ac96	d032524e-10df-417f-b51a-6966d46cb502	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	stand	14	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
e59ed767-779a-4035-99a8-9ee2209eb3c2	d032524e-10df-417f-b51a-6966d46cb502	f2398444-bbe5-4642-8320-981250a60830	stand	15	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
286a0bf4-019d-4527-8c68-31d231ecbd89	d032524e-10df-417f-b51a-6966d46cb502	4574f322-2ac5-4ba4-b422-9d71fbf39408	stand	16	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
8a6ff104-ccd4-4bd5-aa96-6a1c12982c89	d032524e-10df-417f-b51a-6966d46cb502	4af59389-3f46-49b1-8783-d4816706d02b	stand	17	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
756bf890-7d00-4c25-8985-15c2f0c8d3ff	d032524e-10df-417f-b51a-6966d46cb502	b438a3a2-bc18-449d-8ba7-08bf1690a3e2	stand	18	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
eec454b1-72b0-462b-87f0-7301bd582c35	d032524e-10df-417f-b51a-6966d46cb502	ba1c2a86-1612-44e6-aee8-d80be806d487	stand	19	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
c1d3e775-4f21-4597-b47c-90519541c31f	d032524e-10df-417f-b51a-6966d46cb502	ff9be11c-43c3-4383-ba31-94fab9fcd453	stand	20	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
48184c65-529c-4f27-bb2f-0387833c60c1	d032524e-10df-417f-b51a-6966d46cb502	4b77ac6b-96d8-43cc-8128-806471103cb3	stand	21	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
af6490ab-2da1-48eb-8e6a-46e1a6ebe8a9	d032524e-10df-417f-b51a-6966d46cb502	18f544bf-7ea0-46f3-b699-0df77d345ebe	stand	22	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
\.


--
-- Data for Name: dl_levels; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.dl_levels (id, level_number, name, name_id, description, created_at, updated_at) FROM stdin;
efb79234-424f-4134-af6f-4035e519b6a3	0	Level 0 - Lying	Level 0 - Berbaring	Client is bed-bound or lying down. Minimal movement capacity. Only seated upper-body and basic lower-body exercises.	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
705e4d77-255e-4d43-9900-920b4b596663	1	Level 1 - Sitting	Level 1 - Duduk	Client can sit upright. Seated upper-body exercises with TRX-assisted lower-body movements for stability.	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
275e5594-2a9d-44f0-907c-d7fd8b40a49f	2	Level 2 - Standing	Level 2 - Berdiri	Client can stand. Standing exercises with chair/TRX support for balance and safety.	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
6730b33c-e3e9-4377-aaf8-00de1aff9006	3	Level 3 - Limited Walk	Level 3 - Jalan Terbatas	Client can walk with limitations. Chair-supported exercises with more variety including lunges and lateral movements.	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
484e7eb8-5a8f-4ee0-86eb-92313a0f7938	4	Level 4 - Normal Walk	Level 4 - Jalan Normal	Client walks normally. Introduction of dynamic paired movements (upper + lower simultaneously). Chair support optional.	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
7a412b50-41e7-47ce-a7a1-9fabfd67ff74	5	Level 5 - Full Dynamic	Level 5 - Dynamic Full BPM	Full dynamic training at target BPM. All movements without support, including advanced compound exercises.	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
\.


--
-- Data for Name: dl_menu_items; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.dl_menu_items (id, category_id, level_id, movement_id, body_part, sort_order, created_at, updated_at) FROM stdin;
f4213061-cbef-49fd-bf20-827658f7a373	d032524e-10df-417f-b51a-6966d46cb502	efb79234-424f-4134-af6f-4035e519b6a3	c7c8affc-dcdb-4aff-a939-fa66fc08bebf	upper	0	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
b794546e-f2e4-4ccc-a6ab-a79a5d2dff70	d032524e-10df-417f-b51a-6966d46cb502	efb79234-424f-4134-af6f-4035e519b6a3	8428a6d4-1a1b-4692-bea3-a577dfa6a811	upper	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
aae06ce8-0aa0-4f54-b50e-6992b3b77a97	d032524e-10df-417f-b51a-6966d46cb502	efb79234-424f-4134-af6f-4035e519b6a3	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	upper	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
1a0dfcac-2b44-4770-a148-dcf21fbfd83c	d032524e-10df-417f-b51a-6966d46cb502	efb79234-424f-4134-af6f-4035e519b6a3	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	upper	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
04fbd743-0a1b-4735-a8e5-47c72ea60348	d032524e-10df-417f-b51a-6966d46cb502	efb79234-424f-4134-af6f-4035e519b6a3	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	upper	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
0247d4f8-6888-4f2b-8995-043339d81b98	d032524e-10df-417f-b51a-6966d46cb502	efb79234-424f-4134-af6f-4035e519b6a3	f2398444-bbe5-4642-8320-981250a60830	upper	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
9276d42c-58d6-44b1-aa13-4b7ac5fcf167	d032524e-10df-417f-b51a-6966d46cb502	efb79234-424f-4134-af6f-4035e519b6a3	d036485a-87a4-4399-b5f3-b5f617d679b9	lower	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
812360e3-cdcd-4ac4-84c9-64a01ca916b7	d032524e-10df-417f-b51a-6966d46cb502	705e4d77-255e-4d43-9900-920b4b596663	c7c8affc-dcdb-4aff-a939-fa66fc08bebf	upper	0	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
ebaa68d6-e050-407a-8dd4-61493366b581	d032524e-10df-417f-b51a-6966d46cb502	705e4d77-255e-4d43-9900-920b4b596663	8428a6d4-1a1b-4692-bea3-a577dfa6a811	upper	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
b86aa4fe-7cfd-4e34-86fc-6360e3e29480	d032524e-10df-417f-b51a-6966d46cb502	705e4d77-255e-4d43-9900-920b4b596663	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	upper	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
eaa9e78e-4a85-4c69-b751-4aa89930c0dd	d032524e-10df-417f-b51a-6966d46cb502	705e4d77-255e-4d43-9900-920b4b596663	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	upper	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
78a5565c-16dd-4897-88e5-1333d2e3b5da	d032524e-10df-417f-b51a-6966d46cb502	705e4d77-255e-4d43-9900-920b4b596663	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	upper	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
53ed564f-bc05-446b-b16d-e6534836249d	d032524e-10df-417f-b51a-6966d46cb502	705e4d77-255e-4d43-9900-920b4b596663	f2398444-bbe5-4642-8320-981250a60830	upper	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
c520d23e-aefd-488f-85a6-e3c04926424e	d032524e-10df-417f-b51a-6966d46cb502	705e4d77-255e-4d43-9900-920b4b596663	70a2edb9-cb34-4cbe-ad6a-683114cc77e7	lower	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
dc720066-5ab4-45b9-a203-610c6bdb2247	d032524e-10df-417f-b51a-6966d46cb502	705e4d77-255e-4d43-9900-920b4b596663	50b7bc06-2f6c-4ee7-9183-f9ec1eae7d40	lower	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
e34d6d1b-018a-4bc2-9def-c3e63bf4f58a	d032524e-10df-417f-b51a-6966d46cb502	705e4d77-255e-4d43-9900-920b4b596663	8f6c1c2f-0d36-41c0-be60-d4de938e81f8	lower	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
3927442b-e1f0-46d0-9214-e630ff20750c	d032524e-10df-417f-b51a-6966d46cb502	705e4d77-255e-4d43-9900-920b4b596663	d036485a-87a4-4399-b5f3-b5f617d679b9	lower	9	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
0e433691-1886-41d4-94fc-36a55c739454	d032524e-10df-417f-b51a-6966d46cb502	275e5594-2a9d-44f0-907c-d7fd8b40a49f	c7c8affc-dcdb-4aff-a939-fa66fc08bebf	upper	0	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
6d7da00d-37e3-4172-bb74-09eceb30fd52	d032524e-10df-417f-b51a-6966d46cb502	275e5594-2a9d-44f0-907c-d7fd8b40a49f	8428a6d4-1a1b-4692-bea3-a577dfa6a811	upper	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
f2a8168d-3702-4d93-a334-c2e4c9b0862c	d032524e-10df-417f-b51a-6966d46cb502	275e5594-2a9d-44f0-907c-d7fd8b40a49f	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	upper	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
fae291e8-d512-41d0-8349-392d3f88afa2	d032524e-10df-417f-b51a-6966d46cb502	275e5594-2a9d-44f0-907c-d7fd8b40a49f	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	upper	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
c703822b-001d-4e37-8f30-2f2753e40e6b	d032524e-10df-417f-b51a-6966d46cb502	275e5594-2a9d-44f0-907c-d7fd8b40a49f	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	upper	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
ebe7858e-5c65-4e1a-b1b6-a674934b4727	d032524e-10df-417f-b51a-6966d46cb502	275e5594-2a9d-44f0-907c-d7fd8b40a49f	f2398444-bbe5-4642-8320-981250a60830	upper	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
8c2717c3-2353-4ee6-85aa-6e34243e7ef8	d032524e-10df-417f-b51a-6966d46cb502	275e5594-2a9d-44f0-907c-d7fd8b40a49f	4574f322-2ac5-4ba4-b422-9d71fbf39408	lower	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
872c966b-f214-427c-8169-fba5e6cd7c52	d032524e-10df-417f-b51a-6966d46cb502	275e5594-2a9d-44f0-907c-d7fd8b40a49f	4af59389-3f46-49b1-8783-d4816706d02b	lower	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
0b796792-2db4-4634-b44c-3226e3c140a0	d032524e-10df-417f-b51a-6966d46cb502	275e5594-2a9d-44f0-907c-d7fd8b40a49f	b438a3a2-bc18-449d-8ba7-08bf1690a3e2	lower	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
84773a7a-a7c8-43fa-8b31-9ef604699b4f	d032524e-10df-417f-b51a-6966d46cb502	275e5594-2a9d-44f0-907c-d7fd8b40a49f	ba1c2a86-1612-44e6-aee8-d80be806d487	lower	9	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
dbd97829-2661-4edb-a7f7-7bd8cebc227a	d032524e-10df-417f-b51a-6966d46cb502	275e5594-2a9d-44f0-907c-d7fd8b40a49f	ff9be11c-43c3-4383-ba31-94fab9fcd453	lower	10	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
3150c007-b4a2-4f9f-b3d0-1c5637fa9c31	d032524e-10df-417f-b51a-6966d46cb502	275e5594-2a9d-44f0-907c-d7fd8b40a49f	4b77ac6b-96d8-43cc-8128-806471103cb3	lower	11	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
390aa91e-153f-457d-b2d5-44605a827f94	d032524e-10df-417f-b51a-6966d46cb502	275e5594-2a9d-44f0-907c-d7fd8b40a49f	18f544bf-7ea0-46f3-b699-0df77d345ebe	lower	12	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
2b98b3a2-708f-44a3-abbd-c6eab38827b8	d032524e-10df-417f-b51a-6966d46cb502	275e5594-2a9d-44f0-907c-d7fd8b40a49f	6b794bbb-4265-4785-8402-0c686cc0e1ca	lower	13	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
9b924165-7661-44bf-943a-942107b1afd7	d032524e-10df-417f-b51a-6966d46cb502	275e5594-2a9d-44f0-907c-d7fd8b40a49f	db2f510f-b6de-48fd-942e-2fd9fa41d7b3	lower	14	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
9dbd4555-4089-491f-bdf2-f993c7a56de5	d032524e-10df-417f-b51a-6966d46cb502	275e5594-2a9d-44f0-907c-d7fd8b40a49f	42b48539-518c-41ea-8381-d3b5b07f27b6	lower	15	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
47f8c12e-b1b1-4ca2-9674-9c910f1e5f7e	d032524e-10df-417f-b51a-6966d46cb502	6730b33c-e3e9-4377-aaf8-00de1aff9006	c7c8affc-dcdb-4aff-a939-fa66fc08bebf	upper	0	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
cc92ade2-d0ae-41e2-9a7f-a8531162ac72	d032524e-10df-417f-b51a-6966d46cb502	6730b33c-e3e9-4377-aaf8-00de1aff9006	8428a6d4-1a1b-4692-bea3-a577dfa6a811	upper	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
221b594f-775c-456e-8c1c-9319f54de151	d032524e-10df-417f-b51a-6966d46cb502	6730b33c-e3e9-4377-aaf8-00de1aff9006	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	upper	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
e030e83a-01c6-4922-801d-e5cf55aa43d0	d032524e-10df-417f-b51a-6966d46cb502	6730b33c-e3e9-4377-aaf8-00de1aff9006	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	upper	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
3f77479a-6ea0-4f38-86a8-9e05edc682ad	d032524e-10df-417f-b51a-6966d46cb502	6730b33c-e3e9-4377-aaf8-00de1aff9006	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	upper	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
94d6e93f-02cc-4964-a72b-a76c8eef1b5f	d032524e-10df-417f-b51a-6966d46cb502	6730b33c-e3e9-4377-aaf8-00de1aff9006	f2398444-bbe5-4642-8320-981250a60830	upper	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
3604e1ee-b90a-43c2-b78b-44ea688ac263	d032524e-10df-417f-b51a-6966d46cb502	6730b33c-e3e9-4377-aaf8-00de1aff9006	4574f322-2ac5-4ba4-b422-9d71fbf39408	lower	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
fdca5e9e-5e41-497d-82f1-8dbfc49c41e1	d032524e-10df-417f-b51a-6966d46cb502	6730b33c-e3e9-4377-aaf8-00de1aff9006	4af59389-3f46-49b1-8783-d4816706d02b	lower	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
a4d6e5b6-75c2-4558-ac8f-9361d9b6d43a	d032524e-10df-417f-b51a-6966d46cb502	6730b33c-e3e9-4377-aaf8-00de1aff9006	b438a3a2-bc18-449d-8ba7-08bf1690a3e2	lower	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
edfa48dc-f274-4bf2-8c7c-8433f1246650	d032524e-10df-417f-b51a-6966d46cb502	6730b33c-e3e9-4377-aaf8-00de1aff9006	ba1c2a86-1612-44e6-aee8-d80be806d487	lower	9	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
fd212ec4-9e33-428e-993f-6d8f456701ff	d032524e-10df-417f-b51a-6966d46cb502	6730b33c-e3e9-4377-aaf8-00de1aff9006	ff9be11c-43c3-4383-ba31-94fab9fcd453	lower	10	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
6af8c33b-d0fb-482e-b011-a316ddb28fb2	d032524e-10df-417f-b51a-6966d46cb502	6730b33c-e3e9-4377-aaf8-00de1aff9006	4b77ac6b-96d8-43cc-8128-806471103cb3	lower	11	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
76279fe3-c915-43f8-85a7-238070535a97	d032524e-10df-417f-b51a-6966d46cb502	6730b33c-e3e9-4377-aaf8-00de1aff9006	18f544bf-7ea0-46f3-b699-0df77d345ebe	lower	12	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
19793cb0-eeaa-4a0d-93e2-30b3a940270b	d032524e-10df-417f-b51a-6966d46cb502	6730b33c-e3e9-4377-aaf8-00de1aff9006	6b794bbb-4265-4785-8402-0c686cc0e1ca	lower	13	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
c0a8b0ed-90e1-4e0a-9f09-89c0fadafe2c	d032524e-10df-417f-b51a-6966d46cb502	6730b33c-e3e9-4377-aaf8-00de1aff9006	db2f510f-b6de-48fd-942e-2fd9fa41d7b3	lower	14	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
7825bc63-7d05-4882-85bc-f496e2227bd3	d032524e-10df-417f-b51a-6966d46cb502	6730b33c-e3e9-4377-aaf8-00de1aff9006	42b48539-518c-41ea-8381-d3b5b07f27b6	lower	15	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
7fcb229b-7fa6-4e93-9c1a-1b7fec719abb	d032524e-10df-417f-b51a-6966d46cb502	6730b33c-e3e9-4377-aaf8-00de1aff9006	51f3d882-7ac7-44e8-8253-7764916ce2f4	lower	16	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
de29391e-295e-46b7-aef8-374cf65eaa03	d032524e-10df-417f-b51a-6966d46cb502	6730b33c-e3e9-4377-aaf8-00de1aff9006	725322db-77dd-4f6f-aab4-b53726e25752	lower	17	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
7c6c3944-0a12-4fda-a880-7315479bb5df	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	c7c8affc-dcdb-4aff-a939-fa66fc08bebf	upper	0	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
44a257ff-f22e-4339-b23a-0c067663ed3c	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	d6e261d0-faf1-45f5-912c-0cd831b7522e	upper	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
9ecd7a73-630f-4830-9948-987301ecfc74	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	8428a6d4-1a1b-4692-bea3-a577dfa6a811	upper	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
c7ae6c5a-2271-4a34-84e3-b8b1bbf528ee	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	upper	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
08000e95-fa96-4766-8b86-e40a8f650fb5	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	upper	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
b08a3fb1-38c9-4e47-b45d-012986828619	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	upper	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
dbb13d78-8a47-43d2-96c9-5c1224a92aff	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	f2398444-bbe5-4642-8320-981250a60830	upper	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
974cf97c-f520-4ab6-8ddd-f62ccbc9b54b	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	e3cdfd81-2ea1-4841-b959-010c0de70cfa	upper	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
afa5c678-5e8b-4c8d-93d8-51bdbc1583e1	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	aafde125-051f-4ce0-aaed-bf2e99a97372	upper	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
986e7892-8421-48fb-9c0b-7fda1e13ebc3	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	cfc843cd-d86d-45c5-b973-3115f382c168	upper	9	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
a0cc996f-9047-4799-91d2-3bb01632a262	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	c9a344b5-3874-4b87-9e26-74dc9fe2e5cd	lower	10	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
c658f78f-3391-41ff-9358-4ebfac444a48	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	1b29430e-2226-4bb6-8a3e-2e1e87e948bb	lower	11	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
2b85964c-5179-43c2-9cef-83677cd186d4	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	7ea08c97-c22e-4839-b097-d6b50633f91a	lower	12	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
4d5d84c2-7206-48e7-aba8-57680f86be87	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	9dc772a5-dc6f-4227-a4b5-2a3b7f749346	lower	13	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
1fbcba83-644b-40fc-bbf6-6326dc1e7b26	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	63a6a666-a584-4d06-9d50-123f8416d5fa	lower	14	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
640c963e-7d05-4514-95c6-94de45bb8f59	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	db796cdf-63d0-48eb-9fdb-3606f9193979	lower	15	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
145d4faf-dbad-43a0-b7f3-dde5cfeab4b6	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	c4556c38-bdaa-46f6-a028-34bfa47d1b03	lower	16	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
5697146c-c812-4458-ab08-b1775cc3eb9b	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	05defb2e-fb85-45b2-95f8-3599770e5e91	lower	17	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
e7b85776-3056-4725-a47a-5bfcf2ea4859	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	3c80c5d3-045c-49f2-93eb-5bf137808878	lower	18	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
768c4881-eab9-45b0-94e2-77d504c9fb37	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	9935cb34-904b-4213-9143-0b27365fee6b	lower	19	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
b9aa517a-04c1-4233-a377-881682a3ae8f	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	87857153-fc40-495f-aeec-c0dfe041a736	lower	20	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
fa361744-bba5-42ff-98bd-c22886e2b21d	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	51f3d882-7ac7-44e8-8253-7764916ce2f4	lower	21	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
dcd242aa-3f13-4b11-9d60-f2aec4b053d8	d032524e-10df-417f-b51a-6966d46cb502	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	15d5324e-f356-4b97-b49e-8151578dff23	lower	22	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
35bf5e97-5ebc-43f6-97ef-ec26fde45728	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	c7c8affc-dcdb-4aff-a939-fa66fc08bebf	upper	0	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
dbe1f350-9175-45f2-bdca-83b1023689c8	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	d6e261d0-faf1-45f5-912c-0cd831b7522e	upper	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
e101ac1c-1d06-45f2-a7a6-f2d9fcd5f72b	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	8428a6d4-1a1b-4692-bea3-a577dfa6a811	upper	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
f4ada4dd-dc68-45ef-a79f-29b50c1b69e1	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	upper	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
6845fcd4-e2ce-4731-a7f7-4aad96f4e7bc	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	upper	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
4c11044f-5d9c-46ec-bf5d-386466fc5a4f	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	upper	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
6832ec6d-32b4-4583-b59d-a970275815f9	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	f2398444-bbe5-4642-8320-981250a60830	upper	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
54ea1410-7f3c-481c-8d73-cf748fb0c8cd	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	e3cdfd81-2ea1-4841-b959-010c0de70cfa	upper	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
77ea06e2-bf0b-47cb-95ee-cea79f9cd614	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	aafde125-051f-4ce0-aaed-bf2e99a97372	upper	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
e1dd381b-5f0f-4efe-a926-adbb83318264	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	cfc843cd-d86d-45c5-b973-3115f382c168	upper	9	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
33258532-5f98-4703-b41d-db161d7f3f29	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	c9a344b5-3874-4b87-9e26-74dc9fe2e5cd	lower	10	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
f21b5a9e-04c8-4287-a436-5f76232446c6	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	1b29430e-2226-4bb6-8a3e-2e1e87e948bb	lower	11	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
ede35b9c-0086-40d6-a0a2-f9d7e594d787	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	7ea08c97-c22e-4839-b097-d6b50633f91a	lower	12	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
15755c8a-5906-405e-a201-48f2af4b9367	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	9dc772a5-dc6f-4227-a4b5-2a3b7f749346	lower	13	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
4d042fd9-5dd1-433f-8078-ffb63cfa72c3	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	63a6a666-a584-4d06-9d50-123f8416d5fa	lower	14	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
f6cf2f59-4d05-4721-93d3-5434ab2cb937	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	db796cdf-63d0-48eb-9fdb-3606f9193979	lower	15	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
7fb6d58e-0276-4d36-a832-6764622ff755	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	c4556c38-bdaa-46f6-a028-34bfa47d1b03	lower	16	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
d92d46e3-addf-48d1-9e5c-2dd17a869361	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	85b1b505-0ef3-4982-b046-4fbe098c7fe4	lower	17	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
58128885-9f27-4e69-95bb-a901dec8b392	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	3c80c5d3-045c-49f2-93eb-5bf137808878	lower	18	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
bf796e50-099e-4da0-8c28-ec549f7c0f25	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	f142aa48-3c52-4818-b4e4-863e1ef6e0e3	lower	19	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
d7e61b5b-ce29-4d47-a9d4-eb5145f459f7	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	ac2557b4-8e09-4195-a6f1-eac7105975a4	lower	20	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
69c5f255-cb76-4303-9efc-232fb241605d	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	4b6d2e84-9a13-4bfb-9605-9b754440f9d2	lower	21	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
060e2994-b6aa-45c8-99b9-f8fcb0bd9bd3	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	894ca941-f68d-4938-9b9c-679871952f5d	lower	22	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
13b6ef72-c7b3-42f5-b985-2bce27362125	d032524e-10df-417f-b51a-6966d46cb502	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	0eba8dcf-fb6d-4250-95ab-9e4f61d757b7	lower	23	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
d99498f8-8972-4017-a605-aa1f811146c2	aae69106-90e2-4803-a4f5-6a7841f6ce34	efb79234-424f-4134-af6f-4035e519b6a3	c7c8affc-dcdb-4aff-a939-fa66fc08bebf	upper	0	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
2255281b-2ba0-4c35-8bb3-1678d587dd0d	aae69106-90e2-4803-a4f5-6a7841f6ce34	efb79234-424f-4134-af6f-4035e519b6a3	8428a6d4-1a1b-4692-bea3-a577dfa6a811	upper	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
ed5d4b7a-268e-491d-ac04-0d24c722eaa7	aae69106-90e2-4803-a4f5-6a7841f6ce34	efb79234-424f-4134-af6f-4035e519b6a3	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	upper	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
0dd50905-ea8c-4215-b825-01b1cedc532c	aae69106-90e2-4803-a4f5-6a7841f6ce34	efb79234-424f-4134-af6f-4035e519b6a3	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	upper	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
cec43fb6-b229-44a9-98fd-06a3b578c0df	aae69106-90e2-4803-a4f5-6a7841f6ce34	efb79234-424f-4134-af6f-4035e519b6a3	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	upper	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
d93c0be9-353a-45b5-bd44-5408e51cd3da	aae69106-90e2-4803-a4f5-6a7841f6ce34	efb79234-424f-4134-af6f-4035e519b6a3	f2398444-bbe5-4642-8320-981250a60830	upper	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
41ac6c76-1413-4f8b-a5b0-b1dbaf0f7604	aae69106-90e2-4803-a4f5-6a7841f6ce34	efb79234-424f-4134-af6f-4035e519b6a3	d036485a-87a4-4399-b5f3-b5f617d679b9	lower	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
9de24f28-8949-4b98-b8c8-5ecb21f22abb	aae69106-90e2-4803-a4f5-6a7841f6ce34	705e4d77-255e-4d43-9900-920b4b596663	c7c8affc-dcdb-4aff-a939-fa66fc08bebf	upper	0	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
30ad1714-83e1-4d90-bf3c-778fc928afbb	aae69106-90e2-4803-a4f5-6a7841f6ce34	705e4d77-255e-4d43-9900-920b4b596663	8428a6d4-1a1b-4692-bea3-a577dfa6a811	upper	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
92905251-6f75-4dc1-9d7c-40064489c18b	aae69106-90e2-4803-a4f5-6a7841f6ce34	705e4d77-255e-4d43-9900-920b4b596663	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	upper	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
3179c246-385f-41d1-ab07-3567cd51325e	aae69106-90e2-4803-a4f5-6a7841f6ce34	705e4d77-255e-4d43-9900-920b4b596663	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	upper	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
15371e3b-f7fa-4bf6-a3f9-7292c3b81e65	aae69106-90e2-4803-a4f5-6a7841f6ce34	705e4d77-255e-4d43-9900-920b4b596663	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	upper	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
22ae4446-b02d-4dac-a348-c952b70f3967	aae69106-90e2-4803-a4f5-6a7841f6ce34	705e4d77-255e-4d43-9900-920b4b596663	f2398444-bbe5-4642-8320-981250a60830	upper	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
ec34439f-62f9-450d-b833-112df3da2bf4	aae69106-90e2-4803-a4f5-6a7841f6ce34	705e4d77-255e-4d43-9900-920b4b596663	70a2edb9-cb34-4cbe-ad6a-683114cc77e7	lower	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
9dec8232-d004-4af5-924c-83f4cc7f3d66	aae69106-90e2-4803-a4f5-6a7841f6ce34	705e4d77-255e-4d43-9900-920b4b596663	50b7bc06-2f6c-4ee7-9183-f9ec1eae7d40	lower	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
639f5615-3139-4052-88b7-865ea7b63a57	aae69106-90e2-4803-a4f5-6a7841f6ce34	705e4d77-255e-4d43-9900-920b4b596663	8f6c1c2f-0d36-41c0-be60-d4de938e81f8	lower	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
26117576-f220-49a5-8987-3a6437a94286	aae69106-90e2-4803-a4f5-6a7841f6ce34	705e4d77-255e-4d43-9900-920b4b596663	d036485a-87a4-4399-b5f3-b5f617d679b9	lower	9	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
b371d80d-e611-4939-a955-7c047f54c123	aae69106-90e2-4803-a4f5-6a7841f6ce34	275e5594-2a9d-44f0-907c-d7fd8b40a49f	c7c8affc-dcdb-4aff-a939-fa66fc08bebf	upper	0	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
c2ffa23b-241a-4630-8e90-d4c5536c7a20	aae69106-90e2-4803-a4f5-6a7841f6ce34	275e5594-2a9d-44f0-907c-d7fd8b40a49f	8428a6d4-1a1b-4692-bea3-a577dfa6a811	upper	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
1b5e1c0b-7cff-49d3-9e6a-b6bbb0c8abdf	aae69106-90e2-4803-a4f5-6a7841f6ce34	275e5594-2a9d-44f0-907c-d7fd8b40a49f	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	upper	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
e78022b5-6411-42b1-9e5a-ccfcbefd80a7	aae69106-90e2-4803-a4f5-6a7841f6ce34	275e5594-2a9d-44f0-907c-d7fd8b40a49f	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	upper	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
cde93191-1ded-4792-a426-2166b2b580f9	aae69106-90e2-4803-a4f5-6a7841f6ce34	275e5594-2a9d-44f0-907c-d7fd8b40a49f	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	upper	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
8925c230-015f-4d05-a757-5babea2d925f	aae69106-90e2-4803-a4f5-6a7841f6ce34	275e5594-2a9d-44f0-907c-d7fd8b40a49f	f2398444-bbe5-4642-8320-981250a60830	upper	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
f52f45e8-e730-4499-9391-66dead4dc3f8	aae69106-90e2-4803-a4f5-6a7841f6ce34	275e5594-2a9d-44f0-907c-d7fd8b40a49f	4574f322-2ac5-4ba4-b422-9d71fbf39408	lower	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
61477853-37cf-47e9-9a11-5dd940092fa1	aae69106-90e2-4803-a4f5-6a7841f6ce34	275e5594-2a9d-44f0-907c-d7fd8b40a49f	4af59389-3f46-49b1-8783-d4816706d02b	lower	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
4652a6d8-8810-4c61-af1b-f71e2cc8fa60	aae69106-90e2-4803-a4f5-6a7841f6ce34	275e5594-2a9d-44f0-907c-d7fd8b40a49f	b438a3a2-bc18-449d-8ba7-08bf1690a3e2	lower	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
9210013f-1fed-4fdd-9148-f203af0a196d	aae69106-90e2-4803-a4f5-6a7841f6ce34	275e5594-2a9d-44f0-907c-d7fd8b40a49f	ba1c2a86-1612-44e6-aee8-d80be806d487	lower	9	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
870737eb-6b59-4bc8-b2f0-0073e583fd2b	aae69106-90e2-4803-a4f5-6a7841f6ce34	275e5594-2a9d-44f0-907c-d7fd8b40a49f	ff9be11c-43c3-4383-ba31-94fab9fcd453	lower	10	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
7f3a2cc0-a26d-4dfd-ba33-9b71189568b5	aae69106-90e2-4803-a4f5-6a7841f6ce34	275e5594-2a9d-44f0-907c-d7fd8b40a49f	4b77ac6b-96d8-43cc-8128-806471103cb3	lower	11	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
29cd2153-6c27-4d60-83d6-59bb068955c3	aae69106-90e2-4803-a4f5-6a7841f6ce34	275e5594-2a9d-44f0-907c-d7fd8b40a49f	18f544bf-7ea0-46f3-b699-0df77d345ebe	lower	12	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
1be355c1-4b03-46a7-940f-b320cc791c37	aae69106-90e2-4803-a4f5-6a7841f6ce34	275e5594-2a9d-44f0-907c-d7fd8b40a49f	6b794bbb-4265-4785-8402-0c686cc0e1ca	lower	13	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
cdb4e2f9-8cd2-49c7-88fc-00dd9cac9943	aae69106-90e2-4803-a4f5-6a7841f6ce34	275e5594-2a9d-44f0-907c-d7fd8b40a49f	db2f510f-b6de-48fd-942e-2fd9fa41d7b3	lower	14	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
6a624699-8c33-45aa-b49c-673ceeeadee2	aae69106-90e2-4803-a4f5-6a7841f6ce34	275e5594-2a9d-44f0-907c-d7fd8b40a49f	42b48539-518c-41ea-8381-d3b5b07f27b6	lower	15	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
f89a8055-ec52-42b0-b03c-79de6228444e	aae69106-90e2-4803-a4f5-6a7841f6ce34	6730b33c-e3e9-4377-aaf8-00de1aff9006	c7c8affc-dcdb-4aff-a939-fa66fc08bebf	upper	0	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
352e5ef5-d49e-4950-a6ce-98f652268ba6	aae69106-90e2-4803-a4f5-6a7841f6ce34	6730b33c-e3e9-4377-aaf8-00de1aff9006	8428a6d4-1a1b-4692-bea3-a577dfa6a811	upper	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
4dd8612f-f4fc-4521-843a-6543fba11f21	aae69106-90e2-4803-a4f5-6a7841f6ce34	6730b33c-e3e9-4377-aaf8-00de1aff9006	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	upper	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
aa666eb4-c3f5-40e3-99f4-1c96d2a8ba02	aae69106-90e2-4803-a4f5-6a7841f6ce34	6730b33c-e3e9-4377-aaf8-00de1aff9006	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	upper	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
9dbe2043-bbb3-440b-bb97-8f47f28e246a	aae69106-90e2-4803-a4f5-6a7841f6ce34	6730b33c-e3e9-4377-aaf8-00de1aff9006	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	upper	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
d5196afc-f54e-4a4c-b526-dcac9d1305d5	aae69106-90e2-4803-a4f5-6a7841f6ce34	6730b33c-e3e9-4377-aaf8-00de1aff9006	f2398444-bbe5-4642-8320-981250a60830	upper	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
7944c2d9-80fc-42d9-a1f8-45df816e2fb4	aae69106-90e2-4803-a4f5-6a7841f6ce34	6730b33c-e3e9-4377-aaf8-00de1aff9006	4574f322-2ac5-4ba4-b422-9d71fbf39408	lower	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
7dbf63ab-07b0-4faa-8147-f72f486ab942	aae69106-90e2-4803-a4f5-6a7841f6ce34	6730b33c-e3e9-4377-aaf8-00de1aff9006	4af59389-3f46-49b1-8783-d4816706d02b	lower	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
0dc907b3-5420-42a0-851a-055e810e229b	aae69106-90e2-4803-a4f5-6a7841f6ce34	6730b33c-e3e9-4377-aaf8-00de1aff9006	b438a3a2-bc18-449d-8ba7-08bf1690a3e2	lower	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
bc9b9d7a-b32f-4f32-ac6c-6071efa655f5	aae69106-90e2-4803-a4f5-6a7841f6ce34	6730b33c-e3e9-4377-aaf8-00de1aff9006	ba1c2a86-1612-44e6-aee8-d80be806d487	lower	9	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
21133fb1-09db-437a-8d9b-5a4475625943	aae69106-90e2-4803-a4f5-6a7841f6ce34	6730b33c-e3e9-4377-aaf8-00de1aff9006	ff9be11c-43c3-4383-ba31-94fab9fcd453	lower	10	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
02a38b0d-f553-4423-bdea-a2c91c376c62	aae69106-90e2-4803-a4f5-6a7841f6ce34	6730b33c-e3e9-4377-aaf8-00de1aff9006	4b77ac6b-96d8-43cc-8128-806471103cb3	lower	11	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
7700ac83-bf93-4cde-adc5-af6fbd720c26	aae69106-90e2-4803-a4f5-6a7841f6ce34	6730b33c-e3e9-4377-aaf8-00de1aff9006	18f544bf-7ea0-46f3-b699-0df77d345ebe	lower	12	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
3022f94b-9664-4548-95c1-fb33e8bbe689	aae69106-90e2-4803-a4f5-6a7841f6ce34	6730b33c-e3e9-4377-aaf8-00de1aff9006	6b794bbb-4265-4785-8402-0c686cc0e1ca	lower	13	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
b96c01aa-6ccd-4730-85cc-3142ef2450ca	aae69106-90e2-4803-a4f5-6a7841f6ce34	6730b33c-e3e9-4377-aaf8-00de1aff9006	db2f510f-b6de-48fd-942e-2fd9fa41d7b3	lower	14	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
21fbc85e-bb2a-4e59-a72d-9138b927cd4d	aae69106-90e2-4803-a4f5-6a7841f6ce34	6730b33c-e3e9-4377-aaf8-00de1aff9006	42b48539-518c-41ea-8381-d3b5b07f27b6	lower	15	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
8d1c8726-8d8a-4513-8d41-d535e8575bde	aae69106-90e2-4803-a4f5-6a7841f6ce34	6730b33c-e3e9-4377-aaf8-00de1aff9006	51f3d882-7ac7-44e8-8253-7764916ce2f4	lower	16	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
c3ea9c91-640d-4563-9ff3-2131d726daad	aae69106-90e2-4803-a4f5-6a7841f6ce34	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	c7c8affc-dcdb-4aff-a939-fa66fc08bebf	upper	0	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
414aa16a-5a8f-4915-9799-0153de65ab16	aae69106-90e2-4803-a4f5-6a7841f6ce34	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	8428a6d4-1a1b-4692-bea3-a577dfa6a811	upper	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
38f9fc11-98c2-45b1-800b-65e8d7e0b294	aae69106-90e2-4803-a4f5-6a7841f6ce34	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	upper	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
5424d346-e1eb-4833-b6d8-3924af48dbf3	aae69106-90e2-4803-a4f5-6a7841f6ce34	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	9139bf83-aa03-46bd-b796-129f11f78d06	upper	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
d543d02b-0b7d-4c9f-83e8-3a59e405c2a8	aae69106-90e2-4803-a4f5-6a7841f6ce34	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	upper	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
a6fe2320-147f-460b-a656-3492fb713bd3	aae69106-90e2-4803-a4f5-6a7841f6ce34	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	f2398444-bbe5-4642-8320-981250a60830	upper	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
c81312c5-9379-45c7-9e5e-26f7d12ff915	aae69106-90e2-4803-a4f5-6a7841f6ce34	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	aafde125-051f-4ce0-aaed-bf2e99a97372	upper	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
12dbeaf6-2fe6-4145-99c4-7cd5a3dbb642	aae69106-90e2-4803-a4f5-6a7841f6ce34	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	upper	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
c9e0fba7-ddbc-4558-8d9d-e56b8b01f816	aae69106-90e2-4803-a4f5-6a7841f6ce34	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	d6e261d0-faf1-45f5-912c-0cd831b7522e	upper	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
01371e75-2d4b-4cb3-8e22-3419652479fc	aae69106-90e2-4803-a4f5-6a7841f6ce34	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	e3cdfd81-2ea1-4841-b959-010c0de70cfa	upper	9	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
89c61bf5-e1b2-4004-beed-f53a0adbf3a5	aae69106-90e2-4803-a4f5-6a7841f6ce34	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	cfc843cd-d86d-45c5-b973-3115f382c168	upper	10	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
bf5dfa95-69bf-4047-81f3-00fb1034b380	aae69106-90e2-4803-a4f5-6a7841f6ce34	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	c9a344b5-3874-4b87-9e26-74dc9fe2e5cd	lower	11	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
025674b7-8f64-483c-8c82-74064eef31f8	aae69106-90e2-4803-a4f5-6a7841f6ce34	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	c840bc04-8c76-402d-bc8d-73346d736c06	lower	12	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
60efead6-89b2-453a-bf70-c1dd3ea6229a	aae69106-90e2-4803-a4f5-6a7841f6ce34	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	833089c8-da19-43e4-a612-fbff2c1f101c	lower	13	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
b0404ac9-8b50-4d22-9167-336c094c37da	aae69106-90e2-4803-a4f5-6a7841f6ce34	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	1b29430e-2226-4bb6-8a3e-2e1e87e948bb	lower	14	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
b898350c-202b-4b78-8db9-28d72cb83c2b	aae69106-90e2-4803-a4f5-6a7841f6ce34	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	7ea08c97-c22e-4839-b097-d6b50633f91a	lower	15	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
e5749e80-1414-406e-beb1-a08e3d573a47	aae69106-90e2-4803-a4f5-6a7841f6ce34	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	9dc772a5-dc6f-4227-a4b5-2a3b7f749346	lower	16	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
880c81bb-2498-424f-a41d-6c2302150f78	aae69106-90e2-4803-a4f5-6a7841f6ce34	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	63a6a666-a584-4d06-9d50-123f8416d5fa	lower	17	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
ec01a19b-e69d-431e-9679-55227c2cd698	aae69106-90e2-4803-a4f5-6a7841f6ce34	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	db796cdf-63d0-48eb-9fdb-3606f9193979	lower	18	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
d81d175e-c68b-48e8-ba6a-7edcb13b1c54	aae69106-90e2-4803-a4f5-6a7841f6ce34	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	c4556c38-bdaa-46f6-a028-34bfa47d1b03	lower	19	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
4de7e129-3dbb-47c4-8e07-4c13b5eec6d3	aae69106-90e2-4803-a4f5-6a7841f6ce34	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	c7c8affc-dcdb-4aff-a939-fa66fc08bebf	upper	0	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
13c13c79-1248-4f44-9ef9-300192c81b06	aae69106-90e2-4803-a4f5-6a7841f6ce34	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	8428a6d4-1a1b-4692-bea3-a577dfa6a811	upper	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
2f248cf5-4ee3-4f88-bd1e-19ae120b27f7	aae69106-90e2-4803-a4f5-6a7841f6ce34	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	upper	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
0ab945fc-61c7-432e-ac66-0faa7c17d0df	aae69106-90e2-4803-a4f5-6a7841f6ce34	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	9139bf83-aa03-46bd-b796-129f11f78d06	upper	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
aee0c261-3b27-4794-810a-2102ad0dbca7	aae69106-90e2-4803-a4f5-6a7841f6ce34	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	upper	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
3eeac6ad-b673-4971-9c60-4b4c716b22d5	aae69106-90e2-4803-a4f5-6a7841f6ce34	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	f2398444-bbe5-4642-8320-981250a60830	upper	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
acae8613-0d34-4f45-a2c6-68454738dbb3	aae69106-90e2-4803-a4f5-6a7841f6ce34	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	aafde125-051f-4ce0-aaed-bf2e99a97372	upper	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
d1c3af89-027c-49d8-878e-9d094f78e263	aae69106-90e2-4803-a4f5-6a7841f6ce34	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	upper	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
cbb4e0f7-57b1-43f5-8a77-8533b64529e1	aae69106-90e2-4803-a4f5-6a7841f6ce34	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	d6e261d0-faf1-45f5-912c-0cd831b7522e	upper	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
cf23dc4e-b6cc-44eb-b22e-ab1fd3b9d7a4	aae69106-90e2-4803-a4f5-6a7841f6ce34	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	e3cdfd81-2ea1-4841-b959-010c0de70cfa	upper	9	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
5f058665-83d7-466a-8875-e8f963bc9c9e	aae69106-90e2-4803-a4f5-6a7841f6ce34	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	cfc843cd-d86d-45c5-b973-3115f382c168	upper	10	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
01b90adf-e159-4363-a47d-c245c4929823	aae69106-90e2-4803-a4f5-6a7841f6ce34	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	c9a344b5-3874-4b87-9e26-74dc9fe2e5cd	lower	11	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
2eb65d6a-e6cd-40b6-9c6d-a35b6a21d493	aae69106-90e2-4803-a4f5-6a7841f6ce34	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	c840bc04-8c76-402d-bc8d-73346d736c06	lower	12	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
0b79130d-6766-4eba-8464-55de5fd53e97	aae69106-90e2-4803-a4f5-6a7841f6ce34	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	833089c8-da19-43e4-a612-fbff2c1f101c	lower	13	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
4c5fd740-cbab-47e2-ab3b-2226bf724f94	aae69106-90e2-4803-a4f5-6a7841f6ce34	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	1b29430e-2226-4bb6-8a3e-2e1e87e948bb	lower	14	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
d93f348c-b26d-4250-9431-7eaf840b15ba	aae69106-90e2-4803-a4f5-6a7841f6ce34	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	7ea08c97-c22e-4839-b097-d6b50633f91a	lower	15	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
ef8552f7-7845-47dd-9278-0262fee82e6a	aae69106-90e2-4803-a4f5-6a7841f6ce34	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	9dc772a5-dc6f-4227-a4b5-2a3b7f749346	lower	16	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
77b0dcea-9649-45a1-af18-b2a21bd51e09	aae69106-90e2-4803-a4f5-6a7841f6ce34	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	63a6a666-a584-4d06-9d50-123f8416d5fa	lower	17	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
c305744f-ae61-4d0f-826d-33cefaad66fe	aae69106-90e2-4803-a4f5-6a7841f6ce34	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	db796cdf-63d0-48eb-9fdb-3606f9193979	lower	18	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
0f202e70-f2c6-424e-b60d-b5624a568541	aae69106-90e2-4803-a4f5-6a7841f6ce34	7a412b50-41e7-47ce-a7a1-9fabfd67ff74	c4556c38-bdaa-46f6-a028-34bfa47d1b03	lower	19	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
503359fc-e654-4782-90ff-3242f5493f74	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	705e4d77-255e-4d43-9900-920b4b596663	8428a6d4-1a1b-4692-bea3-a577dfa6a811	upper	0	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
586858b9-1e23-478a-85cc-bf9d199b9252	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	705e4d77-255e-4d43-9900-920b4b596663	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	upper	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
f2176607-b8a0-4584-a808-675ce0751d60	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	705e4d77-255e-4d43-9900-920b4b596663	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	upper	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
fea1c369-5a1d-4349-b1cf-d9bcfcdfceaa	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	705e4d77-255e-4d43-9900-920b4b596663	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	upper	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
c01861ac-8c7d-40ab-8c97-41e8b53293dc	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	705e4d77-255e-4d43-9900-920b4b596663	0b6e7914-54d4-42a0-aec8-05b7c7234872	upper	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
6b908ffa-cd71-4a72-8f83-4aaea7ccc867	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	705e4d77-255e-4d43-9900-920b4b596663	aafde125-051f-4ce0-aaed-bf2e99a97372	upper	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
97b18341-f94d-406c-95b6-d224d2a22758	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	705e4d77-255e-4d43-9900-920b4b596663	27ca566a-bd2e-4d13-a8a3-49eccc0f7bf8	lower	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
3d4e71fc-9fe4-4968-8f97-597de4672756	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	275e5594-2a9d-44f0-907c-d7fd8b40a49f	8428a6d4-1a1b-4692-bea3-a577dfa6a811	upper	0	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
b4496ee7-af05-468e-acc5-b73ec648479c	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	275e5594-2a9d-44f0-907c-d7fd8b40a49f	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	upper	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
98d4989b-227c-481a-87be-b83e14653752	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	275e5594-2a9d-44f0-907c-d7fd8b40a49f	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	upper	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
712dcf46-b41e-4a6b-9f1b-478d84bd5732	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	275e5594-2a9d-44f0-907c-d7fd8b40a49f	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	upper	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
5cc04039-0168-4083-8a05-0755e890e686	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	275e5594-2a9d-44f0-907c-d7fd8b40a49f	0b6e7914-54d4-42a0-aec8-05b7c7234872	upper	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
5c166645-a0d6-4074-a5a0-d3cc3af49c55	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	275e5594-2a9d-44f0-907c-d7fd8b40a49f	aafde125-051f-4ce0-aaed-bf2e99a97372	upper	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
e930cece-00c7-4d5e-aead-f3f2134ecd98	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	275e5594-2a9d-44f0-907c-d7fd8b40a49f	27ca566a-bd2e-4d13-a8a3-49eccc0f7bf8	lower	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
0ddac8dc-c1fb-4837-b6b7-9b41e0cc9dd1	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	275e5594-2a9d-44f0-907c-d7fd8b40a49f	9dc772a5-dc6f-4227-a4b5-2a3b7f749346	lower	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
68eb7351-0568-43da-b721-4454d0a81dcd	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	6730b33c-e3e9-4377-aaf8-00de1aff9006	8428a6d4-1a1b-4692-bea3-a577dfa6a811	upper	0	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
61001194-7ab8-412a-8023-3fa4c0da9a1e	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	6730b33c-e3e9-4377-aaf8-00de1aff9006	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	upper	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
ba7f80d4-7843-47ab-a885-2088bdeca7f5	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	6730b33c-e3e9-4377-aaf8-00de1aff9006	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	upper	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
33cfdc54-d924-4d80-bbe5-e1a4ba557dd6	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	6730b33c-e3e9-4377-aaf8-00de1aff9006	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	upper	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
a3fcf89c-3e98-417e-9935-fee39722c5be	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	6730b33c-e3e9-4377-aaf8-00de1aff9006	0b6e7914-54d4-42a0-aec8-05b7c7234872	upper	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
72d5f6e8-6173-4f9f-84b3-baed2a9f3ffb	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	6730b33c-e3e9-4377-aaf8-00de1aff9006	aafde125-051f-4ce0-aaed-bf2e99a97372	upper	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
b9febdb6-1bf0-4eb7-a3f1-ac9bf4816142	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	6730b33c-e3e9-4377-aaf8-00de1aff9006	27ca566a-bd2e-4d13-a8a3-49eccc0f7bf8	lower	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
e86a719c-d4ea-4fbb-aef3-2ccf5c7bcaf0	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	6730b33c-e3e9-4377-aaf8-00de1aff9006	9dc772a5-dc6f-4227-a4b5-2a3b7f749346	lower	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
bf1045f4-bcb1-48d7-a0a3-5ca9ed90a18c	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	6730b33c-e3e9-4377-aaf8-00de1aff9006	d4ac99a4-3ce1-4483-9cb3-d35cbb42c950	lower	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
44841e70-acb0-4491-a316-8bf585a8e57e	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	8428a6d4-1a1b-4692-bea3-a577dfa6a811	upper	0	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
6b34b285-9d9c-428e-b690-da9278bde98e	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	340af0b0-87dd-4fdd-b2cb-002c8a2cd766	upper	1	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
e4301816-2ccc-4e4e-9f38-b934737c7aba	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	13aef7ea-a368-4ba3-a72a-7767ebb0a71a	upper	2	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
da1bb026-d545-41e1-9784-704122ccc32a	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	d36016e9-b051-44a2-a1ad-1823ed6dcd9e	upper	3	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
4feaf5dd-df47-493b-9371-f03bbcd9d33b	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	0b6e7914-54d4-42a0-aec8-05b7c7234872	upper	4	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
f175a2bb-b51e-4c6b-8028-25fa2ba2e375	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	aafde125-051f-4ce0-aaed-bf2e99a97372	upper	5	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
b529f635-7d30-42bf-b5d2-6e1d0db0b231	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	5ba18970-1774-4a6a-8456-c19bab92671d	upper	6	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
6e43cb91-ee46-4706-965b-4d16c68c745c	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	521a2b77-234b-44f4-a482-1f1ce3abf3f1	upper	7	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
7a48d965-fdbd-46d9-bc19-47a402f56574	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	f614af5f-c633-44c2-b92c-be9ca507cfd7	upper	8	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
56cffaf3-62ce-46de-bdb0-b05a49923d5e	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	ae70796b-d9aa-4ea4-b795-89165bfb8029	upper	9	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
27760a55-acde-4180-bdc3-a545d3a79da4	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	789b9947-e362-4948-8d6a-7b6b3f43b246	upper	10	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
9fb00d31-1950-4fc8-83d7-b4837698b199	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	47057f8e-9f03-4cf8-87ef-4f587d856f19	upper	11	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
2a162f29-f1e5-480e-88a7-a338d3c33410	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	9160e1a2-13fe-4ca6-9040-4e4d0f78c030	upper	12	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
c5d70187-1668-4430-b21e-b97cfadebc53	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	74f13017-e0ed-4cc5-aa05-b513ea6cf24f	upper	13	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
69199902-194a-4bda-9935-5aed125cb2fa	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	61ee0d3d-f5b5-433c-9408-473d7e8a32df	upper	14	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
486423f2-a583-4b40-b63b-d3901579c388	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	d4ac99a4-3ce1-4483-9cb3-d35cbb42c950	lower	15	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
5d345283-7d4c-4109-9101-8e32b8462a91	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	4daf5ce2-89ee-416e-92cd-69594d1c5a14	lower	16	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
0caa9e80-be82-46e2-8296-8b7feaf0187e	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	9dc772a5-dc6f-4227-a4b5-2a3b7f749346	lower	17	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
4cef4143-227c-4de6-b859-2bc63933256f	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	27ca566a-bd2e-4d13-a8a3-49eccc0f7bf8	lower	18	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
6dd555ad-2695-4d7d-975f-04090d50ea2d	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	44f65fd4-2aaf-49fe-befb-3fef93739677	lower	19	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
819672a0-4e23-47f6-ac4e-e23410f10a84	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	37edd988-e4fe-4abe-b016-3ad8d88ff60a	lower	20	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
0e7e1058-0c11-42a4-933b-f709576ac504	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	abb6395e-9d40-43b3-9dcd-85416c240ab8	lower	21	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
fe348bc6-28a4-40b1-9669-3fc5ba406ab0	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	229a63f3-8403-43e0-a3b2-9c36f5733691	core	22	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
268d6b75-a83f-4140-8309-9a8df62a7264	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	49430048-c0a3-4e1f-a7d2-95d55bde015d	core	23	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
aed9ba46-ce37-4e52-8f23-459ced752821	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	c416cdea-8b8c-402d-80ed-de59b496ce95	core	24	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
a7051054-29b0-4ff5-a80f-9555e2abf19f	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	cd86eb5f-db74-4163-a9cb-b35a29ddf4ee	core	25	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
01517a69-7be8-4795-bbcf-d54e191ef967	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	4428a891-e6d8-48f7-bfac-24c55d97172a	core	26	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
453e7b85-c48c-4607-b88e-c0571e1331eb	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	7807a4d4-be64-443f-bc3e-a1db82dbfe55	core	27	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
2c5bc217-3663-4201-86ad-3af8d12ffbb6	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	5f615c5e-c0bf-4e9b-a42f-914ff9b8290b	core	28	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
6f5323a4-c15c-4b84-a036-15caa4843c67	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	aa2bca70-423e-4d49-9df2-38d255f485cd	core	29	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
fd5cf2d9-396d-4266-84bc-eef4da138fd2	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	2be6c219-74e7-40a5-9604-f142c9779a7c	core	30	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
ec5ddd05-defc-4e45-b5f9-7605da4a818d	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	46bea93c-e782-4faa-85fb-07a475c2372a	core	31	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
d3bef348-0e3c-4174-8dce-de608bc64c5a	1f386f1c-0da7-43c0-bc0e-eeca447f3dc9	484e7eb8-5a8f-4ee0-86eb-92313a0f7938	86aa2a5b-ae2f-4af0-8d90-9ff7748e4e1c	core	32	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07
\.


--
-- Data for Name: dl_movements; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.dl_movements (id, name, body_part, video_url_male, video_url_female, image_url, instructions, categories, created_at, updated_at, type, pattern, level, name_en, instructions_en, description_en) FROM stdin;
5ba18970-1774-4a6a-8456-c19bab92671d	Partial Lateral Raise	upper	\N	\N	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07	\N	\N	\N	\N	{}	\N
521a2b77-234b-44f4-a482-1f1ce3abf3f1	Triceps Extension	upper	\N	\N	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07	\N	\N	\N	\N	{}	\N
f614af5f-c633-44c2-b92c-be9ca507cfd7	Lat Pull Down (Close Grip)	upper	\N	\N	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07	\N	\N	\N	\N	{}	\N
ae70796b-d9aa-4ea4-b795-89165bfb8029	Crossover Lat Pull Down	upper	\N	\N	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07	\N	\N	\N	\N	{}	\N
725322db-77dd-4f6f-aab4-b53726e25752	Lateral Lunge TRX	lower	\N	\N	\N	{}	{fc}	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07	\N	\N	\N	\N	{}	\N
c9a344b5-3874-4b87-9e26-74dc9fe2e5cd	Wide Step Touch	lower	\N	\N	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07	\N	\N	\N	\N	{}	\N
1b29430e-2226-4bb6-8a3e-2e1e87e948bb	Back step	lower	\N	\N	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07	\N	\N	\N	\N	{}	\N
7ea08c97-c22e-4839-b097-d6b50633f91a	Front Lift	lower	\N	\N	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07	\N	\N	\N	\N	{}	\N
9dc772a5-dc6f-4227-a4b5-2a3b7f749346	Side Lift	lower	\N	\N	\N	{}	{fc,cc,mc}	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07	\N	\N	\N	\N	{}	\N
63a6a666-a584-4d06-9d50-123f8416d5fa	Side High Knee	lower	\N	\N	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07	\N	\N	\N	\N	{}	\N
db796cdf-63d0-48eb-9fdb-3606f9193979	High Knee	lower	\N	\N	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07	\N	\N	\N	\N	{}	\N
c4556c38-bdaa-46f6-a028-34bfa47d1b03	Knee Drive	lower	\N	\N	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07	\N	\N	\N	\N	{}	\N
0b6e7914-54d4-42a0-aec8-05b7c7234872	Tricep Press	upper	https://youtu.be/UkFjVk5QcCY	https://youtu.be/Q8Et1YRNA1s	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:35:35.558705+07	\N	\N	\N	\N	{}	\N
789b9947-e362-4948-8d6a-7b6b3f43b246	Squat Press	upper	https://youtu.be/UR3zf5_kbdU	\N	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:35:35.558705+07	\N	\N	\N	\N	{}	\N
c840bc04-8c76-402d-bc8d-73346d736c06	Front Step	lower	\N	\N	\N	{}	{cc}	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07	\N	\N	\N	\N	{}	\N
833089c8-da19-43e4-a612-fbff2c1f101c	Side Step	lower	\N	\N	\N	{}	{cc}	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07	\N	\N	\N	\N	{}	\N
49430048-c0a3-4e1f-a7d2-95d55bde015d	Pedal	core	\N	\N	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07	\N	\N	\N	\N	{}	\N
c416cdea-8b8c-402d-80ed-de59b496ce95	Glute Bridge	core	\N	\N	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07	\N	\N	\N	\N	{}	\N
aa2bca70-423e-4d49-9df2-38d255f485cd	Sit Up Band	core	\N	\N	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07	\N	\N	\N	\N	{}	\N
46bea93c-e782-4faa-85fb-07a475c2372a	Spider Lunge	core	\N	\N	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-26 23:13:37.451895+07	\N	\N	\N	\N	{}	\N
c7c8affc-dcdb-4aff-a939-fa66fc08bebf	Arm Rotation	upper	https://youtu.be/Gv0JzAjI4wE	https://youtu.be/CDkR0Hqu_B4	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
d6e261d0-faf1-45f5-912c-0cd831b7522e	Arm Swing	upper	https://youtu.be/dgGHE1Sdl44	https://youtu.be/bPdopl2Jf3M	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
4574f322-2ac5-4ba4-b422-9d71fbf39408	Back step - Chair	lower	https://youtu.be/2yhPBvyZSUU	https://youtu.be/0F48EbjjQTw	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
9160e1a2-13fe-4ca6-9040-4e4d0f78c030	Bent Over Fly	upper	https://youtu.be/prz4V9AacSE	\N	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
61ee0d3d-f5b5-433c-9408-473d7e8a32df	Bicep Curls	upper	https://youtu.be/SZKOhGoXcTI	\N	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
47057f8e-9f03-4cf8-87ef-4f587d856f19	Chest Press	upper	https://youtu.be/wuH_zwLy6EM	\N	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
f2398444-bbe5-4642-8320-981250a60830	Cross Front	upper	https://youtu.be/E9IzR-wui8o	https://youtu.be/h-Qk-6DWgsQ	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
aafde125-051f-4ce0-aaed-bf2e99a97372	Cross Up	upper	\N	https://youtu.be/qy2ldvISD2Y	\N	{}	{fc,cc,mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
44f65fd4-2aaf-49fe-befb-3fef93739677	Doggy Pee Band	lower	\N	https://youtu.be/xJXlQ3eAb3U	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
4daf5ce2-89ee-416e-92cd-69594d1c5a14	Donkey Kick	lower	\N	https://youtu.be/REjEINo4nJc	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
37edd988-e4fe-4abe-b016-3ad8d88ff60a	Donkey Kick Band	lower	\N	https://youtu.be/qmOF8yrtw4M	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
ba1c2a86-1612-44e6-aee8-d80be806d487	Front Lift Chair	lower	https://youtu.be/R63B9LnlbZE	https://youtu.be/JheecrPIpmM	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
d036485a-87a4-4399-b5f3-b5f617d679b9	Front Lift Sit	lower	\N	https://youtu.be/2X7EtSq2T6s	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
2be6c219-74e7-40a5-9604-f142c9779a7c	Glute Bridge Band	core	\N	https://youtu.be/2DzvTS7g394	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
ff9be11c-43c3-4383-ba31-94fab9fcd453	High Knee Chair	lower	https://youtu.be/CknG49mGjcs	https://youtu.be/oOGxaCNDeE4	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
0eba8dcf-fb6d-4250-95ab-9e4f61d757b7	Curtsy Lunges	lower	\N	https://youtu.be/7llhcX_p1Qw	\N	{}	{fc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:35:35.558705+07	\N	\N	\N	\N	{}	\N
86aa2a5b-ae2f-4af0-8d90-9ff7748e4e1c	Pedal Band	core	\N	https://youtu.be/caeEgVqXUxE	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:35:35.558705+07	\N	\N	\N	\N	{}	\N
5f615c5e-c0bf-4e9b-a42f-914ff9b8290b	High Plank	core	\N	https://youtu.be/6mFaXOZwqOw	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
18f544bf-7ea0-46f3-b699-0df77d345ebe	Jog-Chair	lower	https://youtu.be/8sWa8vyjwvA	https://youtu.be/qSKkOd9gylg	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
d4ac99a4-3ce1-4483-9cb3-d35cbb42c950	Kick Back	lower	\N	https://youtu.be/K-TIOy5Vft0	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
abb6395e-9d40-43b3-9dcd-85416c240ab8	Kick Back Band	lower	\N	https://youtu.be/nvSk5r4ZtMY	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
4b77ac6b-96d8-43cc-8128-806471103cb3	Knee Drive Chair	lower	https://youtu.be/Rg_XddCoNZ4	https://youtu.be/SeEB4tTMy3g	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
894ca941-f68d-4938-9b9c-679871952f5d	Lateral Lunge	lower	https://youtu.be/DZI61Qlo3n4	https://youtu.be/pIlDIlALdbc	\N	{}	{fc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
15d5324e-f356-4b97-b49e-8151578dff23	Lateral Lunge Chair	lower	https://youtu.be/O9jBkVxvV6w	https://youtu.be/A8zrLo4iuns	\N	{}	{fc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
4b6d2e84-9a13-4bfb-9605-9b754440f9d2	Lunges	lower	https://youtu.be/ztKJWHeKSdU	https://youtu.be/ZcbOg4goUWY	\N	{}	{fc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
51f3d882-7ac7-44e8-8253-7764916ce2f4	Lunges Chair	lower	https://youtu.be/IcfCRJexRx4	https://youtu.be/ekUL39z6KzQ	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
d36016e9-b051-44a2-a1ad-1823ed6dcd9e	Open Arm	upper	https://youtu.be/CmPzKXUH9GQ	https://youtu.be/Wh_4iamBMMc	\N	{}	{fc,cc,mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
9139bf83-aa03-46bd-b796-129f11f78d06	Open Chest	upper	https://youtu.be/OnCUQ1_RYTE	https://youtu.be/pIWz19u3Xw0	\N	{}	{cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
8428a6d4-1a1b-4692-bea3-a577dfa6a811	Open V	upper	https://youtu.be/ICoAkaFoMAQ	https://youtu.be/qjKyIhvRSto	\N	{}	{fc,cc,mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
74f13017-e0ed-4cc5-aa05-b513ea6cf24f	Overhead Press	upper	https://youtu.be/NFsWcXn8HmU	\N	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
3c80c5d3-045c-49f2-93eb-5bf137808878	Overhead Squat	lower	https://youtu.be/syENYeSA1-4	https://youtu.be/Zz_kb0SUEvM	\N	{}	{fc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
db2f510f-b6de-48fd-942e-2fd9fa41d7b3	Overhead Squat TRX	lower	https://youtu.be/zuD0fWUmQlc	https://youtu.be/Y6dZVU7lfM4	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
7807a4d4-be64-443f-bc3e-a1db82dbfe55	Plank	core	https://youtu.be/vnifs9riEJY	\N	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
13aef7ea-a368-4ba3-a72a-7767ebb0a71a	Press Front	upper	https://youtu.be/J5wWtoTR-ak	https://youtu.be/y2ApZiAYNH0	\N	{}	{fc,cc,mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
340af0b0-87dd-4fdd-b2cb-002c8a2cd766	Press Up	upper	https://youtu.be/vQl_OVtbI00	https://youtu.be/aFbveSHv7cQ	\N	{}	{fc,cc,mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
cfc843cd-d86d-45c5-b973-3115f382c168	Pull Down	upper	https://youtu.be/S6zwg686YrY	https://youtu.be/3vimOX9AHQc	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
e3cdfd81-2ea1-4841-b959-010c0de70cfa	Pull Side Down	upper	\N	https://youtu.be/jgOaIUNOQww	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
229a63f3-8403-43e0-a3b2-9c36f5733691	Push Up	core	https://youtu.be/Q4fCSHL8FlU	\N	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
4428a891-e6d8-48f7-bfac-24c55d97172a	Push Up Plank	core	\N	https://youtu.be/qGa0DdAFp8A	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
b438a3a2-bc18-449d-8ba7-08bf1690a3e2	Side Lift Chair	lower	https://youtu.be/XFv3FOuQuqM	https://youtu.be/D-ekkwKHtSs	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
4af59389-3f46-49b1-8783-d4816706d02b	Side Step Chair	lower	https://youtu.be/VlqR1OxrXhE	https://youtu.be/3OFDAcpR3cU	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
50b7bc06-2f6c-4ee7-9183-f9ec1eae7d40	Sit Overhead Squat TRX	lower	https://youtu.be/WLXNxVgKWWk	\N	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
70a2edb9-cb34-4cbe-ad6a-683114cc77e7	Sit Squat TRX	lower	https://youtu.be/Nk-WOfTOKDk	\N	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
8f6c1c2f-0d36-41c0-be60-d4de938e81f8	Sit Sumo Squat TRX	lower	https://youtu.be/KmhFbTEOzq0	\N	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
cd86eb5f-db74-4163-a9cb-b35a29ddf4ee	Sit Up	core	https://youtu.be/CLweukibDg0	https://youtu.be/Po3qKd74lpg	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
85b1b505-0ef3-4982-b046-4fbe098c7fe4	Squat	lower	https://youtu.be/Z_efCtyd2dQ	https://youtu.be/XyS-XmW2Pwc	\N	{}	{fc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
05defb2e-fb85-45b2-95f8-3599770e5e91	Squat Chair	lower	https://youtu.be/xxeOLPbsK7Y	https://youtu.be/lZbEjnKuygo	\N	{}	{fc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
ac2557b4-8e09-4195-a6f1-eac7105975a4	Squat Step	lower	https://youtu.be/BnfKGJrSCvk	https://youtu.be/lx7tnAYnfqU	\N	{}	{fc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
87857153-fc40-495f-aeec-c0dfe041a736	Squat Step Chair	lower	https://youtu.be/qY3b9178JnA	https://youtu.be/co1rOOnWJpo	\N	{}	{fc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
6b794bbb-4265-4785-8402-0c686cc0e1ca	Squat TRX	lower	https://youtu.be/OJ_dpcSszR8	https://youtu.be/aEXUq7v5EvE	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
27ca566a-bd2e-4d13-a8a3-49eccc0f7bf8	Squat-Band	lower	\N	https://youtu.be/eeq1nRoE7g8	\N	{}	{mc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
f142aa48-3c52-4818-b4e4-863e1ef6e0e3	Sumo Squat	lower	https://youtu.be/z669Jt8SD8A	https://youtu.be/fLjY9iWHM5g	\N	{}	{fc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
9935cb34-904b-4213-9143-0b27365fee6b	Sumo Squat Chair	lower	https://youtu.be/pyAAJmwFpH0	https://youtu.be/O2tJsvOTbiQ	\N	{}	{fc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
42b48539-518c-41ea-8381-d3b5b07f27b6	Sumo Squat TRX	lower	https://youtu.be/RMp3AABx4-I	https://youtu.be/o-I54NprOe4	\N	{}	{fc,cc}	2026-06-26 23:13:37.451895+07	2026-06-30 21:34:54.860458+07	\N	\N	\N	\N	{}	\N
adce0883-4ab4-4ad1-995e-b1a81dfcfb56	Barbel Row	upper	https://youtu.be/dQPys_dgoGY	\N	\N	{}	{mc}	2026-06-30 21:35:35.558705+07	2026-06-30 21:35:35.558705+07	\N	\N	\N	\N	{}	\N
27dd77ed-4786-47c4-aa14-1d25abc42dc4	Dumbbell Rows	upper	https://youtu.be/1gPBgQn3JiA	\N	\N	{}	{mc}	2026-06-30 21:35:35.558705+07	2026-06-30 21:35:35.558705+07	\N	\N	\N	\N	{}	\N
0dbd068b-368b-4818-801d-35e14c87c981	Front Lift - Sit	lower	\N	https://youtu.be/Atb_GRZ8sWE	\N	{}	{cc}	2026-06-30 21:35:35.558705+07	2026-06-30 21:35:35.558705+07	\N	\N	\N	\N	{}	\N
7720a527-6fc4-40f8-9948-13afb8d6f384	Front Raise	upper	https://youtu.be/VOzvuZKDrL4	\N	\N	{}	{mc}	2026-06-30 21:35:35.558705+07	2026-06-30 21:35:35.558705+07	\N	\N	\N	\N	{}	\N
f58e5fb8-08f3-46d4-8f26-2423207d6a3f	Squat-Cross Up	upper	\N	https://youtu.be/h6T2Uc7Q-Go	\N	{}	{mc}	2026-06-30 21:35:35.558705+07	2026-06-30 21:35:35.558705+07	\N	\N	\N	\N	{}	\N
1caf4e0b-761b-4afe-8694-ee52fc5dda8b	Variasi Crunch	lower	https://youtu.be/yCu79ggGrME	\N	\N	{}	{mc}	2026-06-30 21:35:35.558705+07	2026-06-30 21:35:35.558705+07	\N	\N	\N	\N	{}	\N
\.


--
-- Data for Name: doctor_videos; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.doctor_videos (id, title, description, video_url, thumbnail_url, doctor_name, doctor_specialty, is_published, created_at, updated_at, title_en, description_en) FROM stdin;
5ed733ef-0aa0-433e-94a9-b30bfebaef37	Tips Latihan Kardio Aman untuk Jantung	Panduan bagi pemula dan penderita hipertensi dalam melakukan latihan kardiovaskular secara aman dan terkontrol.	https://www.youtube.com/embed/dQw4w9WgXcQ	https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?q=80&w=600&auto=format&fit=crop	dr. Andi Wijaya, Sp.JP	Spesialis Jantung & Pembuluh Darah	t	2026-06-26 22:34:24.078571+07	2026-06-26 22:34:24.078571+07	\N	\N
f44fe40e-5931-4473-8226-cc4a1a59734d	Mengapa Diet Ketat Sering Gagal?	Penjelasan mendalam dari kacamata medis mengenai metabolisme tubuh saat menghadapi defisit kalori yang terlalu ekstrem.	https://www.youtube.com/embed/dQw4w9WgXcQ	https://images.unsplash.com/photo-1498837167922-ddd27525d352?q=80&w=600&auto=format&fit=crop	dr. Sarah Smith, Sp.GK	Spesialis Gizi Klinik	t	2026-06-26 22:34:24.078571+07	2026-06-26 22:34:24.078571+07	\N	\N
\.


--
-- Data for Name: equipments; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.equipments (id, name, category, description, is_active, sort_order, created_by, created_at, updated_at) FROM stdin;
e41d67c6-72af-464c-bbb0-7fe337fd878b	Wrist 0.25 kg	upper	\N	t	1	\N	2026-06-26 22:34:20.361589+07	2026-06-26 22:34:20.361589+07
66bc4d0d-a419-4e23-9f13-6ad501e34cfa	Wrist 0.5 kg	upper	\N	t	2	\N	2026-06-26 22:34:20.361589+07	2026-06-26 22:34:20.361589+07
bd5635e1-dc9e-4f95-a6db-10173b9f63d6	Wrist 1 kg	upper	\N	t	3	\N	2026-06-26 22:34:20.361589+07	2026-06-26 22:34:20.361589+07
10f79a44-bc80-4b9c-89e8-a3aefa6b724d	Wrist 1.5 kg	upper	\N	t	4	\N	2026-06-26 22:34:20.361589+07	2026-06-26 22:34:20.361589+07
b57ab81c-ff67-4032-a587-cf42a171bf93	Wrist 2 kg	upper	\N	t	5	\N	2026-06-26 22:34:20.361589+07	2026-06-26 22:34:20.361589+07
c8e5024b-a0d9-445f-825e-d66a4e0d535c	Wrist 2.5 kg	upper	\N	t	6	\N	2026-06-26 22:34:20.361589+07	2026-06-26 22:34:20.361589+07
15e288bb-a1ac-4aaa-aad3-017bb754089a	Stick 0.5 kg	upper	\N	t	7	\N	2026-06-26 22:34:20.361589+07	2026-06-26 22:34:20.361589+07
8a064ecb-1b3d-4278-84d5-ae792c8d7ed5	Stick 1 kg	upper	\N	t	8	\N	2026-06-26 22:34:20.361589+07	2026-06-26 22:34:20.361589+07
8d10bd62-1e6c-46b8-a8e6-bffd2c418ee2	Stick 1.5 kg	upper	\N	t	9	\N	2026-06-26 22:34:20.361589+07	2026-06-26 22:34:20.361589+07
2b3e579a-7648-4458-947f-e03af2708453	Stick 2 kg	upper	\N	t	10	\N	2026-06-26 22:34:20.361589+07	2026-06-26 22:34:20.361589+07
9e39b9ab-42ad-4280-a550-e0d709a063ba	Ankle 0.5 kg	lower	\N	t	1	\N	2026-06-26 22:34:20.361589+07	2026-06-26 22:34:20.361589+07
3d683c54-1eaf-4aff-8e4e-550897fa8aa3	Ankle 1 kg	lower	\N	t	2	\N	2026-06-26 22:34:20.361589+07	2026-06-26 22:34:20.361589+07
0edbdb53-d7e7-46e0-8884-3fff5aa9ae74	Ankle 1.5 kg	lower	\N	t	3	\N	2026-06-26 22:34:20.361589+07	2026-06-26 22:34:20.361589+07
145fe661-c6be-4415-bac5-cb8f6dfbc96c	Ankle 2 kg	lower	\N	t	4	\N	2026-06-26 22:34:20.361589+07	2026-06-26 22:34:20.361589+07
9007f83e-f71c-4cd6-a629-467d061b695e	Ankle 2.5 kg	lower	\N	t	5	\N	2026-06-26 22:34:20.361589+07	2026-06-26 22:34:20.361589+07
af8b054d-bff0-4e8c-a217-dd2e79372a92	Ankle 3 kg	lower	\N	t	6	\N	2026-06-26 22:34:20.361589+07	2026-06-26 22:34:20.361589+07
167288c3-0ed4-4144-9f0e-f3b920097036	Ankle 3.5 kg	lower	\N	t	7	\N	2026-06-26 22:34:20.361589+07	2026-06-26 22:34:20.361589+07
22c91e08-e243-4bec-856e-24c521bfc37c	Ankle 4 kg	lower	\N	t	8	\N	2026-06-26 22:34:20.361589+07	2026-06-26 22:34:20.361589+07
\.


--
-- Data for Name: event_participants; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.event_participants (id, event_id, user_id, rsvp_status, joined_at) FROM stdin;
\.


--
-- Data for Name: event_types; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.event_types (id, name, description, category, duration_min, color, is_active, created_by, created_at, updated_at) FROM stdin;
472128b0-8411-46d0-862f-5571b9969048	HIIT Boot Camp	High-intensity interval training group class	group_class	45	#F59E0B	t	\N	2026-06-26 22:34:26.260063+07	2026-06-26 22:34:26.260063+07
1cd0e3a5-70ac-4756-a038-a03f8dd57d82	Online Consultation	Virtual consultation via video call	one_on_one	30	#8B5CF6	t	\N	2026-06-26 22:34:26.260063+07	2026-06-26 22:34:26.260063+07
2ed0ec55-118d-4be8-84ac-8c8743ba2b46	Personal Event	Personal time block	personal	60	#6B7280	t	\N	2026-06-26 22:34:26.260063+07	2026-06-26 22:34:26.260063+07
09eb1471-ae88-4ed3-b50e-1159c8f972d3	1 on 1 Personal Training	Private personal training session	one_on_one	60	#3B82F6	t	\N	2026-06-26 22:34:26.260063+07	2026-06-26 22:34:26.260063+07
50204ea9-67f7-4b42-940e-6457c9d1b928	Nutrition Coaching	One-on-one nutrition consultation	one_on_one	45	#06B6D4	t	\N	2026-06-26 22:34:26.260063+07	2026-06-26 22:34:26.260063+07
07891dd2-39b7-4e75-af78-c08f75d154ec	Group Fitness Class	Group training session (max 12 participants)	group_class	45	#10B981	t	\N	2026-06-26 22:34:26.260063+07	2026-06-26 22:34:26.260063+07
c047b303-71c1-471e-a83b-fa1251961f0f	Yoga & Stretch	Guided yoga and stretching session	group_class	60	#EC4899	t	\N	2026-06-26 22:34:26.260063+07	2026-06-26 22:34:26.260063+07
\.


--
-- Data for Name: exercises; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.exercises (id, name, description, muscle_group, equipment, difficulty, video_url, thumbnail_url, instructions, created_by, is_system, created_at, updated_at) FROM stdin;
2fae72c2-ee45-4cbe-bf15-8030eba79ab3	Barbell Bench Press	Compound chest exercise. The king of upper body pressing movements.	{chest,triceps,shoulders}	barbell	intermediate	https://www.youtube.com/watch?v=rT7DgCr-3pg	\N	{"Lie flat on bench with feet on floor","Grip bar slightly wider than shoulder width","Unrack and lower bar to mid-chest","Press up to full lockout"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
0e36a09b-c9b8-4cd3-b770-0d9c87692355	Dumbbell Incline Press	Upper chest focused pressing movement on an incline bench.	{chest,shoulders,triceps}	dumbbell	intermediate	https://www.youtube.com/watch?v=8iPEnn-ltC8	\N	{"Set bench to 30-45 degree incline","Press dumbbells from shoulder level to full extension","Lower with control"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
c24869f4-d364-4f23-98d2-c50720d0a4c8	Push-Up	Bodyweight chest exercise. Fundamental pushing movement.	{chest,triceps,shoulders,core}	bodyweight	beginner	https://www.youtube.com/watch?v=IODxDxX7oi4	\N	{"Start in plank position with hands shoulder-width apart","Lower chest to floor","Push back up to starting position","Keep core tight throughout"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
2e3c72dd-56de-4f87-841e-237f7072c0c3	Dumbbell Chest Fly	Isolation exercise targeting the chest with a wide arc motion.	{chest}	dumbbell	beginner	https://www.youtube.com/watch?v=eozdVDA78K0	\N	{"Lie flat on bench holding dumbbells above chest","Open arms wide in arc motion with slight bend in elbows","Squeeze chest to bring dumbbells back together"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
5bb98292-ce6d-4857-bc8b-94de6c673314	Barbell Deadlift	Full-body compound lift. The ultimate strength builder.	{back,hamstrings,glutes,core}	barbell	advanced	https://www.youtube.com/watch?v=op9kVnSso6Q	\N	{"Stand with feet hip-width, bar over mid-foot","Hinge at hips, grip bar outside knees","Drive through floor, keeping bar close to body","Stand tall, squeeze glutes at top","Return bar to floor with control"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
b6cbdae9-726d-4d90-ba35-f0479ad4384d	Pull-Up	Bodyweight back exercise. Gold standard for upper back development.	{back,biceps,core}	pull-up bar	intermediate	https://www.youtube.com/watch?v=eGo4IYlbE5g	\N	{"Hang from bar with overhand grip, slightly wider than shoulders","Pull up until chin clears bar","Lower with control to full hang"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
0ed3c051-1aae-482d-86d3-4a0acdd37e9c	Barbell Bent-Over Row	Compound back exercise building thickness.	{back,biceps,core}	barbell	intermediate	https://www.youtube.com/watch?v=FWJR5Ve8bnQ	\N	{"Hinge at hips about 45 degrees","Pull bar to lower chest/upper abdomen","Squeeze shoulder blades at top","Lower with control"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
8f2671ea-e344-4f5a-9642-3f1f54f403a2	Lat Pulldown	Machine back exercise targeting lats. Easier alternative to pull-ups.	{back,biceps}	cable machine	beginner	https://www.youtube.com/watch?v=CAwf7n6Luuc	\N	{"Grip bar wider than shoulder width","Pull bar down to upper chest","Squeeze lats at bottom","Return with control"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
1164a8cb-7996-4f7b-bb18-5b7cdd052bee	Seated Cable Row	Machine back exercise targeting mid-back thickness.	{back,biceps}	cable machine	beginner	https://www.youtube.com/watch?v=GZbfZ033f74	\N	{"Sit with feet on platform, slight knee bend","Pull handle to abdomen","Squeeze shoulder blades together","Extend arms with control"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
beea9a1a-2c79-4aff-91d9-10d07b6d4f7f	Barbell Back Squat	King of leg exercises. Full lower body compound movement.	{quadriceps,glutes,hamstrings,core}	barbell	intermediate	https://www.youtube.com/watch?v=ultWZbUMPL8	\N	{"Bar on upper traps, feet shoulder-width apart","Break at hips and knees simultaneously","Descend until thighs are parallel or below","Drive up through heels"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
dd7841b2-2d1d-438b-be84-f4b3f3d1f3fa	Romanian Deadlift	Hip-hinge movement targeting posterior chain.	{hamstrings,glutes,back}	barbell	intermediate	https://www.youtube.com/watch?v=7j-2w4-P14I	\N	{"Hold bar at hip level with slight knee bend","Hinge at hips, pushing them back","Lower bar along thighs until hamstring stretch","Drive hips forward to return"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
b28674fc-abcf-4f4c-90cc-8668feb2a12a	Leg Press	Machine compound leg exercise. Safer alternative to squats.	{quadriceps,glutes}	machine	beginner	https://www.youtube.com/watch?v=IZxyjW7MPJQ	\N	{"Sit in machine with feet shoulder-width on platform","Release safety and lower platform","Press through feet to extend legs","Do not lock knees at top"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
8ad7a994-2dc4-4b48-95cb-8928b0760286	Walking Lunges	Unilateral leg exercise improving balance and strength.	{quadriceps,glutes,hamstrings}	dumbbell	beginner	https://www.youtube.com/watch?v=L8fvypPrzzs	\N	{"Hold dumbbells at sides","Step forward into lunge, both knees at 90 degrees","Push off front foot to step forward into next lunge"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
47d27048-f099-4761-a398-1f13291f3b27	Leg Curl	Isolation exercise for hamstrings.	{hamstrings}	machine	beginner	https://www.youtube.com/watch?v=1Tq3QdYUuHs	\N	{"Lie face down on machine","Curl weight by bending knees","Squeeze hamstrings at top","Lower with control"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
ec386ac2-6666-434c-9cf4-07c62074f7e4	Leg Extension	Isolation exercise for quadriceps.	{quadriceps}	machine	beginner	https://www.youtube.com/watch?v=YyvSfVjQeL0	\N	{"Sit in machine with pad on shins","Extend legs to full lockout","Squeeze quads at top","Lower with control"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
ad178a37-adba-40c8-b2d9-2b1452b755a3	Calf Raise	Isolation exercise for calves. Can be done standing or seated.	{calves}	machine	beginner	https://www.youtube.com/watch?v=gwLzBJYoWlI	\N	{"Stand on edge of platform with heels hanging off","Rise up onto toes as high as possible","Lower heels below platform for full stretch"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
e2451023-e857-41e9-8312-5e13260575eb	Overhead Press	Compound shoulder exercise. Primary deltoid builder.	{shoulders,triceps,core}	barbell	intermediate	https://www.youtube.com/watch?v=2yjwXTZQDDI	\N	{"Start with bar at shoulder height","Press overhead to full lockout","Move head forward once bar passes face","Lower with control"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
7ec5bcf1-53ec-4c69-9bd9-aacca49a353e	Dumbbell Lateral Raise	Isolation exercise for side delts. Builds shoulder width.	{shoulders}	dumbbell	beginner	https://www.youtube.com/watch?v=3VcKaXpzqRo	\N	{"Stand with dumbbells at sides","Raise arms out to sides until parallel with floor","Slight bend in elbows throughout","Lower with control"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
9215b23e-70c3-48b5-9f5f-c83c59837e76	Face Pull	Rear delt and rotator cuff exercise. Essential for shoulder health.	{shoulders,back}	cable machine	beginner	https://www.youtube.com/watch?v=rep-qVOkqgk	\N	{"Set cable at face height with rope attachment","Pull rope to face, separating ends","Squeeze rear delts and external rotate","Return with control"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
887919e9-4c29-472a-b582-62393dfb5121	Barbell Curl	Classic bicep exercise for building arm size.	{biceps}	barbell	beginner	https://www.youtube.com/watch?v=kwG2ipFRgfo	\N	{"Stand with bar at arms length, underhand grip","Curl bar to shoulder level","Keep elbows stationary at sides","Lower with control"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
2e1f07c0-c849-4692-add9-2243cafe6b7b	Dumbbell Hammer Curl	Bicep and forearm exercise with neutral grip.	{biceps,forearms}	dumbbell	beginner	https://www.youtube.com/watch?v=zC3nLlEvin4	\N	{"Hold dumbbells with palms facing each other","Curl up keeping neutral grip","Lower with control"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
73ef983f-de31-41e6-bfe0-82efb6d728ba	Tricep Pushdown	Cable isolation exercise for triceps.	{triceps}	cable machine	beginner	https://www.youtube.com/watch?v=2-LAMcpzODU	\N	{"Stand at cable machine with bar/rope at chest height","Push down to full extension","Keep elbows pinned at sides","Return with control"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
ce445dff-a9ed-4438-b78f-659ff817d526	Close-Grip Bench Press	Compound tricep exercise. Targets triceps with chest assistance.	{triceps,chest,shoulders}	barbell	intermediate	https://www.youtube.com/watch?v=nEF0bv2FW94	\N	{"Lie on bench with hands shoulder-width apart","Lower bar to lower chest","Press up focusing on tricep contraction","Keep elbows closer to body than standard bench"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
5a2bd6cd-333a-494d-916b-4c40ab3ff69a	Plank	Isometric core exercise. Foundation of core training.	{core}	bodyweight	beginner	https://www.youtube.com/watch?v=ASdvN_XEl_c	\N	{"Forearms on ground, body in straight line","Squeeze glutes and brace core","Hold position for prescribed duration","Do not let hips sag or pike"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
3ffd4fc8-121c-441f-a05c-b36f0eae0af6	Hanging Leg Raise	Advanced core exercise targeting lower abs.	{core}	pull-up bar	advanced	https://www.youtube.com/watch?v=hdng3Nm1x_E	\N	{"Hang from bar with straight arms","Raise legs until parallel or higher","Lower with control, no swinging","Keep core engaged throughout"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
760db084-2c7f-42d4-8a1c-e31d876fe683	Russian Twist	Rotational core exercise targeting obliques.	{core}	bodyweight	beginner	https://www.youtube.com/watch?v=wkD8rjkodUI	\N	{"Sit with knees bent, lean back slightly","Hold weight or hands together at chest","Rotate torso side to side","Keep feet elevated for added difficulty"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
7ed64e0c-f21f-4602-a95b-9277f739c0bf	Ab Wheel Rollout	Advanced core exercise for full abdominal development.	{core,shoulders}	ab wheel	advanced	https://www.youtube.com/watch?v=uYBOBBv9GzY	\N	{"Kneel with ab wheel in front","Roll forward extending body","Maintain tight core, do not arch back","Roll back to starting position"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
8c6d4533-6514-4638-bb94-fdfdff4c9a71	Hip Thrust	The best glute isolation exercise. Maximum glute activation.	{glutes,hamstrings}	barbell	intermediate	https://www.youtube.com/watch?v=SEdqd1n0cvg	\N	{"Upper back on bench, bar across hips","Drive hips up until body is in straight line","Squeeze glutes hard at top","Lower with control"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
9d4780d4-60e6-47eb-8aa6-f576c2977029	Bulgarian Split Squat	Unilateral leg exercise with heavy glute emphasis.	{glutes,quadriceps,hamstrings}	dumbbell	intermediate	https://www.youtube.com/watch?v=2C-uNgKwPLE	\N	{"Rear foot elevated on bench","Lower into lunge until rear knee nearly touches floor","Drive through front heel to stand","Keep torso upright"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
c0f6838f-c3f0-4032-b235-c251318eea57	Treadmill Run	Cardiovascular exercise on treadmill. Adjustable speed and incline.	{cardio}	treadmill	beginner	https://www.youtube.com/watch?v=8_gMCkbJ0NM	\N	{"Set desired speed and incline","Maintain steady pace for prescribed duration","Use incline for added intensity"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
9183b392-a383-4af7-a6e7-63bfce4f0054	Rowing Machine	Full body cardiovascular exercise with back emphasis.	{cardio,back,legs}	rowing machine	beginner	https://www.youtube.com/watch?v=kzuMvBCmn3I	\N	{"Drive with legs first, then lean back, then pull arms","Return in reverse order: arms, body, legs","Maintain steady rhythm"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
1723bc27-d0d1-4392-8472-a280f573a8fd	Jump Rope	High-intensity cardio exercise improving coordination.	{cardio,calves}	jump rope	beginner	https://www.youtube.com/watch?v=FJmRQ5iTXKE	\N	{"Hold rope handles at hip level","Jump with small hops, staying on balls of feet","Rotate rope with wrists not arms"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
c661720a-a4ba-47dd-b47e-4ccf131149da	Battle Ropes	High-intensity upper body cardio exercise.	{cardio,shoulders,core}	battle ropes	intermediate	https://www.youtube.com/watch?v=dsSahKBwefs	\N	{"Hold one end in each hand","Create waves by alternating arm slams","Maintain slight squat position","Keep core braced"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
2474400d-9f1b-42d1-a03d-b18bc173fc5b	Burpees	Full-body cardio exercise. Maximum calorie burn.	{cardio,chest,core,legs}	bodyweight	intermediate	https://www.youtube.com/watch?v=dZgVxmf6jkA	\N	{"Stand, then squat down placing hands on floor","Jump feet back to plank position","Do a push-up","Jump feet forward and explosively jump up with arms overhead"}	\N	t	2026-06-26 22:34:24.926852+07	2026-06-26 22:34:24.926852+07
d8b43890-1eab-4971-8045-23c2903df36a	Barbell Bench Press	Compound chest exercise. The king of upper body pressing movements.	{chest,triceps,shoulders}	barbell	intermediate	https://www.youtube.com/watch?v=rT7DgCr-3pg	\N	{"Lie flat on bench with feet on floor","Grip bar slightly wider than shoulder width","Unrack and lower bar to mid-chest","Press up to full lockout"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
8728a04c-c27d-4143-b71b-197a5073cb11	Dumbbell Incline Press	Upper chest focused pressing movement on an incline bench.	{chest,shoulders,triceps}	dumbbell	intermediate	https://www.youtube.com/watch?v=8iPEnn-ltC8	\N	{"Set bench to 30-45 degree incline","Press dumbbells from shoulder level to full extension","Lower with control"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
26fcb7ae-61eb-414e-a316-4c7f2a2a247a	Push-Up	Bodyweight chest exercise. Fundamental pushing movement.	{chest,triceps,shoulders,core}	bodyweight	beginner	https://www.youtube.com/watch?v=IODxDxX7oi4	\N	{"Start in plank position with hands shoulder-width apart","Lower chest to floor","Push back up to starting position","Keep core tight throughout"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
a0c4ad1d-6c13-4b3e-a7a5-a4d833e89c8a	Dumbbell Chest Fly	Isolation exercise targeting the chest with a wide arc motion.	{chest}	dumbbell	beginner	https://www.youtube.com/watch?v=eozdVDA78K0	\N	{"Lie flat on bench holding dumbbells above chest","Open arms wide in arc motion with slight bend in elbows","Squeeze chest to bring dumbbells back together"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
761e5308-4335-4cb2-9dcc-8f1a9a336996	Barbell Deadlift	Full-body compound lift. The ultimate strength builder.	{back,hamstrings,glutes,core}	barbell	advanced	https://www.youtube.com/watch?v=op9kVnSso6Q	\N	{"Stand with feet hip-width, bar over mid-foot","Hinge at hips, grip bar outside knees","Drive through floor, keeping bar close to body","Stand tall, squeeze glutes at top","Return bar to floor with control"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
dd7c85b8-fe20-450a-b4a3-0f62165eef27	Pull-Up	Bodyweight back exercise. Gold standard for upper back development.	{back,biceps,core}	pull-up bar	intermediate	https://www.youtube.com/watch?v=eGo4IYlbE5g	\N	{"Hang from bar with overhand grip, slightly wider than shoulders","Pull up until chin clears bar","Lower with control to full hang"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
717195a8-12b0-4fdd-a4e2-c383c573a928	Barbell Bent-Over Row	Compound back exercise building thickness.	{back,biceps,core}	barbell	intermediate	https://www.youtube.com/watch?v=FWJR5Ve8bnQ	\N	{"Hinge at hips about 45 degrees","Pull bar to lower chest/upper abdomen","Squeeze shoulder blades at top","Lower with control"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
e34297e5-4046-4be6-bce8-d0b9bd2d0552	Lat Pulldown	Machine back exercise targeting lats. Easier alternative to pull-ups.	{back,biceps}	cable machine	beginner	https://www.youtube.com/watch?v=CAwf7n6Luuc	\N	{"Grip bar wider than shoulder width","Pull bar down to upper chest","Squeeze lats at bottom","Return with control"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
a0b422a8-87d7-40b2-8384-0126bd162bab	Seated Cable Row	Machine back exercise targeting mid-back thickness.	{back,biceps}	cable machine	beginner	https://www.youtube.com/watch?v=GZbfZ033f74	\N	{"Sit with feet on platform, slight knee bend","Pull handle to abdomen","Squeeze shoulder blades together","Extend arms with control"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
c204e269-832a-483d-af14-aece8d51d860	Barbell Back Squat	King of leg exercises. Full lower body compound movement.	{quadriceps,glutes,hamstrings,core}	barbell	intermediate	https://www.youtube.com/watch?v=ultWZbUMPL8	\N	{"Bar on upper traps, feet shoulder-width apart","Break at hips and knees simultaneously","Descend until thighs are parallel or below","Drive up through heels"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
db279934-ac13-4b8b-8cd6-41e21afa6670	Romanian Deadlift	Hip-hinge movement targeting posterior chain.	{hamstrings,glutes,back}	barbell	intermediate	https://www.youtube.com/watch?v=7j-2w4-P14I	\N	{"Hold bar at hip level with slight knee bend","Hinge at hips, pushing them back","Lower bar along thighs until hamstring stretch","Drive hips forward to return"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
acfff952-25fb-43c8-9a6b-933b50fb0d8d	Leg Press	Machine compound leg exercise. Safer alternative to squats.	{quadriceps,glutes}	machine	beginner	https://www.youtube.com/watch?v=IZxyjW7MPJQ	\N	{"Sit in machine with feet shoulder-width on platform","Release safety and lower platform","Press through feet to extend legs","Do not lock knees at top"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
84d3a528-c8d8-464a-a4f3-caaf001dfb27	Walking Lunges	Unilateral leg exercise improving balance and strength.	{quadriceps,glutes,hamstrings}	dumbbell	beginner	https://www.youtube.com/watch?v=L8fvypPrzzs	\N	{"Hold dumbbells at sides","Step forward into lunge, both knees at 90 degrees","Push off front foot to step forward into next lunge"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
0831fa74-e8d0-4471-9bda-8e85e9324995	Leg Curl	Isolation exercise for hamstrings.	{hamstrings}	machine	beginner	https://www.youtube.com/watch?v=1Tq3QdYUuHs	\N	{"Lie face down on machine","Curl weight by bending knees","Squeeze hamstrings at top","Lower with control"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
a1b6a9ee-4d87-4c7e-a45c-56912761e65a	Leg Extension	Isolation exercise for quadriceps.	{quadriceps}	machine	beginner	https://www.youtube.com/watch?v=YyvSfVjQeL0	\N	{"Sit in machine with pad on shins","Extend legs to full lockout","Squeeze quads at top","Lower with control"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
f65704d2-0d68-4b92-8f8c-f553f82d0645	Calf Raise	Isolation exercise for calves. Can be done standing or seated.	{calves}	machine	beginner	https://www.youtube.com/watch?v=gwLzBJYoWlI	\N	{"Stand on edge of platform with heels hanging off","Rise up onto toes as high as possible","Lower heels below platform for full stretch"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
b7c1af69-0df6-4da9-b351-235fc51df8c7	Overhead Press	Compound shoulder exercise. Primary deltoid builder.	{shoulders,triceps,core}	barbell	intermediate	https://www.youtube.com/watch?v=2yjwXTZQDDI	\N	{"Start with bar at shoulder height","Press overhead to full lockout","Move head forward once bar passes face","Lower with control"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
7ef790df-8daa-4df5-887d-edd012d7be87	Dumbbell Lateral Raise	Isolation exercise for side delts. Builds shoulder width.	{shoulders}	dumbbell	beginner	https://www.youtube.com/watch?v=3VcKaXpzqRo	\N	{"Stand with dumbbells at sides","Raise arms out to sides until parallel with floor","Slight bend in elbows throughout","Lower with control"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
b33548f5-103b-4c83-9248-d8b5e3cd55b5	Face Pull	Rear delt and rotator cuff exercise. Essential for shoulder health.	{shoulders,back}	cable machine	beginner	https://www.youtube.com/watch?v=rep-qVOkqgk	\N	{"Set cable at face height with rope attachment","Pull rope to face, separating ends","Squeeze rear delts and external rotate","Return with control"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
45248f21-8809-49d0-9217-df133a49c149	Barbell Curl	Classic bicep exercise for building arm size.	{biceps}	barbell	beginner	https://www.youtube.com/watch?v=kwG2ipFRgfo	\N	{"Stand with bar at arms length, underhand grip","Curl bar to shoulder level","Keep elbows stationary at sides","Lower with control"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
c72f8979-595d-47d1-b0fb-de6ed5095360	Dumbbell Hammer Curl	Bicep and forearm exercise with neutral grip.	{biceps,forearms}	dumbbell	beginner	https://www.youtube.com/watch?v=zC3nLlEvin4	\N	{"Hold dumbbells with palms facing each other","Curl up keeping neutral grip","Lower with control"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
6afa94e0-b299-40b1-b16d-3fc102e4ae12	Tricep Pushdown	Cable isolation exercise for triceps.	{triceps}	cable machine	beginner	https://www.youtube.com/watch?v=2-LAMcpzODU	\N	{"Stand at cable machine with bar/rope at chest height","Push down to full extension","Keep elbows pinned at sides","Return with control"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
df44e77f-9d60-44f8-b002-2af0ad2c5304	Close-Grip Bench Press	Compound tricep exercise. Targets triceps with chest assistance.	{triceps,chest,shoulders}	barbell	intermediate	https://www.youtube.com/watch?v=nEF0bv2FW94	\N	{"Lie on bench with hands shoulder-width apart","Lower bar to lower chest","Press up focusing on tricep contraction","Keep elbows closer to body than standard bench"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
ad115d3f-087c-4c6f-97c7-3c216dcadb8b	Plank	Isometric core exercise. Foundation of core training.	{core}	bodyweight	beginner	https://www.youtube.com/watch?v=ASdvN_XEl_c	\N	{"Forearms on ground, body in straight line","Squeeze glutes and brace core","Hold position for prescribed duration","Do not let hips sag or pike"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
66185fce-2bb4-49d9-b5f9-7d1e41e14966	Hanging Leg Raise	Advanced core exercise targeting lower abs.	{core}	pull-up bar	advanced	https://www.youtube.com/watch?v=hdng3Nm1x_E	\N	{"Hang from bar with straight arms","Raise legs until parallel or higher","Lower with control, no swinging","Keep core engaged throughout"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
c32297b9-4262-45ea-a4d4-642d7cb4b065	Russian Twist	Rotational core exercise targeting obliques.	{core}	bodyweight	beginner	https://www.youtube.com/watch?v=wkD8rjkodUI	\N	{"Sit with knees bent, lean back slightly","Hold weight or hands together at chest","Rotate torso side to side","Keep feet elevated for added difficulty"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
8aaaf26e-00be-46f4-b1ba-2200672d0bf2	Ab Wheel Rollout	Advanced core exercise for full abdominal development.	{core,shoulders}	ab wheel	advanced	https://www.youtube.com/watch?v=uYBOBBv9GzY	\N	{"Kneel with ab wheel in front","Roll forward extending body","Maintain tight core, do not arch back","Roll back to starting position"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
7df22479-9b3b-4c9c-8b53-169063a39d7c	Hip Thrust	The best glute isolation exercise. Maximum glute activation.	{glutes,hamstrings}	barbell	intermediate	https://www.youtube.com/watch?v=SEdqd1n0cvg	\N	{"Upper back on bench, bar across hips","Drive hips up until body is in straight line","Squeeze glutes hard at top","Lower with control"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
0239963d-4c9c-4653-a314-ed882f30b326	Bulgarian Split Squat	Unilateral leg exercise with heavy glute emphasis.	{glutes,quadriceps,hamstrings}	dumbbell	intermediate	https://www.youtube.com/watch?v=2C-uNgKwPLE	\N	{"Rear foot elevated on bench","Lower into lunge until rear knee nearly touches floor","Drive through front heel to stand","Keep torso upright"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
52c200d0-61f9-4fcb-986b-584533a7d5ec	Treadmill Run	Cardiovascular exercise on treadmill. Adjustable speed and incline.	{cardio}	treadmill	beginner	https://www.youtube.com/watch?v=8_gMCkbJ0NM	\N	{"Set desired speed and incline","Maintain steady pace for prescribed duration","Use incline for added intensity"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
92d5a6e5-3b03-4df4-aee5-bdb6d7f9c558	Rowing Machine	Full body cardiovascular exercise with back emphasis.	{cardio,back,legs}	rowing machine	beginner	https://www.youtube.com/watch?v=kzuMvBCmn3I	\N	{"Drive with legs first, then lean back, then pull arms","Return in reverse order: arms, body, legs","Maintain steady rhythm"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
b4774a03-b04d-480d-a326-08b671a857a1	Jump Rope	High-intensity cardio exercise improving coordination.	{cardio,calves}	jump rope	beginner	https://www.youtube.com/watch?v=FJmRQ5iTXKE	\N	{"Hold rope handles at hip level","Jump with small hops, staying on balls of feet","Rotate rope with wrists not arms"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
9def5874-9580-4ace-b783-3a2c74e1f4cd	Battle Ropes	High-intensity upper body cardio exercise.	{cardio,shoulders,core}	battle ropes	intermediate	https://www.youtube.com/watch?v=dsSahKBwefs	\N	{"Hold one end in each hand","Create waves by alternating arm slams","Maintain slight squat position","Keep core braced"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
edf31f60-da2b-48b6-ba2a-476edbd93f16	Burpees	Full-body cardio exercise. Maximum calorie burn.	{cardio,chest,core,legs}	bodyweight	intermediate	https://www.youtube.com/watch?v=dZgVxmf6jkA	\N	{"Stand, then squat down placing hands on floor","Jump feet back to plank position","Do a push-up","Jump feet forward and explosively jump up with arms overhead"}	\N	t	2026-06-26 23:07:12.534539+07	2026-06-26 23:07:12.534539+07
\.


--
-- Data for Name: foods; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.foods (id, name, description, image_url, meal_types, calories, protein_g, carbs_g, fat_g, fiber_g, serving_size, serving_unit, is_system, created_by, created_at, updated_at) FROM stdin;
7f5b2c27-adb1-47bb-b444-bd9ff99b4d9b	Cottage Cheese with Fruit	Low-fat cottage cheese with mixed berries	\N	{snack}	180	20.0	18.0	3.0	2.0	1	cup	t	\N	2026-06-26 22:34:26.004872+07	2026-06-26 22:34:26.004872+07
35382964-1320-4b86-802d-ccaf4fff73ce	Beef Stir Fry	Lean beef strips with mixed vegetables in soy sauce	\N	{dinner}	450	35.0	20.0	25.0	4.0	1	plate	t	\N	2026-06-26 22:34:26.004872+07	2026-06-26 22:34:26.004872+07
8f3153fd-fff7-4e4e-952d-e92cb8c89bca	Baked Sweet Potato	Baked sweet potato with cottage cheese topping	\N	{dinner,lunch}	320	16.0	48.0	6.0	7.0	1	piece	t	\N	2026-06-26 22:34:26.004872+07	2026-06-26 22:34:26.004872+07
3e397f1d-38a4-4da9-ad1c-1a18ac1b2b1a	Chicken Steak Bowl	Grilled chicken with rice, beans, and salsa	\N	{lunch,dinner}	550	40.0	52.0	16.0	8.0	1	bowl	t	\N	2026-06-26 22:34:26.004872+07	2026-06-26 22:34:26.004872+07
23843cca-d53f-4d2a-80b1-8132b7dfc53f	Tofu Stir Fry	Firm tofu with broccoli and brown rice	\N	{dinner,lunch}	380	22.0	40.0	14.0	6.0	1	plate	t	\N	2026-06-26 22:34:26.004872+07	2026-06-26 22:34:26.004872+07
6a1acdc7-2e31-462a-9d44-618c07eed4a9	Salmon Quinoa Bowl	Grilled salmon with quinoa and roasted vegetables	\N	{dinner}	530	40.0	42.0	20.0	6.0	1	bowl	t	\N	2026-06-26 22:34:26.004872+07	2026-06-26 22:34:26.004872+07
4f78181e-e1cc-46c4-8a2a-bb4b51d93b06	Tuna Wrap	Whole wheat wrap with tuna salad and veggies	\N	{lunch}	380	28.0	35.0	14.0	4.0	1	wrap	t	\N	2026-06-26 22:34:26.004872+07	2026-06-26 22:34:26.004872+07
de088641-13ee-4cfd-bbcc-79436ccf5a2a	Grilled Chicken Breast	Seasoned chicken breast grilled to perfection	\N	{lunch,dinner}	285	42.0	0.0	12.0	0.0	200	gram	t	\N	2026-06-26 22:34:26.004872+07	2026-06-26 22:34:26.004872+07
f7f203cf-33e0-4226-ace8-651b29354b6d	Greek Yogurt Parfait	Greek yogurt with granola and mixed berries	\N	{breakfast,snack}	280	18.0	35.0	8.0	3.0	1	cup	t	\N	2026-06-26 22:34:26.004872+07	2026-06-26 22:34:26.004872+07
a7ef1e18-cb65-41ab-a3b7-ae374e74a463	Brown Rice & Salmon	Pan-seared salmon with steamed brown rice and vegetables	\N	{lunch,dinner}	520	38.0	45.0	18.0	4.0	1	plate	t	\N	2026-06-26 22:34:26.004872+07	2026-06-26 22:34:26.004872+07
4b73ef83-c0e3-4095-8a43-5a56b0ffc456	Chicken Caesar Salad	Romaine lettuce with grilled chicken and caesar dressing	\N	{lunch}	420	35.0	12.0	26.0	3.0	1	bowl	t	\N	2026-06-26 22:34:26.004872+07	2026-06-26 22:34:26.004872+07
15f4ae86-4fef-422a-8b53-05774e0b35f8	Protein Bar	High protein energy bar	\N	{snack}	220	20.0	25.0	8.0	3.0	1	bar	t	\N	2026-06-26 22:34:26.004872+07	2026-06-26 22:34:26.004872+07
a5edfc14-7083-4276-8bb1-bd41739ac8bb	Chicken Breast with Caprese Salad	Grilled chicken with tomato, mozzarella and basil	\N	{lunch,dinner}	480	45.0	8.0	28.0	2.0	1	plate	t	\N	2026-06-26 22:34:26.004872+07	2026-06-26 22:34:26.004872+07
1889733b-1c1f-4582-b579-ca5c687baad1	Hard Boiled Eggs	Two hard boiled eggs	\N	{snack}	155	13.0	1.0	11.0	0.0	2	eggs	t	\N	2026-06-26 22:34:26.004872+07	2026-06-26 22:34:26.004872+07
3d141826-209d-4e76-a04a-0855bdff0014	Avocado Toast	Smashed avocado on sourdough with egg	\N	{breakfast,lunch}	390	14.0	32.0	24.0	8.0	1	serving	t	\N	2026-06-26 22:34:26.004872+07	2026-06-26 22:34:26.004872+07
ec85fc36-3ae6-4dca-a58f-cfcc78d7ab07	Oatmeal with Banana	Classic whole grain oats topped with sliced banana and honey	\N	{breakfast}	350	12.0	58.0	7.0	6.0	1	bowl	t	\N	2026-06-26 22:34:26.004872+07	2026-06-26 22:34:26.004872+07
6a7f3917-77ec-42f0-8c50-d4c4c1730172	Protein Smoothie Bowl	Blended protein shake with fruits and toppings	\N	{breakfast}	420	30.0	48.0	10.0	5.0	1	bowl	t	\N	2026-06-26 22:34:26.004872+07	2026-06-26 22:34:26.004872+07
ff945bd5-9829-41b9-a5a6-56f3bbf0f313	Scrambled Eggs on Toast	Two scrambled eggs on whole wheat toast	\N	{breakfast}	380	22.0	30.0	18.0	3.0	1	serving	t	\N	2026-06-26 22:34:26.004872+07	2026-06-26 22:34:26.004872+07
a6e1d3bb-8975-4ec6-aef5-a80c05bb6cbe	Banana with Peanut Butter	Fresh banana with natural peanut butter	\N	{snack,breakfast}	290	8.0	35.0	16.0	4.0	1	serving	t	\N	2026-06-26 22:34:26.004872+07	2026-06-26 22:34:26.004872+07
bc57ec30-a6ad-4a1b-bc2f-f9b1895a7873	Mixed Nuts	Almonds, cashews, and walnuts	\N	{snack}	280	10.0	12.0	22.0	4.0	50	gram	t	\N	2026-06-26 22:34:26.004872+07	2026-06-26 22:34:26.004872+07
\.


--
-- Data for Name: form_fields; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.form_fields (id, form_id, label, field_type, required, options, sort_order) FROM stdin;
6b6b11b1-483e-433d-8cea-c71c379b2871	7a7385cd-adb4-4d6b-846a-4c0d51ad5ce5	Current fitness level	select	t	{"choices": ["Beginner", "Intermediate", "Advanced"]}	1
2636a994-2bde-45b8-8048-bb4032594a5c	7a7385cd-adb4-4d6b-846a-4c0d51ad5ce5	How many days per week can you train?	select	t	{"choices": ["1-2 days", "3-4 days", "5-6 days", "Every day"]}	2
28e75c33-488a-4e62-8b94-5c0be4bd76ef	7a7385cd-adb4-4d6b-846a-4c0d51ad5ce5	Do you have any injuries or medical conditions?	textarea	t	\N	3
7876b913-4b1e-4498-913f-013ab4ff0bd0	7a7385cd-adb4-4d6b-846a-4c0d51ad5ce5	What are your fitness goals?	multi_select	t	{"choices": ["Lose weight", "Build muscle", "Improve endurance", "Flexibility", "General health"]}	0
ca90715b-b6c1-40f8-a82b-12c15c839f5a	7a7385cd-adb4-4d6b-846a-4c0d51ad5ce5	Preferred training time	select	f	{"choices": ["Morning (6-9 AM)", "Midday (10 AM-1 PM)", "Afternoon (2-5 PM)", "Evening (6-9 PM)"]}	4
c318f13d-cc06-4c51-ad52-5913bbf6a7af	7a7385cd-adb4-4d6b-846a-4c0d51ad5ce5	Rate your nutrition knowledge (1-5)	rating	f	{"max": 5, "min": 1}	5
\.


--
-- Data for Name: form_responses; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.form_responses (id, form_id, user_id, answers, submitted_at) FROM stdin;
\.


--
-- Data for Name: forms; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.forms (id, name, description, status, is_system, created_by, created_at, updated_at) FROM stdin;
e1157131-e99b-48c9-8458-05c1e6da44db	Nutrition Assessment	Assess dietary habits and preferences for meal planning.	published	t	\N	2026-06-26 22:34:26.242616+07	2026-06-26 22:34:26.242616+07
b962a75d-602d-4907-8e39-c61b671f0e86	Injury & Health Assessment	Pre-training health screening and injury history form.	published	t	\N	2026-06-26 22:34:26.242616+07	2026-06-26 22:34:26.242616+07
7a7385cd-adb4-4d6b-846a-4c0d51ad5ce5	Client Onboarding Form	Collect essential information from new clients before their first session.	published	t	\N	2026-06-26 22:34:26.242616+07	2026-06-26 22:34:26.242616+07
9d81f834-708c-413b-add0-cd6ef8ee79e4	Weekly Check-in Form	Weekly progress check-in questionnaire for active clients.	published	t	\N	2026-06-26 22:34:26.242616+07	2026-06-26 22:34:26.242616+07
\.


--
-- Data for Name: group_members; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.group_members (id, group_id, user_id, role, joined_at) FROM stdin;
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.groups (id, name, description, image_url, max_members, created_by, created_at, updated_at) FROM stdin;
d3184283-effc-4073-8563-3d00bafc3fff	Weight Loss Squad	Dedicated group for weight loss transformation clients	\N	15	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	2026-06-26 22:34:26.278746+07	2026-06-26 22:34:26.278746+07
7fa7b87f-44a4-42c2-98fb-38c3d245e133	Morning Warriors	Early morning training group â€” 6 AM sessions	\N	12	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	2026-06-26 22:34:26.278746+07	2026-06-26 22:34:26.278746+07
9d8e2a3c-3a45-4334-9ba0-c05304604e18	Yoga & Wellness	Mind-body balance group sessions	\N	20	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	2026-06-26 22:34:26.278746+07	2026-06-26 22:34:26.278746+07
4fce3c24-e080-4504-9e27-752597f1a5db	Muscle Builders	Hypertrophy-focused training group	\N	10	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	2026-06-26 22:34:26.278746+07	2026-06-26 22:34:26.278746+07
8343e5d5-9a9f-47d3-bc59-d774598c68a7	Competition Prep	Athletes preparing for competitions	\N	8	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	2026-06-26 22:34:26.278746+07	2026-06-26 22:34:26.278746+07
\.


--
-- Data for Name: habit_folders; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.habit_folders (id, name, sort_order, created_by, created_at, updated_at) FROM stdin;
077c1eed-3cc8-4d3c-a9ad-3d11f02e4fd2	Mindfulness	4	\N	2026-06-26 22:34:26.136409+07	2026-06-26 22:34:26.136409+07
6b07baaf-a7ec-412b-b373-77dd44b5afce	Active Living / Movement	3	\N	2026-06-26 22:34:26.136409+07	2026-06-26 22:34:26.136409+07
f8ac48b3-dcb6-4297-9929-31f229996d9b	Nutrition Portion Guides	1	\N	2026-06-26 22:34:26.136409+07	2026-06-26 22:34:26.136409+07
d1bb01f6-4105-4a7e-a288-f37921b5f69a	Nutrition	2	\N	2026-06-26 22:34:26.136409+07	2026-06-26 22:34:26.136409+07
6154b69a-ef5c-478e-8852-82c68dd80de2	Sleep	5	\N	2026-06-26 22:34:26.136409+07	2026-06-26 22:34:26.136409+07
\.


--
-- Data for Name: habit_logs; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.habit_logs (id, user_id, habit_id, logged_at, completed, notes) FROM stdin;
\.


--
-- Data for Name: habits; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.habits (id, folder_id, name, description, icon, is_system, created_by, created_at, updated_at) FROM stdin;
31fdd568-168d-4451-826d-837d2c2c1e0d	f8ac48b3-dcb6-4297-9929-31f229996d9b	Eat good fats	This habit focuses on having clients consume good fats with each of their meals.	fat	t	\N	2026-06-26 22:34:26.14973+07	2026-06-26 22:34:26.14973+07
63af3583-ef9e-442c-bdeb-d79fc0ae7329	f8ac48b3-dcb6-4297-9929-31f229996d9b	Eat complex carbs	This habit focuses on having clients consume complex carbs with each of their meals.	carbs	t	\N	2026-06-26 22:34:26.14973+07	2026-06-26 22:34:26.14973+07
6702a021-2965-4d99-90a4-9a8cc2b4d3f0	f8ac48b3-dcb6-4297-9929-31f229996d9b	Eat protein	This habit focuses on having clients consume protein with each of their meals.	protein	t	\N	2026-06-26 22:34:26.14973+07	2026-06-26 22:34:26.14973+07
8017fc76-a380-4391-9b2a-208e9ddb0745	f8ac48b3-dcb6-4297-9929-31f229996d9b	Follow portion guides	This habit focuses on having clients practice following portion guides for their meals.	portion	t	\N	2026-06-26 22:34:26.14973+07	2026-06-26 22:34:26.14973+07
ecb1dd22-2e52-472a-bd97-438b4651e6eb	f8ac48b3-dcb6-4297-9929-31f229996d9b	Eat vegetables	This habit focuses on having clients consume vegetables with each of their meals.	vegetable	t	\N	2026-06-26 22:34:26.14973+07	2026-06-26 22:34:26.14973+07
98a457e3-b048-4c57-90a2-25999f903c68	d1bb01f6-4105-4a7e-a288-f37921b5f69a	Drink enough water	Drink at least 8 glasses of water throughout the day.	water	t	\N	2026-06-26 22:34:26.153693+07	2026-06-26 22:34:26.153693+07
7f529ebe-f25b-4eed-babe-442b8507abfa	d1bb01f6-4105-4a7e-a288-f37921b5f69a	Avoid sugary drinks	Replace sodas and juices with water or unsweetened beverages.	no_sugar	t	\N	2026-06-26 22:34:26.153693+07	2026-06-26 22:34:26.153693+07
a3f607eb-e709-40bd-8c51-6f26770d1835	d1bb01f6-4105-4a7e-a288-f37921b5f69a	Eat slowly	Practice mindful eating by taking at least 20 minutes per meal.	clock	t	\N	2026-06-26 22:34:26.153693+07	2026-06-26 22:34:26.153693+07
03e63190-fa39-47ba-8950-d0deac3a3c3f	d1bb01f6-4105-4a7e-a288-f37921b5f69a	Prepare meals in advance	Meal prep for the next day or the week ahead.	meal_prep	t	\N	2026-06-26 22:34:26.153693+07	2026-06-26 22:34:26.153693+07
e8fffdaa-d099-4ca1-9cc0-df2cd1d0c09d	d1bb01f6-4105-4a7e-a288-f37921b5f69a	Eat until 80% full	Stop eating when you feel satisfied, not stuffed.	plate	t	\N	2026-06-26 22:34:26.153693+07	2026-06-26 22:34:26.153693+07
ad9cfa27-f25f-4b32-98ae-4a5c1a692fc1	6b07baaf-a7ec-412b-b373-77dd44b5afce	Take 10,000 steps	Walk at least 10,000 steps throughout the day.	steps	t	\N	2026-06-26 22:34:26.15492+07	2026-06-26 22:34:26.15492+07
0b625de3-c3d2-4baa-8353-ddd0ea4bb8d4	6b07baaf-a7ec-412b-b373-77dd44b5afce	Stretch for 10 minutes	Perform a 10-minute stretching routine daily.	stretch	t	\N	2026-06-26 22:34:26.15492+07	2026-06-26 22:34:26.15492+07
81dc90bb-785d-493b-b113-1c0d71dc64fa	6b07baaf-a7ec-412b-b373-77dd44b5afce	Stand up every hour	Get up and move around for at least 2 minutes every hour.	stand	t	\N	2026-06-26 22:34:26.15492+07	2026-06-26 22:34:26.15492+07
d0c34375-fbfe-45aa-8244-f4db8d30fc75	6b07baaf-a7ec-412b-b373-77dd44b5afce	Take the stairs	Choose stairs over elevators whenever possible.	stairs	t	\N	2026-06-26 22:34:26.15492+07	2026-06-26 22:34:26.15492+07
49e2d15e-5098-481f-aefb-8dbc7ec601c7	077c1eed-3cc8-4d3c-a9ad-3d11f02e4fd2	Practice gratitude	Write down 3 things you are grateful for today.	gratitude	t	\N	2026-06-26 22:34:26.155962+07	2026-06-26 22:34:26.155962+07
74aae3bf-9818-44fd-8dfa-8626d4aee4ae	077c1eed-3cc8-4d3c-a9ad-3d11f02e4fd2	Meditate for 5 minutes	Practice 5 minutes of guided or silent meditation.	meditation	t	\N	2026-06-26 22:34:26.155962+07	2026-06-26 22:34:26.155962+07
3d9e838f-050c-4e5c-9470-dd951825b0f1	077c1eed-3cc8-4d3c-a9ad-3d11f02e4fd2	Journal your thoughts	Spend 5 minutes writing in your journal.	journal	t	\N	2026-06-26 22:34:26.155962+07	2026-06-26 22:34:26.155962+07
571c2009-22b3-46c1-9a4c-c9acc15a6b36	077c1eed-3cc8-4d3c-a9ad-3d11f02e4fd2	Deep breathing exercises	Do 5 rounds of deep belly breathing.	breathing	t	\N	2026-06-26 22:34:26.155962+07	2026-06-26 22:34:26.155962+07
d0dce06a-1c80-4f39-a514-1f662f8ec28f	6154b69a-ef5c-478e-8852-82c68dd80de2	Sleep 7-8 hours	Aim for 7 to 8 hours of quality sleep each night.	sleep	t	\N	2026-06-26 22:34:26.156811+07	2026-06-26 22:34:26.156811+07
02319013-e5c0-4427-b542-9deee44c4331	6154b69a-ef5c-478e-8852-82c68dd80de2	Consistent bedtime	Go to bed at the same time every night.	bedtime	t	\N	2026-06-26 22:34:26.156811+07	2026-06-26 22:34:26.156811+07
5f9397c7-72ae-42e4-bf97-574cb6f7456a	6154b69a-ef5c-478e-8852-82c68dd80de2	No screens before bed	Avoid screens for at least 30 minutes before bedtime.	no_screen	t	\N	2026-06-26 22:34:26.156811+07	2026-06-26 22:34:26.156811+07
\.


--
-- Data for Name: health_articles; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.health_articles (id, title, content, image_url, source, is_published, created_at, updated_at, title_en, content_en) FROM stdin;
7725c1df-d815-483b-8100-a94aff7bf3fb	Hidrasi Tepat: Kunci Utama Performa Maksimal	Minum air yang cukup bukan sekadar menghilangkan rasa haus. Saat kita berolahraga, tubuh kehilangan cairan dan elektrolit melalui keringat. Kekurangan cairan hingga 2% dari berat badan dapat menurunkan performa atletik secara drastis, memicu kram otot, dan mempercepat kelelahan. Direkomendasikan untuk mengonsumsi 500ml air 2 jam sebelum latihan, dan 150-200ml setiap 15-20 menit selama latihan intensitas tinggi.	https://images.unsplash.com/photo-1548690312-e3b507d8c110?q=80&w=600&auto=format&fit=crop	dr. Andi Wijaya, Sp.KO	t	2026-06-26 22:34:24.076265+07	2026-06-26 22:34:24.076265+07	\N	\N
91577c60-cf3c-4441-becf-5a131141a56c	Pentingnya Tidur Berkualitas Bagi Pertumbuhan Otot	Banyak orang mengira otot tumbuh saat mereka mengangkat beban di gym. Faktanya, latihan beban merobek serat otot (micro-tears), dan proses perbaikan serta pertumbuhan otot yang sebenarnya terjadi saat kita beristirahat, terutama selama fase deep sleep. Selama tidur nyenyak, tubuh melepaskan hormon pertumbuhan (Human Growth Hormone) yang sangat krusial untuk pemulihan jaringan. Kurang tidur kronis terbukti meningkatkan hormon stres kortisol yang justru bersifat katabolik (memecah otot).	https://images.unsplash.com/photo-1511295742364-92b9345f8e00?q=80&w=600&auto=format&fit=crop	dr. Budi Utomo, Sp.N	t	2026-06-26 22:34:24.076265+07	2026-06-26 22:34:24.076265+07	\N	\N
71138cbb-6ab6-4aec-bee0-7a5f1c19c3f6	Strategi Mengatur Asupan Protein Harian	Protein adalah makronutrisi pembangun utama tubuh. Bagi individu aktif, kebutuhan protein berkisar antara 1.6 hingga 2.2 gram per kilogram berat badan setiap hari. Dibandingkan mengonsumsi seluruh protein dalam satu kali makan besar, membagi asupan protein menjadi 20-40 gram per sesi makan setiap 3-4 jam terbukti lebih efektif untuk menstimulasi sintesis protein otot secara berkelanjutan sepanjang hari.	https://images.unsplash.com/photo-1532550907401-a500c9a57435?q=80&w=600&auto=format&fit=crop	dr. Sarah Smith, Sp.GK	t	2026-06-26 22:34:24.076265+07	2026-06-26 22:34:24.076265+07	\N	\N
\.


--
-- Data for Name: lab_consultations; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.lab_consultations (id, user_id, consultant_id, assessment_id, payment_id, status, fee_amount, booking_note, preferred_at, scheduled_at, completed_at, result_summary, result_payload, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: meal_plan_items; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.meal_plan_items (id, meal_plan_id, meal_type, day_of_week, food_name, portion, calories, protein_g, carbs_g, fat_g) FROM stdin;
\.


--
-- Data for Name: meal_plans; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.meal_plans (id, name, description, daily_calories, protein_g, carbs_g, fat_g, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: medicines; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.medicines (id, name, category, main_function, side_effects, detail_url, image_url, is_system, created_by, created_at, updated_at) FROM stdin;
0713e532-271a-484a-8da5-4ad6e1137117	Allopurinol	Penghambat xanthine-oxidase	Asam Urat, Batu Ginjal	Sakit perut, Mual, Muntah ,Diare ,Kantuk, Pusing ,Sakit kepala, Kehilangan fungsi indra pengecap, Gatal-gatal, Rambut rontok, Ruam kulit, Urine berkurang atau nyeri, Memar. Kebas, Gangguan hati	https://www.alodokter.com/allopurinol	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
b01dcbbf-32b9-462c-8e8a-541d0ae72b25	Amlodipine	Antagonis Calsium	Hipertensi, Angina	Kantuk, Pusing, Lelah, Sakit perut, Mual, Kulit wajah atau leher memerah, Jantung berdebar, Nyeri dada. Kaki atau pergelangan kaki bengkak. Mata dan kulit menguning.	https://www.alodokter.com/amlodipine	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
b38807fb-f857-489f-9604-aa5dd5b1e6b4	Angintriz	Agen Metabolic Anti-Ischemic	Angina Pectoris	Pusing, sakit kepala, sakit perut, sakit maag, diare, lemas, mual, muntah, sembelit, atau timbul ruam kulit yang terasa gatal.\r\nGejala ekstrapiramidal, seperti otot kaku, sulit mengontrol gerakan, tremor, atau gangguan keseimbangan\r\nJantung berdebar atau berdetak tidak beraturan\r\nTekanan darah rendah akibat perubahan posisi (hipotensi ortostatik), yang dapat menyebabkan pusing atau pingsan\r\nWajah, leher, atau dada bagian atas memerah (flushing)\r\nTubuh mudah memar atau berdarah\r\nPenyakit liver, yang bisa ditandai dengan kulit dan mata menguning\r\nInfeksi, yang bisa ditandai dengan demam, menggigil, lelah, atau nyeri otot\r\nReaksi alergi obat, yang bisa ditandai dengan bengkak di wajah, bibir, mulut, lidah, atau di tenggorokan sehingga menyebabkan sulit bernapas	https://www.alodokter.com/aloshop/products/angintriz-mr-10-tablet/62a18eeff15ee840f565ed99	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
d65600cc-b3a8-4c04-aa18-4ed5a393b430	Arcalion	Sulbutiamine	Suplemen Vit B1	agitasi ringan, reaksi alergi kulit.	https://www.alodokter.com/aloshop/products/arcalion-200-mg-6-tablet/5fb386cf41ab59059e869d41	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
6ca6e320-56da-4546-8a94-4499797a166e	Ardium	Micronized Purified Flavonoid Fraction 500 mg setara dengan diosmin 90% dan hesperidin 10%	Obat Wasir & Varises	sakit perut, diare, pusing, atau sakit kepala.	https://www.alodokter.com/aloshop/products/ardium-500-mg-15-tablet/5fcd84a441ab590e7c94f7b9	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
05ce8d69-c0e4-4c00-b764-c4b4245abb80	Aromasin / Exemestane	aromatase inhibitor	Anti Kanker Payudara	Hot flashes atau rasa dan sensasi panas dan gerah, Mual, Rambut rontok, Sakit kepala, pusing, atau lelah, Nafsu makan meningkat, Nyeri otot, Sulit tidur	https://www.alodokter.com/exemestane	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
1e49380b-2803-4eb6-9706-cdfb17a57fce	Atorvastatin	Statin	Kolesterol, Trigliseda	Nyeri sendi dan otot, Sakit kepala, Hidung tersumbat, sakit tenggorokan, Diare, Mual, Konstipasi, Kembung, Mimisan	https://www.alodokter.com/atorvastatin	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
fb3963b7-4a10-40ba-a17f-85f2d624a1b9	Avodart / Dutasteride	Penghambat 5-alpha-reductase	pembesaran prostat jinak atau benign prostatic hyperplasia (BPH)	Disfungsi ereksi\r\nGangguan ejakulasi\r\nPenurunan libido\r\nNyeri atau bengkak pada buah zakar	https://www.alodokter.com/aloshop/products/avodart-0%2C5-mg-10-kapsul/5fb3890b41ab59059e86a373	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
97aa59b3-4dbe-457a-80c4-f55eb799775e	Candesartan	Angiotensin receptor blocker	Hipertensi, Gagal Jantung	Sakit kepala, Nyeri punggung, Pusing, Batuk. Bersin, Hidung tersumbat, Ruam kulit, Gejala Hiperkalemia, Urine berkurang	https://www.alodokter.com/candesartan	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
59effd1f-aa14-412f-8bdf-20b3072f1e5a	Clopidogrel	Obat antiplatelet	Mencegah stroke dan penggumpalan darah	Diare, Mudah mengalami memar atau perdarahan, Perdarahan sulit berhenti, Sembelit, Rasa terbakar di dada (heartburn), Nyeri perut, Kulit atau bagian putih mata (sklera) menguning atau penyakit kuning , Kelelahan	https://www.alodokter.com/clopidogrel	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
81090a39-cd0e-4d7c-9675-bcda449188a0	Concor	Antihipertensi jenis penghambat beta	hipertensi, gagal jantung kronis, dan angina pektoris	Gejala gangguan pencernaan, Pusing, Sakit kepala, Kelelahan, Insomnia atau sulit tidur, Nyeri otot atau nyeri sendi, Mulut kering, Hidung meler, batuk, sakit tenggorokan\r\nTangan dan kaki dingin, kesemutan, mati rasa, atau tampak kebiruan\r\nDenyut jantung sangat lambat (Bradikardia)\r\nPusing berat seperti akan pingsan\r\nGangguan penglihatan, nyeri mata\r\nBronkospasme, yang gejalanya antara lain mengi, dada terasa sesak, atau sulit bernapas lega\r\nPerubahan mental, seperti linglung, mood swing, atau depresi\r\nGagal jantung yang baru muncul atau bertambah parah, yang gejalanya bisa berupa sesak napas, bengkak di tungkai atau pergelangan kaki, tubuh terasa sangat lelah, berat badan naik mendadak	https://www.alodokter.com/concor	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
1bd3763c-c61c-4f7f-a37b-f195d6fa9947	Cordarone	Amiodarone	Aritmia Jantung	Mual\r\nMuntah\r\nKehilangan nafsu makan \r\nKonstipasi	https://www.alodokter.com/aloshop/products/cordarone-200-mg-10-tablet/5fb387a941ab59059e869fd2	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
aada1f5e-5e65-4512-92e4-746bf053ccbb	Coveram	Perindopril arginine 10 mg dan amlodipine 10 mg	Mengatasi hipertensi dan penyakit jantung koroner	Pusing, sakit kepala, wajah dan leher memerah (flushing), sakit perut, jantung berdebar, lelah, vertigo	https://www.alodokter.com/aloshop/products/coveram-10-mg-10-mg-30-tablet/6438c74f90e64fce9f2628f7	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
1339fb66-c6a6-44e9-aed9-ede084a622af	Crestor	Rosuvastatin	Kolesterol, Trigilesrida Tinggi	Sakit kepala, Pusing, Mual, Nyeri perut, Nyeri otot, Sembelit, Lemas atau tidak bertenaga, Gangguan ginjal	https://www.alodokter.com/crestor	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
4c42646e-d2f6-49a9-8ecd-edb1fd0be42b	Cyclo Proginova	Obat Hormon	Siklus Haid, Menopouse akibat kurang Esterogen	Payudara terasa kencang\r\nSpotting\r\nNyeri payudara\r\nPeningkatan berat badan\r\nMood swings\r\nPerut kembung\r\nMual	https://www.alodokter.com/aloshop/products/cyclo-progynova-21-tablet/5fb37d6b41ab59059e868785	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
89109441-d004-48e2-8d00-c1c933b9e87f	Dalfarol	Vitamin E / D-alfa tokoferol 200 IU	Anti Oksidan	Mual\r\nDiare\r\nPusing\r\nNyeri perut\r\nKelelahan\r\nPenglihatan kabur	https://www.alodokter.com/aloshop/products/dalfarol-200-iu-4-kapsul/62a18f11f15ee840f565eea6	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
3b6e80a0-6679-4266-ba0c-6089a3061c00	Disflatyl	Antiflatulensi / Simethicone	mengurangi perut kembung, sendawa, banyak buang angin, atau atau rasa tidak nyaman di perut akibat penumpukan gas pada saluran pencernaan.	Sendawa\r\nMual atau muntah\r\nSembelit atau malah diare\r\nHeartburn	https://www.alodokter.com/disflatyl	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
261620b2-ae8b-4fe3-891f-108f8d74bbe8	Eliquis	Anti-Koagulan / Apixaban	Mengurangi Penggumpalan Darah di pembuluh darah kaki dan paru-paru	Anemia, Memar, Mual, Pendarahan	https://www.halodoc.com/obat-dan-vitamin/eliquis-2-5-mg-10-tablet-1?srsltid=AfmBOopKpG-yZji8ZfpXirvEL9tZQop5oiYZ6huPPiUrJiS_rwTRz89v	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
0628c2f4-363d-4fb3-972e-fc3c61184af2	Equfina	50 mg Safinamide	Obat Parkinson, Meningkatkan Dopamin di otak	Gangguan Hati	https://registrasiobat.pom.go.id/files/assesment-reports/01700621318.pdf	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
8cfd4cdc-56fe-4abe-bb4d-d8291d47822e	Euthyrox	levothyroxine	hipotiroidisme	Rambut rontok pada bulan-bulan pertama konsumsi\r\nMuntah\r\nDiare \r\nSakit kepala\r\nSulit tidur\r\nRasa lelah\r\nNafsu makan bertambah\r\nHot flashes atau rasa hangat dan kemerahan pada kulit leher dan wajah\r\nKeringat berlebih\r\nPerubahan suasana hati\r\nKram pada kaki	https://www.alodokter.com/euthyrox	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
5806236d-e49d-4c08-b973-648fd0e5c430	Frego	Anti-Migrain, Anti-Histamin	Migrain, Vertigo dan Ganggian pada Vestibular	Kantuk, Mual, Heartburn, Kenaikan berat badan, Gelisah, Mulut kering, Nyeri otot, Kesulitan bergerak, Tremor, Gerakan berulang yang tidak disadari pada wajah atau mulut, Depresi	https://www.alodokter.com/aloshop/products/frego-5-mg-10-tablet/5fb382be41ab59059e869413	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
e0f5d9d2-a3b7-46d1-a486-f651a58517cf	Glucophage	metformin.	Anti-Diabetes	Perut kembung\r\nRasa panas di dada (heartburn)\r\nSembelit\r\nSakit kepala\r\nMual atau muntah\r\nDiare\r\nTidak selera makan\r\nGangguan indera pengecap, seperti rasa logam di mulut	https://www.alodokter.com/glucophage	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
e646b5d1-2529-4763-9591-fbada25443f0	Glucosamine	Suplemen Sendi	Nyeri Sendi, Osteoartritis	Mual\r\nMuntah\r\nNyeri ulu hati\r\nGangguan percernaan, seperti diare, sembelit, atau perut kembung\r\nPusing\r\nKantuk\r\nSakit kepala\r\nKelelahan\r\nRasa hangat pada wajah, leher, atau dada (flushing)\r\nReaksi alergi, seperti ruam, kemerahan, atau gatal pada kulit	https://www.alodokter.com/glucosamine	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
370c7e9d-6e1a-4de4-8970-906e9c235f28	Glucovan	Combo Metformin dan Glibenclamide	Anti-Diabetes	hipoglikemia adalah sulit berkonsentrasi, gemetar, pucat, keringat dingin, atau jantung berdebar. mual atau muntah, sakit maag, perut terasa penuh, dan diare.	https://www.alodokter.com/aloshop/products/glucovance-500-mg-2%2C5-mg-10-tablet/5fb388c241ab59059e86a2c5	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
d8abfcee-9fd0-4d1a-a441-edacc9d90a34	HCT	Hydrochlorothiazide	\N	\N	\N	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
39a8b686-b770-4a4e-8870-b35ae3aa851d	Irbesartan	Angina Reseptor (ARB)	Hipertensi dan terapi gagal jantung	Kelelahan dan sakit kepala. Diare dan maag. Nyeri otot dan sendi.	https://www.siloamhospitals.com/informasi-siloam/obat-dan-suplemen/irbesartan	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
c225299e-0e34-42b9-9593-5c60b0f04293	Isoprolol	Beta Blocker	Hipertensi	Denyut jantung yang sangat lambat (<60 kali per menit)\r\nPingsan\r\nTangan dan kaki dingin, pucat atau biru, dan nyeri\r\nPerubahan suasana hati, seperti mood swing\r\nSesak napas, bengkak pada pergelangan kaki, dan kelelahan yang berlebihan	https://www.alodokter.com/bisoprolol	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
3a98e4e0-f9c1-4cfb-9c90-925e452edcb8	Jardiance Duo	Combo Empagliflozin dan Metformin	Anti-diabetes	Sering haus\r\nSering buang air kecil\r\nLelah atau lemas\r\nSakit perut\r\nMual, muntah\r\nDiare\r\nRasa logam di mulut\r\nPusing hingga terasa seperti akan pingsan	https://www.alodokter.com/aloshop/products/jardiance-duo-12%2C5-mg-500-mg-10-tablet/62a18f84f15ee840f565f29d	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
39b65ad9-bc7f-4f66-8588-be10fad40f3b	Lipanthyl	Fenofibrate	Kolesterol dan Trigliserida	Sembelit\r\nDiare \r\nMual dan muntah\r\nPenyakit asam lambung\r\nSakit kepala\r\nNyeri punggung	https://www.alodokter.com/aloshop/products/lipanthyl-300-mg-6-kapsul/5fb3734b41ab59059e866eb9	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
45976fed-21f7-484a-9470-8b1a034671ba	Lipitor	Statin / Atorvastatin	Kolesterol dan Trigliserida	Nyeri sendi, nyeri otot, atau kram otot\r\nHidung tersumbat, sakit tenggorokan\r\nSakit perut\r\nDiare\r\nMual\r\nSulit tidur	https://www.alodokter.com/lipitor	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
25d4b995-9377-4025-96a4-165311711f3e	Lixiana	Anti-Koagulan	Stroke , Embolism, Afib	Anemia, Mimisan	https://www.halodoc.com/obat-dan-vitamin/lixiana-30-mg-14-tablet?srsltid=AfmBOoodGQJPqecOv2-Bcf3JbzxhpKrDXX8mTxyi-PGbTqMufJ-tlDU-	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
b4a48950-d7b0-44cf-9d2d-89774d47dc4a	Maltofer	Iron Polymaltose Complex	Penambah Darah (anti Anemia)	perubahan warna tinja, diare, mual, sakit perut, konstipasi, atau sakit maag.	https://www.alodokter.com/maltofer	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
a61a2457-24f3-4ebb-bfa9-90966fed5a55	Merislon	Antivertigo/Antihistamin H3	Obat Vertigo	Sakit maag\r\nPerut kembung\r\nSakit kepala\r\nMulut kering\r\nDiare	https://www.alodokter.com/merislon	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
259fe550-7e85-40cc-be08-51caddb4b879	Micardis	Angiotensin II receptor blocker (ARB) / Telmisartan	Hipertensi	Pusing, terutama setelah bangun tidur atau duduk\r\nSakit punggung\r\nHidung tersumbat, infeksi saluran pernapasan atas, radang sinus (sinusitis), atau infeksi saluran kemih	https://www.alodokter.com/aloshop/products/micardis-80-mg-10-tablet/5fb3899641ab59059e86a4de	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
496452ae-57ff-4cc4-a5b3-05b0cd3548cb	Modexa	Obat antiradang	meredakan gejala peradangan pada rhinitis alergi atau polip hidung.	sakit kepala, mimisan, bersin, atau hidung terasa perih.	https://www.alodokter.com/aloshop/products/modexa-0%2C05%25-nasal-spray-60-dosis/61b37f43b5a5e2062d979b0b	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
d85bd434-75eb-4e1a-a7f6-7e07e29dd18e	Neurobion	Suplemen Vit B	Produksi sel darah merah	Diare\r\nSakit perut\r\nSering buang air kecil\r\nKerusakan saraf	https://www.alodokter.com/aloshop/products/neurobion-10-tablet/5fb38a0341ab59059e86a5f8	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
d5cc5a7c-9cb7-45c5-ab51-8e3a4a5a661d	Nexium	Penghambat pompa proton / Esomeprazole	obat penurun asam lambung	Sakit kepala\r\nMual atau muntah\r\nMasuk angin atau kembung\r\nSakit perut\r\nDiare atau malah sembelit	https://www.alodokter.com/nexium	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
e8e1ec69-feb9-4f8c-807a-41a70ba0c5a6	Nitrokaf Retard	Nitrat / Nitroglycerin	Pengobatan Angina Pectoris	Sakit kepala yang sangat berat dan tidak membaik bahkan setelah nitrogliserin dihentikan\r\nPusing berat seperti akan pingsan\r\nDenyut jantung terlalu cepat, terlalu lambat, atau tidak beraturan\r\nJantung berdebar atau terasa seperti bergetar\r\nPenglihatan buram atau mulut kering\r\nPucat dan keringat dingin\r\nNapas pendek dan cepat	https://www.alodokter.com/nitrogliserin	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
9077c050-d363-495b-bea8-e6f49329bb24	Norvask	antagonis kalsium / Amlodipin besilate	terapi hipertensi dan anti angina	sakit kepala, kelelahan, rasa panas dan kemerahan pada wajah, pusing, edema, mual, palpitasi, nyeri perut, somnolen	https://www.k24klik.com/p/norvask-5mg-tab-30s-112#	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
d2d5a474-c29e-40b6-a1c0-b66e567a11b5	Omletec	\N	\N	\N	\N	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
a1bb12d7-9d0f-4591-a536-b6365e611dd8	Pradaxa	Antikoagulan / dabigatran etexilate.	Pengencer Darah	Mudah memar, gusi berdarah terus menerus, sering mimisan dan lama berhenti\r\nBatuk darah, muntah darah, urine berdarah, BAB berdarah atau berwarna hitam\r\nPingsan\r\nLemas atau lelah\r\nSakit kepala yang sangat berat\r\nMenstruasi yang berat atau berlangsung lebih lama (menorrhagia)	https://www.alodokter.com/aloshop/products/pradaxa-150-mg-10-kapsul/62a18ec7f15ee840f565ec38	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
3daae3c8-9bfd-4682-9d11-332f19c68e8e	Prorenal	Suplemen Asam Amino	Terapi Gagal Ginjal	Kelelahan\r\nKehilangan kordinasi tubuh\r\nSakit kepala\r\nRasa nyeri\r\nGangguan lambung\r\nMual\r\nPerut kembung\r\nDiare	https://www.alodokter.com/aloshop/products/prorenal-10-kaplet/5fb3892641ab59059e86a3cb	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
0022f2cd-ae73-41ee-943e-6df3193818d5	Prostam	Tamsulosin	Pembesaran Prostat Jinak	gangguan fungsi hati, ikterus, pusing, sakit kepala, gelisah, penurunan tekanan darah, hipotensi ortostatik, takikardia, palpitasi, gatal, ruam, gangguan gastrointestinal, obstruksi nasal, edema, inkontinensia urin, rasa panas terbakar pada faring, kelelahan	https://www.alodokter.com/aloshop/products/prostam-sr-0%2C4-mg-10-tablet/62a18f34f15ee840f565efe1#:~:text=Prostam%20merupakan%20obat%20dengan%20kandungan,(BPH)%20pada%20pria%20dewasa.	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
c80595df-5535-43b5-974a-ddc885ac5a16	Ramipril	ACE inhibitor	antihipertensi	Pusing berat seperti akan pingsan\r\nLinglung\r\nGejala angioedema, misalnya bengkak di wajah, lidah, tangan atau kaki\r\nGejala hiperkalemia, seperti denyut jantung terlalu cepat, lambat, atau tidak beraturan; lemah otot, sesak napas\r\nGangguan fungsi ginjal, yang gejalanya berupa jarang berkemih, urine yang keluar makin sedikit atau tidak keluar sama sekali\r\nGangguan fungsi hati, yang gejalanya bisa meliputi sakit perut berat, urine berwarna gelap, tinja berwarna pucat seperti dempul, atau penyakit kuning	https://www.alodokter.com/ramipril	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
b9e601b9-f361-441f-ba21-03aa08a8585f	Maltofer	Iron Polymaltose Complex	Penambah Darah (anti Anemia)	perubahan warna tinja, diare, mual, sakit perut, konstipasi, atau sakit maag.	https://www.alodokter.com/maltofer	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
215ab004-f8d1-4de1-b0c7-65033f9af9fb	Regumen	Peningkat hormon Pregesteron / Norethisterone	Pengobatan perdarahan rahim disfungsional, endometriosis, metropati hemoragika, sindroma pra-menstruasi, penundaan waktu haid, menoragi & dismenore	Gangguan fungsi hati, ikterus, eksaserbasi epilepsi & migren, jerawat, urtikaria, retensi urin, gangguan sal cerna, perubahan libido, rasa tdk nyaman pd payudara, gejala pra menstruasi, siklus mens tdk teratur, mual, insomnia, alopesia, hirsutisme (pd penggunaan lama), depresi & somnolen.	https://www.alodokter.com/aloshop/products/regumen-5-mg-10-tablet/62a1874ef15ee840f565e8da	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
9ee950f7-76d5-4e01-80c4-e8f7e1ac98ea	Seloxy	Suplemen Vitamin	Anti Oksidan , Metabolism Booster	diare, pusing, nyeri sendi, mual, sakit perut, kram perut, perdarahan atau memar, dan warna kulit menjadi kuning.	https://www.alodokter.com/aloshop/products/seloxy-6-kaplet/61b380dbb5a5e2062d979d99	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
5f2319ed-aa4e-419a-9b38-a786a3391aab	Simvastatin	Statin	Kolesterol dan Trigliserida	Nyeri otot seperti kram dan otot yang melemah.\r\nGangguan pencernaan seperti mual, muntah, dan diare.\r\nSakit kepala.\r\nPeningkatan enzim hati.	https://www.halodoc.com/kesehatan/simvastatin	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
59a5ada3-bd0d-4a6d-9403-b69bf2cbb04d	Suvesco	Rosuvastatin 10 mg	Obat penurun kolesterol golongan statin	Sakit kepala\r\nMual\r\nPegal atau nyeri otot\r\nSakit perut\r\nLemas	https://www.alodokter.com/aloshop/products/suvesco-10-mg-10-tablet/62a19119f15ee840f56600b6	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
553ad2ec-e8f3-45f2-b5f8-acc653520aaf	Tamsulosin	penghambat alfa (alpha blocker)	Masalah Pembesaran Prostat	Pusing atau pening\r\nHidung meler atau tersumbat\r\nKantuk\r\nMual atau muntah\r\nDiare\r\nKonstipasi atau sembelit\r\nGangguan ejakulasi	https://www.alodokter.com/tamsulosin	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
c31171c5-cb1b-4b8e-aa12-1e854ebb652a	Tebokan	Gingko Biloba, Herbal	Untuk sirkulasi darah di susunan saraf	\N	https://www.halodoc.com/obat-dan-vitamin/tebokan-forte-120-mg-15-tablet?srsltid=AfmBOoo1opgL71XkWreEyzRgReNArdfPIBJspLmO934LO-lRsXk9Bj3L	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
bf6aa9af-bdb2-422d-885b-1d89af00f99e	Tegretol	Carbamazepine	antikonvulsan atau antikejang	Kantuk\r\nPusing\r\nMual atau muntah\r\nMulut kering\r\nSembelit\r\nTremor\r\nSulit berkonsentrasi atau berpikir\r\nGangguan keseimbangan, misalnya sempoyongan saat berjalan	https://www.alodokter.com/tegretol	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
5462d3b7-ae7a-478d-a54b-0b789454b328	Trizedon	antianginal	antianginal	pusing, mual dan muntah	\N	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
4ab18d1e-899d-46c4-8b49-bb121c3e4d38	Twynsta	Angiotensin II receptor blocker (ARB) dan antagonis kalsium / Telmisartan dan amlodipine	Anti Hipertensi parah	Pusing berat seperti akan pingsan\r\nRasa lemah yang tidak wajar\r\nJantung berdebar atau berdetak tidak beraturan\r\nSesak napas, bahkan saat beraktivitas ringan\r\nBerat badan naik drastis tanpa penyebab yang jelas\r\nNyeri dada atau perburukan nyeri dada yang sebelumnya sudah ada\r\nGemetar\r\nBuang air kecil berkurang atau terasa sakit dan sulit\r\nKencing berdarah\r\nOtot kaku atau kedutan	https://www.alodokter.com/twynsta	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
ef7d22f1-b9fd-4866-abc3-521be8ac2cae	Uritos	Imidafenacine	Gangguan Kandung Kemih dan Prostat.	Mulut kering\r\nSembelit.\r\nFotofobia: penglihatan kabur\r\nKantuk\r\nKetidaknyamanan perut\r\nPeningkatan trigliserida dan peningkatan Î³-GTP.	https://www.klikdokter.com/obat/obat-saluran-kemih-dan-prostat/uritos?srsltid=AfmBOooToVlP1gc1E72fB_Hqr-pe0A911I2ZVnPg-vwPLaY9b8f3MpE8	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
f73afe7c-418c-4c89-8bd6-ca96040fac92	Vitamin D	Suplemen vitamin	osteoporosis, hipoparatiroid, rakitis, hipofosfatemia	Mual atau muntah\r\nMudah haus\r\nSering buang air kecil\r\nTubuh terasa lelah\r\nHilang nafsu makan\r\nSembelit\r\nPerubahan suasana hati atau linglung\r\nSakit perut\r\nTelinga berdenging	https://www.alodokter.com/vitamin-d	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
3f5c1776-e55c-46cd-84c8-dcc70554dc29	Rosurvastatin	\N	\N	\N	\N	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
9ef8a98f-7581-45ca-9836-86c7568a66cf	V-bloc	Beta Blocker (Penghambat Beta)\r\nCarvedilol	hipertensi, gagal jantung\r\nkronik, pasca serangan	Pusing, bradikardia, edema,  hipotensi, mual, diare, kabur pandangan, kelelahan	\N	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
83abb105-5682-4091-87bc-1a42c280fce9	Farnormin	Beta Blocker\r\n(Penghambat Beta)	hipertensi, angina pektoris,\r\naritmia, pasca serangan\r\njantung	Pusing, kelelahan, rasa kantuk, dan ekstremitas (tangan/kaki) terasa dingin.\r\nMual, diare, atau sakit perut. bradikardia. hipotensi. gangguan tidur	\N	\N	t	\N	2026-06-26 22:34:25.745017+07	2026-06-26 22:34:25.745017+07
afed839b-a97e-4ae4-ab74-bed83034a77d	Allopurinol	Penghambat xanthine-oxidase	Asam Urat, Batu Ginjal	Sakit perut, Mual, Muntah ,Diare ,Kantuk, Pusing ,Sakit kepala, Kehilangan fungsi indra pengecap, Gatal-gatal, Rambut rontok, Ruam kulit, Urine berkurang atau nyeri, Memar. Kebas, Gangguan hati	https://www.alodokter.com/allopurinol	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
0ce650da-7017-4ef4-8e92-7793ee29a562	Amlodipine	Antagonis Calsium	Hipertensi, Angina	Kantuk, Pusing, Lelah, Sakit perut, Mual, Kulit wajah atau leher memerah, Jantung berdebar, Nyeri dada. Kaki atau pergelangan kaki bengkak. Mata dan kulit menguning.	https://www.alodokter.com/amlodipine	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
564264c7-fd5e-448d-ba65-0e09d18d6bd4	Angintriz	Agen Metabolic Anti-Ischemic	Angina Pectoris	Pusing, sakit kepala, sakit perut, sakit maag, diare, lemas, mual, muntah, sembelit, atau timbul ruam kulit yang terasa gatal.\nGejala ekstrapiramidal, seperti otot kaku, sulit mengontrol gerakan, tremor, atau gangguan keseimbangan\nJantung berdebar atau berdetak tidak beraturan\nTekanan darah rendah akibat perubahan posisi (hipotensi ortostatik), yang dapat menyebabkan pusing atau pingsan\nWajah, leher, atau dada bagian atas memerah (flushing)\nTubuh mudah memar atau berdarah\nPenyakit liver, yang bisa ditandai dengan kulit dan mata menguning\nInfeksi, yang bisa ditandai dengan demam, menggigil, lelah, atau nyeri otot\nReaksi alergi obat, yang bisa ditandai dengan bengkak di wajah, bibir, mulut, lidah, atau di tenggorokan sehingga menyebabkan sulit bernapas	https://www.alodokter.com/aloshop/products/angintriz-mr-10-tablet/62a18eeff15ee840f565ed99	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
b098bbcf-1146-403c-8204-30732a2d6be0	Arcalion	Sulbutiamine	Suplemen Vit B1	agitasi ringan, reaksi alergi kulit.	https://www.alodokter.com/aloshop/products/arcalion-200-mg-6-tablet/5fb386cf41ab59059e869d41	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
91ab12c4-0abc-4cc8-923b-ed72b06468d5	Ardium	Micronized Purified Flavonoid Fraction 500 mg setara dengan diosmin 90% dan hesperidin 10%	Obat Wasir & Varises	sakit perut, diare, pusing, atau sakit kepala.	https://www.alodokter.com/aloshop/products/ardium-500-mg-15-tablet/5fcd84a441ab590e7c94f7b9	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
95a5e1c1-006b-4819-99ad-798c57cafe80	Aromasin / Exemestane	aromatase inhibitor	Anti Kanker Payudara	Hot flashes atau rasa dan sensasi panas dan gerah, Mual, Rambut rontok, Sakit kepala, pusing, atau lelah, Nafsu makan meningkat, Nyeri otot, Sulit tidur	https://www.alodokter.com/exemestane	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
2373697d-c54b-477d-a2c4-3b1720433ed8	Atorvastatin	Statin	Kolesterol, Trigliseda	Nyeri sendi dan otot, Sakit kepala, Hidung tersumbat, sakit tenggorokan, Diare, Mual, Konstipasi, Kembung, Mimisan	https://www.alodokter.com/atorvastatin	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
f720e510-6905-4132-bf02-ea203cba268e	Avodart / Dutasteride	Penghambat 5-alpha-reductase	pembesaran prostat jinak atau benign prostatic hyperplasia (BPH)	Disfungsi ereksi\nGangguan ejakulasi\nPenurunan libido\nNyeri atau bengkak pada buah zakar	https://www.alodokter.com/aloshop/products/avodart-0%2C5-mg-10-kapsul/5fb3890b41ab59059e86a373	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
d39f2a2a-254d-4457-8f09-d7e787815c4c	Merislon	Antivertigo/Antihistamin H3	Obat Vertigo	Sakit maag\nPerut kembung\nSakit kepala\nMulut kering\nDiare	https://www.alodokter.com/merislon	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
7071bdb3-80e6-4c78-b9c0-13ce0119b18a	Candesartan	Angiotensin receptor blocker	Hipertensi, Gagal Jantung	Sakit kepala, Nyeri punggung, Pusing, Batuk. Bersin, Hidung tersumbat, Ruam kulit, Gejala Hiperkalemia, Urine berkurang	https://www.alodokter.com/candesartan	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
43444b62-6323-42e8-9deb-c5bd91a0e084	Clopidogrel	Obat antiplatelet	Mencegah stroke dan penggumpalan darah	Diare, Mudah mengalami memar atau perdarahan, Perdarahan sulit berhenti, Sembelit, Rasa terbakar di dada (heartburn), Nyeri perut, Kulit atau bagian putih mata (sklera) menguning atau penyakit kuning , Kelelahan	https://www.alodokter.com/clopidogrel	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
9718c81f-f3b0-4bb6-be63-2ce2d124adb1	Concor	Antihipertensi jenis penghambat beta	hipertensi, gagal jantung kronis, dan angina pektoris	Gejala gangguan pencernaan, Pusing, Sakit kepala, Kelelahan, Insomnia atau sulit tidur, Nyeri otot atau nyeri sendi, Mulut kering, Hidung meler, batuk, sakit tenggorokan\nTangan dan kaki dingin, kesemutan, mati rasa, atau tampak kebiruan\nDenyut jantung sangat lambat (Bradikardia)\nPusing berat seperti akan pingsan\nGangguan penglihatan, nyeri mata\nBronkospasme, yang gejalanya antara lain mengi, dada terasa sesak, atau sulit bernapas lega\nPerubahan mental, seperti linglung, mood swing, atau depresi\nGagal jantung yang baru muncul atau bertambah parah, yang gejalanya bisa berupa sesak napas, bengkak di tungkai atau pergelangan kaki, tubuh terasa sangat lelah, berat badan naik mendadak	https://www.alodokter.com/concor	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
e4f6b5d7-1147-49ac-b645-9e154102f90b	Cordarone	Amiodarone	Aritmia Jantung	Mual\nMuntah\nKehilangan nafsu makan \nKonstipasi	https://www.alodokter.com/aloshop/products/cordarone-200-mg-10-tablet/5fb387a941ab59059e869fd2	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
85e599c5-6beb-4828-a368-41713d00eb2e	Coveram	Perindopril arginine 10 mg dan amlodipine 10 mg	Mengatasi hipertensi dan penyakit jantung koroner	Pusing, sakit kepala, wajah dan leher memerah (flushing), sakit perut, jantung berdebar, lelah, vertigo	https://www.alodokter.com/aloshop/products/coveram-10-mg-10-mg-30-tablet/6438c74f90e64fce9f2628f7	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
705281c9-df63-434c-abad-34cf2fabe93e	Crestor	Rosuvastatin	Kolesterol, Trigilesrida Tinggi	Sakit kepala, Pusing, Mual, Nyeri perut, Nyeri otot, Sembelit, Lemas atau tidak bertenaga, Gangguan ginjal	https://www.alodokter.com/crestor	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
026f45ef-9f8e-4e95-a8a7-015a719799df	Cyclo Proginova	Obat Hormon	Siklus Haid, Menopouse akibat kurang Esterogen	Payudara terasa kencang\nSpotting\nNyeri payudara\nPeningkatan berat badan\nMood swings\nPerut kembung\nMual	https://www.alodokter.com/aloshop/products/cyclo-progynova-21-tablet/5fb37d6b41ab59059e868785	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
1e579505-c7d5-4466-8aa9-57ea8b86029a	Dalfarol	Vitamin E / D-alfa tokoferol 200 IU	Anti Oksidan	Mual\nDiare\nPusing\nNyeri perut\nKelelahan\nPenglihatan kabur	https://www.alodokter.com/aloshop/products/dalfarol-200-iu-4-kapsul/62a18f11f15ee840f565eea6	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
9e7e056a-dde4-42cc-a044-e152f520d695	Disflatyl	Antiflatulensi / Simethicone	mengurangi perut kembung, sendawa, banyak buang angin, atau atau rasa tidak nyaman di perut akibat penumpukan gas pada saluran pencernaan.	Sendawa\nMual atau muntah\nSembelit atau malah diare\nHeartburn	https://www.alodokter.com/disflatyl	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
091b601b-cf20-434a-9901-0772c012687c	Eliquis	Anti-Koagulan / Apixaban	Mengurangi Penggumpalan Darah di pembuluh darah kaki dan paru-paru	Anemia, Memar, Mual, Pendarahan	https://www.halodoc.com/obat-dan-vitamin/eliquis-2-5-mg-10-tablet-1?srsltid=AfmBOopKpG-yZji8ZfpXirvEL9tZQop5oiYZ6huPPiUrJiS_rwTRz89v	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
c72d8c03-a4b0-4cd8-b8f5-0e97bcac08e1	Equfina	50 mg Safinamide	Obat Parkinson, Meningkatkan Dopamin di otak	Gangguan Hati	https://registrasiobat.pom.go.id/files/assesment-reports/01700621318.pdf	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
c8d73a26-6d6d-4fba-bc3b-d456cdbaa27e	Euthyrox	levothyroxine	hipotiroidisme	Rambut rontok pada bulan-bulan pertama konsumsi\nMuntah\nDiare \nSakit kepala\nSulit tidur\nRasa lelah\nNafsu makan bertambah\nHot flashes atau rasa hangat dan kemerahan pada kulit leher dan wajah\nKeringat berlebih\nPerubahan suasana hati\nKram pada kaki	https://www.alodokter.com/euthyrox	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
adf84f2c-b025-43cd-9a04-8afd3a3b5099	Frego	Anti-Migrain, Anti-Histamin	Migrain, Vertigo dan Ganggian pada Vestibular	Kantuk, Mual, Heartburn, Kenaikan berat badan, Gelisah, Mulut kering, Nyeri otot, Kesulitan bergerak, Tremor, Gerakan berulang yang tidak disadari pada wajah atau mulut, Depresi	https://www.alodokter.com/aloshop/products/frego-5-mg-10-tablet/5fb382be41ab59059e869413	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
f2602530-e031-47fe-ba0d-6ee725f31343	Glucophage	metformin.	Anti-Diabetes	Perut kembung\nRasa panas di dada (heartburn)\nSembelit\nSakit kepala\nMual atau muntah\nDiare\nTidak selera makan\nGangguan indera pengecap, seperti rasa logam di mulut	https://www.alodokter.com/glucophage	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
125c3e32-0ea4-46cd-b279-1b97e0acd9e0	Glucosamine	Suplemen Sendi	Nyeri Sendi, Osteoartritis	Mual\nMuntah\nNyeri ulu hati\nGangguan percernaan, seperti diare, sembelit, atau perut kembung\nPusing\nKantuk\nSakit kepala\nKelelahan\nRasa hangat pada wajah, leher, atau dada (flushing)\nReaksi alergi, seperti ruam, kemerahan, atau gatal pada kulit	https://www.alodokter.com/glucosamine	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
569951e9-2c44-4aea-8f47-3ce808b4c725	Glucovan	Combo Metformin dan Glibenclamide	Anti-Diabetes	hipoglikemia adalah sulit berkonsentrasi, gemetar, pucat, keringat dingin, atau jantung berdebar. mual atau muntah, sakit maag, perut terasa penuh, dan diare.	https://www.alodokter.com/aloshop/products/glucovance-500-mg-2%2C5-mg-10-tablet/5fb388c241ab59059e86a2c5	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
3b839eb9-5667-41b6-bc86-842ac4a08136	HCT	Hydrochlorothiazide	\N	\N	\N	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
8da3c6f1-eb9c-4f74-9b25-3dbff95eaf17	Irbesartan	Angina Reseptor (ARB)	Hipertensi dan terapi gagal jantung	Kelelahan dan sakit kepala. Diare dan maag. Nyeri otot dan sendi.	https://www.siloamhospitals.com/informasi-siloam/obat-dan-suplemen/irbesartan	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
dbb4e5af-5fdc-4b1c-9616-729aaddc905c	Isoprolol	Beta Blocker	Hipertensi	Denyut jantung yang sangat lambat (<60 kali per menit)\nPingsan\nTangan dan kaki dingin, pucat atau biru, dan nyeri\nPerubahan suasana hati, seperti mood swing\nSesak napas, bengkak pada pergelangan kaki, dan kelelahan yang berlebihan	https://www.alodokter.com/bisoprolol	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
0b78c469-1e83-4560-bc77-997946ccc7a6	Jardiance Duo	Combo Empagliflozin dan Metformin	Anti-diabetes	Sering haus\nSering buang air kecil\nLelah atau lemas\nSakit perut\nMual, muntah\nDiare\nRasa logam di mulut\nPusing hingga terasa seperti akan pingsan	https://www.alodokter.com/aloshop/products/jardiance-duo-12%2C5-mg-500-mg-10-tablet/62a18f84f15ee840f565f29d	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
8ab82e87-4a6b-4c2e-ba73-7b7fd3d8b492	Lipanthyl	Fenofibrate	Kolesterol dan Trigliserida	Sembelit\nDiare \nMual dan muntah\nPenyakit asam lambung\nSakit kepala\nNyeri punggung	https://www.alodokter.com/aloshop/products/lipanthyl-300-mg-6-kapsul/5fb3734b41ab59059e866eb9	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
baa4fab5-c2b2-4b32-890b-1760dff62d99	Lipitor	Statin / Atorvastatin	Kolesterol dan Trigliserida	Nyeri sendi, nyeri otot, atau kram otot\nHidung tersumbat, sakit tenggorokan\nSakit perut\nDiare\nMual\nSulit tidur	https://www.alodokter.com/lipitor	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
2e9d8d42-06c7-4d95-967b-d024d7b52c64	Lixiana	Anti-Koagulan	Stroke , Embolism, Afib	Anemia, Mimisan	https://www.halodoc.com/obat-dan-vitamin/lixiana-30-mg-14-tablet?srsltid=AfmBOoodGQJPqecOv2-Bcf3JbzxhpKrDXX8mTxyi-PGbTqMufJ-tlDU-	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
99e6d8c2-d920-4cd6-9312-9196823eb224	Micardis	Angiotensin II receptor blocker (ARB) / Telmisartan	Hipertensi	Pusing, terutama setelah bangun tidur atau duduk\nSakit punggung\nHidung tersumbat, infeksi saluran pernapasan atas, radang sinus (sinusitis), atau infeksi saluran kemih	https://www.alodokter.com/aloshop/products/micardis-80-mg-10-tablet/5fb3899641ab59059e86a4de	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
530a607e-26b3-4eb5-af70-62b8ec8c48b9	Modexa	Obat antiradang	meredakan gejala peradangan pada rhinitis alergi atau polip hidung.	sakit kepala, mimisan, bersin, atau hidung terasa perih.	https://www.alodokter.com/aloshop/products/modexa-0%2C05%25-nasal-spray-60-dosis/61b37f43b5a5e2062d979b0b	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
88df094a-6cbd-4cd7-b2c8-52cac0620e1d	Neurobion	Suplemen Vit B	Produksi sel darah merah	Diare\nSakit perut\nSering buang air kecil\nKerusakan saraf	https://www.alodokter.com/aloshop/products/neurobion-10-tablet/5fb38a0341ab59059e86a5f8	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
e7646c14-92bc-403b-b6bd-23cde5c79617	Nexium	Penghambat pompa proton / Esomeprazole	obat penurun asam lambung	Sakit kepala\nMual atau muntah\nMasuk angin atau kembung\nSakit perut\nDiare atau malah sembelit	https://www.alodokter.com/nexium	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
491a2757-e4bd-4ce0-ad47-e88e2f06cd72	Nitrokaf Retard	Nitrat / Nitroglycerin	Pengobatan Angina Pectoris	Sakit kepala yang sangat berat dan tidak membaik bahkan setelah nitrogliserin dihentikan\nPusing berat seperti akan pingsan\nDenyut jantung terlalu cepat, terlalu lambat, atau tidak beraturan\nJantung berdebar atau terasa seperti bergetar\nPenglihatan buram atau mulut kering\nPucat dan keringat dingin\nNapas pendek dan cepat	https://www.alodokter.com/nitrogliserin	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
b4229a4f-a2c2-4166-a0a9-617fb73ad20e	Norvask	antagonis kalsium / Amlodipin besilate	terapi hipertensi dan anti angina	sakit kepala, kelelahan, rasa panas dan kemerahan pada wajah, pusing, edema, mual, palpitasi, nyeri perut, somnolen	https://www.k24klik.com/p/norvask-5mg-tab-30s-112#	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
fd0cdd7c-981b-433c-b3e6-199a8783a557	Omletec	\N	\N	\N	\N	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
6b4e9a54-54a0-4c28-a14c-0e5d80298324	Pradaxa	Antikoagulan / dabigatran etexilate.	Pengencer Darah	Mudah memar, gusi berdarah terus menerus, sering mimisan dan lama berhenti\nBatuk darah, muntah darah, urine berdarah, BAB berdarah atau berwarna hitam\nPingsan\nLemas atau lelah\nSakit kepala yang sangat berat\nMenstruasi yang berat atau berlangsung lebih lama (menorrhagia)	https://www.alodokter.com/aloshop/products/pradaxa-150-mg-10-kapsul/62a18ec7f15ee840f565ec38	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
d191a2ef-0411-4e12-8656-59dca05805b6	Prorenal	Suplemen Asam Amino	Terapi Gagal Ginjal	Kelelahan\nKehilangan kordinasi tubuh\nSakit kepala\nRasa nyeri\nGangguan lambung\nMual\nPerut kembung\nDiare	https://www.alodokter.com/aloshop/products/prorenal-10-kaplet/5fb3892641ab59059e86a3cb	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
955e6bb0-af22-4338-91de-5ae85d877f85	Prostam	Tamsulosin	Pembesaran Prostat Jinak	gangguan fungsi hati, ikterus, pusing, sakit kepala, gelisah, penurunan tekanan darah, hipotensi ortostatik, takikardia, palpitasi, gatal, ruam, gangguan gastrointestinal, obstruksi nasal, edema, inkontinensia urin, rasa panas terbakar pada faring, kelelahan	https://www.alodokter.com/aloshop/products/prostam-sr-0%2C4-mg-10-tablet/62a18f34f15ee840f565efe1#:~:text=Prostam%20merupakan%20obat%20dengan%20kandungan,(BPH)%20pada%20pria%20dewasa.	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
cef661d8-9a4d-46b3-ba67-1510ced63d53	Ramipril	ACE inhibitor	antihipertensi	Pusing berat seperti akan pingsan\nLinglung\nGejala angioedema, misalnya bengkak di wajah, lidah, tangan atau kaki\nGejala hiperkalemia, seperti denyut jantung terlalu cepat, lambat, atau tidak beraturan; lemah otot, sesak napas\nGangguan fungsi ginjal, yang gejalanya berupa jarang berkemih, urine yang keluar makin sedikit atau tidak keluar sama sekali\nGangguan fungsi hati, yang gejalanya bisa meliputi sakit perut berat, urine berwarna gelap, tinja berwarna pucat seperti dempul, atau penyakit kuning	https://www.alodokter.com/ramipril	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
022045fd-49d2-4589-aaea-3801143c01b4	Regumen	Peningkat hormon Pregesteron / Norethisterone	Pengobatan perdarahan rahim disfungsional, endometriosis, metropati hemoragika, sindroma pra-menstruasi, penundaan waktu haid, menoragi & dismenore	Gangguan fungsi hati, ikterus, eksaserbasi epilepsi & migren, jerawat, urtikaria, retensi urin, gangguan sal cerna, perubahan libido, rasa tdk nyaman pd payudara, gejala pra menstruasi, siklus mens tdk teratur, mual, insomnia, alopesia, hirsutisme (pd penggunaan lama), depresi & somnolen.	https://www.alodokter.com/aloshop/products/regumen-5-mg-10-tablet/62a1874ef15ee840f565e8da	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
8e142c85-006f-4c5f-9baf-7facb2d44139	Seloxy	Suplemen Vitamin	Anti Oksidan , Metabolism Booster	diare, pusing, nyeri sendi, mual, sakit perut, kram perut, perdarahan atau memar, dan warna kulit menjadi kuning.	https://www.alodokter.com/aloshop/products/seloxy-6-kaplet/61b380dbb5a5e2062d979d99	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
e7029101-778f-4c5b-bd78-0d7a0a9f8925	Simvastatin	Statin	Kolesterol dan Trigliserida	Nyeri otot seperti kram dan otot yang melemah.\nGangguan pencernaan seperti mual, muntah, dan diare.\nSakit kepala.\nPeningkatan enzim hati.	https://www.halodoc.com/kesehatan/simvastatin	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
0395f27f-272c-4c94-a6e2-01d6275c6c7d	Suvesco	Rosuvastatin 10 mg	Obat penurun kolesterol golongan statin	Sakit kepala\nMual\nPegal atau nyeri otot\nSakit perut\nLemas	https://www.alodokter.com/aloshop/products/suvesco-10-mg-10-tablet/62a19119f15ee840f56600b6	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
410ec8d5-1790-4b46-a0d7-ba928852e468	Tamsulosin	penghambat alfa (alpha blocker)	Masalah Pembesaran Prostat	Pusing atau pening\nHidung meler atau tersumbat\nKantuk\nMual atau muntah\nDiare\nKonstipasi atau sembelit\nGangguan ejakulasi	https://www.alodokter.com/tamsulosin	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
2bb90cf4-9e30-4fc2-a252-953fb9eb306d	Tebokan	Gingko Biloba, Herbal	Untuk sirkulasi darah di susunan saraf	\N	https://www.halodoc.com/obat-dan-vitamin/tebokan-forte-120-mg-15-tablet?srsltid=AfmBOoo1opgL71XkWreEyzRgReNArdfPIBJspLmO934LO-lRsXk9Bj3L	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
e8332737-116d-4465-a765-c1140e34cde4	Tegretol	Carbamazepine	antikonvulsan atau antikejang	Kantuk\nPusing\nMual atau muntah\nMulut kering\nSembelit\nTremor\nSulit berkonsentrasi atau berpikir\nGangguan keseimbangan, misalnya sempoyongan saat berjalan	https://www.alodokter.com/tegretol	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
ba4105c1-4d6f-4acd-9d5b-74560069e3e6	Trizedon	antianginal	antianginal	pusing, mual dan muntah	\N	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
38e70c47-5f51-4ff0-b558-f5711ad645c0	Twynsta	Angiotensin II receptor blocker (ARB) dan antagonis kalsium / Telmisartan dan amlodipine	Anti Hipertensi parah	Pusing berat seperti akan pingsan\nRasa lemah yang tidak wajar\nJantung berdebar atau berdetak tidak beraturan\nSesak napas, bahkan saat beraktivitas ringan\nBerat badan naik drastis tanpa penyebab yang jelas\nNyeri dada atau perburukan nyeri dada yang sebelumnya sudah ada\nGemetar\nBuang air kecil berkurang atau terasa sakit dan sulit\nKencing berdarah\nOtot kaku atau kedutan	https://www.alodokter.com/twynsta	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
a7cc29a9-73f7-48f9-a505-52462a67b7fe	Uritos	Imidafenacine	Gangguan Kandung Kemih dan Prostat.	Mulut kering\nSembelit.\nFotofobia: penglihatan kabur\nKantuk\nKetidaknyamanan perut\nPeningkatan trigliserida dan peningkatan γ-GTP.	https://www.klikdokter.com/obat/obat-saluran-kemih-dan-prostat/uritos?srsltid=AfmBOooToVlP1gc1E72fB_Hqr-pe0A911I2ZVnPg-vwPLaY9b8f3MpE8	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
eb35eef5-369e-45dd-9d64-e8664221d7be	Vitamin D	Suplemen vitamin	osteoporosis, hipoparatiroid, rakitis, hipofosfatemia	Mual atau muntah\nMudah haus\nSering buang air kecil\nTubuh terasa lelah\nHilang nafsu makan\nSembelit\nPerubahan suasana hati atau linglung\nSakit perut\nTelinga berdenging	https://www.alodokter.com/vitamin-d	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
f8e01197-d806-4771-848a-66573012cbd6	Rosurvastatin	\N	\N	\N	\N	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
5764602a-50cc-4c46-b81c-0c6793f3f8aa	V-bloc	Beta Blocker (Penghambat Beta)\nCarvedilol	hipertensi, gagal jantung\nkronik, pasca serangan	Pusing, bradikardia, edema,  hipotensi, mual, diare, kabur pandangan, kelelahan	\N	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
b0487459-d459-46e6-a0d0-ba40c418171a	Farnormin	Beta Blocker\n(Penghambat Beta)	hipertensi, angina pektoris,\naritmia, pasca serangan\njantung	Pusing, kelelahan, rasa kantuk, dan ekstremitas (tangan/kaki) terasa dingin.\nMual, diare, atau sakit perut. bradikardia. hipotensi. gangguan tidur	\N	\N	t	\N	2026-06-26 23:07:12.751495+07	2026-06-26 23:07:12.751495+07
\.


--
-- Data for Name: menu_role_privileges; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.menu_role_privileges (id, menu_id, role, can_access, created_at) FROM stdin;
3e8dd832-591f-4897-aee6-581de0347231	a0000000-0000-0000-0000-000000000057	owner	t	2026-06-26 22:34:24.06886+07
08f9a77b-a3e4-474d-8d1d-93bf671b593d	a0000000-0000-0000-0000-000000000058	owner	t	2026-06-26 22:34:24.06886+07
8a5ac111-640c-4edc-9e9e-7a41a6a65490	a0000000-0000-0000-0000-000000000057	admin	t	2026-06-26 22:34:24.075156+07
e9bef19d-092b-4f06-a51e-7459b40b5592	a0000000-0000-0000-0000-000000000058	admin	t	2026-06-26 22:34:24.075156+07
d288e0f2-e93a-450c-85a0-3fa984b7506b	a0000000-0000-0000-0000-000000000001	owner	t	2026-06-26 23:07:12.914022+07
396db37e-bbd7-42a8-b74a-7dd05eb71703	a0000000-0000-0000-0000-000000000002	owner	t	2026-06-26 23:07:12.914022+07
72cc4985-3164-4ae1-9770-8a43a4a5060c	a0000000-0000-0000-0000-000000000003	owner	t	2026-06-26 23:07:12.914022+07
7317797d-b5e3-4d44-afe4-b48c75daa86c	a0000000-0000-0000-0000-000000000004	owner	t	2026-06-26 23:07:12.914022+07
22d98430-84d9-403c-a86d-2ce6e49276a7	a0000000-0000-0000-0000-000000000005	owner	t	2026-06-26 23:07:12.914022+07
ab768e92-aa17-4896-ac82-5f922eb3c9a8	a0000000-0000-0000-0000-000000000006	owner	t	2026-06-26 23:07:12.914022+07
70891f4e-7e0d-4e6c-bbcf-c0ea6a87e11c	a0000000-0000-0000-0000-000000000007	owner	t	2026-06-26 23:07:12.914022+07
e63f1ea1-495b-48ab-be46-6dc66ed324a7	a0000000-0000-0000-0000-000000000010	owner	t	2026-06-26 23:07:12.914022+07
ceab1763-b939-40bb-a941-6a1ad8f56192	a0000000-0000-0000-0000-000000000020	owner	t	2026-06-26 23:07:12.914022+07
04ff9429-708b-4436-9a0b-7b82d3e8acac	a0000000-0000-0000-0000-000000000030	owner	t	2026-06-26 23:07:12.914022+07
432b369c-19b2-48c9-8158-22bb9bf835c4	a0000000-0000-0000-0000-000000000031	owner	t	2026-06-26 23:07:12.914022+07
590f42c9-ba94-41b9-a90b-cdce234f460c	a0000000-0000-0000-0000-000000000032	owner	t	2026-06-26 23:07:12.914022+07
d978acde-b8f7-4716-b4b7-58e001782992	a0000000-0000-0000-0000-000000000033	owner	t	2026-06-26 23:07:12.914022+07
22d4111c-a748-4a0b-a5ab-c00eb7e5cf4c	a0000000-0000-0000-0000-000000000034	owner	t	2026-06-26 23:07:12.914022+07
4b71f59b-7fbb-4970-a573-400cb8418e78	a0000000-0000-0000-0000-000000000011	owner	t	2026-06-26 23:07:12.914022+07
1162c9f7-0ed3-4853-894b-c86976813cc7	a0000000-0000-0000-0000-000000000012	owner	t	2026-06-26 23:07:12.914022+07
cb4a7339-0135-4dab-9309-edce67c451c5	a0000000-0000-0000-0000-000000000013	owner	t	2026-06-26 23:07:12.914022+07
6c2272bb-7039-41da-a149-bfc3c5749d18	a0000000-0000-0000-0000-000000000014	owner	t	2026-06-26 23:07:12.914022+07
e68c8e9b-99a4-4da5-9677-9f431699f15d	a0000000-0000-0000-0000-000000000015	owner	t	2026-06-26 23:07:12.914022+07
c0540171-479e-4af5-93b7-7954bdcac5c1	a0000000-0000-0000-0000-000000000016	owner	t	2026-06-26 23:07:12.914022+07
85d97e62-60aa-4182-ad8d-f1722eecdfd1	a0000000-0000-0000-0000-000000000017	owner	t	2026-06-26 23:07:12.914022+07
74bb39ee-2be5-46c2-95b7-85e62e471d9c	a0000000-0000-0000-0000-000000000018	owner	t	2026-06-26 23:07:12.914022+07
ec4ff391-a531-455a-9115-c32b5cfd90f0	a0000000-0000-0000-0000-000000000019	owner	t	2026-06-26 23:07:12.914022+07
a26137ef-a0ef-4ebe-8341-4410a634c80d	a0000000-0000-0000-0000-00000000001a	owner	t	2026-06-26 23:07:12.914022+07
f871154c-6425-43a2-ac5b-50cd7eeaa850	a0000000-0000-0000-0000-00000000001b	owner	t	2026-06-26 23:07:12.914022+07
13e40954-1dc0-4af3-a168-838af1994ac6	a0000000-0000-0000-0000-000000000021	owner	t	2026-06-26 23:07:12.914022+07
5315bef4-ae49-4214-8823-3e33e3c5e6b0	a0000000-0000-0000-0000-000000000022	owner	t	2026-06-26 23:07:12.914022+07
c2f03d78-2e4d-45b7-a3fe-ab2a92b65414	a0000000-0000-0000-0000-000000000023	owner	t	2026-06-26 23:07:12.914022+07
7bf3917f-fa28-4faf-8a1f-4959105e36aa	a0000000-0000-0000-0000-000000000001	admin	t	2026-06-26 23:07:12.914022+07
0dace202-a177-44ea-9a26-8b56e4b3f528	a0000000-0000-0000-0000-000000000002	admin	t	2026-06-26 23:07:12.914022+07
7424175a-cfd8-4af4-8f19-e15d7def32a4	a0000000-0000-0000-0000-000000000003	admin	t	2026-06-26 23:07:12.914022+07
dc0c8fc2-b757-486e-b6c2-31d8e7218abf	a0000000-0000-0000-0000-000000000004	admin	t	2026-06-26 23:07:12.914022+07
9f7a1663-778d-46db-8604-f4d221f79622	a0000000-0000-0000-0000-000000000005	admin	t	2026-06-26 23:07:12.914022+07
ecdd2781-e7ca-4490-8bc9-6f1470fe2b6a	a0000000-0000-0000-0000-000000000006	admin	t	2026-06-26 23:07:12.914022+07
e6dec15e-fa44-4f58-920c-40dc274885fb	a0000000-0000-0000-0000-000000000007	admin	t	2026-06-26 23:07:12.914022+07
15d00658-7117-4f21-9747-7c21947c47ba	a0000000-0000-0000-0000-000000000010	admin	t	2026-06-26 23:07:12.914022+07
2ee16955-c680-464e-be71-5c6d54818d9f	a0000000-0000-0000-0000-000000000020	admin	t	2026-06-26 23:07:12.914022+07
3d115ab7-c67c-43d6-940b-c0fe97018717	a0000000-0000-0000-0000-000000000030	admin	t	2026-06-26 23:07:12.914022+07
ba9aabcc-79bb-4bb8-836d-b291d33d2f44	a0000000-0000-0000-0000-000000000031	admin	t	2026-06-26 23:07:12.914022+07
54af6639-06a7-4229-9550-9716468a2e68	a0000000-0000-0000-0000-000000000032	admin	t	2026-06-26 23:07:12.914022+07
69af3bc4-0b20-4619-9c7a-323daed0b8ca	a0000000-0000-0000-0000-000000000033	admin	t	2026-06-26 23:07:12.914022+07
8796b94f-cc28-4ade-a305-c251f4bf059a	a0000000-0000-0000-0000-000000000011	admin	t	2026-06-26 23:07:12.914022+07
5e1d9d97-ebed-4c10-bd2a-c5c872d56cee	a0000000-0000-0000-0000-000000000012	admin	t	2026-06-26 23:07:12.914022+07
ab17ed0d-1e3c-479f-978b-e380a971ac7c	a0000000-0000-0000-0000-000000000013	admin	t	2026-06-26 23:07:12.914022+07
02bb8745-9017-4466-8a5a-f6dfe178c16e	a0000000-0000-0000-0000-000000000014	admin	t	2026-06-26 23:07:12.914022+07
09fa6a56-f799-4fbe-8c86-6f640783443d	a0000000-0000-0000-0000-000000000015	admin	t	2026-06-26 23:07:12.914022+07
21894609-fe18-48b6-93e1-0efd557438fa	a0000000-0000-0000-0000-000000000016	admin	t	2026-06-26 23:07:12.914022+07
7e0836b3-2cc2-43ab-85e1-e8726f33b2d8	a0000000-0000-0000-0000-000000000017	admin	t	2026-06-26 23:07:12.914022+07
e552115b-09d7-4c2a-b059-e43a5127442a	a0000000-0000-0000-0000-000000000018	admin	t	2026-06-26 23:07:12.914022+07
e560f27d-b6b0-425b-8e4c-c24bc4d2c8eb	a0000000-0000-0000-0000-000000000019	admin	t	2026-06-26 23:07:12.914022+07
45054d05-a3d8-4df5-b878-eb23f0b0f46e	a0000000-0000-0000-0000-00000000001a	admin	t	2026-06-26 23:07:12.914022+07
f2cb9c67-75cb-4173-bd7a-013b8d9a2eba	a0000000-0000-0000-0000-00000000001b	admin	t	2026-06-26 23:07:12.914022+07
2fcc36bd-68b6-4eaa-820c-54ea05f47029	a0000000-0000-0000-0000-000000000021	admin	t	2026-06-26 23:07:12.914022+07
d7189b1a-2988-4b7e-8377-8c73f6a1ba49	a0000000-0000-0000-0000-000000000022	admin	t	2026-06-26 23:07:12.914022+07
ac4b4a8c-69a3-4074-b5f9-1c6443e54a1b	a0000000-0000-0000-0000-000000000023	admin	t	2026-06-26 23:07:12.914022+07
a11953ca-0c1e-40f1-b12f-1dc237e05634	a0000000-0000-0000-0000-000000000001	finance	t	2026-06-26 23:07:12.914022+07
e5fa99d3-b2d7-40bf-b133-01363c4781f0	a0000000-0000-0000-0000-000000000002	finance	t	2026-06-26 23:07:12.914022+07
981c45d9-2769-4f18-b9a9-75bf94a009a3	a0000000-0000-0000-0000-000000000007	finance	t	2026-06-26 23:07:12.914022+07
ce41f3d4-5d66-4010-b726-dfa6f377d2cc	a0000000-0000-0000-0000-000000000033	finance	t	2026-06-26 23:07:12.914022+07
edbbb987-f451-432b-9c28-0220aaf10314	a0000000-0000-0000-0000-000000000001	trainer	t	2026-06-26 23:07:12.914022+07
a9d819ab-de84-45c0-8526-2351c3e94321	a0000000-0000-0000-0000-000000000002	trainer	t	2026-06-26 23:07:12.914022+07
bb50a5ac-a930-4708-9231-8d1a3d90bc91	a0000000-0000-0000-0000-000000000003	trainer	t	2026-06-26 23:07:12.914022+07
4677e6a4-3248-4379-bd7c-352115b4861a	a0000000-0000-0000-0000-000000000004	trainer	t	2026-06-26 23:07:12.914022+07
bf0d5001-bdfb-49be-b5f2-59cc971d9c3e	a0000000-0000-0000-0000-000000000005	trainer	t	2026-06-26 23:07:12.914022+07
4e47476b-dec8-4066-bd92-a5bb942f97d3	a0000000-0000-0000-0000-000000000010	trainer	t	2026-06-26 23:07:12.914022+07
dbf72dee-6df3-4484-a4b8-84b5831916bc	a0000000-0000-0000-0000-000000000020	trainer	t	2026-06-26 23:07:12.914022+07
a5fd4b4b-2f84-4a5d-96a6-9366033409d1	a0000000-0000-0000-0000-000000000031	trainer	t	2026-06-26 23:07:12.914022+07
9299b060-f8e0-44ee-8fd3-9696fae1c35c	a0000000-0000-0000-0000-000000000032	trainer	t	2026-06-26 23:07:12.914022+07
105b4ff3-bfa0-4a13-98c5-325aae1a9246	a0000000-0000-0000-0000-000000000033	trainer	t	2026-06-26 23:07:12.914022+07
29c85874-8bed-4a62-a744-336737b9b5f4	a0000000-0000-0000-0000-000000000011	trainer	t	2026-06-26 23:07:12.914022+07
8b8be6fc-ddd4-46d1-a7c9-99383dec2125	a0000000-0000-0000-0000-000000000012	trainer	t	2026-06-26 23:07:12.914022+07
511405de-bfb3-4fbc-baf1-97ead64cd94e	a0000000-0000-0000-0000-000000000013	trainer	t	2026-06-26 23:07:12.914022+07
eb8d91c8-a2e8-40d3-a69b-7ddb2e414c1f	a0000000-0000-0000-0000-000000000014	trainer	t	2026-06-26 23:07:12.914022+07
ca61f910-8e6d-4dc1-bd77-3ddf415f3011	a0000000-0000-0000-0000-000000000015	trainer	t	2026-06-26 23:07:12.914022+07
193ad864-549f-406a-86da-f112a06be7ef	a0000000-0000-0000-0000-000000000016	trainer	t	2026-06-26 23:07:12.914022+07
784e9b53-eb1e-4eb6-8a2d-81ad467c40e7	a0000000-0000-0000-0000-000000000017	trainer	t	2026-06-26 23:07:12.914022+07
3e84406b-1a0e-42aa-bfe3-8c4440e51256	a0000000-0000-0000-0000-000000000018	trainer	t	2026-06-26 23:07:12.914022+07
b11b9c9f-6418-488f-adce-49bd29644aaf	a0000000-0000-0000-0000-000000000019	trainer	t	2026-06-26 23:07:12.914022+07
05fd04f7-15b6-4833-8bb3-7e42700387b2	a0000000-0000-0000-0000-00000000001a	trainer	t	2026-06-26 23:07:12.914022+07
569edd29-5086-4546-9cbb-db1c6c380d48	a0000000-0000-0000-0000-00000000001b	trainer	t	2026-06-26 23:07:12.914022+07
3f95bd23-bd92-459a-ba3b-9618065bf7ca	a0000000-0000-0000-0000-000000000021	trainer	t	2026-06-26 23:07:12.914022+07
107bc122-f8b2-47e4-8008-0e2bdee4db6a	a0000000-0000-0000-0000-000000000022	trainer	t	2026-06-26 23:07:12.914022+07
95d93cb4-b58e-4865-8c4e-c22ef978d7e3	a0000000-0000-0000-0000-000000000023	trainer	t	2026-06-26 23:07:12.914022+07
d2a502ef-0a7c-4370-b9b9-aea99a63d14d	a0000000-0000-0000-0000-000000000001	client	t	2026-06-26 23:07:12.914022+07
06339ae7-e5c5-48fb-9418-4b0c10382337	a0000000-0000-0000-0000-000000000002	client	t	2026-06-26 23:07:12.914022+07
aa2b234c-3635-45eb-8ece-0ed53d1e3584	a0000000-0000-0000-0000-000000000033	client	t	2026-06-26 23:07:12.914022+07
118419c1-246e-413d-82f1-46450a66a97b	a0000000-0000-0000-0000-000000000035	owner	t	2026-06-26 23:07:12.933326+07
75e7b117-5f95-465f-8426-c52127a906f7	a0000000-0000-0000-0000-000000000071	owner	t	2026-06-26 23:07:12.945849+07
fa811a1c-af52-475c-aef6-f7e25c4c9b3a	a0000000-0000-0000-0000-000000000072	owner	t	2026-06-26 23:07:12.945849+07
ccf41e02-e5ef-4a34-b8a9-6682fda5422c	a0000000-0000-0000-0000-000000000073	owner	t	2026-06-26 23:07:12.945849+07
089ec065-0f59-4277-bef1-03a0834eb28f	a0000000-0000-0000-0000-000000000074	owner	t	2026-06-26 23:07:12.945849+07
10171744-5179-44cc-844a-2c12939c129d	a0000000-0000-0000-0000-000000000071	admin	t	2026-06-26 23:07:12.945849+07
0309fe31-4795-432e-81f0-f0e92647e1f4	a0000000-0000-0000-0000-000000000072	admin	t	2026-06-26 23:07:12.945849+07
0844207e-e5f0-4e34-8f94-40ae137daeab	a0000000-0000-0000-0000-000000000073	admin	t	2026-06-26 23:07:12.945849+07
bd64a9d0-077c-4764-bb0d-8de6ff4a7277	a0000000-0000-0000-0000-000000000074	admin	t	2026-06-26 23:07:12.945849+07
e3e6a4a5-314e-481a-8f36-8ddae550ce8f	a0000000-0000-0000-0000-000000000071	finance	t	2026-06-26 23:07:12.945849+07
93b4fc8d-c794-408b-bd81-c7fa5f2e7339	a0000000-0000-0000-0000-000000000072	finance	t	2026-06-26 23:07:12.945849+07
568e4b6d-94f1-49ef-a19a-7e8b0589c9e9	a0000000-0000-0000-0000-000000000073	finance	t	2026-06-26 23:07:12.945849+07
dd60f274-47eb-430f-a47a-6d3f925929f8	a0000000-0000-0000-0000-000000000074	finance	t	2026-06-26 23:07:12.945849+07
0618d1e9-3b14-4f0e-be47-a15a2bf2aade	a0000000-0000-0000-0000-000000000040	owner	t	2026-06-26 23:07:12.957782+07
44b75132-ada9-4630-8fb5-f4af0c123c2c	a0000000-0000-0000-0000-000000000040	admin	t	2026-06-26 23:07:12.957782+07
2e1de08c-c781-40d7-a955-2ab0267113fe	a0000000-0000-0000-0000-000000000040	trainer	t	2026-06-26 23:07:12.957782+07
5f7ac581-718a-45a2-bc99-b155b0c08c13	a0000000-0000-0000-0000-000000000041	owner	t	2026-06-26 23:07:12.969534+07
a3145cbb-87fc-4d3a-94f6-8bb200cbb3f9	a0000000-0000-0000-0000-000000000041	admin	t	2026-06-26 23:07:12.969534+07
078f4fbc-3b93-46b7-96b2-589d72832cf7	a0000000-0000-0000-0000-000000000041	trainer	t	2026-06-26 23:07:12.969534+07
d4110565-2136-49ba-ba81-1ccf5a2fca27	a0000000-0000-0000-0000-000000000075	owner	t	2026-06-26 23:07:12.979523+07
443a84e8-89cb-4a2f-ba39-534e1eb9a9c2	a0000000-0000-0000-0000-000000000075	admin	t	2026-06-26 23:07:12.979523+07
740c1b32-0737-49fb-8c9b-b2c357860154	a0000000-0000-0000-0000-000000000075	finance	t	2026-06-26 23:07:12.979523+07
d942e398-43f6-429e-976e-627a7f8c3612	a0000000-0000-0000-0000-000000000042	owner	t	2026-06-26 23:07:12.991053+07
b5c6027e-7487-40e7-818d-b5ae283e4141	a0000000-0000-0000-0000-000000000042	admin	t	2026-06-26 23:07:12.991053+07
510249c6-02b8-477d-9472-a6a1b3ccacef	a0000000-0000-0000-0000-0000000000a1	owner	t	2026-06-26 23:07:13.019261+07
94cef4a6-9adf-4bd3-84bd-cde744d9dc5c	a0000000-0000-0000-0000-0000000000a2	owner	t	2026-06-26 23:07:13.019261+07
532072fd-db8e-4134-8f1f-d6c703f2536b	a0000000-0000-0000-0000-0000000000a3	owner	t	2026-06-26 23:07:13.019261+07
ccce93d1-ea87-4c66-8fba-6e0e88bf5ba5	a0000000-0000-0000-0000-0000000000a1	admin	t	2026-06-26 23:07:13.019261+07
d20d2d41-5cc4-4de5-ba25-997d54a571cf	a0000000-0000-0000-0000-0000000000a2	admin	t	2026-06-26 23:07:13.019261+07
8278703b-d00a-472b-8182-16cb9fdd1af1	a0000000-0000-0000-0000-0000000000a3	admin	t	2026-06-26 23:07:13.019261+07
c28d3944-78b0-48c0-9fb4-1502d81321a3	a0000000-0000-0000-0000-0000000000a4	owner	t	2026-06-26 23:07:13.030861+07
9797d33f-c9eb-44c1-bc9a-bea284826f47	a0000000-0000-0000-0000-0000000000a5	owner	t	2026-06-26 23:07:13.030861+07
114c166f-93ab-4597-b010-31c5f7acb7a6	a0000000-0000-0000-0000-0000000000a5	admin	t	2026-06-26 23:07:13.030861+07
9eacb3e7-ac21-4c6e-bbd0-4dccc5e9b190	a0000000-0000-0000-0000-0000000000a6	owner	t	2026-06-26 23:07:13.042849+07
fb36b404-a3f9-4b4b-af14-2a88d03b2be0	a0000000-0000-0000-0000-0000000000a7	owner	t	2026-06-26 23:07:13.042849+07
1f1b5080-d829-4678-95eb-578a39b49eb1	a0000000-0000-0000-0000-0000000000a6	admin	t	2026-06-26 23:07:13.042849+07
c723ef69-80d0-430d-8b4d-1011154f20fd	a0000000-0000-0000-0000-0000000000a7	admin	t	2026-06-26 23:07:13.042849+07
a6750f99-925d-469c-b189-86def04f0b51	a0000000-0000-0000-0000-0000000000a6	consultant	t	2026-06-26 23:07:13.068105+07
5f0b2d6d-2c71-457d-a390-5e9e822a0753	a0000000-0000-0000-0000-0000000000c1	consultant	t	2026-06-26 23:07:13.068105+07
6b49a4da-889d-4f01-be94-f81719d9cdca	a0000000-0000-0000-0000-0000000000c2	consultant	t	2026-06-26 23:07:13.068105+07
ce1f8aba-85b9-42e7-ae22-3a54c9f5bc9d	a0000000-0000-0000-0000-0000000000c3	consultant	t	2026-06-26 23:07:13.068105+07
ee2aa88c-e043-436f-bedb-8f05d0f8811f	a0000000-0000-0000-0000-0000000000c1	admin	t	2026-06-26 23:07:13.068105+07
36ede68f-8991-4390-8be8-65d6cce406d7	a0000000-0000-0000-0000-0000000000c2	admin	t	2026-06-26 23:07:13.068105+07
bb6eee6b-5418-4d1a-9ab1-01521db8b923	a0000000-0000-0000-0000-0000000000c3	admin	t	2026-06-26 23:07:13.068105+07
f76dcf96-2d14-4a48-8d1c-2a7bfea1f641	a0000000-0000-0000-0000-0000000000c1	owner	t	2026-06-26 23:07:13.068105+07
fc2f03d5-d546-490f-987c-9f9e8f342a4b	a0000000-0000-0000-0000-0000000000c2	owner	t	2026-06-26 23:07:13.068105+07
0c252894-8ce7-4229-b072-6e58deaa4e06	a0000000-0000-0000-0000-0000000000c3	owner	t	2026-06-26 23:07:13.068105+07
3d59be3c-0624-4370-a831-2b474219a0a0	a0000000-0000-0000-0000-00000000001c	owner	t	2026-06-26 23:07:13.081258+07
4d90a873-d852-43d7-b61f-9ce641a9a1cb	a0000000-0000-0000-0000-00000000001c	admin	t	2026-06-26 23:07:13.081258+07
f972070a-25ef-4fba-81a8-197ae06d93cc	a0000000-0000-0000-0000-00000000001c	trainer	t	2026-06-26 23:07:13.081258+07
\.


--
-- Data for Name: menus; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.menus (id, parent_id, code, label, icon, href, sort_order, is_active, created_at, updated_at) FROM stdin;
a0000000-0000-0000-0000-000000000057	\N	health-news	Health News	Megaphone	/health-news	34	t	2026-06-26 22:34:24.062291+07	2026-06-26 22:34:24.062291+07
a0000000-0000-0000-0000-000000000058	\N	doctor-videos	Doctor Videos	HeartPulse	/doctor-videos	35	t	2026-06-26 22:34:24.062291+07	2026-06-26 22:34:24.062291+07
a0000000-0000-0000-0000-000000000001	\N	dashboard	Dashboard	LayoutDashboard	/	1	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000002	\N	messages	Messages	MessageSquare	/messages	2	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000003	\N	groups	Groups	UsersRound	/groups	3	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000004	\N	challenges	Challenges	Trophy	/challenges	4	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000005	\N	clients	Clients	UserCheck	/clients	5	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000006	\N	team	Team	Users	/team	6	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000010	\N	master-libraries	Master Libraries	Library	\N	10	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000020	\N	scheduling	Scheduling	CalendarDays	\N	20	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000030	\N	announcements	Announcements	Megaphone	/announcements	30	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000031	\N	progress	Progress	TrendingUp	/progress	31	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000032	\N	automations	Automations	Zap	/automations	32	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000033	\N	settings	Settings	Settings	/settings	99	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000034	\N	menu-management	Menu Management	Shield	/menu-management	98	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000011	a0000000-0000-0000-0000-000000000010	digital-library	Digital Library	BookOpen	/digital-library	1	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000012	a0000000-0000-0000-0000-000000000010	programs	Programs	CalendarRange	/programs	2	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000013	a0000000-0000-0000-0000-000000000010	workouts	Workouts	ClipboardList	/workouts	3	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000014	a0000000-0000-0000-0000-000000000010	exercises	Exercises	Dumbbell	/exercises	4	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000015	a0000000-0000-0000-0000-000000000010	meals	Meals	UtensilsCrossed	/nutrition	5	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000016	a0000000-0000-0000-0000-000000000010	foods	Foods	Cookie	/foods	6	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000017	a0000000-0000-0000-0000-000000000010	habits	Habits	Repeat	/habits	7	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000018	a0000000-0000-0000-0000-000000000010	medicines	Daftar Obat	Pill	/medicines	8	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000019	a0000000-0000-0000-0000-000000000010	program-categories	Program Categories	Layers	/program-categories	9	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-00000000001a	a0000000-0000-0000-0000-000000000010	trainer-card-types	Training Card Types	ClipboardCheck	/training-card-types	10	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-00000000001b	a0000000-0000-0000-0000-000000000010	forms	Forms	FileText	/forms	11	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000021	a0000000-0000-0000-0000-000000000020	scheduling-calendar	Calendar	CalendarDays	/scheduling/calendar	1	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000022	a0000000-0000-0000-0000-000000000020	scheduling-availability	Availability	CalendarRange	/scheduling/availability	2	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000023	a0000000-0000-0000-0000-000000000020	scheduling-event-types	Event Types	CalendarDays	/scheduling/event-types	3	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.914022+07
a0000000-0000-0000-0000-000000000035	\N	training-schedules	Training Schedules	CalendarClock	/training-schedules	8	t	2026-06-26 23:07:12.933326+07	2026-06-26 23:07:12.933326+07
a0000000-0000-0000-0000-000000000007	\N	payments	Payments	CreditCard	\N	7	t	2026-06-26 23:07:12.914022+07	2026-06-26 23:07:12.945849+07
a0000000-0000-0000-0000-000000000071	a0000000-0000-0000-0000-000000000007	payments-overview	Overview	CreditCard	/payments	1	t	2026-06-26 23:07:12.945849+07	2026-06-26 23:07:12.945849+07
a0000000-0000-0000-0000-000000000072	a0000000-0000-0000-0000-000000000007	client-subscriptions	Client Subscriptions	Star	/payments/subscriptions	2	t	2026-06-26 23:07:12.945849+07	2026-06-26 23:07:12.945849+07
a0000000-0000-0000-0000-000000000073	a0000000-0000-0000-0000-000000000007	manage-plans	Manage Plans	Layers	/payments/plans	3	t	2026-06-26 23:07:12.945849+07	2026-06-26 23:07:12.945849+07
a0000000-0000-0000-0000-000000000074	a0000000-0000-0000-0000-000000000007	payment-reports	Reports	TrendingUp	/payments/reports	4	t	2026-06-26 23:07:12.945849+07	2026-06-26 23:07:12.945849+07
a0000000-0000-0000-0000-000000000040	\N	assessments	Assessments	ClipboardCheck	/assessments	8	t	2026-06-26 23:07:12.957782+07	2026-06-26 23:07:12.957782+07
a0000000-0000-0000-0000-000000000041	\N	nutrition-guidance	Nutrition Guidance	Apple	/nutrition-guidance	9	t	2026-06-26 23:07:12.969534+07	2026-06-26 23:07:12.969534+07
a0000000-0000-0000-0000-000000000075	a0000000-0000-0000-0000-000000000007	bank-accounts	Bank Accounts	CreditCard	/payments/bank-accounts	5	t	2026-06-26 23:07:12.979523+07	2026-06-26 23:07:12.979523+07
a0000000-0000-0000-0000-000000000042	\N	banners	Banners	Image	/banners	33	t	2026-06-26 23:07:12.991053+07	2026-06-26 23:07:12.991053+07
a0000000-0000-0000-0000-0000000000a1	\N	sf_master	SF Master	Layers	\N	18	t	2026-06-26 23:07:13.019261+07	2026-06-26 23:07:13.019261+07
a0000000-0000-0000-0000-0000000000a2	a0000000-0000-0000-0000-0000000000a1	sf_condition_classifications	Klasifikasi Kondisi	HeartPulse	/master/condition-classifications	1	t	2026-06-26 23:07:13.019261+07	2026-06-26 23:07:13.019261+07
a0000000-0000-0000-0000-0000000000a3	a0000000-0000-0000-0000-0000000000a1	sf_specific_conditions	Kondisi Spesifik	Stethoscope	/master/specific-conditions	2	t	2026-06-26 23:07:13.019261+07	2026-06-26 23:07:13.019261+07
a0000000-0000-0000-0000-0000000000a4	a0000000-0000-0000-0000-0000000000a1	sf_system_score_weights	Bobot System Score	Activity	/system-score	3	t	2026-06-26 23:07:13.030861+07	2026-06-26 23:07:13.030861+07
a0000000-0000-0000-0000-0000000000a5	a0000000-0000-0000-0000-0000000000a1	sf_assessment_v2_schema	Skema Asesmen v2	ClipboardCheck	/assessments/v2-schema	4	t	2026-06-26 23:07:13.030861+07	2026-06-26 23:07:13.030861+07
a0000000-0000-0000-0000-0000000000a6	a0000000-0000-0000-0000-0000000000a1	sf_lab_consultations	Lab Consultations	ClipboardCheck	/lab-consultations	5	t	2026-06-26 23:07:13.042849+07	2026-06-26 23:07:13.042849+07
a0000000-0000-0000-0000-0000000000a7	a0000000-0000-0000-0000-0000000000a1	sf_tier4_waitlist	Tier 4 Waitlist	Star	/tier4-waitlist	6	t	2026-06-26 23:07:13.042849+07	2026-06-26 23:07:13.042849+07
a0000000-0000-0000-0000-0000000000c1	\N	sf_consultant	Consultant	Stethoscope	\N	19	t	2026-06-26 23:07:13.068105+07	2026-06-26 23:07:13.068105+07
a0000000-0000-0000-0000-0000000000c2	a0000000-0000-0000-0000-0000000000c1	sf_consultant_queue	Antrian Review	ClipboardCheck	/consultant/queue	1	t	2026-06-26 23:07:13.068105+07	2026-06-26 23:07:13.068105+07
a0000000-0000-0000-0000-0000000000c3	a0000000-0000-0000-0000-0000000000c1	sf_consultant_clients	Klien Saya	UsersRound	/consultant/clients	2	t	2026-06-26 23:07:13.068105+07	2026-06-26 23:07:13.068105+07
a0000000-0000-0000-0000-00000000001c	a0000000-0000-0000-0000-000000000010	training-card-templates	Card Templates	Layers	/training-card-templates	12	t	2026-06-26 23:07:13.081258+07	2026-06-26 23:07:13.081258+07
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.messages (id, conversation_id, sender_id, content, type, media_url, is_read, created_at) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.notifications (id, user_id, title, body, type, data, status, sent_via_push, push_sent_at, read_at, created_at) FROM stdin;
\.


--
-- Data for Name: nutrition_daily_logs; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.nutrition_daily_logs (id, user_id, log_date, vegetable_intake, protein_intake, hydration_ok, sugar_excess, diet_violation, score, status, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: nutrition_health_profiles; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.nutrition_health_profiles (user_id, gender, age_group, female_condition, goal, weight_kg, allergies, conditions, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: nutrition_logs; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.nutrition_logs (id, user_id, logged_at, meal_type, food_name, calories, protein_g, carbs_g, fat_g, photo_url) FROM stdin;
\.


--
-- Data for Name: payment_plans; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.payment_plans (id, name, description, price, currency, duration_months, features, max_clients, is_active, created_at, updated_at, tier, billing_period, original_price, discount_pct, is_popular, sort_order, is_legacy) FROM stdin;
72a73081-d223-47c0-bb7d-0a7ae29ef2b2	SF Free â€” System Check	Akses gratis selamanya. Asesmen lengkap (Phase A/B/C) + System Score awal + Chronobiology Window personal.	0.00	IDR	1200	["SF System Assessment lengkap (Phase A + B + C)", "System Score awal (Movement + Rest + Nutrition)", "Chronobiology Window â€” rekomendasi waktu sesi", "Akses modul gratis: Gerakan dari Kursi (Level 0-3)", "Waitlist program berbayar"]	\N	t	2026-06-26 22:34:22.409633+07	2026-06-26 22:34:22.409633+07	sf_free	lifetime	\N	0	f	10	f
ab78f5cf-91e6-4229-a73f-d88b80601979	SF Lab Consultation (Add-on)	Sekali bayar sebelum program aktif. Wajib Tier 3, opsional Tier 1-2. Mencakup pembacaan hasil lab + penilaian kondisi menyeluruh oleh Consultant + rekomendasi program awal.	350000.00	IDR	1200	["Pembacaan biomarker / hasil lab oleh Consultant", "Penilaian kondisi menyeluruh (riwayat medis, gaya hidup)", "Rekomendasi program awal yang dipersonalisasi", "Sesi 30-45 menit via online atau onsite (Bandung & Jakarta)"]	\N	t	2026-06-26 22:34:22.41918+07	2026-06-26 22:34:22.41918+07	sf_lab_consultation	one_time	\N	0	f	60	f
f91752c2-7ad1-4980-87af-5a7116b2aa5f	SF Tier 1 â€” Preventive Auto	Untuk Level 5 tanpa kondisi medis â€” fully automated, scale tanpa Consultant.	399000.00	IDR	1	["Semua fitur Free", "Full Program 60 mnt, 2x/minggu (automated Session Card)", "Daily Reset 30 mnt, 2-3x/minggu", "Session Card dengan video gerakan + metronome BPM + breathing guide", "Nutrition Guidance otomatis berbasis AI", "System Score update setiap minggu", "Mode Didampingi (Guided View) untuk setiap sesi"]	\N	f	2026-06-26 22:34:22.412302+07	2026-06-26 22:34:23.461514+07	sf_tier_1	monthly	\N	0	f	20	f
3965de0a-ec8b-4f5a-869a-437ee9c9d116	SF Tier 1 â€” Preventive Auto (3 Bulan)	Bayar 3 bulan di muka, hemat 15%.	1017000.00	IDR	3	["Semua fitur Tier 1 monthly", "Hemat Rp 180.000 dibanding bayar bulanan"]	\N	f	2026-06-26 22:34:22.414007+07	2026-06-26 22:34:23.461514+07	sf_tier_1	quarterly	1197000.00	15	f	21	f
5edf503e-77d4-4362-8c89-50af24a9f78d	SF Tier 4 â€” System Elite (Coming Soon)	Tersedia di Bandung & Jakarta. Daftar minat sekarang, kami hubungi ketika quota terbuka. Estimasi harga Rp 1.499.000/bulan saat dibuka.	1499000.00	IDR	1	["Semua fitur Tier 3", "4 sesi Trainer on-site per bulan (60 menit per sesi)", "Trainer hadir langsung di lokasi klien", "Session Card dijalankan oleh Trainer bersertifikat", "Laporan sesi Trainer langsung ke Consultant dashboard", "Priority Consultant response (2 jam)"]	\N	f	2026-06-26 22:34:22.418598+07	2026-06-26 22:34:23.461514+07	sf_tier_4_waitlist	monthly	\N	0	f	50	f
532aec9b-f243-429b-97fd-eb0a59cb1691	SF Tier 2 â€” Level 5 & 6 (Dinamis)	Program latihan otomatis untuk Level 5 & 6 (bisa jalan dan bergerak dinamis) dengan training card otomatis sesuai kondisi medis, durasi sequence teratur, movement dasar, hitungan beban otomatis, breathing pattern, dan panduan gizi/olahraga terbatas (hipertensi).	499000.00	IDR	1	["Otomatis: Level 5 & 6 (bisa jalan & bergerak dinamis)", "Training card otomatis sesuai 1 kondisi medis (5 klasifikasi)", "Sequence durasi otomatis sesuai klasifikasi (maksimal 2 kartu)", "Full program dan daily reset", "Movement dasar (gerakan dasar terbatas)", "Hitungan beban otomatis di training card", "Pola pernapasan (Breathing Pattern)", "Panduan nutrisi terbatas (hanya untuk Hipertensi)", "Panduan jam olahraga terbatas (hanya untuk Hipertensi)"]	\N	t	2026-06-26 22:34:22.414739+07	2026-06-26 22:34:23.47056+07	sf_tier_2	monthly	\N	0	t	30	f
7c265502-b8d0-4448-96ff-12fc0fb0d499	SF Tier 2 â€” Level 5 & 6 (3 Bulan)	Bayar 3 bulan di muka, hemat 15%.	1272000.00	IDR	3	["Otomatis: Level 5 & 6 (bisa jalan & bergerak dinamis)", "Training card otomatis sesuai 1 kondisi medis (5 klasifikasi)", "Sequence durasi otomatis sesuai klasifikasi (maksimal 2 kartu)", "Full program dan daily reset", "Movement dasar (gerakan dasar terbatas)", "Hitungan beban otomatis di training card", "Pola pernapasan (Breathing Pattern)", "Panduan nutrisi terbatas (hanya untuk Hipertensi)", "Panduan jam olahraga terbatas (hanya untuk Hipertensi)"]	\N	t	2026-06-26 22:34:22.41536+07	2026-06-26 22:34:23.471491+07	sf_tier_2	quarterly	1497000.00	15	f	31	f
83376bd4-61fe-4a64-8601-dae9d51db877	SF Tier 3 â€” System Active (Medical & Preventive)	Program lengkap dengan training card otomatis preventive & klasifikasi medis lengkap, sequence waktu otomatis (FC 15m, CC 20m, MC 20m, CD 5m), hitungan beban berbasis profil lengkap, tempo/BPM otomatis, dan panduan gizi lengkap untuk semua kondisi.	799000.00	IDR	1	["Training card otomatis preventive & klasifikasi medis", "Sequence waktu otomatis (Preventive FC 15m, CC 20m, MC 20m, CD 5m)", "Full program dan daily reset", "Semua gerakan dibuka bebas untuk dipilih (Full Movement)", "Hitungan beban otomatis berbasis gender, umur, dan tinggi badan", "Rekomendasi rentang tempo/BPM otomatis di masing-masing set (FC 3 set, CC 2 set, MC 3 set)", "Pola pernapasan (Breathing Pattern)", "Panduan nutrisi lengkap untuk semua kondisi kesehatan"]	\N	t	2026-06-26 22:34:22.417228+07	2026-06-26 22:34:23.472282+07	sf_tier_3	monthly	\N	0	f	40	f
e55e4316-78b6-4693-8981-6b3a5c8e72d9	SF Tier 3 â€” System Active (3 Bulan)	Bayar 3 bulan di muka, hemat 15%. Lab Consultation tetap dibayar terpisah Rp 350.000.	2037000.00	IDR	3	["Training card otomatis preventive & klasifikasi medis", "Sequence waktu otomatis (Preventive FC 15m, CC 20m, MC 20m, CD 5m)", "Full program dan daily reset", "Semua gerakan dibuka bebas untuk dipilih (Full Movement)", "Hitungan beban otomatis berbasis gender, umur, dan tinggi badan", "Rekomendasi rentang tempo/BPM otomatis di masing-masing set (FC 3 set, CC 2 set, MC 3 set)", "Pola pernapasan (Breathing Pattern)", "Panduan nutrisi lengkap untuk semua kondisi kesehatan"]	\N	t	2026-06-26 22:34:22.417944+07	2026-06-26 22:34:23.472936+07	sf_tier_3	quarterly	2397000.00	15	f	41	f
ee51cced-cb9b-4804-a5e5-80114af5b3bb	Basic	Perfect for getting started with personal training.	299000.00	IDR	1	["Akses workout library", "1 program aktif", "Progress tracking", "Chat dengan trainer"]	\N	f	2026-06-26 22:34:25.205287+07	2026-06-26 23:07:12.710083+07	\N	monthly	\N	0	f	0	f
95cb0ea6-ce21-4318-91b4-206327b67279	Pro	Most popular plan for serious fitness enthusiasts.	499000.00	IDR	1	["Semua fitur Basic", "Unlimited programs", "Nutrition tracking", "Body metrics & foto", "Prioritas support"]	\N	f	2026-06-26 22:34:25.205287+07	2026-06-26 23:07:12.710083+07	\N	monthly	\N	0	f	0	f
e2577f2a-e25d-4d68-a9e2-08614dcff0a5	Premium	Complete package with personal coaching.	999000.00	IDR	1	["Semua fitur Pro", "1-on-1 video call per minggu", "Custom meal plan", "Dedicated trainer", "Akses automation"]	\N	f	2026-06-26 22:34:25.205287+07	2026-06-26 23:07:12.710083+07	\N	monthly	\N	0	f	0	f
daa3110c-cbf6-4c02-ae05-3e2962c0f8ac	Annual Pro	Pro plan â€” save 20% with annual billing.	4790000.00	IDR	12	["Semua fitur Pro", "Hemat 20%", "2 bulan gratis"]	\N	f	2026-06-26 22:34:25.205287+07	2026-06-26 23:07:12.710083+07	\N	monthly	\N	0	f	0	f
dcc7b87e-0375-4ade-932b-56fe8b33b21c	Basic	Cocok untuk pemula yang ingin mulai latihan mandiri.	99000.00	IDR	1	["Akses video workout library", "1 program latihan dasar", "Progress tracking", "Panduan latihan pemula"]	\N	t	2026-06-26 22:34:25.410242+07	2026-06-26 22:34:25.410242+07	basic	monthly	\N	0	f	1	f
5862559c-740f-43bb-b42e-dc10894977fa	Basic Annual	Basic plan â€” hemat 16% dengan pembayaran tahunan.	999000.00	IDR	12	["Semua fitur Basic", "Hemat 16%", "Akses penuh 12 bulan"]	\N	t	2026-06-26 22:34:25.410242+07	2026-06-26 22:34:25.410242+07	basic	annual	1188000.00	16	f	2	f
f05cdc6a-f0b0-41bb-a929-92a5a33e83ac	Pro	Paling populer â€” untuk kamu yang serius ingin transformasi.	299000.00	IDR	1	["Semua fitur Basic", "Program terstruktur (bulking, cutting, dll)", "Nutrition tracking", "Body metrics & progress foto", "Chat terbatas dengan coach", "Akses komunitas"]	\N	t	2026-06-26 22:34:25.411866+07	2026-06-26 22:34:25.411866+07	pro	monthly	\N	0	t	3	f
6f990f98-e82e-4cd9-a46e-0d887c89f522	Pro Annual	Pro plan â€” hemat 30% dengan pembayaran tahunan.	2499000.00	IDR	12	["Semua fitur Pro", "Hemat 30%", "Bonus: 2 sesi konsultasi gratis", "Akses penuh 12 bulan"]	\N	t	2026-06-26 22:34:25.411866+07	2026-06-26 22:34:25.411866+07	pro	annual	3588000.00	30	f	4	f
21267301-dedb-4cbd-ada9-cd4ce30d67ac	Elite	Mendekati personal trainer â€” custom plan + review mingguan.	799000.00	IDR	1	["Semua fitur Pro", "Custom workout plan", "Custom meal plan", "Review progress mingguan", "Chat langsung dengan coach", "Prioritas support"]	\N	t	2026-06-26 22:34:25.412739+07	2026-06-26 22:34:25.412739+07	elite	monthly	\N	0	f	5	f
3a6db51f-d3df-463c-93e4-ea478be581c8	Elite Annual	Elite plan â€” hemat 27% dengan pembayaran tahunan.	6999000.00	IDR	12	["Semua fitur Elite", "Hemat 27%", "Bonus: 1-on-1 video call per bulan", "Akses penuh 12 bulan"]	\N	t	2026-06-26 22:34:25.412739+07	2026-06-26 22:34:25.412739+07	elite	annual	9588000.00	27	f	6	f
d50e4d5f-1e75-4464-9c90-c63e088a5964	Basic	Perfect for getting started with personal training.	299000.00	IDR	1	["Akses workout library", "1 program aktif", "Progress tracking", "Chat dengan trainer"]	\N	f	2026-06-26 23:07:12.676196+07	2026-06-26 23:07:12.710083+07	\N	monthly	\N	0	f	0	f
38526ecc-af1a-40a0-9208-7b303481512c	Pro	Most popular plan for serious fitness enthusiasts.	499000.00	IDR	1	["Semua fitur Basic", "Unlimited programs", "Nutrition tracking", "Body metrics & foto", "Prioritas support"]	\N	f	2026-06-26 23:07:12.676196+07	2026-06-26 23:07:12.710083+07	\N	monthly	\N	0	f	0	f
71b7dd1d-1a91-4334-b2c2-a61c80f3e022	Premium	Complete package with personal coaching.	999000.00	IDR	1	["Semua fitur Pro", "1-on-1 video call per minggu", "Custom meal plan", "Dedicated trainer", "Akses automation"]	\N	f	2026-06-26 23:07:12.676196+07	2026-06-26 23:07:12.710083+07	\N	monthly	\N	0	f	0	f
5319244c-b032-499d-824a-f0afc0d009e0	Annual Pro	Pro plan — save 20% with annual billing.	4790000.00	IDR	12	["Semua fitur Pro", "Hemat 20%", "2 bulan gratis"]	\N	f	2026-06-26 23:07:12.676196+07	2026-06-26 23:07:12.710083+07	\N	monthly	\N	0	f	0	f
e87e7e7d-720c-49fc-8def-6a569b49ae28	Basic	Cocok untuk pemula yang ingin mulai latihan mandiri.	99000.00	IDR	1	["Akses video workout library", "1 program latihan dasar", "Progress tracking", "Panduan latihan pemula"]	\N	t	2026-06-26 23:07:12.710083+07	2026-06-26 23:07:12.710083+07	basic	monthly	\N	0	f	1	f
d1911fe5-e90d-49c0-abe7-7380fbee811e	Basic Annual	Basic plan — hemat 16% dengan pembayaran tahunan.	999000.00	IDR	12	["Semua fitur Basic", "Hemat 16%", "Akses penuh 12 bulan"]	\N	t	2026-06-26 23:07:12.710083+07	2026-06-26 23:07:12.710083+07	basic	annual	1188000.00	16	f	2	f
a8026157-b892-445f-a1f5-cc8fc9425cf7	Pro	Paling populer — untuk kamu yang serius ingin transformasi.	299000.00	IDR	1	["Semua fitur Basic", "Program terstruktur (bulking, cutting, dll)", "Nutrition tracking", "Body metrics & progress foto", "Chat terbatas dengan coach", "Akses komunitas"]	\N	t	2026-06-26 23:07:12.710083+07	2026-06-26 23:07:12.710083+07	pro	monthly	\N	0	t	3	f
6f89b909-06c4-4cd5-baab-2c67b1414f17	Pro Annual	Pro plan — hemat 30% dengan pembayaran tahunan.	2499000.00	IDR	12	["Semua fitur Pro", "Hemat 30%", "Bonus: 2 sesi konsultasi gratis", "Akses penuh 12 bulan"]	\N	t	2026-06-26 23:07:12.710083+07	2026-06-26 23:07:12.710083+07	pro	annual	3588000.00	30	f	4	f
296aff02-dc63-4dd6-9d6f-fef2e25e93a3	Elite	Mendekati personal trainer — custom plan + review mingguan.	799000.00	IDR	1	["Semua fitur Pro", "Custom workout plan", "Custom meal plan", "Review progress mingguan", "Chat langsung dengan coach", "Prioritas support"]	\N	t	2026-06-26 23:07:12.710083+07	2026-06-26 23:07:12.710083+07	elite	monthly	\N	0	f	5	f
8ebe36f5-5777-4039-8816-61fcae08fefc	Elite Annual	Elite plan — hemat 27% dengan pembayaran tahunan.	6999000.00	IDR	12	["Semua fitur Elite", "Hemat 27%", "Bonus: 1-on-1 video call per bulan", "Akses penuh 12 bulan"]	\N	t	2026-06-26 23:07:12.710083+07	2026-06-26 23:07:12.710083+07	elite	annual	9588000.00	27	f	6	f
\.


--
-- Data for Name: payment_records; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.payment_records (id, subscription_id, user_id, amount, currency, status, payment_method, external_id, paid_at, failed_at, refunded_at, metadata, created_at, updated_at, payment_type, bank_account_id, proof_image_url, proof_uploaded_at, snap_token, snap_redirect_url, gateway_status, gateway_response) FROM stdin;
\.


--
-- Data for Name: payment_status_logs; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.payment_status_logs (id, payment_id, user_id, old_status, new_status, changed_by, changed_by_name, reason, subscription_id, metadata, created_at) FROM stdin;
\.


--
-- Data for Name: physical_status_levels; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.physical_status_levels (id, slug, label, description, routing, waitlist_message, sort_order, is_active, created_at, updated_at) FROM stdin;
1abc1941-0bc6-4dba-ad56-d7cb50d09155	level_0_1	Saya hanya bisa berbaring atau duduk. Berdiri sendiri sangat sulit.	Level 0â€“1: mobilitas dasar terbatas. Akses ke program aktif belum tersedia.	waitlist	Program Systemic Fitness saat ini dirancang untuk mereka yang sudah bisa bergerak mandiri. Kami sedang mengembangkan program khusus untuk anda â€” dan anda adalah alasan kami membangun platform ini lebih cepat.	1	t	2026-06-26 22:34:22.011182+07	2026-06-26 22:34:22.011182+07
4a0a437f-3eab-4b7e-97a7-d9c26a16984f	level_2_3	Saya bisa berdiri, tapi berjalan masih terbatas atau butuh bantuan.	Level 2â€“3: mampu berdiri dengan keterbatasan. Akses program aktif belum tersedia, tetap masuk waitlist + akses gratis modul "Gerakan dari Kursi".	waitlist	Program Systemic Fitness saat ini dirancang untuk mereka yang sudah bisa bergerak mandiri. Kami sedang mengembangkan program khusus untuk anda â€” dan anda adalah alasan kami membangun platform ini lebih cepat.	2	t	2026-06-26 22:34:22.011182+07	2026-06-26 22:34:22.011182+07
8bfea653-18ee-4334-b4b1-f64054cc4ca3	level_4_5_perf	Saya bisa berjalan, tapi gerakan fisik saya masih sangat terbatas dan stamina rendah.	Level 4â€“5 / Performance: lanjut ke Phase A Q2 untuk menentukan kondisi medis & program. Untuk Preventive (tidak ada kondisi medis), lakukan Basic Movement Test sebelum Q2.	continue	\N	3	t	2026-06-26 22:34:22.011182+07	2026-06-26 22:34:22.011182+07
\.


--
-- Data for Name: program_categories; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.program_categories (id, name, code, description, parameter_template, display_order, is_active, is_system, created_by, created_at, updated_at) FROM stdin;
664c2d1f-3cc4-41fa-9119-16b5f5b16d67	Functional Conditioning	functional	Program latihan fungsional untuk meningkatkan kemampuan gerak sehari-hari dan stabilitas tubuh.	{"bpm_range": true}	1	t	t	\N	2026-06-26 23:07:12.898014+07	2026-06-26 23:07:12.898014+07
05f41810-2f08-4646-bc46-0a5a40f104d8	Cardiorespiratory Conditioning	cardiorespiratory	Program latihan kardiovaskular untuk meningkatkan daya tahan jantung dan paru-paru.	{"bpm_range": true, "beban_lower": true, "beban_upper": true}	2	t	t	\N	2026-06-26 23:07:12.898014+07	2026-06-26 23:07:12.898014+07
5385cb84-7c3e-43b5-8268-f31015d6a4bd	Metabolic Conditioning	metabolic	Program latihan metabolik untuk meningkatkan pembakaran kalori dan efisiensi metabolisme tubuh.	{"resistance": true, "beban_lower": true, "beban_upper": true}	3	t	t	\N	2026-06-26 23:07:12.898014+07	2026-06-26 23:07:12.898014+07
\.


--
-- Data for Name: program_days; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.program_days (id, program_id, week_number, day_of_week, workout_id, is_rest_day) FROM stdin;
14fdae98-936d-4d27-b894-d5d8ba2f2879	283767c3-f771-465c-a8cb-aaf3af63617d	1	0	0cad9050-bac3-46f5-bba1-0afb4a724b68	f
d1b3d21d-f7d1-456c-8b6c-e32b14ac6d2e	283767c3-f771-465c-a8cb-aaf3af63617d	1	1	\N	t
d4886614-2258-4843-a0f0-41dc370f4e1e	283767c3-f771-465c-a8cb-aaf3af63617d	1	2	f6fe0dd9-28d2-423e-9f28-0052758fcc79	f
f76d677b-c897-4bd9-8da6-7ebce3fdb514	283767c3-f771-465c-a8cb-aaf3af63617d	1	3	\N	t
b3114a03-2ee1-440b-b239-1e6f9dcc6494	283767c3-f771-465c-a8cb-aaf3af63617d	1	4	187929fa-13fe-4e9a-871f-5875e992f674	f
a4a765ff-fc50-4d21-b027-8331831c2b48	283767c3-f771-465c-a8cb-aaf3af63617d	1	5	\N	t
075eb207-072a-4eb6-a58d-12499df1d6ea	283767c3-f771-465c-a8cb-aaf3af63617d	1	6	\N	t
67b40d0e-0b32-4b6c-ad1b-7689bac019a2	283767c3-f771-465c-a8cb-aaf3af63617d	2	0	0cad9050-bac3-46f5-bba1-0afb4a724b68	f
ab38a550-c989-4afc-b664-c0b23eda196a	283767c3-f771-465c-a8cb-aaf3af63617d	2	1	\N	t
02eca1f1-1626-4711-b4e1-b705d2500deb	283767c3-f771-465c-a8cb-aaf3af63617d	2	2	f6fe0dd9-28d2-423e-9f28-0052758fcc79	f
90fd8133-63fb-4fd9-9134-c3cded0f6eb0	283767c3-f771-465c-a8cb-aaf3af63617d	2	3	\N	t
cb748b6e-c33d-47cb-8ae5-b8d50f7e2ecb	283767c3-f771-465c-a8cb-aaf3af63617d	2	4	187929fa-13fe-4e9a-871f-5875e992f674	f
87f37ff6-66ce-471c-9218-c601f0a2e4b6	283767c3-f771-465c-a8cb-aaf3af63617d	2	5	\N	t
bebc9b45-b5d2-41ea-bc96-a698848a7830	283767c3-f771-465c-a8cb-aaf3af63617d	2	6	\N	t
154bccac-4ff5-4700-a5ee-71d7cfb3e419	283767c3-f771-465c-a8cb-aaf3af63617d	3	0	0cad9050-bac3-46f5-bba1-0afb4a724b68	f
50484dab-c0bc-475b-bb3c-df0e324a640f	283767c3-f771-465c-a8cb-aaf3af63617d	3	1	\N	t
01c6098b-44ae-4453-abd9-5dccc4f0e8d8	283767c3-f771-465c-a8cb-aaf3af63617d	3	2	f6fe0dd9-28d2-423e-9f28-0052758fcc79	f
4ba02429-4e46-4ef6-b74a-7db81cfa53c8	283767c3-f771-465c-a8cb-aaf3af63617d	3	3	\N	t
82f2646e-b2df-4166-92ee-ddf9e09ae851	283767c3-f771-465c-a8cb-aaf3af63617d	3	4	187929fa-13fe-4e9a-871f-5875e992f674	f
0b11edd5-4fd5-4fd9-bc4c-d36a9c4e6e1c	283767c3-f771-465c-a8cb-aaf3af63617d	3	5	\N	t
a2950334-b23c-4315-8428-cb14ecfa0687	283767c3-f771-465c-a8cb-aaf3af63617d	3	6	\N	t
5c07bba5-2531-44b3-b16f-8287e7d53234	283767c3-f771-465c-a8cb-aaf3af63617d	4	0	0cad9050-bac3-46f5-bba1-0afb4a724b68	f
f6f72f71-94ca-4943-a747-3ed945b9440a	283767c3-f771-465c-a8cb-aaf3af63617d	4	1	\N	t
d45a95b3-3533-4b56-813f-2991da9ab5ec	283767c3-f771-465c-a8cb-aaf3af63617d	4	2	f6fe0dd9-28d2-423e-9f28-0052758fcc79	f
9b2a7391-52a2-4109-a39c-903d8a5d8fd0	283767c3-f771-465c-a8cb-aaf3af63617d	4	3	\N	t
75cc3fcf-5522-4305-9e8a-1cf525fcf057	283767c3-f771-465c-a8cb-aaf3af63617d	4	4	187929fa-13fe-4e9a-871f-5875e992f674	f
44439c53-7e96-43d9-8c3d-e116475ec9c0	283767c3-f771-465c-a8cb-aaf3af63617d	4	5	\N	t
7ef6b0da-ac3f-4afc-90ae-7d79d1ed350c	283767c3-f771-465c-a8cb-aaf3af63617d	4	6	\N	t
871ce71e-f7f6-4581-a58c-38ccd7a2c0ce	e0d78dfd-5295-4a5f-8462-dd6b74617496	1	0	d8ab627f-8c03-42f4-aa43-3860f1d88df3	f
a2bd3d33-c314-444a-8ede-afd4cfd7062d	e0d78dfd-5295-4a5f-8462-dd6b74617496	1	1	c73c9923-4f53-44e9-bf88-c41d52765870	f
2604ce1c-0f43-4c60-826d-5b467c6db384	e0d78dfd-5295-4a5f-8462-dd6b74617496	1	2	aa8bfa29-596f-4f9f-ba9c-629e8b681453	f
2043a7ae-ee24-47c7-85e3-b3e7d221657d	e0d78dfd-5295-4a5f-8462-dd6b74617496	1	3	d8ab627f-8c03-42f4-aa43-3860f1d88df3	f
32b5c44b-0f17-4e76-be6f-e31721a52400	e0d78dfd-5295-4a5f-8462-dd6b74617496	1	4	c73c9923-4f53-44e9-bf88-c41d52765870	f
7c5eafdc-fcea-4a0b-8c1d-988dd94c4c8f	e0d78dfd-5295-4a5f-8462-dd6b74617496	1	5	aa8bfa29-596f-4f9f-ba9c-629e8b681453	f
7c566cbe-78f5-405e-8013-09c092dcc96d	e0d78dfd-5295-4a5f-8462-dd6b74617496	1	6	\N	t
925531de-d728-45a9-a9d7-106b2663dd95	e0d78dfd-5295-4a5f-8462-dd6b74617496	2	0	d8ab627f-8c03-42f4-aa43-3860f1d88df3	f
170b1719-5c0e-48ad-a69c-b57d056294d3	e0d78dfd-5295-4a5f-8462-dd6b74617496	2	1	c73c9923-4f53-44e9-bf88-c41d52765870	f
3b6ba4a6-a781-46fe-86f6-d15f802b3c23	e0d78dfd-5295-4a5f-8462-dd6b74617496	2	2	aa8bfa29-596f-4f9f-ba9c-629e8b681453	f
e0c6a917-00e7-420e-b333-1df02ff56930	e0d78dfd-5295-4a5f-8462-dd6b74617496	2	3	d8ab627f-8c03-42f4-aa43-3860f1d88df3	f
d9a6a8b9-3d19-40ce-bc25-652ae6e1e5d4	e0d78dfd-5295-4a5f-8462-dd6b74617496	2	4	c73c9923-4f53-44e9-bf88-c41d52765870	f
d42f670d-140c-4a2a-8bf1-74efaf3f6c52	e0d78dfd-5295-4a5f-8462-dd6b74617496	2	5	aa8bfa29-596f-4f9f-ba9c-629e8b681453	f
edaac9f1-4f21-4813-8129-828a4c70c536	e0d78dfd-5295-4a5f-8462-dd6b74617496	2	6	\N	t
6ead0220-f5a5-4bbc-a641-51477b7ccd36	e0d78dfd-5295-4a5f-8462-dd6b74617496	3	0	d8ab627f-8c03-42f4-aa43-3860f1d88df3	f
eb95fbf6-1316-44de-8619-35983781ae63	e0d78dfd-5295-4a5f-8462-dd6b74617496	3	1	c73c9923-4f53-44e9-bf88-c41d52765870	f
192a15c8-1f00-42ed-a23d-84629b35ef04	e0d78dfd-5295-4a5f-8462-dd6b74617496	3	2	aa8bfa29-596f-4f9f-ba9c-629e8b681453	f
c20d7bde-07cd-4141-9a95-bbf9725990db	e0d78dfd-5295-4a5f-8462-dd6b74617496	3	3	d8ab627f-8c03-42f4-aa43-3860f1d88df3	f
f88fe147-3a47-46e3-bb6a-dae9d52086bd	e0d78dfd-5295-4a5f-8462-dd6b74617496	3	4	c73c9923-4f53-44e9-bf88-c41d52765870	f
eb228f1a-2d01-4ee0-939f-8146eaf3943c	e0d78dfd-5295-4a5f-8462-dd6b74617496	3	5	aa8bfa29-596f-4f9f-ba9c-629e8b681453	f
9c7f77a8-86c9-4238-932e-78ababe1ff75	e0d78dfd-5295-4a5f-8462-dd6b74617496	3	6	\N	t
771350fc-33fa-46b8-bb20-e9de0c491345	e0d78dfd-5295-4a5f-8462-dd6b74617496	4	0	d8ab627f-8c03-42f4-aa43-3860f1d88df3	f
8b853664-1918-479d-82e7-0ac6a31e0719	e0d78dfd-5295-4a5f-8462-dd6b74617496	4	1	c73c9923-4f53-44e9-bf88-c41d52765870	f
b7a6efb5-e1d5-4182-ae7b-5600be180cd7	e0d78dfd-5295-4a5f-8462-dd6b74617496	4	2	aa8bfa29-596f-4f9f-ba9c-629e8b681453	f
793b29af-7e63-4945-b8c7-c93d541f218d	e0d78dfd-5295-4a5f-8462-dd6b74617496	4	3	d8ab627f-8c03-42f4-aa43-3860f1d88df3	f
0898a15c-781e-4f7a-8de5-533ee28fd10b	e0d78dfd-5295-4a5f-8462-dd6b74617496	4	4	c73c9923-4f53-44e9-bf88-c41d52765870	f
ac73c698-7388-4d70-a4c3-6ded8ca54bab	e0d78dfd-5295-4a5f-8462-dd6b74617496	4	5	aa8bfa29-596f-4f9f-ba9c-629e8b681453	f
b8ef8d9b-e9e9-457a-9820-a576890d4ed0	e0d78dfd-5295-4a5f-8462-dd6b74617496	4	6	\N	t
5c0bc9a8-d53e-4a3f-9c0f-012f896798cf	e0d78dfd-5295-4a5f-8462-dd6b74617496	5	0	d8ab627f-8c03-42f4-aa43-3860f1d88df3	f
5f970408-06c8-42d7-a6d5-4e11e78cbdb0	e0d78dfd-5295-4a5f-8462-dd6b74617496	5	1	c73c9923-4f53-44e9-bf88-c41d52765870	f
ebc44fde-66f0-4ec4-8e40-0b1fb8d57fdc	e0d78dfd-5295-4a5f-8462-dd6b74617496	5	2	aa8bfa29-596f-4f9f-ba9c-629e8b681453	f
8adac689-e017-4017-a94b-49d8cd338fa3	e0d78dfd-5295-4a5f-8462-dd6b74617496	5	3	d8ab627f-8c03-42f4-aa43-3860f1d88df3	f
99a58fe3-7ca0-4c88-9b76-90e155d2aa92	e0d78dfd-5295-4a5f-8462-dd6b74617496	5	4	c73c9923-4f53-44e9-bf88-c41d52765870	f
77dcbe64-62ff-4087-99cd-79fafbe0ee1e	e0d78dfd-5295-4a5f-8462-dd6b74617496	5	5	aa8bfa29-596f-4f9f-ba9c-629e8b681453	f
3add5662-24fc-4c92-8084-c8d656e8dd70	e0d78dfd-5295-4a5f-8462-dd6b74617496	5	6	\N	t
6ec9fcd9-874f-418e-9a58-30591a3daad3	e0d78dfd-5295-4a5f-8462-dd6b74617496	6	0	d8ab627f-8c03-42f4-aa43-3860f1d88df3	f
496ce52a-af2a-422d-826c-e34e02daad1b	e0d78dfd-5295-4a5f-8462-dd6b74617496	6	1	c73c9923-4f53-44e9-bf88-c41d52765870	f
294acbc9-cb6a-46bc-abe4-a17b2b66cb66	e0d78dfd-5295-4a5f-8462-dd6b74617496	6	2	aa8bfa29-596f-4f9f-ba9c-629e8b681453	f
ef951c22-6c9b-4f09-9488-9ac4e3df5293	e0d78dfd-5295-4a5f-8462-dd6b74617496	6	3	d8ab627f-8c03-42f4-aa43-3860f1d88df3	f
2cc2117b-2f6a-4d0a-b6f8-6f1fbcedb191	e0d78dfd-5295-4a5f-8462-dd6b74617496	6	4	c73c9923-4f53-44e9-bf88-c41d52765870	f
bea51768-69aa-41b8-9a7d-8a2446989455	e0d78dfd-5295-4a5f-8462-dd6b74617496	6	5	aa8bfa29-596f-4f9f-ba9c-629e8b681453	f
ee00a9f7-d77a-4427-9a71-1edd1e639bf2	e0d78dfd-5295-4a5f-8462-dd6b74617496	6	6	\N	t
d872f572-d6da-4036-9189-be8a85e74221	e0d78dfd-5295-4a5f-8462-dd6b74617496	7	0	d8ab627f-8c03-42f4-aa43-3860f1d88df3	f
39a3b3b0-41f3-48f4-9e3d-e2ee1269edec	e0d78dfd-5295-4a5f-8462-dd6b74617496	7	1	c73c9923-4f53-44e9-bf88-c41d52765870	f
1548da12-3239-4d13-84f3-79b2c605c123	e0d78dfd-5295-4a5f-8462-dd6b74617496	7	2	aa8bfa29-596f-4f9f-ba9c-629e8b681453	f
0b1f19d2-9b7c-4dd0-b173-14bf606e28e5	e0d78dfd-5295-4a5f-8462-dd6b74617496	7	3	d8ab627f-8c03-42f4-aa43-3860f1d88df3	f
512533a1-15c1-43bd-bc0b-aa003c3c0458	e0d78dfd-5295-4a5f-8462-dd6b74617496	7	4	c73c9923-4f53-44e9-bf88-c41d52765870	f
ebcf7100-692d-4dae-b308-d6e936895eaa	e0d78dfd-5295-4a5f-8462-dd6b74617496	7	5	aa8bfa29-596f-4f9f-ba9c-629e8b681453	f
6313491e-a316-467a-8a70-0e6e93240b89	e0d78dfd-5295-4a5f-8462-dd6b74617496	7	6	\N	t
49e6e909-5eb7-4f68-8dd9-af8f4fd7f58b	e0d78dfd-5295-4a5f-8462-dd6b74617496	8	0	d8ab627f-8c03-42f4-aa43-3860f1d88df3	f
1fd43297-fb1f-4c03-9de5-55a80994ef93	e0d78dfd-5295-4a5f-8462-dd6b74617496	8	1	c73c9923-4f53-44e9-bf88-c41d52765870	f
7a815468-b21f-410f-97ec-1c04fae2e247	e0d78dfd-5295-4a5f-8462-dd6b74617496	8	2	aa8bfa29-596f-4f9f-ba9c-629e8b681453	f
9cc48ed0-aacf-4819-b6bd-8c3f762009f4	e0d78dfd-5295-4a5f-8462-dd6b74617496	8	3	d8ab627f-8c03-42f4-aa43-3860f1d88df3	f
89765991-fdb8-402b-a56f-ad9142bccb38	e0d78dfd-5295-4a5f-8462-dd6b74617496	8	4	c73c9923-4f53-44e9-bf88-c41d52765870	f
fd0595a8-c241-4701-8a79-3248389fd01f	e0d78dfd-5295-4a5f-8462-dd6b74617496	8	5	aa8bfa29-596f-4f9f-ba9c-629e8b681453	f
bb78beb8-224c-455c-af57-0845a11274d7	e0d78dfd-5295-4a5f-8462-dd6b74617496	8	6	\N	t
c26ee9f4-64eb-4221-825e-f8adcc478e36	ad91b56a-9d4f-4803-9455-d864e27630fe	1	0	81ea0647-cbac-414a-9302-b70aaff304de	f
b45dc0aa-60f6-42a3-bda1-262cac3db7a8	ad91b56a-9d4f-4803-9455-d864e27630fe	1	1	becbb1bb-8d84-4fb9-9d1f-125a6954b6ce	f
389e8396-3a06-4c12-8a05-d4aa698b897d	ad91b56a-9d4f-4803-9455-d864e27630fe	1	2	28c02bef-5801-4d4d-a5f1-4eea3598fbf1	f
33b597d0-ee05-43b7-8571-6d1c754b8723	ad91b56a-9d4f-4803-9455-d864e27630fe	1	3	1d0720d4-a986-49a5-853a-a5550a879a43	f
010fcf4e-2873-44a6-ac06-cfc1ea702926	ad91b56a-9d4f-4803-9455-d864e27630fe	1	4	c2afc8a7-44c3-48f7-977a-1d8f87f14200	f
392b8af2-bbd0-4c18-94db-b746a916bfc8	ad91b56a-9d4f-4803-9455-d864e27630fe	1	5	\N	t
a790ab42-a007-4032-a10d-b2cf68a6628b	ad91b56a-9d4f-4803-9455-d864e27630fe	1	6	\N	t
4b3d7691-114c-446b-9262-13e63a002514	ad91b56a-9d4f-4803-9455-d864e27630fe	2	0	81ea0647-cbac-414a-9302-b70aaff304de	f
3c5542ca-4be2-4c29-95d0-280b517496ab	ad91b56a-9d4f-4803-9455-d864e27630fe	2	1	becbb1bb-8d84-4fb9-9d1f-125a6954b6ce	f
7b17a37e-ddb7-4845-ab21-3417e561ea4b	ad91b56a-9d4f-4803-9455-d864e27630fe	2	2	28c02bef-5801-4d4d-a5f1-4eea3598fbf1	f
45c8a451-93b0-4517-98f5-fe9b266e0cc7	ad91b56a-9d4f-4803-9455-d864e27630fe	2	3	1d0720d4-a986-49a5-853a-a5550a879a43	f
da706998-52d2-41c3-903c-ce2df976d21c	ad91b56a-9d4f-4803-9455-d864e27630fe	2	4	c2afc8a7-44c3-48f7-977a-1d8f87f14200	f
90d6a04a-3171-42a1-801e-1eb8f6b93621	ad91b56a-9d4f-4803-9455-d864e27630fe	2	5	\N	t
025dc84c-2f0e-4568-af6f-0146023a770f	ad91b56a-9d4f-4803-9455-d864e27630fe	2	6	\N	t
3edc2526-b7b1-4cad-9951-c00d3982702b	ad91b56a-9d4f-4803-9455-d864e27630fe	3	0	81ea0647-cbac-414a-9302-b70aaff304de	f
7498aea4-708c-423d-8eb1-18e4e6d9f289	ad91b56a-9d4f-4803-9455-d864e27630fe	3	1	becbb1bb-8d84-4fb9-9d1f-125a6954b6ce	f
ecf8be99-0c51-4ce4-b638-3e3bae290457	ad91b56a-9d4f-4803-9455-d864e27630fe	3	2	28c02bef-5801-4d4d-a5f1-4eea3598fbf1	f
d2906827-adf3-40f4-958a-e4e7c870f98c	ad91b56a-9d4f-4803-9455-d864e27630fe	3	3	1d0720d4-a986-49a5-853a-a5550a879a43	f
186a0d2d-aa05-4f9c-92a3-ad91ff65900e	ad91b56a-9d4f-4803-9455-d864e27630fe	3	4	c2afc8a7-44c3-48f7-977a-1d8f87f14200	f
37e7c760-4c4c-4087-9386-f1c596f9aa01	ad91b56a-9d4f-4803-9455-d864e27630fe	3	5	\N	t
763e0044-5c83-4348-9923-d65fa1ecb89f	ad91b56a-9d4f-4803-9455-d864e27630fe	3	6	\N	t
3c8ba582-2430-444c-a529-684c022b31ee	ad91b56a-9d4f-4803-9455-d864e27630fe	4	0	81ea0647-cbac-414a-9302-b70aaff304de	f
189f0a64-3391-4a4d-8720-658843db0633	ad91b56a-9d4f-4803-9455-d864e27630fe	4	1	becbb1bb-8d84-4fb9-9d1f-125a6954b6ce	f
99274d9b-37e4-487c-ba00-7b455b57e7f0	ad91b56a-9d4f-4803-9455-d864e27630fe	4	2	28c02bef-5801-4d4d-a5f1-4eea3598fbf1	f
bc3fb008-6420-4bd2-ab15-011cd0503d66	ad91b56a-9d4f-4803-9455-d864e27630fe	4	3	1d0720d4-a986-49a5-853a-a5550a879a43	f
5524a300-1786-4c25-ba7d-20c503e45e91	ad91b56a-9d4f-4803-9455-d864e27630fe	4	4	c2afc8a7-44c3-48f7-977a-1d8f87f14200	f
22bd2ca5-8e3b-4a6e-9aaf-ff206b48fea3	ad91b56a-9d4f-4803-9455-d864e27630fe	4	5	\N	t
2e4a553e-4bd6-427a-b459-61689590a41b	ad91b56a-9d4f-4803-9455-d864e27630fe	4	6	\N	t
f9a04ca3-b5d2-462b-9af0-06cf5d6d13fc	ad91b56a-9d4f-4803-9455-d864e27630fe	5	0	81ea0647-cbac-414a-9302-b70aaff304de	f
065bd676-f0bf-4bf2-945c-09fcb4943327	ad91b56a-9d4f-4803-9455-d864e27630fe	5	1	becbb1bb-8d84-4fb9-9d1f-125a6954b6ce	f
3fa0f0ec-6df2-44fb-9e7a-34d0597f1705	ad91b56a-9d4f-4803-9455-d864e27630fe	5	2	28c02bef-5801-4d4d-a5f1-4eea3598fbf1	f
0c7ecabd-38a9-4f92-b278-b262cf726cd2	ad91b56a-9d4f-4803-9455-d864e27630fe	5	3	1d0720d4-a986-49a5-853a-a5550a879a43	f
fe7abf08-ccec-4ad6-a9e2-d41742cc61b2	ad91b56a-9d4f-4803-9455-d864e27630fe	5	4	c2afc8a7-44c3-48f7-977a-1d8f87f14200	f
707a7ed7-0fb7-4884-a401-fb0af70ee157	ad91b56a-9d4f-4803-9455-d864e27630fe	5	5	\N	t
93e34a80-d62c-4f5d-a9fc-023d59f5925d	ad91b56a-9d4f-4803-9455-d864e27630fe	5	6	\N	t
98198444-4fc3-4f0c-a145-c9db93b7ee3c	ad91b56a-9d4f-4803-9455-d864e27630fe	6	0	81ea0647-cbac-414a-9302-b70aaff304de	f
4792aeac-b58c-46b7-8835-a5f985b1756f	ad91b56a-9d4f-4803-9455-d864e27630fe	6	1	becbb1bb-8d84-4fb9-9d1f-125a6954b6ce	f
45e107f6-a8d8-40da-9540-64bd2f14f5eb	ad91b56a-9d4f-4803-9455-d864e27630fe	6	2	28c02bef-5801-4d4d-a5f1-4eea3598fbf1	f
1297034e-ed2b-4ab4-a511-12ce7fdc9d49	ad91b56a-9d4f-4803-9455-d864e27630fe	6	3	1d0720d4-a986-49a5-853a-a5550a879a43	f
3f40f0dd-944a-4d69-8435-51ea8e0d87f8	ad91b56a-9d4f-4803-9455-d864e27630fe	6	4	c2afc8a7-44c3-48f7-977a-1d8f87f14200	f
694dc54d-946b-4f27-b593-781e8f155a0d	ad91b56a-9d4f-4803-9455-d864e27630fe	6	5	\N	t
abc98639-75f5-4f11-bfc3-0f63c420d928	ad91b56a-9d4f-4803-9455-d864e27630fe	6	6	\N	t
44e02fd0-9235-48cc-a532-656e3d223a1b	ad91b56a-9d4f-4803-9455-d864e27630fe	7	0	81ea0647-cbac-414a-9302-b70aaff304de	f
5a2ccdf8-3f7d-4ecf-8715-9160d1eb5886	ad91b56a-9d4f-4803-9455-d864e27630fe	7	1	becbb1bb-8d84-4fb9-9d1f-125a6954b6ce	f
81edddac-6fc8-485d-94c9-be679297d38c	ad91b56a-9d4f-4803-9455-d864e27630fe	7	2	28c02bef-5801-4d4d-a5f1-4eea3598fbf1	f
f3c2bc02-34e6-45ea-b2df-e03ccf3254d1	ad91b56a-9d4f-4803-9455-d864e27630fe	7	3	1d0720d4-a986-49a5-853a-a5550a879a43	f
37b500a4-fad5-47b1-9da7-47933d7f753b	ad91b56a-9d4f-4803-9455-d864e27630fe	7	4	c2afc8a7-44c3-48f7-977a-1d8f87f14200	f
a5ee93e4-ea48-4b83-a04b-08063285f02e	ad91b56a-9d4f-4803-9455-d864e27630fe	7	5	\N	t
6186209d-090f-497f-bc06-16ec71a0fedf	ad91b56a-9d4f-4803-9455-d864e27630fe	7	6	\N	t
14e55feb-c47c-473c-97e7-e384cb6cd0bd	ad91b56a-9d4f-4803-9455-d864e27630fe	8	0	81ea0647-cbac-414a-9302-b70aaff304de	f
a8f19248-876c-413d-85a6-74e72ad3535b	ad91b56a-9d4f-4803-9455-d864e27630fe	8	1	becbb1bb-8d84-4fb9-9d1f-125a6954b6ce	f
607af71c-5189-42f4-a609-cc22574a8940	ad91b56a-9d4f-4803-9455-d864e27630fe	8	2	28c02bef-5801-4d4d-a5f1-4eea3598fbf1	f
07f8b7ec-30d6-4d4d-85e6-3d609c1ba2fb	ad91b56a-9d4f-4803-9455-d864e27630fe	8	3	1d0720d4-a986-49a5-853a-a5550a879a43	f
d4145d5f-27a5-4aba-868e-60069b63197f	ad91b56a-9d4f-4803-9455-d864e27630fe	8	4	c2afc8a7-44c3-48f7-977a-1d8f87f14200	f
e35b3913-aa0b-4ee6-9961-654305cabbd8	ad91b56a-9d4f-4803-9455-d864e27630fe	8	5	\N	t
036053e7-1d0d-4b5a-bfbc-e460822f6437	ad91b56a-9d4f-4803-9455-d864e27630fe	8	6	\N	t
84e1baf6-2e22-4ed0-834b-8dc87af489ad	ad91b56a-9d4f-4803-9455-d864e27630fe	9	0	81ea0647-cbac-414a-9302-b70aaff304de	f
cf82929e-b262-4ccb-965a-0c3d97b98037	ad91b56a-9d4f-4803-9455-d864e27630fe	9	1	becbb1bb-8d84-4fb9-9d1f-125a6954b6ce	f
c76e4bf8-ac25-4196-b874-94e2a373cc13	ad91b56a-9d4f-4803-9455-d864e27630fe	9	2	28c02bef-5801-4d4d-a5f1-4eea3598fbf1	f
a04f951f-1b7a-450d-8cd5-20a73288ba3a	ad91b56a-9d4f-4803-9455-d864e27630fe	9	3	1d0720d4-a986-49a5-853a-a5550a879a43	f
806ade43-0914-4139-b84b-9cf48cb12d67	ad91b56a-9d4f-4803-9455-d864e27630fe	9	4	c2afc8a7-44c3-48f7-977a-1d8f87f14200	f
cb4e1437-35f7-4f28-b70e-acacc49eb064	ad91b56a-9d4f-4803-9455-d864e27630fe	9	5	\N	t
f5ca0e35-69bc-47dd-8a2b-76af9cd07893	ad91b56a-9d4f-4803-9455-d864e27630fe	9	6	\N	t
090d195d-760c-4294-ab08-41c144a94d44	ad91b56a-9d4f-4803-9455-d864e27630fe	10	0	81ea0647-cbac-414a-9302-b70aaff304de	f
4664512d-bc3e-4730-a661-7be872214794	ad91b56a-9d4f-4803-9455-d864e27630fe	10	1	becbb1bb-8d84-4fb9-9d1f-125a6954b6ce	f
65b386c3-6914-4f44-9b98-0c1d17358f01	ad91b56a-9d4f-4803-9455-d864e27630fe	10	2	28c02bef-5801-4d4d-a5f1-4eea3598fbf1	f
7ae07e07-2d7a-4e6c-b4b7-e007c9988409	ad91b56a-9d4f-4803-9455-d864e27630fe	10	3	1d0720d4-a986-49a5-853a-a5550a879a43	f
9b8bdd66-1fc8-42c4-bcbd-ef1882f3556b	ad91b56a-9d4f-4803-9455-d864e27630fe	10	4	c2afc8a7-44c3-48f7-977a-1d8f87f14200	f
56097dcd-d2e7-4952-b81d-7466e5ac3b86	ad91b56a-9d4f-4803-9455-d864e27630fe	10	5	\N	t
d9faddd1-52be-4720-8f08-129c645cce53	ad91b56a-9d4f-4803-9455-d864e27630fe	10	6	\N	t
c602aac0-4cdb-42cc-8960-9c20e70c71ad	ad91b56a-9d4f-4803-9455-d864e27630fe	11	0	81ea0647-cbac-414a-9302-b70aaff304de	f
bef35e34-2cf7-49f6-b142-50a9a48b7629	ad91b56a-9d4f-4803-9455-d864e27630fe	11	1	becbb1bb-8d84-4fb9-9d1f-125a6954b6ce	f
24349f18-a7bc-45c0-b99b-230690588792	ad91b56a-9d4f-4803-9455-d864e27630fe	11	2	28c02bef-5801-4d4d-a5f1-4eea3598fbf1	f
ce752955-0a30-4a56-87cb-247e10e0640e	ad91b56a-9d4f-4803-9455-d864e27630fe	11	3	1d0720d4-a986-49a5-853a-a5550a879a43	f
390a2d71-bcf6-4687-b51b-749696259f94	ad91b56a-9d4f-4803-9455-d864e27630fe	11	4	c2afc8a7-44c3-48f7-977a-1d8f87f14200	f
3ebab737-b7cd-489a-811b-e3979912dd51	ad91b56a-9d4f-4803-9455-d864e27630fe	11	5	\N	t
c4cd8d5d-3cf7-4ae1-8b95-3b4da5d58df6	ad91b56a-9d4f-4803-9455-d864e27630fe	11	6	\N	t
e4c6ec0b-48a8-4f04-bbf4-dd591d180483	ad91b56a-9d4f-4803-9455-d864e27630fe	12	0	81ea0647-cbac-414a-9302-b70aaff304de	f
719e9259-07c4-434e-80b0-bf864fbd3668	ad91b56a-9d4f-4803-9455-d864e27630fe	12	1	becbb1bb-8d84-4fb9-9d1f-125a6954b6ce	f
6fabebe5-b7df-40e3-96f1-b504148daa30	ad91b56a-9d4f-4803-9455-d864e27630fe	12	2	28c02bef-5801-4d4d-a5f1-4eea3598fbf1	f
a96d714c-1fc8-4ad8-b081-7a0cd6c8cad6	ad91b56a-9d4f-4803-9455-d864e27630fe	12	3	1d0720d4-a986-49a5-853a-a5550a879a43	f
f195e9ac-a1ae-4ae6-b00c-f8b4a4ea6bd8	ad91b56a-9d4f-4803-9455-d864e27630fe	12	4	c2afc8a7-44c3-48f7-977a-1d8f87f14200	f
1a466d18-14a9-46e6-8e91-4766e97d5510	ad91b56a-9d4f-4803-9455-d864e27630fe	12	5	\N	t
741b21b1-ac0a-46f3-8e11-2a9f92f5ec20	ad91b56a-9d4f-4803-9455-d864e27630fe	12	6	\N	t
49ed1879-12b8-48e5-aede-7b20823d12c5	949862aa-853e-4a1e-ba81-40255f17e7fa	1	0	a020e9d0-e44a-4866-a940-ee0eca9795d2	f
5fee8431-3c84-4ebe-a30e-b8537810d8a7	949862aa-853e-4a1e-ba81-40255f17e7fa	1	1	\N	t
ef0bdfbc-3870-4ce8-b813-3ef33e95dd17	949862aa-853e-4a1e-ba81-40255f17e7fa	1	2	3ba47441-abc2-4209-ad95-1f9cac9b09c0	f
301df5a9-f909-4924-90d9-97527bf2d03d	949862aa-853e-4a1e-ba81-40255f17e7fa	1	3	\N	t
388c7da5-50e2-4f11-b4e2-ea2a26a7c924	949862aa-853e-4a1e-ba81-40255f17e7fa	1	4	55734559-3141-4ae4-9c5d-788dbcff03c6	f
b7abf452-e43f-4205-8889-a4eb187271c6	949862aa-853e-4a1e-ba81-40255f17e7fa	1	5	\N	t
fa250d3d-fa31-4c57-a5b5-2c7e0ffcdf74	949862aa-853e-4a1e-ba81-40255f17e7fa	1	6	\N	t
aa544049-b828-407d-8aeb-f8fee17148ac	949862aa-853e-4a1e-ba81-40255f17e7fa	2	0	a020e9d0-e44a-4866-a940-ee0eca9795d2	f
7e9867a7-1c86-4e46-9c7b-b79255749f94	949862aa-853e-4a1e-ba81-40255f17e7fa	2	1	\N	t
29b22c4c-b98e-4102-97c5-740f03e92b94	949862aa-853e-4a1e-ba81-40255f17e7fa	2	2	3ba47441-abc2-4209-ad95-1f9cac9b09c0	f
a4d37197-0afd-45eb-9d4d-ebaa6b0cef50	949862aa-853e-4a1e-ba81-40255f17e7fa	2	3	\N	t
1b8d100b-bb5f-473d-bc4f-acb5fee6cca9	949862aa-853e-4a1e-ba81-40255f17e7fa	2	4	55734559-3141-4ae4-9c5d-788dbcff03c6	f
d9e42a0c-3f66-4d1d-8b40-7d5fa8477516	949862aa-853e-4a1e-ba81-40255f17e7fa	2	5	\N	t
cd87a5c0-9aa1-464b-8587-dd9fb55d23e1	949862aa-853e-4a1e-ba81-40255f17e7fa	2	6	\N	t
925816b6-f285-410e-95ec-9f536824d806	949862aa-853e-4a1e-ba81-40255f17e7fa	3	0	a020e9d0-e44a-4866-a940-ee0eca9795d2	f
ff3d6627-11ab-4d75-8b10-4bfb13d53b69	949862aa-853e-4a1e-ba81-40255f17e7fa	3	1	\N	t
66d5d0dc-e1bf-490e-aacc-c4d1937ca2ef	949862aa-853e-4a1e-ba81-40255f17e7fa	3	2	3ba47441-abc2-4209-ad95-1f9cac9b09c0	f
470cf6c0-8180-4ac6-95a8-11b6cf31a2d3	949862aa-853e-4a1e-ba81-40255f17e7fa	3	3	\N	t
c65548f1-92a9-476d-a320-a9f3028b9e9a	949862aa-853e-4a1e-ba81-40255f17e7fa	3	4	55734559-3141-4ae4-9c5d-788dbcff03c6	f
22bbfb37-7539-476d-89ba-47b2b048cdde	949862aa-853e-4a1e-ba81-40255f17e7fa	3	5	\N	t
815ea006-8733-4344-9c91-fc7c96390cd6	949862aa-853e-4a1e-ba81-40255f17e7fa	3	6	\N	t
4372c567-f2e9-439d-8dd7-cd1fea795b0f	949862aa-853e-4a1e-ba81-40255f17e7fa	4	0	a020e9d0-e44a-4866-a940-ee0eca9795d2	f
fc6cb6db-1996-4f6f-b9f6-b6334a868c9e	949862aa-853e-4a1e-ba81-40255f17e7fa	4	1	\N	t
28f48d29-c26b-4618-80b0-d0b977da9fec	949862aa-853e-4a1e-ba81-40255f17e7fa	4	2	3ba47441-abc2-4209-ad95-1f9cac9b09c0	f
f0a99faa-4a14-442a-bc05-6e806f9a0a58	949862aa-853e-4a1e-ba81-40255f17e7fa	4	3	\N	t
4226366a-47f0-49f1-b9fc-1b82119b48f6	949862aa-853e-4a1e-ba81-40255f17e7fa	4	4	55734559-3141-4ae4-9c5d-788dbcff03c6	f
1e68fa5c-95cc-4459-a1ca-5914d64d1535	949862aa-853e-4a1e-ba81-40255f17e7fa	4	5	\N	t
5a048fb2-e008-44e2-b345-3b5824ccb971	949862aa-853e-4a1e-ba81-40255f17e7fa	4	6	\N	t
4c9ded9d-615a-4f2d-8f06-0e86ed31a115	d01f806c-1f60-4117-817b-57171c37e42f	1	0	60499b59-4657-46ce-adbb-fc0ef606042d	f
12648dd9-faf5-4ebb-bbf8-7ce9e918cdbe	d01f806c-1f60-4117-817b-57171c37e42f	1	1	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	f
4fdd5107-39f9-4757-bc2f-d07247838be0	d01f806c-1f60-4117-817b-57171c37e42f	1	2	27f7272a-fd92-4146-8f1a-78b266c89f2d	f
0bcf6007-a5c7-45ce-9d49-de7e8cc93c55	d01f806c-1f60-4117-817b-57171c37e42f	1	3	60499b59-4657-46ce-adbb-fc0ef606042d	f
c9a38eec-cfea-43e5-a77d-6ee7f91be56c	d01f806c-1f60-4117-817b-57171c37e42f	1	4	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	f
92adc096-51e7-4a71-be00-869d0bac2961	d01f806c-1f60-4117-817b-57171c37e42f	1	5	27f7272a-fd92-4146-8f1a-78b266c89f2d	f
007e681f-ba92-4199-88b0-e2976dbcc9dd	d01f806c-1f60-4117-817b-57171c37e42f	1	6	\N	t
d22275ca-a5b6-420f-9637-f9dc6a1b12cc	d01f806c-1f60-4117-817b-57171c37e42f	2	0	60499b59-4657-46ce-adbb-fc0ef606042d	f
83670120-a5ff-4ab9-ad6c-9f7b631af012	d01f806c-1f60-4117-817b-57171c37e42f	2	1	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	f
14fca8a3-6d47-41b1-a8e8-79401e28fe90	d01f806c-1f60-4117-817b-57171c37e42f	2	2	27f7272a-fd92-4146-8f1a-78b266c89f2d	f
976683e4-57af-4acf-92ce-05d156579438	d01f806c-1f60-4117-817b-57171c37e42f	2	3	60499b59-4657-46ce-adbb-fc0ef606042d	f
12137102-04ac-4908-8bfd-a5c953a06dcb	d01f806c-1f60-4117-817b-57171c37e42f	2	4	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	f
fc6af48c-4cd0-4842-a60c-897833e85c4d	d01f806c-1f60-4117-817b-57171c37e42f	2	5	27f7272a-fd92-4146-8f1a-78b266c89f2d	f
64817fd3-dce7-4bd4-9334-96a77265cbbb	d01f806c-1f60-4117-817b-57171c37e42f	2	6	\N	t
13d0cb05-63ab-4753-a4b1-1ed1af548d05	d01f806c-1f60-4117-817b-57171c37e42f	3	0	60499b59-4657-46ce-adbb-fc0ef606042d	f
6c1930ac-1451-4be1-94e3-17d1665a6cda	d01f806c-1f60-4117-817b-57171c37e42f	3	1	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	f
f9ca0e26-9f46-4036-aa5e-d76251bb814b	d01f806c-1f60-4117-817b-57171c37e42f	3	2	27f7272a-fd92-4146-8f1a-78b266c89f2d	f
13c156b2-7e4e-4bf3-8655-f2e1dc3ac04b	d01f806c-1f60-4117-817b-57171c37e42f	3	3	60499b59-4657-46ce-adbb-fc0ef606042d	f
aebb5ea3-4341-44f9-9514-701af6be88b0	d01f806c-1f60-4117-817b-57171c37e42f	3	4	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	f
4fb9705d-97da-42d5-90cf-179cd3df8501	d01f806c-1f60-4117-817b-57171c37e42f	3	5	27f7272a-fd92-4146-8f1a-78b266c89f2d	f
50bf3b2f-3dd7-42b4-81a1-f5770ce8b8c4	d01f806c-1f60-4117-817b-57171c37e42f	3	6	\N	t
32bdde96-40a8-410c-a0a2-e307aa227f36	d01f806c-1f60-4117-817b-57171c37e42f	4	0	60499b59-4657-46ce-adbb-fc0ef606042d	f
5d737564-8c1d-4ba4-8080-6dea7fad4b6c	d01f806c-1f60-4117-817b-57171c37e42f	4	1	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	f
97ed309c-fefd-4924-b3c6-0e8ddcffcd4d	d01f806c-1f60-4117-817b-57171c37e42f	4	2	27f7272a-fd92-4146-8f1a-78b266c89f2d	f
288a5b5f-0b1d-40e0-a042-9463cdbb3aaf	d01f806c-1f60-4117-817b-57171c37e42f	4	3	60499b59-4657-46ce-adbb-fc0ef606042d	f
08141801-8b37-4cb6-aaf7-c6839c049652	d01f806c-1f60-4117-817b-57171c37e42f	4	4	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	f
9591fadb-6ba0-4e93-81d6-e5e40bbd78a3	d01f806c-1f60-4117-817b-57171c37e42f	4	5	27f7272a-fd92-4146-8f1a-78b266c89f2d	f
f4fa0671-1fee-4df4-9809-cf0d7a21436f	d01f806c-1f60-4117-817b-57171c37e42f	4	6	\N	t
47ab651d-c41d-4dba-854a-c2f2c89ac3d7	d01f806c-1f60-4117-817b-57171c37e42f	5	0	60499b59-4657-46ce-adbb-fc0ef606042d	f
c382ffe3-bb24-488c-a266-21ddd70f8b2c	d01f806c-1f60-4117-817b-57171c37e42f	5	1	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	f
f652a47f-d99e-464d-8279-795085dad172	d01f806c-1f60-4117-817b-57171c37e42f	5	2	27f7272a-fd92-4146-8f1a-78b266c89f2d	f
8583e201-9b26-4d9a-8f04-5c59be9da1c0	d01f806c-1f60-4117-817b-57171c37e42f	5	3	60499b59-4657-46ce-adbb-fc0ef606042d	f
4d466fd5-a949-4dab-ab73-82dbbe03dbc1	d01f806c-1f60-4117-817b-57171c37e42f	5	4	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	f
e0c00cd5-f440-4ee6-bd02-e03fca559179	d01f806c-1f60-4117-817b-57171c37e42f	5	5	27f7272a-fd92-4146-8f1a-78b266c89f2d	f
77b96185-dddf-4fb9-b743-b6012e62c445	d01f806c-1f60-4117-817b-57171c37e42f	5	6	\N	t
8194261c-d032-4ed8-83a1-ccbdc9092a2d	d01f806c-1f60-4117-817b-57171c37e42f	6	0	60499b59-4657-46ce-adbb-fc0ef606042d	f
3b8888b6-6ce0-4ce5-8915-806f41048234	d01f806c-1f60-4117-817b-57171c37e42f	6	1	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	f
000593f9-913c-41a4-91a0-5a85b1c8d652	d01f806c-1f60-4117-817b-57171c37e42f	6	2	27f7272a-fd92-4146-8f1a-78b266c89f2d	f
f04f568c-f136-4a16-8dc8-db931e4fda76	d01f806c-1f60-4117-817b-57171c37e42f	6	3	60499b59-4657-46ce-adbb-fc0ef606042d	f
b9f4bec0-0493-40c4-b7aa-47866364b9cf	d01f806c-1f60-4117-817b-57171c37e42f	6	4	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	f
749864fa-e443-47e3-b206-2fcc058c4470	d01f806c-1f60-4117-817b-57171c37e42f	6	5	27f7272a-fd92-4146-8f1a-78b266c89f2d	f
aff4c760-2ee0-4d8d-b727-02427b703efd	d01f806c-1f60-4117-817b-57171c37e42f	6	6	\N	t
b378e418-a5aa-49a2-a40f-d963e2362be3	d01f806c-1f60-4117-817b-57171c37e42f	7	0	60499b59-4657-46ce-adbb-fc0ef606042d	f
ca9e7aa9-7192-4f33-a983-a0672f9cb723	d01f806c-1f60-4117-817b-57171c37e42f	7	1	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	f
cd23b01e-1e81-4acc-aaa3-59ed047d9d60	d01f806c-1f60-4117-817b-57171c37e42f	7	2	27f7272a-fd92-4146-8f1a-78b266c89f2d	f
9a31eadc-0df6-41b1-84a1-90bf511c3f59	d01f806c-1f60-4117-817b-57171c37e42f	7	3	60499b59-4657-46ce-adbb-fc0ef606042d	f
bf85600a-e841-49ab-81f0-5169d306fe3b	d01f806c-1f60-4117-817b-57171c37e42f	7	4	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	f
e9309acb-b540-45ed-88dd-c0893f043a48	d01f806c-1f60-4117-817b-57171c37e42f	7	5	27f7272a-fd92-4146-8f1a-78b266c89f2d	f
26650977-242c-431e-8166-f2da8c8bb498	d01f806c-1f60-4117-817b-57171c37e42f	7	6	\N	t
59f51fa7-ff99-42df-b72a-3d89002376e6	d01f806c-1f60-4117-817b-57171c37e42f	8	0	60499b59-4657-46ce-adbb-fc0ef606042d	f
8b7c191f-cd72-4cfb-adce-36d3f9fa9db0	d01f806c-1f60-4117-817b-57171c37e42f	8	1	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	f
cb914aa6-ea45-4821-8841-065a354ae9dc	d01f806c-1f60-4117-817b-57171c37e42f	8	2	27f7272a-fd92-4146-8f1a-78b266c89f2d	f
c90b7bd0-d7c5-41b9-bb12-711e0d375091	d01f806c-1f60-4117-817b-57171c37e42f	8	3	60499b59-4657-46ce-adbb-fc0ef606042d	f
7e5de6b2-0680-4341-932d-d47622ef5c69	d01f806c-1f60-4117-817b-57171c37e42f	8	4	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	f
1a01ec9e-79a6-4304-86aa-275b8a854998	d01f806c-1f60-4117-817b-57171c37e42f	8	5	27f7272a-fd92-4146-8f1a-78b266c89f2d	f
3608db99-a918-4687-a40b-0141a1736ab3	d01f806c-1f60-4117-817b-57171c37e42f	8	6	\N	t
9af8e2da-49c3-4552-92ad-7bb612cd6ada	395e713a-9f72-4dfe-91f0-73f9e426a57a	1	0	a2e3dcaa-967b-4897-ac2c-edcf82396156	f
07665192-bd60-4524-af29-3298d20bce6c	395e713a-9f72-4dfe-91f0-73f9e426a57a	1	1	ba021ebe-3860-4aaf-bd5d-a330c21952a8	f
ad63a873-1d6a-423f-ae4d-c235b74e1932	395e713a-9f72-4dfe-91f0-73f9e426a57a	1	2	c9785992-68ce-41a0-b857-c650c96c9287	f
6f1572ab-6359-4b36-b30e-480f7b5ee3ff	395e713a-9f72-4dfe-91f0-73f9e426a57a	1	3	f330d37e-4d1a-47c0-bb61-95e891a3a830	f
24beb61d-2941-45cf-907a-acd47b571113	395e713a-9f72-4dfe-91f0-73f9e426a57a	1	4	e3097813-f8fd-47f3-94bc-99a47fab3966	f
8ac25488-74cd-43b8-b599-594e3c577ebf	395e713a-9f72-4dfe-91f0-73f9e426a57a	1	5	\N	t
9ea8285e-734e-46ef-990a-d7b282042d86	395e713a-9f72-4dfe-91f0-73f9e426a57a	1	6	\N	t
c2ca3970-713a-486a-abc3-b223ac3addfd	395e713a-9f72-4dfe-91f0-73f9e426a57a	2	0	a2e3dcaa-967b-4897-ac2c-edcf82396156	f
427f1935-70ff-4751-8cdc-68b7e3ff85c0	395e713a-9f72-4dfe-91f0-73f9e426a57a	2	1	ba021ebe-3860-4aaf-bd5d-a330c21952a8	f
bac63020-94a4-45ad-89b0-4e63bcf86ce6	395e713a-9f72-4dfe-91f0-73f9e426a57a	2	2	c9785992-68ce-41a0-b857-c650c96c9287	f
aa32ba98-42da-403f-b0e5-cb9b59efdac1	395e713a-9f72-4dfe-91f0-73f9e426a57a	2	3	f330d37e-4d1a-47c0-bb61-95e891a3a830	f
217e934e-86c2-467a-9d2d-eb834f44ff2e	395e713a-9f72-4dfe-91f0-73f9e426a57a	2	4	e3097813-f8fd-47f3-94bc-99a47fab3966	f
84b620b8-8a33-4c86-9335-3e7ed22abe26	395e713a-9f72-4dfe-91f0-73f9e426a57a	2	5	\N	t
b13f36ac-91db-45b5-88af-1ad99cf893b9	395e713a-9f72-4dfe-91f0-73f9e426a57a	2	6	\N	t
fa3fd363-c2e1-479a-8e68-232e44520f46	395e713a-9f72-4dfe-91f0-73f9e426a57a	3	0	a2e3dcaa-967b-4897-ac2c-edcf82396156	f
9f018df8-ae17-4d9c-b581-f33f223d3296	395e713a-9f72-4dfe-91f0-73f9e426a57a	3	1	ba021ebe-3860-4aaf-bd5d-a330c21952a8	f
613230d0-9cef-429c-b037-aeda1c37139b	395e713a-9f72-4dfe-91f0-73f9e426a57a	3	2	c9785992-68ce-41a0-b857-c650c96c9287	f
9e1297aa-f310-4a61-9011-2e700c0a3416	395e713a-9f72-4dfe-91f0-73f9e426a57a	3	3	f330d37e-4d1a-47c0-bb61-95e891a3a830	f
b89717ec-7b57-436b-bafe-8073a8ab3c14	395e713a-9f72-4dfe-91f0-73f9e426a57a	3	4	e3097813-f8fd-47f3-94bc-99a47fab3966	f
6e93ef48-a2da-4357-9723-2e792ff0c9b3	395e713a-9f72-4dfe-91f0-73f9e426a57a	3	5	\N	t
8562a1a4-7d98-49c9-b7bd-d50d59d3ee26	395e713a-9f72-4dfe-91f0-73f9e426a57a	3	6	\N	t
960064e5-3c17-4612-96d5-7463b1350907	395e713a-9f72-4dfe-91f0-73f9e426a57a	4	0	a2e3dcaa-967b-4897-ac2c-edcf82396156	f
9ad74f16-e796-4600-9933-77adc814a00e	395e713a-9f72-4dfe-91f0-73f9e426a57a	4	1	ba021ebe-3860-4aaf-bd5d-a330c21952a8	f
97afb05d-e505-4435-a3c3-397b022591e1	395e713a-9f72-4dfe-91f0-73f9e426a57a	4	2	c9785992-68ce-41a0-b857-c650c96c9287	f
57185310-1bf6-4156-b1eb-33346afb61cb	395e713a-9f72-4dfe-91f0-73f9e426a57a	4	3	f330d37e-4d1a-47c0-bb61-95e891a3a830	f
a2f95556-2ef9-401e-893c-025e9bd6abc3	395e713a-9f72-4dfe-91f0-73f9e426a57a	4	4	e3097813-f8fd-47f3-94bc-99a47fab3966	f
47a28415-25f1-4ae2-8739-b7a144043e0a	395e713a-9f72-4dfe-91f0-73f9e426a57a	4	5	\N	t
372e3dbb-d74e-429d-afa5-65f74f1971a5	395e713a-9f72-4dfe-91f0-73f9e426a57a	4	6	\N	t
ef5831ca-c266-4ef5-909d-e08b146e034b	395e713a-9f72-4dfe-91f0-73f9e426a57a	5	0	a2e3dcaa-967b-4897-ac2c-edcf82396156	f
fcd23d83-cced-481e-ac9b-8e00ec4fb20b	395e713a-9f72-4dfe-91f0-73f9e426a57a	5	1	ba021ebe-3860-4aaf-bd5d-a330c21952a8	f
f348b512-779a-4f08-86eb-5f95ee71a88f	395e713a-9f72-4dfe-91f0-73f9e426a57a	5	2	c9785992-68ce-41a0-b857-c650c96c9287	f
cc0e4851-c5ef-4f1d-8efb-e1b5873a34ae	395e713a-9f72-4dfe-91f0-73f9e426a57a	5	3	f330d37e-4d1a-47c0-bb61-95e891a3a830	f
3efb06ac-9982-45d9-b065-21e9c64924f6	395e713a-9f72-4dfe-91f0-73f9e426a57a	5	4	e3097813-f8fd-47f3-94bc-99a47fab3966	f
148881d9-1c1d-4fdc-9cef-e710c54d5ee0	395e713a-9f72-4dfe-91f0-73f9e426a57a	5	5	\N	t
64cd8e69-2482-4c9a-8e92-fa2764afe1d9	395e713a-9f72-4dfe-91f0-73f9e426a57a	5	6	\N	t
7385876e-fa3f-4669-82ff-f7044226975d	395e713a-9f72-4dfe-91f0-73f9e426a57a	6	0	a2e3dcaa-967b-4897-ac2c-edcf82396156	f
6aea4e3a-9bd7-45fd-880e-7aa44a54a91a	395e713a-9f72-4dfe-91f0-73f9e426a57a	6	1	ba021ebe-3860-4aaf-bd5d-a330c21952a8	f
2fa76fc7-06b6-468c-bac5-92c33daa64bd	395e713a-9f72-4dfe-91f0-73f9e426a57a	6	2	c9785992-68ce-41a0-b857-c650c96c9287	f
ac542736-3e27-40b1-8af4-17bdc6bbfcb1	395e713a-9f72-4dfe-91f0-73f9e426a57a	6	3	f330d37e-4d1a-47c0-bb61-95e891a3a830	f
f0f9eaa8-2a09-4937-8e08-d2f8040e3c3f	395e713a-9f72-4dfe-91f0-73f9e426a57a	6	4	e3097813-f8fd-47f3-94bc-99a47fab3966	f
5671571e-23a1-4e49-8f60-c7823a5561b9	395e713a-9f72-4dfe-91f0-73f9e426a57a	6	5	\N	t
49504f37-0503-40df-8139-6412549ba3dc	395e713a-9f72-4dfe-91f0-73f9e426a57a	6	6	\N	t
3c62e68c-645f-4401-a69c-c1de8fac93ce	395e713a-9f72-4dfe-91f0-73f9e426a57a	7	0	a2e3dcaa-967b-4897-ac2c-edcf82396156	f
76e32a6e-edcf-4ca7-9bbd-d2f0764ff492	395e713a-9f72-4dfe-91f0-73f9e426a57a	7	1	ba021ebe-3860-4aaf-bd5d-a330c21952a8	f
de497d0a-e283-47ee-ace3-9af5d9cebc2c	395e713a-9f72-4dfe-91f0-73f9e426a57a	7	2	c9785992-68ce-41a0-b857-c650c96c9287	f
bf2adb94-4d0e-4756-b547-fb8e1f81f8cf	395e713a-9f72-4dfe-91f0-73f9e426a57a	7	3	f330d37e-4d1a-47c0-bb61-95e891a3a830	f
ad83262f-3a47-4bbe-9d82-c5871dfad162	395e713a-9f72-4dfe-91f0-73f9e426a57a	7	4	e3097813-f8fd-47f3-94bc-99a47fab3966	f
d32a9157-9345-43be-b983-74e154cac2ed	395e713a-9f72-4dfe-91f0-73f9e426a57a	7	5	\N	t
c62c6c78-cedb-45d7-a0b7-d816f55ea1d1	395e713a-9f72-4dfe-91f0-73f9e426a57a	7	6	\N	t
b4fa4209-d729-43f1-8cf4-1637e4915006	395e713a-9f72-4dfe-91f0-73f9e426a57a	8	0	a2e3dcaa-967b-4897-ac2c-edcf82396156	f
5e92d85c-a0d1-4abd-bede-6539bc813b1d	395e713a-9f72-4dfe-91f0-73f9e426a57a	8	1	ba021ebe-3860-4aaf-bd5d-a330c21952a8	f
4c70273c-7917-4a93-a3c1-acd99e6b73bf	395e713a-9f72-4dfe-91f0-73f9e426a57a	8	2	c9785992-68ce-41a0-b857-c650c96c9287	f
4b73a104-cc24-4137-b81c-2eeec0edbdff	395e713a-9f72-4dfe-91f0-73f9e426a57a	8	3	f330d37e-4d1a-47c0-bb61-95e891a3a830	f
aefb5ffe-dce1-4577-8d2a-d3ac39b819d7	395e713a-9f72-4dfe-91f0-73f9e426a57a	8	4	e3097813-f8fd-47f3-94bc-99a47fab3966	f
94cae174-c80c-4ed1-b2b1-c93037bfb8d0	395e713a-9f72-4dfe-91f0-73f9e426a57a	8	5	\N	t
e8edb641-611f-4e45-8f84-9363c270f179	395e713a-9f72-4dfe-91f0-73f9e426a57a	8	6	\N	t
cca3268b-393c-42cc-a364-f780081048cf	395e713a-9f72-4dfe-91f0-73f9e426a57a	9	0	a2e3dcaa-967b-4897-ac2c-edcf82396156	f
27a08f45-eae6-4d99-992c-a6f4fba9b89c	395e713a-9f72-4dfe-91f0-73f9e426a57a	9	1	ba021ebe-3860-4aaf-bd5d-a330c21952a8	f
b4c668a0-00f0-405e-b55e-5864580a544d	395e713a-9f72-4dfe-91f0-73f9e426a57a	9	2	c9785992-68ce-41a0-b857-c650c96c9287	f
92ce5cdc-138b-4b34-8106-6eb813a8ce30	395e713a-9f72-4dfe-91f0-73f9e426a57a	9	3	f330d37e-4d1a-47c0-bb61-95e891a3a830	f
29d27a1e-c3e2-466d-937d-f07e1a22e655	395e713a-9f72-4dfe-91f0-73f9e426a57a	9	4	e3097813-f8fd-47f3-94bc-99a47fab3966	f
8a5926bc-c889-4dc0-b5e7-4352edbf18a8	395e713a-9f72-4dfe-91f0-73f9e426a57a	9	5	\N	t
f0b85e62-e9af-493d-beda-8bec1256c4a9	395e713a-9f72-4dfe-91f0-73f9e426a57a	9	6	\N	t
8684296b-7fa4-4a4a-b0a0-7a908b8a5260	395e713a-9f72-4dfe-91f0-73f9e426a57a	10	0	a2e3dcaa-967b-4897-ac2c-edcf82396156	f
8feedc49-d924-4c73-b417-a7fec7c2b7df	395e713a-9f72-4dfe-91f0-73f9e426a57a	10	1	ba021ebe-3860-4aaf-bd5d-a330c21952a8	f
0fe9a0f3-9e89-4e57-ba3e-c862111abb10	395e713a-9f72-4dfe-91f0-73f9e426a57a	10	2	c9785992-68ce-41a0-b857-c650c96c9287	f
cacedeac-e728-4a6e-883e-ef4170eacc6b	395e713a-9f72-4dfe-91f0-73f9e426a57a	10	3	f330d37e-4d1a-47c0-bb61-95e891a3a830	f
2caec56a-04ce-4d45-be87-137e08a9eeb7	395e713a-9f72-4dfe-91f0-73f9e426a57a	10	4	e3097813-f8fd-47f3-94bc-99a47fab3966	f
24f97cf4-fb20-4b42-8b58-da9651c97767	395e713a-9f72-4dfe-91f0-73f9e426a57a	10	5	\N	t
9fb506e2-738a-449f-98fc-387461d63830	395e713a-9f72-4dfe-91f0-73f9e426a57a	10	6	\N	t
4480522a-73ae-4c40-ba43-5795e7eb3623	395e713a-9f72-4dfe-91f0-73f9e426a57a	11	0	a2e3dcaa-967b-4897-ac2c-edcf82396156	f
1733d66f-f14b-4514-98a9-d89336dd1586	395e713a-9f72-4dfe-91f0-73f9e426a57a	11	1	ba021ebe-3860-4aaf-bd5d-a330c21952a8	f
3318af7e-c428-4bd4-9d9e-4e4772c5e9c6	395e713a-9f72-4dfe-91f0-73f9e426a57a	11	2	c9785992-68ce-41a0-b857-c650c96c9287	f
c212b158-af73-424a-84d4-68791a7ab332	395e713a-9f72-4dfe-91f0-73f9e426a57a	11	3	f330d37e-4d1a-47c0-bb61-95e891a3a830	f
cfa56f06-4c84-4bf8-b966-931c828f21ed	395e713a-9f72-4dfe-91f0-73f9e426a57a	11	4	e3097813-f8fd-47f3-94bc-99a47fab3966	f
c0ee6c87-5917-468b-9db7-c60ade905eef	395e713a-9f72-4dfe-91f0-73f9e426a57a	11	5	\N	t
82f42840-bb04-460f-ac67-d64c11c5ab70	395e713a-9f72-4dfe-91f0-73f9e426a57a	11	6	\N	t
4f919cb7-8e89-460b-b447-de6a3943099a	395e713a-9f72-4dfe-91f0-73f9e426a57a	12	0	a2e3dcaa-967b-4897-ac2c-edcf82396156	f
74599ec6-72ee-47b6-9e86-b20fa3c1de2b	395e713a-9f72-4dfe-91f0-73f9e426a57a	12	1	ba021ebe-3860-4aaf-bd5d-a330c21952a8	f
27ee2b3a-52d2-4975-a396-ecd2062a8b99	395e713a-9f72-4dfe-91f0-73f9e426a57a	12	2	c9785992-68ce-41a0-b857-c650c96c9287	f
b465ad8e-ce53-4db6-97d7-29d1a3b7742f	395e713a-9f72-4dfe-91f0-73f9e426a57a	12	3	f330d37e-4d1a-47c0-bb61-95e891a3a830	f
ed0b8bbf-b81b-403e-be0a-85d158415aeb	395e713a-9f72-4dfe-91f0-73f9e426a57a	12	4	e3097813-f8fd-47f3-94bc-99a47fab3966	f
ccdce819-bc8e-4943-a37c-22ad330bc4a9	395e713a-9f72-4dfe-91f0-73f9e426a57a	12	5	\N	t
73b45ca8-54cf-45e0-b7aa-58d302e57c7e	395e713a-9f72-4dfe-91f0-73f9e426a57a	12	6	\N	t
\.


--
-- Data for Name: programs; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.programs (id, name, description, duration_weeks, difficulty, goal, created_by, is_template, created_at, updated_at) FROM stdin;
283767c3-f771-465c-a8cb-aaf3af63617d	Beginner Full Body	Perfect starting program. 3 days per week with full body workouts focusing on compound movements and proper form.	4	beginner	general_fitness	\N	t	2026-06-26 22:34:25.046987+07	2026-06-26 22:34:25.046987+07
e0d78dfd-5295-4a5f-8462-dd6b74617496	Intermediate PPL	Push/Pull/Legs split â€” 6 days per week. Run each PPL rotation twice. Ideal for lifters with 6+ months experience wanting to build muscle.	8	intermediate	gain_muscle	\N	t	2026-06-26 22:34:25.046987+07	2026-06-26 22:34:25.046987+07
ad91b56a-9d4f-4803-9455-d864e27630fe	Advanced Bodybuilding Split	5-day bro split for experienced lifters. High volume with supersets. Chest/Back/Shoulders/Legs/Arms. Requires solid strength foundation.	12	advanced	gain_muscle	\N	t	2026-06-26 22:34:25.046987+07	2026-06-26 22:34:25.046987+07
949862aa-853e-4a1e-ba81-40255f17e7fa	Beginner Full Body	Perfect starting program. 3 days per week with full body workouts focusing on compound movements and proper form.	4	beginner	general_fitness	\N	t	2026-06-26 23:07:12.594983+07	2026-06-26 23:07:12.594983+07
d01f806c-1f60-4117-817b-57171c37e42f	Intermediate PPL	Push/Pull/Legs split — 6 days per week. Run each PPL rotation twice. Ideal for lifters with 6+ months experience wanting to build muscle.	8	intermediate	gain_muscle	\N	t	2026-06-26 23:07:12.594983+07	2026-06-26 23:07:12.594983+07
395e713a-9f72-4dfe-91f0-73f9e426a57a	Advanced Bodybuilding Split	5-day bro split for experienced lifters. High volume with supersets. Chest/Back/Shoulders/Legs/Arms. Requires solid strength foundation.	12	advanced	gain_muscle	\N	t	2026-06-26 23:07:12.594983+07	2026-06-26 23:07:12.594983+07
\.


--
-- Data for Name: progress_logs; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.progress_logs (id, user_id, exercise_id, workout_id, logged_at, sets, notes, mood) FROM stdin;
\.


--
-- Data for Name: promotions; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.promotions (id, title, description, image_url, badge, route, status, start_date, end_date, sort_order, created_by, created_at, updated_at) FROM stdin;
b0000000-0000-0000-0000-000000000001	New Member Special - 50% Off!	Join now and get 50% off your first month subscription. Limited time offer for new members only!	https://placehold.co/1200x400/FF6B35/ffffff?text=NEW+MEMBER+50%25+OFF&font=montserrat	HOT	/payments/plans	active	2026-04-01 07:00:00+07	2026-07-01 06:59:59+07	1	\N	2026-06-26 23:07:13.00136+07	2026-06-26 23:07:13.00136+07
b0000000-0000-0000-0000-000000000002	Summer Body Challenge 2026	Join our 8-week summer body transformation challenge! Includes personalized workout & meal plans.	https://placehold.co/1200x400/1E90FF/ffffff?text=SUMMER+BODY+CHALLENGE&font=montserrat	NEW	/challenges	active	2026-04-10 07:00:00+07	2026-08-01 06:59:59+07	2	\N	2026-06-26 23:07:13.00136+07	2026-06-26 23:07:13.00136+07
b0000000-0000-0000-0000-000000000003	Free Nutrition Guide Download	Download our comprehensive nutrition guide for free. Learn meal prep, macros, and healthy eating habits.	https://placehold.co/1200x400/2ECC71/ffffff?text=FREE+NUTRITION+GUIDE&font=montserrat	FREE	/nutrition-guidance	active	2026-04-01 07:00:00+07	2027-01-01 06:59:59+07	3	\N	2026-06-26 23:07:13.00136+07	2026-06-26 23:07:13.00136+07
b0000000-0000-0000-0000-000000000004	Personal Training - Book 10 Get 2 Free	Book 10 personal training sessions and get 2 extra sessions absolutely free!	https://placehold.co/1200x400/9B59B6/ffffff?text=PT+SESSION+DEAL&font=montserrat	DEAL	/scheduling/calendar	active	2026-04-15 07:00:00+07	2026-06-01 06:59:59+07	4	\N	2026-06-26 23:07:13.00136+07	2026-06-26 23:07:13.00136+07
b0000000-0000-0000-0000-000000000005	Fitness Expo 2026 - Coming Soon	Get ready for the biggest fitness expo this year! Free entry for all premium members.	https://placehold.co/1200x400/E74C3C/ffffff?text=FITNESS+EXPO+2026&font=montserrat	SOON	/announcements	draft	2026-08-01 07:00:00+07	2026-08-16 06:59:59+07	5	\N	2026-06-26 23:07:13.00136+07	2026-06-26 23:07:13.00136+07
b0000000-0000-0000-0000-000000000006	March Madness - 30% Off All Plans	Our March promotion has ended. Stay tuned for more exciting offers!	https://placehold.co/1200x400/95A5A6/ffffff?text=MARCH+MADNESS+ENDED&font=montserrat	ENDED	/payments/plans	ended	2026-03-01 07:00:00+07	2026-04-01 06:59:59+07	6	\N	2026-06-26 23:07:13.00136+07	2026-06-26 23:07:13.00136+07
\.


--
-- Data for Name: session_meals; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.session_meals (id, session_id, meal_time, food_description, food_id, notes) FROM stdin;
\.


--
-- Data for Name: session_medicines; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.session_medicines (id, session_id, medicine_id, notes) FROM stdin;
\.


--
-- Data for Name: session_vitals; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.session_vitals (id, session_id, measurement_type, systolic, diastolic, heartrate, notes) FROM stdin;
\.


--
-- Data for Name: specific_conditions; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.specific_conditions (id, classification_id, slug, label, description, severity_default, notes, sort_order, is_active, created_at, updated_at) FROM stdin;
ce898b15-fa21-4cb1-9272-f1a3f00f1a26	2a6ef936-8d13-4db1-bf6c-4e7afa244bba	fibromyalgia	Fibromyalgia	\N	moderate	{}	6	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
aa3b5657-9b4d-4b74-ba3b-f56176f13249	2a6ef936-8d13-4db1-bf6c-4e7afa244bba	tumor-jinak	Tumor jinak	\N	monitor	{"medical_priority": true}	5	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
095a49e3-e43f-46b5-875f-7682ed6996d5	2a6ef936-8d13-4db1-bf6c-4e7afa244bba	kista	Kista (ovarium, payudara, tiroid)	\N	monitor	{"medical_priority": true}	4	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
59c7e0c3-de20-4800-b88b-9ece5ed94dd7	2a6ef936-8d13-4db1-bf6c-4e7afa244bba	inflamasi-sistemik	Inflamasi sistemik	\N	moderate	{}	3	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
081c9a97-815f-494a-97c8-3dbc41a964e2	2a6ef936-8d13-4db1-bf6c-4e7afa244bba	alergi-kronis	Alergi kronis	\N	mild	{}	2	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
12e040d4-40a2-4726-aa1c-cd4ea27530f8	2a6ef936-8d13-4db1-bf6c-4e7afa244bba	autoimun	Autoimun (Lupus, RA, MS, dll)	\N	monitor	{}	1	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
4e75340f-9760-4d60-acc3-ecf1af165c19	80afc103-42c4-4beb-afdb-8f5d6f1c0fc3	hiperkalemia-ringan	Hiperkalemia ringan	\N	mild	{"lab_required": true}	4	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
d368dcb7-b8fa-43b6-ba93-e1d72b1ad415	80afc103-42c4-4beb-afdb-8f5d6f1c0fc3	asam-urat	Asam urat / Gout	\N	mild	{}	3	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
99da4c99-e16c-47dd-ac7a-80f314822482	80afc103-42c4-4beb-afdb-8f5d6f1c0fc3	batu-ginjal	Batu ginjal	\N	mild	{}	2	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
53844d01-a34a-4430-8929-53bee6cd2e40	80afc103-42c4-4beb-afdb-8f5d6f1c0fc3	ckd-1-3	Gangguan ginjal (CKD stadium 1â€“3)	\N	moderate	{"lab_required": true}	1	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
456f5753-3c88-4070-bdbf-5685d37eb5a5	79650160-ecd0-4564-ac3f-e78e5a62ea83	gangguan-syaraf-pusat	Gangguan syaraf pusat (post-stroke, MS ringan)	\N	severe	{"medical_priority": true}	7	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
69caca47-8a85-4923-b8ac-ad7a622c57db	79650160-ecd0-4564-ac3f-e78e5a62ea83	kolesterol	Kolesterol tinggi	\N	mild	{}	6	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
a0b159b0-d88d-43a6-ba84-492934c4c0c7	79650160-ecd0-4564-ac3f-e78e5a62ea83	ppok-ringan	PPOK ringan	\N	mild	{}	5	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
52726bbf-cc13-4fd9-b0d2-b1df0abbe363	79650160-ecd0-4564-ac3f-e78e5a62ea83	asma-terkontrol	Asma terkontrol	\N	mild	{}	4	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
0429f563-a39b-49f8-9248-78e0bb165591	79650160-ecd0-4564-ac3f-e78e5a62ea83	aritmia-ringan	Aritmia ringan	\N	moderate	{}	3	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
e4d8fd75-0f74-4c50-8be2-61ea143bd3bb	79650160-ecd0-4564-ac3f-e78e5a62ea83	penyakit-jantung	Penyakit jantung koroner stabil	\N	severe	{"medical_priority": true}	2	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
467d94c1-829c-4aa0-a07c-95f111b86f15	79650160-ecd0-4564-ac3f-e78e5a62ea83	hipertensi	Hipertensi (stadium 1â€“2)	\N	moderate	{}	1	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
f99ebf6f-9fc8-4bb4-bc70-2a15439063b3	5884abe4-0575-407f-a263-97794aeef2a4	obesitas-metabolik	Obesitas metabolik	\N	moderate	{}	6	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
ccc1eabd-cf48-4c48-bdcd-014af263fb67	5884abe4-0575-407f-a263-97794aeef2a4	resistensi-insulin	Resistensi insulin	\N	mild	{}	5	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
e487e880-07f3-4b1b-b55e-fe777ee63102	5884abe4-0575-407f-a263-97794aeef2a4	tiroid	Gangguan tiroid (hipotiroid / hipertiroid terkontrol)	\N	moderate	{}	4	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
a5f507a2-d5c4-4ae0-ba20-af9fa6cab99a	5884abe4-0575-407f-a263-97794aeef2a4	pcos	PCOS	\N	moderate	{}	3	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
1875792b-5c26-4220-b066-cf44c8956df1	5884abe4-0575-407f-a263-97794aeef2a4	pre-diabetes	Pre-diabetes	\N	mild	{}	2	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
ddd166f4-2312-460f-ab28-b16e6714644b	5884abe4-0575-407f-a263-97794aeef2a4	diabetes-tipe-2	Diabetes Tipe 2 (terkontrol)	\N	moderate	{}	1	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
76fe457a-9358-464a-9b79-b0a32cdf1d5d	587d2fd5-f8ca-4ab0-8700-b57fb3c2220b	lemah-otot-pasca-imobilisasi	Kelemahan otot pasca imobilisasi	\N	mild	{}	8	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
d28de3aa-920c-49b2-8b24-7a5749574614	587d2fd5-f8ca-4ab0-8700-b57fb3c2220b	neuropati-perifer	Gangguan syaraf tepi (neuropati perifer)	\N	moderate	{}	7	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
072bc01d-79c9-4f1b-bdd0-ec956ab39f39	587d2fd5-f8ca-4ab0-8700-b57fb3c2220b	skoliosis	Skoliosis	\N	moderate	{}	6	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
1a2f58c8-1d52-4b32-94c9-41d7da03f622	587d2fd5-f8ca-4ab0-8700-b57fb3c2220b	frozen-shoulder	Frozen shoulder	\N	mild	{}	5	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
c520392c-3ed3-4580-b99a-9f8770ad9da4	587d2fd5-f8ca-4ab0-8700-b57fb3c2220b	spondylosis	Spondylosis	\N	moderate	{}	4	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
c42bb10c-1b64-4192-822f-3124e07a5d44	587d2fd5-f8ca-4ab0-8700-b57fb3c2220b	hnp	Hernia Nukleus Pulposus (HNP)	\N	severe	{}	3	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
a4a8507d-6372-4199-b786-7fa20df14536	587d2fd5-f8ca-4ab0-8700-b57fb3c2220b	osteoporosis	Osteoporosis	\N	moderate	{}	2	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
3a536ac5-5489-4746-a83e-9a3d1b6c1837	587d2fd5-f8ca-4ab0-8700-b57fb3c2220b	osteoarthritis	Osteoarthritis	\N	moderate	{}	1	t	2026-06-26 22:34:21.887302+07	2026-06-26 22:34:21.887302+07
\.


--
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.subscriptions (id, user_id, plan_id, status, started_at, expires_at, cancelled_at, payment_method, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: system_score_weights; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.system_score_weights (id, name, movement_pct, nutrition_pct, rest_pct, is_active, notes, created_by, created_at, updated_at) FROM stdin;
21c9f546-164c-4978-a77d-28fa0b88180e	SF Default	35	35	30	t	Default System Score weights from SF Master Platform Spec v1.0 / 2026, Â§04.	\N	2026-06-26 22:34:22.276565+07	2026-06-26 22:34:22.276565+07
\.


--
-- Data for Name: tier4_waitlist_entries; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.tier4_waitlist_entries (id, user_id, full_name, email, phone, city, source, assessment_id, note, status, admin_note, contacted_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: trainer_availability; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.trainer_availability (id, trainer_id, day_of_week, start_time, end_time, is_active) FROM stdin;
b77a1d69-f501-4c1c-ac63-33fd7146d4ec	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	2	07:00:00	12:00:00	t
c88d0bb6-ba9c-4754-b38c-11566df4709e	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	3	08:00:00	13:00:00	t
45388423-7948-465f-b5d4-de68b3c12c1d	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	4	08:00:00	13:00:00	t
91ec3e6b-6816-4b66-bbf5-322c8d6ba0dc	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	2	14:00:00	20:00:00	t
e087fb8e-5521-484f-8702-802d3cc64e04	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	5	14:00:00	18:00:00	t
edfa6730-1727-4e1a-8d03-72b92585535d	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	1	14:00:00	20:00:00	t
aa069bae-8460-4bfa-8d2e-3cd6e31515b8	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	3	15:00:00	21:00:00	t
59f7a1c5-a285-4b70-8d1d-5e4148779586	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	5	07:00:00	12:00:00	t
e31318ed-2718-442c-a5c2-c7bba952993b	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	4	15:00:00	21:00:00	t
27f869c0-eae4-4f18-adae-7465bec96c8d	7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	1	07:00:00	12:00:00	t
\.


--
-- Data for Name: trainer_card_sequences; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.trainer_card_sequences (id, trainer_card_id, program_category_id, duration, sort_order, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: trainer_card_set_items; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.trainer_card_set_items (id, set_id, movement_id, movement_name, body_part, equipment, reps, sets_count, sort_order, created_at, updated_at, breathing_core, breathing_diaphragm, allowed_tiers) FROM stdin;
\.


--
-- Data for Name: trainer_card_sets; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.trainer_card_sets (id, sequence_id, set_number, duration, equipment_upper, equipment_lower, type_id, bpm, extra_load, notes, sort_order, created_at, updated_at, pattern, breathing_core, breathing_diaphragm) FROM stdin;
\.


--
-- Data for Name: trainer_card_template_sequences; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.trainer_card_template_sequences (id, template_id, program_category_id, duration, sort_order, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: trainer_card_template_set_items; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.trainer_card_template_set_items (id, set_id, movement_id, movement_name, body_part, equipment, reps, sets_count, sort_order, created_at, updated_at, breathing_core, breathing_diaphragm, allowed_tiers) FROM stdin;
\.


--
-- Data for Name: trainer_card_template_sets; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.trainer_card_template_sets (id, sequence_id, set_number, duration, equipment_upper, equipment_lower, type_id, bpm, extra_load, notes, sort_order, created_at, updated_at, pattern, breathing_core, breathing_diaphragm) FROM stdin;
\.


--
-- Data for Name: trainer_card_templates; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.trainer_card_templates (id, level, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: trainer_card_types; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.trainer_card_types (id, name, description, is_active, sort_order, created_at, updated_at) FROM stdin;
00e6b107-7baf-40e6-8432-dd662f614dcd	Isolate	Gerakan isolasi â€” satu bagian tubuh per gerakan	t	1	2026-06-26 22:34:19.691434+07	2026-06-26 22:34:19.691434+07
d49fd69d-4092-4f57-95a4-d4b77542279b	Dynamic	Gerakan dinamis â€” kombinasi upper dan lower body	t	2	2026-06-26 22:34:19.691434+07	2026-06-26 22:34:19.691434+07
\.


--
-- Data for Name: trainer_cards; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.trainer_cards (id, customer_id, level, notes, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: trainer_clients; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.trainer_clients (trainer_id, client_id, assigned_at, status, role_type) FROM stdin;
7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	91057f40-e579-4624-aaa7-92a538a0982f	2026-06-26 22:34:25.868015+07	active	trainer
7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	9b79840c-119e-4494-b37c-354b603cc864	2026-06-26 22:34:25.882919+07	active	trainer
7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	c9eb9182-0a47-450e-98d2-4264862529eb	2026-06-26 22:34:25.88405+07	active	trainer
00f2b827-ab58-4b2b-ba93-8db9420d2db7	f048cfed-379d-4d1f-9c6d-c70ca5678527	2026-06-26 22:34:25.884965+07	active	trainer
00f2b827-ab58-4b2b-ba93-8db9420d2db7	aef34b62-410a-44c2-8b07-9542fd31a7b2	2026-06-26 22:34:25.88589+07	active	trainer
00f2b827-ab58-4b2b-ba93-8db9420d2db7	9c5483d6-0e8e-49cd-bf9b-da32c9fa6d3b	2026-06-26 22:34:25.886794+07	active	trainer
44e6c28e-be82-47c3-beac-d7dc33c712b4	8bb6f22a-6c4c-458b-a12d-5ba5cfa88ccd	2026-06-26 22:34:25.887563+07	active	trainer
44e6c28e-be82-47c3-beac-d7dc33c712b4	531a93f5-fa57-4e53-a020-cf31eb9d8293	2026-06-26 22:34:25.888386+07	paused	trainer
\.


--
-- Data for Name: training_schedules; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.training_schedules (id, client_id, trainer_id, day_of_week, start_time, end_time, location, notes, is_active, created_by, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: training_sessions; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.training_sessions (id, schedule_id, client_id, trainer_id, session_date, start_time, end_time, status, location, notes, is_substitute, original_trainer_id, substitute_reason, created_by, created_at, updated_at, substituted_by, substituted_at) FROM stdin;
\.


--
-- Data for Name: uploads; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.uploads (id, original_name, stored_name, mime_type, size_bytes, width, height, path, url, uploaded_by, entity_type, entity_id, created_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: user_profiles; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.user_profiles (user_id, date_of_birth, gender, height_cm, weight_kg, fitness_goal, experience_level, medical_notes, emergency_contact, updated_at) FROM stdin;
f8f2faed-9a96-4fdc-8ac6-f6ae466b0a93	\N	male	\N	\N	\N	advanced	\N	\N	2026-06-26 22:34:25.192504+07
8ea4d240-6efb-41ec-8382-dcfc833dc9bf	\N	male	\N	\N	\N	advanced	\N	\N	2026-06-26 22:34:25.197325+07
74d7caa4-6804-43f4-854a-467177aaf5dd	\N	female	\N	\N	\N	intermediate	\N	\N	2026-06-26 22:34:25.198868+07
7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	1988-04-10	male	178.0	82.0	gain_muscle	advanced	\N	\N	2026-06-26 22:34:25.200472+07
00f2b827-ab58-4b2b-ba93-8db9420d2db7	1991-09-25	female	165.0	58.0	maintain	advanced	\N	\N	2026-06-26 22:34:25.202869+07
44e6c28e-be82-47c3-beac-d7dc33c712b4	1993-12-05	male	182.0	88.0	gain_muscle	advanced	\N	\N	2026-06-26 22:34:25.20445+07
91057f40-e579-4624-aaa7-92a538a0982f	1995-03-15	male	175.0	78.0	gain_muscle	intermediate	\N	\N	2026-06-26 22:34:25.622382+07
f048cfed-379d-4d1f-9c6d-c70ca5678527	1998-07-22	female	160.0	55.0	lose_weight	beginner	\N	\N	2026-06-26 22:34:25.627796+07
9b79840c-119e-4494-b37c-354b603cc864	1992-11-08	male	170.0	85.0	lose_weight	beginner	\N	\N	2026-06-26 22:34:25.629348+07
aef34b62-410a-44c2-8b07-9542fd31a7b2	2000-01-30	female	165.0	60.0	improve_endurance	intermediate	\N	\N	2026-06-26 22:34:25.630724+07
8bb6f22a-6c4c-458b-a12d-5ba5cfa88ccd	1997-06-12	male	180.0	90.0	maintain	advanced	\N	\N	2026-06-26 22:34:25.632089+07
9c5483d6-0e8e-49cd-bf9b-da32c9fa6d3b	1999-05-18	female	158.0	52.0	flexibility	beginner	\N	\N	2026-06-26 22:34:25.633502+07
c9eb9182-0a47-450e-98d2-4264862529eb	1994-08-20	male	173.0	75.0	gain_muscle	intermediate	\N	\N	2026-06-26 22:34:25.634884+07
531a93f5-fa57-4e53-a020-cf31eb9d8293	1996-02-14	female	162.0	65.0	lose_weight	beginner	\N	\N	2026-06-26 22:34:25.636127+07
268517b9-3377-4087-a523-08c3b032bfe2	2001-10-05	male	168.0	70.0	gain_muscle	beginner	\N	\N	2026-06-26 22:34:25.637465+07
248a8cb1-9d52-41f8-94b2-1ff93098b3ec	1993-04-28	female	170.0	68.0	maintain	intermediate	\N	\N	2026-06-26 22:34:25.638884+07
4df24737-38d4-4e08-94de-e835be654e72	1986-07-14	female	162.0	56.0	maintain	advanced	\N	\N	2026-06-26 23:07:13.055322+07
40bc1a74-2fa6-4737-adad-c10d34734e79	1990-10-28	male	168.0	68.0	\N	\N	\N	\N	2026-06-29 05:20:01.253518+07
\.


--
-- Data for Name: user_programs; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.user_programs (id, user_id, program_id, assigned_by, start_date, end_date, status, current_week, current_day, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.users (id, email, password_hash, full_name, phone, avatar_url, role, status, timezone, created_at, updated_at, deleted_at) FROM stdin;
f8f2faed-9a96-4fdc-8ac6-f6ae466b0a93	admin@systemic.app	$2a$10$zw.QdcCORuK8iB5mgsV5qufvpBnvySTIOm9y1TWTvLpgYJR0iJppK	FitCoach Admin	+6281234567890	\N	owner	active	Asia/Jakarta	2026-06-26 22:34:25.181655+07	2026-06-26 22:34:25.181655+07	\N
8ea4d240-6efb-41ec-8382-dcfc833dc9bf	denny@fitcoach.app	$2a$10$zw.QdcCORuK8iB5mgsV5qufvpBnvySTIOm9y1TWTvLpgYJR0iJppK	Denny Septiady	+6281234567891	\N	admin	active	Asia/Jakarta	2026-06-26 22:34:25.196644+07	2026-06-26 22:34:25.196644+07	\N
74d7caa4-6804-43f4-854a-467177aaf5dd	finance@fitcoach.app	$2a$10$zw.QdcCORuK8iB5mgsV5qufvpBnvySTIOm9y1TWTvLpgYJR0iJppK	Rina Kartika	+6281234567892	\N	finance	active	Asia/Jakarta	2026-06-26 22:34:25.198164+07	2026-06-26 22:34:25.198164+07	\N
7d74bb5f-22a9-42d7-ae79-5d5faee82fd6	coach.arif@fitcoach.app	$2a$10$zw.QdcCORuK8iB5mgsV5qufvpBnvySTIOm9y1TWTvLpgYJR0iJppK	Arif Setiawan	+6281300000001	\N	trainer	active	Asia/Jakarta	2026-06-26 22:34:25.199691+07	2026-06-26 22:34:25.199691+07	\N
00f2b827-ab58-4b2b-ba93-8db9420d2db7	coach.lisa@fitcoach.app	$2a$10$zw.QdcCORuK8iB5mgsV5qufvpBnvySTIOm9y1TWTvLpgYJR0iJppK	Lisa Andriani	+6281300000002	\N	trainer	active	Asia/Jakarta	2026-06-26 22:34:25.202262+07	2026-06-26 22:34:25.202262+07	\N
44e6c28e-be82-47c3-beac-d7dc33c712b4	coach.fajar@fitcoach.app	$2a$10$zw.QdcCORuK8iB5mgsV5qufvpBnvySTIOm9y1TWTvLpgYJR0iJppK	Fajar Nugroho	+6281300000003	\N	trainer	active	Asia/Jakarta	2026-06-26 22:34:25.203837+07	2026-06-26 22:34:25.203837+07	\N
91057f40-e579-4624-aaa7-92a538a0982f	budi@example.com	$2a$12$jst93.qFbIMAZHDmJ7Xjs.ePcaikYgkcc6sUZ8dFrFuMBnQPqR6s2	Budi Santoso	+6281200000001	\N	client	active	Asia/Jakarta	2026-06-26 22:34:25.619532+07	2026-06-26 22:34:25.619532+07	\N
f048cfed-379d-4d1f-9c6d-c70ca5678527	sari@example.com	$2a$12$jst93.qFbIMAZHDmJ7Xjs.ePcaikYgkcc6sUZ8dFrFuMBnQPqR6s2	Sari Dewi	+6281200000002	\N	client	active	Asia/Jakarta	2026-06-26 22:34:25.627241+07	2026-06-26 22:34:25.627241+07	\N
9b79840c-119e-4494-b37c-354b603cc864	andi@example.com	$2a$12$jst93.qFbIMAZHDmJ7Xjs.ePcaikYgkcc6sUZ8dFrFuMBnQPqR6s2	Andi Pratama	+6281200000003	\N	client	active	Asia/Jakarta	2026-06-26 22:34:25.62885+07	2026-06-26 22:34:25.62885+07	\N
aef34b62-410a-44c2-8b07-9542fd31a7b2	maya@example.com	$2a$12$jst93.qFbIMAZHDmJ7Xjs.ePcaikYgkcc6sUZ8dFrFuMBnQPqR6s2	Maya Putri	+6281200000004	\N	client	active	Asia/Jakarta	2026-06-26 22:34:25.630122+07	2026-06-26 22:34:25.630122+07	\N
8bb6f22a-6c4c-458b-a12d-5ba5cfa88ccd	rizki@example.com	$2a$12$jst93.qFbIMAZHDmJ7Xjs.ePcaikYgkcc6sUZ8dFrFuMBnQPqR6s2	Rizki Ramadhan	+6281200000005	\N	client	active	Asia/Jakarta	2026-06-26 22:34:25.631551+07	2026-06-26 22:34:25.631551+07	\N
9c5483d6-0e8e-49cd-bf9b-da32c9fa6d3b	diana@example.com	$2a$12$jst93.qFbIMAZHDmJ7Xjs.ePcaikYgkcc6sUZ8dFrFuMBnQPqR6s2	Diana Kusuma	+6281200000006	\N	client	active	Asia/Jakarta	2026-06-26 22:34:25.632882+07	2026-06-26 22:34:25.632882+07	\N
c9eb9182-0a47-450e-98d2-4264862529eb	hendra@example.com	$2a$12$jst93.qFbIMAZHDmJ7Xjs.ePcaikYgkcc6sUZ8dFrFuMBnQPqR6s2	Hendra Wijaya	+6281200000007	\N	client	active	Asia/Jakarta	2026-06-26 22:34:25.634347+07	2026-06-26 22:34:25.634347+07	\N
531a93f5-fa57-4e53-a020-cf31eb9d8293	wati@example.com	$2a$12$jst93.qFbIMAZHDmJ7Xjs.ePcaikYgkcc6sUZ8dFrFuMBnQPqR6s2	Wati Susilowati	+6281200000008	\N	client	inactive	Asia/Jakarta	2026-06-26 22:34:25.635559+07	2026-06-26 22:34:25.635559+07	\N
268517b9-3377-4087-a523-08c3b032bfe2	tommy@example.com	$2a$12$jst93.qFbIMAZHDmJ7Xjs.ePcaikYgkcc6sUZ8dFrFuMBnQPqR6s2	Tommy Hidayat	+6281200000009	\N	client	pending	Asia/Jakarta	2026-06-26 22:34:25.636886+07	2026-06-26 22:34:25.636886+07	\N
248a8cb1-9d52-41f8-94b2-1ff93098b3ec	fika@example.com	$2a$12$jst93.qFbIMAZHDmJ7Xjs.ePcaikYgkcc6sUZ8dFrFuMBnQPqR6s2	Fika Ramadhani	+6281200000010	\N	client	suspended	Asia/Jakarta	2026-06-26 22:34:25.638185+07	2026-06-26 22:34:25.638185+07	\N
4df24737-38d4-4e08-94de-e835be654e72	consultant.maya@fitcoach.app	$2a$12$7TEnCWoPa8eT1EfVbffEE.p5tMi0c0fUUiOpeKSA6G9nSZu/BBrie	dr. Maya Pranatasari	+6281300000004	\N	consultant	active	Asia/Jakarta	2026-06-26 23:07:13.055322+07	2026-06-26 23:07:13.055322+07	\N
40bc1a74-2fa6-4737-adad-c10d34734e79	my.mustofa1999@gmail.com	$2a$12$uQNhJUr2RgIWX.Qx2rc9leZoP0hXdLEhKX3v3Uhfox8PVKYqefiP6	yusuf	082117144462	\N	client	active	Asia/Jakarta	2026-06-29 05:19:14.941069+07	2026-06-29 05:20:01.132062+07	\N
\.


--
-- Data for Name: workout_exercises; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.workout_exercises (id, workout_id, exercise_id, order_index, sets, reps, weight_kg, rest_seconds, notes, superset_group) FROM stdin;
12ba6896-978d-43b6-883b-2f1c12b1470c	0cad9050-bac3-46f5-bba1-0afb4a724b68	beea9a1a-2c79-4aff-91d9-10d07b6d4f7f	1	3	8-10	\N	120	\N	\N
7206928e-5472-4edf-9ad2-96cc7182940f	0cad9050-bac3-46f5-bba1-0afb4a724b68	2fae72c2-ee45-4cbe-bf15-8030eba79ab3	2	3	8-10	\N	90	\N	\N
2e0f0305-ca38-4a34-bd2c-2003796aee45	0cad9050-bac3-46f5-bba1-0afb4a724b68	8f2671ea-e344-4f5a-9642-3f1f54f403a2	3	3	10-12	\N	90	\N	\N
8b47c422-6e84-4311-84cf-e34f6ca161bd	0cad9050-bac3-46f5-bba1-0afb4a724b68	47d27048-f099-4761-a398-1f13291f3b27	4	3	12	\N	60	\N	\N
58467e36-a96b-4556-a47e-8b98a7a536d9	0cad9050-bac3-46f5-bba1-0afb4a724b68	5a2bd6cd-333a-494d-916b-4c40ab3ff69a	5	3	30s	\N	60	\N	\N
ef48498d-e5ff-4e3b-bfe1-9f5e9faf7a8b	f6fe0dd9-28d2-423e-9f28-0052758fcc79	5bb98292-ce6d-4857-bc8b-94de6c673314	1	3	5	\N	180	\N	\N
44d4130d-bd2a-4543-b384-90cba592db0d	f6fe0dd9-28d2-423e-9f28-0052758fcc79	e2451023-e857-41e9-8312-5e13260575eb	2	3	8-10	\N	90	\N	\N
a5776eea-2188-4efb-a464-b5f349c37f8b	f6fe0dd9-28d2-423e-9f28-0052758fcc79	1164a8cb-7996-4f7b-bb18-5b7cdd052bee	3	3	10-12	\N	90	\N	\N
44cb41f3-e2be-4f37-bb20-8b42e48e1687	f6fe0dd9-28d2-423e-9f28-0052758fcc79	b28674fc-abcf-4f4c-90cc-8668feb2a12a	4	3	12	\N	90	\N	\N
00a086e2-2035-4cea-9d14-5fd2e4c0e4a1	f6fe0dd9-28d2-423e-9f28-0052758fcc79	887919e9-4c29-472a-b582-62393dfb5121	5	2	12	\N	60	\N	\N
f38b36f7-6353-4cbd-b46c-9bf985aa25e1	187929fa-13fe-4e9a-871f-5875e992f674	c24869f4-d364-4f23-98d2-c50720d0a4c8	1	3	AMRAP	\N	60	\N	\N
08d8af1f-9149-49be-b9d4-c186ce31d540	187929fa-13fe-4e9a-871f-5875e992f674	8ad7a994-2dc4-4b48-95cb-8928b0760286	2	3	12	\N	60	\N	\N
dd31ec0c-aaef-480c-bf8b-58b90a3999ce	187929fa-13fe-4e9a-871f-5875e992f674	9215b23e-70c3-48b5-9f5f-c83c59837e76	3	3	15	\N	60	\N	\N
c5cb893e-25db-4e6c-af5c-25f88278c771	187929fa-13fe-4e9a-871f-5875e992f674	760db084-2c7f-42d4-8a1c-e31d876fe683	4	3	20	\N	45	\N	\N
829b200a-3013-4909-af0c-c34be61a4ceb	187929fa-13fe-4e9a-871f-5875e992f674	c0f6838f-c3f0-4032-b235-c251318eea57	5	1	15min	\N	0	\N	\N
1d6882e9-eea5-4f3f-8ea3-95b97da99376	d8ab627f-8c03-42f4-aa43-3860f1d88df3	2fae72c2-ee45-4cbe-bf15-8030eba79ab3	1	4	6-8	\N	120	\N	\N
dfe72a66-a0f4-4bee-9b63-2d4b86d51c90	d8ab627f-8c03-42f4-aa43-3860f1d88df3	0e36a09b-c9b8-4cd3-b770-0d9c87692355	2	3	8-10	\N	90	\N	\N
6320c312-5bbb-431e-b7bb-515ff07c63ce	d8ab627f-8c03-42f4-aa43-3860f1d88df3	e2451023-e857-41e9-8312-5e13260575eb	3	3	8-10	\N	90	\N	\N
e0e360e3-8e02-425c-8c8a-92afe4e281cf	d8ab627f-8c03-42f4-aa43-3860f1d88df3	7ec5bcf1-53ec-4c69-9bd9-aacca49a353e	4	3	12-15	\N	60	\N	\N
60fe4ecb-2734-4275-a3ac-13deb5738bcf	d8ab627f-8c03-42f4-aa43-3860f1d88df3	2e3c72dd-56de-4f87-841e-237f7072c0c3	5	3	12	\N	60	\N	\N
920e3fc3-4d0a-4e49-bd78-ad347cf1fa91	d8ab627f-8c03-42f4-aa43-3860f1d88df3	73ef983f-de31-41e6-bfe0-82efb6d728ba	6	3	12-15	\N	60	\N	\N
b85aa3bc-d95e-440d-960e-5033c8aa667f	c73c9923-4f53-44e9-bf88-c41d52765870	5bb98292-ce6d-4857-bc8b-94de6c673314	1	3	5	\N	180	\N	\N
939b8f59-7be0-49a8-9922-65dd8b725214	c73c9923-4f53-44e9-bf88-c41d52765870	b6cbdae9-726d-4d90-ba35-f0479ad4384d	2	4	AMRAP	\N	120	\N	\N
5608a767-f8a4-4957-acf4-c8af08e41eb4	c73c9923-4f53-44e9-bf88-c41d52765870	0ed3c051-1aae-482d-86d3-4a0acdd37e9c	3	3	8-10	\N	90	\N	\N
ef62c95d-6706-4de9-acfb-073f37e7d5ee	c73c9923-4f53-44e9-bf88-c41d52765870	1164a8cb-7996-4f7b-bb18-5b7cdd052bee	4	3	10-12	\N	90	\N	\N
fe491bb1-5b0e-4c1b-b802-2bfa7fb722ba	c73c9923-4f53-44e9-bf88-c41d52765870	9215b23e-70c3-48b5-9f5f-c83c59837e76	5	3	15	\N	60	\N	\N
9e745555-3459-40c1-9b2c-3a87ff5bbb7f	c73c9923-4f53-44e9-bf88-c41d52765870	887919e9-4c29-472a-b582-62393dfb5121	6	3	10-12	\N	60	\N	\N
ed9656a5-4091-4ba5-87a8-85c23cd7ee3a	c73c9923-4f53-44e9-bf88-c41d52765870	2e1f07c0-c849-4692-add9-2243cafe6b7b	7	2	12	\N	60	\N	\N
4a69011b-f343-4873-b08e-9e830e9ab385	aa8bfa29-596f-4f9f-ba9c-629e8b681453	beea9a1a-2c79-4aff-91d9-10d07b6d4f7f	1	4	6-8	\N	180	\N	\N
bb9db7f9-c2c2-4235-a5d9-ef69bfa73b3f	aa8bfa29-596f-4f9f-ba9c-629e8b681453	dd7841b2-2d1d-438b-be84-f4b3f3d1f3fa	2	3	8-10	\N	120	\N	\N
e4103ced-9f1c-412f-b890-46f460148a34	aa8bfa29-596f-4f9f-ba9c-629e8b681453	b28674fc-abcf-4f4c-90cc-8668feb2a12a	3	3	10-12	\N	90	\N	\N
baba1bcb-016d-4799-9360-957b365e56fc	aa8bfa29-596f-4f9f-ba9c-629e8b681453	8ad7a994-2dc4-4b48-95cb-8928b0760286	4	3	12	\N	60	\N	\N
568cf940-289c-4da1-a5d0-3d2ebb816666	aa8bfa29-596f-4f9f-ba9c-629e8b681453	47d27048-f099-4761-a398-1f13291f3b27	5	3	12	\N	60	\N	\N
da76d520-1e1f-4f58-b5d1-4378efb19d71	aa8bfa29-596f-4f9f-ba9c-629e8b681453	ec386ac2-6666-434c-9cf4-07c62074f7e4	6	3	12	\N	60	\N	\N
383b7e42-34c4-4461-b34a-a2dc538f2d9f	aa8bfa29-596f-4f9f-ba9c-629e8b681453	ad178a37-adba-40c8-b2d9-2b1452b755a3	7	4	15	\N	45	\N	\N
6fbd1b8d-dc54-461e-bb67-5857c7e459c6	81ea0647-cbac-414a-9302-b70aaff304de	2fae72c2-ee45-4cbe-bf15-8030eba79ab3	1	4	6-8	\N	120	\N	\N
cf112f45-5de2-40cf-a27e-476039e2fc9f	81ea0647-cbac-414a-9302-b70aaff304de	0e36a09b-c9b8-4cd3-b770-0d9c87692355	2	4	8-10	\N	90	\N	\N
1a39c0db-aecd-4136-8f08-1bba0d0dbc8f	81ea0647-cbac-414a-9302-b70aaff304de	2e3c72dd-56de-4f87-841e-237f7072c0c3	3	3	12	\N	60	\N	\N
6fd190cc-7854-4208-9f38-39b5923f43a7	81ea0647-cbac-414a-9302-b70aaff304de	c24869f4-d364-4f23-98d2-c50720d0a4c8	4	3	AMRAP	\N	60	\N	\N
e1d69cc6-0fde-4ff9-b54c-2d3dee873e7a	81ea0647-cbac-414a-9302-b70aaff304de	ce445dff-a9ed-4438-b78f-659ff817d526	5	4	8-10	\N	90	\N	\N
4d7da94d-aa97-4675-8e4f-7d5784ee7375	81ea0647-cbac-414a-9302-b70aaff304de	73ef983f-de31-41e6-bfe0-82efb6d728ba	6	3	12-15	\N	45	\N	1
3639b4f2-444b-4852-91cf-2f7c7d961536	81ea0647-cbac-414a-9302-b70aaff304de	5a2bd6cd-333a-494d-916b-4c40ab3ff69a	7	3	45s	\N	45	\N	1
7a4a4005-d8fb-44a0-9d57-0c3c7671ce79	becbb1bb-8d84-4fb9-9d1f-125a6954b6ce	5bb98292-ce6d-4857-bc8b-94de6c673314	1	4	5	\N	180	\N	\N
688ed68a-08fd-48db-a8cf-b8945f5c9710	becbb1bb-8d84-4fb9-9d1f-125a6954b6ce	b6cbdae9-726d-4d90-ba35-f0479ad4384d	2	4	AMRAP	\N	120	\N	\N
ddfae86d-2e28-406f-9470-44a2991fa65b	becbb1bb-8d84-4fb9-9d1f-125a6954b6ce	0ed3c051-1aae-482d-86d3-4a0acdd37e9c	3	4	8-10	\N	90	\N	\N
e0e340bf-e9ed-4b0c-88be-7d0406075611	becbb1bb-8d84-4fb9-9d1f-125a6954b6ce	1164a8cb-7996-4f7b-bb18-5b7cdd052bee	4	3	10-12	\N	90	\N	\N
8b2c2aa2-e63a-430f-9440-720cbafdcd6f	becbb1bb-8d84-4fb9-9d1f-125a6954b6ce	8f2671ea-e344-4f5a-9642-3f1f54f403a2	5	3	12	\N	60	\N	\N
f2bdb54e-f8f3-4d4d-a683-f025d874c5f5	becbb1bb-8d84-4fb9-9d1f-125a6954b6ce	887919e9-4c29-472a-b582-62393dfb5121	6	4	8-10	\N	60	\N	\N
60093ecb-5783-41b7-b4fe-1a604db55fc5	becbb1bb-8d84-4fb9-9d1f-125a6954b6ce	2e1f07c0-c849-4692-add9-2243cafe6b7b	7	3	12	\N	45	\N	\N
935032b5-d239-4f3c-8ebe-310fdc89b329	28c02bef-5801-4d4d-a5f1-4eea3598fbf1	e2451023-e857-41e9-8312-5e13260575eb	1	4	6-8	\N	120	\N	\N
e4aabb51-cd1c-4de7-adfd-45d3fcc59a59	28c02bef-5801-4d4d-a5f1-4eea3598fbf1	7ec5bcf1-53ec-4c69-9bd9-aacca49a353e	2	4	12-15	\N	60	\N	\N
56752fcf-372b-4075-a28f-244b9ed4f662	28c02bef-5801-4d4d-a5f1-4eea3598fbf1	9215b23e-70c3-48b5-9f5f-c83c59837e76	3	4	15	\N	60	\N	\N
978420e9-3b6e-4198-976f-509bb23758b7	28c02bef-5801-4d4d-a5f1-4eea3598fbf1	0e36a09b-c9b8-4cd3-b770-0d9c87692355	4	3	10	\N	90	\N	\N
40838f84-c21e-432a-b55d-c018e90803fc	28c02bef-5801-4d4d-a5f1-4eea3598fbf1	760db084-2c7f-42d4-8a1c-e31d876fe683	5	3	20	\N	45	\N	\N
c5d0b558-2354-41d4-bc7f-98043d015f93	1d0720d4-a986-49a5-853a-a5550a879a43	beea9a1a-2c79-4aff-91d9-10d07b6d4f7f	1	5	5	\N	180	\N	\N
297721ad-07ef-4cbe-b238-dbf875e37068	1d0720d4-a986-49a5-853a-a5550a879a43	8c6d4533-6514-4638-bb94-fdfdff4c9a71	2	4	8-10	\N	120	\N	\N
cc6ac84d-6ed3-47f2-bc44-a587a24884b1	1d0720d4-a986-49a5-853a-a5550a879a43	9d4780d4-60e6-47eb-8aa6-f576c2977029	3	3	10	\N	90	\N	\N
21f429b4-4179-4aa9-8719-42c9679a1ad2	1d0720d4-a986-49a5-853a-a5550a879a43	dd7841b2-2d1d-438b-be84-f4b3f3d1f3fa	4	3	10	\N	90	\N	\N
a7dbf0f1-c92b-49ba-a2f1-bb13c7e2fe72	1d0720d4-a986-49a5-853a-a5550a879a43	ec386ac2-6666-434c-9cf4-07c62074f7e4	5	3	12-15	\N	60	\N	\N
2d3f0f17-aa13-40dc-ad50-21392d49c72e	1d0720d4-a986-49a5-853a-a5550a879a43	47d27048-f099-4761-a398-1f13291f3b27	6	3	12-15	\N	60	\N	\N
5f1cbfaa-e385-44f0-90c7-049ebc293be8	1d0720d4-a986-49a5-853a-a5550a879a43	ad178a37-adba-40c8-b2d9-2b1452b755a3	7	5	15	\N	45	\N	\N
9b79c8c6-bb81-4089-a305-28a403c9b0b1	c2afc8a7-44c3-48f7-977a-1d8f87f14200	887919e9-4c29-472a-b582-62393dfb5121	1	4	8-10	\N	90	\N	\N
d141e6ad-06d9-4d48-ae14-bb4d24a17d5c	c2afc8a7-44c3-48f7-977a-1d8f87f14200	ce445dff-a9ed-4438-b78f-659ff817d526	2	4	8-10	\N	90	\N	\N
a293b816-0375-478a-9af4-ca60060e9829	c2afc8a7-44c3-48f7-977a-1d8f87f14200	2e1f07c0-c849-4692-add9-2243cafe6b7b	3	3	12	\N	45	\N	1
c9ef54f3-917b-49e7-9a5b-5f30bfc94d06	c2afc8a7-44c3-48f7-977a-1d8f87f14200	73ef983f-de31-41e6-bfe0-82efb6d728ba	4	3	12-15	\N	45	\N	1
b3c6633f-dbb8-4108-a333-53f876b2475c	c2afc8a7-44c3-48f7-977a-1d8f87f14200	3ffd4fc8-121c-441f-a05c-b36f0eae0af6	5	3	15	\N	60	\N	\N
8a442d7e-083a-425c-a2fb-0b27263b09ab	a020e9d0-e44a-4866-a940-ee0eca9795d2	beea9a1a-2c79-4aff-91d9-10d07b6d4f7f	1	3	8-10	\N	120	\N	\N
3799c3fa-5af3-449c-8275-2482bfe7d44e	a020e9d0-e44a-4866-a940-ee0eca9795d2	2fae72c2-ee45-4cbe-bf15-8030eba79ab3	2	3	8-10	\N	90	\N	\N
493da13e-4549-477d-ae5f-5c75dec58554	a020e9d0-e44a-4866-a940-ee0eca9795d2	8f2671ea-e344-4f5a-9642-3f1f54f403a2	3	3	10-12	\N	90	\N	\N
b6541452-ba82-4420-b0c2-fe9b1d49a28f	a020e9d0-e44a-4866-a940-ee0eca9795d2	47d27048-f099-4761-a398-1f13291f3b27	4	3	12	\N	60	\N	\N
7cdb7082-b937-4b43-823d-79e2bac60e04	a020e9d0-e44a-4866-a940-ee0eca9795d2	5a2bd6cd-333a-494d-916b-4c40ab3ff69a	5	3	30s	\N	60	\N	\N
a5d08b8e-a14f-4808-b985-d00878432df0	3ba47441-abc2-4209-ad95-1f9cac9b09c0	5bb98292-ce6d-4857-bc8b-94de6c673314	1	3	5	\N	180	\N	\N
79d93106-5a21-4d21-9ab8-85d1e30d3a66	3ba47441-abc2-4209-ad95-1f9cac9b09c0	e2451023-e857-41e9-8312-5e13260575eb	2	3	8-10	\N	90	\N	\N
ad1851ef-8352-4bf8-85d5-c936c50a1231	3ba47441-abc2-4209-ad95-1f9cac9b09c0	1164a8cb-7996-4f7b-bb18-5b7cdd052bee	3	3	10-12	\N	90	\N	\N
c341b81c-221d-4fb7-b7de-0de708b5b186	3ba47441-abc2-4209-ad95-1f9cac9b09c0	b28674fc-abcf-4f4c-90cc-8668feb2a12a	4	3	12	\N	90	\N	\N
7f406ecc-7978-4aea-8216-3eaf4bfde414	3ba47441-abc2-4209-ad95-1f9cac9b09c0	887919e9-4c29-472a-b582-62393dfb5121	5	2	12	\N	60	\N	\N
480c525e-d6e1-47ab-8364-a5f227f48b0a	55734559-3141-4ae4-9c5d-788dbcff03c6	c24869f4-d364-4f23-98d2-c50720d0a4c8	1	3	AMRAP	\N	60	\N	\N
0d2767aa-5261-49b9-bcd0-881dda859835	55734559-3141-4ae4-9c5d-788dbcff03c6	8ad7a994-2dc4-4b48-95cb-8928b0760286	2	3	12	\N	60	\N	\N
4dc61f32-56f9-447b-9130-45b3a9c787a3	55734559-3141-4ae4-9c5d-788dbcff03c6	9215b23e-70c3-48b5-9f5f-c83c59837e76	3	3	15	\N	60	\N	\N
d8222676-47f5-4d80-92ec-2a795e141632	55734559-3141-4ae4-9c5d-788dbcff03c6	760db084-2c7f-42d4-8a1c-e31d876fe683	4	3	20	\N	45	\N	\N
e73fa046-949b-44d1-8be2-4aa7d6c4b19d	55734559-3141-4ae4-9c5d-788dbcff03c6	c0f6838f-c3f0-4032-b235-c251318eea57	5	1	15min	\N	0	\N	\N
db638170-e5a6-4090-98da-4efa33ad81a2	60499b59-4657-46ce-adbb-fc0ef606042d	2fae72c2-ee45-4cbe-bf15-8030eba79ab3	1	4	6-8	\N	120	\N	\N
d0fdd4bd-76ef-4caa-ae6e-5407b2c00178	60499b59-4657-46ce-adbb-fc0ef606042d	0e36a09b-c9b8-4cd3-b770-0d9c87692355	2	3	8-10	\N	90	\N	\N
0a47946b-5950-4bd4-b40c-7ca8f789cdc5	60499b59-4657-46ce-adbb-fc0ef606042d	e2451023-e857-41e9-8312-5e13260575eb	3	3	8-10	\N	90	\N	\N
5ac9508f-10cd-4c4b-9d63-42af40ff29c6	60499b59-4657-46ce-adbb-fc0ef606042d	7ec5bcf1-53ec-4c69-9bd9-aacca49a353e	4	3	12-15	\N	60	\N	\N
f8560dcd-3d73-4eca-bcbb-6bc65c954a5c	60499b59-4657-46ce-adbb-fc0ef606042d	2e3c72dd-56de-4f87-841e-237f7072c0c3	5	3	12	\N	60	\N	\N
34027629-3b1f-4964-9c2f-83e35be16e48	60499b59-4657-46ce-adbb-fc0ef606042d	73ef983f-de31-41e6-bfe0-82efb6d728ba	6	3	12-15	\N	60	\N	\N
2f60d6c4-ac33-41ce-b4a7-dfb69d20b433	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	5bb98292-ce6d-4857-bc8b-94de6c673314	1	3	5	\N	180	\N	\N
386ab72b-31bc-4a71-a729-58573beaa100	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	b6cbdae9-726d-4d90-ba35-f0479ad4384d	2	4	AMRAP	\N	120	\N	\N
a57bf40a-2696-4b85-801b-6a44c70bc708	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	0ed3c051-1aae-482d-86d3-4a0acdd37e9c	3	3	8-10	\N	90	\N	\N
85b9b43e-3751-4e4c-9d64-5d067d857a4b	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	1164a8cb-7996-4f7b-bb18-5b7cdd052bee	4	3	10-12	\N	90	\N	\N
fa3c2e3c-84e8-4165-8b23-fef592aa8c8d	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	9215b23e-70c3-48b5-9f5f-c83c59837e76	5	3	15	\N	60	\N	\N
48c08d04-6cff-4a59-a42b-8071bf31b856	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	887919e9-4c29-472a-b582-62393dfb5121	6	3	10-12	\N	60	\N	\N
f7dcb74d-960e-431b-a162-815d9146fab2	e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	2e1f07c0-c849-4692-add9-2243cafe6b7b	7	2	12	\N	60	\N	\N
4926cb9a-f978-4537-8a15-231fe7bfe405	27f7272a-fd92-4146-8f1a-78b266c89f2d	beea9a1a-2c79-4aff-91d9-10d07b6d4f7f	1	4	6-8	\N	180	\N	\N
36920f99-fbad-470f-ae70-c6297e2cdea3	27f7272a-fd92-4146-8f1a-78b266c89f2d	dd7841b2-2d1d-438b-be84-f4b3f3d1f3fa	2	3	8-10	\N	120	\N	\N
15aebea9-dc98-40e0-8734-5de54e90c58e	27f7272a-fd92-4146-8f1a-78b266c89f2d	b28674fc-abcf-4f4c-90cc-8668feb2a12a	3	3	10-12	\N	90	\N	\N
347a93a2-dc4d-4160-ac79-0e6fe2320776	27f7272a-fd92-4146-8f1a-78b266c89f2d	8ad7a994-2dc4-4b48-95cb-8928b0760286	4	3	12	\N	60	\N	\N
7123763b-be7c-43c7-8a63-7e744e187202	27f7272a-fd92-4146-8f1a-78b266c89f2d	47d27048-f099-4761-a398-1f13291f3b27	5	3	12	\N	60	\N	\N
0f471466-8fcc-4903-ade4-b030dddc58e9	27f7272a-fd92-4146-8f1a-78b266c89f2d	ec386ac2-6666-434c-9cf4-07c62074f7e4	6	3	12	\N	60	\N	\N
2ed4fa18-6e28-4141-9eb3-e9db8f3b4f29	27f7272a-fd92-4146-8f1a-78b266c89f2d	ad178a37-adba-40c8-b2d9-2b1452b755a3	7	4	15	\N	45	\N	\N
6aa7a6ee-5e8c-4a63-a6eb-213d84bf71dc	a2e3dcaa-967b-4897-ac2c-edcf82396156	2fae72c2-ee45-4cbe-bf15-8030eba79ab3	1	4	6-8	\N	120	\N	\N
f5e7d032-87a4-42f4-a7d5-2669e0d98e7d	a2e3dcaa-967b-4897-ac2c-edcf82396156	0e36a09b-c9b8-4cd3-b770-0d9c87692355	2	4	8-10	\N	90	\N	\N
1a9a7e56-85cf-4ac2-acf3-b31032957999	a2e3dcaa-967b-4897-ac2c-edcf82396156	2e3c72dd-56de-4f87-841e-237f7072c0c3	3	3	12	\N	60	\N	\N
8f7616b4-f5c7-4927-8ba8-471a65b6b22c	a2e3dcaa-967b-4897-ac2c-edcf82396156	c24869f4-d364-4f23-98d2-c50720d0a4c8	4	3	AMRAP	\N	60	\N	\N
3a6fee07-3f64-486f-9451-436a19c97741	a2e3dcaa-967b-4897-ac2c-edcf82396156	ce445dff-a9ed-4438-b78f-659ff817d526	5	4	8-10	\N	90	\N	\N
5cbeae45-731c-4683-a6ed-9c4efb34c73c	a2e3dcaa-967b-4897-ac2c-edcf82396156	73ef983f-de31-41e6-bfe0-82efb6d728ba	6	3	12-15	\N	45	\N	1
18537d73-18a0-4344-b0d3-26832b9391b1	a2e3dcaa-967b-4897-ac2c-edcf82396156	5a2bd6cd-333a-494d-916b-4c40ab3ff69a	7	3	45s	\N	45	\N	1
21f1ff1c-5c02-4302-9e05-7ce4aa4d714d	ba021ebe-3860-4aaf-bd5d-a330c21952a8	5bb98292-ce6d-4857-bc8b-94de6c673314	1	4	5	\N	180	\N	\N
ae2863ea-3f2b-43e6-97d3-980980a76d01	ba021ebe-3860-4aaf-bd5d-a330c21952a8	b6cbdae9-726d-4d90-ba35-f0479ad4384d	2	4	AMRAP	\N	120	\N	\N
e9b5d590-9db7-4e81-8a24-f619e2cd87ab	ba021ebe-3860-4aaf-bd5d-a330c21952a8	0ed3c051-1aae-482d-86d3-4a0acdd37e9c	3	4	8-10	\N	90	\N	\N
9384f513-a03e-433c-9915-094f44e96353	ba021ebe-3860-4aaf-bd5d-a330c21952a8	1164a8cb-7996-4f7b-bb18-5b7cdd052bee	4	3	10-12	\N	90	\N	\N
2d79aebb-6e3a-4c39-a1e7-55f03f26015a	ba021ebe-3860-4aaf-bd5d-a330c21952a8	8f2671ea-e344-4f5a-9642-3f1f54f403a2	5	3	12	\N	60	\N	\N
baffeffc-9180-4968-8848-1908b6193856	ba021ebe-3860-4aaf-bd5d-a330c21952a8	887919e9-4c29-472a-b582-62393dfb5121	6	4	8-10	\N	60	\N	\N
f372c708-c658-4e0a-93cd-1836e3c0dcf3	ba021ebe-3860-4aaf-bd5d-a330c21952a8	2e1f07c0-c849-4692-add9-2243cafe6b7b	7	3	12	\N	45	\N	\N
5735047b-26bb-4f87-89ee-ae64a5a7880b	c9785992-68ce-41a0-b857-c650c96c9287	e2451023-e857-41e9-8312-5e13260575eb	1	4	6-8	\N	120	\N	\N
e07ec46d-3ddc-4f39-be2a-4c33805089ef	c9785992-68ce-41a0-b857-c650c96c9287	7ec5bcf1-53ec-4c69-9bd9-aacca49a353e	2	4	12-15	\N	60	\N	\N
27b3f084-fe37-45a4-aa77-1309c5908f86	c9785992-68ce-41a0-b857-c650c96c9287	9215b23e-70c3-48b5-9f5f-c83c59837e76	3	4	15	\N	60	\N	\N
7597d88c-c691-4088-8441-7eeeb91adc1a	c9785992-68ce-41a0-b857-c650c96c9287	0e36a09b-c9b8-4cd3-b770-0d9c87692355	4	3	10	\N	90	\N	\N
4c14b61f-0ac1-488b-949b-ef34da5e4a21	c9785992-68ce-41a0-b857-c650c96c9287	760db084-2c7f-42d4-8a1c-e31d876fe683	5	3	20	\N	45	\N	\N
d95fa0af-67e9-4879-88ff-11b9ac9a05cf	f330d37e-4d1a-47c0-bb61-95e891a3a830	beea9a1a-2c79-4aff-91d9-10d07b6d4f7f	1	5	5	\N	180	\N	\N
af6c1c33-3849-4c72-befb-525d6f6da04e	f330d37e-4d1a-47c0-bb61-95e891a3a830	8c6d4533-6514-4638-bb94-fdfdff4c9a71	2	4	8-10	\N	120	\N	\N
6b1f3184-0066-4e16-89cb-e286d075e678	f330d37e-4d1a-47c0-bb61-95e891a3a830	9d4780d4-60e6-47eb-8aa6-f576c2977029	3	3	10	\N	90	\N	\N
0cf37d6c-d7e1-4fba-87c2-25a63255501e	f330d37e-4d1a-47c0-bb61-95e891a3a830	dd7841b2-2d1d-438b-be84-f4b3f3d1f3fa	4	3	10	\N	90	\N	\N
157f95d5-ecb2-4429-8cff-797e59229c72	f330d37e-4d1a-47c0-bb61-95e891a3a830	ec386ac2-6666-434c-9cf4-07c62074f7e4	5	3	12-15	\N	60	\N	\N
a361e7d9-0ca0-42d6-9917-14737bd35903	f330d37e-4d1a-47c0-bb61-95e891a3a830	47d27048-f099-4761-a398-1f13291f3b27	6	3	12-15	\N	60	\N	\N
dd57de19-b0fd-4c8e-9037-082809f006bf	f330d37e-4d1a-47c0-bb61-95e891a3a830	ad178a37-adba-40c8-b2d9-2b1452b755a3	7	5	15	\N	45	\N	\N
0571c5a7-8ec6-408c-a81e-250fc43e3c64	e3097813-f8fd-47f3-94bc-99a47fab3966	887919e9-4c29-472a-b582-62393dfb5121	1	4	8-10	\N	90	\N	\N
ea378152-a821-4b7a-bccd-d7d16a960197	e3097813-f8fd-47f3-94bc-99a47fab3966	ce445dff-a9ed-4438-b78f-659ff817d526	2	4	8-10	\N	90	\N	\N
44616db5-ccd5-433d-a94f-065026a2d844	e3097813-f8fd-47f3-94bc-99a47fab3966	2e1f07c0-c849-4692-add9-2243cafe6b7b	3	3	12	\N	45	\N	1
5b147fd3-0732-404f-8886-d0c509385bc4	e3097813-f8fd-47f3-94bc-99a47fab3966	73ef983f-de31-41e6-bfe0-82efb6d728ba	4	3	12-15	\N	45	\N	1
fc887736-a140-4b08-8db4-017e621791ed	e3097813-f8fd-47f3-94bc-99a47fab3966	3ffd4fc8-121c-441f-a05c-b36f0eae0af6	5	3	15	\N	60	\N	\N
\.


--
-- Data for Name: workout_reminders; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.workout_reminders (id, user_id, enabled, days_of_week, remind_at, timezone, last_sent_on, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: workout_session_logs; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.workout_session_logs (id, user_id, trainer_card_id, session_type, level, duration_seconds, completed_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: workouts; Type: TABLE DATA; Schema: public; Owner: fitcoach
--

COPY public.workouts (id, name, description, type, estimated_duration_min, created_by, is_template, created_at, updated_at) FROM stdin;
0cad9050-bac3-46f5-bba1-0afb4a724b68	Beginner Full Body A	Focus on squat + push + pull fundamentals	strength	45	\N	t	2026-06-26 22:34:25.046987+07	2026-06-26 22:34:25.046987+07
f6fe0dd9-28d2-423e-9f28-0052758fcc79	Beginner Full Body B	Focus on deadlift + press + row fundamentals	strength	45	\N	t	2026-06-26 22:34:25.046987+07	2026-06-26 22:34:25.046987+07
187929fa-13fe-4e9a-871f-5875e992f674	Beginner Full Body C	Lighter day with bodyweight and cardio	strength	40	\N	t	2026-06-26 22:34:25.046987+07	2026-06-26 22:34:25.046987+07
d8ab627f-8c03-42f4-aa43-3860f1d88df3	PPL: Push Day	Chest, shoulders, triceps	strength	60	\N	t	2026-06-26 22:34:25.046987+07	2026-06-26 22:34:25.046987+07
c73c9923-4f53-44e9-bf88-c41d52765870	PPL: Pull Day	Back, biceps, rear delts	strength	60	\N	t	2026-06-26 22:34:25.046987+07	2026-06-26 22:34:25.046987+07
aa8bfa29-596f-4f9f-ba9c-629e8b681453	PPL: Leg Day	Quads, hamstrings, glutes, calves	strength	65	\N	t	2026-06-26 22:34:25.046987+07	2026-06-26 22:34:25.046987+07
81ea0647-cbac-414a-9302-b70aaff304de	Bro Split: Chest & Triceps	High volume chest and triceps	strength	70	\N	t	2026-06-26 22:34:25.046987+07	2026-06-26 22:34:25.046987+07
becbb1bb-8d84-4fb9-9d1f-125a6954b6ce	Bro Split: Back & Biceps	High volume back and biceps	strength	70	\N	t	2026-06-26 22:34:25.046987+07	2026-06-26 22:34:25.046987+07
28c02bef-5801-4d4d-a5f1-4eea3598fbf1	Bro Split: Shoulders	All three delt heads + traps	strength	55	\N	t	2026-06-26 22:34:25.046987+07	2026-06-26 22:34:25.046987+07
1d0720d4-a986-49a5-853a-a5550a879a43	Bro Split: Legs	Heavy compound + isolation	strength	75	\N	t	2026-06-26 22:34:25.046987+07	2026-06-26 22:34:25.046987+07
c2afc8a7-44c3-48f7-977a-1d8f87f14200	Bro Split: Arms	Dedicated arm day â€” biceps, triceps, forearms	strength	50	\N	t	2026-06-26 22:34:25.046987+07	2026-06-26 22:34:25.046987+07
a020e9d0-e44a-4866-a940-ee0eca9795d2	Beginner Full Body A	Focus on squat + push + pull fundamentals	strength	45	\N	t	2026-06-26 23:07:12.594983+07	2026-06-26 23:07:12.594983+07
3ba47441-abc2-4209-ad95-1f9cac9b09c0	Beginner Full Body B	Focus on deadlift + press + row fundamentals	strength	45	\N	t	2026-06-26 23:07:12.594983+07	2026-06-26 23:07:12.594983+07
55734559-3141-4ae4-9c5d-788dbcff03c6	Beginner Full Body C	Lighter day with bodyweight and cardio	strength	40	\N	t	2026-06-26 23:07:12.594983+07	2026-06-26 23:07:12.594983+07
60499b59-4657-46ce-adbb-fc0ef606042d	PPL: Push Day	Chest, shoulders, triceps	strength	60	\N	t	2026-06-26 23:07:12.594983+07	2026-06-26 23:07:12.594983+07
e563f523-8ca7-45f7-8b3d-5fd26f16ad1a	PPL: Pull Day	Back, biceps, rear delts	strength	60	\N	t	2026-06-26 23:07:12.594983+07	2026-06-26 23:07:12.594983+07
27f7272a-fd92-4146-8f1a-78b266c89f2d	PPL: Leg Day	Quads, hamstrings, glutes, calves	strength	65	\N	t	2026-06-26 23:07:12.594983+07	2026-06-26 23:07:12.594983+07
a2e3dcaa-967b-4897-ac2c-edcf82396156	Bro Split: Chest & Triceps	High volume chest and triceps	strength	70	\N	t	2026-06-26 23:07:12.594983+07	2026-06-26 23:07:12.594983+07
ba021ebe-3860-4aaf-bd5d-a330c21952a8	Bro Split: Back & Biceps	High volume back and biceps	strength	70	\N	t	2026-06-26 23:07:12.594983+07	2026-06-26 23:07:12.594983+07
c9785992-68ce-41a0-b857-c650c96c9287	Bro Split: Shoulders	All three delt heads + traps	strength	55	\N	t	2026-06-26 23:07:12.594983+07	2026-06-26 23:07:12.594983+07
f330d37e-4d1a-47c0-bb61-95e891a3a830	Bro Split: Legs	Heavy compound + isolation	strength	75	\N	t	2026-06-26 23:07:12.594983+07	2026-06-26 23:07:12.594983+07
e3097813-f8fd-47f3-94bc-99a47fab3966	Bro Split: Arms	Dedicated arm day — biceps, triceps, forearms	strength	50	\N	t	2026-06-26 23:07:12.594983+07	2026-06-26 23:07:12.594983+07
\.


--
-- Name: announcement_reads announcement_reads_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.announcement_reads
    ADD CONSTRAINT announcement_reads_pkey PRIMARY KEY (id);


--
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: assessments assessments_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_pkey PRIMARY KEY (id);


--
-- Name: automation_logs automation_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.automation_logs
    ADD CONSTRAINT automation_logs_pkey PRIMARY KEY (id);


--
-- Name: automations automations_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.automations
    ADD CONSTRAINT automations_pkey PRIMARY KEY (id);


--
-- Name: bank_accounts bank_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.bank_accounts
    ADD CONSTRAINT bank_accounts_pkey PRIMARY KEY (id);


--
-- Name: body_metrics body_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.body_metrics
    ADD CONSTRAINT body_metrics_pkey PRIMARY KEY (id);


--
-- Name: broadcast_notifications broadcast_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.broadcast_notifications
    ADD CONSTRAINT broadcast_notifications_pkey PRIMARY KEY (id);


--
-- Name: calendar_events calendar_events_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.calendar_events
    ADD CONSTRAINT calendar_events_pkey PRIMARY KEY (id);


--
-- Name: challenge_participants challenge_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.challenge_participants
    ADD CONSTRAINT challenge_participants_pkey PRIMARY KEY (id);


--
-- Name: challenges challenges_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.challenges
    ADD CONSTRAINT challenges_pkey PRIMARY KEY (id);


--
-- Name: clinical_notes clinical_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.clinical_notes
    ADD CONSTRAINT clinical_notes_pkey PRIMARY KEY (id);


--
-- Name: cms_content cms_content_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.cms_content
    ADD CONSTRAINT cms_content_pkey PRIMARY KEY (section_key, locale);


--
-- Name: cms_media cms_media_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.cms_media
    ADD CONSTRAINT cms_media_pkey PRIMARY KEY (id);


--
-- Name: cms_pricing_tiers cms_pricing_tiers_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.cms_pricing_tiers
    ADD CONSTRAINT cms_pricing_tiers_pkey PRIMARY KEY (id);


--
-- Name: cms_programs cms_programs_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.cms_programs
    ADD CONSTRAINT cms_programs_pkey PRIMARY KEY (id);


--
-- Name: cms_settings cms_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.cms_settings
    ADD CONSTRAINT cms_settings_pkey PRIMARY KEY (key);


--
-- Name: cms_testimonials cms_testimonials_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.cms_testimonials
    ADD CONSTRAINT cms_testimonials_pkey PRIMARY KEY (id);


--
-- Name: condition_classifications condition_classifications_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.condition_classifications
    ADD CONSTRAINT condition_classifications_pkey PRIMARY KEY (id);


--
-- Name: condition_classifications condition_classifications_slug_key; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.condition_classifications
    ADD CONSTRAINT condition_classifications_slug_key UNIQUE (slug);


--
-- Name: conversation_members conversation_members_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.conversation_members
    ADD CONSTRAINT conversation_members_pkey PRIMARY KEY (conversation_id, user_id);


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);


--
-- Name: customer_hr_zones customer_hr_zones_customer_id_key; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.customer_hr_zones
    ADD CONSTRAINT customer_hr_zones_customer_id_key UNIQUE (customer_id);


--
-- Name: customer_hr_zones customer_hr_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.customer_hr_zones
    ADD CONSTRAINT customer_hr_zones_pkey PRIMARY KEY (id);


--
-- Name: customer_medicines customer_medicines_customer_id_medicine_id_key; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.customer_medicines
    ADD CONSTRAINT customer_medicines_customer_id_medicine_id_key UNIQUE (customer_id, medicine_id);


--
-- Name: customer_medicines customer_medicines_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.customer_medicines
    ADD CONSTRAINT customer_medicines_pkey PRIMARY KEY (id);


--
-- Name: customer_program_assignments customer_program_assignments_customer_id_program_category_i_key; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.customer_program_assignments
    ADD CONSTRAINT customer_program_assignments_customer_id_program_category_i_key UNIQUE (customer_id, program_category_id);


--
-- Name: customer_program_assignments customer_program_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.customer_program_assignments
    ADD CONSTRAINT customer_program_assignments_pkey PRIMARY KEY (id);


--
-- Name: daily_journal_sessions daily_journal_sessions_customer_id_session_date_key; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.daily_journal_sessions
    ADD CONSTRAINT daily_journal_sessions_customer_id_session_date_key UNIQUE (customer_id, session_date);


--
-- Name: daily_journal_sessions daily_journal_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.daily_journal_sessions
    ADD CONSTRAINT daily_journal_sessions_pkey PRIMARY KEY (id);


--
-- Name: device_tokens device_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_pkey PRIMARY KEY (id);


--
-- Name: dl_categories dl_categories_code_key; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.dl_categories
    ADD CONSTRAINT dl_categories_code_key UNIQUE (code);


--
-- Name: dl_categories dl_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.dl_categories
    ADD CONSTRAINT dl_categories_pkey PRIMARY KEY (id);


--
-- Name: dl_dynamic_items dl_dynamic_items_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.dl_dynamic_items
    ADD CONSTRAINT dl_dynamic_items_pkey PRIMARY KEY (id);


--
-- Name: dl_isolate_items dl_isolate_items_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.dl_isolate_items
    ADD CONSTRAINT dl_isolate_items_pkey PRIMARY KEY (id);


--
-- Name: dl_levels dl_levels_level_number_key; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.dl_levels
    ADD CONSTRAINT dl_levels_level_number_key UNIQUE (level_number);


--
-- Name: dl_levels dl_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.dl_levels
    ADD CONSTRAINT dl_levels_pkey PRIMARY KEY (id);


--
-- Name: dl_menu_items dl_menu_items_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.dl_menu_items
    ADD CONSTRAINT dl_menu_items_pkey PRIMARY KEY (id);


--
-- Name: dl_movements dl_movements_name_key; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.dl_movements
    ADD CONSTRAINT dl_movements_name_key UNIQUE (name);


--
-- Name: dl_movements dl_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.dl_movements
    ADD CONSTRAINT dl_movements_pkey PRIMARY KEY (id);


--
-- Name: doctor_videos doctor_videos_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.doctor_videos
    ADD CONSTRAINT doctor_videos_pkey PRIMARY KEY (id);


--
-- Name: equipments equipments_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.equipments
    ADD CONSTRAINT equipments_pkey PRIMARY KEY (id);


--
-- Name: event_participants event_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.event_participants
    ADD CONSTRAINT event_participants_pkey PRIMARY KEY (id);


--
-- Name: event_types event_types_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.event_types
    ADD CONSTRAINT event_types_pkey PRIMARY KEY (id);


--
-- Name: exercises exercises_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.exercises
    ADD CONSTRAINT exercises_pkey PRIMARY KEY (id);


--
-- Name: foods foods_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.foods
    ADD CONSTRAINT foods_pkey PRIMARY KEY (id);


--
-- Name: form_fields form_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.form_fields
    ADD CONSTRAINT form_fields_pkey PRIMARY KEY (id);


--
-- Name: form_responses form_responses_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.form_responses
    ADD CONSTRAINT form_responses_pkey PRIMARY KEY (id);


--
-- Name: forms forms_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.forms
    ADD CONSTRAINT forms_pkey PRIMARY KEY (id);


--
-- Name: group_members group_members_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: habit_folders habit_folders_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.habit_folders
    ADD CONSTRAINT habit_folders_pkey PRIMARY KEY (id);


--
-- Name: habit_logs habit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.habit_logs
    ADD CONSTRAINT habit_logs_pkey PRIMARY KEY (id);


--
-- Name: habits habits_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.habits
    ADD CONSTRAINT habits_pkey PRIMARY KEY (id);


--
-- Name: health_articles health_articles_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.health_articles
    ADD CONSTRAINT health_articles_pkey PRIMARY KEY (id);


--
-- Name: lab_consultations lab_consultations_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.lab_consultations
    ADD CONSTRAINT lab_consultations_pkey PRIMARY KEY (id);


--
-- Name: meal_plan_items meal_plan_items_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.meal_plan_items
    ADD CONSTRAINT meal_plan_items_pkey PRIMARY KEY (id);


--
-- Name: meal_plans meal_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.meal_plans
    ADD CONSTRAINT meal_plans_pkey PRIMARY KEY (id);


--
-- Name: medicines medicines_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.medicines
    ADD CONSTRAINT medicines_pkey PRIMARY KEY (id);


--
-- Name: menu_role_privileges menu_role_privileges_menu_id_role_key; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.menu_role_privileges
    ADD CONSTRAINT menu_role_privileges_menu_id_role_key UNIQUE (menu_id, role);


--
-- Name: menu_role_privileges menu_role_privileges_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.menu_role_privileges
    ADD CONSTRAINT menu_role_privileges_pkey PRIMARY KEY (id);


--
-- Name: menus menus_code_key; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_code_key UNIQUE (code);


--
-- Name: menus menus_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: nutrition_daily_logs nutrition_daily_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.nutrition_daily_logs
    ADD CONSTRAINT nutrition_daily_logs_pkey PRIMARY KEY (id);


--
-- Name: nutrition_daily_logs nutrition_daily_logs_user_id_log_date_key; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.nutrition_daily_logs
    ADD CONSTRAINT nutrition_daily_logs_user_id_log_date_key UNIQUE (user_id, log_date);


--
-- Name: nutrition_health_profiles nutrition_health_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.nutrition_health_profiles
    ADD CONSTRAINT nutrition_health_profiles_pkey PRIMARY KEY (user_id);


--
-- Name: nutrition_logs nutrition_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.nutrition_logs
    ADD CONSTRAINT nutrition_logs_pkey PRIMARY KEY (id);


--
-- Name: payment_plans payment_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.payment_plans
    ADD CONSTRAINT payment_plans_pkey PRIMARY KEY (id);


--
-- Name: payment_records payment_records_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.payment_records
    ADD CONSTRAINT payment_records_pkey PRIMARY KEY (id);


--
-- Name: payment_status_logs payment_status_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.payment_status_logs
    ADD CONSTRAINT payment_status_logs_pkey PRIMARY KEY (id);


--
-- Name: physical_status_levels physical_status_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.physical_status_levels
    ADD CONSTRAINT physical_status_levels_pkey PRIMARY KEY (id);


--
-- Name: physical_status_levels physical_status_levels_slug_key; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.physical_status_levels
    ADD CONSTRAINT physical_status_levels_slug_key UNIQUE (slug);


--
-- Name: program_categories program_categories_code_key; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.program_categories
    ADD CONSTRAINT program_categories_code_key UNIQUE (code);


--
-- Name: program_categories program_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.program_categories
    ADD CONSTRAINT program_categories_pkey PRIMARY KEY (id);


--
-- Name: program_days program_days_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.program_days
    ADD CONSTRAINT program_days_pkey PRIMARY KEY (id);


--
-- Name: programs programs_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.programs
    ADD CONSTRAINT programs_pkey PRIMARY KEY (id);


--
-- Name: progress_logs progress_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.progress_logs
    ADD CONSTRAINT progress_logs_pkey PRIMARY KEY (id);


--
-- Name: promotions promotions_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.promotions
    ADD CONSTRAINT promotions_pkey PRIMARY KEY (id);


--
-- Name: session_meals session_meals_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.session_meals
    ADD CONSTRAINT session_meals_pkey PRIMARY KEY (id);


--
-- Name: session_medicines session_medicines_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.session_medicines
    ADD CONSTRAINT session_medicines_pkey PRIMARY KEY (id);


--
-- Name: session_medicines session_medicines_session_id_medicine_id_key; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.session_medicines
    ADD CONSTRAINT session_medicines_session_id_medicine_id_key UNIQUE (session_id, medicine_id);


--
-- Name: session_vitals session_vitals_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.session_vitals
    ADD CONSTRAINT session_vitals_pkey PRIMARY KEY (id);


--
-- Name: session_vitals session_vitals_session_id_measurement_type_key; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.session_vitals
    ADD CONSTRAINT session_vitals_session_id_measurement_type_key UNIQUE (session_id, measurement_type);


--
-- Name: specific_conditions specific_conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.specific_conditions
    ADD CONSTRAINT specific_conditions_pkey PRIMARY KEY (id);


--
-- Name: specific_conditions specific_conditions_slug_key; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.specific_conditions
    ADD CONSTRAINT specific_conditions_slug_key UNIQUE (slug);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: system_score_weights system_score_weights_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.system_score_weights
    ADD CONSTRAINT system_score_weights_pkey PRIMARY KEY (id);


--
-- Name: tier4_waitlist_entries tier4_waitlist_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.tier4_waitlist_entries
    ADD CONSTRAINT tier4_waitlist_entries_pkey PRIMARY KEY (id);


--
-- Name: trainer_availability trainer_availability_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_availability
    ADD CONSTRAINT trainer_availability_pkey PRIMARY KEY (id);


--
-- Name: trainer_card_sequences trainer_card_sequences_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_sequences
    ADD CONSTRAINT trainer_card_sequences_pkey PRIMARY KEY (id);


--
-- Name: trainer_card_set_items trainer_card_set_items_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_set_items
    ADD CONSTRAINT trainer_card_set_items_pkey PRIMARY KEY (id);


--
-- Name: trainer_card_sets trainer_card_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_sets
    ADD CONSTRAINT trainer_card_sets_pkey PRIMARY KEY (id);


--
-- Name: trainer_card_template_sequences trainer_card_template_sequences_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_template_sequences
    ADD CONSTRAINT trainer_card_template_sequences_pkey PRIMARY KEY (id);


--
-- Name: trainer_card_template_set_items trainer_card_template_set_items_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_template_set_items
    ADD CONSTRAINT trainer_card_template_set_items_pkey PRIMARY KEY (id);


--
-- Name: trainer_card_template_sets trainer_card_template_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_template_sets
    ADD CONSTRAINT trainer_card_template_sets_pkey PRIMARY KEY (id);


--
-- Name: trainer_card_templates trainer_card_templates_level_key; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_templates
    ADD CONSTRAINT trainer_card_templates_level_key UNIQUE (level);


--
-- Name: trainer_card_templates trainer_card_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_templates
    ADD CONSTRAINT trainer_card_templates_pkey PRIMARY KEY (id);


--
-- Name: trainer_card_types trainer_card_types_name_key; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_types
    ADD CONSTRAINT trainer_card_types_name_key UNIQUE (name);


--
-- Name: trainer_card_types trainer_card_types_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_types
    ADD CONSTRAINT trainer_card_types_pkey PRIMARY KEY (id);


--
-- Name: trainer_cards trainer_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_cards
    ADD CONSTRAINT trainer_cards_pkey PRIMARY KEY (id);


--
-- Name: trainer_clients trainer_clients_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_clients
    ADD CONSTRAINT trainer_clients_pkey PRIMARY KEY (trainer_id, client_id);


--
-- Name: training_schedules training_schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.training_schedules
    ADD CONSTRAINT training_schedules_pkey PRIMARY KEY (id);


--
-- Name: training_sessions training_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.training_sessions
    ADD CONSTRAINT training_sessions_pkey PRIMARY KEY (id);


--
-- Name: uploads uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: announcement_reads uq_announcement_reads; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.announcement_reads
    ADD CONSTRAINT uq_announcement_reads UNIQUE (announcement_id, user_id);


--
-- Name: challenge_participants uq_challenge_participants; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.challenge_participants
    ADD CONSTRAINT uq_challenge_participants UNIQUE (challenge_id, user_id);


--
-- Name: event_participants uq_event_participants; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.event_participants
    ADD CONSTRAINT uq_event_participants UNIQUE (event_id, user_id);


--
-- Name: group_members uq_group_members; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT uq_group_members UNIQUE (group_id, user_id);


--
-- Name: habit_logs uq_habit_logs_user_habit_date; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.habit_logs
    ADD CONSTRAINT uq_habit_logs_user_habit_date UNIQUE (user_id, habit_id, logged_at);


--
-- Name: program_days uq_program_day; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.program_days
    ADD CONSTRAINT uq_program_day UNIQUE (program_id, week_number, day_of_week);


--
-- Name: trainer_card_sequences uq_trainer_card_sequence; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_sequences
    ADD CONSTRAINT uq_trainer_card_sequence UNIQUE (trainer_card_id, program_category_id);


--
-- Name: trainer_card_template_sequences uq_trainer_card_template_sequence; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_template_sequences
    ADD CONSTRAINT uq_trainer_card_template_sequence UNIQUE (template_id, program_category_id);


--
-- Name: trainer_cards uq_trainer_cards_customer; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_cards
    ADD CONSTRAINT uq_trainer_cards_customer UNIQUE (customer_id);


--
-- Name: users uq_users_email; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uq_users_email UNIQUE (email);


--
-- Name: workout_exercises uq_workout_exercise_order; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.workout_exercises
    ADD CONSTRAINT uq_workout_exercise_order UNIQUE (workout_id, order_index);


--
-- Name: user_profiles user_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_pkey PRIMARY KEY (user_id);


--
-- Name: user_programs user_programs_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.user_programs
    ADD CONSTRAINT user_programs_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: workout_exercises workout_exercises_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.workout_exercises
    ADD CONSTRAINT workout_exercises_pkey PRIMARY KEY (id);


--
-- Name: workout_reminders workout_reminders_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.workout_reminders
    ADD CONSTRAINT workout_reminders_pkey PRIMARY KEY (id);


--
-- Name: workout_reminders workout_reminders_user_id_key; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.workout_reminders
    ADD CONSTRAINT workout_reminders_user_id_key UNIQUE (user_id);


--
-- Name: workout_session_logs workout_session_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.workout_session_logs
    ADD CONSTRAINT workout_session_logs_pkey PRIMARY KEY (id);


--
-- Name: workouts workouts_pkey; Type: CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.workouts
    ADD CONSTRAINT workouts_pkey PRIMARY KEY (id);


--
-- Name: idx_announcement_reads_announcement; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_announcement_reads_announcement ON public.announcement_reads USING btree (announcement_id);


--
-- Name: idx_announcement_reads_user; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_announcement_reads_user ON public.announcement_reads USING btree (user_id);


--
-- Name: idx_announcements_creator; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_announcements_creator ON public.announcements USING btree (created_by);


--
-- Name: idx_announcements_published; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_announcements_published ON public.announcements USING btree (published_at DESC) WHERE (status = 'published'::public.announcement_status);


--
-- Name: idx_announcements_status; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_announcements_status ON public.announcements USING btree (status);


--
-- Name: idx_assessments_classification; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_assessments_classification ON public.assessments USING btree (classification_id) WHERE (classification_id IS NOT NULL);


--
-- Name: idx_assessments_pending_review; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_assessments_pending_review ON public.assessments USING btree (created_at DESC) WHERE ((tier = 'paid'::public.assessment_tier) AND (status = 'submitted'::public.assessment_status));


--
-- Name: idx_assessments_status; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_assessments_status ON public.assessments USING btree (status);


--
-- Name: idx_assessments_tier; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_assessments_tier ON public.assessments USING btree (tier);


--
-- Name: idx_assessments_user_created; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_assessments_user_created ON public.assessments USING btree (user_id, created_at DESC) WHERE (user_id IS NOT NULL);


--
-- Name: idx_assessments_version_v2; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_assessments_version_v2 ON public.assessments USING btree (version, created_at DESC) WHERE ((version)::text = 'v2'::text);


--
-- Name: idx_automation_logs_automation; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_automation_logs_automation ON public.automation_logs USING btree (automation_id, triggered_at DESC);


--
-- Name: idx_automation_logs_status; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_automation_logs_status ON public.automation_logs USING btree (status);


--
-- Name: idx_automation_logs_triggered; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_automation_logs_triggered ON public.automation_logs USING btree (triggered_at DESC);


--
-- Name: idx_automation_logs_user; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_automation_logs_user ON public.automation_logs USING btree (user_id);


--
-- Name: idx_automations_created_by; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_automations_created_by ON public.automations USING btree (created_by);


--
-- Name: idx_automations_is_active; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_automations_is_active ON public.automations USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_automations_trigger_type; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_automations_trigger_type ON public.automations USING btree (trigger_type);


--
-- Name: idx_bank_accounts_active; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_bank_accounts_active ON public.bank_accounts USING btree (is_active, sort_order) WHERE (is_active = true);


--
-- Name: idx_body_metrics_user_logged; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_body_metrics_user_logged ON public.body_metrics USING btree (user_id, logged_at DESC);


--
-- Name: idx_calendar_events_creator; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_calendar_events_creator ON public.calendar_events USING btree (created_by);


--
-- Name: idx_calendar_events_range; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_calendar_events_range ON public.calendar_events USING btree (start_at, end_at);


--
-- Name: idx_calendar_events_start; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_calendar_events_start ON public.calendar_events USING btree (start_at);


--
-- Name: idx_calendar_events_status; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_calendar_events_status ON public.calendar_events USING btree (status) WHERE (status = 'scheduled'::public.event_status);


--
-- Name: idx_challenge_participants_challenge; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_challenge_participants_challenge ON public.challenge_participants USING btree (challenge_id);


--
-- Name: idx_challenge_participants_user; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_challenge_participants_user ON public.challenge_participants USING btree (user_id);


--
-- Name: idx_challenges_creator; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_challenges_creator ON public.challenges USING btree (created_by);


--
-- Name: idx_challenges_dates; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_challenges_dates ON public.challenges USING btree (start_date, end_date);


--
-- Name: idx_challenges_status; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_challenges_status ON public.challenges USING btree (status);


--
-- Name: idx_clinical_notes_assessment; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_clinical_notes_assessment ON public.clinical_notes USING btree (assessment_id) WHERE ((assessment_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: idx_clinical_notes_client_created; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_clinical_notes_client_created ON public.clinical_notes USING btree (client_id, created_at DESC) WHERE (deleted_at IS NULL);


--
-- Name: idx_clinical_notes_consultant_created; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_clinical_notes_consultant_created ON public.clinical_notes USING btree (consultant_id, created_at DESC) WHERE (deleted_at IS NULL);


--
-- Name: idx_cms_media_tag_created; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_cms_media_tag_created ON public.cms_media USING btree (tag, created_at DESC);


--
-- Name: idx_cms_pricing_tiers_locale_active_order; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_cms_pricing_tiers_locale_active_order ON public.cms_pricing_tiers USING btree (locale, is_active, order_index);


--
-- Name: idx_cms_programs_locale_active_order; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_cms_programs_locale_active_order ON public.cms_programs USING btree (locale, is_active, order_index);


--
-- Name: idx_cms_testimonials_locale_active_order; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_cms_testimonials_locale_active_order ON public.cms_testimonials USING btree (locale, is_active, order_index);


--
-- Name: idx_condition_classifications_active_sort; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_condition_classifications_active_sort ON public.condition_classifications USING btree (is_active, sort_order);


--
-- Name: idx_conversation_members_user; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_conversation_members_user ON public.conversation_members USING btree (user_id);


--
-- Name: idx_customer_medicines_customer; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_customer_medicines_customer ON public.customer_medicines USING btree (customer_id);


--
-- Name: idx_customer_program_assignments_customer; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_customer_program_assignments_customer ON public.customer_program_assignments USING btree (customer_id);


--
-- Name: idx_daily_journal_sessions_customer; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_daily_journal_sessions_customer ON public.daily_journal_sessions USING btree (customer_id);


--
-- Name: idx_daily_journal_sessions_month; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_daily_journal_sessions_month ON public.daily_journal_sessions USING btree (month_year);


--
-- Name: idx_device_tokens_token; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE UNIQUE INDEX idx_device_tokens_token ON public.device_tokens USING btree (token);


--
-- Name: idx_device_tokens_user; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_device_tokens_user ON public.device_tokens USING btree (user_id) WHERE (is_active = true);


--
-- Name: idx_dl_dynamic_category; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_dl_dynamic_category ON public.dl_dynamic_items USING btree (category_id);


--
-- Name: idx_dl_isolate_cat_pos; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_dl_isolate_cat_pos ON public.dl_isolate_items USING btree (category_id, "position");


--
-- Name: idx_dl_menu_cat_level; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_dl_menu_cat_level ON public.dl_menu_items USING btree (category_id, level_id);


--
-- Name: idx_dl_menu_movement; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_dl_menu_movement ON public.dl_menu_items USING btree (movement_id);


--
-- Name: idx_dl_movements_body_part; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_dl_movements_body_part ON public.dl_movements USING btree (body_part);


--
-- Name: idx_dl_movements_categories; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_dl_movements_categories ON public.dl_movements USING gin (categories);


--
-- Name: idx_dl_movements_name_trgm; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_dl_movements_name_trgm ON public.dl_movements USING gin (name public.gin_trgm_ops);


--
-- Name: idx_doctor_videos_published_created; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_doctor_videos_published_created ON public.doctor_videos USING btree (is_published, created_at DESC);


--
-- Name: idx_equipments_category; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_equipments_category ON public.equipments USING btree (category);


--
-- Name: idx_equipments_is_active; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_equipments_is_active ON public.equipments USING btree (is_active);


--
-- Name: idx_event_participants_event; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_event_participants_event ON public.event_participants USING btree (event_id);


--
-- Name: idx_event_participants_user; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_event_participants_user ON public.event_participants USING btree (user_id);


--
-- Name: idx_event_types_category; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_event_types_category ON public.event_types USING btree (category);


--
-- Name: idx_exercises_created_by; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_exercises_created_by ON public.exercises USING btree (created_by);


--
-- Name: idx_exercises_difficulty; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_exercises_difficulty ON public.exercises USING btree (difficulty);


--
-- Name: idx_exercises_is_system; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_exercises_is_system ON public.exercises USING btree (is_system) WHERE (is_system = true);


--
-- Name: idx_exercises_muscle_group; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_exercises_muscle_group ON public.exercises USING gin (muscle_group);


--
-- Name: idx_exercises_name_trgm; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_exercises_name_trgm ON public.exercises USING gin (name public.gin_trgm_ops);


--
-- Name: idx_foods_created_by; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_foods_created_by ON public.foods USING btree (created_by);


--
-- Name: idx_foods_is_system; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_foods_is_system ON public.foods USING btree (is_system) WHERE (is_system = true);


--
-- Name: idx_foods_meal_types; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_foods_meal_types ON public.foods USING gin (meal_types);


--
-- Name: idx_foods_name; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_foods_name ON public.foods USING btree (name);


--
-- Name: idx_form_fields_form; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_form_fields_form ON public.form_fields USING btree (form_id, sort_order);


--
-- Name: idx_form_responses_form; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_form_responses_form ON public.form_responses USING btree (form_id);


--
-- Name: idx_form_responses_user; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_form_responses_user ON public.form_responses USING btree (user_id);


--
-- Name: idx_forms_created_by; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_forms_created_by ON public.forms USING btree (created_by);


--
-- Name: idx_forms_status; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_forms_status ON public.forms USING btree (status);


--
-- Name: idx_group_members_group; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_group_members_group ON public.group_members USING btree (group_id);


--
-- Name: idx_group_members_user; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_group_members_user ON public.group_members USING btree (user_id);


--
-- Name: idx_groups_created_by; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_groups_created_by ON public.groups USING btree (created_by);


--
-- Name: idx_habit_folders_sort; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_habit_folders_sort ON public.habit_folders USING btree (sort_order);


--
-- Name: idx_habit_logs_habit; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_habit_logs_habit ON public.habit_logs USING btree (habit_id);


--
-- Name: idx_habit_logs_user; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_habit_logs_user ON public.habit_logs USING btree (user_id, logged_at DESC);


--
-- Name: idx_habits_folder; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_habits_folder ON public.habits USING btree (folder_id);


--
-- Name: idx_habits_is_system; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_habits_is_system ON public.habits USING btree (is_system) WHERE (is_system = true);


--
-- Name: idx_habits_name; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_habits_name ON public.habits USING btree (name);


--
-- Name: idx_health_articles_published_created; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_health_articles_published_created ON public.health_articles USING btree (is_published, created_at DESC);


--
-- Name: idx_lab_consultations_consultant; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_lab_consultations_consultant ON public.lab_consultations USING btree (consultant_id, status) WHERE (consultant_id IS NOT NULL);


--
-- Name: idx_lab_consultations_status; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_lab_consultations_status ON public.lab_consultations USING btree (status, created_at DESC) WHERE ((status)::text = ANY ((ARRAY['pending'::character varying, 'scheduled'::character varying])::text[]));


--
-- Name: idx_lab_consultations_user; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_lab_consultations_user ON public.lab_consultations USING btree (user_id, created_at DESC);


--
-- Name: idx_meal_plan_items_day_meal; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_meal_plan_items_day_meal ON public.meal_plan_items USING btree (meal_plan_id, day_of_week, meal_type);


--
-- Name: idx_meal_plan_items_plan; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_meal_plan_items_plan ON public.meal_plan_items USING btree (meal_plan_id);


--
-- Name: idx_meal_plans_created_by; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_meal_plans_created_by ON public.meal_plans USING btree (created_by);


--
-- Name: idx_medicines_category; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_medicines_category ON public.medicines USING btree (category);


--
-- Name: idx_medicines_name_trgm; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_medicines_name_trgm ON public.medicines USING gin (name public.gin_trgm_ops);


--
-- Name: idx_menu_role_priv_menu_id; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_menu_role_priv_menu_id ON public.menu_role_privileges USING btree (menu_id);


--
-- Name: idx_menu_role_priv_role; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_menu_role_priv_role ON public.menu_role_privileges USING btree (role);


--
-- Name: idx_menus_is_active; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_menus_is_active ON public.menus USING btree (is_active);


--
-- Name: idx_menus_parent_id; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_menus_parent_id ON public.menus USING btree (parent_id);


--
-- Name: idx_menus_sort_order; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_menus_sort_order ON public.menus USING btree (sort_order);


--
-- Name: idx_messages_conversation_created; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_messages_conversation_created ON public.messages USING btree (conversation_id, created_at DESC);


--
-- Name: idx_messages_sender; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_messages_sender ON public.messages USING btree (sender_id);


--
-- Name: idx_messages_unread; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_messages_unread ON public.messages USING btree (conversation_id, is_read) WHERE (is_read = false);


--
-- Name: idx_notifications_user_created; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_notifications_user_created ON public.notifications USING btree (user_id, created_at DESC);


--
-- Name: idx_notifications_user_status; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_notifications_user_status ON public.notifications USING btree (user_id, status) WHERE (status = 'unread'::public.notification_status);


--
-- Name: idx_nutrition_daily_logs_user_date; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_nutrition_daily_logs_user_date ON public.nutrition_daily_logs USING btree (user_id, log_date DESC);


--
-- Name: idx_nutrition_logs_user_logged; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_nutrition_logs_user_logged ON public.nutrition_logs USING btree (user_id, logged_at DESC);


--
-- Name: idx_payment_plans_active; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_payment_plans_active ON public.payment_plans USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_payment_plans_sort; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_payment_plans_sort ON public.payment_plans USING btree (sort_order, price);


--
-- Name: idx_payment_plans_tier; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_payment_plans_tier ON public.payment_plans USING btree (tier) WHERE (tier IS NOT NULL);


--
-- Name: idx_payment_records_external; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_payment_records_external ON public.payment_records USING btree (external_id) WHERE (external_id IS NOT NULL);


--
-- Name: idx_payment_records_gateway_status; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_payment_records_gateway_status ON public.payment_records USING btree (gateway_status) WHERE (gateway_status IS NOT NULL);


--
-- Name: idx_payment_records_paid_at; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_payment_records_paid_at ON public.payment_records USING btree (paid_at DESC) WHERE (paid_at IS NOT NULL);


--
-- Name: idx_payment_records_proof; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_payment_records_proof ON public.payment_records USING btree (proof_uploaded_at DESC) WHERE (proof_image_url IS NOT NULL);


--
-- Name: idx_payment_records_status; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_payment_records_status ON public.payment_records USING btree (status);


--
-- Name: idx_payment_records_subscription; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_payment_records_subscription ON public.payment_records USING btree (subscription_id);


--
-- Name: idx_payment_records_user; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_payment_records_user ON public.payment_records USING btree (user_id);


--
-- Name: idx_payment_status_logs_changed_by; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_payment_status_logs_changed_by ON public.payment_status_logs USING btree (changed_by);


--
-- Name: idx_payment_status_logs_created; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_payment_status_logs_created ON public.payment_status_logs USING btree (created_at DESC);


--
-- Name: idx_payment_status_logs_payment; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_payment_status_logs_payment ON public.payment_status_logs USING btree (payment_id);


--
-- Name: idx_payment_status_logs_user; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_payment_status_logs_user ON public.payment_status_logs USING btree (user_id);


--
-- Name: idx_physical_status_levels_active_sort; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_physical_status_levels_active_sort ON public.physical_status_levels USING btree (is_active, sort_order);


--
-- Name: idx_program_categories_code; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_program_categories_code ON public.program_categories USING btree (code);


--
-- Name: idx_program_categories_name_trgm; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_program_categories_name_trgm ON public.program_categories USING gin (name public.gin_trgm_ops);


--
-- Name: idx_program_days_program; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_program_days_program ON public.program_days USING btree (program_id);


--
-- Name: idx_program_days_workout; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_program_days_workout ON public.program_days USING btree (workout_id);


--
-- Name: idx_programs_created_by; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_programs_created_by ON public.programs USING btree (created_by);


--
-- Name: idx_programs_difficulty; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_programs_difficulty ON public.programs USING btree (difficulty);


--
-- Name: idx_programs_is_template; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_programs_is_template ON public.programs USING btree (is_template) WHERE (is_template = true);


--
-- Name: idx_progress_logs_exercise; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_progress_logs_exercise ON public.progress_logs USING btree (exercise_id);


--
-- Name: idx_progress_logs_logged_at; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_progress_logs_logged_at ON public.progress_logs USING btree (logged_at DESC);


--
-- Name: idx_progress_logs_user_exercise; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_progress_logs_user_exercise ON public.progress_logs USING btree (user_id, exercise_id, logged_at DESC);


--
-- Name: idx_progress_logs_user_logged; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_progress_logs_user_logged ON public.progress_logs USING btree (user_id, logged_at DESC);


--
-- Name: idx_progress_logs_workout; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_progress_logs_workout ON public.progress_logs USING btree (workout_id);


--
-- Name: idx_promotions_active; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_promotions_active ON public.promotions USING btree (status, start_date, end_date) WHERE ((status)::text = 'active'::text);


--
-- Name: idx_promotions_status; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_promotions_status ON public.promotions USING btree (status);


--
-- Name: idx_session_meals_session; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_session_meals_session ON public.session_meals USING btree (session_id);


--
-- Name: idx_session_medicines_session; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_session_medicines_session ON public.session_medicines USING btree (session_id);


--
-- Name: idx_session_vitals_session; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_session_vitals_session ON public.session_vitals USING btree (session_id);


--
-- Name: idx_specific_conditions_classification; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_specific_conditions_classification ON public.specific_conditions USING btree (classification_id, is_active, sort_order);


--
-- Name: idx_subscriptions_expires; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_subscriptions_expires ON public.subscriptions USING btree (expires_at) WHERE (status = 'active'::public.subscription_status);


--
-- Name: idx_subscriptions_plan; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_subscriptions_plan ON public.subscriptions USING btree (plan_id);


--
-- Name: idx_subscriptions_status; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_subscriptions_status ON public.subscriptions USING btree (status);


--
-- Name: idx_subscriptions_user; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_subscriptions_user ON public.subscriptions USING btree (user_id);


--
-- Name: idx_subscriptions_user_status; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_subscriptions_user_status ON public.subscriptions USING btree (user_id, status);


--
-- Name: idx_system_score_weights_active; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE UNIQUE INDEX idx_system_score_weights_active ON public.system_score_weights USING btree (is_active) WHERE (is_active = true);


--
-- Name: idx_tier4_waitlist_email; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_tier4_waitlist_email ON public.tier4_waitlist_entries USING btree (lower((email)::text));


--
-- Name: idx_tier4_waitlist_status_created; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_tier4_waitlist_status_created ON public.tier4_waitlist_entries USING btree (status, created_at DESC);


--
-- Name: idx_tier4_waitlist_user; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_tier4_waitlist_user ON public.tier4_waitlist_entries USING btree (user_id) WHERE (user_id IS NOT NULL);


--
-- Name: idx_trainer_availability; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_trainer_availability ON public.trainer_availability USING btree (trainer_id, day_of_week);


--
-- Name: idx_trainer_card_sequences_card; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_trainer_card_sequences_card ON public.trainer_card_sequences USING btree (trainer_card_id);


--
-- Name: idx_trainer_card_set_items_movement; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_trainer_card_set_items_movement ON public.trainer_card_set_items USING btree (movement_id);


--
-- Name: idx_trainer_card_set_items_set; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_trainer_card_set_items_set ON public.trainer_card_set_items USING btree (set_id);


--
-- Name: idx_trainer_card_sets_sequence; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_trainer_card_sets_sequence ON public.trainer_card_sets USING btree (sequence_id);


--
-- Name: idx_trainer_card_template_sequences_tmpl; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_trainer_card_template_sequences_tmpl ON public.trainer_card_template_sequences USING btree (template_id);


--
-- Name: idx_trainer_card_template_set_items_movement; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_trainer_card_template_set_items_movement ON public.trainer_card_template_set_items USING btree (movement_id);


--
-- Name: idx_trainer_card_template_set_items_set; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_trainer_card_template_set_items_set ON public.trainer_card_template_set_items USING btree (set_id);


--
-- Name: idx_trainer_card_template_sets_sequence; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_trainer_card_template_sets_sequence ON public.trainer_card_template_sets USING btree (sequence_id);


--
-- Name: idx_trainer_cards_created_by; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_trainer_cards_created_by ON public.trainer_cards USING btree (created_by);


--
-- Name: idx_trainer_cards_customer; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_trainer_cards_customer ON public.trainer_cards USING btree (customer_id);


--
-- Name: idx_trainer_clients_client; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_trainer_clients_client ON public.trainer_clients USING btree (client_id);


--
-- Name: idx_trainer_clients_status; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_trainer_clients_status ON public.trainer_clients USING btree (status);


--
-- Name: idx_training_schedules_active; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_training_schedules_active ON public.training_schedules USING btree (is_active);


--
-- Name: idx_training_schedules_client; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_training_schedules_client ON public.training_schedules USING btree (client_id);


--
-- Name: idx_training_schedules_day; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_training_schedules_day ON public.training_schedules USING btree (day_of_week);


--
-- Name: idx_training_schedules_trainer; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_training_schedules_trainer ON public.training_schedules USING btree (trainer_id);


--
-- Name: idx_training_sessions_client; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_training_sessions_client ON public.training_sessions USING btree (client_id);


--
-- Name: idx_training_sessions_date; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_training_sessions_date ON public.training_sessions USING btree (session_date);


--
-- Name: idx_training_sessions_schedule; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_training_sessions_schedule ON public.training_sessions USING btree (schedule_id);


--
-- Name: idx_training_sessions_status; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_training_sessions_status ON public.training_sessions USING btree (status);


--
-- Name: idx_training_sessions_substitute; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_training_sessions_substitute ON public.training_sessions USING btree (is_substitute) WHERE (is_substitute = true);


--
-- Name: idx_training_sessions_substituted_by; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_training_sessions_substituted_by ON public.training_sessions USING btree (substituted_by) WHERE (substituted_by IS NOT NULL);


--
-- Name: idx_training_sessions_trainer; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_training_sessions_trainer ON public.training_sessions USING btree (trainer_id);


--
-- Name: idx_uploads_entity; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_uploads_entity ON public.uploads USING btree (entity_type, entity_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_uploads_uploaded_by; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_uploads_uploaded_by ON public.uploads USING btree (uploaded_by) WHERE (deleted_at IS NULL);


--
-- Name: idx_user_programs_assigned_by; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_user_programs_assigned_by ON public.user_programs USING btree (assigned_by);


--
-- Name: idx_user_programs_program; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_user_programs_program ON public.user_programs USING btree (program_id);


--
-- Name: idx_user_programs_user; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_user_programs_user ON public.user_programs USING btree (user_id);


--
-- Name: idx_user_programs_user_status; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_user_programs_user_status ON public.user_programs USING btree (user_id, status);


--
-- Name: idx_users_created_at; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_users_created_at ON public.users USING btree (created_at);


--
-- Name: idx_users_deleted_at; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_users_deleted_at ON public.users USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: idx_users_role; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_users_role ON public.users USING btree (role);


--
-- Name: idx_users_status; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_users_status ON public.users USING btree (status);


--
-- Name: idx_workout_exercises_exercise; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_workout_exercises_exercise ON public.workout_exercises USING btree (exercise_id);


--
-- Name: idx_workout_exercises_workout; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_workout_exercises_workout ON public.workout_exercises USING btree (workout_id);


--
-- Name: idx_workout_reminders_enabled; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_workout_reminders_enabled ON public.workout_reminders USING btree (enabled) WHERE (enabled = true);


--
-- Name: idx_workout_session_logs_user_completed; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_workout_session_logs_user_completed ON public.workout_session_logs USING btree (user_id, completed_at DESC);


--
-- Name: idx_workout_session_logs_user_type; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_workout_session_logs_user_type ON public.workout_session_logs USING btree (user_id, session_type);


--
-- Name: idx_workouts_created_by; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_workouts_created_by ON public.workouts USING btree (created_by);


--
-- Name: idx_workouts_is_template; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_workouts_is_template ON public.workouts USING btree (is_template) WHERE (is_template = true);


--
-- Name: idx_workouts_type; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE INDEX idx_workouts_type ON public.workouts USING btree (type);


--
-- Name: uq_users_email_active; Type: INDEX; Schema: public; Owner: fitcoach
--

CREATE UNIQUE INDEX uq_users_email_active ON public.users USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: clinical_notes set_clinical_notes_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER set_clinical_notes_updated_at BEFORE UPDATE ON public.clinical_notes FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: condition_classifications set_condition_classifications_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER set_condition_classifications_updated_at BEFORE UPDATE ON public.condition_classifications FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: customer_hr_zones set_customer_hr_zones_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER set_customer_hr_zones_updated_at BEFORE UPDATE ON public.customer_hr_zones FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: customer_program_assignments set_customer_program_assignments_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER set_customer_program_assignments_updated_at BEFORE UPDATE ON public.customer_program_assignments FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: daily_journal_sessions set_daily_journal_sessions_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER set_daily_journal_sessions_updated_at BEFORE UPDATE ON public.daily_journal_sessions FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: equipments set_equipments_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER set_equipments_updated_at BEFORE UPDATE ON public.equipments FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: lab_consultations set_lab_consultations_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER set_lab_consultations_updated_at BEFORE UPDATE ON public.lab_consultations FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: medicines set_medicines_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER set_medicines_updated_at BEFORE UPDATE ON public.medicines FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: physical_status_levels set_physical_status_levels_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER set_physical_status_levels_updated_at BEFORE UPDATE ON public.physical_status_levels FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: program_categories set_program_categories_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER set_program_categories_updated_at BEFORE UPDATE ON public.program_categories FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: specific_conditions set_specific_conditions_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER set_specific_conditions_updated_at BEFORE UPDATE ON public.specific_conditions FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: system_score_weights set_system_score_weights_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER set_system_score_weights_updated_at BEFORE UPDATE ON public.system_score_weights FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: tier4_waitlist_entries set_tier4_waitlist_entries_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER set_tier4_waitlist_entries_updated_at BEFORE UPDATE ON public.tier4_waitlist_entries FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: announcements trg_announcements_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_announcements_updated_at BEFORE UPDATE ON public.announcements FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: assessments trg_assessments_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_assessments_updated_at BEFORE UPDATE ON public.assessments FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: automations trg_automations_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_automations_updated_at BEFORE UPDATE ON public.automations FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: bank_accounts trg_bank_accounts_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_bank_accounts_updated_at BEFORE UPDATE ON public.bank_accounts FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: calendar_events trg_calendar_events_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_calendar_events_updated_at BEFORE UPDATE ON public.calendar_events FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: challenges trg_challenges_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_challenges_updated_at BEFORE UPDATE ON public.challenges FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: conversations trg_conversations_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_conversations_updated_at BEFORE UPDATE ON public.conversations FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: device_tokens trg_device_tokens_updated; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_device_tokens_updated BEFORE UPDATE ON public.device_tokens FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: dl_categories trg_dl_categories_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_dl_categories_updated_at BEFORE UPDATE ON public.dl_categories FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: dl_dynamic_items trg_dl_dynamic_items_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_dl_dynamic_items_updated_at BEFORE UPDATE ON public.dl_dynamic_items FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: dl_isolate_items trg_dl_isolate_items_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_dl_isolate_items_updated_at BEFORE UPDATE ON public.dl_isolate_items FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: dl_levels trg_dl_levels_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_dl_levels_updated_at BEFORE UPDATE ON public.dl_levels FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: dl_menu_items trg_dl_menu_items_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_dl_menu_items_updated_at BEFORE UPDATE ON public.dl_menu_items FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: dl_movements trg_dl_movements_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_dl_movements_updated_at BEFORE UPDATE ON public.dl_movements FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: event_types trg_event_types_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_event_types_updated_at BEFORE UPDATE ON public.event_types FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: exercises trg_exercises_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_exercises_updated_at BEFORE UPDATE ON public.exercises FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: foods trg_foods_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_foods_updated_at BEFORE UPDATE ON public.foods FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: forms trg_forms_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_forms_updated_at BEFORE UPDATE ON public.forms FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: groups trg_groups_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_groups_updated_at BEFORE UPDATE ON public.groups FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: habit_folders trg_habit_folders_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_habit_folders_updated_at BEFORE UPDATE ON public.habit_folders FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: habits trg_habits_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_habits_updated_at BEFORE UPDATE ON public.habits FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: meal_plans trg_meal_plans_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_meal_plans_updated_at BEFORE UPDATE ON public.meal_plans FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: menus trg_menus_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_menus_updated_at BEFORE UPDATE ON public.menus FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: messages trg_messages_update_conversation; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_messages_update_conversation AFTER INSERT ON public.messages FOR EACH ROW EXECUTE FUNCTION public.fn_message_update_conversation();


--
-- Name: payment_plans trg_payment_plans_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_payment_plans_updated_at BEFORE UPDATE ON public.payment_plans FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: payment_records trg_payment_records_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_payment_records_updated_at BEFORE UPDATE ON public.payment_records FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: programs trg_programs_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_programs_updated_at BEFORE UPDATE ON public.programs FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: subscriptions trg_subscriptions_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_subscriptions_updated_at BEFORE UPDATE ON public.subscriptions FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: trainer_card_sequences trg_trainer_card_sequences_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_trainer_card_sequences_updated_at BEFORE UPDATE ON public.trainer_card_sequences FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: trainer_card_set_items trg_trainer_card_set_items_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_trainer_card_set_items_updated_at BEFORE UPDATE ON public.trainer_card_set_items FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: trainer_card_sets trg_trainer_card_sets_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_trainer_card_sets_updated_at BEFORE UPDATE ON public.trainer_card_sets FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: trainer_card_template_sequences trg_trainer_card_template_sequences_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_trainer_card_template_sequences_updated_at BEFORE UPDATE ON public.trainer_card_template_sequences FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: trainer_card_template_set_items trg_trainer_card_template_set_items_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_trainer_card_template_set_items_updated_at BEFORE UPDATE ON public.trainer_card_template_set_items FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: trainer_card_template_sets trg_trainer_card_template_sets_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_trainer_card_template_sets_updated_at BEFORE UPDATE ON public.trainer_card_template_sets FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: trainer_card_templates trg_trainer_card_templates_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_trainer_card_templates_updated_at BEFORE UPDATE ON public.trainer_card_templates FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: trainer_card_types trg_trainer_card_types_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_trainer_card_types_updated_at BEFORE UPDATE ON public.trainer_card_types FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: trainer_cards trg_trainer_cards_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_trainer_cards_updated_at BEFORE UPDATE ON public.trainer_cards FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: training_schedules trg_training_schedules_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_training_schedules_updated_at BEFORE UPDATE ON public.training_schedules FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: training_sessions trg_training_sessions_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_training_sessions_updated_at BEFORE UPDATE ON public.training_sessions FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: user_profiles trg_user_profiles_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_user_profiles_updated_at BEFORE UPDATE ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: user_programs trg_user_programs_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_user_programs_updated_at BEFORE UPDATE ON public.user_programs FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: users trg_users_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: workouts trg_workouts_updated_at; Type: TRIGGER; Schema: public; Owner: fitcoach
--

CREATE TRIGGER trg_workouts_updated_at BEFORE UPDATE ON public.workouts FOR EACH ROW EXECUTE FUNCTION public.fn_set_updated_at();


--
-- Name: announcement_reads announcement_reads_announcement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.announcement_reads
    ADD CONSTRAINT announcement_reads_announcement_id_fkey FOREIGN KEY (announcement_id) REFERENCES public.announcements(id) ON DELETE CASCADE;


--
-- Name: announcement_reads announcement_reads_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.announcement_reads
    ADD CONSTRAINT announcement_reads_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: announcements announcements_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: assessments assessments_classification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_classification_id_fkey FOREIGN KEY (classification_id) REFERENCES public.condition_classifications(id) ON DELETE SET NULL;


--
-- Name: assessments assessments_reviewed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_reviewed_by_fkey FOREIGN KEY (reviewed_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: assessments assessments_specific_condition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_specific_condition_id_fkey FOREIGN KEY (specific_condition_id) REFERENCES public.specific_conditions(id) ON DELETE SET NULL;


--
-- Name: assessments assessments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.assessments
    ADD CONSTRAINT assessments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: automation_logs automation_logs_automation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.automation_logs
    ADD CONSTRAINT automation_logs_automation_id_fkey FOREIGN KEY (automation_id) REFERENCES public.automations(id) ON DELETE CASCADE;


--
-- Name: automation_logs automation_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.automation_logs
    ADD CONSTRAINT automation_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: automations automations_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.automations
    ADD CONSTRAINT automations_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: body_metrics body_metrics_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.body_metrics
    ADD CONSTRAINT body_metrics_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: broadcast_notifications broadcast_notifications_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.broadcast_notifications
    ADD CONSTRAINT broadcast_notifications_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: calendar_events calendar_events_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.calendar_events
    ADD CONSTRAINT calendar_events_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: calendar_events calendar_events_event_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.calendar_events
    ADD CONSTRAINT calendar_events_event_type_id_fkey FOREIGN KEY (event_type_id) REFERENCES public.event_types(id) ON DELETE SET NULL;


--
-- Name: challenge_participants challenge_participants_challenge_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.challenge_participants
    ADD CONSTRAINT challenge_participants_challenge_id_fkey FOREIGN KEY (challenge_id) REFERENCES public.challenges(id) ON DELETE CASCADE;


--
-- Name: challenge_participants challenge_participants_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.challenge_participants
    ADD CONSTRAINT challenge_participants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: challenges challenges_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.challenges
    ADD CONSTRAINT challenges_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: clinical_notes clinical_notes_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.clinical_notes
    ADD CONSTRAINT clinical_notes_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments(id) ON DELETE SET NULL;


--
-- Name: clinical_notes clinical_notes_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.clinical_notes
    ADD CONSTRAINT clinical_notes_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: clinical_notes clinical_notes_consultant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.clinical_notes
    ADD CONSTRAINT clinical_notes_consultant_id_fkey FOREIGN KEY (consultant_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: cms_content cms_content_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.cms_content
    ADD CONSTRAINT cms_content_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: cms_media cms_media_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.cms_media
    ADD CONSTRAINT cms_media_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: cms_programs cms_programs_image_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.cms_programs
    ADD CONSTRAINT cms_programs_image_id_fkey FOREIGN KEY (image_id) REFERENCES public.cms_media(id) ON DELETE SET NULL;


--
-- Name: cms_settings cms_settings_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.cms_settings
    ADD CONSTRAINT cms_settings_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: cms_testimonials cms_testimonials_image_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.cms_testimonials
    ADD CONSTRAINT cms_testimonials_image_id_fkey FOREIGN KEY (image_id) REFERENCES public.cms_media(id) ON DELETE SET NULL;


--
-- Name: conversation_members conversation_members_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.conversation_members
    ADD CONSTRAINT conversation_members_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: conversation_members conversation_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.conversation_members
    ADD CONSTRAINT conversation_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: customer_hr_zones customer_hr_zones_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.customer_hr_zones
    ADD CONSTRAINT customer_hr_zones_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.users(id);


--
-- Name: customer_medicines customer_medicines_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.customer_medicines
    ADD CONSTRAINT customer_medicines_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.users(id);


--
-- Name: customer_medicines customer_medicines_medicine_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.customer_medicines
    ADD CONSTRAINT customer_medicines_medicine_id_fkey FOREIGN KEY (medicine_id) REFERENCES public.medicines(id);


--
-- Name: customer_program_assignments customer_program_assignments_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.customer_program_assignments
    ADD CONSTRAINT customer_program_assignments_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.users(id);


--
-- Name: customer_program_assignments customer_program_assignments_program_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.customer_program_assignments
    ADD CONSTRAINT customer_program_assignments_program_category_id_fkey FOREIGN KEY (program_category_id) REFERENCES public.program_categories(id);


--
-- Name: daily_journal_sessions daily_journal_sessions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.daily_journal_sessions
    ADD CONSTRAINT daily_journal_sessions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: daily_journal_sessions daily_journal_sessions_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.daily_journal_sessions
    ADD CONSTRAINT daily_journal_sessions_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.users(id);


--
-- Name: device_tokens device_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: dl_dynamic_items dl_dynamic_items_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.dl_dynamic_items
    ADD CONSTRAINT dl_dynamic_items_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.dl_categories(id) ON DELETE CASCADE;


--
-- Name: dl_dynamic_items dl_dynamic_items_lower_movement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.dl_dynamic_items
    ADD CONSTRAINT dl_dynamic_items_lower_movement_id_fkey FOREIGN KEY (lower_movement_id) REFERENCES public.dl_movements(id) ON DELETE SET NULL;


--
-- Name: dl_dynamic_items dl_dynamic_items_upper_movement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.dl_dynamic_items
    ADD CONSTRAINT dl_dynamic_items_upper_movement_id_fkey FOREIGN KEY (upper_movement_id) REFERENCES public.dl_movements(id) ON DELETE SET NULL;


--
-- Name: dl_isolate_items dl_isolate_items_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.dl_isolate_items
    ADD CONSTRAINT dl_isolate_items_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.dl_categories(id) ON DELETE CASCADE;


--
-- Name: dl_isolate_items dl_isolate_items_movement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.dl_isolate_items
    ADD CONSTRAINT dl_isolate_items_movement_id_fkey FOREIGN KEY (movement_id) REFERENCES public.dl_movements(id) ON DELETE CASCADE;


--
-- Name: dl_menu_items dl_menu_items_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.dl_menu_items
    ADD CONSTRAINT dl_menu_items_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.dl_categories(id) ON DELETE CASCADE;


--
-- Name: dl_menu_items dl_menu_items_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.dl_menu_items
    ADD CONSTRAINT dl_menu_items_level_id_fkey FOREIGN KEY (level_id) REFERENCES public.dl_levels(id) ON DELETE CASCADE;


--
-- Name: dl_menu_items dl_menu_items_movement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.dl_menu_items
    ADD CONSTRAINT dl_menu_items_movement_id_fkey FOREIGN KEY (movement_id) REFERENCES public.dl_movements(id) ON DELETE CASCADE;


--
-- Name: equipments equipments_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.equipments
    ADD CONSTRAINT equipments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: event_participants event_participants_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.event_participants
    ADD CONSTRAINT event_participants_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.calendar_events(id) ON DELETE CASCADE;


--
-- Name: event_participants event_participants_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.event_participants
    ADD CONSTRAINT event_participants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: event_types event_types_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.event_types
    ADD CONSTRAINT event_types_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: exercises exercises_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.exercises
    ADD CONSTRAINT exercises_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: foods foods_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.foods
    ADD CONSTRAINT foods_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: form_fields form_fields_form_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.form_fields
    ADD CONSTRAINT form_fields_form_id_fkey FOREIGN KEY (form_id) REFERENCES public.forms(id) ON DELETE CASCADE;


--
-- Name: form_responses form_responses_form_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.form_responses
    ADD CONSTRAINT form_responses_form_id_fkey FOREIGN KEY (form_id) REFERENCES public.forms(id) ON DELETE CASCADE;


--
-- Name: form_responses form_responses_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.form_responses
    ADD CONSTRAINT form_responses_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: forms forms_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.forms
    ADD CONSTRAINT forms_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: group_members group_members_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: group_members group_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: groups groups_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: habit_folders habit_folders_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.habit_folders
    ADD CONSTRAINT habit_folders_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: habit_logs habit_logs_habit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.habit_logs
    ADD CONSTRAINT habit_logs_habit_id_fkey FOREIGN KEY (habit_id) REFERENCES public.habits(id) ON DELETE CASCADE;


--
-- Name: habit_logs habit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.habit_logs
    ADD CONSTRAINT habit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: habits habits_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.habits
    ADD CONSTRAINT habits_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: habits habits_folder_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.habits
    ADD CONSTRAINT habits_folder_id_fkey FOREIGN KEY (folder_id) REFERENCES public.habit_folders(id) ON DELETE SET NULL;


--
-- Name: lab_consultations lab_consultations_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.lab_consultations
    ADD CONSTRAINT lab_consultations_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments(id) ON DELETE SET NULL;


--
-- Name: lab_consultations lab_consultations_consultant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.lab_consultations
    ADD CONSTRAINT lab_consultations_consultant_id_fkey FOREIGN KEY (consultant_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: lab_consultations lab_consultations_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.lab_consultations
    ADD CONSTRAINT lab_consultations_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES public.payment_records(id) ON DELETE SET NULL;


--
-- Name: lab_consultations lab_consultations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.lab_consultations
    ADD CONSTRAINT lab_consultations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: meal_plan_items meal_plan_items_meal_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.meal_plan_items
    ADD CONSTRAINT meal_plan_items_meal_plan_id_fkey FOREIGN KEY (meal_plan_id) REFERENCES public.meal_plans(id) ON DELETE CASCADE;


--
-- Name: meal_plans meal_plans_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.meal_plans
    ADD CONSTRAINT meal_plans_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: medicines medicines_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.medicines
    ADD CONSTRAINT medicines_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: menu_role_privileges menu_role_privileges_menu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.menu_role_privileges
    ADD CONSTRAINT menu_role_privileges_menu_id_fkey FOREIGN KEY (menu_id) REFERENCES public.menus(id) ON DELETE CASCADE;


--
-- Name: menus menus_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.menus(id) ON DELETE CASCADE;


--
-- Name: messages messages_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id) ON DELETE CASCADE;


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: nutrition_daily_logs nutrition_daily_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.nutrition_daily_logs
    ADD CONSTRAINT nutrition_daily_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: nutrition_health_profiles nutrition_health_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.nutrition_health_profiles
    ADD CONSTRAINT nutrition_health_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: nutrition_logs nutrition_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.nutrition_logs
    ADD CONSTRAINT nutrition_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: payment_records payment_records_bank_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.payment_records
    ADD CONSTRAINT payment_records_bank_account_id_fkey FOREIGN KEY (bank_account_id) REFERENCES public.bank_accounts(id) ON DELETE SET NULL;


--
-- Name: payment_records payment_records_subscription_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.payment_records
    ADD CONSTRAINT payment_records_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES public.subscriptions(id) ON DELETE RESTRICT;


--
-- Name: payment_records payment_records_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.payment_records
    ADD CONSTRAINT payment_records_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: payment_status_logs payment_status_logs_changed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.payment_status_logs
    ADD CONSTRAINT payment_status_logs_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: payment_status_logs payment_status_logs_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.payment_status_logs
    ADD CONSTRAINT payment_status_logs_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES public.payment_records(id) ON DELETE CASCADE;


--
-- Name: payment_status_logs payment_status_logs_subscription_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.payment_status_logs
    ADD CONSTRAINT payment_status_logs_subscription_id_fkey FOREIGN KEY (subscription_id) REFERENCES public.subscriptions(id) ON DELETE SET NULL;


--
-- Name: payment_status_logs payment_status_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.payment_status_logs
    ADD CONSTRAINT payment_status_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE RESTRICT;


--
-- Name: program_categories program_categories_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.program_categories
    ADD CONSTRAINT program_categories_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: program_days program_days_program_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.program_days
    ADD CONSTRAINT program_days_program_id_fkey FOREIGN KEY (program_id) REFERENCES public.programs(id) ON DELETE CASCADE;


--
-- Name: program_days program_days_workout_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.program_days
    ADD CONSTRAINT program_days_workout_id_fkey FOREIGN KEY (workout_id) REFERENCES public.workouts(id) ON DELETE SET NULL;


--
-- Name: programs programs_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.programs
    ADD CONSTRAINT programs_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: progress_logs progress_logs_exercise_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.progress_logs
    ADD CONSTRAINT progress_logs_exercise_id_fkey FOREIGN KEY (exercise_id) REFERENCES public.exercises(id) ON DELETE RESTRICT;


--
-- Name: progress_logs progress_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.progress_logs
    ADD CONSTRAINT progress_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: progress_logs progress_logs_workout_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.progress_logs
    ADD CONSTRAINT progress_logs_workout_id_fkey FOREIGN KEY (workout_id) REFERENCES public.workouts(id) ON DELETE SET NULL;


--
-- Name: promotions promotions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.promotions
    ADD CONSTRAINT promotions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: session_meals session_meals_food_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.session_meals
    ADD CONSTRAINT session_meals_food_id_fkey FOREIGN KEY (food_id) REFERENCES public.foods(id);


--
-- Name: session_meals session_meals_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.session_meals
    ADD CONSTRAINT session_meals_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.daily_journal_sessions(id) ON DELETE CASCADE;


--
-- Name: session_medicines session_medicines_medicine_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.session_medicines
    ADD CONSTRAINT session_medicines_medicine_id_fkey FOREIGN KEY (medicine_id) REFERENCES public.medicines(id);


--
-- Name: session_medicines session_medicines_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.session_medicines
    ADD CONSTRAINT session_medicines_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.daily_journal_sessions(id) ON DELETE CASCADE;


--
-- Name: session_vitals session_vitals_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.session_vitals
    ADD CONSTRAINT session_vitals_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.daily_journal_sessions(id) ON DELETE CASCADE;


--
-- Name: specific_conditions specific_conditions_classification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.specific_conditions
    ADD CONSTRAINT specific_conditions_classification_id_fkey FOREIGN KEY (classification_id) REFERENCES public.condition_classifications(id) ON DELETE RESTRICT;


--
-- Name: subscriptions subscriptions_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.payment_plans(id) ON DELETE RESTRICT;


--
-- Name: subscriptions subscriptions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: system_score_weights system_score_weights_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.system_score_weights
    ADD CONSTRAINT system_score_weights_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: tier4_waitlist_entries tier4_waitlist_entries_assessment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.tier4_waitlist_entries
    ADD CONSTRAINT tier4_waitlist_entries_assessment_id_fkey FOREIGN KEY (assessment_id) REFERENCES public.assessments(id) ON DELETE SET NULL;


--
-- Name: tier4_waitlist_entries tier4_waitlist_entries_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.tier4_waitlist_entries
    ADD CONSTRAINT tier4_waitlist_entries_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: trainer_availability trainer_availability_trainer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_availability
    ADD CONSTRAINT trainer_availability_trainer_id_fkey FOREIGN KEY (trainer_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: trainer_card_sequences trainer_card_sequences_program_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_sequences
    ADD CONSTRAINT trainer_card_sequences_program_category_id_fkey FOREIGN KEY (program_category_id) REFERENCES public.program_categories(id);


--
-- Name: trainer_card_sequences trainer_card_sequences_trainer_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_sequences
    ADD CONSTRAINT trainer_card_sequences_trainer_card_id_fkey FOREIGN KEY (trainer_card_id) REFERENCES public.trainer_cards(id) ON DELETE CASCADE;


--
-- Name: trainer_card_set_items trainer_card_set_items_movement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_set_items
    ADD CONSTRAINT trainer_card_set_items_movement_id_fkey FOREIGN KEY (movement_id) REFERENCES public.dl_movements(id) ON DELETE SET NULL;


--
-- Name: trainer_card_set_items trainer_card_set_items_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_set_items
    ADD CONSTRAINT trainer_card_set_items_set_id_fkey FOREIGN KEY (set_id) REFERENCES public.trainer_card_sets(id) ON DELETE CASCADE;


--
-- Name: trainer_card_sets trainer_card_sets_sequence_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_sets
    ADD CONSTRAINT trainer_card_sets_sequence_id_fkey FOREIGN KEY (sequence_id) REFERENCES public.trainer_card_sequences(id) ON DELETE CASCADE;


--
-- Name: trainer_card_sets trainer_card_sets_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_sets
    ADD CONSTRAINT trainer_card_sets_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.trainer_card_types(id) ON DELETE SET NULL;


--
-- Name: trainer_card_template_sequences trainer_card_template_sequences_program_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_template_sequences
    ADD CONSTRAINT trainer_card_template_sequences_program_category_id_fkey FOREIGN KEY (program_category_id) REFERENCES public.program_categories(id);


--
-- Name: trainer_card_template_sequences trainer_card_template_sequences_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_template_sequences
    ADD CONSTRAINT trainer_card_template_sequences_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.trainer_card_templates(id) ON DELETE CASCADE;


--
-- Name: trainer_card_template_set_items trainer_card_template_set_items_movement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_template_set_items
    ADD CONSTRAINT trainer_card_template_set_items_movement_id_fkey FOREIGN KEY (movement_id) REFERENCES public.dl_movements(id) ON DELETE SET NULL;


--
-- Name: trainer_card_template_set_items trainer_card_template_set_items_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_template_set_items
    ADD CONSTRAINT trainer_card_template_set_items_set_id_fkey FOREIGN KEY (set_id) REFERENCES public.trainer_card_template_sets(id) ON DELETE CASCADE;


--
-- Name: trainer_card_template_sets trainer_card_template_sets_sequence_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_template_sets
    ADD CONSTRAINT trainer_card_template_sets_sequence_id_fkey FOREIGN KEY (sequence_id) REFERENCES public.trainer_card_template_sequences(id) ON DELETE CASCADE;


--
-- Name: trainer_card_template_sets trainer_card_template_sets_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_card_template_sets
    ADD CONSTRAINT trainer_card_template_sets_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.trainer_card_types(id) ON DELETE SET NULL;


--
-- Name: trainer_cards trainer_cards_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_cards
    ADD CONSTRAINT trainer_cards_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: trainer_cards trainer_cards_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_cards
    ADD CONSTRAINT trainer_cards_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: trainer_clients trainer_clients_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_clients
    ADD CONSTRAINT trainer_clients_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: trainer_clients trainer_clients_trainer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.trainer_clients
    ADD CONSTRAINT trainer_clients_trainer_id_fkey FOREIGN KEY (trainer_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: training_schedules training_schedules_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.training_schedules
    ADD CONSTRAINT training_schedules_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: training_schedules training_schedules_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.training_schedules
    ADD CONSTRAINT training_schedules_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: training_schedules training_schedules_trainer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.training_schedules
    ADD CONSTRAINT training_schedules_trainer_id_fkey FOREIGN KEY (trainer_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: training_sessions training_sessions_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.training_sessions
    ADD CONSTRAINT training_sessions_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: training_sessions training_sessions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.training_sessions
    ADD CONSTRAINT training_sessions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: training_sessions training_sessions_original_trainer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.training_sessions
    ADD CONSTRAINT training_sessions_original_trainer_id_fkey FOREIGN KEY (original_trainer_id) REFERENCES public.users(id);


--
-- Name: training_sessions training_sessions_schedule_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.training_sessions
    ADD CONSTRAINT training_sessions_schedule_id_fkey FOREIGN KEY (schedule_id) REFERENCES public.training_schedules(id) ON DELETE SET NULL;


--
-- Name: training_sessions training_sessions_substituted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.training_sessions
    ADD CONSTRAINT training_sessions_substituted_by_fkey FOREIGN KEY (substituted_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: training_sessions training_sessions_trainer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.training_sessions
    ADD CONSTRAINT training_sessions_trainer_id_fkey FOREIGN KEY (trainer_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: uploads uploads_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.uploads
    ADD CONSTRAINT uploads_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.users(id);


--
-- Name: user_profiles user_profiles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.user_profiles
    ADD CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: user_programs user_programs_assigned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.user_programs
    ADD CONSTRAINT user_programs_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: user_programs user_programs_program_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.user_programs
    ADD CONSTRAINT user_programs_program_id_fkey FOREIGN KEY (program_id) REFERENCES public.programs(id) ON DELETE RESTRICT;


--
-- Name: user_programs user_programs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.user_programs
    ADD CONSTRAINT user_programs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: workout_exercises workout_exercises_exercise_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.workout_exercises
    ADD CONSTRAINT workout_exercises_exercise_id_fkey FOREIGN KEY (exercise_id) REFERENCES public.exercises(id) ON DELETE RESTRICT;


--
-- Name: workout_exercises workout_exercises_workout_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.workout_exercises
    ADD CONSTRAINT workout_exercises_workout_id_fkey FOREIGN KEY (workout_id) REFERENCES public.workouts(id) ON DELETE CASCADE;


--
-- Name: workout_reminders workout_reminders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.workout_reminders
    ADD CONSTRAINT workout_reminders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: workout_session_logs workout_session_logs_trainer_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.workout_session_logs
    ADD CONSTRAINT workout_session_logs_trainer_card_id_fkey FOREIGN KEY (trainer_card_id) REFERENCES public.trainer_cards(id) ON DELETE SET NULL;


--
-- Name: workout_session_logs workout_session_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.workout_session_logs
    ADD CONSTRAINT workout_session_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: workouts workouts_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fitcoach
--

ALTER TABLE ONLY public.workouts
    ADD CONSTRAINT workouts_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO fitcoach;


--
-- PostgreSQL database dump complete
--

\unrestrict fL2Er7hN90jKe2jyVWCMPpeyF3DshOPlQqkMcH21bEh9Ph3Qgl8zfgUatjHvB2H

