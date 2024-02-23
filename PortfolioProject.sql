Select *
from PortfolioProject..CovidDeaths

---- Needed Data
SELECT location, date, total_cases, total_deaths, new_cases, new_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Deeath to Cases Ratio
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 DTCR
from PortfolioProject..CovidDeaths
where location like '%Nigeria%'
order by 1,2


-- Cases to Population

SELECT location, date, population, cast (total_cases as float),  (cast(total_cases as float)/population)*100 CTPR
from PortfolioProject..CovidDeaths
where location = 'Nigeria' 
order by 1,2

--- Continetal Data

SELECT continent, MAX(cast (total_deaths as float)) TDBC
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TDBC desc


-- Highest infection To Population Ratio Per Country.
SELECT continent, location, population, MAX(cast (total_cases as float)) HighestCases,  MAX((total_cases/population))*100 HITPRPC
from PortfolioProject..CovidDeaths
--where location = 'Nigeria'
where continent is not null
Group by continent, location, population
order by HITPRPC desc


-- Global Numbers

SELECT date, sum(new_cases) TotalCases, sum(cast(new_deaths as int)) TotalDeaths, sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 GDTCP
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
Group by date
order by 1

SELECT date, sum(new_cases), total_cases, total_deaths, (cast(total_deaths as int)/total_cases) *100 GDTCP
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
Group by date
order by 1


Select *
from PortfolioProject..CovidVaccination
order by 1,2

-- Total Population VS Total Vaccinations

Select DA.continent, DA.location, da.date, da.population, va.new_vaccinations, 
sum(convert(float, va.new_vaccinations)) over (partition by da.location order by da.location, da.date) GrowthInVaccinationsPerDay
from PortfolioProject..CovidDeaths DA
join PortfolioProject..CovidVaccination VA
	on DA.location = VA.location
	and DA.date = VA.date
where da.continent is not null
order by 2,3


-- USE CTE
With PopvsVac (Continent, location, date, population, new_vaccinations, GrowthInVaccinationsPerDay)
as
(
Select DA.continent, DA.location, da.date, da.population, va.new_vaccinations, 
sum(convert(float, va.new_vaccinations)) over (partition by da.location order by da.location, da.date) GrowthInVaccinationsPerDay
from PortfolioProject..CovidDeaths DA
join PortfolioProject..CovidVaccination VA
	on DA.location = VA.location
	and DA.date = VA.date
where da.continent is not null
--order by 2,3
)
Select *, (GrowthInVaccinationsPerDay/population)*100
from PopvsVac


--TEMP TABLE

Drop table if exists #PercentPopulation
Create table #PercentPopulation
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
GrowthInVaccinationsPerDay numeric
)

Insert into #PercentPopulation
Select DA.continent, DA.location, da.date, da.population, va.new_vaccinations, 
sum(convert(float, va.new_vaccinations)) over (partition by da.location order by da.location, da.date) GrowthInVaccinationsPerDay
from PortfolioProject..CovidDeaths DA
join PortfolioProject..CovidVaccination VA
	on DA.location = VA.location
	and DA.date = VA.date
where da.continent is not null
--order by 2,3

Select *, (GrowthInVaccinationsPerDay/population)*100 VTPR
from #PercentPopulation



USE PortfolioProject
-- create view 
Create view PercentPopulation as
Select DA.continent, DA.location, da.date, da.population, va.new_vaccinations, 
sum(convert(float, va.new_vaccinations)) over (partition by da.location order by da.location, da.date) GrowthInVaccinationsPerDay
from PortfolioProject..CovidDeaths DA
join PortfolioProject..CovidVaccination VA
	on DA.location = VA.location
	and DA.date = VA.date
where da.continent is not null
--order by 2,3

Select *
from PercentPopulation