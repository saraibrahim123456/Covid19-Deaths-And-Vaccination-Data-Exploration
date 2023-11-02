update  coviddeaths set continent = null where continent=''
select*
from portfolio..covidDeaths



select location,date,total_cases,total_deaths
from portfolio..covidDeaths
order by 1,2
---showing Deathpercentage from covid in the USA
set arithabort off
set ansi_warnings off
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolio..covidDeaths
where location like '%states%'
order by 1,2
alter table portfolio..covidDeaths alter column total_deaths float null


--Showing percentage of population who got covid in the UnitedStates 
select location,date,population,total_cases, (total_deaths/population)*100 as infectionRate
from portfolio..covidDeaths
where location like '%states%'
 

 ---showing countries with Highest infection Rate compared to population 
 
 select location,population,max(total_cases) as HighestInfectioncount, max((total_cases/population))*100 as percentpopulationinfected
from portfolio..covidDeaths
where continent is not null
group by population,location
order by percentpopulationinfected desc 

---countries with highest death count per population 

select 
location,max(total_deaths) as TotalDeathcount
from portfolio..covidDeaths
where continent is not null
group by  location
order by totaldeathcount desc 

---showing continent with highest death count per population
select continent,max(total_deaths) as totaldeathcount
from portfolio..covidDeaths
where continent is not null
group by continent
order by totaldeathcount desc

---Global Numbers
alter table portfolio..coviddeaths alter column new_cases float
select date,sum(new_cases) as totalCases,sum(cast(new_deaths as int)) as totalDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from portfolio..covidDeaths
where continent is not null 
group by date
order by 1,2
 ---Total population vs, Vaccination
 
 --cte
 with popvsvac(continent,location,date,population,new_vaccinations,RollingPeoplevaccinated)
 as
 (
 select dea.continent,dea.location,dea.date,population,vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeoplevaccinated
 from covidvaccinations vac
 join covidDeaths dea
 on vac.date=dea.date
 and vac.location=dea.location
 where dea.continent is not null 
 --order by 2,3
 )
 select*,(RollingPeoplevaccinated/population)*100 from popvsvac
 alter table covidDeaths alter column population float

 --Temp Table 
 drop table if exists #percentpopulationvaccinated
 create table #percentpopulationvaccinated
 (continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population float,
 new_vaccinations float,
 RollingPeoplevaccinated float
 )
 insert into #percentpopulationvaccinated
 select dea.continent,dea.location,dea.date,population,vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeoplevaccinated
 from covidvaccinations vac
 join covidDeaths dea
 on vac.date=dea.date
 and vac.location=dea.location
 where dea.continent is not null 
 --order by 2,3
 select *,RollingPeoplevaccinated/population from #percentpopulationvaccinated
 
 ---create view to store data for visualization

 create view percentpopulationvaccinated as
 select dea.continent,dea.location,dea.date,population,vac.new_vaccinations, sum(convert(float,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeoplevaccinated
 from covidvaccinations vac
 join covidDeaths dea
 on vac.date=dea.date
 and vac.location=dea.location
 where dea.continent is not null 
 --order by 2,3
 select * from 
 percentpopulationvaccinated
 















