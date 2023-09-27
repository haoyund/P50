# This notebook pre-processes the phenotype data to PLINK readable format

```
from datetime import datetime
import os 
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
```

```
bucket = os.getenv("WORKSPACE_BUCKET")
bucket
```

```
'gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e'
```

Go to the bucket where we store our case and control, move them into local directory

```
!gsutil -u $GOOGLE_PROJECT ls gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806
```

```
gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806/case.csv
gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806/case_ids.tsv
gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806/control.csv
gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806/control_ids.tsv
gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806/test_case.csv
gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806/test_case_ids.tsv
gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806/test_control.csv
gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806/test_control_ids.tsv
```

```
#store paths to case and control in variables 
case_path = 'gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806/case.csv'
case_ids_path = 'gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806/case_ids.tsv'
control_path = 'gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806/control.csv'
control_ids_path = 'gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806/control_ids.tsv'
test_case_path = 'gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806/test_case.csv'
test_case_ids_path = 'gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806/test_case_ids.tsv'
test_control_path = 'gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806/test_control.csv'
test_control_ids_path = 'gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806/test_control_ids.tsv'
```

```
#move case and control to local directory
#only move "test" files when testing out pipeline
!gsutil cp {case_path} .
!gsutil cp {case_ids_path} .
!gsutil cp {control_path} .
!gsutil cp {control_ids_path} .
```

```
Copying gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806/case.csv...
/ [1 files][  1.2 MiB/  1.2 MiB]                                                
Operation completed over 1 objects/1.2 MiB.                                      
Copying gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806/case_ids.tsv...
/ [1 files][ 96.0 KiB/ 96.0 KiB]                                                
Operation completed over 1 objects/96.0 KiB.                                     
Copying gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806/control.csv...
/ [1 files][  5.0 MiB/  5.0 MiB]                                                
Operation completed over 1 objects/5.0 MiB.                                      
Copying gs://fc-secure-c8b84a93-2a47-44c5-bd2c-56358bb9a84e/data/aou/pheno/20230806/control_ids.tsv...
/ [1 files][319.9 KiB/319.9 KiB]                                                
Operation completed over 1 objects/319.9 KiB.
```

```
case_demo = pd.read_csv("case.csv")
case_demo.head()
```


```
0	0	0	0	0	1988-06-15T00:00:00Z	1596947	Black or African American	I prefer not to answer	Not Hispanic or Latino	None	2011-10-18T00:00:00Z	2013-06-04T00:00:00Z	4	3	Opioid abuse, Opioid dependence, Continuous op...	1988-06-15	35	2
1	1	1	1	1	1994-06-15T00:00:00Z	1686051	PMI: Skip	I prefer not to answer	PMI: Skip	I prefer not to answer	2015-10-02T20:23:00Z	2020-11-24T19:44:00Z	53	2	Opioid dependence, Opioid abuse	1994-06-15	29	2
2	2	2	2	2	1971-06-15T00:00:00Z	2726287	White	Male	Not Hispanic or Latino	None	2017-10-26T02:49:21Z	2021-05-11T06:38:55Z	27	3	Opioid dependence in remission, Opioid abuse, ...	1971-06-15	52	2
3	3	3	3	3	1958-06-15T00:00:00Z	3291352	White	Male	Not Hispanic or Latino	None	2007-05-08T00:00:00Z	2022-03-23T11:59:59Z	80	2	Opioid abuse, Opioid dependence	1958-06-15	65	2
4	4	4	4	4	1963-06-15T00:00:00Z	1027261	Black or African American	Gender Identity: Transgender	Not Hispanic or Latino	I prefer not to answer	2009-06-02T00:00:00Z	2009-06-04T11:59:59Z	1	1	Opioid abuse	1963-06-15	60	2
```

```
control_demo = pd.read_csv("control.csv")
control_demo.head()
```


```
0	0	0	0	0	1967-06-15T00:00:00Z	1625463	Black or African American	Female	Not Hispanic or Latino	None	Lifestyle	Recreational Drug Use: Which Drugs Used	Which Drugs Used: Prescription Opioids Use	1	1967-06-15	56	1
1	1	1	1	1	1974-06-15T00:00:00Z	4933067	White	I prefer not to answer	Not Hispanic or Latino	I prefer not to answer	Lifestyle	Recreational Drug Use: Which Drugs Used	Which Drugs Used: Prescription Opioids Use	1	1974-06-15	49	1
2	2	2	2	2	1989-06-15T00:00:00Z	2449537	I prefer not to answer	Not man only, not woman only, prefer not to an...	PMI: Prefer Not To Answer	I prefer not to answer	Lifestyle	Recreational Drug Use: Which Drugs Used	Which Drugs Used: Street Opioids Use	1	1989-06-15	34	1
3	3	3	3	3	1979-06-15T00:00:00Z	1659969	Black or African American	Female	Not Hispanic or Latino	I prefer not to answer	Lifestyle	Recreational Drug Use: Which Drugs Used	Which Drugs Used: Prescription Opioids Use	1	1979-06-15	44	1
4	4	4	4	4	1990-06-15T00:00:00Z	2291241	Black or African American	Male	Not Hispanic or Latino	None	Lifestyle	Recreational Drug Use: Which Drugs Used	Which Drugs Used: Street Opioids Use	1	1990-06-15	33	1
```


```
#take a look at datatypes
case_demo.info()
```

```
<class 'pandas.core.frame.DataFrame'>
RangeIndex: 6144 entries, 0 to 6143
Data columns (total 19 columns):
 #   Column                        Non-Null Count  Dtype 
---  ------                        --------------  ----- 
 0   Unnamed: 0                    6144 non-null   int64 
 1   Unnamed: 0.1                  6144 non-null   int64 
 2   Unnamed: 0.1.1                6144 non-null   int64 
 3   Unnamed: 0.1.1.1              6144 non-null   int64 
 4   Unnamed: 0.1.1.1.1            6144 non-null   int64 
 5   date_of_birth                 6144 non-null   object
 6   person_id                     6144 non-null   int64 
 7   race                          6144 non-null   object
 8   gender                        6144 non-null   object
 9   ethnicity                     6144 non-null   object
 10  sex_at_birth                  6144 non-null   object
 11  condition_start_datetime      6144 non-null   object
 12  condition_end_datetime        6144 non-null   object
 13  opioid_condition_count        6144 non-null   int64 
 14  opioid_conditions_mult_count  6144 non-null   int64 
 15  opioid_conditions             6144 non-null   object
 16  date                          6144 non-null   object
 17  age                           6144 non-null   int64 
 18  has_oud                       6144 non-null   int64 
dtypes: int64(10), object(9)
memory usage: 912.1+ KB
```

```
control_demo.info()
```

```
<class 'pandas.core.frame.DataFrame'>
RangeIndex: 24705 entries, 0 to 24704
Data columns (total 18 columns):
 #   Column              Non-Null Count  Dtype 
---  ------              --------------  ----- 
 0   Unnamed: 0          24705 non-null  int64 
 1   Unnamed: 0.1        24705 non-null  int64 
 2   Unnamed: 0.1.1      24705 non-null  int64 
 3   Unnamed: 0.1.1.1    24705 non-null  int64 
 4   Unnamed: 0.1.1.1.1  24705 non-null  int64 
 5   date_of_birth       24705 non-null  object
 6   person_id           24705 non-null  int64 
 7   race                24705 non-null  object
 8   gender              24705 non-null  object
 9   ethnicity           24705 non-null  object
 10  sex_at_birth        24705 non-null  object
 11  survey              24705 non-null  object
 12  question            24705 non-null  object
 13  answer              24705 non-null  object
 14  control             24705 non-null  int64 
 15  date                24705 non-null  object
 16  age                 24705 non-null  int64 
 17  has_oud             24705 non-null  int64 
dtypes: int64(9), object(9)
memory usage: 3.4+ MB
```

Prepping our covariants for PLINK: sex, age, race, case or control

```
#convert gender and ethnicity to strings
case_demo["sex_at_birth"] = case_demo["sex_at_birth"].astype(str)
case_demo["ethnicity"] = case_demo["ethnicity"].astype(str)
control_demo["sex_at_birth"] = control_demo["sex_at_birth"].astype(str)
control_demo["ethnicity"] = control_demo["ethnicity"].astype(str)
```

```
#calc age
import datetime 

def reformatDate(date):
    d = datetime.datetime.fromisoformat(date.replace('Z', '+00:00'))
    d = d.date()
    return d

def calculateAge(born):
    today = datetime.date.today()
    try:
        birthday = born.replace(year = today.year)
 
    # raised when birth date is February 29
    # and the current year is not a leap year
    except ValueError:
        birthday = born.replace(year = today.year,
                  month = born.month + 1, day = 1)
 
    if birthday > today:
        return today.year - born.year - 1
    else:
        return today.year - born.year
```


```
case_demo["date"] = case_demo["date_of_birth"].apply(reformatDate)
case_demo["age"] = case_demo["date"].apply(calculateAge)
control_demo["date"] = control_demo["date_of_birth"].apply(reformatDate)
control_demo["age"] = control_demo["date"].apply(calculateAge)
```

```
case_demo.head()
```

```
0	0	0	0	0	1988-06-15T00:00:00Z	1596947	Black or African American	I prefer not to answer	Not Hispanic or Latino	None	2011-10-18T00:00:00Z	2013-06-04T00:00:00Z	4	3	Opioid abuse, Opioid dependence, Continuous op...	1988-06-15	35	2
1	1	1	1	1	1994-06-15T00:00:00Z	1686051	PMI: Skip	I prefer not to answer	PMI: Skip	I prefer not to answer	2015-10-02T20:23:00Z	2020-11-24T19:44:00Z	53	2	Opioid dependence, Opioid abuse	1994-06-15	29	2
2	2	2	2	2	1971-06-15T00:00:00Z	2726287	White	Male	Not Hispanic or Latino	None	2017-10-26T02:49:21Z	2021-05-11T06:38:55Z	27	3	Opioid dependence in remission, Opioid abuse, ...	1971-06-15	52	2
3	3	3	3	3	1958-06-15T00:00:00Z	3291352	White	Male	Not Hispanic or Latino	None	2007-05-08T00:00:00Z	2022-03-23T11:59:59Z	80	2	Opioid abuse, Opioid dependence	1958-06-15	65	2
4	4	4	4	4	1963-06-15T00:00:00Z	1027261	Black or African American	Gender Identity: Transgender	Not Hispanic or Latino	I prefer not to answer	2009-06-02T00:00:00Z	2009-06-04T11:59:59Z	1	1	Opioid abuse	1963-06-15	60	2
```


```
control_demo.head()
```


```
0	0	0	0	0	1967-06-15T00:00:00Z	1625463	Black or African American	Female	Not Hispanic or Latino	None	Lifestyle	Recreational Drug Use: Which Drugs Used	Which Drugs Used: Prescription Opioids Use	1	1967-06-15	56	1
1	1	1	1	1	1974-06-15T00:00:00Z	4933067	White	I prefer not to answer	Not Hispanic or Latino	I prefer not to answer	Lifestyle	Recreational Drug Use: Which Drugs Used	Which Drugs Used: Prescription Opioids Use	1	1974-06-15	49	1
2	2	2	2	2	1989-06-15T00:00:00Z	2449537	I prefer not to answer	Not man only, not woman only, prefer not to an...	PMI: Prefer Not To Answer	I prefer not to answer	Lifestyle	Recreational Drug Use: Which Drugs Used	Which Drugs Used: Street Opioids Use	1	1989-06-15	34	1
3	3	3	3	3	1979-06-15T00:00:00Z	1659969	Black or African American	Female	Not Hispanic or Latino	I prefer not to answer	Lifestyle	Recreational Drug Use: Which Drugs Used	Which Drugs Used: Prescription Opioids Use	1	1979-06-15	44	1
4	4	4	4	4	1990-06-15T00:00:00Z	2291241	Black or African American	Male	Not Hispanic or Latino	None	Lifestyle	Recreational Drug Use: Which Drugs Used	Which Drugs Used: Street Opioids Use	1	1990-06-15	33	1
```


