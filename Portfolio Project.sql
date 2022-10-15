SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3, 4;

--SELECT * 
--FROM PortfolioProject..CovidVaccination
--ORDER BY 3, 4; 

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2;

-- Looking at Total Cases Vs Total Deaths
-- Show likelihood of dying from Covid in Canada overtime

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Canada%'
ORDER BY 1, 2;

-- Looking at Total Cases vs Populations
-- Show what percentage of population got Covid

SELECT location, date,population,  total_cases, (total_cases/population) * 100 AS CovidAffectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Canada%'
ORDER BY 1, 2;

--Looking at Countries with Highest Infection Rate Compared to Population

SELECT location, date, population, total_cases, (total_cases/population) * 100 AS CovidAffectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE date = '2022-10-13' AND location LIKE 'France'
ORDER BY CovidAffectedPercentage DESC;

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Let's break things down by continent
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Showing continents with the highest death count

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- Global Numbers

SELECT date, SUM(NEW_CASES) AS Total_Cases, SUM(CAST(new_deaths as int)) AS Total_deaths, 
	SUM(CAST(New_deaths as int)) / SUM(New_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;


-- Looking at Total Population vs Vaccinations

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccination Vac
ON Dea.location = Vac.location AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2, 3
;

-- Looking at Total Population vs Vaccinations

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS float)) OVER (Partition by Dea.location ORDER BY dea.location , Dea.Date) RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccination Vac
ON Dea.location = Vac.location AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2, 3
;

--USE CTE

With PopvsVac (Continent, Location, Date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS float)) OVER (Partition by Dea.location ORDER BY dea.location , Dea.Date) RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccination Vac
ON Dea.location = Vac.location AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 1, 2, 3
)
SELECT * , RollingPeopleVaccinated / population * 100
FROM PopvsVac


-- Temp Table
DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS float)) OVER (Partition by Dea.location ORDER BY dea.location , Dea.Date) RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccination Vac
ON Dea.location = Vac.location AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2, 3

SELECT * FROM #PercentPopulationVaccinated;


-- Creating View to Store data for later visualizations

Create VIEW PercentPopulationVaccinated AS
SELECT Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS float)) OVER (Partition by Dea.location ORDER BY dea.location , Dea.Date) RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidVaccination Vac
ON Dea.location = Vac.location AND Dea.date = Vac.date
WHERE dea.continent IS NOT NULL;