
/*
Select *
From PortfolioProject..CovidDeaths
ORDER BY 3,4
*/

Select *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4
Select *
FROM PortfolioProject..CovidVaccination
ORDER BY 3,4


--Select data that we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid 19 in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location Like '%states%'
ORDER BY 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
FROM PortfolioProject..CovidDeaths
Where location Like '%states%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as InfectionPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY InfectionPercentage DESC

-- Showing Countries with Highest Death Percentage per Population
Select Location, Population, MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/population)*100) as DeathPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY DeathPercentage DESC

-- Showing Countries with Highest Death Count
Select Location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY HighestDeathCount DESC


-- Let's break things down by continent
Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount DESC


-- Global numbers

Select date, SUM(new_cases) as TotalNewCase, SUM(CAST(new_deaths as int)) as TotalNewDeath
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Looking at total population vs total vaccination
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
     ON dea.date = vac.date
	 And dea.location = vac.location
WHERE dea.continent is not null
ORDER BY 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
     ON dea.date = vac.date
	 And dea.location = vac.location
WHERE dea.continent is not null
)

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinePercentage
From PopvsVac

-- Use Temp Table
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

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
     ON dea.date = vac.date
	 And dea.location = vac.location
WHERE dea.continent is not null


Select *, (RollingPeopleVaccinated/Population)*100 as VaccinePercentage
From #PercentPopulationVaccinated

-- Creating view to store data for later visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
     ON dea.date = vac.date
	 And dea.location = vac.location
WHERE dea.continent is not null

Select *
From PercentPopulationVaccinated