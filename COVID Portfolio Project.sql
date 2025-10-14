Select *
From [Portfolio Project]..CovidDeaths
order by 3, 4 

Select *
From [Portfolio Project]..CovidVaccinations
order by 3, 4 

Select Location, date, total_cases, new_cases, total_deaths, population 
From [Portfolio Project]..CovidDeaths
order by 1, 2


-- Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From [Portfolio Project]..CovidDeaths
Where location like '%china%' 
order by 1, 2

-- Total Cases vs Population

Select Location, date, population, total_cases, (total_cases/population)*100 as CasePercentage 
From [Portfolio Project]..CovidDeaths
--Where location like '%china%' 
order by 1, 2


-- Countries with Highest Infection Count Compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected  
From [Portfolio Project]..CovidDeaths 
Group by Location, population 
order by PercentPopulationInfected desc 


-- Showing Countries with Highest Death Count per Population 

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount  
From [Portfolio Project]..CovidDeaths 
Where continent is not null
Group by Location		
order by TotalDeathCount desc 
-- Without cast(), result will be shown incorrectly because of the data type. 
-- Where ... is to avoid getting places that are continents or the "World" data. 


-- Explore Data by Continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount  
From [Portfolio Project]..CovidDeaths 
Where continent is null
Group by location 		
order by TotalDeathCount desc 


-- Global Numbers

Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as Death_Percentage 
From [Portfolio Project]..CovidDeaths
Where continent is not null 
Group by date 
order by 1, 2


-- Vaccinations vs Total Population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
-- , (RollingPeopleVaccinated/dea.population) * 100 
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
Order by 2, 3


-- Using CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
-- , (RollingPeopleVaccinated/dea.population) * 100 
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--Order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population) * 100 as PercentagePopulationVaccinated
From PopvsVac 


-- Using Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccications numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
-- , (RollingPeopleVaccinated/dea.population) * 100 
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--Order by 2, 3
Select *, (RollingPeopleVaccinated/Population) * 100 as PercentagePopulationVaccinated
From #PercentPopulationVaccinated 


-- Creating View to store data for visulizations later 

USE [Portfolio Project]; 
GO

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
-- , (RollingPeopleVaccinated/dea.population) * 100 
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--Order by 2, 3

Select *
From PercentPopulationVaccinated