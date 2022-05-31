-- בחירת הנתונים מ2 השולחנות שהוספתי וסידור לפי מיקום ותאריך
SELECT * From CovidDeaths 
Order By 3,4
Select * From Covidvaccinations
Order By 3,4

-- בדיקה כמה מקרי מוות מקורונה מתוך סה"כ הנדבקים בישראל
-- הכפלתי ב100 כדי לקבל אחוזים 
Select Location,Date, Population, Total_Cases, Total_Deaths, (Total_Deaths/Total_cases)*100 AS DeathPrecentage
From CovidDeaths
Where location = 'Israel'
Order By 1,2

--מראה אחוז הידבקות בקורונה מתוך סך כל האוכלוסייה
Select Location,Date, Population,Total_Cases, (Total_Cases/Population)*100 AS PrecentPopulationInfected
From CovidDeaths
Where location = 'Israel' 
Order By 1,2

Select Location, Population,MAX(Total_Cases) AS HighestInfectionCount , MAX(Total_Cases/Population)*100 AS PrecentPopulationInfected
From CovidDeaths
Group By Location,population
Order By PrecentPopulationInfected Desc

--  אחוז מצטבר מקסימלי של סה"כ נדבקים בקורונה מתוך סה"כ האוכלוסייה בישראל
Select Location, Population,MAX(Total_Cases) , MAX(Total_Cases/Population)*100 AS PrecentPopulationInfected
From CovidDeaths
Where location = 'Israel' 
Group By Location,population
Order By 1,2

-- אחוז הנדבקים המצטבר הגבוה ביותר בכל מדינה לפי סדר יורד
Select Location,Date, Population,MAX(Total_Cases) AS MaximumCases, MAX(Total_Cases/Population)*100 AS PrecentPopulationInfected
From CovidDeaths
Group By Location,population,Date
Order By PrecentPopulationInfected Desc

-- מדינות עם מקרי המוות הגבוהים ביותר מתוך אוכלוסייה
-- אפשר לראות שישראל מקום 61 בעולם מתוך 209 מדינות
Select Location,Max(cast(Total_Deaths as INT)) AS TotalDeathsCount
from CovidDeaths
Where continent is not null -- הוספתי כדי להיפטר מיבשות שמופיעות בדאטה יחד עם מדינות.
Group BY Location
Order BY TotalDeathsCount Desc


-- מראה מקרי מוות בסדר יורד לפי יבשות
Select Continent,Max(cast(Total_Deaths as INT)) AS TotalDeathsCount
from CovidDeaths
Where continent is not null -- הוספתי כדי להיפטר מיבשות שמופיעות בדאטה יחד עם מדינות.
Group BY Continent
Order BY TotalDeathsCount Desc

-- אחוזי מקרי מוות מתוך אוכלוסייה עבור כל יבשת בסדר יורד
Select Population, Continent,(Max(cast(Total_Deaths as INT))/Population)*100 AS TotalDeathsCount
from CovidDeaths
Where continent is not null -- הוספתי כדי להיפטר מיבשות שמופיעות בדאטה יחד מדינות.
Group BY Population,Continent
Order BY TotalDeathsCount Desc

--2. סה"כ מקרי קורונה עבור כל יבשת
-- -- המדינות שהוצאתי לא כלולות בשאילתות האחרות, הסרתי כדי להישאר עקבי, בנוסף האיחוד האירופי כלול בתוך אירופה
Select Location, SUM(Cast(New_Deaths AS INT)) AS TotalDeathsCount
From CovidDeaths 
Where Continent Is Null
And Location not in ('World', 'European Union', 'International') -- לבודד מדינות
Group By Location 
Order By TotalDeathsCount Desc

-- מראה סה"כ מקרי הדבקה ומקרי מוות באופן גלובאלי עבור כל יום
SELECT Sum(New_Cases) AS Total_Cases, SUM(cast(New_Deaths AS INT))AS Total_Deaths, Sum(Cast(New_Deaths AS INT))/Sum(New_Cases)*100  AS 
DeathPrecentage
From CovidDeaths
where Continent is not null


--סה"כ מקרי הידבקות בקורונה, מוות מקורונה ואחוז מתים מקורונה מסך הנדבקים, במצטבר עד היום
SELECT Sum(New_Cases) AS TotalNewCases, SUM(cast(New_Deaths AS INT))AS NewTotalDeaths, Sum(Cast(New_Deaths AS INT))/Sum(New_Cases)*100  AS 
NewDeathPrecentage
From CovidDeaths
where Continent is not null


--מספר חיסונים חדשים מצטבר עבור כל מדינה לפי תאריך
Select Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_Vaccinations,
SUM(CONVERT(BigInt,Vac.new_vaccinations)) OVER (Partition by Dea.Location order by Dea.Location, Dea.Date)
AS RollingCountNewVaccinations FROM CovidDeaths Dea
Inner Join CovidVaccinations Vac
on Dea.Location= Vac.Location 
AND Dea.Date=Vac.Date
Where Dea.Continent is not null 
order by 2,3


--  סה"כ מס' החיסונים המצטבר בישראל מתאריך 20.12.2020 עד ה30.4.22 
Select Dea.Continent, Dea.Location, Dea.Date, Dea.Population, Vac.New_Vaccinations,
SUM(CONVERT(BigInt,Vac.new_vaccinations)) OVER (Partition by Dea.Location order by Dea.Location, Dea.Date)
AS RollingCountNewVaccinations FROM CovidDeaths Dea
Inner Join CovidVaccinations Vac
on Dea.Location= Vac.Location 
AND Dea.Date=Vac.Date
Where Dea.Continent is not null And Vac.New_Vaccinations is not null And Dea.Location='Israel'
Order BY Date ASC


-- CTE-  על מנת להראות סה"כ אחוז חיסונים מצטברים עבור כל מדינה ביחס לאוכלוסייה
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

-- CTE- על מנת להראות סה"כ אחוז חיסונים מצטברים בישראל ביחס לאוכלוסייה
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

-- להראות את מקסימום החיסונים שנלק במצטבר בכל מדינה
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

--1. מראה סה"כ מקרי הדבקה ומקרי מוות באופן גלובאלי עבור כל יום
SELECT Sum(New_Cases) AS Total_Cases, SUM(cast(New_Deaths AS INT))AS Total_Deaths, Sum(Cast(New_Deaths AS INT))/Sum(New_Cases)*100  AS 
DeathPrecentage
From CovidDeaths
where Continent is not null

--2. סה"כ מקרי קורונה עבור כל יבשת
-- -- המדינות שהוצאתי לא כלולות בשאילתות האחרות, הסרתי כדי להישאר עקבי, בנוסף האיחוד האירופי כלול בתוך אירופה
Group By Location 
Select Location, SUM(Cast(New_Deaths AS INT)) AS TotalDeathsCount
From CovidDeaths 
Where Continent Is Null
And Location not in ('World', 'European Union', 'International') 
Order By TotalDeathsCount Desc

--3. אחוז מצטבר מקסימלי של סה"כ נדבקים בקורונה מתוך סה"כ האוכלוסייה 
Select Location, Population,MAX(Total_Cases) AS HighestInfectionCount , MAX(Total_Cases/Population)*100 AS PrecentPopulationInfected
From CovidDeaths
Group By Location,population
Order By PrecentPopulationInfected Desc


4--מראה באופן גלובאלי כמה חיסונים יש באופן מצטבר עבור כל מדינה בנפרד לפי תאריך
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