```
#plot distribution of gender and ethnicity
fig, (ax1, ax2, ax3, ax4) = plt.subplots(1,4, figsize=(60,5))
sns.histplot(case_demo["sex_at_birth"], ax=ax1).set(title="case sex")
sns.histplot(case_demo["gender"], ax=ax2).set(title="case gender") 
sns.histplot(control_demo["sex_at_birth"], ax=ax3).set(title="control sex")
sns.histplot(control_demo["gender"], ax=ax4).set(title="control gender")
plt.show()
```

```
#we'll use "sex_at_birth", but only "Female" and "Male"
#create a column that identifies cases and controls; same column name in order to sucessfully merge the two later
#PLINK recognizes "1" as control, "2" as case
```

```
case_demo["has_oud"] = "2"
case_demo.head()
```


```
0	0	0	0	0	1988-06-15T00:00:00Z	1596947	Black or African American	I prefer not to answer	Not Hispanic or Latino	None	2011-10-18T00:00:00Z	2013-06-04T00:00:00Z	4	3	Opioid abuse, Opioid dependence, Continuous op...	1988-06-15	35	2
1	1	1	1	1	1994-06-15T00:00:00Z	1686051	PMI: Skip	I prefer not to answer	PMI: Skip	I prefer not to answer	2015-10-02T20:23:00Z	2020-11-24T19:44:00Z	53	2	Opioid dependence, Opioid abuse	1994-06-15	29	2
2	2	2	2	2	1971-06-15T00:00:00Z	2726287	White	Male	Not Hispanic or Latino	None	2017-10-26T02:49:21Z	2021-05-11T06:38:55Z	27	3	Opioid dependence in remission, Opioid abuse, ...	1971-06-15	52	2
3	3	3	3	3	1958-06-15T00:00:00Z	3291352	White	Male	Not Hispanic or Latino	None	2007-05-08T00:00:00Z	2022-03-23T11:59:59Z	80	2	Opioid abuse, Opioid dependence	1958-06-15	65	2
4	4	4	4	4	1963-06-15T00:00:00Z	1027261	Black or African American	Gender Identity: Transgender	Not Hispanic or Latino	I prefer not to answer	2009-06-02T00:00:00Z	2009-06-04T11:59:59Z	1	1	Opioid abuse	1963-06-15	60	2
```

```
control_demo["has_oud"] = "1"
control_demo.head(5)
```


```
0	0	0	0	0	1967-06-15T00:00:00Z	1625463	Black or African American	Female	Not Hispanic or Latino	None	Lifestyle	Recreational Drug Use: Which Drugs Used	Which Drugs Used: Prescription Opioids Use	1	1967-06-15	56	1
1	1	1	1	1	1974-06-15T00:00:00Z	4933067	White	I prefer not to answer	Not Hispanic or Latino	I prefer not to answer	Lifestyle	Recreational Drug Use: Which Drugs Used	Which Drugs Used: Prescription Opioids Use	1	1974-06-15	49	1
2	2	2	2	2	1989-06-15T00:00:00Z	2449537	I prefer not to answer	Not man only, not woman only, prefer not to an...	PMI: Prefer Not To Answer	I prefer not to answer	Lifestyle	Recreational Drug Use: Which Drugs Used	Which Drugs Used: Street Opioids Use	1	1989-06-15	34	1
3	3	3	3	3	1979-06-15T00:00:00Z	1659969	Black or African American	Female	Not Hispanic or Latino	I prefer not to answer	Lifestyle	Recreational Drug Use: Which Drugs Used	Which Drugs Used: Prescription Opioids Use	1	1979-06-15	44	1
4	4	4	4	4	1990-06-15T00:00:00Z	2291241	Black or African American	Male	Not Hispanic or Latino	None	Lifestyle	Recreational Drug Use: Which Drugs Used	Which Drugs Used: Street Opioids Use	1	1990-06-15	33	1
```


```
#do the same to the "ids.tsv" files
#load in case, add column "case" and set all values to 2
case = pd.read_csv("case_ids.tsv", delimiter="\t")
```


```
case["has_oud"] = "2"
case.head(5)
```


```
1596947	1596947	2
1686051	1686051	2
2726287	2726287	2
3291352	3291352	2
1027261	1027261	2
```


```
#load in control, add column "case" and set all values to 1
control = pd.read_csv("control_ids.tsv", delimiter="\t")
```


```
control["has_oud"] = "1"
control.head(5)
```

```
1625463	1625463	1
4933067	4933067	1
2449537	2449537	1
1659969	1659969	1
2291241	2291241	1
```


```
#save case and control demo as csv files back to bucket
case_demo.to_csv("case.csv")
control_demo.to_csv("control.csv")
```

```
!gsutil -m cp case.csv control.csv {bucket}/data/aou/pheno/20230806
```


