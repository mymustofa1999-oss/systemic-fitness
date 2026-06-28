-- Migration 051: Add program_map_payload to assessments for Assessment V2 Program Map Reference

ALTER TABLE assessments 
ADD COLUMN IF NOT EXISTS program_map_payload JSONB;
