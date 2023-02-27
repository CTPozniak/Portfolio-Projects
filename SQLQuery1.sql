SELECT *
FROM PortfolioProject..CovidDeaths$
Where continent is not null
order by 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--order by 3, 4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows Chance of dying if contracting Covid in different Countries
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1, 2

--Looking at Total Cases vs Population
-- Shows percent of population that got covid
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPop
From PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1, 2

-- Look at Countries with Highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfect,  MAX((total_cases/population))*100 as PercentPopInfected
From PortfolioProject..CovidDeaths$
Group by location, population
order by PercentPopInfected desc

-- Showing Countries with Highest Death Rate per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by location
order by TotalDeathCount desc

--By Continent

Select SUM(new_cases) as total_case, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercent
From PortfolioProject..CovidDeaths$
Where continent is not null
--Group by date
order by 1, 2

--Total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location, dea.Date) as RollingPeopleVac
From PortfolioProject..CovidDeaths$ dea 
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 1, 2, 3

With PopVsVac (Continent, location, Date, Population, new_vaccinations, RollingPeopleVac)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location, dea.Date) as RollingPeopleVac
From PortfolioProject..CovidDeaths$ dea 
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

)
Select *, (RollingPeopleVac/Population)*100
From PopVsVac


Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVac numeric
)


Insert into..#PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location, dea.Date) as RollingPeopleVac
From PortfolioProject..CovidDeaths$ dea 
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVac/Population)*100
From #PercentPopulationVaccinated



--Creating View 
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location, dea.Date) as RollingPeopleVac
From PortfolioProject..CovidDeaths$ dea 
join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


