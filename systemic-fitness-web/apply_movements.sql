BEGIN;

-- UPDATE EXISTING: Arm Rotation
UPDATE dl_movements SET video_url_male = 'https://youtu.be/uLK9HMwjYjk', video_url_female = 'https://youtu.be/KehSzUUpVY8' WHERE name = 'Arm Rotation';

-- UPDATE EXISTING: Open V
UPDATE dl_movements SET video_url_male = 'https://www.youtube.com/watch?v=h2JEPSaXsbY', video_url_female = 'https://youtu.be/qjKyIhvRSto' WHERE name = 'Open V';

-- UPDATE EXISTING: Press Up
UPDATE dl_movements SET video_url_male = 'https://youtu.be/vQl_OVtbI00', video_url_female = 'https://youtu.be/aFbveSHv7cQ?si=5M1-vlEBLDKZ8fEH' WHERE name = 'Press Up';

-- UPDATE EXISTING: Press Front
UPDATE dl_movements SET video_url_male = 'https://youtu.be/bhdITmK2Hn8', video_url_female = 'https://youtu.be/S1AhD6o6tnI' WHERE name = 'Press Front';

-- UPDATE EXISTING: Open Arm
UPDATE dl_movements SET video_url_male = 'https://youtu.be/CmPzKXUH9GQ', video_url_female = 'https://youtu.be/VyOHUL9OtoQ' WHERE name = 'Open Arm';

-- UPDATE EXISTING: Cross Front
UPDATE dl_movements SET video_url_male = 'https://youtu.be/j_V0hvaU93c', video_url_female = 'https://youtu.be/iGVTZCT-LIE' WHERE name = 'Cross Front';

-- INSERT NEW: Front Knee Lift
INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, categories, is_active, target_gender) VALUES ('Front Knee Lift', 'lower', 'https://youtu.be/2X7EtSq2T6s', 'https://youtu.be/Atb_GRZ8sWE', '{}', true, 'universal');

-- INSERT NEW: Front Leg Ext
INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, categories, is_active, target_gender) VALUES ('Front Leg Ext', 'lower', 'waitlist', 'waitlist', '{}', true, 'universal');

-- UPDATE EXISTING: Sit Squat TRX
UPDATE dl_movements SET video_url_male = 'https://youtu.be/Nk-WOfTOKDk', video_url_female = 'https://youtu.be/Nk-WOfTOKDk' WHERE name = 'Sit Squat TRX';

-- UPDATE EXISTING: Sit Overhead Squat TRX
UPDATE dl_movements SET video_url_male = 'https://youtu.be/WLXNxVgKWWk', video_url_female = 'https://youtu.be/WLXNxVgKWWk' WHERE name = 'Sit Overhead Squat TRX';

-- UPDATE EXISTING: Sit Sumo Squat TRX
UPDATE dl_movements SET video_url_male = 'https://youtu.be/KmhFbTEOzq0', video_url_female = 'https://youtu.be/KmhFbTEOzq0' WHERE name = 'Sit Sumo Squat TRX';

-- UPDATE EXISTING: Triceps Extension
UPDATE dl_movements SET video_url_male = 'https://youtu.be/UkFjVk5QcCY', video_url_female = 'https://youtu.be/Q8Et1YRNA1s' WHERE name = 'Triceps Extension';

-- UPDATE EXISTING: Cross Up
UPDATE dl_movements SET video_url_male = 'https://youtu.be/qy2ldvISD2Y', video_url_female = 'https://youtu.be/qy2ldvISD2Y' WHERE name = 'Cross Up';

-- INSERT NEW: Hip Abductor Band
INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, categories, is_active, target_gender) VALUES ('Hip Abductor Band', 'lower', 'https://youtu.be/iBCOKowoozg', 'https://youtu.be/iBCOKowoozg', '{}', true, 'universal');

-- INSERT NEW: 1
INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, categories, is_active, target_gender) VALUES ('1', 'upper', 'https://youtu.be/tOhv0VRVejo', 'https://youtu.be/tOhv0VRVejo', '{}', true, 'universal');

-- INSERT NEW: 2
INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, categories, is_active, target_gender) VALUES ('2', 'upper', 'https://youtu.be/V4mn6TbnWNQ', 'https://youtu.be/V4mn6TbnWNQ', '{}', true, 'universal');

-- INSERT NEW: 3
INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, categories, is_active, target_gender) VALUES ('3', 'upper', 'https://youtu.be/MJA4uPj84gY', 'https://youtu.be/MJA4uPj84gY', '{}', true, 'universal');

-- INSERT NEW: 4
INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, categories, is_active, target_gender) VALUES ('4', 'upper', 'https://youtu.be/zOPb6M65i-w', 'https://youtu.be/zOPb6M65i-w', '{}', true, 'universal');

-- INSERT NEW: 5
INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, categories, is_active, target_gender) VALUES ('5', 'upper', 'https://youtu.be/okZldHu7Ia0', 'https://youtu.be/okZldHu7Ia0', '{}', true, 'universal');

-- INSERT NEW: 6
INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, categories, is_active, target_gender) VALUES ('6', 'upper', 'https://youtu.be/wuHLXsC9dEw', 'https://youtu.be/wuHLXsC9dEw', '{}', true, 'universal');

-- INSERT NEW: 7
INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, categories, is_active, target_gender) VALUES ('7', 'upper', 'https://youtu.be/At7NNBl1epE', 'https://youtu.be/At7NNBl1epE', '{}', true, 'universal');

-- INSERT NEW: 8
INSERT INTO dl_movements (name, body_part, video_url_male, video_url_female, categories, is_active, target_gender) VALUES ('8', 'upper', 'https://youtu.be/4URSj-qYyQo', 'https://youtu.be/4URSj-qYyQo', '{}', true, 'universal');

COMMIT;
