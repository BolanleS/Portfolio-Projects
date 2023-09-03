SELECT * FROM MyPortfolioProject.dbo.CovidDeaths

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM MyPortfolioProject.dbo.CovidDeaths
ORDER BY location

-------------------------------------------------------------------------------------------------------------

--Total Cases vs Total Deaths

SELECT location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM MyPortfolioProject.dbo.CovidDeaths
WHERE location = 'United Kingdom' 
AND total_deaths IS NOT NULL
ORDER BY location

--------------------------------------------------------------------------------------------------------------

--Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationinfected
FROM MyPortfolioProject.dbo.CovidDeaths
WHERE location = 'United Kingdom'
ORDER BY location

----------------------------------------------------------------------------------------------------------------

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationinfected
FROM MyPortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationinfected DESC

------------------------------------------------------------------------------------------------------------------

-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM MyPortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Contintents with the highest death count per population

SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCountPerContinent
FROM MyPortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCountPerContinent DESC

----------------------------------------------------------------------------------------------------------

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS  total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM MyPortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS  total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM MyPortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date

-----------------------------------------------------------------------------------------------------------

--Joining of two tables

SELECT * FROM MyPortfolioProject.dbo.CovidDeaths AS dea
INNER JOIN MyPortfolioProject.dbo.CovidVaccinations AS vac
ON vac.location = dea.location
AND vac.date = dea.date

---------------------------------------------------------------------------------------------------------------

--Total Population vs Total Vaccinations

SELECT dea.continent, dea.date, dea.location, dea.population, vac.total_vaccinations 
FROM MyPortfolioProject.dbo.CovidDeaths AS dea
INNER JOIN  MyPortfolioProject.dbo.CovidVaccinations AS vac
ON vac.location = dea.location
AND vac.date = dea.date


--Total Population vs New Vaccinations

SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations 
FROM MyPortfolioProject.dbo.CovidDeaths AS dea
INNER JOIN  MyPortfolioProject.dbo.CovidVaccinations AS vac
ON vac.location = dea.location
AND vac.date = dea.date
WHERE vac.new_vaccinations IS NOT NULL
AND dea.continent IS NOT NULL
ORDER BY location

--------------------------------------------------------------------------------------------------------------

--Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummulativeOfPeopleVaccinated
FROM MyPortfolioProject.dbo.CovidDeaths AS dea
INNER JOIN  MyPortfolioProject.dbo.CovidVaccinations AS vac
ON vac.location = dea.location
AND vac.date = dea.date
WHERE vac.new_vaccinations IS NOT NULL
AND dea.continent IS NOT NULL
ORDER BY location

----------------------------------------------------------------------------------------------------------------

--Using CTE 

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CummulativeOfPeopleVaccinated)
AS
(
SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummulativeOfPeopleVaccinated
FROM MyPortfolioProject.dbo.CovidDeaths AS dea
INNER JOIN  MyPortfolioProject.dbo.CovidVaccinations AS vac
ON vac.location = dea.location
AND vac.date = dea.date
WHERE vac.new_vaccinations IS NOT NULL
AND dea.continent IS NOT NULL
)
SELECT *, (CummulativeOfPeopleVaccinated/Population)*100
FROM PopvsVac

-----------------------------------------------------------------------------------------------------------

--Temp Table

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CummulativeOfPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as CummulativeOfPeopleVaccinated
FROM MyPortfolioProject.dbo.CovidDeaths dea
Join MyPortfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT *, (CummulativeOfPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-------------------------------------------------------------------------------------------------------------

--Creating view for later visualiation in Tableau

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as CummulativeOfPeopleVaccinated
FROM MyPortfolioProject..CovidDeaths dea
Join MyPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM PercentPopulationVaccinated


CREATE VIEW TotalPopulationVaccinated AS
SELECT dea.continent, dea.date, dea.location, dea.population, vac.total_vaccinations 
FROM MyPortfolioProject.dbo.CovidDeaths AS dea
INNER JOIN  MyPortfolioProject.dbo.CovidVaccinations AS vac
ON vac.location = dea.location
AND vac.date = dea.date

SELECT * FROM TotalPopulationVaccinated

CREATE VIEW DeathPercentage AS
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS  total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM MyPortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date

SELECT *FROM DeathPercentage