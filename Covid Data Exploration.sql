select *
from portfolioProject1.covidDeaths 
order by 3,4;

-- select *
-- from portfolioProject1.NewTable
-- order by 3,4;

SELECT location, date, total_cases , new_cases , total_deaths , population 
from portfolioProject1.covidDeaths
order by 1,2;
 
-- Looking at total cases vs total deaths, shows probability of dying if you contract covid in your country
SELECT  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from portfolioProject1.covidDeaths
WHERE location LIKE '%czech%'
order by 1, 2;

-- Looking at  total cases vs population
SELECT  location, date, total_cases, population, (total_cases/population) *100 as PercentPopulationInfected
from portfolioProject1.covidDeaths 
WHERE location LIKE '%czech%'
order by 1, 2;

-- Looking at coutries with highest infection rate compared to population
SELECT  location, MAX(total_cases) as highestInfectionCount, population, MAX((total_cases/population)) *100 as percentPopulationInfected
from portfolioProject1.covidDeaths 
group by location ,population 
order by PercentPopulationInfected DESC ;

-- Showing countries with highest death count per population
SELECT  location, MAX(total_deaths) as totalDeathCount, population, MAX((total_deaths/population)) *100 as percentPopulationDeaths
from portfolioProject1.covidDeaths 
group by location ,population 
order by percentPopulationDeaths DESC ;

-- total deaths by continent 
SELECT  continent , MAX(total_deaths) as totalDeathCount
from portfolioProject1.covidDeaths  
group by continent 
order by totalDeathCount DESC ;
-- by location - continent
SELECT  location , MAX(total_deaths) as totalDeathCount
from portfolioProject1.covidDeaths 
-- where continent = ''
group by location  
order by totalDeathCount DESC ;

-- global numbers
SELECT SUM(new_cases) as total_cases , SUM(new_deaths) as total_deaths , SUM(new_deaths)/SUM(new_cases)*100 as deathPercentage  -- , total_deaths, (total_deaths/total_cases)*100 as deathPercentage 
from portfolioProject1.covidDeaths
group by date
order by 1, 2;

-- Total population and vaccination


SELECT cd.continent , cd.location , cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(cv.new_vaccinations, INT)) 
	OVER (PARTITION by cd.location order by cd.location, cd.date)  as rollingPeopleVaccinated
from portfolioProject1.covidDeaths cd 
join portfolioProject1.covidVaccination cv 
	on cd.location  = cv.location 
	and cd.date = cv.date
where cd.continent != ''
-- order by 2,3;



-- USE CTE - working

with PopvsVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated) as
(
SELECT cd.continent , cd.location , cd.date, cd.population, cv.new_vaccinations, SUM(cv.new_vaccinations) 
	OVER (PARTITION by cd.location order by cd.location, cd.date)  as rollingPeopleVaccinated
from portfolioProject1.covidDeaths cd 
join portfolioProject1.covidVaccination cv 
	on cd.location  = cv.location 
	and cd.date = cv.date
where cd.continent != ''
-- LIMIT 2000,100
) 
SELECT *, (rollingPeopleVaccinated/population)*100
from PopvsVac;

-- TEMP TABLE

DROP Table if exists PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(continent varchar(255),
location varchar(255),
date datetime,
population INT,
new_vaccinations INT,
-- rollingPeopleVaccinated INT 
);
INSERT INTO PercentPopulationVaccinated
SELECT cd.continent , cd.location , cd.date, cd.population, cv.new_vaccinations, SUM(cv.new_vaccinations) 
OVER (PARTITION by cd.location order by c d.location, cd.date)  as rollingPeopleVaccinated
from portfolioProject1.covidDeaths cd 
join portf olioProject1.covidVaccination cv 
	on cd.location  = cv.location 
	and cd.date = cv.date
-- where cd.continent != '';

SELECT *, (rollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated;



-- Creating view to store data for later visualizations

CREATE View PercentPopulationVaccinated as
SELECT cd.continent , cd.location , cd.date, cd.population, cv.new_vaccinations, SUM(cv.new_vaccinations) 
OVER (PARTITION by cd.location order by cd.location, cd.date)  as rollingPeopleVaccinated
from portfolioProject1.covidDeaths cd 
join portfolioProject1.covidVaccination cv 
	on cd.location  = cv.location 
	and cd.date = cv.date
where cd.continent !='';	

SELECT *
FROM PercentPopulationVaccinated ppv ;
