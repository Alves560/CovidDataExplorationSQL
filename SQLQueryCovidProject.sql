--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4;

SELECT *
FROM PortfolioProject.dbo.['CovidDeaths']
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.['CovidDeaths']
ORDER BY 1,2;

-- Percentage of dying from COVID in EU and Portugal --
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS PercentageDeath
FROM PortfolioProject.dbo.['CovidDeaths']
WHERE location like 'European Union'
ORDER BY 1,2;

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS PercentageDeath
FROM PortfolioProject.dbo.['CovidDeaths']
WHERE location like 'Portugal'
ORDER BY 1,2;

-- Percentage of population in Portugal who has contracted COVID --
SELECT location, date, total_cases, population, (total_cases / population) * 100 AS PercentagePopulationContracted
FROM PortfolioProject.dbo.['CovidDeaths']
WHERE location like 'Portugal'
ORDER BY 1,2;

-- Countries with Highest Infection Rate compared to Population (World) --
SELECT location, MAX(total_cases), population, MAX((total_cases / population)) * 100 AS PercentagePopulationContracted
FROM PortfolioProject.dbo.['CovidDeaths']
GROUP BY location, population
ORDER BY 4 DESC;

-- Countries with Highest Infection Rate compared to Population (Europe) --
SELECT location, MAX(total_cases), population, MAX((total_cases / population)) * 100 AS PercentagePopulationContracted
FROM PortfolioProject.dbo.['CovidDeaths']
WHERE continent like 'Europe'
GROUP BY location, population
ORDER BY 4 DESC;

-- Countries with Highest Death Count compared to Population (World) --
SELECT location, MAX(CAST(total_deaths AS INT)) AS totalDeaths
FROM PortfolioProject.dbo.['CovidDeaths']
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;

-- Countries with Highest Death Count compared to Population (Europe) --
SELECT location, MAX(CAST(total_deaths AS INT)) AS totalDeaths
FROM PortfolioProject.dbo.['CovidDeaths']
WHERE continent IS NOT NULL AND continent like 'Europe'
GROUP BY location
ORDER BY 2 DESC;

-- Group by Continent (Highest Death Count) --
SELECT continent, MAX(CAST(total_deaths AS INT)) AS totalDeaths
FROM PortfolioProject.dbo.['CovidDeaths']
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC;

-- Global Numbers --
SELECT SUM(new_cases) AS totalCases, SUM(cast(new_deaths AS INT)) AS totalDeaths, SUM(cast(new_deaths AS INT)) / SUM(new_cases) * 100 AS PercentageDeath
FROM PortfolioProject.dbo.['CovidDeaths']
WHERE continent IS NOT NULL
ORDER BY 1,2;



-- Comparison between Total Population VS Vaccinations --
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(CAST(VAC.new_vaccinations AS INT)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.DATE) AS rollingPopulationVaccinated
FROM PortfolioProject.dbo.['CovidDeaths'] AS DEA
JOIN PortfolioProject.dbo.CovidVaccinations AS VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL 
ORDER BY 2,3;

-- CTE --
WITH PopVsVac (continent, location, date, population, new_vaccinations, rollingPopulationVaccinated)
AS (
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(CAST(VAC.new_vaccinations AS INT)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.DATE) AS rollingPopulationVaccinated
FROM PortfolioProject.dbo.['CovidDeaths'] AS DEA
JOIN PortfolioProject.dbo.CovidVaccinations AS VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL 
) 
SELECT *, (rollingPopulationVaccinated / population) * 100
FROM PopVsVac;



CREATE VIEW PercentPopulationVaccinated AS 
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, 
SUM(CAST(VAC.new_vaccinations AS INT)) OVER (PARTITION BY DEA.location ORDER BY DEA.location, DEA.DATE) AS rollingPopulationVaccinated
FROM PortfolioProject.dbo.['CovidDeaths'] AS DEA
JOIN PortfolioProject.dbo.CovidVaccinations AS VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL 
--ORDER BY 2,3;