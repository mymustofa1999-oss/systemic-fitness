-- ════════════════════════════════════════════════════════════════════
--  Systemic Fitness — Movement Video URL Migration
--  Generated from: Modul Gerakan .xlsx
--  Total entries: 129 (95 male URLs, 100 female URLs)
--
--  HOW TO RUN:
--    1. Copy this file to VPS:
--       scp movement_videos.sql root@<VPS_IP>:/tmp/
--
--    2. (Optional) Dry-run — check current state:
--       psql -U fitcoach -d fitcoach -c "SELECT name, body_part, categories, video_url_male IS NOT NULL AS has_male, video_url_female IS NOT NULL AS has_female FROM dl_movements ORDER BY name;"
--
--    3. Run the migration:
--       psql -U fitcoach -d fitcoach -f /tmp/movement_videos.sql
--
--    NOTE: If movement names in the DB don't match exactly,
--    the UPDATE will silently affect 0 rows. Check the
--    verification query at the bottom to confirm.
-- ════════════════════════════════════════════════════════════════════

-- Pre-check: show current state before migration
SELECT 'BEFORE MIGRATION' AS status,
    COUNT(*) FILTER (WHERE video_url_male IS NOT NULL) AS male_videos,
    COUNT(*) FILTER (WHERE video_url_female IS NOT NULL) AS female_videos,
    COUNT(*) AS total_movements
FROM dl_movements;

BEGIN;

-- ── FUNCTIONAL CONDITIONING ─────────────────────────────────────────

