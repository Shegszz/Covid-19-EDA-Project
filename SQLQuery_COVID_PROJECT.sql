
Select *
From [Portfolio Project]..CovidDeaths$
where continent is not null
order by 3,4


--Select *
--From [Portfolio Project]..CovidVaccinations$
--order by 3,4

--Select data we are going to be using

Select location, date, total_cases, new_cases,total_deaths,population
From [Portfolio Project]..CovidDeaths$
where continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentge
From [Portfolio Project]..CovidDeaths$
where location like '%nigeria%'
and continent is not null
order by 1,2

--looking at the total cases vs population
--shows what percentage of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
From [Portfolio Project]..CovidDeaths$
--where location like '%nigeria%'
order by 1,2

--looking at countries with highest infection rate compared to population


Select location, population, max(total_cases) as  Highest_Infection_Count, max(total_cases/population)*100 AS PercentagePopulationInfected
From [Portfolio Project]..CovidDeaths$
--where location like '%nigeria%'
group by location, population
order by PercentagePopulationInfected desc

--Showing Countries with the highest death count per population


Select location, max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
group by continent
order by TotalDeathCount asc


--Showing the continent with highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
group by continent
order by TotalDeathCount asc



--Global Numbers


Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
From [Portfolio Project]..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
group by date
order by 1,2

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
From [Portfolio Project]..CovidDeaths$
--where location like '%nigeria%'
where continent is not null
--group by date
order by 1,2


--Looking at Total Populaton vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinate
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
    ON dea.Location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3




--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
    ON dea.Location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac 




--Temp Table

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

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
    ON dea.Location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
    ON dea.Location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated