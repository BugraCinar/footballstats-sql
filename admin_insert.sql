USE ONSIDE;

INSERT INTO admins (person_ID , is_super_admin)
VALUES (1,TRUE),
(2,FALSE),
(3,FALSE),
(4,TRUE),
(5,FALSE);
DELETE FROM admin WHERE person_ID = 1; -- bi düzenleme yapmam lazımdı
