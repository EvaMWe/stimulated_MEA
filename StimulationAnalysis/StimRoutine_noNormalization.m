function dataCell =StimRoutine_noNormalization(varargin)
%% ********************User INPUT********************************
nbstim = 3;

%% *******************Read In Data:******************************
%  FILES FOR SPONTANEOUS AVTIVITY and to get valid wells
%select one file per STIM
[SAInfo, SAPath] = uigetfile('*.csv','select one SA file for getting valid wells');
cd(SAPath);


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

% ENTER SAVING PATH
[reportFile,reportPath] = uiputfile('.xlsx','Save As...');

%% NEEDED FOR FINAL GROUPING PER ANIMAL
listOfGroups = xlsx2mat_grouping('sheetname', 'SHP2-firstGrouping', 'nbGroups',7 ,...
 'variableNames',{'1','2','3','4','5','6','7'});  %STOP MODIFICATION-PART
%listOfGroups = xlsx2mat_grouping('sheetname', 'SHP2_groupedPmouse', 'nbGroups', 8 ,...
%   'variableNames',{'ms1m','ms2m','ms3wT','ms4m','ms5wT','ms6m','ms7wT','ms8wT'});
%   listOfGroups = xlsx2mat_grouping('sheetname', 'KRASV_groupedPmouse', 'nbGroups', 6 ,...
%     'variableNames',{'ms1wT','ms2m','ms3m','ms4wT','ms5_wT','ms6m'});
%   'ms6Stimm','ms4cm','ms5cwT','ms6cm'}); 
%listOfGroups = xlsx2mat_grouping('sheetname', 'SHP2-012-plateA', 'nbGroups',8,...
% 'variableNames',{'ms1m','ms2m','ms3m','ms4m','ms5wT','ms6wT','ms7m','ms8m'}); 
%STOP MODIFICATION-PART



%% get valid wells
firstList = getList('instruction','insert baseline files','multiSelection','off',...
    'folder',SAPath,'file',SAInfo); %receive the spike list of baseline
dataRaw = firstList.data;
[~,validList, validWells] = cleanData(dataRaw);
% compare validWells with listOfGroups
listedWells = listOfGroups(2:end,:);
listedWells = listedWells(:);
listedGroupindex = ismember(validWells,listedWells);
validWells = validWells(listedGroupindex);
   
   
nbSessions = length(baseInfo)/nbstim;
nbWells = length(validWells);
%% preallocating
%stimResult=repmat(struct('sessionresults',1),1,nbSessions);

%% (1) get spontanous activity
% MFRstore = zeros(nbstim,length(validList));
% 
% for c = 1:nbstim
%     dataStruct = getList('nameList',validList,'multiSelection','off',...
%         'folder',SAPath,'file',SAInfo{c});
%     data = dataStruct.data;
%     electrodeNames = dataStruct.nameElectrodes;
%     % get interval
%     
%     [spiking, ~] = spikeCalcIndiv(data, electrodeNames);
%     MFR = spiking.spikeRate;
%     MFRstore(c,:) = MFR;    
% end
% 
 MFRdata = cell(2,nbWells,nbSessions);
% MFRdataSA = cell(2,nbWells,nbSessions);
%names = repmat(validWells,1,1,nbSessions);

%% Stimulation analysis
for s = 1:nbSessions
        fileData = cell(1,nbstim);
        fileStim = cell(1,nbstim);
        
        for st = 1:nbstim        
            fileData(1,st) = baseInfo(1,s+(st-1)*nbSessions);
            fileStim(1,st) = StimInfo(1,s+(st-1)*nbSessions);     
        end
    
    [MFRrel] = StimAnalysis_noNorm (fileData,fileStim,basePath,StimPath,validList, validWells, nbstim); % 1 = not stim wells are not discarded
    MFRdata(:,:,s) = MFRrel;  

      
end

%oreallocatinv
meanRelMFR = zeros(nbstim, nbWells);
stdRelMFR = zeros(nbstim, nbWells);
RelCV = zeros(nbstim, nbWells);
RelSkewness = zeros(nbstim, nbWells);

containerMFR = zeros(nbstim,nbWells, nbSessions);
containerSD = zeros(nbstim,nbWells, nbSessions);
containerCV = zeros(nbstim,nbWells, nbSessions);
containerskewness = zeros(nbstim,nbWells, nbSessions);

%average over all electrodes 
for s = 1:nbSessions
    for w = 1:nbWells
        for stim = 1:nbstim     
            temp = MFRdata{2,w,s};
            temp = cell2mat(temp(2:end,:));
            temp(isinf(temp)) = 0;
            meanRelMFR(:,w) = mean(temp,2);
            stdRelMFR(:,w) = std(temp,0,2);
            RelCV(:,w) = stdRelMFR(:,w)./meanRelMFR(:,w);
            RelSkewness(:,w) = mean(((temp-meanRelMFR(:,w))./stdRelMFR(:,w)).^3,2);
        end
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

dataCell = cell(3+nbstim,nbWells,3);
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
    dataCell(4:end,count:count+length(wellNam)-1,1) = num2cell(dataSub1);
    dataCell(4:end,count:count+length(wellNam)-1,2) = num2cell(dataSub2);
    dataCell(4:end,count:count+length(wellNam)-1,3) = num2cell(dataSub3);
    count = count+length(wellNam);
end


export2Excel(dataCell,reportPath,reportFile);

end

function r = replace(a)
if isempty(a)
    r = nan;
else
    r = a;
end
end

function export2Excel(dataCell,reportPath,reportFile)
cd (reportPath)


id = 'MATLAB:xlswrite:AddSheet';
warning('off',id);

writetable(array2table(dataCell(:,:,1)),reportFile,'WriteVariableNames',false,...
    'Sheet','Mean value');
writetable(array2table(dataCell(:,:,2)),reportFile,'WriteVariableNames',false,...
    'Sheet','Coeff. of variance');
writetable(array2table(dataCell(:,:,3)),reportFile,'WriteVariableNames',false,...
    'Sheet','Skewness');


end


 