--Choosing data from 2 tables and ordering by location and date

SELECT * From CovidDeaths 
Order By 3,4
Select * From Covidvaccinations
Order By 3,4

--Total Deaths cases from total Covid cases in Israel

Select Location,Date, Population, Total_Cases, Total_Deaths, (Total_Deaths/Total_cases)*100 AS DeathPrecentage
From CovidDeaths
Where location = 'Israel'
Order By 1,2

-- Covid cases precentage from total population in Israel per day

Select Location,Date, Population,Total_Cases, (Total_Cases/Population)*100 AS PrecentPopulationInfected
From CovidDeaths
Where location = 'Israel' 
Order By 1,2

--Max Precentage of Covid cases from population per locatin
Select Location, Population,MAX(Total_Cases) AS HighestInfectionCount , MAX(Total_Cases/Population)*100 AS PrecentPopulationInfected
From CovidDeaths
Group By Location,population
Order By PrecentPopulationInfected Desc
--
--Max cumulative Covid cases precentage in Israel in descending order
Select Location, Population,MAX(Total_Cases) AS MaxTotalCases , MAX(Total_Cases/Population)*100 AS PrecentPopulationInfected
From CovidDeaths
Where location = 'Israel' 
Group By Location,population
Order By 1,2

-- Max cumulative Covid cases precentage per location in descending order

Select Location,Date, Population,MAX(Total_Cases) AS MaximumCases, MAX(Total_Cases/Population)*100 AS PrecentPopulationInfected
From CovidDeaths
Group By Location,population,Date
Order By PrecentPopulationInfected Desc

--Countries with Max death cases from population
--Israel is ranked 61st out of 209 countries

Select Location,Max(cast(Total_Deaths as INT)) AS TotalDeathsCount
from CovidDeaths
Where continent is not null -- äåñôúé ëãé ìäéôèø îéáùåú ùîåôéòåú áãàèä éçã òí îãéðåú.
Group BY Location
Order BY TotalDeathsCount Desc


-- Death cases from population per continent in descending order
Select Continent,Max(cast(Total_Deaths as INT)) AS TotalDeathsCount
from CovidDeaths
Where continent is not null -- äåñôúé ëãé ìäéôèø îéáùåú ùîåôéòåú áãàèä éçã òí îãéðåú.
Group BY Continent
Order BY TotalDeathsCount Desc

-- Death cases precentage from population per continent in descending order

Select Population, Continent,(Max(cast(Total_Deaths as INT))/Population)*100 AS TotalDeathsCount
from CovidDeaths
Where continent is not null -- äåñôúé ëãé ìäéôèø îéáùåú ùîåôéòåú áãàèä éçã îãéðåú.
Group BY Population,Continent
Order BY TotalDeathsCount Desc

--2. Total Covid cases per each continent
-- -- Excluded countries which not included in other quiries, Ueropean Union is already included in Europe.
Select Location, SUM(Cast(New_Deaths AS INT)) AS TotalDeathsCount
From CovidDeaths 
Where Continent Is Null
And Location not in ('World', 'European Union', 'International') -- ìáåãã îãéðåú
Group By Location 
Order By TotalDeathsCount Desc

-- Shows total Covid cases and total deaths cases per day 
SELECT Sum(New_Cases) AS Total_Cases, SUM(cast(New_Deaths AS INT))AS Total_Deaths, Sum(Cast(New_Deaths AS INT))/Sum(New_Cases)*100  AS 
DeathPrecentage
From CovidDeaths
where Continent is not null


--Total cumulative deaths cases and deaths precentage in relation to total Covid cases

SELECT Sum(New_Cases) AS TotalNewCases, SUM(cast(New_Deaths AS INT))AS NewTotalDeaths, Sum(Cast(New_Deaths AS INT))/Sum(New_Cases)*100  AS 
NewDeathPrecentage
From CovidDeaths
where Continent is not null


--Toal cumulative new vaccinations per location 

Select Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_Vaccinations,
SUM(CONVERT(BigInt,Vac.new_vaccinations)) OVER (Partition by Dea.Location order by Dea.Location, Dea.Date)
AS RollingCountNewVaccinations FROM CovidDeaths Dea
Inner Join CovidVaccinations Vac
on Dea.Location= Vac.Location 
AND Dea.Date=Vac.Date
Where Dea.Continent is not null 
order by 2,3


-- Total cumulative vaccinations in Israel from 20.12.2020 to 30.4.22

Select Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_Vaccinations,
SUM(CONVERT(BigInt,Vac.new_vaccinations)) OVER (Partition by Dea.Location order by Dea.Location, Dea.Date)
AS RollingCountNewVaccinations FROM CovidDeaths Dea
Inner Join CovidVaccinations Vac
on Dea.Location= Vac.Location 
AND Dea.Date=Vac.Date
Where Dea.Continent is not null And Vac.New_Vaccinations is not null And Dea.Location='Israel'
Order BY Date ASC


