function [dataStore] = groupingIndays_KRAS_003_plate2_Stim21(dataStore)

data_scale = dataStore(1).dataArray;

nbGroups = size(data_scale,3);
nbPeriods = 12;
nbFeatures = length(dataStore);
nbwells = size(dataStore(1).dataArray,1);


for f = 1:nbFeatures
    
    meanData = zeros(nbwells,nbPeriods,nbGroups);
    stdData = zeros(nbwells,nbPeriods,nbGroups);
    
    dataArray= dataStore(f).dataArray;
    
 count =1;   
 
    t1 = 1:4; %DIV7
    dataStore(f).day1 = dataArray(:, t1,:);
  for ms = 1:nbGroups
      meanData(:,count,ms) = mean(dataArray(:, t1,ms),2,'omitnan');
      stdData(:,count,ms) = std(dataArray(:, t1,ms),0,2,'omitnan');
  end  
  
count = count + 1;    
    t2 = 5:8; %DIV10
    dataStore(f).day2 = dataArray(:, t2,:);
    for ms = 1:nbGroups
      meanData(:,count,ms) = mean(dataArray(:, t2,ms),2,'omitnan');
      stdData(:,count,ms) = std(dataArray(:, t2,ms),0,2,'omitnan');
    end
    
count = count + 1;    
    t3 = 9:12; %DIV15
    dataStore(f).day3 = dataArray(:,t3,:);
    for ms = 1:nbGroups
      meanData(:,count,ms) = mean(dataArray(:, t3,ms),2,'omitnan');
      stdData(:,count,ms) = std(dataArray(:, t3,ms),0,2,'omitnan');
    end   
    
count = count + 1;        
    t4 = 13:16; %DIV18
    dataStore(f).day4 = dataArray(:,t4,:);
    for ms = 1:nbGroups
      meanData(:,count,ms) = mean(dataArray(:, t4,ms),2,'omitnan');
      stdData(:,count,ms) = std(dataArray(:, t4,ms),0,2,'omitnan');
    end   
    
count = count + 1;    
    t5 = 19 ; %DIV21
    dataStore(f).day5 = dataArray(:,t5,:);
    for ms = 1:nbGroups
        meanData(:,count,ms) = mean(dataArray(:, t5,ms),2,'omitnan');
        stdData(:,count,ms) = std(dataArray(:, t5,ms),0,2,'omitnan');
    end
    


        dataStore(f). meanSum = meanData;
        dataStore(f).stdSum = stdData;
%     
end
end
