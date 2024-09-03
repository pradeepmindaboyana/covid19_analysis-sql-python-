
--1.What is the total number of patients diagnosed with COVID-19 (classification 1-3)?
--This question requires counting the number of patients who have a classification value of 1:mild, 2:moderate, or 3:severe.

select clasiffication_final,count(*) as no_of_patients from df_covid19
where clasiffication_final in ('severe_degree_cvpostive','Mild_degree_cvpostive','Moderate_degree_cvpostive')
group by clasiffication_final
order by no_of_patients desc;

--2.How many patients were hospitalized (patient type = 2) and what percentage of them had pneumonia?
--This question asks for the total number of hospitalized patients and the percentage of those who had pneumonia.
--formula for that total =(pneumonia patients who are hospitalized)*100/total pneumonia patients

with cte as(
select count(*) as total_no_patients_pneumonia,
sum(case when patient_type ='hospitalization' then 1 else 0 end) as Hos_patients_with_pneumonia
from df_covid19 
where pneumonia='yes' 
)
select Hos_patients_with_pneumonia,
total_no_patients_pneumonia,
round((cast(Hos_patients_with_pneumonia as float)/total_no_patients_pneumonia)*100,2) as percentage_of_pneumonia 
from cte;

--3.What is the average age of patients who were admitted to the ICU (icu = 1)?
--This requires calculating the average age of patients who were admitted to the ICU.

select round(avg(age),2) as Average_Age_of_ICU_Patients
from df_covid19
where icu='yes';

--4.How many male and female patients were intubated (intubed = 1) during their treatment?
--This asks for a gender breakdown of patients who were intubated.

select sex,count(*) as Number_of_Intubated_Patients from df_covid19
where intubed='yes'
group by sex

--5.What is the distribution of chronic diseases (like diabetes, hipertension, cardiovascular) among patients who died?
--This question requires examining how many patients with specific chronic diseases passed away.

select 
sum(case when diabetes='yes' then 1 else 0 end)as diabetes_patients,
sum(case when hipertension ='yes' then 1 else 0 end)as hypertension_patients,
sum(case when cardiovascular='yes' then 1 else 0 end)as cardiovascular_patients
from df_covid19
where date_died<> '9999-99-99' -- we need to store it in single quote because date_died is str data type and 9999-99-99 represented as not died.

--6.Which medical units have the highest number of COVID-19 positive cases (classification 1-3)?
--This asks for a count of COVID-19 positive cases by medical unit.

select medical_unit,count(*) as covid_patients from df_covid19
where clasiffication_final in ('severe_degree_cvpostive','Mild_degree_cvpostive','Moderate_degree_cvpostive')
group by medical_unit
order by covid_patients desc

--7.How many pregnant patients (pregnancy = 1) were diagnosed with COVID-19, and what was their outcome (home return vs hospitalization)?
--This requires filtering for pregnant patients and analyzing their outcomes.

select patient_type,count(*) as cvpositive_pregnant from df_covid19
where pregnant='yes' and clasiffication_final in ('severe_degree_cvpostive','Mild_degree_cvpostive','Moderate_degree_cvpostive')
group by patient_type;

--8.What percentage of COVID-19 positive patients were smokers (tobacco = 1)?
--This question requires calculating the percentage of COVID-19 positive patients who are smokers.

with cte as(
select count(*) as total_smokers,
sum(case when clasiffication_final in ('severe_degree_cvpostive','Mild_degree_cvpostive','Moderate_degree_cvpostive') then 1 else 0 end) as smokers_with_cvpositive
from df_covid19
where tobacco='yes'
)
select total_smokers,smokers_with_cvpositive,
round((cast(smokers_with_cvpositive as float) / total_smokers)*100,2) as percentage_smokers_with_cvpositive
from cte;

--9.How many patients over the age of 60 were admitted to the ICU and how many of them were intubated?
--This asks for a count of elderly patients admitted to the ICU and how many were intubated.

with cte as(
select 
count(*) as total_elderly_icu_patients,
sum(case when intubed='yes' then 1 else 0 end) as intubated_patients
from df_covid19
where age>60 and icu='yes'
)
select total_elderly_icu_patients,intubated_patients
from cte;

--10.What is the mortality rate among COVID-19 positive patients with chronic renal disease (renal chronic = 1)?
--This question requires determining the mortality rate for patients with chronic renal disease.

select 
(sum(case when date_died <> '9999-99-99' then 1 else 0 end)*100 /count(*)) as mortality_rate
from df_covid19
where renal_chronic='yes' and clasiffication_final in ('severe_degree_cvpostive','Mild_degree_cvpostive','Moderate_degree_cvpostive')


