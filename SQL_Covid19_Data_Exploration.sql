SELECT * 
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL

SELECT *
FROM PortfolioProject..CovidVaccinations$

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Total cases Vs Total 

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercent
FROM PortfolioProject..CovidDeaths$
WHERE location like '%united%state%'
ORDER BY 1, 2

-- Total cases Vs Popoulation

SELECT location, date,population, total_cases, (total_cases/population)*100 AS CasePercent
FROM PortfolioProject..CovidDeaths$
WHERE location like '%united%state%'
ORDER BY 1, 2

-- Countries with highest infection rate compared to population

SELECT location,population, MAX(total_cases) AS HighestInfectionCount, 
MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

-- Countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC


-- Death BY Continent

SELECT location, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

-- Global numbers

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) AS TotalDeath,
SUM(cast(new_deaths as int))/SUM(new_cases) AS DeathPercent
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2

-- JOIN Tables

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- The Querry above using a USE CTE

with PopvsVac (continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccPerPopulation
FROM PopvsVac


-- The same querry with Temp Table

DROP TABLE IF EXISTS #PercentPopulatioVaccinated
CREATE TABLE #PercentPopulatioVaccinated
(
Continent nvarchar(225),
Location nvarchar(225), 
Date datetime, 
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulatioVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccPerPopulation
FROM #PercentPopulatioVaccinated

-- Create view to use it later for visualation

CREATE VIEW PercentPopulatioVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
from PercentPopulatioVaccinated