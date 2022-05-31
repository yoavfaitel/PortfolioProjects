-- ����� ������� �2 �������� ������� ������ ��� ����� ������
SELECT * From CovidDeaths 
Order By 3,4
Select * From Covidvaccinations
Order By 3,4

-- ����� ��� ���� ���� ������� ���� ��"� ������� ������
-- ������ �100 ��� ���� ������ 
Select Location,Date, Population, Total_Cases, Total_Deaths, (Total_Deaths/Total_cases)*100 AS DeathPrecentage
From CovidDeaths
Where location = 'Israel'
Order By 1,2

--���� ���� ������� ������� ���� �� �� ����������
Select Location,Date, Population,Total_Cases, (Total_Cases/Population)*100 AS PrecentPopulationInfected
From CovidDeaths
Where location = 'Israel' 
Order By 1,2

Select Location, Population,MAX(Total_Cases) AS HighestInfectionCount , MAX(Total_Cases/Population)*100 AS PrecentPopulationInfected
From CovidDeaths
Group By Location,population
Order By PrecentPopulationInfected Desc

--  ���� ����� ������� �� ��"� ������ ������� ���� ��"� ���������� ������
Select Location, Population,MAX(Total_Cases) , MAX(Total_Cases/Population)*100 AS PrecentPopulationInfected
From CovidDeaths
Where location = 'Israel' 
Group By Location,population
Order By 1,2

-- ���� ������� ������ ����� ����� ��� ����� ��� ��� ����
Select Location,Date, Population,MAX(Total_Cases) AS MaximumCases, MAX(Total_Cases/Population)*100 AS PrecentPopulationInfected
From CovidDeaths
Group By Location,population,Date
Order By PrecentPopulationInfected Desc

-- ������ �� ���� ����� ������� ����� ���� ���������
-- ���� ����� ������ ���� 61 ����� ���� 209 ������
Select Location,Max(cast(Total_Deaths as INT)) AS TotalDeathsCount
from CovidDeaths
Where continent is not null -- ������ ��� ������ ������ �������� ����� ��� �� ������.
Group BY Location
Order BY TotalDeathsCount Desc


-- ���� ���� ���� ���� ���� ��� �����
Select Continent,Max(cast(Total_Deaths as INT)) AS TotalDeathsCount
from CovidDeaths
Where continent is not null -- ������ ��� ������ ������ �������� ����� ��� �� ������.
Group BY Continent
Order BY TotalDeathsCount Desc

-- ����� ���� ���� ���� ��������� ���� �� ���� ���� ����
Select Population, Continent,(Max(cast(Total_Deaths as INT))/Population)*100 AS TotalDeathsCount
from CovidDeaths
Where continent is not null -- ������ ��� ������ ������ �������� ����� ��� ������.
Group BY Population,Continent
Order BY TotalDeathsCount Desc

--2. ��"� ���� ������ ���� �� ����
-- -- ������� ������� �� ������ �������� ������, ����� ��� ������ ����, ����� ������ ������� ���� ���� ������
Select Location, SUM(Cast(New_Deaths AS INT)) AS TotalDeathsCount
From CovidDeaths 
Where Continent Is Null
And Location not in ('World', 'European Union', 'International') -- ����� ������
Group By Location 
Order By TotalDeathsCount Desc

-- ���� ��"� ���� ����� ����� ���� ����� ������� ���� �� ���
SELECT Sum(New_Cases) AS Total_Cases, SUM(cast(New_Deaths AS INT))AS Total_Deaths, Sum(Cast(New_Deaths AS INT))/Sum(New_Cases)*100  AS 
DeathPrecentage
From CovidDeaths
where Continent is not null


--��"� ���� ������� �������, ���� ������� ����� ���� ������� ��� �������, ������ �� ����
SELECT Sum(New_Cases) AS TotalNewCases, SUM(cast(New_Deaths AS INT))AS NewTotalDeaths, Sum(Cast(New_Deaths AS INT))/Sum(New_Cases)*100  AS 
NewDeathPrecentage
From CovidDeaths
where Continent is not null


--���� ������� ����� ����� ���� �� ����� ��� �����
Select Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_Vaccinations,
SUM(CONVERT(BigInt,Vac.new_vaccinations)) OVER (Partition by Dea.Location order by Dea.Location, Dea.Date)
AS RollingCountNewVaccinations FROM CovidDeaths Dea
Inner Join CovidVaccinations Vac
on Dea.Location= Vac.Location 
AND Dea.Date=Vac.Date
Where Dea.Continent is not null 
order by 2,3


--  ��"� ��' �������� ������ ������ ������ 20.12.2020 �� �30.4.22 
Select Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_Vaccinations,
SUM(CONVERT(BigInt,Vac.new_vaccinations)) OVER (Partition by Dea.Location order by Dea.Location, Dea.Date)
AS RollingCountNewVaccinations FROM CovidDeaths Dea
Inner Join CovidVaccinations Vac
on Dea.Location= Vac.Location 
AND Dea.Date=Vac.Date
Where Dea.Continent is not null And Vac.New_Vaccinations is not null And Dea.Location='Israel'
Order BY Date ASC


-- CTE-  �� ��� ������ ��"� ���� ������� ������� ���� �� ����� ���� ����������
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

-- CTE- �� ��� ������ ��"� ���� ������� ������� ������ ���� ����������
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

-- ������ �� ������� �������� ���� ������ ��� �����
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

--1. ���� ��"� ���� ����� ����� ���� ����� ������� ���� �� ���
SELECT Sum(New_Cases) AS Total_Cases, SUM(cast(New_Deaths AS INT))AS Total_Deaths, Sum(Cast(New_Deaths AS INT))/Sum(New_Cases)*100  AS 
DeathPrecentage
From CovidDeaths
where Continent is not null

--2. ��"� ���� ������ ���� �� ����
-- -- ������� ������� �� ������ �������� ������, ����� ��� ������ ����, ����� ������ ������� ���� ���� ������
Group By Location 
Select Location, SUM(Cast(New_Deaths AS INT)) AS TotalDeathsCount
From CovidDeaths 
Where Continent Is Null
And Location not in ('World', 'European Union', 'International') 
Order By TotalDeathsCount Desc

--3. ���� ����� ������� �� ��"� ������ ������� ���� ��"� ���������� 
Select Location, Population,MAX(Total_Cases) AS HighestInfectionCount , MAX(Total_Cases/Population)*100 AS PrecentPopulationInfected
From CovidDeaths
Group By Location,population
Order By PrecentPopulationInfected Desc


4--���� ����� ������� ��� ������� �� ����� ����� ���� �� ����� ����� ��� �����
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
