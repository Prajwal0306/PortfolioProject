SELECT *
FROM [dbo].[CovidDeaths]
WHERE continent is NOT null
ORDER BY 3, 4

--Select data that we are going to use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [dbo].[CovidDeaths]
WHERE continent is NOT null
ORDER BY 1, 2

--Looking at total cases vs total deaths
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percent
FROM [dbo].[CovidDeaths]
WHERE continent is NOT null
ORDER BY 1, 2

--Looking at total cases vs Population
SELECT location, date,population, total_cases ,(total_cases/population)*100 as Infection_Percent
FROM [dbo].[CovidDeaths]
WHERE continent is NOT null
ORDER BY 1, 2

--Looking at countried with highest infection rate
SELECT location,population, MAX(total_cases) as HighestInfectionCount ,MAX((total_cases/population))*100 as Infection_Percent
FROM [dbo].[CovidDeaths]
WHERE continent is NOT null
GROUP BY location,population
ORDER BY Infection_Percent desc

--Showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int) ) as TotalDeathCount 
FROM [dbo].[CovidDeaths]
WHERE continent is NOT null
GROUP BY location
ORDER BY TotalDeathCount desc

--Showing continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as int) ) as TotalDeathCount 
FROM [dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--global numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percent
FROM [dbo].[CovidDeaths]
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

--Global total cases, total deaths and Death_Percent
SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percent
FROM [dbo].[CovidDeaths]
WHERE continent is not null
ORDER BY 1, 2

--Looking at total population vs Vaccination

--SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
--SUM(cast(vac.new_vaccinations as int))  OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
--FROM [dbo].[CovidDeaths] dea
--JOIN [dbo].[CovidVaccinations] vac
--ON dea.location = vac.location
--AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

--USE CTE

WITH popvsvac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int))  OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
FROM [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM popvsvac 


--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int))  OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
FROM [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--creating view for visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int))  OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
FROM [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated