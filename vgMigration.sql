use testdb;

-- First, wer're looking for duplicate rows in vg_csv. --
SELECT name, platform, year, genre, publisher, na_sales, eu_sales,
jp_sales, other_sales, global_sales, COUNT(*) FROM vg_csv
GROUP BY name, platform, year, genre, publisher, na_sales, eu_sales,
jp_sales, other_sales, global_sales
HAVING COUNT(*) > 1;
-- We find that the game 'Wii de Asobu: Metroid Prime' is duplicated. Thus, we'll keep the first instance --
-- and drop the second instance. --
SELECT ranking FROM vg_csv WHERE name = 'Wii de Asobu: Metroid Prime';
DELETE FROM vg_csv WHERE ranking = 15002;

-- Next, we'll check for duplicate rows in a more clever way. --
SELECT name, platform, year, genre, publisher, COUNT(*) FROM vg_csv
GROUP BY name, platform, year, genre, publisher
HAVING COUNT(*) > 1;
-- We find that there are two rows with the same name ('Madden NFL 13'), platform, year, genre and publisher. --
SELECT * FROM vg_csv WHERE name = 'Madden NFL 13';
-- Looking into it further we find that these two instances of Madden NFL 13 only differ in their sales data. --
-- We'll treat these two instances as the same game and keep the --
-- one with the higher sales and drop the one with the lower sales. --
DELETE FROM vg_csv WHERE ranking = 16130;
-- With that, we've accounted for all of the duplicates in vg_csv. --

-- We're also going to add an vg_csvID column to vg_csv to facilatate inserting data into vg_gameplatpubyear later. --
CREATE TABLE backup_vg_csv LIKE vg_csv;
INSERT INTO backup_vg_csv SELECT * FROM vg_csv;
TRUNCATE TABLE vg_csv;
ALTER TABLE vg_csv ADD vg_csvID INT AUTO_INCREMENT PRIMARY KEY FIRST;
INSERT INTO vg_csv (ranking, name, platform, year, genre, publisher, na_sales, eu_sales, jp_sales, other_sales, global_sales)
SELECT ranking, name, platform, year, genre, publisher, na_sales, eu_sales, jp_sales, other_sales, global_sales
FROM backup_vg_csv;
DROP TABLE IF EXISTS backup_vg_csv;
SELECT * FROM vg_csv;

-- Now, we'll start creating our tables and inserting data into them. --
DROP TABLE IF EXISTS vg_gameplatpubyear;
DROP TABLE IF EXISTS vg_game;
DROP TABLE IF EXISTS vg_genre;
DROP TABLE IF EXISTS vg_platform;
DROP TABLE IF EXISTS vg_publisher;

CREATE TABLE vg_publisher (
	publisherID INT NOT NULL AUTO_INCREMENT,
    publisher_name VARCHAR(200) NOT NULL,
    CONSTRAINT vg_publisher_publisherID_PK PRIMARY KEY (publisherID)
);

CREATE TABLE vg_platform (
	platformID INT NOT NULL AUTO_INCREMENT,
    platform_name VARCHAR(30) NOT NULL,
    CONSTRAINT vg_platform_platformID_PK PRIMARY KEY (platformID)
);

CREATE TABLE vg_genre (
	genreID INT NOT NULL AUTO_INCREMENT,
    genre_name VARCHAR(30) NOT NULL,
    CONSTRAINT vg_genre_genreID_PK PRIMARY KEY (genreID)
);

CREATE TABLE vg_game (
	gameID INT NOT NULL AUTO_INCREMENT,
    game_name VARCHAR(200) NOT NULL,
    genreID INT NOT NULL,
    CONSTRAINT vg_game_gameID_PK PRIMARY KEY (gameID),
    CONSTRAINT vg_game_genreID_FK FOREIGN KEY (genreID) REFERENCES vg_genre(genreID)
);

CREATE TABLE vg_gameplatpubyear (
	releaseID INT NOT NULL AUTO_INCREMENT,
    gameID INT NOT NULL,
    platformID INT NOT NULL,
    publisherID INT NOT NULL,
    year YEAR,
    na_sales DOUBLE NOT NULL,
    eu_sales DOUBLE NOT NULL,
    jp_sales DOUBLE NOT NULL,
    other_sales DOUBLE NOT NULL,
    global_sales DOUBLE NOT NULL,
    CONSTRAINT vg_gameplatpubyear_releaseID_PK PRIMARY KEY (releaseID),
    CONSTRAINT vg_gameplatpubyear_gameID_FK FOREIGN KEY (gameID) REFERENCES vg_game(gameID),
    CONSTRAINT vg_gameplatpubyear_platformID_FK FOREIGN KEY (platformID) REFERENCES vg_platform(platformID),
    CONSTRAINT vg_gameplatpubyear_publisherID_FK FOREIGN KEY (publisherID) REFERENCES vg_publisher(publisherID)
);

INSERT INTO vg_publisher (publisher_name)
SELECT DISTINCT(publisher) FROM vg_csv;

INSERT INTO vg_platform (platform_name)
SELECT DISTINCT(platform) FROM vg_csv;

INSERT INTO vg_genre (genre_name)
SELECT DISTINCT(genre) FROM vg_csv;

INSERT INTO vg_game (game_name, genreID)
SELECT name, genreID FROM vg_csv INNER JOIN vg_genre
ON vg_csv.genre = vg_genre.genre_name;

INSERT INTO vg_gameplatpubyear (gameID, platformID, publisherID, year, na_sales, eu_sales, jp_sales, other_sales, global_sales)
SELECT gameID, platformID, publisherID,
(CASE WHEN year = 'N/A' THEN NULL ELSE year END),
na_sales, eu_sales, jp_sales, other_sales, global_sales
FROM vg_game INNER JOIN vg_csv ON vg_game.gameID = vg_csv.vg_csvID
INNER JOIN vg_platform ON vg_csv.platform = vg_platform.platform_name
INNER JOIN vg_publisher ON vg_csv.publisher = vg_publisher.publisher_name;