-- Isolate Functional Movement (menu trainer dan custom) / Upper Sit
-- Row 7: Arm Rotation (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/pWLo4ASgThA', video_url_female = 'https://youtu.be/_rOmevahtfg' WHERE name = 'Arm Rotation' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 8: Open V (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/DswiLrjoxxY', video_url_female = 'https://youtu.be/vW4hYdWDFQs' WHERE name = 'Open V' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 9: Press Up (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/LwMSkwsyF1k', video_url_female = 'https://youtu.be/WHqnzb7PNhY' WHERE name = 'Press Up' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 10: Press Front (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/liMXFUIBKO4', video_url_female = 'https://youtu.be/-Dt4vpTTveM' WHERE name = 'Press Front' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 11: Open Arm (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/QgUyFlKn7ss', video_url_female = 'https://youtu.be/mT4KBrXiG-0' WHERE name = 'Open Arm' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 12: Cross Front (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/wUElNgGulvo', video_url_female = 'https://youtu.be/3sNteqa5dX0' WHERE name = 'Cross Front' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 14: Front Lift Sit (FC/lower)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/2X7EtSq2T6s' WHERE name = 'Front Lift Sit' AND body_part = 'lower' AND categories @> ARRAY['fc']::training_category[];

-- Row 15: Sit Squat TRX (FC/lower)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/Nk-WOfTOKDk' WHERE name = 'Sit Squat TRX' AND body_part = 'lower' AND categories @> ARRAY['fc']::training_category[];

-- Row 16: Sit Overhead Squat TRX (FC/lower)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/WLXNxVgKWWk' WHERE name = 'Sit Overhead Squat TRX' AND body_part = 'lower' AND categories @> ARRAY['fc']::training_category[];

-- Row 17: Sit Sumo Squat TRX (FC/lower)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/KmhFbTEOzq0' WHERE name = 'Sit Sumo Squat TRX' AND body_part = 'lower' AND categories @> ARRAY['fc']::training_category[];

-- Row 19: Arm Rotation (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/sDOZ6_IryG4', video_url_female = 'https://youtu.be/3S5hk1mM9c4' WHERE name = 'Arm Rotation' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 20: Open V (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/Z0gRsOoH5pM', video_url_female = 'https://youtu.be/HO-6f595dyc' WHERE name = 'Open V' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 21: Press Up (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/nD7VmQs5PKg', video_url_female = 'https://youtu.be/8xNbmpUQ4rE' WHERE name = 'Press Up' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 22: Press Front (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/YLQENH_iYgQ', video_url_female = 'https://youtu.be/uIPb6IDr51w' WHERE name = 'Press Front' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 23: Open Arm (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/3HLQsRgNOIQ', video_url_female = 'https://youtu.be/g_LKFDpIdy8' WHERE name = 'Open Arm' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 24: Cross Front (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/LuPaSY9FBs8', video_url_female = 'https://youtu.be/FzYB8lcHSPI' WHERE name = 'Cross Front' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 26: Back step - Chair (FC/lower)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/fBOm3969Yqs', video_url_female = 'https://youtu.be/YCY0kXQRiKw' WHERE name = 'Back step - Chair' AND body_part = 'lower' AND categories @> ARRAY['fc']::training_category[];

-- Row 28: Side Lift Chair (FC/lower)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/2le3ZUhrrCo', video_url_female = 'https://youtu.be/P_H-K-tRju4' WHERE name = 'Side Lift Chair' AND body_part = 'lower' AND categories @> ARRAY['fc']::training_category[];

-- Row 29: Front Lift Chair (FC/lower)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/_X3Yay98-iY', video_url_female = 'https://youtu.be/u7mh_0N10ng' WHERE name = 'Front Lift Chair' AND body_part = 'lower' AND categories @> ARRAY['fc']::training_category[];

-- Row 30: High Knee Chair (FC/lower)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/Hs-7YhopeJI', video_url_female = 'https://youtu.be/Ox8pRX6m-uc' WHERE name = 'High Knee Chair' AND body_part = 'lower' AND categories @> ARRAY['fc']::training_category[];

-- Row 31: Knee Drive Chair (FC/lower)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/wFpgh1BJYeE' WHERE name = 'Knee Drive Chair' AND body_part = 'lower' AND categories @> ARRAY['fc']::training_category[];

-- Row 32: Jog-Chair (FC/lower)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/xACMI0OBOVc', video_url_female = 'https://youtu.be/FSNB9y7s_sU' WHERE name = 'Jog-Chair' AND body_part = 'lower' AND categories @> ARRAY['fc']::training_category[];

-- Dynamic Functional Movement / Upper
-- Row 36: Arm Rotation (FC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/Pug7FAy_KCM' WHERE name = 'Arm Rotation' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 37: Arm Rotation (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/lj1diXjbLic' WHERE name = 'Arm Rotation' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 38: Arm Swing (FC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/0D9rCR9uJi4' WHERE name = 'Arm Swing' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 39: Open V (FC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/8EQbLb0VKMU' WHERE name = 'Open V' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 40: Open V (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/2-PJzn307D4' WHERE name = 'Open V' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 41: Press Up (FC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/v7H6_j7illg' WHERE name = 'Press Up' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 42: Press Up (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/Wy84RyjVzzE' WHERE name = 'Press Up' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 43: Open V (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/PD35IcUpkRg' WHERE name = 'Open V' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 46: Press Front (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/WskPENhO6h4' WHERE name = 'Press Front' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 47: Open Arm (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/tSZRWHtYOnE' WHERE name = 'Open Arm' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 48: Cross Front (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/u5glRn4tBtA', video_url_female = 'https://youtu.be/UJiEOkWT5zc' WHERE name = 'Cross Front' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 49: Arm Swing (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/7iD6dmofuKA', video_url_female = 'https://youtu.be/lvhqPnmQbK4' WHERE name = 'Arm Swing' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 50: Pull Side Down (FC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/EaWOWO7pkEg' WHERE name = 'Pull Side Down' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 51: Cross Front (FC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/QoTDyry4MPk' WHERE name = 'Cross Front' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 52: Cross Up (FC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/GbDDU-PLDPI' WHERE name = 'Cross Up' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 53: Pull Down (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/ZwA4_ZFz3MQ', video_url_female = 'https://youtu.be/OYQUBXfy92c' WHERE name = 'Pull Down' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 55: Squat TRX (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/OJ_dpcSszR8', video_url_female = 'https://youtu.be/aEXUq7v5EvE' WHERE name = 'Squat TRX' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 56: Overhead Squat TRX (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/zuD0fWUmQlc', video_url_female = 'https://youtu.be/Y6dZVU7lfM4' WHERE name = 'Overhead Squat TRX' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 57: Sumo Squat TRX (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/RMp3AABx4-I', video_url_female = 'https://youtu.be/o-I54NprOe4' WHERE name = 'Sumo Squat TRX' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 58: Lunges Chair (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/IcfCRJexRx4', video_url_female = 'https://youtu.be/ekUL39z6KzQ' WHERE name = 'Lunges Chair' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 60: Squat Chair (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/xxeOLPbsK7Y', video_url_female = 'https://youtu.be/lZbEjnKuygo' WHERE name = 'Squat Chair' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 61: Sumo Squat Chair (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/pyAAJmwFpH0', video_url_female = 'https://youtu.be/O2tJsvOTbiQ' WHERE name = 'Sumo Squat Chair' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 62: Squat Step Chair (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/qY3b9178JnA', video_url_female = 'https://youtu.be/co1rOOnWJpo' WHERE name = 'Squat Step Chair' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 63: Lateral Lunge Chair (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/O9jBkVxvV6w', video_url_female = 'https://youtu.be/A8zrLo4iuns' WHERE name = 'Lateral Lunge Chair' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 64: Squat (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/Z_efCtyd2dQ', video_url_female = 'https://youtu.be/XyS-XmW2Pwc' WHERE name = 'Squat' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 65: Overhead Squat (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/syENYeSA1-4', video_url_female = 'https://youtu.be/Zz_kb0SUEvM' WHERE name = 'Overhead Squat' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 66: Sumo Squat (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/z669Jt8SD8A', video_url_female = 'https://youtu.be/fLjY9iWHM5g' WHERE name = 'Sumo Squat' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 67: Squat Step (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/BnfKGJrSCvk', video_url_female = 'https://youtu.be/lx7tnAYnfqU' WHERE name = 'Squat Step' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 68: Lunges (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/ztKJWHeKSdU', video_url_female = 'https://youtu.be/ZcbOg4goUWY' WHERE name = 'Lunges' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 69: Lateral Lunge (FC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/DZI61Qlo3n4', video_url_female = 'https://youtu.be/pIlDIlALdbc' WHERE name = 'Lateral Lunge' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- Row 70: Squat Curtsy Lunges (FC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/7llhcX_p1Qw' WHERE name = 'Squat Curtsy Lunges' AND body_part = 'upper' AND categories @> ARRAY['fc']::training_category[];

-- ── CARDIO CONDITIONING ─────────────────────────────────────────

-- Isolate Cardio Movement (menu trainer dan custom) / Upper Sit
-- Row 77: Arm Rotation (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/uLK9HMwjYjk', video_url_female = 'https://youtu.be/KehSzUUpVY8' WHERE name = 'Arm Rotation' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 78: Open V (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/h2JEPSaXsbY', video_url_female = 'https://youtu.be/mMvq_ZWa-AU' WHERE name = 'Open V' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 79: Press Up (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/chw74rCgOjg', video_url_female = 'https://youtu.be/trlgpxVehok' WHERE name = 'Press Up' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 80: Press Front (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/bhdITmK2Hn8', video_url_female = 'https://youtu.be/S1AhD6o6tnI' WHERE name = 'Press Front' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 81: Open Arm (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/XG233Fngu-0', video_url_female = 'https://youtu.be/gIeBMVSQQAI' WHERE name = 'Open Arm' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 82: Cross Front (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/j_V0hvaU93c', video_url_female = 'https://youtu.be/iGVTZCT-LIE' WHERE name = 'Cross Front' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 84: Front Lift - Sit (CC/lower)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/Atb_GRZ8sWE' WHERE name = 'Front Lift - Sit' AND body_part = 'lower' AND categories @> ARRAY['cc']::training_category[];

-- Row 90: Arm Rotation (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/Gv0JzAjI4wE', video_url_female = 'https://youtu.be/rQG0Qrw3HTE' WHERE name = 'Arm Rotation' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 91: Open V (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/AW-YmbtnQuY', video_url_female = 'https://youtu.be/IXmE3KR8HU8' WHERE name = 'Open V' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 92: Press Up (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/iWPFTtwlHwE', video_url_female = 'https://youtu.be/y_nx3_UcZ5I' WHERE name = 'Press Up' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 93: Press Front (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/DKVBV1eG9vI' WHERE name = 'Press Front' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 94: Open Arm (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/8lAB9sXnvHA' WHERE name = 'Open Arm' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 95: Cross Front (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/Fn0SsvZO6D4', video_url_female = 'https://youtu.be/Ipd3w6kNseo' WHERE name = 'Cross Front' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 97: Back step - Chair (CC/lower)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/2yhPBvyZSUU', video_url_female = 'https://youtu.be/0F48EbjjQTw' WHERE name = 'Back step - Chair' AND body_part = 'lower' AND categories @> ARRAY['cc']::training_category[];

-- Row 98: Side Step Chair (CC/lower)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/VlqR1OxrXhE', video_url_female = 'https://youtu.be/3OFDAcpR3cU' WHERE name = 'Side Step Chair' AND body_part = 'lower' AND categories @> ARRAY['cc']::training_category[];

-- Row 99: Side Lift Chair (CC/lower)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/XFv3FOuQuqM', video_url_female = 'https://youtu.be/D-ekkwKHtSs' WHERE name = 'Side Lift Chair' AND body_part = 'lower' AND categories @> ARRAY['cc']::training_category[];

-- Row 100: Front Lift Chair (CC/lower)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/R63B9LnlbZE', video_url_female = 'https://youtu.be/JheecrPIpmM' WHERE name = 'Front Lift Chair' AND body_part = 'lower' AND categories @> ARRAY['cc']::training_category[];

-- Row 101: High Knee Chair (CC/lower)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/CknG49mGjcs', video_url_female = 'https://youtu.be/oOGxaCNDeE4' WHERE name = 'High Knee Chair' AND body_part = 'lower' AND categories @> ARRAY['cc']::training_category[];

-- Row 102: Knee Drive Chair (CC/lower)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/Rg_XddCoNZ4', video_url_female = 'https://youtu.be/SeEB4tTMy3g' WHERE name = 'Knee Drive Chair' AND body_part = 'lower' AND categories @> ARRAY['cc']::training_category[];

-- Row 103: Jog-Chair (CC/lower)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/8sWa8vyjwvA', video_url_female = 'https://youtu.be/qSKkOd9gylg' WHERE name = 'Jog-Chair' AND body_part = 'lower' AND categories @> ARRAY['cc']::training_category[];

-- Dynamic Cardio Movement / Upper
-- Row 111: Arm Rotation (CC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/CDkR0Hqu_B4' WHERE name = 'Arm Rotation' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 112: Open V (CC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/lq5xyb4Gbqw' WHERE name = 'Open V' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 113: Open V (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/2DFVVzg7_wA' WHERE name = 'Open V' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 114: Open Arm (CC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/P1eSuz6kqiY' WHERE name = 'Open Arm' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 115: Open Arm (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/7QuULk8igKs' WHERE name = 'Open Arm' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 116: Open Chest (CC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/pIWz19u3Xw0' WHERE name = 'Open Chest' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 117: Open Chest (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/OnCUQ1_RYTE' WHERE name = 'Open Chest' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 118: Press Front (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/BQ2dFuJsOk4', video_url_female = 'https://youtu.be/ockOeSpsi6s' WHERE name = 'Press Front' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 119: Cross Front (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/9QVyWOnKDNQ', video_url_female = 'https://youtu.be/UQIr_ipsjW4' WHERE name = 'Cross Front' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 120: Cross Up (CC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/vryAReBm_Dg' WHERE name = 'Cross Up' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 121: Press Up (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/uUtxuiIuP10' WHERE name = 'Press Up' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 122: Open V (CC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/3_8oPYwzqeU' WHERE name = 'Open V' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 123: Open V (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/pXPbrDo1LOQ', video_url_female = 'https://youtu.be/h1yDRnY_f_g' WHERE name = 'Open V' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 124: Press Up (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/dn4rKXIa_t8', video_url_female = 'https://youtu.be/D6HVuSKpuJY' WHERE name = 'Press Up' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 125: Open Arm (CC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/i5TCtKu4DAg' WHERE name = 'Open Arm' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 127: Press Front (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/Kpcf1EY4ZI0', video_url_female = 'https://youtu.be/y2ApZiAYNH0' WHERE name = 'Press Front' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 128: Open Arm (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/I2ziQ5trgGQ', video_url_female = 'https://youtu.be/Q7MPMJeCyn0' WHERE name = 'Open Arm' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 129: Cross Front (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/Lv2KrnPLxqk', video_url_female = 'https://youtu.be/UdXyx4eSKac' WHERE name = 'Cross Front' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 130: Arm Swing (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/dgGHE1Sdl44', video_url_female = 'https://youtu.be/bPdopl2Jf3M' WHERE name = 'Arm Swing' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 131: Pull Side Down (CC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/jgOaIUNOQww' WHERE name = 'Pull Side Down' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 132: Cross Front (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/E9IzR-wui8o', video_url_female = 'https://youtu.be/h-Qk-6DWgsQ' WHERE name = 'Cross Front' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 133: Cross Up (CC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/0wV-AXp6f7Q' WHERE name = 'Cross Up' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 134: Pull Down (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/diF01S8vM5c', video_url_female = 'https://youtu.be/D73tCsorelU' WHERE name = 'Pull Down' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 135: Pull Down (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/S6zwg686YrY', video_url_female = 'https://youtu.be/3vimOX9AHQc' WHERE name = 'Pull Down' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- Row 136: Open V (CC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/ICoAkaFoMAQ' WHERE name = 'Open V' AND body_part = 'upper' AND categories @> ARRAY['cc']::training_category[];

-- ── METABOLIC CONDITIONING ─────────────────────────────────────────

-- Metabolic Basic Movement / Upper Sit
-- Row 143: Open V (MC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/qjKyIhvRSto' WHERE name = 'Open V' AND body_part = 'upper' AND categories @> ARRAY['mc']::training_category[];

-- Row 144: Press Up (MC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/vQl_OVtbI00', video_url_female = 'https://youtu.be/aFbveSHv7cQ' WHERE name = 'Press Up' AND body_part = 'upper' AND categories @> ARRAY['mc']::training_category[];

-- Row 145: Open Arm (MC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/CmPzKXUH9GQ', video_url_female = 'https://youtu.be/VyOHUL9OtoQ' WHERE name = 'Open Arm' AND body_part = 'upper' AND categories @> ARRAY['mc']::training_category[];

-- Row 146: Triceps Press (MC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/UkFjVk5QcCY', video_url_female = 'https://youtu.be/Q8Et1YRNA1s' WHERE name = 'Triceps Press' AND body_part = 'upper' AND categories @> ARRAY['mc']::training_category[];

-- Row 147: Cross Up (MC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/qy2ldvISD2Y' WHERE name = 'Cross Up' AND body_part = 'upper' AND categories @> ARRAY['mc']::training_category[];

-- Row 148: Press Front (MC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/J5wWtoTR-ak' WHERE name = 'Press Front' AND body_part = 'upper' AND categories @> ARRAY['mc']::training_category[];

-- Row 150: Chest Press (MC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/wuH_zwLy6EM' WHERE name = 'Chest Press' AND body_part = 'upper' AND categories @> ARRAY['mc']::training_category[];

-- Row 151: Bent Over Fly (MC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/prz4V9AacSE' WHERE name = 'Bent Over Fly' AND body_part = 'upper' AND categories @> ARRAY['mc']::training_category[];

-- Row 152: Overhead Press (MC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/NFsWcXn8HmU' WHERE name = 'Overhead Press' AND body_part = 'upper' AND categories @> ARRAY['mc']::training_category[];

-- Row 153: Bicep Curls (MC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/SZKOhGoXcTI' WHERE name = 'Bicep Curls' AND body_part = 'upper' AND categories @> ARRAY['mc']::training_category[];

-- Row 154: Barbel Row (MC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/dQPys_dgoGY' WHERE name = 'Barbel Row' AND body_part = 'upper' AND categories @> ARRAY['mc']::training_category[];

-- Row 156: Squat-Band (MC/lower)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/iBCOKowoozg' WHERE name = 'Squat-Band' AND body_part = 'lower' AND categories @> ARRAY['mc']::training_category[];

-- Row 160: Squat-Press Up (MC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/UR3zf5_kbdU' WHERE name = 'Squat-Press Up' AND body_part = 'upper' AND categories @> ARRAY['mc']::training_category[];

-- Row 161: Open Arm (MC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/Wh_4iamBMMc' WHERE name = 'Open Arm' AND body_part = 'upper' AND categories @> ARRAY['mc']::training_category[];

-- Row 163: Squat-Cross Up (MC/upper)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/h6T2Uc7Q-Go' WHERE name = 'Squat-Cross Up' AND body_part = 'upper' AND categories @> ARRAY['mc']::training_category[];

-- Row 164: Dumbbell Rows (MC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/1gPBgQn3JiA' WHERE name = 'Dumbbell Rows' AND body_part = 'upper' AND categories @> ARRAY['mc']::training_category[];

-- Row 165: Front Raise (MC/upper)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/VOzvuZKDrL4' WHERE name = 'Front Raise' AND body_part = 'upper' AND categories @> ARRAY['mc']::training_category[];

-- Row 167: Squat-Band (MC/lower)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/eeq1nRoE7g8' WHERE name = 'Squat-Band' AND body_part = 'lower' AND categories @> ARRAY['mc']::training_category[];

-- Row 169: Kick Back (MC/lower)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/K-TIOy5Vft0' WHERE name = 'Kick Back' AND body_part = 'lower' AND categories @> ARRAY['mc']::training_category[];

-- Row 172: Donkey Kick (MC/lower)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/REjEINo4nJc' WHERE name = 'Donkey Kick' AND body_part = 'lower' AND categories @> ARRAY['mc']::training_category[];

-- Row 174: Doggy Pee Band (MC/lower)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/xJXlQ3eAb3U' WHERE name = 'Doggy Pee Band' AND body_part = 'lower' AND categories @> ARRAY['mc']::training_category[];

-- Row 175: Donkey Kick Band (MC/lower)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/qmOF8yrtw4M' WHERE name = 'Donkey Kick Band' AND body_part = 'lower' AND categories @> ARRAY['mc']::training_category[];

-- Row 176: Kick Back Band (MC/lower)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/nvSk5r4ZtMY' WHERE name = 'Kick Back Band' AND body_part = 'lower' AND categories @> ARRAY['mc']::training_category[];

-- Metabolic Core Movement ( menu prevention berdasarkan gender) / Level 1
-- Row 180: Push Up (MC/core)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/Q4fCSHL8FlU' WHERE name = 'Push Up' AND body_part = 'core' AND categories @> ARRAY['mc']::training_category[];

-- Row 183: Sit Up (MC/core)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/CLweukibDg0', video_url_female = 'https://youtu.be/Po3qKd74lpg' WHERE name = 'Sit Up' AND body_part = 'core' AND categories @> ARRAY['mc']::training_category[];

-- Row 184: Push Up Plank (MC/core)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/qGa0DdAFp8A' WHERE name = 'Push Up Plank' AND body_part = 'core' AND categories @> ARRAY['mc']::training_category[];

-- Row 185: Plank (MC/core)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/vnifs9riEJY' WHERE name = 'Plank' AND body_part = 'core' AND categories @> ARRAY['mc']::training_category[];

-- Row 186: High Plank (MC/core)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/6mFaXOZwqOw' WHERE name = 'High Plank' AND body_part = 'core' AND categories @> ARRAY['mc']::training_category[];

-- Row 189: Glute Bridge Band (MC/core)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/2DzvTS7g394' WHERE name = 'Glute Bridge Band' AND body_part = 'core' AND categories @> ARRAY['mc']::training_category[];

-- Row 191: Pedal band (MC/core)
UPDATE dl_movements SET video_url_female = 'https://youtu.be/caeEgVqXUxE' WHERE name = 'Pedal band' AND body_part = 'core' AND categories @> ARRAY['mc']::training_category[];

-- Row 192: Variasi Crunch (MC/core)
UPDATE dl_movements SET video_url_male = 'https://youtu.be/yCu79ggGrME' WHERE name = 'Variasi Crunch' AND body_part = 'core' AND categories @> ARRAY['mc']::training_category[];

COMMIT;

-- ════════════════════════════════════════════════════════════════════
--  Verification: count how many movements now have video URLs
-- ════════════════════════════════════════════════════════════════════
SELECT 'AFTER MIGRATION' AS status,
    COUNT(*) FILTER (WHERE video_url_male IS NOT NULL) AS male_videos,
    COUNT(*) FILTER (WHERE video_url_female IS NOT NULL) AS female_videos,
    COUNT(*) FILTER (WHERE video_url_male IS NOT NULL OR video_url_female IS NOT NULL) AS with_any_video,
    COUNT(*) FILTER (WHERE video_url_male IS NULL AND video_url_female IS NULL) AS without_video,
    COUNT(*) AS total_movements
FROM dl_movements;

-- Show all movements that still have NO video (potential unmatched names)
SELECT name, body_part, categories
FROM dl_movements
WHERE video_url_male IS NULL AND video_url_female IS NULL
ORDER BY categories, body_part, name;
