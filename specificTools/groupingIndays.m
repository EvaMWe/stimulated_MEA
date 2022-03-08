function [dataStore] = groupingIndays_SHP2_pre(dataStore)

nbGroups = 4;
nbPeriods = 5;
nbFeatures = length(dataStore);
nbwells = size(dataStore(1).dataArray,1);


for f = 1:nbFeatures
    
    meanData = zeros(nbwells,nbPeriods,nbGroups);
    stdData = zeros(nbwells,nbPeriods,nbGroups);
    
    dataArray= dataStore(f).dataArray;  
    
    t1 = 2:8;
    dataStore(f).day1 = dataArray(:, t1,:);
  
    meanData(:,1,1) =  mean(dataArray(:, t1,1),2,'omitnan');
    meanData(:,1,2) =  mean(dataArray(:, t1,2),2,'omitnan');    
    meanData(:,1,3) =  mean(dataArray(:, t1,3),2,'omitnan');
    meanData(:,1,4) =  mean(dataArray(:, t1,4),2,'omitnan');
    
    stdData(:,1,1) = std(dataArray(:, t1,1),0,2,'omitnan');
    stdData(:,1,2) = std(dataArray(:, t1,2),0,2,'omitnan');
    stdData(:,1,3) = std(dataArray(:, t1,3),0,2,'omitnan');
    stdData(:,1,4) = std(dataArray(:, t1,4),0,2,'omitnan');
    
    t2 = 11:13;
    dataStore(f).day2 = dataArray(:, t2,:);
    meanData(:,2,1) =  mean(dataArray(:, t2,1),2,'omitnan');
    meanData(:,2,2) =  mean(dataArray(:, t2,2),2,'omitnan');    
    meanData(:,2,3) =  mean(dataArray(:, t2,3),2,'omitnan');
    meanData(:,2,4) =  mean(dataArray(:, t2,4),2, 'omitnan');
    
    stdData(:,2,1) = std(dataArray(:, t2,1),0,2,'omitnan');
    stdData(:,2,2) = std(dataArray(:, t2,2),0,2,'omitnan');
    stdData(:,2,3) = std(dataArray(:, t2,3),0,2,'omitnan');
    stdData(:,2,4) = std(dataArray(:, t2,4),0,2,'omitnan');
    
    t3 = 15:17;
    dataStore(f).day3 = dataArray(:,t3,:);
    meanData(:,3,1) =  mean(dataArray(:, t3,1),2,'omitnan');
    meanData(:,3,2) =  mean(dataArray(:, t3,2),2,'omitnan');    
    meanData(:,3,3) =  mean(dataArray(:, t3,3),2,'omitnan');
    meanData(:,3,4) =  mean(dataArray(:, t3,4),2,'omitnan');
    
    stdData(:,3,1) = std(dataArray(:, t3,1),0,2,'omitnan');
    stdData(:,3,2) = std(dataArray(:, t3,2),0,2,'omitnan');
    stdData(:,3,3) = std(dataArray(:, t3,3),0,2,'omitnan');
    stdData(:,3,4) = std(dataArray(:, t3,4),0,2,'omitnan');
    
    t4 = 19:21;
    dataStore(f).day4 = dataArray(:,t4,:);
    meanData(:,4,1) =  mean(dataArray(:, t4,1),2,'omitnan');
    meanData(:,4,2) =  mean(dataArray(:, t4,2),2,'omitnan');    
    meanData(:,4,3) =  mean(dataArray(:, t4,3),2,'omitnan');
    meanData(:,4,4) =  mean(dataArray(:, t4,4),2,'omitnan');
    
    stdData(:,4,1) = std(dataArray(:, t4,1),0,2,'omitnan');
    stdData(:,4,2) = std(dataArray(:, t4,2),0,2,'omitnan');
    stdData(:,4,3) = std(dataArray(:, t4,3),0,2,'omitnan');
    stdData(:,4,4) = std(dataArray(:, t4,4),0,2,'omitnan');
    
    t5 = 19:20;
    dataStore(f).day5 = dataArray(:,t5,:);
    meanData(:,5,1) =  mean(dataArray(:, t5,1),2,'omitnan');
    meanData(:,5,2) =  mean(dataArray(:, t5,2),2,'omitnan');    
    meanData(:,5,3) =  mean(dataArray(:, t5,3),2,'omitnan');
    meanData(:,5,4) =  mean(dataArray(:, t5,4),2,'omitnan');
    
    stdData(:,5,1) = std(dataArray(:, t5,1),0,2,'omitnan');
    stdData(:,5,2) = std(dataArray(:, t5,2),0,2,'omitnan');
    stdData(:,5,3) = std(dataArray(:, t5,3),0,2,'omitnan');
    stdData(:,5,4) = std(dataArray(:, t5,4),0,2,'omitnan');
    
    t6 = 35:37;
    dataStore(f).day5 = dataArray(:,t6,:);
    meanData(:,6,1) =  mean(dataArray(:, t6,1),2,'omitnan');
    meanData(:,6,2) =  mean(dataArray(:, t6,2),2,'omitnan');
    
    stdData(:,6,1) = std(dataArray(:, t6,1),0,2,'omitnan');
    stdData(:,6,2) = std(dataArray(:, t6,2),0,2,'omitnan');  
        
    dataStore(f). meanSum = meanData;
    dataStore(f).stdSum = stdData;
%     
end
end