```
Copying file://case.csv [Content-Type=text/csv]...
Copying file://control.csv [Content-Type=text/csv]...                           
- [2/2 files][  6.3 MiB/  6.3 MiB] 100% Done                                    
Operation completed over 2 objects/6.3 MiB.                                      
!gsutil -m cat {bucket}/data/aou/pheno/20230806/case.csv | head
,Unnamed: 0,Unnamed: 0.1,Unnamed: 0.1.1,Unnamed: 0.1.1.1,Unnamed: 0.1.1.1.1,date_of_birth,person_id,race,gender,ethnicity,sex_at_birth,condition_start_datetime,condition_end_datetime,opioid_condition_count,opioid_conditions_mult_count,opioid_conditions,date,age,has_oud
0,0,0,0,0,0,1988-06-15T00:00:00Z,1596947,Black or African American,I prefer not to answer,Not Hispanic or Latino,None,2011-10-18T00:00:00Z,2013-06-04T00:00:00Z,4,3,"Opioid abuse, Opioid dependence, Continuous opioid dependence",1988-06-15,35,2
1,1,1,1,1,1,1994-06-15T00:00:00Z,1686051,PMI: Skip,I prefer not to answer,PMI: Skip,I prefer not to answer,2015-10-02T20:23:00Z,2020-11-24T19:44:00Z,53,2,"Opioid dependence, Opioid abuse",1994-06-15,29,2
2,2,2,2,2,2,1971-06-15T00:00:00Z,2726287,White,Male,Not Hispanic or Latino,None,2017-10-26T02:49:21Z,2021-05-11T06:38:55Z,27,3,"Opioid dependence in remission, Opioid abuse, Opioid dependence",1971-06-15,52,2
3,3,3,3,3,3,1958-06-15T00:00:00Z,3291352,White,Male,Not Hispanic or Latino,None,2007-05-08T00:00:00Z,2022-03-23T11:59:59Z,80,2,"Opioid abuse, Opioid dependence",1958-06-15,65,2
4,4,4,4,4,4,1963-06-15T00:00:00Z,1027261,Black or African American,Gender Identity: Transgender,Not Hispanic or Latino,I prefer not to answer,2009-06-02T00:00:00Z,2009-06-04T11:59:59Z,1,1,Opioid abuse,1963-06-15,60,2
5,5,5,5,5,5,1954-06-15T00:00:00Z,1728944,White,Gender Identity: Additional Options,Not Hispanic or Latino,None,2015-11-04T00:00:00Z,2016-03-15T00:00:00Z,2,1,Continuous opioid dependence,1954-06-15,69,2
6,6,6,6,6,6,1999-06-15T00:00:00Z,2366246,White,"Not man only, not woman only, prefer not to answer, or skipped",Not Hispanic or Latino,None,2018-11-15T17:40:00Z,2018-11-15T17:40:00Z,1,1,Opioid abuse,1999-06-15,24,2
7,7,7,7,7,7,1979-06-15T00:00:00Z,1357846,White,Male,Not Hispanic or Latino,Intersex,2015-08-08T12:28:00Z,2020-09-09T18:59:00Z,26,3,"Opioid abuse, Continuous opioid dependence, Opioid dependence",1979-06-15,44,2
8,8,8,8,8,8,1986-06-15T00:00:00Z,1179190,None of these,Gender Identity: Non Binary,What Race Ethnicity: Race Ethnicity None Of These,Intersex,2022-05-12T23:21:15Z,2022-05-12T23:21:15Z,1,1,Opioid abuse,1986-06-15,37,2
```


```
#create a new dataframe for covariates and start formatting it for PLINK
covar_cases = (case_demo[["person_id","has_oud", "sex_at_birth", "age" ]])

#PLINK recognizes 1 as male, 2 as female
covar_cases.loc[covar_cases["sex_at_birth"] == "Male", "sex_at_birth"] = "1"
covar_cases.loc[covar_cases["sex_at_birth"] == "Female", "sex_at_birth"] = "2"

#renaming "sex_at_birth" column to "is_male".
#If sex is not 1 or 2, meaning its not "Male" nor "Female", then change the entry to 0. This is necessary in order to generate it into a PLINK readable format
covar_cases = covar_cases.rename(columns={'sex_at_birth': 'is_male'})
covar_cases.loc[(covar_cases["is_male"] != "1") & (covar_cases["is_male"] != "2"), "is_male"] = "0"
```


```
covar_cases.head(5)
```


```
/opt/conda/lib/python3.7/site-packages/pandas/core/indexing.py:1817: SettingWithCopyWarning: 
A value is trying to be set on a copy of a slice from a DataFrame.
Try using .loc[row_indexer,col_indexer] = value instead

See the caveats in the documentation: https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html#returning-a-view-versus-a-copy
  self._setitem_single_column(loc, value, pi)
1596947	2	0	35
1686051	2	0	29
2726287	2	0	52
3291352	2	0	65
1027261	2	0	60
```


```
#generating a new df to populate wiht cases informatoin, and inserting family ID column
cases_final = covar_cases
cases_final.insert(0, "FID", cases_final.person_id)
cases_final.head(5)
```


```
1596947	1596947	2	0	35
1686051	1686051	2	0	29
2726287	2726287	2	0	52
3291352	3291352	2	0	65
1027261	1027261	2	0	60
```

```
#complete the same steps to reformat the control data 
covar_control = (control_demo[["person_id","has_oud", "sex_at_birth", "age"]])

covar_control.loc[covar_control["sex_at_birth"] == "Male", "sex_at_birth"] = "1"
covar_control.loc[covar_control["sex_at_birth"] == "Female", "sex_at_birth"] = "2"
covar_control = covar_control.rename(columns={'sex_at_birth': 'is_male'})
covar_control.loc[(covar_control["is_male"] != "1") & (covar_control["is_male"] != "2"), "is_male"] = "0"

covar_control.head(5)
```


```
/opt/conda/lib/python3.7/site-packages/pandas/core/indexing.py:1817: SettingWithCopyWarning: 
A value is trying to be set on a copy of a slice from a DataFrame.
Try using .loc[row_indexer,col_indexer] = value instead

See the caveats in the documentation: https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html#returning-a-view-versus-a-copy
  self._setitem_single_column(loc, value, pi)
1625463	1	0	56
4933067	1	0	49
2449537	1	0	34
1659969	1	0	44
2291241	1	0	33
```


