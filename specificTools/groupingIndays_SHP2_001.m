function [dataStore] = groupingIndays_SHP2_001(dataStore)

data_scale = dataStore(1).dataArray;

nbGroups = size(data_scale,3);
nbPeriods = 11;
nbFeatures = length(dataStore);
nbwells = size(dataStore(1).dataArray,1);


for f = 1:nbFeatures
    
    meanData = zeros(nbwells,nbPeriods,nbGroups);
    stdData = zeros(nbwells,nbPeriods,nbGroups);
    
    dataArray= dataStore(f).dataArray;  
    
    t1 = 1:4;
    dataStore(f).day1 = dataArray(:, t1,:);
  for ms = 1:nbGroups
      meanData(:,1,ms) = mean(dataArray(:, t1,ms),2,'omitnan');
      stdData(:,1,ms) = std(dataArray(:, t1,ms),0,2,'omitnan');
  end  
  
    
    t2 = 5:9;
    dataStore(f).day2 = dataArray(:, t2,:);
    for ms = 1:nbGroups
      meanData(:,2,ms) = mean(dataArray(:, t2,ms),2,'omitnan');
      stdData(:,2,ms) = std(dataArray(:, t2,ms),0,2,'omitnan');
    end
    
    
    t3 = 10:13;
    dataStore(f).day3 = dataArray(:,t3,:);
    for ms = 1:nbGroups
      meanData(:,3,ms) = mean(dataArray(:, t3,ms),2,'omitnan');
      stdData(:,3,ms) = std(dataArray(:, t3,ms),0,2,'omitnan');
    end   
    
    
    t4 = 14:17;
    dataStore(f).day4 = dataArray(:,t4,:);
    for ms = 1:nbGroups
      meanData(:,4,ms) = mean(dataArray(:, t4,ms),2,'omitnan');
      stdData(:,4,ms) = std(dataArray(:, t4,ms),0,2,'omitnan');
    end   
    
    
    t5 = 18:21;
    dataStore(f).day5 = dataArray(:,t5,:);
    for ms = 1:nbGroups
        meanData(:,5,ms) = mean(dataArray(:, t5,ms),2,'omitnan');
        stdData(:,5,ms) = std(dataArray(:, t5,ms),0,2,'omitnan');
    end
    
    t6 = 22:25;
    dataStore(f).day6 = dataArray(:,t6,:);
    for ms = 1:nbGroups
        meanData(:,6,ms) = mean(dataArray(:, t6,ms),2,'omitnan');
        stdData(:,6,ms) = std(dataArray(:, t6,ms),0,2,'omitnan');
    end
    
    t7 = 26:29;
    dataStore(f).day7 = dataArray(:,t7,:);
    for ms = 1:nbGroups
        meanData(:,7,ms) = mean(dataArray(:, t7,ms),2,'omitnan');
        stdData(:,7,ms) = std(dataArray(:, t7,ms),0,2,'omitnan');
    end
    t8 = 30:33;
    dataStore(f).day8 = dataArray(:,t8,:);
    for ms = 1:nbGroups
        meanData(:,8,ms) = mean(dataArray(:, t8,ms),2,'omitnan');
        stdData(:,8,ms) = std(dataArray(:, t8,ms),0,2,'omitnan');
    end
    t9 = 34:37;
    dataStore(f).day9 = dataArray(:,t9,:);
    for ms = 1:nbGroups
        meanData(:,9,ms) = mean(dataArray(:, t9,ms),2,'omitnan');
        stdData(:,9,ms) = std(dataArray(:, t9,ms),0,2,'omitnan');
    end
    t10 = 38:41;
    dataStore(f).day10 = dataArray(:,t10,:);
    for ms = 1:nbGroups
        meanData(:,10,ms) = mean(dataArray(:, t10,ms),2,'omitnan');
        stdData(:,10,ms) = std(dataArray(:, t10,ms),0,2,'omitnan');
    end
    
    t11 = 42:45;
    dataStore(f).day11 = dataArray(:,t11,:);
    for ms = 1:nbGroups
        meanData(:,11,ms) = mean(dataArray(:, t11,ms),2,'omitnan');
        stdData(:,11,ms) = std(dataArray(:, t11,ms),0,2,'omitnan');
    end
    
    
    
 
        dataStore(f). meanSum = meanData;
        dataStore(f).stdSum = stdData;
%     
end
end