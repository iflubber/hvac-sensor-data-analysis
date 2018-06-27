**Project4:**

**Analyzing Machine & Sensor Data**

**Sensor Data:**

A sensor is a device that measures a physical quantity and transforms it
into a digital signal. Sensors are always on, capturing data at a low
cost, and powering the “Internet of Things.”

**Potential Uses of Sensor Data:**

Sensors can be used to collect data from many sources, such as:

To monitor machines or infrastructure such as ventilation equipment,
bridges, energy meters, or airplane engines. This data can be used for
predictive analytics, to repair or replace these items before they
break.

To monitor natural phenomena such as meteorological patterns,
underground pressure during oil extraction, or patient vital statistics
during recovery from a medical procedure.

This case study is about how to refine data from heating, ventilation,
and air conditioning (HVAC) systems using the Cloudera Data Platform,
and how to analyze the refined sensor data to maintain optimal building
temperatures.

**Input Data**

In this case study, we will focus on sensor data from building
operations. Specifically, we will refine and analyze the data from
Heating, Ventilation, Air Conditioning (HVAC) systems in 20 large
buildings around the world

In order to perform analysis, we will use the below data as input data:

**HVAC.csv**–contains the targeted building temperatures, along with
the actual (measured) building temperatures. The building temperature
data was obtained using Apache Flume. Flume can be used as a log
aggregator, collecting log data from many diverse sources and moving it
to a centralized data store. In this case, Flume was used to capture the
sensor log data, which we can now load into the Hadoop Distributed File
System (HFDS).

**building.csv**–contains the “building” database table. Apache Sqoop
can be used to transfer this type of data from a structured database
into HFDS.

**Expected Output:**

We would like to accomplish three goals with this data:

Reduce heating and cooling expenses.

Keep indoor temperatures in a comfortable range between 65-70 degrees.

Identify which HVAC products are reliable, and replace unreliable
equipment with those models.

These analysis will be very helpful for facilities department to
initiate data-driven strategies to reduce energy expenditures and
improve employee comfort.

**Analysis need to be performed:**

1.Data visualization/analysis by mapping the buildings that are most
frequently outside of the optimal temperature range. Calculate count of
extremetemp (i.e. where the temperature was more than five degrees
higher or lower than the target temperature) by each country and
temprange

2.Which country offices run hot (Hot offices can lead to employee
complaints and reduced productivity) and which offices run cold (Cold
offices cause elevated energy expenditures and employee discomfort).
Calculate count of offices run in hot and count of office run in cold by
country.

3.Our data set includes information about the performance of five brands
of HVAC equipment, distributed across many types of buildings in a wide
variety of climates. We can use this data to assess the relative
reliability of the different HVAC models(i.e. We can see that the which
model seems to regulate temperature most reliably and maintain the
appropriate temperature range). Calculate count of extremetemp by
hvacproduct.

***Solution:***

Let’s load the downloaded data into HDFS:

\[cloudera@quickstart \~\]\$ hdfs dfs -put
/home/cloudera/localdata/HVAC/building.csv /user/cloudera/pig\_data/

\[cloudera@quickstart \~\]\$ hdfs dfs -put
/home/cloudera/localdata/HVAC/HVAC.csv /user/cloudera/pig\_data/

\[cloudera@quickstart \~\]\$ hdfs dfs -ls /user/cloudera/pig\_data

-rw-r--r-- 1 cloudera cloudera 240591 2018-06-14 00:18
/user/cloudera/pig\_data/HVAC.csv

-rw-r--r-- 1 cloudera cloudera 544 2018-06-14 00:17
/user/cloudera/pig\_data/building.csv

Create Pig relations using this data:

grunt&gt; **building** = LOAD '/user/cloudera/pig\_data/building.csv'
using PigStorage(',') AS
(BuildingID:chararray,BuildingMgr:chararray,BuildingAge:int,HVACproduct:chararray,Country:chararray);

grunt&gt; DESCRIBE building;

building: {BuildingID: chararray,BuildingMgr: chararray,BuildingAge:
int,HVACproduct: chararray,Country: chararray}

grunt&gt; **hvac** = LOAD '/user/cloudera/pig\_data/HVAC.csv' using
PigStorage(',') AS
(Date:chararray,Time:chararray,TargetTemp:int,ActualTemp:int,System:int,SystemAge:int,BuildingID:chararray);

grunt&gt; DESCRIBE hvac;

hvac: {Date: chararray,Time: chararray,TargetTemp: int,ActualTemp:
int,System: int,SystemAge: int,BuildingID: chararray}

View 10 records from the 2 relations:

grunt&gt; A = LIMIT building 10;

grunt&gt; DUMP A;

(1,M1,25,AC1000,USA)

(2,M2,27,FN39TG,France)

(3,M3,28,JDNS77,Brazil)

(4,M4,17,GG1919,Finland)

(5,M5,3,ACMAX22,Hong Kong)

(6,M6,9,AC1000,Singapore)

(7,M7,13,FN39TG,South Africa)

(8,M8,25,JDNS77,Australia)

(9,M9,11,GG1919,Mexico)

