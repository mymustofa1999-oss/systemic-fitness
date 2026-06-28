-- 053: Rename Trainer Card Labels to Training Card Labels
UPDATE menus
SET label = 'Training Card Types',
    href = '/training-card-types'
WHERE code = 'trainer-card-types';
