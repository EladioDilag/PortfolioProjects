SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
	AND continent is not NULL
ORDER BY 1, 2

--Total Cases vs Population
SELECT location, date, population, total_cases, (cast(total_cases as float)/population) * 100 AS InfectionPercentage 
FROM PortfolioProject..CovidDeaths
WHERE location like 'United States'
	AND continent is not NULL
ORDER BY 1, 2

--Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
	MAX((total_cases/population)) * 100 AS PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Countries with highest death count per population
SELECT location, MAX(cast(total_deaths as float)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Global death count breakdown
SELECT location, MAX(cast(total_deaths as float)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Continents with highest death count
SELECT continent, MAX(cast(total_deaths as float)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, 
	SUM(new_deaths)/NULLIF(SUM(new_cases),0) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1, 2

--Total Population vs Vaccination (As a CTE)
WITH PopulationVsVaccination (Continent, Location, Date, Population, NewVaccinations, 
	RollingVaccinationCount)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
)
Select *, (RollingVaccinationCount/Population) * 100
From PopulationVsVaccination


--Total Population vs Vaccination (As a temp table)
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinationCount numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *, (RollingVaccinationCount/Population) * 100
FROM #PercentPopulationVaccinated

--Create view to store data for later visualization
CREATE VIEW PercentPoplationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) AS RollingVaccinationCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL

SELECT * 
FROM PercentPoplationVaccinated