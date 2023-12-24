select *
from [dbo].[CovidDeaths]
order by 3,4

--Select *
--from [dbo].[CovidVaccinations]

-- Select the data we will be using
Select location, date, total_cases, new_cases, total_deaths,population
from [dbo].[CovidDeaths]
Order by 1,2

-- Looking at total Cases vs Total Deaths
Select location, date, total_cases,total_deaths, (CAST(total_deaths as float)/CAST(total_cases as float))*100 as DeathPercentage
from [dbo].[CovidDeaths]
where location = 'United States'
order by 5 DESC

-- Looking at what percentage of population got covid
select Location, date, total_cases, population,(CAST(total_cases as float)/CAST(population as float))*100
from coviddeaths
order by 1,2

-- looking at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount,MAX((CAST(total_cases as float)/CAST(population as float))*100) as Percentpopulationinfected
from coviddeaths
Group by location, population
order by Percentpopulationinfected DESC

-- showing countries ith highest death count
Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not NULL
Group by continent
Order by TotalDeathCount


-- global

Select sum(new_cases) as totalCases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
--Group by date
order by 1,2



-- with CTE to get percentvaccinated
With Popvsac(continent, location, population, new_vaccinations, RollingPeopleVaccination)
as
(
select dea.continent, dea.location, dea.population, vac.new_vaccinations, SUM(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccination
from CovidDeaths Dea
join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccination/population)*100
from Popvsac


-- With TEMP tables
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccination numeric)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccination
from CovidDeaths Dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select *, (RollingPeopleVaccination/Population)*100
from #PercentPopulationVaccinated


Create view PercentPopulationVaccinated
as
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations, SUM(convert(float,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccination
from CovidDeaths Dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select *
From [dbo].[CovidVaccinations]