```
#generating a final df for the control information

control_final = covar_control
control_final.insert(0, "FID", control_final.person_id)
control_final.head()
1625463	1625463	1	0	56
4933067	4933067	1	0	49
2449537	2449537	1	0	34
1659969	1659969	1	0	44
2291241	2291241	1	0	33
```


```
#to analyze within PLINK it is necessary to merge the cases and control phenotypes into one phenotype file, and read the new file into python
#combine case and contorl dataframes into data.tsv
data = pd.concat([cases_final, control_final])
#data = data.rename(columns={'person_id': 'IID'})
data.to_csv('data.tsv', index=False, sep='\t')
data.info()
```


```
<class 'pandas.core.frame.DataFrame'>
Int64Index: 30849 entries, 0 to 24704
Data columns (total 5 columns):
 #   Column     Non-Null Count  Dtype 
---  ------     --------------  ----- 
 0   FID        30849 non-null  int64 
 1   person_id  30849 non-null  int64 
 2   has_oud    30849 non-null  object
 3   is_male    30849 non-null  object
 4   age        30849 non-null  int64 
dtypes: int64(3), object(2)
memory usage: 1.4+ MB
```


```
#change data types; necessary step for PLINK
data["FID"] = data["FID"].astype(int)
data["person_id"] = data["person_id"].astype(int)
data["has_oud"] = data["has_oud"].astype(int)
data["is_male"] = data["is_male"].astype(int)
data = data.fillna(0)
data.head()
```


```
1596947	1596947	2	0	35
1686051	1686051	2	0	29
2726287	2726287	2	0	52
3291352	3291352	2	0	65
1027261	1027261	2	0	60
```

```
#computng the ancestry pca
!gsutil -u $GOOGLE_PROJECT cp gs://fc-aou-datasets-controlled/v7/wgs/short_read/snpindel/aux/ancestry/ancestry_preds.tsv .
```

```
Copying gs://fc-aou-datasets-controlled/v7/wgs/short_read/snpindel/aux/ancestry/ancestry_preds.tsv...
\ [1 files][ 96.7 MiB/ 96.7 MiB]                                                
Operation completed over 1 objects/96.7 MiB.
```

```
ancestry_pred = pd.read_csv("ancestry_preds.tsv", delimiter="\t")
ancestry_pred.head(5)
```

```
1000004	eur	[0.0, 0.0, 0.01, 0.99, 0.0, 0.0]	[0.10051663592874799, 0.1360249193403286, -0.0...	eur
1000033	eur	[0.0, 0.0, 0.01, 0.99, 0.0, 0.0]	[0.09828612276613305, 0.12465899985829886, -0....	eur
1000039	afr	[1.0, 0.0, 0.0, 0.0, 0.0, 0.0]	[-0.26592708178595414, 0.004729216912298321, -...	afr
1000042	afr	[0.98, 0.01, 0.0, 0.0, 0.0, 0.01]	[-0.25547433413383014, 0.005969157650966834, 0...	afr
1000045	eas	[0.0, 0.0, 1.0, 0.0, 0.0, 0.0]	[0.09727124534081225, -0.15845581375982454, -0...	eas
```


```
#extract cols we need
ancestry_pred["pca_features"] = ancestry_pred["pca_features"].str[1:-1]

PCs = ancestry_pred["pca_features"].str.split(",", n = 16, expand = True)
PCs = PCs.astype(float)

pid = ancestry_pred[["research_id"]]
pid.head(5)

columns = ["PC1","PC2","PC3","PC4","PC5","PC6","PC7","PC8","PC9","PC10","PC11","PC12","PC13","PC14","PC15","PC16"]
PCs.columns = columns
```

```
#concat ids and pcs into one dataframe
PCs_final = pd.concat([pid, PCs], axis = 1)
PCs_final.head(5)
```

```
1000004	0.100517	0.136025	-0.006317	0.052249	0.003265	0.016336	0.016028	-0.002148	-0.001439	0.001007	0.001428	-0.000513	0.000050	-0.000664	0.000859	-0.001316
1000033	0.098286	0.124659	-0.009625	0.043192	0.003481	0.020772	0.022588	-0.002583	-0.001346	0.000062	-0.000137	0.000462	0.000482	0.000705	0.000607	0.000818
1000039	-0.265927	0.004729	-0.001065	0.001808	0.031469	0.002316	0.006266	0.013233	-0.001833	0.002631	-0.001643	0.006893	0.003547	0.002388	0.004751	0.004297
1000042	-0.255474	0.005969	0.002745	0.008753	0.010249	0.009687	-0.000693	-0.002679	0.010450	0.006879	0.003765	-0.003041	-0.002768	0.000905	0.002441	0.005669
1000045	0.097271	-0.158456	-0.043939	0.034949	-0.000316	-0.004195	-0.003381	0.000809	-0.000132	-0.000836	0.000206	0.000180	0.000095	-0.000599	0.000456	-0.000737
```

```
#get ancestry_pred column for pcs graph
PCs_with_race = pd.concat([PCs_final, ancestry_pred.ancestry_pred], axis = 1)
PCs_with_race.head(5)
```


```
1000004	0.100517	0.136025	-0.006317	0.052249	0.003265	0.016336	0.016028	-0.002148	-0.001439	0.001007	0.001428	-0.000513	0.000050	-0.000664	0.000859	-0.001316	eur
1000033	0.098286	0.124659	-0.009625	0.043192	0.003481	0.020772	0.022588	-0.002583	-0.001346	0.000062	-0.000137	0.000462	0.000482	0.000705	0.000607	0.000818	eur
1000039	-0.265927	0.004729	-0.001065	0.001808	0.031469	0.002316	0.006266	0.013233	-0.001833	0.002631	-0.001643	0.006893	0.003547	0.002388	0.004751	0.004297	afr
1000042	-0.255474	0.005969	0.002745	0.008753	0.010249	0.009687	-0.000693	-0.002679	0.010450	0.006879	0.003765	-0.003041	-0.002768	0.000905	0.002441	0.005669	afr
1000045	0.097271	-0.158456	-0.043939	0.034949	-0.000316	-0.004195	-0.003381	0.000809	-0.000132	-0.000836	0.000206	0.000180	0.000095	-0.000599	0.000456	-0.000737	eas
```


