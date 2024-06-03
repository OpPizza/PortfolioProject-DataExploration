-- Select everything and order by location and date.
SELECT * FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4;

SELECT location, date, total_cases, new_cases, total_deaths, population FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2;

-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
from PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
order by 1,2;

-- Total Cases vs Total Deaths in Malaysia
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
from PortfolioProject..covidDeaths
WHERE location = 'Malaysia'
ORDER BY 1,2;

-- Total Cases vs Population
SELECT location, date, population, total_cases, (total_cases/population) * 100 AS InfectedPercentage
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Total Cases vs Population in Malaysia
SELECT location, date, population, total_cases, (total_cases/population) * 100 AS InfectedPercentage
FROM PortfolioProject..covidDeaths
WHERE location = 'Malaysia'
ORDER BY 1,2;

-- Countries with highest infection rate vs population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 AS InfectedPercentage
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectedPercentage DESC

-- Countries with highest death count vs population
SELECT location, MAX(cast(total_deaths AS INT)) as HighestDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC


-- CONTINENT

-- Continent with highest death count vs population
SELECT continent, MAX(cast(total_deaths AS INT)) as HighestDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC


-- WORLD
-- New Cases and Death per day, worldwide
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

SELECT * FROM PortfolioProject..CovidVaccinations

-- Total population VS vaccination

SELECT PortfolioProject..CovidDeaths.continent, PortfolioProject..CovidDeaths.location, PortfolioProject..CovidDeaths.date, 
PortfolioProject..CovidDeaths.population, PortfolioProject..CovidVaccinations.new_vaccinations,
SUM(CAST(CovidVaccinations.new_vaccinations AS INT)) 
OVER (PARTITION BY PortfolioProject..CovidDeaths.location ORDER BY PortfolioProject..CovidDeaths.location, PortfolioProject..CovidDeaths.date) AS Vaccinated
FROM PortfolioProject..CovidDeaths
JOIN PortfolioProject..CovidVaccinations ON PortfolioProject..CovidDeaths.location = PortfolioProject..CovidVaccinations.location 
AND 
PortfolioProject..CovidDeaths.date = PortfolioProject..CovidVaccinations.date
WHERE PortfolioProject..CovidDeaths.continent IS NOT NULL
ORDER BY 2, 3;

-- CTE
-- Total population VS vaccination with Vaccinated Percentage

WITH PopvsVac (continent, location, date, population, new_vaccination, Vaccinated)
AS
(
SELECT PortfolioProject..CovidDeaths.continent, PortfolioProject..CovidDeaths.location, PortfolioProject..CovidDeaths.date, 
PortfolioProject..CovidDeaths.population, PortfolioProject..CovidVaccinations.new_vaccinations,
SUM(CAST(CovidVaccinations.new_vaccinations AS INT)) 
OVER (PARTITION BY PortfolioProject..CovidDeaths.location ORDER BY PortfolioProject..CovidDeaths.location, PortfolioProject..CovidDeaths.date) AS Vaccinated
FROM PortfolioProject..CovidDeaths
JOIN PortfolioProject..CovidVaccinations ON PortfolioProject..CovidDeaths.location = PortfolioProject..CovidVaccinations.location 
AND 
PortfolioProject..CovidDeaths.date = PortfolioProject..CovidVaccinations.date
WHERE PortfolioProject..CovidDeaths.continent IS NOT NULL
)
SELECT *, (Vaccinated/population)*100 AS vaccinated_percentage FROM PopvsVac;

-- Create VIEW

CREATE VIEW PopulationVaccinated AS
SELECT PortfolioProject..CovidDeaths.continent, PortfolioProject..CovidDeaths.location, PortfolioProject..CovidDeaths.date, 
PortfolioProject..CovidDeaths.population, PortfolioProject..CovidVaccinations.new_vaccinations,
SUM(CAST(CovidVaccinations.new_vaccinations AS INT)) 
OVER (PARTITION BY PortfolioProject..CovidDeaths.location ORDER BY PortfolioProject..CovidDeaths.location, PortfolioProject..CovidDeaths.date) AS Vaccinated
FROM PortfolioProject..CovidDeaths
JOIN PortfolioProject..CovidVaccinations ON PortfolioProject..CovidDeaths.location = PortfolioProject..CovidVaccinations.location 
AND 
PortfolioProject..CovidDeaths.date = PortfolioProject..CovidVaccinations.date
WHERE PortfolioProject..CovidDeaths.continent IS NOT NULL
