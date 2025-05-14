--EDA (Exploratory Data Analysis)
-- 1.1. แพลตฟอร์มไหนมียอดขายรวมสูงสุด?
Select "Platform",SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
GROUP BY "Platform"
ORDER BY Total_Sales DESC;


-- 1.2. Top 3 Platform ของแต่ละภูมิภาค

WITH region_sales AS (
  SELECT 'NA' AS region, "Platform", SUM("NA_Sales") AS sales
  FROM suisuss.videogames_sales
  GROUP BY "Platform"
  UNION ALL
  SELECT 'JP', "Platform", SUM("JP_Sales")
  FROM suisuss.videogames_sales
  GROUP BY "Platform"
  UNION ALL
  SELECT 'EU', "Platform", SUM("EU_Sales")
  FROM suisuss.videogames_sales
  GROUP BY "Platform"
  UNION ALL
  SELECT 'Other', "Platform", SUM("Other_Sales")
  FROM suisuss.videogames_sales
  GROUP BY "Platform"
  UNION ALL
  SELECT 'Global', "Platform", SUM("Global_Sales")
  FROM suisuss.videogames_sales
  GROUP BY "Platform"
),
ranked AS (
  SELECT region, "Platform", sales,
         RANK() OVER(PARTITION BY region ORDER BY sales DESC) AS rk
  FROM region_sales
),
top3 AS (
  SELECT * FROM ranked WHERE rk <= 3
)
SELECT
  region,
  MAX(CASE WHEN rk = 1 THEN "Platform" END) AS rank1,
  MAX(CASE WHEN rk = 2 THEN "Platform" END) AS rank2,
  MAX(CASE WHEN rk = 3 THEN "Platform" END) AS rank3
FROM top3
GROUP BY region
ORDER BY region;
 
--1.3 Genre ที่ขายดีที่สุดของ platform PS2 ซึ่งเป็นplatform ขายดีที่สุด

Select "Genre" ,SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
WHERE "Platform" = 'PS2' 
GROUP BY "Genre"
ORDER BY Total_Sales DESC
-- พบว่าแนว Sport และ Action มียอดขายใกล้เคียงกันจึงตัดสินใจดูทั้ง 2 Genre

-- 1.4.1 หา Publisher ที่ทำเงินจากเกม Genre ดังกล่าวมากที่สุด
WITH PS_BEST_GENRE AS (
Select "Genre" ,SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
WHERE "Platform" = 'PS2' 
GROUP BY "Genre"
ORDER BY Total_Sales DESC
LIMIT 2
)

, Ac_SP AS (
SELECT "Publisher","Genre",SUM("Global_Sales") as total_sales 
From suisuss.videogames_sales
WHERE 
  "Genre" IN (
    SELECT "Genre" FROM PS_BEST_GENRE
  )
  AND "Genre" IS NOT NULL
GROUP BY "Publisher","Genre"
), Ac_SP2 AS ( 
SELECT * 
FROM 
(SELECT *,SUM(total_sales) OVER(PARTITION BY "Publisher") as sum_2 
FROM Ac_SP)
ORDER BY sum_2 desc,total_sales desc
)
SELECT *
FROM Ac_SP2;

-- 1.4.2 หาเกมที่ขายดีจาก Publisher นั้น

WITH PS_BEST_GENRE AS (
Select "Genre" ,SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
WHERE "Platform" = 'PS2' 
GROUP BY "Genre"
ORDER BY Total_Sales DESC
LIMIT 2
)

, Ac_SP AS (
SELECT "Publisher","Genre",SUM("Global_Sales") as total_sales 
From suisuss.videogames_sales
WHERE 
  "Genre" IN (
    SELECT "Genre" FROM PS_BEST_GENRE
  )
  AND "Genre" IS NOT NULL
GROUP BY "Publisher","Genre"
), Ac_SP2 AS ( 
SELECT * 
FROM 
(SELECT *,SUM(total_sales) OVER(PARTITION BY "Publisher") as sum_2 
FROM Ac_SP)
ORDER BY sum_2 desc,total_sales desc
)

-----Code เดิมจาก1.4.1

, Ac_SP3 AS (
  SELECT *
  FROM suisuss.videogames_sales
  WHERE "Publisher" IN (
    SELECT "Publisher" FROM Ac_SP2 LIMIT 5
  )
    AND "Genre" IN ('Sports', 'Action')
    AND "Platform" = 'PS2'
),
ranked_games AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY "Genre" ORDER BY "Global_Sales" DESC) AS rnk
  FROM Ac_SP3
)
SELECT "Name", "Genre", "Publisher", "Global_Sales"
FROM ranked_games
WHERE rnk = 1;

-- 1.4.3 หา Publisher ที่ทำเกม Genre ดังกล่าวออกมามากที่สุด
WITH PS_BEST_GENRE AS (
Select "Genre" ,SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
WHERE "Platform" = 'PS2' 
GROUP BY "Genre"
ORDER BY Total_Sales DESC
LIMIT 2
)

SELECT "Publisher",COUNT(DISTINCT "Name") as total_games 
FROM suisuss.videogames_sales
WHERE 
  "Genre" IN (
    SELECT "Genre" FROM PS_BEST_GENRE
  )
  AND "Genre" IS NOT NULL
GROUP BY "Publisher"
ORDER BY total_games DESC;


-- 2. ประเภทเกม (Genre) ไหนขายดีที่สุดทั่วโลก?

Select "Genre",SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
GROUP BY "Genre"
ORDER BY Total_Sales DESC

