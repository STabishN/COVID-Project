-- Total cases vs deaths
-- Probability if exposed to COVID 

---Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
--From PortfolioProject..Coviddeaths
--where location like '%arab%'
--order by 1,2

-- Total cases vs population
-- Shows what percentage got covid

--Select Location, date, total_cases, population, (total_cases/population)*100 as CovidPopulation
--From PortfolioProject..Coviddeaths
--where location like '%australia%'
--order by 2,1

Select*
From PortfolioProject..Coviddeaths
where continent is not null

-- Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CovidePopulationInfected
From PortfolioProject..Coviddeaths 
Group by location,population
order by CovidePopulationInfected desc

-- Countries with Higest Death Count per population

Select Location, MAX(cast (total_deaths as int)) as COVIDdeaths
From PortfolioProject..Coviddeaths 
where continent is not null
Group by location
order by COVIDdeaths desc

-- Lets break things down by continent
-- Showing continents with the highest death count per population

Select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject..Coviddeaths 
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..Coviddeaths
where continent is not null
Group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..Coviddeaths
where continent is not null
--Group by date
order by 1,2

--Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated--, MAX(RollingPeopleVaccinated/population)*100
From PortfolioProject..Coviddeaths dea
Join PortfolioProject..Covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USING CTE

With POPvsVAC (Continent, location, date, population, New_vaccincations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date) 
as RollingPeopleVaccinated 
-- MAX(RollingPeopleVaccinated/population)*100
From PortfolioProject..Coviddeaths dea
Join PortfolioProject..Covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/population)*100 as PercentVaccinatedPerCountry
From POPvsVAC


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date) 
as RollingPeopleVaccinated 
-- MAX(RollingPeopleVaccinated/population)*100
From PortfolioProject..Coviddeaths dea
Join PortfolioProject..Covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/population)*100 as PercentVaccinatedPerCountry
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date) 
as RollingPeopleVaccinated 
-- MAX(RollingPeopleVaccinated/population)*100
From PortfolioProject..Coviddeaths dea
Join PortfolioProject..Covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
