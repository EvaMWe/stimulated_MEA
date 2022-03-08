function [dataStore] = wogroupingJustFormating(dataStore)

data_scale = dataStore(1).dataArray;

nbGroups = size(data_scale,3);
nbPeriods = 4;
nbFeatures = length(dataStore);
nbwells = size(dataStore(1).dataArray,1);


for f = 1:nbFeatures
    
    meanData = zeros(nbwells,nbPeriods,nbGroups);
    %stdData = zeros(nbwells,nbPeriods,nbGroups);
    
    dataArray= dataStore(f).dataArray;  
    
    t1 = 1; %DIV8
    dataStore(f).day1 = dataArray(:, t1,:);
  for ms = 1:nbGroups
      meanData(:,1,ms) = mean(dataArray(:, t1,ms),2,'omitnan');
      %stdData(:,1,ms) = std(dataArray(:, t1,ms),0,2,'omitnan');
  end  
  
    
    t2 = 2; %DIV13
    dataStore(f).day2 = dataArray(:, t2,:);
    for ms = 1:nbGroups
      meanData(:,2,ms) = mean(dataArray(:, t2,ms),2,'omitnan');
      %stdData(:,2,ms) = std(dataArray(:, t2,ms),0,2,'omitnan');
    end
    
    
    t3 = 3; %DIV14
    dataStore(f).day3 = dataArray(:,t3,:);
    for ms = 1:nbGroups
      meanData(:,3,ms) = mean(dataArray(:, t3,ms),2,'omitnan');
      %stdData(:,3,ms) = std(dataArray(:, t3,ms),0,2,'omitnan');
    end   
    
     t4 = 4; %DIV14
    dataStore(f).day4 = dataArray(:,t4,:);
    for ms = 1:nbGroups
      meanData(:,4,ms) = mean(dataArray(:, t4,ms),2,'omitnan');
      %stdData(:,3,ms) = std(dataArray(:, t3,ms),0,2,'omitnan');
    end   
    
    
     
     dataStore(f). meanSum = meanData;
     %dataStore(f).stdSum = stdData;
%     
%     
end
end
