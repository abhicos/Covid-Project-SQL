use PortfolioProject

select * from CovidDeaths
where continent is not null
order by 3,4;

--select * from CovidVaccinations
--order by 3,4;

-- Select data that we are going to be using.
select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
where continent is not null
order by 1,2;

-- Looking at total cases and total deaths.
-- Shows likelihood of dying if you contract coronavirus in your country.
select location, date, total_cases,  total_deaths, round((convert(float, total_deaths)/convert(float, total_cases))*100, 2) as Deathpercentage
from CovidDeaths
where continent is not null
order by 1,2;
select location, date, total_cases,  total_deaths, round((convert(float, total_deaths)/convert(float, total_cases))*100, 2) as Deathpercentage
from CovidDeaths
where location like '%India%'
order by 1,2;

-- Total cases vs population.
-- Show what percentage of people got Covid in your country.

select location, date, total_cases, population, round((convert(float, total_cases)/convert(float, population))*100, 4) as Infectionpercentage
from CovidDeaths
where location like '%India%'
order by 1,2;

-- Looking at the countries with highest infection rate.
select location, population, max(total_cases) as HighestInfectionCount, max(round((convert(float, total_cases)/convert(float, population)) *100, 2)) as Infectionpercentage
from CovidDeaths
where continent is not null
group by location, population
order by Infectionpercentage desc;

-- Showing countries with the highest death count per population.
select location, max(convert(int, total_deaths)) as HighestDeathCount 
from CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc ;

-- let's break things down by continent.

-- showing continents with the highest death count per population.

select continent, max(convert(int, total_deaths)) as HighestDeathCount 
from CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount desc ;

-- GLOBAL NUMBERS
-- by date
select date, sum(new_cases) as total_new_cases,  sum(cast(new_deaths as int)) as total_new_deaths, 
case 
when sum(new_cases) = 0 then 0
else round((sum(cast(new_deaths as int))/sum(new_cases))*100, 2) 
end as DeathPercetage
from CovidDeaths 
where continent is not null
group by date
order by 1;

-- overall
select  sum(new_cases) as total_new_cases,  sum(cast(new_deaths as int)) as total_new_deaths, 
case 
when sum(new_cases) = 0 then 0
else round((sum(cast(new_deaths as int))/sum(new_cases))*100, 2) 
end as DeathPercetage
from CovidDeaths 
where continent is not null
order by 1;


select * 
from CovidDeaths dea
join CovidVaccinations vac
on dea.date = vac.date and dea.location = vac.location;

-- looking at total population vs Vaccinated population

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeaths dea
join CovidVaccinations vac
on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
order by 1,2,3;

-- providing a new column with rolling count of no of vaccinations for each country


-- using cte to to show rollingpeoplevaccinated percentage.

with PopVsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
)

select *, round((RollingPeopleVaccinated/population) * 100, 2) as RollingPeopleVaccinatedPercent
from PopVsVac
where location = 'India';

-- Creating view to store the data

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
;

create view OverallResultsDeath as 
select  sum(new_cases) as total_new_cases,  sum(cast(new_deaths as int)) as total_new_deaths, 
case 
when sum(new_cases) = 0 then 0
else round((sum(cast(new_deaths as int))/sum(new_cases))*100, 2) 
end as DeathPercetage
from CovidDeaths 
where continent is not null
;

