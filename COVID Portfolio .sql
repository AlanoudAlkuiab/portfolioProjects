select * from CovidDeaths 


--looking at Total Cases vs Total Deaths 
-- shows the liklehood if you contrat covid in your country
select location , date , total_cases ,total_deaths 
, (total_deaths/total_cases)*100 as DeathPercentage 
from dbo.CovidDeaths
where location like '%states' -- saudi  here 
order by 2;



--looking at Total Cases vs population
--shows what percentage of population got covid 
select location , date , population,total_cases  
, (total_cases/population)*100 as CasesPercentage 
from dbo.CovidDeaths
--where location like '%states'   -- saudi  here 
order by 1,2;



--looking at countries with the highest ifection rate compared to population

select location , population , max(total_cases) HightestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from dbo.CovidDeaths
group by location ,population
order by PercentagePopulationInfected desc


--showing the countries with highest death count per population 

select location  , max(total_deaths) HightestDeathCount 
from CovidDeaths
where continent is not null 
group by location ,population
order by HightestDeathCount desc
--
--select location , population , max(total_deaths) HightestDeathCount, max((total_deaths/population))*100 as PercentagePopulatinDeaths
--from dbo.CovidDeaths
--group by location ,population
--order by PercentagePopulatinDeaths desc


--let's break things by continent 
select continent  , max(total_deaths) HightestDeathCount 
from CovidDeaths
where continent is not null 
group by continent 
order by HightestDeathCount desc




--copy from above and much accurte 
--select location   , max(total_deaths) HightestDeathCount 
--from CovidDeaths
--where continent is  null 
--group by location 
--order by HightestDeathCount desc



--showing the continet with the highest death counts per population 
select continent  , max(total_deaths) HightestDeathCount --, sum(distinct population)
from CovidDeaths 
where continent is not null 
group by continent 
order by HightestDeathCount desc


--global numbers 

select date , sum(new_cases) TotalCasesPerDay ,sum(new_deaths) TotalDeathsPerDay
, sum(new_deaths)/sum(new_cases)*100 as DeathPercentageGlobally 
from dbo.CovidDeaths
--where location like '%states' -- saudi  here 
where continent is not null and new_cases <>0
group by date
order by 1, 2;


---
select sum(new_cases) TotalCasesPerDay ,sum(new_deaths) TotalDeathsPerDay
, sum(new_deaths)/sum(new_cases)*100 as DeathPercentageGlobally 
from dbo.CovidDeaths
--where location like '%states' -- saudi  here 
where continent is not null and new_cases <>0
--group by date
order by 1, 2;

--imaging we are uaing diffrent table  -- i but all the columns into one table 

select * from CovidDeaths

-- join 
-- looking at the totoal population vs the total vaccination

select continent , location , date, population , new_vaccinations , (new_vaccinations/population)*100 vaccinationPercentage
from CovidDeaths
where continent is not null 
order by 2,3


--
select continent , location , date, population , new_vaccinations ,
sum(new_vaccinations)  over ( partition by location order by location,date) as RollingPeopleVaccinated 
from CovidDeaths
where continent is not null 
order by 2,3


--
select continent , location , population , new_vaccinations ,
sum(new_vaccinations)  over ( partition by location order by location,date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths
where continent is not null 
order by 2,3




select continent , location , population , new_vaccinations ,
sum(new_vaccinations)  over ( partition by location order by location,date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths
where continent is not null 
order by 2,3

--using CTE

with PopvsVac (continent, location,Date ,population,new_vaccinations,RollingPeopleVaccinated)
as(
select continent , location , date,population , new_vaccinations ,
sum(new_vaccinations)  over ( partition by location order by location,date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths
where continent is not null 
)
select *,  (RollingPeopleVaccinated/population)*100
from PopvsVac
order by 2,3

--max number of vaccinated people in each contry

with PopvsVac (continent,date,location,population,new_vaccinations,RollingPeopleVaccinated)
as(
select continent,date, location ,population , new_vaccinations ,
sum(new_vaccinations)  over ( partition by location order by location,date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths
where continent is not null 
)
select location, max(RollingPeopleVaccinated/population)*100
from PopvsVac
group by location 
order by 2 desc



--TEMP TALBE 
drop table if exists #PecentPopulationVaccinated

create table #PecentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vacinations numeric,
RollingPeopleVaccinated numeric

)
insert into #PecentPopulationVaccinated
select continent,location,date ,population , new_vaccinations ,
sum(new_vaccinations)  over ( partition by location order by location,date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths
where continent is not null 



select *,  (RollingPeopleVaccinated/population)*100
from #PecentPopulationVaccinated
order by 2,3



--creating View to store data for later visualizations
create view PercentPopulationVaccinated as 
select continent,location,date ,population , new_vaccinations ,
sum(new_vaccinations)  over ( partition by location order by location,date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidDeaths
where continent is not null 




