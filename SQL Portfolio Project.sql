Select *
from master..coviddeth$
Where continent is not null
order by 3,4

--Select *
--from master..covidvaccinations$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
from master..coviddeth$
Where continent is not null
order by 1,2

  --looking atTotal Cases vs Total Deth

 alter table dbo.coviddeth$ 
 alter column total_deaths numeric
  alter table dbo.coviddeth$ 
 alter column total_cases numeric

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DethPerecent
from master..coviddeth$
Where location like 'Ukraine'
order by 1,2

--Looking Total Cases vs population
--Shows what percentage of populatione got Covid

Select location, date, population,total_cases, (total_cases/population)*100 as InfectedPercent
from master..coviddeth$
Where location like 'Ukraine'
order by 1,2

-- Looking at countries with highest ifacton rate compared to population

--3 TABLEAU TABLE
Select location, population, max(total_cases) as highestifacton, max((total_cases/population))*100 as MAXInfectedPercent
from master..coviddeth$
Where continent is not null
Group by location,population
order by MAXInfectedPercent	desc

--4 TABLEAU TABLE
Select location, population,date, max(total_cases) as highestifacton, max((total_cases/population))*100 as MAXInfectedPercent
from master..coviddeth$
Where continent is not null
Group by location,population,date
order by MAXInfectedPercent	desc



-- Looking at countries with highest death count 

Select location, max(cast (total_deaths as int)) as TotalDeathCount
from master..coviddeth$
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Let's break things down by continent
-- Showing continent's with highest death count rate compared to population
-- 2 TABLEAU TABLE
Select continent, max(cast (total_deaths as int)) as TotalDeathCount
from master..coviddeth$
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

 alter table dbo.coviddeth$ 
 alter column new_cases numeric
  alter table dbo.coviddeth$ 
 alter column new_deaths numeric
--1 TABLEAU TABLE
Select SUM(new_cases) as SUM_new_cases, SUM(new_deaths) as SUM_new_death, SUM(new_deaths)/SUM(new_cases)*100 as NEWDathPercent
from master..coviddeth$
Where continent is not null
--Group by date
order by 1,2

-- Looking at total population vs vacctinations 

alter table covidvaccinations$
 alter column new_vaccinations numeric

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingpeoplevaccinated
from master..coviddeth$ dea
join covidvaccinations$ vac 
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3 

-- Use cte

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, rollingpeoplevaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingpeoplevaccinated
from master..coviddeth$ dea
join covidvaccinations$ vac 
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3 
)
Select *, (rollingpeoplevaccinated/population)*100
From PopvsVac


-- Temp Table

Drop Table if exists #PercentPeopleVaccinated
Create table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vacctinations numeric,
rollingpeoplevaccinated numeric
)

insert into #PercentPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingpeoplevaccinated
from master..coviddeth$ dea
join covidvaccinations$ vac 
on dea.location = vac.location
and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3 

Select *, (rollingpeoplevaccinated/population)*100
From #PercentPeopleVaccinated

-- Creating View to store data for later visualizations
Create View PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as rollingpeoplevaccinated
from master..coviddeth$ dea
join covidvaccinations$ vac 
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3 
Select *
From PercentPeopleVaccinated