```
#merge data with pcs
data_final = data.merge(PCs_final, left_on = "person_id", right_on = "research_id", how = "left").drop(["research_id"], axis = 1)
data_final.head(5)
```


```
1596947	1596947	2	0	35	-0.223920	0.021011	-0.002759	0.009253	0.008981	...	0.013730	0.006873	0.002107	0.006481	0.016159	-0.002512	-0.000201	-0.007459	-0.004949	0.002006
1686051	1686051	2	0	29	0.092675	0.129767	-0.015348	0.037817	0.001213	...	0.004816	-0.001004	-0.000282	-0.000743	-0.000120	-0.000146	0.000465	0.001239	-0.000444	0.001409
2726287	2726287	2	0	52	0.098861	0.125435	-0.011342	0.047728	0.001623	...	0.024384	-0.004746	-0.001938	0.000168	0.000313	-0.000089	-0.000255	-0.000881	0.000880	-0.000488
3291352	3291352	2	0	65	0.091231	0.122021	-0.009065	0.038350	0.000950	...	0.000482	0.000300	0.000150	0.000368	-0.000736	0.000294	0.001625	-0.000649	0.000837	-0.000244
1027261	1027261	2	0	60	-0.202754	0.024971	0.000387	0.015254	-0.002987	...	0.016666	0.000567	0.012631	0.010386	0.000026	0.005272	0.001205	-0.000741	0.000234	-0.001047
5 rows × 21 columns
```


```
data_final_with_race = data.merge(PCs_with_race, left_on = "person_id", right_on = "research_id", how = "left").drop(["research_id"], axis = 1)
data_final_with_race.head(5)
```


```
1596947	1596947	2	0	35	-0.223920	0.021011	-0.002759	0.009253	0.008981	...	0.006873	0.002107	0.006481	0.016159	-0.002512	-0.000201	-0.007459	-0.004949	0.002006	afr
1686051	1686051	2	0	29	0.092675	0.129767	-0.015348	0.037817	0.001213	...	-0.001004	-0.000282	-0.000743	-0.000120	-0.000146	0.000465	0.001239	-0.000444	0.001409	eur
2726287	2726287	2	0	52	0.098861	0.125435	-0.011342	0.047728	0.001623	...	-0.004746	-0.001938	0.000168	0.000313	-0.000089	-0.000255	-0.000881	0.000880	-0.000488	eur
3291352	3291352	2	0	65	0.091231	0.122021	-0.009065	0.038350	0.000950	...	0.000300	0.000150	0.000368	-0.000736	0.000294	0.001625	-0.000649	0.000837	-0.000244	eur
1027261	1027261	2	0	60	-0.202754	0.024971	0.000387	0.015254	-0.002987	...	0.000567	0.012631	0.010386	0.000026	0.005272	0.001205	-0.000741	0.000234	-0.001047	afr
5 rows × 22 columns
```


```
data_final_with_race.shape
```

```
(30849, 22)
```


```
fam = pd.read_csv("plink/clinvar.chr1.fam", delimiter = "\t",
                  names = ["A","B","C","D","E","F"])
fam.head(3)
```


```
0	1000004	0	0	0	NaN
0	1000033	0	0	0	NaN
0	1000039	0	0	0	NaN
```


```
data_new = fam.merge(data_final, left_on = "B", right_on = "person_id", how = "left")
data_new.head()
```


```
0	1000004	0	0	0	NaN	NaN	NaN	NaN	NaN	...	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
0	1000033	0	0	0	NaN	NaN	NaN	NaN	NaN	...	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
0	1000039	0	0	0	NaN	NaN	NaN	NaN	NaN	...	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
0	1000042	0	0	0	NaN	NaN	NaN	NaN	NaN	...	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
0	1000045	0	0	0	NaN	NaN	NaN	NaN	NaN	...	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
5 rows × 27 columns
```


```
data_out = data_new.iloc[:,np.r_[1,1,8:26]]
data_out = data_out.fillna(0)
data_out.columns.values[1] = "person_id"
data_out.head(3)
```


```
1000004	1000004	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0
1000033	1000033	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0
1000039	1000039	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0
```


```
#remove duplicates
data_out2 = data_out.drop_duplicates()
data_out2["person_id"] = data_out2["person_id"].astype(int)
data_out2["has_oud"] = data_out2["has_oud"].astype(int)
data_out2["is_male"] = data_out2["is_male"].astype(int)
data_out2["age"] = data_out2["age"].astype(int)
```

```
/opt/conda/lib/python3.7/site-packages/ipykernel_launcher.py:1: SettingWithCopyWarning: 
A value is trying to be set on a copy of a slice from a DataFrame.
Try using .loc[row_indexer,col_indexer] = value instead

See the caveats in the documentation: https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html#returning-a-view-versus-a-copy
  """Entry point for launching an IPython kernel.
/opt/conda/lib/python3.7/site-packages/ipykernel_launcher.py:2: SettingWithCopyWarning: 
A value is trying to be set on a copy of a slice from a DataFrame.
Try using .loc[row_indexer,col_indexer] = value instead

See the caveats in the documentation: https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html#returning-a-view-versus-a-copy
  
/opt/conda/lib/python3.7/site-packages/ipykernel_launcher.py:3: SettingWithCopyWarning: 
A value is trying to be set on a copy of a slice from a DataFrame.
Try using .loc[row_indexer,col_indexer] = value instead

See the caveats in the documentation: https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html#returning-a-view-versus-a-copy
  This is separate from the ipykernel package so we can avoid doing imports until
/opt/conda/lib/python3.7/site-packages/ipykernel_launcher.py:4: SettingWithCopyWarning: 
A value is trying to be set on a copy of a slice from a DataFrame.
Try using .loc[row_indexer,col_indexer] = value instead

See the caveats in the documentation: https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html#returning-a-view-versus-a-copy
  after removing the cwd from sys.path.
```



