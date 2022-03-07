select top 1000* from coviddeaths
order by 3,4
select top 1000* from covidvaccinations
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2

-- Total Cases VS Total Deaths
-- shows likelihood of dying if you contact covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeaths
where location = 'Italy' and continent is not null
order by 1,2

-- Total Cases VS Population
-- shows what percentage got covid
select location, date, population, total_cases, (total_cases/population)*100 as SickPercentage
from coviddeaths
where continent is not null
--where location = 'Somalia'
order by 1,2

-- Looking at countries with highest infection rate compared to population

select location, population, Max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as SickPercentage
from coviddeaths
--where location = 'Somalia'
where continent is not null
group by location, population
order by SickPercentage desc

-- showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from coviddeaths
--where location = 'Somalia'
where continent is not null
group by location
order by TotalDeathCount desc

-- Lets break things down by continent
--  showing continents with the highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from coviddeaths
where continent is null 
group by location
order by TotalDeathCount desc

--  GLOBAL NUMBERS
-- showing covid cases, covid deaths and death percentage per day worldwide
select date, sum(new_cases) as totalcases,
sum(cast(new_deaths as int)) totaldeaths,
sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from coviddeaths
where continent is not null
group by date
order by 1,2

-- showing total cases, total deaths and deathpercentage worldwide

select sum(new_cases) as totalcases,
sum(cast(new_deaths as int)) totaldeaths,
sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
from coviddeaths
where continent is not null
--group by date
order by 1,2


-- looking at total population vs vaccination


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3


-- to calculate the percentage use CTE

with PopvsVac (continent, location, date, population, new_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100 VacPercentage
from PopvsVac
order by 2,3

-- TEMP TABLE

drop table  #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3


select *, (RollingPeopleVaccinated/population)*100 VacPercentage
from #PercentPopulationVaccinated
order by 2,3


-- Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 2,3

select * from PercentPopulationVaccinated
