Use layoffs;

select * from layoffs;

-- -- Data PreProcessing
-- 1.Remove Duplicates
-- 2. Standardize Data
-- 3. Remove Null Values / Blank values
-- 4. Remove Unwanted Columns

-- Create a duplicate Table

Create Table layoffs_stagging
Like layoffs;

select * from layoffs_stagging;

-- insert values into layoffs_stagging
insert layoffs_stagging
select * 
from layoffs;

select * 
from layoffs_stagging;

-- Create a Row ID
select * ,
ROW_NUMBER() OVER(
PARTITION BY company, total_laid_off, percentage_laid_off,`date`) AS row_num
from layoffs_stagging;
 
-- finding the duplicates

WITH duplicate_cte AS
(select * ,
ROW_NUMBER() OVER(
PARTITION BY company, location ,total_laid_off, percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_stagging)
select * from duplicate_cte
where row_num > 1;

-- Delete Duplicates

WITH duplicate_cte AS
(select * ,
ROW_NUMBER() OVER(
PARTITION BY company, location ,total_laid_off, percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_stagging)
DELETE from duplicate_cte
where row_num > 1;

-- we can't perfrom this easy method instead we deal it by creating a another table
CREATE TABLE `layoffs_stagging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoffs_stagging2;

-- insert values into layoffs_stagging
insert layoffs_stagging2
select * ,
ROW_NUMBER() OVER(
PARTITION BY company, location ,total_laid_off, percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_stagging;

select * from layoffs_stagging2;

SET SQL_SAFE_UPDATES = 0;

delete 
from layoffs_stagging2
where row_num > 1;

select * from layoffs_stagging2;

-- Standardization - Finding the issue in data and fixing

-- 1. remove the white spaces before the data
select company, trim(company) 
from layoffs_stagging2;

update layoffs_stagging2
set company = trim(company);
-- 
select * from layoffs_stagging2;

select industry 
from layoffs_stagging2;

select DISTINCT(industry) 
from layoffs_stagging2
order by 1;
-- we find crypto, cryptoCurrency, crypto Currency
select * 
from layoffs_stagging2
where industry LIKE 'Crypto%';

update layoffs_stagging2
set industry = 'Crypto'
where industry LIKE 'Crypto%';

select DISTINCT(industry) 
from layoffs_stagging2
order by 1;

-- yes we done it!!!
select DISTINCT(country) 
from layoffs_stagging2
where country like 'United States%'
order by 1;

-- United States , United States. is a issue here 
select DISTINCT(country) , trim(trailing '.' from country)
from layoffs_stagging2
where country like 'United States%'
order by 1;

update layoffs_stagging2
set country = trim(trailing '.' from country)
where country like 'United States%';

select DISTINCT(country) 
from layoffs_stagging2;

-- change date format
select `date`,
str_to_date (`date`,'%m/%d/%Y')
from layoffs_stagging2;

update layoffs_stagging2
set `date` = str_to_date (`date`,'%m/%d/%Y');

alter table layoffs_stagging2
modify column `date` DATE;

-- modified the date
-- working with null and blank values


select * 
from layoffs_stagging2
where total_laid_off is null;

select *
from layoffs_stagging2
where company = 'Airbnb';

update layoffs_stagging2
set industry = null
where industry = '';

select 
t1.industry , t2.industry
from layoffs_stagging2 t1
join layoffs_stagging2 t2
   on t1.company = t2.company
   and t1.location = t2.location
   where t1.industry is null or t1.industry = ''
   and t2.industry is not null;
   

update layoffs_stagging2 t1
join layoffs_stagging2 t2
   on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
   and t2.industry is not null;
   
select *
from layoffs_stagging2
where company like 'Bally%';

select *
from layoffs_stagging2;

SELECT * FROM layoffs_stagging2 
 WHERE total_laid_off IS NULL 
 AND percentage_laid_off IS NULL;
 
 ALTER TABLE layoffs_stagging2
 drop column row_num;
 
 Delete 
 From layoffs_stagging2
 where percentage_laid_off is null
 and total_laid_off is null;
 
 select *
from layoffs_stagging2;

 
 