--  3. ยอดขายเกมเปลี่ยนไปอย่างไรตามปี? (แนว Trend)

Select "Year",SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
GROUP BY "Year"
ORDER BY "Year";

--พบว่ายอดขายจะเพิ่มขึ้นเรื่อยๆและพีคในช่วง2007-2011 หลังจากนั้นจึงค่อยลดลง

--  3.1  Top 100 game with most sale between 2007-2011

Select "Year",SUM("Global_Sales") as Total_Sales
From suisuss.videogames_sales
WHERE "Year" between 2007 and 2011
GROUP BY "Year"
ORDER BY "Year";

--  3.2  Top 100 game with most sale between 2007-2011

SELECT *  FROM suisuss.videogames_sales
WHERE "Year" BETWEEN 2007 AND 2011
ORDER BY "Global_Sales" DESC
LIMIT 100;

--  3.3  หาที่Publisher ขายดีที่สุดในช่วง 2007-2011

SELECT  "Platform", SUM("Global_Sales") as Total_Sales FROM suisuss.videogames_sales
WHERE "Year" BETWEEN 2007 AND 2011
GROUP BY "Platform"
ORDER BY Total_Sales DESC
LIMIT 100;

SELECT  "Publisher", SUM("Global_Sales") as Total_Sales FROM suisuss.videogames_sales
WHERE "Year" BETWEEN 2007 AND 2011
GROUP BY "Publisher"
ORDER BY Total_Sales DESC
LIMIT 100;



-- 3.3 เกมใน Top 100 เหล่านี้ เคยขายดีใน Region ไหนมากที่สุด
WITH TopGame07_11 AS(
SELECT *  FROM suisuss.videogames_sales
WHERE "Year" BETWEEN 2007 AND 2011
ORDER BY "Global_Sales" DESC
LIMIT 100
)

SELECT ROUND((sum_Other / sum_total) * 100, 2) AS percentsales_Others,
    ROUND((sum_JP / sum_total) * 100, 2) AS percentsales_JP,
    ROUND((sum_EU / sum_total) * 100, 2) AS percentsales_EU,
    ROUND((sum_NA / sum_total) * 100, 2) AS percentsales_NA
FROM(
SELECT SUM("Other_Sales") as sum_Other,SUM("JP_Sales") as sum_JP,
SUM("EU_Sales")as sum_EU,
SUM("NA_Sales")as sum_NA,SUM("Global_Sales") as sum_total
FROM suisuss.videogames_sales
where "Name" in (SELECT "Name" FROM TopGame07_11)
)

-- 3.4 Top 100 เหล่านี้ ส่วนใหญ่มาจาก Publisher เจ้าใด?
WITH TopGame07_11 AS(
SELECT *  FROM suisuss.videogames_sales
WHERE "Year" BETWEEN 2007 AND 2011
ORDER BY "Global_Sales" DESC
LIMIT 100
)
SELECT "Publisher",COUNT(*) as count_game
FROM TopGame07_11
GROUP BY  "Publisher"
ORDER BY count_game DESC; 

---4.Trend ของ Platform เจ้าใหญ่ (PS2, Wii, Xbox 360) 

--- หายอดขาย Global ต่อปี (SUM(Global_Sales)) สำหรับแต่ละ Platform และใช้ ใช้ Window Function ทำ Rolling 3-year average

CREATE TEMP TABLE IF NOT EXISTS platform_year_sales AS
SELECT "Platform" , "Year" , SUM("Global_Sales") as total_sales
FROM suisuss.videogames_sales
WHERE "Platform" IN ('PS2','Wii','X360') 
GROUP BY "Platform" , "Year";

SELECT "Platform" , "Year" , total_sales , ROUND(rolling_avg_sales,2)
FROM(
SELECT "Platform" , "Year" , total_sales ,
AVG(total_sales) OVER(
  PARTITION BY "Platform" 
  ORDER BY "Year" 
  ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
) as rolling_avg_sales
FROM platform_year_sales
ORDER BY "Platform" , "Year"
);
---2. Peak Year 

--หา ปีที่มียอดขายสูงสุด (MAX(Global_Sales)) ของแต่ละ Platform

--และหาปีที่ยอดขายเริ่มลดลง 20% จากปี peak

WITH PlatformYearSales AS (
SELECT "Platform" , "Year" , SUM("Global_Sales") as total_sales
FROM suisuss.videogames_sales
WHERE "Platform" IN ('PS2','Wii','X360') and "Year" != 0
GROUP BY "Platform" , "Year"
)

, Rolling3YearAvg AS (
SELECT "Platform" , "Year" , total_sales ,
AVG(total_sales) OVER(
  PARTITION BY "Platform" 
  ORDER BY "Year" 
  ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
) as rolling_avg_sales
FROM PlatformYearSales
)

, PeakRolling AS (
SELECT "Platform" , MAX(rolling_avg_sales) as peak_rolling
FROM Rolling3YearAvg
GROUP BY "Platform"
)

, RollingWithPeak AS (
SELECT r."Platform" , r."Year" , r.rolling_avg_sales , p.peak_rolling
FROM Rolling3YearAvg r
JOIN PeakRolling p
ON r."Platform" = p."Platform"
)

SELECT "Platform" , "Year" , ROUND(rolling_avg_sales, 2) as rolling_avg_sales, 
ROUND(peak_rolling, 2) as peak_rolling ,
ROUND((rolling_avg_sales/peak_rolling)*100 , 2) as percent_of_peak
FROM RollingWithPeak
WHERE (rolling_avg_sales / peak_rolling) <= 0.8
ORDER BY "Platform" , "Year";








