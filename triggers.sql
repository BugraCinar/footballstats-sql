USE ONSIDE;

DELIMITER //

CREATE TRIGGER before_fav_teams_insert
BEFORE INSERT ON Fav_Teams
FOR EACH ROW
BEGIN
    DECLARE admin_check INT;
    SELECT COUNT(*) INTO admin_check FROM Admins WHERE person_ID = NEW.person_ID;
    IF admin_check > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Adminler favori takım ekleyemez.';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER before_fav_team_insert_no_same_team
BEFORE INSERT ON Fav_Teams
FOR EACH ROW
BEGIN
  DECLARE count INT;
  SELECT COUNT(*) INTO count FROM Fav_Teams
  WHERE person_ID = NEW.person_ID AND team_ID = NEW.team_ID;
  IF count > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'bu kişinin listesinde bu takım zaten var.';
  END IF;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER before_admin_insert
BEFORE INSERT ON Admins
FOR EACH ROW
BEGIN
    DECLARE user_check INT;
    SELECT COUNT(*) INTO user_check FROM Users WHERE person_ID = NEW.person_ID;
    IF user_check > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Zaten kayıtlı bir user, admin olamaz.';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER before_user_insert
BEFORE INSERT ON Users
FOR EACH ROW
BEGIN
    DECLARE admin_check INT;
    SELECT COUNT(*) INTO admin_check FROM Admins WHERE person_ID = NEW.person_ID;
    IF admin_check > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Zaten kayıtlı bir admin, user olamaz.';
    END IF;
END //

DELIMITER ;




DELIMITER //

CREATE TRIGGER before_match_detail_insert
BEFORE INSERT ON Match_Detail
FOR EACH ROW
BEGIN
    SET NEW.total_score = NEW.home_goal + NEW.away_goal;
    SET NEW.total_foul = NEW.home_foul + NEW.away_foul;
END // -- totalleri ayarla

DELIMITER ;

DELIMITER //

CREATE TRIGGER update_matches_and_teams_after_match_detail_insert
AFTER INSERT ON Match_Detail
FOR EACH ROW
BEGIN
	DECLARE home_goals INT;
    DECLARE away_goals INT;
    DECLARE match_result ENUM('home win', 'away win', 'draw');
   
    -- skorları al
    SET home_goals = (SELECT SUM(home_goal) FROM Match_Detail WHERE match_ID = NEW.match_ID);
    SET away_goals = (SELECT SUM(away_goal) FROM Match_Detail WHERE match_ID = NEW.match_ID);

    -- maç sonucu belirle
    IF home_goals > away_goals THEN
        SET match_result = 'home win';
    ELSEIF home_goals < away_goals THEN
        SET match_result = 'away win';
    ELSE
        SET match_result = 'draw';
    END IF;

    -- maç tablosunu güncelle
    UPDATE Matches
    SET home_score = home_goals,
        away_score = away_goals,
        match_situation = 'played',
        match_result = match_result
    WHERE match_ID = NEW.match_ID;
  
END //

DELIMITER ;


DELIMITER //
CREATE PROCEDURE update_team_stats5(IN match_id INT)
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE a_home_team_id INT;
  DECLARE a_away_team_id INT;
  DECLARE a_match_result VARCHAR(50);
  DECLARE cur CURSOR FOR SELECT home_team_ID, away_team_ID, match_result FROM Matches WHERE match_ID = match_id;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO a_home_team_id, a_away_team_id, a_match_result;
    IF done THEN
      LEAVE read_loop;
    END IF;

    IF a_match_result = 'home win' THEN
        UPDATE Team SET point = point + 3, matches_played = matches_played + 1, matches_won = matches_won + 1 WHERE team_ID = a_home_team_id;
        UPDATE Team SET matches_played = matches_played + 1, matches_lost = matches_lost + 1 WHERE team_ID = a_away_team_id;
    ELSEIF a_match_result = 'away win' THEN
        UPDATE Team SET point = point + 3, matches_played = matches_played + 1, matches_won = matches_won + 1 WHERE team_ID = a_away_team_id;
        UPDATE Team SET matches_played = matches_played + 1, matches_lost = matches_lost + 1 WHERE team_ID = a_home_team_id;
    ELSEIF a_match_result = 'draw' THEN
        UPDATE Team SET point = point + 1, matches_played = matches_played + 1, matches_draw = matches_draw + 1 WHERE team_ID = a_home_team_id;
        UPDATE Team SET point = point + 1, matches_played = matches_played + 1, matches_draw = matches_draw + 1 WHERE team_ID = a_away_team_id;
    END IF;
  END LOOP;
  CLOSE cur;
END //  -- takımları updateleme
DELIMITER ;

CALL update_team_stats5(1);

-- ---------------------
SET @rank := 0;
SET @prev_league := NULL;

UPDATE Team t
SET ranking = @rank := IF(@prev_league = league_ID, @rank + 1, IF(@prev_league := league_ID, 1, 1))
ORDER BY league_ID, point DESC, matches_won DESC; -- ranking oluşturma

-- --------------------------

 DROP TRIGGER update_matches_and_teams_after_match_detail_insert;
 
 DROP PROCEDURE  update_team_stats3;
 
 SHOW CREATE PROCEDURE update_team_stats;
SHOW TRIGGERS;

