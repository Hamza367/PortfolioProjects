SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE Location = 'Canada'
ORDER BY 2 DESC, 1

--Looking at the Total Cases vs Population

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS RatioOfPPop
FROM CovidDeaths
WHERE Location = 'Canada'
ORDER BY 2 DESC, 1

--Looking at countries with highest infection rates compared to population

SELECT Location, MAX(total_cases) AS HighestInfectionCount, population, MAX(total_cases/population)*100 AS PercentOfPopInfected
FROM CovidDeaths
GROUP BY Location, population
ORDER BY 4 DESC

--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) AS TotalDeathCount 
FROM CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY 2 DESC

--Let's break things down by continent

--Showing continents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount 
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC

--Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (cast (vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated

FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (cast (vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated

FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/Population)*100 as percentvaccinated
FROM PopvsVac

--Temp table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (cast (vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated

FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date = vac.date
--where dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100 as percentvaccinated
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (cast (vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated

FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT * 
FROM PercentPopulationVaccinated