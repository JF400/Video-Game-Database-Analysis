-- Calls to game profit by region
call gameProfitByRegion(35, 'WD');
-- game_name         global_sales
-- Wii Sports        82.74
-- Super Mario Bros. 40.23
-- Mario Kart Wii.   35.82
call gameProfitByRegion(12, 'EU');
-- game_name         eu_sales
-- Wii Sports        29.02
-- Mario Kart Wii.   12.88
call gameProfitByRegion(10, 'JP');
-- game_name                       jp_sales
-- Pokemon Red/Pokemon Blue        10.22


-- Calls to genre ranking by region
call genreRankingByRegion('Sports', 'WD');
-- genre_name.  Rank_no
-- Action       1
-- Sports       2
-- Shooter      3
-- Role-Playing 4
-- Platform     5
-- Misc         6
-- Racing       7
-- Fighting     8
-- Simulation   9
-- Puzzle       10
-- Adventure    11
-- Strategy     12
call genreRankingByRegion('Role-playing', 'NA');
-- genre_name.  Rank_no
-- Action       1
-- Sports       2
-- Shooter      3
-- Platform     4
-- Misc         5
-- Racing       6
-- Role-playing 7
-- Fighting     8
-- Simulation   9
-- Puzzle       10
-- Adventure    11
-- Strategy     12
call genreRankingByRegion('Role-playing', 'JP');
-- genre_name.  Rank_no
-- Role-playing 1
-- Action       2
-- Sports       3
-- Platform     4
-- Misc         5
-- Fighting     6
-- Simulation   7
-- Puzzle       8
-- Racing       9
-- Adventure    10
-- Strategy     11
-- Shooter      12


-- Calls to published releases
call publishedReleases('Electronic Arts', 'Sports');
-- 560
call publishedReleases('Electronic Arts', 'Action');
-- 183


-- Calls to add new release
call addNewRelease('Foo Attacks', 'X360', 'Strategy', 'Stevenson Studios');

SELECT * FROM vg_publisher WHERE publisher_name = 'Stevenson Studios';
-- publisherID publisher_name
-- 1024        Stevenson Studios

SELECT * FROM vg_genre WHERE genre_name = 'Strategy';
-- genreID genre_name
-- 12      Strategy

SELECT * FROM vg_platform WHERE platform_name = 'X360';
-- platformID platform_name
-- 5          X360

SELECT * FROM vg_game WHERE game_name = 'Foo Attacks';
-- gameID    game_name    genreID
-- 32768     Foo Attacks  12

SELECT * FROM vg_gameplatpubyear WHERE gameID = (SELECT gameID FROM vg_game WHERE game_name = 'Foo Attacks');
-- ReleaseID gameID platformID publisherID year na_sales eu_sales jp_sales other_sales global_sales
-- 32768     32768  5          1024        NULL 0        0        0        0           0