```
data_sex = data_out2[["B", "person_id", "is_male"]]
data_sex["person_id"] = data_sex["person_id"].astype(int)
data_sex["is_male"] = data_sex["is_male"].astype(int)
```


```
/opt/conda/lib/python3.7/site-packages/ipykernel_launcher.py:2: SettingWithCopyWarning: 
A value is trying to be set on a copy of a slice from a DataFrame.
Try using .loc[row_indexer,col_indexer] = value instead

See the caveats in the documentation: https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html#returning-a-view-versus-a-copy
  
/opt/conda/lib/python3.7/site-packages/ipykernel_launcher.py:3: SettingWithCopyWarning: 
A value is trying to be set on a copy of a slice from a DataFrame.
Try using .loc[row_indexer,col_indexer] = value instead

See the caveats in the documentation: https://pandas.pydata.org/pandas-docs/stable/user_guide/indexing.html#returning-a-view-versus-a-copy
  This is separate from the ipykernel package so we can avoid doing imports until
```



```
#save data_sex to the bucket
data_sex.to_csv("data_sex.tsv", index = False, header = False, sep = "\t")
!gsutil cp 'data_sex.tsv' {bucket}/data/
```



```
Copying file://data_sex.tsv [Content-Type=text/tab-separated-values]...
| [1 files][  4.2 MiB/  4.2 MiB]                                                
Operation completed over 1 objects/4.2 MiB.
```


```                            
#save data_out to the bucket
data_out2.to_csv("data.tsv", index = False, header = False, sep = "\t")
!gsutil cp 'data.tsv' {bucket}/data/
```

```
Copying file://data.tsv [Content-Type=text/tab-separated-values]...
/ [1 files][ 25.9 MiB/ 25.9 MiB]    1.6 MiB/s                                   
Operation completed over 1 objects/25.9 MiB.
```


```
data_out2.head()
```


```
1000004	1000004	0	0	0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0
1000033	1000033	0	0	0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0
1000039	1000039	0	0	0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0
1000042	1000042	0	0	0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0
1000045	1000045	0	0	0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0
```


```
data_final_with_race.head(10)
```

```
1596947	1596947	2	0	35	-0.223920	0.021011	-0.002759	0.009253	0.008981	...	0.006873	0.002107	0.006481	0.016159	-0.002512	-0.000201	-0.007459	-0.004949	0.002006	afr
1686051	1686051	2	0	29	0.092675	0.129767	-0.015348	0.037817	0.001213	...	-0.001004	-0.000282	-0.000743	-0.000120	-0.000146	0.000465	0.001239	-0.000444	0.001409	eur
2726287	2726287	2	0	52	0.098861	0.125435	-0.011342	0.047728	0.001623	...	-0.004746	-0.001938	0.000168	0.000313	-0.000089	-0.000255	-0.000881	0.000880	-0.000488	eur
3291352	3291352	2	0	65	0.091231	0.122021	-0.009065	0.038350	0.000950	...	0.000300	0.000150	0.000368	-0.000736	0.000294	0.001625	-0.000649	0.000837	-0.000244	eur
1027261	1027261	2	0	60	-0.202754	0.024971	0.000387	0.015254	-0.002987	...	0.000567	0.012631	0.010386	0.000026	0.005272	0.001205	-0.000741	0.000234	-0.001047	afr
1728944	1728944	2	0	69	0.097280	0.115156	-0.008369	0.040848	0.003600	...	-0.006224	-0.001345	-0.001110	-0.000505	0.000466	0.001296	0.000463	0.001723	0.000078	eur
2366246	2366246	2	0	24	0.100272	0.129232	-0.012481	0.044731	0.002098	...	-0.005731	-0.000991	0.000402	-0.000166	0.000502	-0.000938	-0.000634	-0.000419	-0.000173	eur
1357846	1357846	2	0	44	0.097326	0.124577	-0.014838	0.045447	0.003053	...	-0.004733	-0.000904	-0.000828	-0.001366	-0.000173	0.001052	-0.000979	0.000700	-0.000422	eur
1179190	1179190	2	0	37	0.094456	0.105596	0.018094	0.032938	0.000264	...	-0.001177	0.000071	-0.000863	-0.000651	0.000791	-0.001019	0.000190	0.000394	0.000642	amr
1007578	1007578	2	0	43	0.096361	0.127208	-0.011386	0.044691	0.002225	...	-0.004492	-0.000574	-0.000838	0.000244	-0.000902	0.000147	-0.001043	0.000261	0.000474	eur
10 rows × 22 columns
```



Filtering out ancestry outliers based on a standard deviation of 3 or more greater than the gropu mean through PCA


```
data_final_race = subset(data_final_with_race, (data_final_with_race$PC1 < mean(het$HET_RATE)-3*sd(het$HET_RATE)) | (het$HET_RATE > mean(het$HET_RATE)+3*sd(het$HET_RATE)));
het_fail$HET_DST = (het_fail$HET_RATE-mean(het$HET_RATE))/sd(het$HET_RATE);
data_ancestry = data_final_with_race[data_final_with_race["PC1"] ]
```

Graph PCs for ancestry

```
plt.figure(figsize=(12,7))
 
sns.scatterplot(data=data_final_with_race, 
                x="PC1", 
                y="PC2", 
                hue="ancestry_pred")
 
plt.title("Figure 1",
          fontsize=16)
plt.xlabel('First Principal Component',
           fontsize=16)
plt.ylabel('Second Principal Component',
           fontsize=16)
Text(0, 0.5, 'Second Principal Component')
```



