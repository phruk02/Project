-- Cleaning videogames_sales dataset
SELECT * FROM suisuss.videogames_sales
LIMIT 100;

-- check ว่าในdataset มีค่าแปลกๆไหม 

SELECT MAX("Year"), MIN("Year")
FROM suisuss.videogames_sales;

SELECT MAX("Global_Sales"), MIN("Global_Sales")
FROM suisuss.videogames_sales;

SELECT MAX("NA_Sales"), MIN("NA_Sales")
FROM suisuss.videogames_sales;

SELECT MAX("JP_Sales"), MIN("JP_Sales")
FROM suisuss.videogames_sales;

SELECT MAX("EU_Sales"), MIN("EU_Sales")
FROM suisuss.videogames_sales;

SELECT MAX("Other_Sales"), MIN("Other_Sales")
FROM suisuss.videogames_sales;

-- check แถวที่ซ้ำ

SELECT COUNT(*)
FROM suisuss.videogames_sales;
-- 16598
SELECT  COUNT(*)
FROM 
(SELECT DISTINCT *
FROM suisuss.videogames_sales
);
-- 16597
--ดู Row ที่่ซ้ำ
SELECT * 
FROM
(SELECT *,ROW_NUMBER() OVER(PARTITION BY "EU_Sales","JP_Sales","Other_Sales","NA_Sales","Global_Sales","Year","Name",
"Platform","Genre","Publisher") as row_n
FROM suisuss.videogames_sales)
WHERE row_n > 1;

-- ลบแถวซ้ำ
CREATE TABLE videogames_sales_cleaned AS
SELECT DISTINCT * FROM suisuss.videogames_sales;

DROP TABLE suisuss.videogames_sales;

ALTER TABLE videogames_sales_cleaned RENAME TO videogames_sales;


ALTER TABLE public.videogames_sales SET SCHEMA "suisuss";

SELECT Distinct "Genre"
FROM suisuss.videogames_sales
order by "Genre";

SELECT * FROM suisuss.videogames_sales WHERE "Name" ~ '[^a-zA-Z0-9]';

-- finding null col
SELECT count(*)
FROM suisuss.videogames_sales
where "Name" is NULL;


SELECT
  COUNT(*) AS total_rows,
  COUNT(*) FILTER (WHERE  "Platform" IS NULL) AS null1Platform,
  COUNT(*) FILTER (WHERE "Global_Sales" IS NULL) AS nullGlobal,
  COUNT(*) FILTER (WHERE "NA_Sales" IS NULL) AS nullNA,
  COUNT(*) FILTER (WHERE "EU_Sales" IS NULL) AS nullEU,
  COUNT(*) FILTER (WHERE "JP_Sales" IS NULL) AS nullJP,
  COUNT(*) FILTER (WHERE "Other_Sales" IS NULL) AS nullOther,
  COUNT(*) FILTER (WHERE "Year" IS NULL) AS nullYear,
  COUNT(*) FILTER (WHERE "Genre" IS NULL) AS nullYear,
   COUNT(*) FILTER (WHERE "Publisher" IS NULL) AS nullPublisher
FROM suisuss.videogames_sales;

SELECT *
FROM suisuss.videogames_sales
where "Year" is NULL;

--replace nill year with 0
UPDATE suisuss.videogames_sales
SET "Year" = 0
where "Year" IS NULL;

--replace nill year with 0
UPDATE suisuss.videogames_sales
SET "Publisher" = 'N/A'
where "Year" IS NULL;

--FINISHED


