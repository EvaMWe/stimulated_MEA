% this function analysis the evoked MFR upon test stimulus (just one)
% in this seting one SA belongs to one Stim file.
function dataCell =StimRoutine_forTeststim_multi(varargin)
%% *******************Read In Data:******************************
%  FILES FOR SPONTANEOUS AVTIVITY and to get valid wells
%select one file per STIM
nbSessions = 1; 


[SAInfo, SAPath] = uigetfile('*.csv','select files for calculating spontaneous activity',...
     'MultiSelect','on');
if ~iscell(SAInfo)
    SAInfo = cellstr(SAInfo);
end


% STIMULATION DATA FILES
[baseInfo, basePath] = uigetfile('*.csv','select spike list data',...
    'MultiSelect','on');
if ~iscell(baseInfo)
    baseInfo = cellstr(baseInfo);
end


% STIMULATION INFO FILES
[StimInfo, StimPath] = uigetfile('*.spk','select stimulation data',...
    'MultiSelect','on');
if ~iscell(StimInfo)
    StimInfo = cellstr(StimInfo);
end

% NEEDED FOR FINAL GROUPING PER ANIMAL
% listOfGroups = xlsx2mat_grouping('sheetname', 'KRAS-Stim35-forStim', 'nbGroups', 12 ,...
%   'variableNames',{'ms1Stim','ms2Stim','ms3Stim','ms1c','ms2c','ms3c',...
%   'ms4Stim','ms5Stim','ms6Stim','ms4c','ms5c','ms6c'}); %STOP MODIFICATION-PART
%listOfGroups = xlsx2mat_grouping('sheetname', 'SHP2_groupedPmouse', 'nbGroups', 8 ,...
%   'variableNames',{'ms1m','ms2m','ms3wT','ms4m','ms5wT','ms6m','ms7wT','ms8wT'});
%  listOfGroups = xlsx2mat_grouping('sheetname', 'KRASV_groupedPmouse', 'nbGroups', 6 ,...
%    'variableNames',{'ms1wT','ms2m','ms3m','ms4wT','ms5_wT','ms6m'});
%   'ms6Stimm','ms4cm','ms5cwT','ms6cm'}); 
% listOfGroups = xlsx2mat_grouping('sheetname', 'SHP2_groupedPmouse', 'nbGroups',6 ,...
%  'variableNames',{'ms1wT','ms2SHP2','ms3SHP2','ms4wT','ms5','ms6SHP2'}); 
%STOP MODIFICATION-PART

nbstim = length(SAInfo);

%% get valid wells
z = 1;
firstList = getList('instruction','insert baseline files','multiSelection','off',...
    'folder',SAPath,'file',SAInfo{z}); %receive the spike list of baseline
dataRaw = firstList.data;
[~,validList, validWells] = cleanData(dataRaw);
%% compare validWells with listOfGroups
listedWells = listOfGroups(2:end,:);
listedWells = listedWells(:);
listedGroupindex = ismember(validWells,listedWells);
validWells = validWells(listedGroupindex);
   
   
%equal to length of base Info due to just having one teststimulus
nbWells = length(validWells);
%% preallocating
stimResult=repmat(struct('sessionresults',1),1,nbSessions);

%% (1) get spontanous activity
MFRstore = zeros(nbstim,length(validList));

%get MFR from SA
for c = 1:nbstim
    dataStruct = getList('nameList',validList,'multiSelection','off',...
        'folder',SAPath,'file',SAInfo{c});
    data = dataStruct.data;
    electrodeNames = dataStruct.nameElectrodes;
    % get interval
    
    [spiking, ~] = spikeCalcIndiv(data, electrodeNames);
    MFR = spiking.spikeRate;
    MFRstore(c,:) = MFR;    
end

MFRdata = cell(2,nbWells,nbStim); 
MFRdataSA = cell(2,nbWells,nbStim );
%names = repmat(validWells,1,1,nbSessions);

%% Stimulation analysis
for stim = 1:nbStim

    fileData = baseInfo(1,stim);
    fileStim = StimInfo(1,stim);
    
    [MFRrel, MFRSA] = StimAnalysis_oneStim (fileData,fileStim,SAInfo,basePath,StimPath,validList, validWells,MFRstore,1); % 1 = not stim wells are not discarded
    MFRdata(:,:,stim) = MFRrel;  
    MFRdataSA(:,:,stim) = MFRSA;
      
end

%oreallocatinv
meanRelMFR = zeros(1, nbWells);
stdRelMFR = zeros(1, nbWells);
RelCV = zeros(1, nbWells);
RelSkewness = zeros(1, nbWells);

containerMFR = zeros(1,nbWells, nbSessions);
containerSD = zeros(1,nbWells, nbSessions);
containerCV = zeros(1,nbWells, nbSessions);
containerskewness = zeros(1,nbWells, nbSessions);

%average over all electrodes 
for s = 1:nbSessions
    for w = 1:nbWells
            
            temp = MFRdata{2,w,s};
            temp = cell2mat(temp(2:end,:));
            temp(isinf(temp)) = 0;
            meanRelMFR(:,w) = mean(temp,2);
            stdRelMFR(:,w) = std(temp,0,2);
            RelCV(:,w) = stdRelMFR(:,w)./meanRelMFR(:,w);
            RelSkewness(:,w) = mean(((temp-meanRelMFR(:,w))./stdRelMFR(:,w)).^3,2);
        
    end
    containerMFR(:,:,s) = meanRelMFR;
    containerSD(:,:,s) = stdRelMFR;
    containerCV(:,:,s) = RelCV;
    containerskewness(:,:,s) = RelSkewness;
end

%average over the sessions
meanMFR_together = mean(containerMFR,3); %averaged data over all sessions, over all electrodes per well
meanSD_together = mean(containerSD,3); 
meanCV_together = mean(containerCV,3);
meanSkew_together = mean(containerskewness,3);

%% grouping
%wells in gouping list 

dataCell = cell(4,nbWells,3);
dataCell{1,1,1} = 'mean value';
dataCell{1,1,2} = 'coefiicient of variance';
dataCell{1,1,3} = 'skewness';

nbG = size(listOfGroups,2); %number of groups
count =1;
for gr = 1:nbG
    wells = listOfGroups(2:end,gr);  
    %nbVal = length(wells);
    %dataSub = data(2:end,2:end);
    log = zeros(nbWells,1);
    for k = 1:nbWells
        log(k) = sum(strcmp(validWells{k},wells)) >= 1;
    end
    log = logical(log);
    wellNam = validWells(log');
    dataCell{2,count,1} = listOfGroups(1,gr);
    dataCell{2,count,2} = listOfGroups(1,gr);
    dataCell{2,count,3} = listOfGroups(1,gr);
    dataCell(3,count:count + length(wellNam)-1,1) = wellNam;
    dataCell(3,count:count + length(wellNam)-1,2) = wellNam;
    dataCell(3,count:count + length(wellNam)-1,3) = wellNam;
    dataSub1 = meanMFR_together(:,log');
    dataSub2 = meanCV_together(:,log');
    dataSub3 = meanSkew_together(:,log');
    dataCell(4,count:count+length(wellNam)-1,1) = num2cell(dataSub1);
    dataCell(4,count:count+length(wellNam)-1,2) = num2cell(dataSub2);
    dataCell(4,count:count+length(wellNam)-1,3) = num2cell(dataSub3);
    count = count+length(wellNam);
end

%

end

function r = replace(a)
if isempty(a)
    r = nan;
else
    r = a;
end
end


 