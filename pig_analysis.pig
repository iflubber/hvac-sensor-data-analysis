building = LOAD '/user/cloudera/pig_data/building.csv' using PigStorage(',') AS (BuildingID:chararray,BuildingMgr:chararray,BuildingAge:int,HVACproduct:chararray,Country:chararray);

DESCRIBE building;

hvac = LOAD '/user/cloudera/pig_data/HVAC.csv' using PigStorage(',') AS (Date:chararray,Time:chararray,TargetTemp:int,ActualTemp:int,System:int,SystemAge:int,BuildingID:chararray);

DESCRIBE hvac;

A = LIMIT building 10;
DUMP A;

A = LIMIT hvac 10;
DUMP A;

tempHVACstats = FOREACH hvac GENERATE Date,BuildingID,System,SystemAge,(TargetTemp-ActualTemp) AS temp_diff,(CASE WHEN (TargetTemp-ActualTemp)>5 THEN 'HOT' WHEN (TargetTemp-ActualTemp)<-5 THEN 'COLD' ELSE 'NORMAL' END) AS temp_range,(CASE WHEN (TargetTemp-ActualTemp)>5 THEN 1 WHEN (TargetTemp-ActualTemp)<-5 THEN 1 ELSE 0 END) AS extreme_temp;

DESCRIBE tempHVACstats;

A = LIMIT tempHVACstats 10;
DUMP A;

HVACanalysis = JOIN tempHVACstats BY (BuildingID), building BY (BuildingID);

DESCRIBE HVACanalysis;

A = LIMIT HVACanalysis 10;
DUMP A;

building_hvac_analysis = FOREACH HVACanalysis GENERATE $0 AS date, $1 AS building_id, $2 AS system_id, $3 AS system_age, $4 AS temp_diff, $5 AS temp_range, $6 AS extreme_temp, $8 AS building_mgr, $9 AS building_age, $10 AS hvac_product, $11 AS country;

STORE building_hvac_analysis INTO '/user/cloudera/pig_data/building_hvac_analysis';