
USE ONSIDE;

-- Tablolar
CREATE TABLE Person (
    person_ID INT PRIMARY KEY,
    username VARCHAR(100),
    password VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE Sport_Branch (
    sport_ID INT PRIMARY KEY,
    sport_name VARCHAR(20)
);

CREATE TABLE League (
    league_ID INT PRIMARY KEY,
    sport_ID INT,
    season INT, -- string cevircektim ugrasmiyim dedim
    FOREIGN KEY (sport_ID) REFERENCES Sport_Branch(sport_ID)
);

CREATE TABLE Fixture (
    fixture_ID INT PRIMARY KEY,
    league_ID INT,
    season INT,
    week_total INT,
    FOREIGN KEY (league_ID) REFERENCES League(league_ID)
);

CREATE TABLE Team (
    team_ID INT PRIMARY KEY,
    league_ID INT,
    team_name VARCHAR(50),
    point INT,
    ranking INT,
    matches_played INT,
    matches_won INT,
    matches_lost INT,
    matches_draw INT,
    FOREIGN KEY (league_ID) REFERENCES League(league_ID)
);

CREATE TABLE Player (
    player_ID INT PRIMARY KEY,
    team_ID INT,
    player_name VARCHAR(50),
    player_last_name VARCHAR(50),
    birthdate DATE,
    jersey_num INT,
    position VARCHAR(10),
    FOREIGN KEY (team_ID) REFERENCES Team(team_ID)
);

CREATE TABLE Matches (
    match_ID INT PRIMARY KEY,
    home_team_ID INT,
    away_team_ID INT,
    league_ID INT,
    match_date DATE,
    start_time TIME,
    week_num INT,
    home_score INT,
    away_score INT,
    match_situation ENUM('planned', 'played', 'cancelled') DEFAULT ('planned') NOT NULL, 
    match_result ENUM('home win', 'away win', 'draw'),     
    FOREIGN KEY (home_team_ID) REFERENCES Team(team_ID),
    FOREIGN KEY (away_team_ID) REFERENCES Team(team_ID),
    FOREIGN KEY (league_ID) REFERENCES League(league_ID)

);

CREATE TABLE Match_Detail (
    detail_ID INT PRIMARY KEY,
    match_ID INT,
    total_score INT,
    total_foul INT,
    home_foul INT,
    away_foul INT,
    yellow_card INT,
    red_card INT,
    home_goal INT,
    away_goal INT,
    FOREIGN KEY (match_ID) REFERENCES Matches(match_ID)
    );

CREATE TABLE User (
    person_ID INT PRIMARY KEY,
    is_active BOOLEAN,
    FOREIGN KEY (person_ID) REFERENCES Person(person_ID)
);

CREATE TABLE Admin (
    person_ID INT PRIMARY KEY,
    is_super_admin BOOLEAN,
    FOREIGN KEY (person_ID) REFERENCES Person(person_ID)
);

CREATE TABLE Fav_Teams (
    fav_ID INT PRIMARY KEY,
    person_ID INT,
    team_ID INT,
    team_name VARCHAR(50),
    FOREIGN KEY (person_ID) REFERENCES Person(person_ID),
    FOREIGN KEY (team_ID) REFERENCES Team(team_ID)
);



ALTER TABLE League
ADD COLUMN league_name VARCHAR(100) NOT NULL;

ALTER TABLE Admin
RENAME TO Admins;

ALTER TABLE User
RENAME TO Users;

DROP TABLE Match_Detail;

