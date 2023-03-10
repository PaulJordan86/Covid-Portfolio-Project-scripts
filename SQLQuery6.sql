--Select *
--From PortfolioProject..CovidDeaths
--Order by 3,4

Select *
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

Select *
FROM PortfolioProject..CovidVaccinations
Order by 3,4

-- Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
-- Shows likelihood of dying if you contract Covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where Location like '%state%'
order by 1,2

-- Looking at total cases vs population



-- Looking at countries with the highest infection rate compared to population

Select Location, MAX(total_cases) as HighestInfectionCount, MAX( (total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected DESC

-- Show Countries with Highest Death Count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount DESC

--Break things down by continent

--Showing the continents with the highest death count


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like 'spain'
Where continent is not null
Group by continent
order by TotalDeathCount DESC

-- Global numbers

--Daily

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- Where Location like '%state%'
Where continent is not null
Group by date
order by 1,2

--World Total by removing date


Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
-- Where Location like '%state%'
Where continent is not null
--Group by date
order by 1,2

-- Looking at total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

--USE CTE

With PopvsVac (continent, Location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentagePopulationVaccinated
FROM PopvsVac



-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
	--where dea.continent is not null
	order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100 as PercentagePopulationVaccinated
FROM #PercentPopulationVaccinated


--Creating view to store data for future visualisations


Create view DeathCountContinent as
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like 'spain'
Where continent is not null
Group by continent
--order by TotalDeathCount DESC

Create View DeathCountContinent as
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like 'spain'
Where continent is not null
Group by continent
--order by TotalDeathCount DESC

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

	Select *
	From PercentagePopulationVaccinated