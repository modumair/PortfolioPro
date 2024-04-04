/*Covid 19 Data Sets

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions,
Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--WHERE continent IS NOT NULL
--order by 3,4

-- Selecting data for project to start with 

SELECT Location, date, total_cases, new_cases,
total_cases, total_deaths, population
FROM Portfolioproject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Indicates the chance of dying after contracting COVID in your country.

SELECT Location, date,total_cases, total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolioproject..CovidDeaths
WHERE Location like '%india%'
and continent IS NOT NULL
ORDER BY 1,2

--Total cases vs Population
-- Indicates what proportion of the population affected by COVID

SELECT Location, date,population,total_cases,
(total_cases/population)*100 as InfectedPercentage
FROM Portfolioproject..CovidDeaths
--WHERE Location like '%india%'
ORDER BY 1,2

--Indicates Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount,
MAX((total_cases/population))*100 as InfectedPercentage
FROM Portfolioproject..CovidDeaths
--WHERE Location like '%india%'
GROUP BY population, location
ORDER BY InfectedPercentage DESC

--Indicates Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Portfolioproject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY  location
ORDER BY TotalDeathCount DESC


-- DIVIDING STATISTICS BY CONTINENT.

-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Portfolioproject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY  continent
ORDER BY TotalDeathCount DESC

-- ALTERNATE WAY (MORE ACCURATE)

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Portfolioproject..CovidDeaths
WHERE continent IS  NULL
GROUP BY  location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2 

-- Total Population vs Vaccinations

--  Displays percenatge of population that has recieved at least one Covid vaccination.

SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
	--WHERE dea.location like '%india%' AND
 WHERE dea.continent is not null
ORDER BY 2

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Populaton, New_vaccinations, RollingPeopleVaccinated )
AS
(SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
 WHERE dea.continent is not null)
 SELECT *, (RollingPeopleVaccinated/Populaton)*100
 FROM PopvsVac

 -- Using Temp Table to perform Calculation on Partition By in previous query

 DROP Table IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--AND dea.location like '%India%'
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Additional; View to store data for later data visualisations


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 


	









