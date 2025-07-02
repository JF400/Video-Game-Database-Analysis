DELIMITER $$
CREATE PROCEDURE gameProfitByRegion(IN min_profit DOUBLE,IN region CHAR(2))
BEGIN
	IF region = 'WD' THEN
		SELECT game_name, global_sales
		FROM vg_game INNER JOIN vg_gameplatpubyear
		ON vg_game.gameID = vg_gameplatpubyear.gameID
		WHERE global_sales > min_profit;
	ELSEIF region = 'NA' THEN
		SELECT game_name, na_sales
		FROM vg_game INNER JOIN vg_gameplatpubyear
		ON vg_game.gameID = vg_gameplatpubyear.gameID
		WHERE na_sales > min_profit;
	ELSEIF region = 'EU' THEN
		SELECT game_name, eu_sales
		FROM vg_game INNER JOIN vg_gameplatpubyear
		ON vg_game.gameID = vg_gameplatpubyear.gameID
		WHERE eu_sales > min_profit;
	ELSEIF region = 'JP' THEN
		SELECT game_name, jp_sales
		FROM vg_game INNER JOIN vg_gameplatpubyear
		ON vg_game.gameID = vg_gameplatpubyear.gameID
		WHERE jp_sales > min_profit;
	END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE genreRankingByRegion(IN genre VARCHAR(30),IN region CHAR(2))
BEGIN
	IF region = 'WD' THEN
		SELECT genre_name,
        RANK () OVER (
        ORDER BY SUM(global_sales) DESC
        ) AS Rank_no
        FROM vg_genre INNER JOIN vg_game ON vg_genre.genreID = vg_game.genreID
        INNER JOIN vg_gameplatpubyear ON vg_game.gameID = vg_gameplatpubyear.gameID
        GROUP BY genre_name;
	ELSEIF region = 'NA' THEN
		SELECT genre_name,
        RANK () OVER (
        ORDER BY SUM(na_sales) DESC
        ) AS Rank_no
        FROM vg_genre INNER JOIN vg_game ON vg_genre.genreID = vg_game.genreID
        INNER JOIN vg_gameplatpubyear ON vg_game.gameID = vg_gameplatpubyear.gameID
        GROUP BY genre_name;
	ELSEIF region = 'EU' THEN
		SELECT genre_name,
        RANK () OVER (
        ORDER BY SUM(eu_sales) DESC
        ) AS Rank_no
        FROM vg_genre INNER JOIN vg_game ON vg_genre.genreID = vg_game.genreID
        INNER JOIN vg_gameplatpubyear ON vg_game.gameID = vg_gameplatpubyear.gameID
        GROUP BY genre_name;
	ELSEIF region = 'JP' THEN
		SELECT genre_name,
        RANK () OVER (
        ORDER BY SUM(jp_sales) DESC
        ) AS Rank_no
        FROM vg_genre INNER JOIN vg_game ON vg_genre.genreID = vg_game.genreID
        INNER JOIN vg_gameplatpubyear ON vg_game.gameID = vg_gameplatpubyear.gameID
        GROUP BY genre_name;
	END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE publishedReleases(IN p_name VARCHAR(200),IN g_name VARCHAR(30))
BEGIN
	SELECT COUNT(*) FROM vg_gameplatpubyear
    INNER JOIN vg_game ON vg_gameplatpubyear.gameID = vg_game.gameID
    INNER JOIN vg_publisher ON vg_gameplatpubyear.publisherID = vg_publisher.publisherID
    INNER JOIN vg_genre ON vg_game.genreID = vg_genre.genreID
    WHERE publisher_name = p_name AND genre_name = g_name;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE addNewRelease(IN game VARCHAR(200),IN plat VARCHAR(30),IN genre VARCHAR(30),IN publisher VARCHAR(200))
BEGIN
	DECLARE game_ID INT;
    DECLARE platform_ID INT DEFAULT (SELECT platformID FROM vg_platform WHERE platform_name = plat);
    DECLARE publisher_ID INT DEFAULT (SELECT publisherID FROM vg_publisher WHERE publisher_name = publisher);
    DECLARE genre_ID INT DEFAULT (SELECT genreID FROM vg_genre WHERE genre_name = genre);
    IF (IF(EXISTS(SELECT * FROM vg_platform WHERE platform_name = plat),FALSE,TRUE)) OR (IF(EXISTS(SELECT * FROM vg_publisher WHERE publisher_name = publisher),FALSE,TRUE)) OR (IF(EXISTS(SELECT * FROM vg_genre WHERE genre_name = genre),FALSE,TRUE)) THEN
		IF IF(EXISTS(SELECT * FROM vg_platform WHERE platform_name = plat),FALSE,TRUE) THEN
			INSERT INTO vg_platform (platform_name) VALUES (plat);
			SET platform_ID = LAST_INSERT_ID();
		END IF;
        IF IF(EXISTS(SELECT * FROM vg_publisher WHERE publisher_name = publisher),FALSE,TRUE) THEN
			INSERT INTO vg_publisher (publisher_name) VALUES (publisher);
			SET publisher_ID = LAST_INSERT_ID();
		END IF;
        IF IF(EXISTS(SELECT * FROM vg_genre WHERE genre_name = genre),FALSE,TRUE) THEN
			INSERT INTO vg_genre (genre_name) VALUES (genre);
			SET genre_ID = LAST_INSERT_ID();
		END IF;
		INSERT INTO vg_game (game_name, genreID) VALUES (game, genre_ID);
        SET game_ID = LAST_INSERT_ID();
        INSERT INTO vg_gameplatpubyear (gameID, platformID, publisherID, year, na_sales, eu_sales, jp_sales, other_sales, global_sales)
        VALUES (game_ID, platform_ID, publisher_ID, NULL, 0, 0, 0, 0, 0);
        SELECT 'DATA WAS ADDED';
	END IF;
END $$
DELIMITER ;
