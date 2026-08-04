-- +migrate Up
DELETE FROM menu_role_privileges WHERE menu_id IN (
    SELECT id FROM menus WHERE code IN (
        'sf_consultant_my_clients',
        'sf_consultant_clients_digital',
        'sf_consultant_clients_digital_pt',
        'sf_consultant_clients_digital_gt',
        'sf_consultant_clients_onsite',
        'sf_consultant_clients_onsite_pt',
        'sf_consultant_clients_onsite_gt'
    )
);

DELETE FROM menus WHERE code IN (
    'sf_consultant_clients_digital_pt',
    'sf_consultant_clients_digital_gt',
    'sf_consultant_clients_onsite_pt',
    'sf_consultant_clients_onsite_gt',
    'sf_consultant_clients_digital',
    'sf_consultant_clients_onsite',
    'sf_consultant_my_clients'
);

-- +migrate Down
