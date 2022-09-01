select * from [dbo].[CovidDeaths]
Where Continent is not null
order by 3,4

--select * 
--from [dbo].[CovidVaccinations]
--order by 3,4

--select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
From [dbo].[CovidDeaths]
order by 1,2

--Looking at Total cases vs Total deaths
--shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [dbo].[CovidDeaths]
Where location like '%Africa%'
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [dbo].[CovidDeaths]
Where location like '%States%'
order by 1,2

--Looking at Total cases vs Population
--shows what percentage of population got covid

select location, date, population,total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From [dbo].[CovidDeaths]
Where location like '%Africa%'
order by 1,2

select location, date, population,total_cases,(total_cases/population)*100 as PercentagePopulationInfected
From [dbo].[CovidDeaths]
--Where location like '%Africa%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

select location, population,MAX(total_cases)as HighestInfectionCount,MAX((total_cases/population))*100 as PercentagePopulationInfected
From [dbo].[CovidDeaths]
--Where location like '%Africa%'
Group by location, population
order by PercentagePopulationInfected desc

--showing countries with Highest Deathcount Per Population

select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From [dbo].[CovidDeaths]
--Where location like '%States%'
Where Continent is not null
Group by location 
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT


--Showing continent with the Highest Death Count by Population
select Continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From [dbo].[CovidDeaths]
--Where location like '%Africa%'
Where Continent is not null
Group by Continent
order by TotalDeathCount desc


select Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From [dbo].[CovidDeaths]
--Where location like '%Africa%'
Where Continent is null
Group by Location
order by TotalDeathCount desc

--GLOBAL NUMBERS
select date, SUM(new_cases) as Total_cases, SUM(CAST(new_deaths as int)) as Total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [dbo].[CovidDeaths]
Where continent is not null
Group by date
order by 1,2


select  SUM(new_cases) as Total_cases, SUM(CAST(new_deaths as int)) as Total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [dbo].[CovidDeaths]
Where continent is not null
--Group by date
order by 1,2


--JOINS

--Looking at Total Population vs Vaccinations

select * 
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
	 on dea.location = vac.location
	 and dea.date = vac.date


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
	 on dea.location = vac.location
	 and dea.date = vac.date
	 Where dea.continent is not null
	 order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
	 on dea.location = vac.location
	 and dea.date = vac.date
	 Where dea.continent is not null
	 order by 2,3

	 --or

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
	 on dea.location = vac.location
	 and dea.date = vac.date
	 Where dea.continent is not null
	 order by 2,3


	 --USE CTE(COMMON TABLE EXPRESSION)note: if no. of columns in CTE is different from the no.of columns in the brackets, its gonna give you an error.
With popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated --,(RollingPeopleVaccinated/population) * 100
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
	 on dea.location = vac.location
	 and dea.date = vac.date
	 Where dea.continent is not null
	 --order by 2,3
)
select*
From popvsvac


--CTE PERCENTAGE

With popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated --,(RollingPeopleVaccinated/population) * 100
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
	 on dea.location = vac.location
	 and dea.date = vac.date
	 Where dea.continent is not null
	 --order by 2,3
)
select*, (RollingPeopleVaccinated/population)* 100 as RollingPeopleVaccinatedPercentage
From popvsvac



--TEMP TABLE

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated --,(RollingPeopleVaccinated/population) * 100
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
	 on dea.location = vac.location
	 and dea.date = vac.date
	 --Where dea.continent is not null
	 --order by 2,3

select*, (RollingPeopleVaccinated/population)* 100 as RollingPeopleVaccinatedPercentage
From #percentpopulationvaccinated




--creating view to store data for later visualizations

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated --,(RollingPeopleVaccinated/population) * 100
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
	 on dea.location = vac.location
	 and dea.date = vac.date
	 Where dea.continent is not null
	 --order by 2,3

select * from [dbo].[percentpopulationvaccinated]


create view TotalDeathCount as
select Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From [dbo].[CovidDeaths]
--Where location like '%Africa%'
Where Continent is null
Group by Location
--order by TotalDeathCount desc

select * from [dbo].[TotalDeathCount]


create view TotalDeathCountContinent as
select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From [dbo].[CovidDeaths]
--Where location like '%Africa%'
Where Continent is not null
Group by location 
--order by TotalDeathCount desc


select * from [dbo].[TotalDeathCountContinent]

