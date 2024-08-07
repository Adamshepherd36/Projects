select *
 FROM [PortfolioProject].[dbo].[Covid Deaths]
 where location = 'High income'
 order by 3,4;

 --Updating the table
 UPDATE [dbo].[Covid Deaths]
SET 
    iso_code = NULLIF(iso_code, ''),
    continent = NULLIF(continent, ''),
    location = NULLIF(location, ''),
    date = NULLIF(date, ''),
    population = NULLIF(population, ''),
    total_cases = NULLIF(total_cases, ''),
    new_cases = NULLIF(new_cases, ''),
    new_cases_smoothed = NULLIF(new_cases_smoothed, ''),
    total_deaths = NULLIF(total_deaths, ''),
    new_deaths = NULLIF(new_deaths, ''),
    new_deaths_smoothed = NULLIF(new_deaths_smoothed, ''),
    total_cases_per_million = NULLIF(total_cases_per_million, ''),
    new_cases_per_million = NULLIF(new_cases_per_million, ''),
    new_cases_smoothed_per_million = NULLIF(new_cases_smoothed_per_million, ''),
    total_deaths_per_million = NULLIF(total_deaths_per_million, ''),
    new_deaths_per_million = NULLIF(new_deaths_per_million, ''),
    new_deaths_smoothed_per_million = NULLIF(new_deaths_smoothed_per_million, ''),
    reproduction_rate = NULLIF(reproduction_rate, ''),
    icu_patients = NULLIF(icu_patients, ''),
    icu_patients_per_million = NULLIF(icu_patients_per_million, ''),
    hosp_patients = NULLIF(hosp_patients, ''),
    hosp_patients_per_million = NULLIF(hosp_patients_per_million, ''),
    weekly_icu_admissions = NULLIF(weekly_icu_admissions, ''),
    weekly_icu_admissions_per_million = NULLIF(weekly_icu_admissions_per_million, ''),
    weekly_hosp_admissions = NULLIF(weekly_hosp_admissions, ''),
    weekly_hosp_admissions_per_million = NULLIF(weekly_hosp_admissions_per_million, '')
WHERE 
    iso_code = '' OR
    continent = '' OR
    location = '' OR
    date = '' OR
    population = '' OR
    total_cases = '' OR
    new_cases = '' OR
    new_cases_smoothed = '' OR
    total_deaths = '' OR
    new_deaths = '' OR
    new_deaths_smoothed = '' OR
    total_cases_per_million = '' OR
    new_cases_per_million = '' OR
    new_cases_smoothed_per_million = '' OR
    total_deaths_per_million = '' OR
    new_deaths_per_million = '' OR
    new_deaths_smoothed_per_million = '' OR
    reproduction_rate = '' OR
    icu_patients = '' OR
    icu_patients_per_million = '' OR
    hosp_patients = '' OR
    hosp_patients_per_million = '' OR
    weekly_icu_admissions = '' OR
    weekly_icu_admissions_per_million = '' OR
    weekly_hosp_admissions = '' OR
    weekly_hosp_admissions_per_million = '';







 EXEC sp_enum_oledb_providers;

 --select *
 --from [PortfolioProject].[dbo].[Covid Vaccinations]
 --order by 3,4

 --Select Data that we are going to be using
 Select location, date, total_cases, new_cases, total_deaths, population
  FROM [PortfolioProject].[dbo].[Covid Deaths]
  order by 1,2

  --Looking at Total Cases vs Total Deaths
  --Shows likelihood of fying if you contract covid in your area
   Select 
		location, 
		date, 
		total_cases, 
		total_deaths,
		(total_deaths/NULLIF(total_cases, 0)) * 100 AS DeathPercentage
  FROM [PortfolioProject].[dbo].[Covid Deaths]
  order by 1,2

  --Looking at Total Cases vs Population
  --Shows what percentage of population got covid
     Select 
		location, 
		date,
		population,
		total_cases, 
		(NULLIF(total_cases, 0)/population) * 100 AS PercentPopulationInfected
  FROM [PortfolioProject].[dbo].[Covid Deaths]
  order by 1,2

  --Looking at Countries with Highest Infection Rate compared to Population
     Select 
		location, 
		MAX(total_cases) as HighestInfectionCount,
		MAX((NULLIF(total_cases, 0)/population)) * 100 AS PercentPopulationInfected
  FROM [PortfolioProject].[dbo].[Covid Deaths]
  Group by Location, Population
  order by PercentPopulationInfected desc


  --Showing Countries with Highest Death Count
       Select 
		continent,
		MAX(Total_deaths) as TotalDeathCount
  FROM [PortfolioProject].[dbo].[Covid Deaths]
  Where continent is not null
  Group by continent
  order by TotalDeathCount desc
  
    --Showing Continents with Highest Death Count and Total
       Select 
		location,
		MAX(Total_deaths) as TotalDeathCount
  FROM [PortfolioProject].[dbo].[Covid Deaths]
  Where continent is null and location not like '%income%'
  Group by Location
  order by TotalDeathCount desc 

  
  --Global Numbers per day
     Select 
		date, 
		SUM(new_cases) AS TotalCases,
		SUM(CAST(new_deaths as int)) as TotalDeaths,
		SUM(CAST(new_deaths AS int))/SUM(New_cases)*100 as DeathPercentage
  FROM [PortfolioProject].[dbo].[Covid Deaths]
  Where continent is not null
  Group By date
  order by 1,2
  ------------------------------------------------------------
 
 --Looking at Total Population vs Vaccinations
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, 
	dea.Date) as RollingPeopleVaccinated,
	(SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) / dea.population) * 100 AS VaccinationPercentage
 FROM [PortfolioProject].[dbo].[Covid Deaths] as dea
 JOIN [PortfolioProject].[dbo].[Covid Vaccinations] as vac
		ON dea.location = vac.location
		and dea.date=vac.date
WHERE dea.continent is not null
order by 2,3


--Select *
--from [PortfolioProject].[dbo].[Covid Vaccinations]


--Use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, 
	dea.Date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
 FROM [PortfolioProject].[dbo].[Covid Deaths] as dea
 JOIN [PortfolioProject].[dbo].[Covid Vaccinations] as vac
		ON dea.location = vac.location
		and dea.date=vac.date
WHERE dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population  varchar(50),
New_vaccinations varchar(50),
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
 Select dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location, 
	dea.Date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
 FROM [PortfolioProject].[dbo].[Covid Deaths] as dea
 JOIN [PortfolioProject].[dbo].[Covid Vaccinations] as vac
		ON dea.location = vac.location
		and dea.date=vac.date
WHERE dea.continent is not null

Select *, (RollingPeopleVaccinated/CONVERT(float, Population))*100
From #PercentPopulationVaccinated