-- CTE-  cumulative vaccinations in relation to Population 
With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingCountVaccinations)
AS
(
Select Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_Vaccinations,
SUM(CONVERT(BigInt,Vac.new_vaccinations)) OVER (Partition by Dea.Location order by Dea.Location, Dea.Date)
AS RollingCountVaccinations FROM CovidDeaths Dea
Inner Join CovidVaccinations Vac
on Dea.Location= Vac.Location 
AND Dea.Date=Vac.Date
Where Dea.Continent is not null 
--order by 2,3
)
Select *, (RollingCountVaccinations/Population)*100 AS NewVacPrecentFromPop
From PopvsVac
Order by 2,3

-- CTE- cumulative vaccinations in Israel in relation to Population 

With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingCountVaccinations)
AS
(
Select Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_Vaccinations,
SUM(CONVERT(BigInt,Vac.new_vaccinations)) OVER (Partition by Dea.Location order by Dea.Location, Dea.Date)
AS RollingCountVaccinations FROM CovidDeaths Dea
Inner Join CovidVaccinations Vac
on Dea.Location= Vac.Location 
AND Dea.Date=Vac.Date
Where Dea.Continent is not null And Vac.New_Vaccinations is not null And Dea.Location='Israel'
)
Select *, (RollingCountVaccinations/Population)*100 AS NewVacPrecentFromPop
From PopvsVac

-- Max cumulative vaccinations  per location
--Temp Table
Drop Table If Exists #PrecentPopulationVaccinated
Create Table #PrecentPopulationVaccinated
(
Continent Nvarchar (255),
Location Nvarchar (255),
Population numeric,
New_Vaccinations Numeric,
RollingCountVaccinations Numeric
)

Insert Into #PrecentPopulationVaccinated

Select Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_Vaccinations,
SUM(CONVERT(BigInt,Vac.new_vaccinations)) OVER (Partition by Dea.Location order by Dea.Location, Dea.Date)
AS RollingCountNewVaccinations FROM CovidDeaths Dea
Inner Join CovidVaccinations Vac
on Dea.Location= Vac.Location 
AND Dea.Date=Vac.Date
Where Dea.Continent is not null 
order by 2,3

Select *, (RollingCountVaccinations/Population)*100 AS NewVacPrecentFromPop
From #PrecentPopulationVaccinated
GO

if exists( SELECT * FROM SYS.Views
where name= 'PrecentPopulationVaccinated') 
Drop view  PrecentPopulationVaccinated
GO
Create View PrecentPopulationVaccinated AS

Select Dea.Continent, Dea.Location,Dea.Date, Dea.Population, Vac.New_Vaccinations,
SUM(CONVERT(BigInt,Vac.new_vaccinations)) OVER (Partition by Dea.Location order by Dea.Location, Dea.Date)
AS RollingCountNewVaccinations FROM CovidDeaths Dea
Inner Join CovidVaccinations Vac
on Dea.Location= Vac.Location 
AND Dea.Date=Vac.Date
Where Dea.Continent is not null 
--order by 2,3
GO

SELECT * FROM SYS.Views


SELECT * FROM PrecentPopulationVaccinated 


-- VIEWS

--Total Covid cases and total deaths per day 

SELECT Sum(New_Cases) AS Total_Cases, SUM(cast(New_Deaths AS INT))AS Total_Deaths, Sum(Cast(New_Deaths AS INT))/Sum(New_Cases)*100  AS 
DeathPrecentage
From CovidDeaths
where Continent is not null

--2. Total Covid cases per continent

Group By Location 
Select Location, SUM(Cast(New_Deaths AS INT)) AS TotalDeathsCount
From CovidDeaths 
Where Continent Is Null
And Location not in ('World', 'European Union', 'International') 
Order By TotalDeathsCount Desc

--3.Cumulative precentage of total Covid cases in relation to total population per location 

Select Location, Population,MAX(Total_Cases) AS HighestInfectionCount , MAX(Total_Cases/Population)*100 AS PrecentPopulationInfected
From CovidDeaths
Group By Location,population
Order By PrecentPopulationInfected Desc


--4. Shows cumulative vaccinations for each location

Create View PrecentPopulationVaccinated AS

Select Dea.Continent, Dea.Location,Dea.Date, Dea.Population, Vac.New_Vaccinations,
SUM(CONVERT(BigInt,Vac.new_vaccinations)) OVER (Partition by Dea.Location order by Dea.Location, Dea.Date)
AS RollingCountNewVaccinations FROM CovidDeaths Dea
Inner Join CovidVaccinations Vac
on Dea.Location= Vac.Location 
AND Dea.Date=Vac.Date
Where Dea.Continent is not null 
--order by 2,3
GO
