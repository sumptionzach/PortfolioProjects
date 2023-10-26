Select *
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order By 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--Order By 3,4

-- Select data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order By 1,2

-- Looking at Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths / total_cases)
From PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order By 1,2

-- Changing type
Select location, date, total_cases, total_deaths,
(Convert(float,total_deaths)/Nullif(Convert(float,total_cases),0)) * 100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
AND continent is not null
Order By 1,2

-- Looking at Total Cases vs Population
Select location, date, total_cases, population,
(Convert(float,total_cases)/Nullif(Convert(float,population),0)) * 100 AS CovidPercentage
From PortfolioProject..CovidDeaths
-- Where location = 'United States'
Where continent is not null
Order By 1,2

-- Looking at countries with highest infection rate compared to population
Select location,population, MAX(Cast(total_cases as INT)) AS HighestInfectionCount, MAX(total_cases/population) * 100 AS 
	PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where location = 'United States'
Where continent is not null
Group By location, population
Order By PercentPopulationInfected desc

-- Looking at countries with the highest death rate compared to population
Select location, MAX(Cast(Total_Deaths as INT)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location = 'United States'
Where continent is not null
Group By location
Order By TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(Cast(Total_Deaths as INT)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount desc


-- Showing continents with the highest death count per population
Select continent, MAX(Cast(Total_Deaths as INT)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location = 'United States'
Where continent is not null
Group By continent
Order By TotalDeathCount desc


-- Global Numbers
Select SUM(new_cases) as Total_Cases, SUM(Cast(new_deaths as INT)) as Total_Deaths,
	SUM(new_deaths)/SUM(Cast(new_cases as INT)) *100 AS DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not null
-- Group By date
Order By 1,2


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order By dea.location, dea.date)
	AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3


-- Use CTE

With PopvsVac (Continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order By dea.location, dea.date)
	AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/population) * 100
From PopvsVac

-- Temp Table

DROP Table If exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order By dea.location, dea.date)
	AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/population) * 100
From #PercentPopulationVaccinated

-- Creating View to Store later for visualizations

Create View  PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition By dea.location Order By dea.location, dea.date)
	AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select *
From PercentPopulationVaccinated