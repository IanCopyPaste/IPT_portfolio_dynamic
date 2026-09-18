-- Sample accounts so the admin dashboard has something to show: sign-ups spread over the last year,
-- a few inactive accounts, a mix of recent and old sign-ins, and optional fields left blank on some.
-- Run 001_admin_dashboard.sql first. Safe to run more than once: a username that already exists is
-- skipped. Every account signs in with the password Sample#2026.

USE IPT_portfolio;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;
GO

-- PBKDF2-SHA256 hash of "Sample#2026", in PasswordHasher's format. T-SQL can't compute one.
DECLARE @hash varchar(200) = '100000.8jNj4/rwBF+S9t3gfzcjMw==.e6qsQcJg9nb9BfttDkYje1Zi6uFPhmnPmZ4BSearN+o=';
DECLARE @now datetime2(0) = SYSUTCDATETIME();

-- joined / last_seen are days before now; a NULL last_seen means the account never signed in.
DECLARE @sample TABLE (
    first_name varchar(50), middle_name varchar(50), last_name varchar(50), suffix varchar(15),
    address varchar(200), email varchar(254), sms varchar(11), username varchar(40),
    status varchar(10), joined int, last_seen int NULL);

INSERT INTO @sample VALUES
('Juan',      'Santos',   'Dela Cruz',  'Jr.', 'Quezon City, Metro Manila',     'juan.delacruz@example.com',   '09171234501', 'juan.delacruz',   'active',   350, 2),
('Maria',     'Reyes',    'Clara',      NULL,  'Manila, Metro Manila',          'maria.clara@example.com',     '09181234502', 'mariaclara',      'active',   340, 12),
('Jose',      NULL,       'Rizal',      NULL,  'Calamba, Laguna',               'jose.rizal@example.com',      NULL,          'joserizal',       'active',   331, 45),
('Andres',    'de Castro','Bonifacio',  NULL,  'Tondo, Manila',                 NULL,                          '09191234504', 'andres_b',        'inactive', 322, 200),
('Gabriela',  NULL,       'Silang',     NULL,  'Vigan, Ilocos Sur',             'gabriela.silang@example.com', NULL,          'gab.silang',      'active',   310, 5),
('Apolinario','Maranan',  'Mabini',     NULL,  'Tanauan, Batangas',             'a.mabini@example.com',        '09201234506', 'apolinario_m',    'active',   298, NULL),
('Melchora',  NULL,       'Aquino',     NULL,  'Caloocan, Metro Manila',        'tandang.sora@example.com',    NULL,          'tandang_sora',    'active',   287, 60),
('Emilio',    'Famy',     'Aguinaldo',  NULL,  'Kawit, Cavite',                 'emilio.aguinaldo@example.com','09211234508', 'emilio_a',        'active',   270, 20),
('Antonio',   NULL,       'Luna',       NULL,  'Binondo, Manila',               NULL,                          NULL,          'heneral_luna',    'inactive', 262, 150),
('Gregorio',  'Hilario',  'del Pilar',  NULL,  'Bulacan, Bulacan',              'goyo@example.com',            '09221234510', 'goyo.delpilar',   'active',   250, 33),
('Marcelo',   'Hilario',  'del Pilar',  NULL,  'Bulakan, Bulacan',              'plaridel@example.com',        NULL,          'plaridel',        'active',   241, 95),
('Teresa',    NULL,       'Magbanua',   NULL,  'Pototan, Iloilo',               'teresa.m@example.com',        '09231234512', 'teresa_magbanua', 'active',   229, 8),
('Diego',     NULL,       'Silang',     NULL,  'Pangasinan',                    NULL,                          '09241234513', 'diego.silang',    'active',   215, NULL),
('Josefa',    NULL,       'Llanes Escoda', NULL, 'Dingras, Ilocos Norte',       'josefa.escoda@example.com',   NULL,          'josefa_escoda',   'active',   203, 17),
('Lapu',      NULL,       'Lapu',       NULL,  'Mactan, Cebu',                  'lapulapu@example.com',        '09251234515', 'lapulapu',        'active',   190, 1),
('Francisco', NULL,       'Balagtas',   NULL,  'Bigaa, Bulacan',                'balagtas@example.com',        NULL,          'kiko.balagtas',   'active',   178, 70),
('Trinidad',  NULL,       'Tecson',     NULL,  'San Miguel, Bulacan',           NULL,                          '09261234517', 'trinidad_t',      'inactive', 166, 120),
('Graciano',  'Lopez',    'Jaena',      NULL,  'Jaro, Iloilo',                  'g.lopezjaena@example.com',    '09271234518', 'graciano_lj',     'active',   152, 26),
('Mariano',   NULL,       'Ponce',      NULL,  'Baliuag, Bulacan',              'mariano.ponce@example.com',   NULL,          'mariano_ponce',   'active',   140, NULL),
('Macario',   NULL,       'Sakay',      NULL,  'Tondo, Manila',                 NULL,                          NULL,          'macario.sakay',   'active',   127, 40),
('Paciano',   NULL,       'Rizal',      NULL,  'Calamba, Laguna',               'paciano.rizal@example.com',   '09281234521', 'paciano_r',       'active',   115, 3),
('Leona',     NULL,       'Florentino', NULL,  'Vigan, Ilocos Sur',             'leona.f@example.com',         NULL,          'leona_florentino','active',   101, 14),
('Juan',      NULL,       'Luna',       NULL,  'Badoc, Ilocos Norte',           'juan.luna@example.com',       '09291234523', 'juanluna_art',    'active',    90, 9),
('Fernando',  NULL,       'Amorsolo',   NULL,  'Paco, Manila',                  'amorsolo@example.com',        NULL,          'f.amorsolo',      'active',    78, NULL),
('Corazon',   'Cojuangco','Aquino',     NULL,  'Tarlac City, Tarlac',           'cory@example.com',            '09301234525', 'cory.aquino',     'active',    66, 6),
('Benigno',   'Simeon',   'Aquino',     'III', 'Quezon City, Metro Manila',     'noynoy@example.com',          NULL,          'noynoy_a',        'inactive',  55, 50),
('Ramon',     'del Fierro','Magsaysay', NULL,  'Iba, Zambales',                 'ramon.magsaysay@example.com', '09311234527', 'ramon_m',         'active',    44, 4),
('Carlos',    'Polistico','Garcia',     NULL,  'Talibon, Bohol',                NULL,                          '09321234528', 'carlos.garcia',   'active',    33, 11),
('Manuel',    'Luis',     'Quezon',     NULL,  'Baler, Aurora',                 'mlq@example.com',             NULL,          'manuel.quezon',   'active',    25, 1),
('Sergio',    'Osmena',   'Suico',      'Sr.', 'Cebu City, Cebu',               'sergio.osmena@example.com',   '09331234530', 'sergio_osmena',   'active',    18, NULL),
('Lorenzo',   NULL,       'Ruiz',       NULL,  'Binondo, Manila',               'lorenzo.ruiz@example.com',    NULL,          'san_lorenzo',     'active',    11, 2),
('Pedro',     NULL,       'Calungsod',  NULL,  'Ginatilan, Cebu',               'pedro.calungsod@example.com', '09341234532', 'pedro_calungsod', 'active',     6, 0),
('Hidilyn',   'Francisco','Diaz',       NULL,  'Zamboanga City',                'hidilyn@example.com',         '09351234533', 'hidilyn.diaz',    'active',     3, 0),
('Carlos',    'Edriel',   'Yulo',       NULL,  'Malate, Manila',                'caloy.yulo@example.com',      NULL,          'caloy_yulo',      'active',     1, NULL);

INSERT INTO users (first_name, middle_name, last_name, suffix, address, email, sms, username, password_hash,
                   status, created_at, last_login_at)
SELECT s.first_name, s.middle_name, s.last_name, s.suffix, s.address, s.email, s.sms, s.username, @hash,
       s.status, DATEADD(day, -s.joined, @now),
       CASE WHEN s.last_seen IS NULL THEN NULL ELSE DATEADD(hour, -3, DATEADD(day, -s.last_seen, @now)) END
FROM @sample s
WHERE NOT EXISTS (SELECT 1 FROM users u WHERE u.username = s.username);

PRINT CAST(@@ROWCOUNT AS varchar(10)) + ' sample account(s) added.';
GO
