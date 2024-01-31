function stimResult =StimRoutine(varargin)
%% get valid wells
[refInfo, refPath] = uigetfile('*.csv','select reference bin to get valid wells',...
     'MultiSelect','off');
firstList = getList('instruction','insert baseline files','multiSelection','off',...
    'folder',refPath,'file',refInfo); %receive the spike list of baseline
dataRaw = firstList.data;
[~,validList, validWells] = cleanData(dataRaw);
cd(refPath)
%% grouping: get the grouping List from extern
listOfGroups = xlsx2mat_grouping('sheetname', 'MEA1', 'nbGroups', 7 ,'variableNames',{'CTRL',...
  'LSD_10','PSI_10','DMT_90','LSD_1','PSI_1','DMT_9'});
nbG = size(listOfGroups,2);
%maxNbWell = size(listOfGroups,1)-1;

%% get data
[baseInfo, basePath] = uigetfile('*.csv','select spike list data',...
    'MultiSelect','on');
if ~iscell(baseInfo)
    baseInfo = cellstr(baseInfo);
end


% STIMULATION
[StimInfo, StimPath] = uigetfile('*.spk','select stimulation data',...
    'MultiSelect','on');
if ~iscell(StimInfo)
    StimInfo = cellstr(StimInfo);
end

%% get valid wells

% firstList = getList('instruction','insert baseline files','multiSelection','off',...
%     'folder',basePath,'file',baseInfo{1}); %receive the spike list of baseline
% dataRaw = firstList.data;
% [~,validList, validWells] = cleanData(dataRaw);

%%
nbSessions = length(baseInfo)/3;
%% preallocating
stimResult=repmat(struct('sessionresults',1),1,nbSessions);

%create naming of groups
emptyInd = cellfun('isempty',listOfGroups(2:end,:));
emptyInd = emptyInd == 0;
nbWellsGroup = sum(emptyInd,1);
idxNames = [1 cumsum(nbWellsGroup(1:end-1))+1];
idxNamesEnd = [idxNames(2:end)-1 sum(nbWellsGroup)];


% create nameing row for wells
wellNames = reshape(listOfGroups(2:end,:),1,[]);
emptyIndex = cellfun('isempty', wellNames);
wellNames(emptyIndex) = [];

PI1_result = cell(nbSessions+2,length(wellNames));
PI1_result(2,:) = wellNames;
PI1_result(1,idxNames) = listOfGroups(1,:);
PI2_result = PI1_result;

maxNbEl_ = 16; %per well
maxWell = max(nbWellsGroup);
maxNbEl = maxNbEl_*maxWell; %total

PSTHdiffGr1 = cell(maxNbEl,nbG,nbSessions);
PSTHdiffGr2 = cell(maxNbEl,nbG,nbSessions);
PSTHdiffGr3 = cell(maxNbEl,nbG,nbSessions);

