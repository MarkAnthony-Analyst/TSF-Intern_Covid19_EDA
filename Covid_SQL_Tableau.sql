
SELECT *
FROM Covid.dbo.CovidDeaths
ORDER BY 3,4;

SELECT *
FROM Covid.dbo.CovidVaccinations
ORDER BY 3,4;


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid.dbo.CovidDeaths
ORDER BY 1,2	

--Looking at Total Cases Vs Total Deaths
--Shows the likehood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Death_percentage
FROM Covid.dbo.CovidDeaths
WHERE location = 'Philippines'
ORDER BY 1,2

--Total Cases Vs Populations
--shows what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as cases_percentage
FROM Covid.dbo.CovidDeaths
--WHERE location = 'Philippines'
ORDER BY 1,2

--Countries with Highest Percentage of Infection dependin on population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as Infected_Population_Percentage
FROM Covid.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Infected_Population_Percentage DESC

Select Location, Population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as Infected_Population_Percentage
From Covid.dbo.CovidDeaths
--WHERE continent is not null
Group by Location, Population, date
order by Infected_Population_Percentage desc

--Showing Countries With Highest Death Count

SELECT continent,  SUM(Cast(New_Deaths as INT)) as TotalDeathCount
FROM Covid.dbo.CovidDeaths	
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

---COnfirmation of Above Query
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Covid.dbo.CovidDeaths
Where continent is null 
and location not in ('World', 'Upper middle income', 'High income', 'Lower middle income', 'Low income', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;


--Global
--Number 0f Cases and Number of Deaths per Date

SELECT date, SUM(new_cases)  'New Cases per Day', SUM(CAST(new_deaths as INT)) 'New Deaths per Day',
SUM(CAST(new_deaths as INT))/SUM(new_cases) * 100  'Percentage Of Deaths'
FROM Covid.dbo.CovidDeaths	
WHERE continent is not null
GROUP BY date
ORDER BY date DESC;


SELECT  SUM(new_cases)  'Total Cases', SUM(CAST(new_deaths as INT)) 'Total Deaths',
SUM(CAST(new_deaths as INT))/SUM(new_cases) * 100  'Death Percentage'
FROM Covid.dbo.CovidDeaths	
WHERE continent is not null
ORDER BY 1, 2

--Total Population that has vaccination


SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Covid.dbo.CovidDeaths dea
JOIN Covid.dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3;

--Rolling Count of Vaccinations Depending on Location
--If it's null it will stay the same
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
	dea.date ROWS UNBOUNDED PRECEDING) AS 'Rolling Count of Vaccinations'
FROM Covid.dbo.CovidDeaths dea
JOIN Covid.dbo.CovidVaccinations vac
		ON dea.location = vac.location
		and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

----USE CTE

WITH PopvsVac (Continent, location, date, population, new_vaccinations, Rolling_Count_of_Vaccinations)
AS
(
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
	dea.date ROWS UNBOUNDED PRECEDING) AS 'Rolling_Count_of_Vaccinations'
FROM Covid.dbo.CovidDeaths dea
JOIN Covid.dbo.CovidVaccinations vac
		ON dea.location = vac.location
		and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT  *, (Rolling_Count_of_Vaccinations/population)*100 'Rolling Percentage of Vaccinations'
FROM PopvsVac


---TEMP Table

DROP TABLE IF EXISTS #PercentPeopleVaccinated

CREATE TABLE #PercentPeopleVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population numeric,
New_Vaccinations numeric,
Rolling_Count_of_Vaccinations numeric
)
INSERT INTO #PercentPeopleVaccinated
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
	dea.date ROWS UNBOUNDED PRECEDING) AS 'Rolling_Count_of_Vaccinations'
FROM Covid.dbo.CovidDeaths dea
JOIN Covid.dbo.CovidVaccinations vac
		ON dea.location = vac.location
		and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT  *, (Rolling_Count_of_Vaccinations/population)*100 'Rolling Percentage of Vaccinations'
FROM #PercentPeopleVaccinated



---Create Views for Visualization

CREATE VIEW PercentPeopleVaccinated AS
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
	dea.date ROWS UNBOUNDED PRECEDING) AS 'Rolling_Count_of_Vaccinations'
FROM Covid.dbo.CovidDeaths dea
JOIN Covid.dbo.CovidVaccinations vac
		ON dea.location = vac.location
		and dea.date = vac.date
WHERE dea.continent is not null;


SELECT *
FROM PercentPeopleVaccinated
