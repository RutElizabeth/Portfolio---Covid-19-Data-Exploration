---- Portfolio of reviewing information, adding different forms of analysis in the tables imported into SQL // Portafolio de revisar informacion, agregar diferentes formas de analisis en las tablas importadas a SQL ----

-- Review information from imported tables // Revisar información de las tablas importadas
select * 
from PortfolioProject.dbo.CovidDeaths

select * 
from PortfolioProject.dbo.CovidVaccinations


select * 
from PortfolioProject.dbo.CovidDeaths
order by 3,4
select * 
from PortfolioProject.dbo.CovidVaccinations
order by 3,4


-- Select Data that we are going to be using // Seleccione los datos que vamos a utilizar
select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.dbo.CovidDeaths
order by 1,2


--- Looking at Total cases vs Total Deaths // Mirando el total de casos frente al total de muertes
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..covidDeaths
order by 1,2


-- Shows likelihood of dying if you contract covid in your country // Muestra la probabilidad de morir si contrae covid en su país
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..covidDeaths
where location like '%states%'
order by 1,2


--- Looking at Total cases vs Population  // Mirando el total de casos frente a la población
--- Shows what percentage of population got Covid // Muestra qué porcentaje de la población contrajo Covid
select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..covidDeaths
where location like '%mbi%'
order by 1,2


--- Total country // País total
select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..covidDeaths
order by 1,2


--- Looking at countries whith highest infection rate compared to population // Mirando los países con la tasa de infección más alta en comparación con la población
select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..covidDeaths
where location like '%mbi%'
order by 1,2


--- Looking at Countries with Highest Infection Rate compared to Population // Mirando los países con la tasa de infección más alta en comparación con la población
select Location, Population, Max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..covidDeaths
group by Location, Population
order by PercentPopulationInfected desc


--- Showing Countries with Highest Death Count per Population // Mostrando países con el mayor recuento de muertes por población
select Location, Max(Total_deaths) as TotalDeathCount
from PortfolioProject..covidDeaths
group by Location
order by TotalDeathCount desc

select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
group by Location
order by TotalDeathCount desc

select * 
from PortfolioProject..covidDeaths
where continent is not null

select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc


---Let's break things down by continent // Desglosemos las cosas por continente
select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc


--- Global numbers // Números globales
select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,  Sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..covidDeaths
where continent is not null
group by date
order by 1,2

select date, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,  Sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--- Looking at total population vs Vaccinations // En cuanto a la población total frente a las vacunas
select*
from PortfolioProject..covidDeaths as D
join PortfolioProject..covidVaccinations as V
    on D.location = V.location
    and D.date = V.date

select D.continent, D.location, D.date, D.population, V.new_vaccinations 
from PortfolioProject..covidDeaths as D
join PortfolioProject..covidVaccinations as V
    on D.location = V.location
    and D.date = V.date
where D.continent is not null
order by 1,2,3


---  USE CTE // USAR CET
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--- Temp Table // Tabla temporal
Drop Table if exists  #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select D.continent, D.location, D.date, D.population, V.new_vaccinations,
Sum(Convert(int, V.new_vaccinations)) over (Partition by D.Location order by D.location, D.Date) as RollingPeopleVaccinated
from PortfolioProject..covidDeaths as D
join PortfolioProject..covidVaccinations as V
    on D.location = V.location
    and D.date = V.date

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--- Creating View to store data from later visualizations // Crear vista para almacenar datos de visualizaciones posteriores

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

