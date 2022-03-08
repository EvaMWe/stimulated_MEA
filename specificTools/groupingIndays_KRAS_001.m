function [dataStore] = groupingIndays_KRAS_001(dataStore)

data_scale = dataStore(1).dataArray;

nbGroups = size(data_scale,3);
nbPeriods = 8;
nbFeatures = length(dataStore);
nbwells = size(dataStore(1).dataArray,1);


for f = 1:nbFeatures
    
    meanData = zeros(nbwells,nbPeriods,nbGroups);
    stdData = zeros(nbwells,nbPeriods,nbGroups);
    
    dataArray= dataStore(f).dataArray;  
    
    t1 = 1:4; %DIV8
    dataStore(f).day1 = dataArray(:, t1,:);
  for ms = 1:nbGroups
      meanData(:,1,ms) = mean(dataArray(:, t1,ms),2,'omitnan');
      stdData(:,1,ms) = std(dataArray(:, t1,ms),0,2,'omitnan');
  end  
  
    
    t2 = 5:8; %DIV12
    dataStore(f).day2 = dataArray(:, t2,:);
    for ms = 1:nbGroups
      meanData(:,2,ms) = mean(dataArray(:, t2,ms),2,'omitnan');
      stdData(:,2,ms) = std(dataArray(:, t2,ms),0,2,'omitnan');
    end
    
    
    t3 = 9:12; %DIV16
    dataStore(f).day3 = dataArray(:,t3,:);
    for ms = 1:nbGroups
      meanData(:,3,ms) = mean(dataArray(:, t3,ms),2,'omitnan');
      stdData(:,3,ms) = std(dataArray(:, t3,ms),0,2,'omitnan');
    end   
        
    t4 = 13:16; %DIV19
    dataStore(f).day4 = dataArray(:,t4,:);
    for ms = 1:nbGroups
      meanData(:,4,ms) = mean(dataArray(:, t4,ms),2,'omitnan');
      stdData(:,4,ms) = std(dataArray(:, t4,ms),0,2,'omitnan');
    end   
    
    
    t5 = 17:18 ; %DIV22
    dataStore(f).day5 = dataArray(:,t5,:);
    for ms = 1:nbGroups
        meanData(:,5,ms) = mean(dataArray(:, t5,ms),2,'omitnan');
        stdData(:,5,ms) = std(dataArray(:, t5,ms),0,2,'omitnan');
    end
    
    t6 = 19:21; %DIV25
    dataStore(f).day6 = dataArray(:,t6,:);
    for ms = 1:nbGroups
        meanData(:,6,ms) = mean(dataArray(:, t6,ms),2,'omitnan');
        stdData(:,6,ms) = std(dataArray(:, t6,ms),0,2,'omitnan');
    end
    
    t7 = 22:24; %DIV28
    dataStore(f).day7 = dataArray(:,t7,:);
    for ms = 1:nbGroups
        meanData(:,7,ms) = mean(dataArray(:, t7,ms),2,'omitnan');
        stdData(:,7,ms) = std(dataArray(:, t7,ms),0,2,'omitnan');
    end
    
    
    t8 = 25:27; %DIV35
    dataStore(f).day8 = dataArray(:,t8,:);
    for ms = 1:nbGroups
        meanData(:,8,ms) = mean(dataArray(:, t8,ms),2,'omitnan');
        stdData(:,8,ms) = std(dataArray(:, t8,ms),0,2,'omitnan');
    end
    
    
    
    dataStore(f). meanSum = meanData;
    dataStore(f).stdSum = stdData;
    %
end
end
