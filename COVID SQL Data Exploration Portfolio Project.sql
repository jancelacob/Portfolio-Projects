Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

-- Select data to be used
Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location,date,total_cases,total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
From PortfolioProject..CovidDeaths
Where location like '%Singapore%'
order by 1,2

--Looking at Total Cases vs Population
--shows what % of population got Covid

Select location,date,total_cases,population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS 'Infection percentage'
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select location,population,MAX(total_cases) as HighestInfectionCount, MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100) AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location,population
order by PercentPopulationInfected desc

--by continent,
-- Showing continents with Highest Death Count per Population
Select Continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent != ' '
Group by Continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select date,SUM(CAST(new_cases as int)) as total_cases ,SUM(CAST(new_deaths as int)) as total_deaths, Nullif(SUM(CAST(new_cases as int)),0)/Nullif(SUM(CAST(new_deaths as int)),0) as DeathPercentages
From PortfolioProject..CovidDeaths
Where Continent != ' '
Group by date
order by 1,2


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ' '
Order by 2,3

--USE CTE
With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ' '
--Order by 2,3
)
Select *, CAST(RollingPeopleVaccinated as float)/Nullif(Cast(Population as float),0)*100 AS RollingPeopleVaccinatedPercentage
From PopvsVac
Order by 2,3

--Creating View to store data for later visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ' '
--Order by 2,3

Select * 
From PercentPopulationVaccinated