select *
from ProjectPortfolio..CovidDeath
where continent is not null
order by 3, 4

--Выберем данные с которыми мы будем работать 

select location, date, total_cases, new_cases, total_deaths, population
from ProjectPortfolio..CovidDeath
where continent is not null
order by 1, 2

-- total_cases vs total_deaths
-- Показывает вероятность смерти, если вы заразитесь covid в своей стране

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from ProjectPortfolio..CovidDeath
where location like '%Russiá%'
and continent is not null
order by 1, 2

--total_cases vs population
-- Показывает, какой процент населения заражен Covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from ProjectPortfolio..CovidDeath
where location like '%Russia%'
order by 1,2

-- Страны с самым высоким уровнем заражения по сравнению с населением

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from ProjectPortfolio..CovidDeath
--where location like '%Russia%'
group by location, population
order by PercentPopulationInfected desc

--Страны с самым высоким числом смертей на душу населения

select location, max(cast(total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeath
--where location like '%Russia%'
where continent is not null
group by location
order by TotalDeathCount desc

--Показаны континенты с самым высоким числом смертей на население

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeath
--where location like '%Russia%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Глобальные цифры

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from ProjectPortfolio..CovidDeath
where continent is not null
group by date
order by 1, 2

-- total_population vs Vaccinations
-- Показывает процент населения, получившего хотя бы одну вакцину от Covid.

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeath cd
join ProjectPortfolio..CovidVaccination cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3

-- Использование CTE для выполнения расчета по разделу в предыдущем запросе

with PopvsVac ( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeath cd
join ProjectPortfolio..CovidVaccination cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population) * 100
from PopvsVac