Separate data into racial groups based on ancestry data

```
afr = data_final_with_race.loc[data_final_with_race['ancestry_pred'] == "afr"]
afr.to_csv("afr.tsv", index = False, header = False, sep = "\t")
afr.shape
```

```
(6910, 22)
```


```
afr.head(10)
```


```
1596947	1596947	2	0	35	-0.223920	0.021011	-0.002759	0.009253	0.008981	...	0.006873	0.002107	0.006481	0.016159	-0.002512	-0.000201	-0.007459	-0.004949	0.002006	afr
1027261	1027261	2	0	60	-0.202754	0.024971	0.000387	0.015254	-0.002987	...	0.000567	0.012631	0.010386	0.000026	0.005272	0.001205	-0.000741	0.000234	-0.001047	afr
2044793	2044793	2	0	27	-0.060353	0.075351	-0.007798	0.028739	0.013354	...	0.001612	-0.002909	-0.006931	-0.001043	-0.003507	-0.000265	0.005719	0.004615	-0.004803	afr
2960648	2960648	2	0	31	-0.058281	0.079829	-0.003139	0.033748	0.018417	...	-0.002241	0.000785	0.005114	0.003417	-0.000115	0.001352	0.001855	-0.003191	-0.000311	afr
1493514	1493514	2	1	63	-0.286454	0.000172	0.001692	0.002726	0.005131	...	0.007433	-0.001149	0.005611	-0.007774	-0.006353	-0.006375	-0.003041	0.000150	0.000849	afr
1450821	1450821	2	1	66	-0.255961	0.009172	0.003003	0.008391	0.029956	...	0.001028	0.006933	0.001779	-0.011073	0.013339	0.002957	0.001673	-0.004725	0.007119	afr
2597029	2597029	2	1	65	-0.247393	0.010785	-0.001549	0.005552	0.014031	...	0.001654	-0.001882	0.006953	0.004431	-0.005755	0.003324	0.000976	0.001354	-0.001199	afr
1582553	1582553	2	1	49	-0.288243	0.004015	0.001755	0.007503	0.024040	...	0.017111	-0.005325	-0.000190	0.001386	0.006295	0.000408	0.004040	0.001965	0.004800	afr
1641795	1641795	2	1	59	-0.248157	0.005951	0.002166	0.002611	-0.001284	...	0.013066	-0.004508	-0.009945	-0.002228	-0.000751	-0.005572	-0.005273	0.005655	0.007071	afr
1640630	1640630	2	1	59	-0.145510	0.038420	-0.006612	0.013007	0.005893	...	0.005176	0.008416	-0.002357	0.002641	-0.004304	-0.005656	0.004268	0.001078	-0.005290	afr
10 rows × 22 columns
```


```
import statistics
#afr_filtered = afr[afr["PC1" == statistics.stdev("PC1",)]]
#calculate the mean of each group 
#afr_mean = statsistics.mean(data_final_with_race[])

afr_mean = data_final_with_race.loc[data_final_with_race['ancestry_pred'] == "afr", 'PC1'].mean()
eur_mean = data_final_with_race.loc[data_final_with_race['ancestry_pred'] == "eur", 'PC1'].mean()
amr_mean = data_final_with_race.loc[data_final_with_race['ancestry_pred'] == "amr", 'PC1'].mean()
eas_mean = data_final_with_race.loc[data_final_with_race['ancestry_pred'] == "eas", 'PC1'].mean()
mid_mean = data_final_with_race.loc[data_final_with_race['ancestry_pred'] == "mid", 'PC1'].mean()
sas_mean = data_final_with_race.loc[data_final_with_race['ancestry_pred'] == "sas", 'PC1'].mean()
afr_mean
```

```
-0.23811641335631856
```


```
#calculating group means
def mean(df, group):
    mean = df.loc[df['ancestry_pred'] == group, 'PC1'].mean()
    mean2 = df.loc[df['ancestry_pred'] == group, 'PC2'].mean()
    return mean, mean2
def removing_outliers(df, column):
    
    #calculating group means
    mean = df.loc[df['ancestry_pred'] == group, 'PC1'].mean()
    mean2 = df.loc[df['ancestry_pred'] == group, 'PC2'].mean()
    stdv = df.loc[df['ancestry_pred'] == group, 'PC1'].std()
    stdv = df.loc[df['ancestry_pred'] == group, 'PC1'].std()
    
    #defining bounds
    greater_bound= mean +3 *stdv
    greater_bound2 = mean +3 *stdv
    lower_bound = mean +3 *stdv
    lower_bound = mean +3 *stdv
```


```    
mean(data_final_with_race, "afr")
```

```
(-0.23811641335631856, 0.01353138442672207)
```


```
amr = data_final_with_race.loc[data_final_with_race['ancestry_pred'] == "amr"]
amr.to_csv("amr.tsv", index = False, header = False, sep = "\t")
amr.shape
```

```
(4465, 22)
```


```
eur = data_final_with_race.loc[data_final_with_race['ancestry_pred'] == "eur"]
eur.to_csv("eur.tsv", index = False, header = False, sep = "\t")
eur.shape
```


```
(18920, 22)
```


```
eas = data_final_with_race.loc[data_final_with_race['ancestry_pred'] == "eas"]
eas.to_csv("eas.tsv", index = False, header = False, sep = "\t")
eas.shape
```


```
(298, 22)
```

```
mid = data_final_with_race.loc[data_final_with_race['ancestry_pred'] == "mid"]
mid.to_csv("mid.tsv", index = False, header = False, sep = "\t")
mid.shape
```


```
(49, 22)
```


```
sas = data_final_with_race.loc[data_final_with_race['ancestry_pred'] == "sas"]
sas.to_csv("sas.tsv", index = False, header = False, sep = "\t")
sas.shape
```


```
(207, 22)
```

#ld score regression
