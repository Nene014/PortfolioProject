SELECT *
FROM [Portfolio Project]..CovidDeaths$
where Continent is not null
order by 3,4

--SELECT *
--FROM CovidVaccinations$
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths,population
FROM [Portfolio Project]..CovidDeaths$
order by 1,2

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths$
Where Location like '%states%'
order by 1,2

select Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths$
--Where Location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


select Location, MAX(cast (Total_deaths as int)) as TotalDeathCounts
FROM [Portfolio Project]..CovidDeaths$
--Where Location like '%states%'
where Continent is not null
Group by Location
order by TotalDeathCounts desc

select continent, MAX(cast (Total_deaths as int)) as TotalDeathCounts
FROM [Portfolio Project]..CovidDeaths$
--Where Location like '%states%'
where Continent is not null
Group by Continent
order by TotalDeathCounts desc



select SUM(New_cases) as total_cases, sum(cast(new_deaths as int)) as new_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
FROM [Portfolio Project]..CovidDeaths$
--Where Location like '%states%'
where continent is not null
--group by date
order by 1,2


with PopvsVac (Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

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

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create view PercentPopultionVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopultionVaccinated