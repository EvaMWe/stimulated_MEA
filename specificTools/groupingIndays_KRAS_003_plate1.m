function [dataStore] = groupingIndays_KRAS_003_plate1(dataStore)

data_scale = dataStore(1).dataArray;

nbGroups = size(data_scale,3);
nbPeriods = 13;
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
    t5 = 18:19 ; %DIV21
    dataStore(f).day5 = dataArray(:,t5,:);
    for ms = 1:nbGroups
        meanData(:,count,ms) = mean(dataArray(:, t5,ms),2,'omitnan');
        stdData(:,count,ms) = std(dataArray(:, t5,ms),0,2,'omitnan');
    end
    
count = count + 1;
    t6 = 20:22; %DIV24
    dataStore(f).day6 = dataArray(:,t6,:);
    for ms = 1:nbGroups
        meanData(:,count,ms) = mean(dataArray(:, t6,ms),2,'omitnan');
        stdData(:,count,ms) = std(dataArray(:, t6,ms),0,2,'omitnan');
    end
    
count = count + 1;
    t7 = 23:24; %DIV28
    dataStore(f).day7 = dataArray(:,t7,:);
    for ms = 1:nbGroups
        meanData(:,count,ms) = mean(dataArray(:, t7,ms),2,'omitnan');
        stdData(:,count,ms) = std(dataArray(:, t7,ms),0,2,'omitnan');
    end

count = count + 1;
    t8 = 25:27; %DIV31
    dataStore(f).day8 = dataArray(:,t8,:);
    for ms = 1:nbGroups
        meanData(:,count,ms) = mean(dataArray(:, t8,ms),2,'omitnan');
        stdData(:,count,ms) = std(dataArray(:, t8,ms),0,2,'omitnan');
    end
    
count = count + 1;    
    t9 = 28:29; %DIV35
    dataStore(f).day9 = dataArray(:,t9,:);
    for ms = 1:nbGroups
        meanData(:,count,ms) = mean(dataArray(:, t9,ms),2,'omitnan');
        stdData(:,count,ms) = std(dataArray(:, t9,ms),0,2,'omitnan');
    end

count = count + 1;
    t10 = 30:31; %DIV37
    dataStore(f).day10 = dataArray(:,t10,:);
    for ms = 1:nbGroups
        meanData(:,count,ms) = mean(dataArray(:, t10,ms),2,'omitnan');
        stdData(:,count,ms) = std(dataArray(:, t10,ms),0,2,'omitnan');
    end
%     
count = count + 1;    
    t11 = 32:35; %DIV41
    dataStore(f).day11 = dataArray(:,t11,:);
    for ms = 1:nbGroups
        meanData(:,count,ms) = mean(dataArray(:, t11,ms),2,'omitnan');
        stdData(:,count,ms) = std(dataArray(:, t11,ms),0,2,'omitnan');
    end
%     
count = count + 1;    
    t12 = 36:37; %DIV48
    dataStore(f).day12 = dataArray(:,t12,:);
    for ms = 1:nbGroups
        meanData(:,count,ms) = mean(dataArray(:, t12,ms),2,'omitnan');
        stdData(:,count,ms) = std(dataArray(:, t12,ms),0,2,'omitnan');
    end
    
count = count + 1;
    t13 = 38:39; %DIV56
    dataStore(f).day13 = dataArray(:,t13,:);
    for ms = 1:nbGroups
        meanData(:,count,ms) = mean(dataArray(:, t13,ms),2,'omitnan');
        stdData(:,count,ms) = std(dataArray(:, t13,ms),0,2,'omitnan');
    end
%  
         dataStore(f). meanSum = meanData;
         dataStore(f).stdSum = stdData;
% %     
end
end