for s = 1:nbSessions

    fileData = baseInfo(1,[s s+nbSessions s+2*nbSessions]);
    fileStim = StimInfo(1,[s s+nbSessions s+2*nbSessions]);
    result = StimAnalysis_(fileData,fileStim,basePath,StimPath,validList, validWells,1); % 1 = not stim wells are not discarded
    stimResult(s).sessionresults = result;    
    
    
    PI1 = result.potentiationIndex(:,1);  
    PI2 = result.potentiationIndex(:,2);
    PSTHdiff_1 = result.PSTHareaDiff_Stim3To1;
    PSTHdiff_2 = result.PSTHareaDiff_Stim3To2;
    PSTHdiff_3 = result.PSTHareaDiff_Stim2To1;
    
    for gr = 1:nbG
        names = listOfGroups(2:end,gr); %names of wells belonging to that group (given from extern)
        emptyIndex = cellfun('isempty', names);
        names(emptyIndex) = [];
        wellNames = result.wells;       %list of evaluated well names
        
        numbered = arrayfun(@(a) find(strcmp(wellNames,a)), names, 'UniformOutput',false); %position of given well in wellNames
        numbered = cellfun(@(a) replace(a), numbered); %geplace empty fields with 0   
        idxLog = ~isnan(numbered);  %position with a value
        numberedCl = numbered;
        numberedCl(isnan(numberedCl)) = []; %indices of values without zeros
              
        temp = zeros(1,length(idxLog))+1000; %temporary vector, that is inserted into data cell later
        temp(idxLog) = cell2mat(PI1(numberedCl)); 
        temp(temp==1000) = nan;
        PI1_result(s+2,idxNames(gr):idxNamesEnd(gr)) = num2cell(temp);
        
        temp = zeros(1,length(idxLog))+1000; %temporary vector, that is inserted into data cell later
        temp(idxLog) = cell2mat(PI2(numberedCl)); 
        temp(temp==1000) = nan;
        PI2_result(s+2,idxNames(gr):idxNamesEnd(gr)) = num2cell(temp);
        
        % PSTH area difference all electrodes of all wells and sessions pooled per genotype
        temp = PSTHdiff_1(:,numberedCl);
        temp = num2cell(conversion(temp,2));
        PSTHdiffGr1(1:length(temp),gr,s) = temp;
        
        % PSTH area difference all electrodes of all wells and sessions pooled per genotype
        temp = PSTHdiff_2(:,numberedCl);
        temp = num2cell(conversion(temp,2));
        PSTHdiffGr2(1:length(temp),gr,s) = temp;
        
         % PSTH area difference all electrodes of all wells and sessions pooled per genotype
        temp = PSTHdiff_3(:,numberedCl);
        temp = num2cell(conversion(temp,2));
        PSTHdiffGr3(1:length(temp),gr,s) = temp;
     end
end

m = size(PSTHdiffGr1,1)*size(PSTHdiffGr1,3);
n = size(PSTHdiffGr2,1)*size(PSTHdiffGr2,3);
o = size(PSTHdiffGr3,1)*size(PSTHdiffGr3,3);
PSTHdiffRes1 = cell(m,nbG);
PSTHdiffRes2 = cell(n,nbG);
PSTHdiffRes3 = cell(o,nbG);
for gr = 1:nbG
    temp = (conversion(PSTHdiffGr1(:,gr,:),2))';
    temp_ = permute(temp, [1 3 2]);
    PSTHdiffRes1(1:length(temp_),gr) = num2cell(temp_); 
    
    temp = (conversion(PSTHdiffGr2(:,gr,:),2))';
    temp_ = permute(temp, [1 3 2]);
    PSTHdiffRes2(1:length(temp_),gr) = num2cell(temp_);
    
    temp = (conversion(PSTHdiffGr3(:,gr,:),2))';
    temp_ = permute(temp, [1 3 2]);
    PSTHdiffRes3(1:length(temp_),gr) = num2cell(temp_);
end

logI = sum(conversion(PSTHdiffRes1,1),2);
logI(logI ~= 0) = 1;
PSTHdiffRes1=PSTHdiffRes1(logical(logI),:);

logI = sum(conversion(PSTHdiffRes2,1),2);
logI(logI ~= 0) = 1;
PSTHdiffRes2=PSTHdiffRes2(logical(logI),:);

logI = sum(conversion(PSTHdiffRes3,1),2);
logI(logI ~= 0) = 1;
PSTHdiffRes3=PSTHdiffRes3(logical(logI),:);

stimResult(1).Stim3VsStim1 = PI1_result; 
stimResult(1).Stim3VsStim2 = PI2_result; 
stimResult(1).PSTHdiff_stim3Vs1 = PSTHdiffRes1; 
stimResult(1).PSTHdiff_stim3Vs2 = PSTHdiffRes2;
stimResult(1).PSTHdiff_stim2Vs1 = PSTHdiffRes3;
 
%% PI

end

function r = replace(a)
if isempty(a)
    r = nan;
else
    r = a;
end
end