(BuildingID,BuildingMgr,,HVACproduct,Country)

grunt&gt; A = LIMIT hvac 10;

grunt&gt; DUMP A;

(Date,Time,,,,,BuildingID)

(6/1/13,0:00:01,66,58,13,20,4)

(6/2/13,1:00:01,69,68,3,20,17)

(6/3/13,2:00:01,70,73,17,20,18)

(6/4/13,3:00:01,67,63,2,23,15)

(6/5/13,4:00:01,68,74,16,9,3)

(6/6/13,5:00:01,67,56,13,28,4)

(6/7/13,6:00:01,70,58,12,24,2)

(6/8/13,7:00:01,70,73,20,26,16)

(6/9/13,8:00:01,66,69,16,9,9)

Now, refine the data:

-- Calculate 3 new variables – temp\_diff,temp\_range,extreme\_temp

grunt&gt; tempHVACstats = FOREACH hvac GENERATE
Date,BuildingID,System,SystemAge,(TargetTemp-ActualTemp) AS
**temp\_diff**,(CASE WHEN (TargetTemp-ActualTemp)&gt;5 THEN 'HOT' WHEN
(TargetTemp-ActualTemp)&lt;-5 THEN 'COLD' ELSE 'NORMAL' END) AS
**temp\_range**,(CASE WHEN (TargetTemp-ActualTemp)&gt;5 THEN 1 WHEN
(TargetTemp-ActualTemp)&lt;-5 THEN 1 ELSE 0 END) AS **extreme\_temp**;

grunt&gt; DESCRIBE tempHVACstats;

tempHVACstats: {Date: chararray,BuildingID: chararray,System:
int,SystemAge: int,temp\_diff: int,temp\_range: chararray,extreme\_temp:
int}

grunt&gt; A = LIMIT tempHVACstats 10;

grunt&gt; DUMP A;

(Date,BuildingID,,,,,)

(6/1/13,4,13,20,8,HOT,1)

(6/2/13,17,3,20,1,NORMAL,0)

(6/3/13,18,17,20,-3,NORMAL,0)

(6/4/13,15,2,23,4,NORMAL,0)

(6/5/13,3,16,9,-6,COLD,1)

(6/6/13,4,13,28,11,HOT,1)

(6/7/13,2,12,24,12,HOT,1)

(6/8/13,16,20,26,-3,NORMAL,0)

(6/9/13,9,16,9,-3,NORMAL,0)

-- Join the above relation with building relation

grunt&gt; HVACanalysis = JOIN **tempHVACstats** BY (BuildingID),
**building** BY (BuildingID);

grunt&gt; DESCRIBE HVACanalysis;

HVACanalysis: {tempHVACstats::Date: chararray,tempHVACstats::BuildingID:
chararray,tempHVACstats::System: int,tempHVACstats::SystemAge:
int,tempHVACstats::temp\_diff: int,tempHVACstats::temp\_range:
chararray,tempHVACstats::extreme\_temp: int,building::BuildingID:
chararray,building::BuildingMgr: chararray,building::BuildingAge:
int,building::HVACproduct: chararray,building::Country: chararray}

grunt&gt; A = LIMIT HVACanalysis 10;

grunt&gt; DUMP A;

(6/2/13,1,20,28,1,NORMAL,0,1,M1,25,AC1000,USA)

(6/6/13,1,8,4,-1,NORMAL,0,1,M1,25,AC1000,USA)

(6/8/13,1,20,3,-12,COLD,1,1,M1,25,AC1000,USA)

(6/10/13,1,9,17,-1,NORMAL,0,1,M1,25,AC1000,USA)

(6/11/13,1,15,12,9,HOT,1,1,M1,25,AC1000,USA)

(6/12/13,1,4,22,-12,COLD,1,1,M1,25,AC1000,USA)

(6/14/13,1,18,30,-3,NORMAL,0,1,M1,25,AC1000,USA)

(6/20/13,1,19,15,4,NORMAL,0,1,M1,25,AC1000,USA)

(6/25/13,1,14,23,-3,NORMAL,0,1,M1,25,AC1000,USA)

(6/29/13,1,10,30,-9,COLD,1,1,M1,25,AC1000,USA)

-- Prepare the final relation for analysis

grunt&gt; building\_hvac\_analysis = FOREACH HVACanalysis GENERATE \$0
AS date, \$1 AS building\_id, \$2 AS system\_id, \$3 AS system\_age, \$4
AS temp\_diff, \$5 AS temp\_range, \$6 AS extreme\_temp, \$8 AS
building\_mgr, \$9 AS building\_age, \$10 AS hvac\_product, \$11 AS
country;

-- Save the final file for analysis

grunt&gt; STORE building\_hvac\_analysis INTO
'/user/cloudera/pig\_data/building\_hvac\_analysis';

Using the above generated final file, we can do several analysis & data
visualization.

We will do the analysis & visualization in **Tableau** as follows:

![](./screenshots/media/image1.tiff)

![](./screenshots/media/image2.tiff)

![](./screenshots/media/image3.tiff)

![](./screenshots/media/image4.tiff)
