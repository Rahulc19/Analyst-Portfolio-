SELECT Location, continent, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY date DESC

-- Now going to find correlation of Covid Cases and Deaths

SELECT Location, date, total_cases, total_deaths, ((total_deaths/total_cases) * 100) AS DeathPercentage
FROM coviddeaths
WHERE location LIKE '%Canada%' AND continent is not null
ORDER BY 1,2

-- As of 2022-02-07 the probability of dying from contracting covid is %1.11. 

-- Now looking at Total Cases vs Population. This will show the percentage of population that contracted Covid-19.

SELECT Location, date, total_cases, population, ((total_cases/population) * 100) AS POPCOV
FROM coviddeaths
WHERE location LIKE '%Canada%' AND continent is not null
ORDER BY 1,2

-- Looking at Countries with the Highest Infection Rate compared to population
SELECT Location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population) * 100) AS InfectionRate
FROM coviddeaths
WHERE continent is not null
GROUP BY Location, population
ORDER BY InfectionRate DESC -- Found that highest rate are usually smaller population country, but countries in Euruope such as France, Slovenia have high rates of 30%+


-- Countries with the Highest Death Count per Population
SELECT Location, MAX(total_deaths) AS HighestDeathCount 
FROM coviddeaths
WHERE total_deaths is not null AND continent is not null -- Some countries have a null values for deaths
GROUP BY Location
ORDER BY HighestDeathCount DESC

-- Found that US has the highest death count, followed by Brazil and India.

-- Looking at death count per continent
SELECT location, MAX(total_deaths) AS HighestDeathCount 
FROM coviddeaths
WHERE total_deaths is not null AND continent is NULL -- Some countries have a null values for deaths
GROUP BY location
ORDER BY HighestDeathCount DESC
-- NA has the highest amount of deaths.


-- Global numbers
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM coviddeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Finding the death rate after Omicron Variant was introduced and comparing to Delta variant

SELECT date,location, SUM(new_deaths) OVER (PARTITION BY location ORDER BY date) AS RollingOmiDeath
FROM coviddeaths
WHERE date BETWEEN '2021-11-26' AND '2022-02-07' AND location LIKE '%Canada%'



SELECT date,location, SUM(new_deaths) OVER (PARTITION BY location ORDER BY date) AS RollingDeltaDeath
FROM coviddeaths
WHERE date BETWEEN '2021-07-20' AND '2022-11-26' AND location LIKE '%Canada%'



 
-- Utilizing Joins to capture the total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition BY dea.location ORDER BY dea.date) AS RollingVaxSum
FROM coviddeaths dea
INNER JOIN covidvaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT null
ORDER BY 2,3

-- To find total vaccinated vs population for each country, USE CTE because we can't use column we just created.

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingVaxSum)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition BY dea.location ORDER BY dea.location,dea.date) AS RollingVaxSum
FROM coviddeaths dea
INNER JOIN covidvaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 1,2
	
)
SELECT *, (RollingVaxSUM/population)*100 AS PopVaxxed
FROM PopvsVAC

-- OR utilize TEMP table
SELECT 
continent,
location,
date,
population,
new_vaccinations,
RollingVaxSum

INTO TEMP TABLE percentpopvaccinated
FROM 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition BY dea.location ORDER BY dea.location,dea.date) AS RollingVaxSum
FROM coviddeaths dea
INNER JOIN covidvaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT null) AS vaxtable

SELECT *, (RollingVaxSUM/population)*100 AS PopVaxxed
FROM percentpopvaccinated


-- Creating view for later visualizations (Vaccinated as per Population)

CREATE VIEW percentpopvaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (partition BY dea.location ORDER BY dea.location,dea.date) AS RollingVaxSum
FROM coviddeaths dea
INNER JOIN covidvaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT null
--ORDER BY 1,2

SELECT * FROM percentpopvaccinated

-- VIEW for Canada covid cases vs Deaths
CREATE VIEW CanadaCovidDeaths AS
SELECT Location, date, total_cases, total_deaths, ((total_deaths/total_cases) * 100) AS DeathPercentage
FROM coviddeaths
WHERE location LIKE '%Canada%' AND continent is not null
ORDER BY 1,2

--VIEW for Death per Continent
CREATE VIEW ContinentDeaths AS 
SELECT location, MAX(total_deaths) AS HighestDeathCount 
FROM coviddeaths
WHERE total_deaths is not null AND continent is NULL -- Some countries have a null values for deaths
GROUP BY location
ORDER BY HighestDeathCount DESC


-- VIEW Country Deaths
CREATE VIEW CountryDeaths AS
SELECT Location, MAX(total_deaths) AS HighestDeathCount 
FROM coviddeaths
WHERE total_deaths is not null AND continent is not null -- Some countries have a null values for deaths
GROUP BY Location
ORDER BY HighestDeathCount DESC
