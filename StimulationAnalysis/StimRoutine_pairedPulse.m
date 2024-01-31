function dataCell =StimRoutine_pairedPulse(varargin)
%% *******************Read In Data:******************************
%  FILES FOR SPONTANEOUS AVTIVITY and to get valid wells
%select one file for selecting valide wells
[SAInfo, SAPath] = uigetfile('*.csv','select files for calculating spontaneous activity',...
     'MultiSelect','on');
if ~iscell(SAInfo)
    SAInfo = cellstr(SAInfo);
end
cd(SAPath);

% STIMULATION DATA FILE
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
listOfGroups = xlsx2mat_grouping('sheetname', 'grouping', 'nbGroups',8 ,...
 'variableNames',{'CTRL','LSD_10','DMT_90','PSI_10','LSD_1','DMT_9','PSI_1','LSD_0.1'});  %STOP MODIFICATION-PART
%listOfGroups = xlsx2mat_grouping('sheetname', 'SHP2_groupedPmouse', 'nbGroups', 8 ,...
%   'variableNames',{'ms1m','ms2m','ms3wT','ms4m','ms5wT','ms6m','ms7wT','ms8wT'});
%   listOfGroups = xlsx2mat_grouping('sheetname', 'KRASV_groupedPmouse', 'nbGroups', 6 ,...
%     'variableNames',{'ms1wT','ms2m','ms3m','ms4wT','ms5_wT','ms6m'});
%   'ms6Stimm','ms4cm','ms5cwT','ms6cm'}); 
%listOfGroups = xlsx2mat_grouping('sheetname', 'SHP2-012-plateA', 'nbGroups',8,...
% 'variableNames',{'ms1m','ms2m','ms3m','ms4m','ms5wT','ms6wT','ms7m','ms8m'}); 
%STOP MODIFICATION-PART

nbstim = 1;


%% get valid wells
z = 1;
firstList = getList('instruction','insert baseline files','multiSelection','off',...
    'folder',SAPath,'file',SAInfo{z}); %receive the spike list of baseline
dataRaw = firstList.data;
[~,validList, validWells] = cleanData(dataRaw);
% compare validWells with listOfGroups
listedWells = listOfGroups(2:end,:);
listedWells = listedWells(:);
listedGroupindex = ismember(validWells,listedWells);
validWells = validWells(listedGroupindex);
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

MFRdata = cell(2,nbWells,nbexperiments);
MFRdataev = cell(2,nbWells,nbexperiments);
MFRdataSA = cell(2,nbWells,nbexperiments);
MFRdataampl = cell(2,nbWells,nbexperiments);
%names = repmat(validWells,1,1,nbSessions);
nbExperiments = length(StimInfo);
%% Stimulation analysis
for s = 1:nbExperiments      
    fileData = baseInfo(1,s);         
    fileStim = StimInfo(1,s);
        
    
    [MFRrel, MFRSA, MFRev, Ampl] = StimAnalysis_pairedPulse(fileData,fileStim,SAInfo,basePath,StimPath,validList, validWells,1); % 1 = not stim wells are not discarded
    MFRdata(:,:,s) = MFRrel; 
    MFRdataev(:,:,s) = MFRev; 
    MFRdataSA(:,:,s) = MFRSA;
    MFRdataampl(:,:,s) = Ampl;
      
end
%% average along sessions
%oreallocatinv

meanRelMFR = zeros(nbstim, nbWells);
stdRelMFR = zeros(nbstim, nbWells);
RelCV = zeros(nbstim, nbWells);
RelSkewness = zeros(nbstim, nbWells);
meanevMFR = zeros(nbstim, nbWells);
meanSAMFR = zeros(nbstim, nbWells);
meanCorr = zeros(nbstim, nbWells);
meanCorrAmp = zeros(nbstim, nbWells);

containerMFR = zeros(nbstim,nbWells, nbSessions);
containerSD = zeros(nbstim,nbWells, nbSessions);
containerCV = zeros(nbstim,nbWells, nbSessions);
containerskewness = zeros(nbstim,nbWells, nbSessions);
containerMFRev = zeros(nbstim,nbWells, nbSessions);
containerMFRSA = zeros(nbstim,nbWells, nbSessions);
containerMCorr = zeros(nbstim,nbWells, nbSessions);
containerMCorrAmpl = zeros(nbstim,nbWells, nbSessions);


%average over all electrodes 
for s = 1:nbSessions
    for w = 1:nbWells
       % for stim = 1:nbstim     
            temp = MFRdata{2,w,s};
            temp = cell2mat(temp(2:end,:));
            temp(isinf(temp)) = 0;
            meanRelMFR(:,w) = mean(temp,2);
            stdRelMFR(:,w) = std(temp,0,2);
            RelCV(:,w) = stdRelMFR(:,w)./meanRelMFR(:,w);
            RelSkewness(:,w) = mean(((temp-meanRelMFR(:,w))./stdRelMFR(:,w)).^3,2);
            
            temp2 = MFRdataev{2,w,s};
            temp2 = cell2mat(temp2(2:end,:));
            temp2(isinf(temp2)) = 0;
            meanevMFR(:,w) = mean(temp2,2);
            
            temp3 = MFRdataSA{2,w,s};
            temp3 = cell2mat(temp3(2:end,:));
            temp3(isinf(temp3)) = 0;
            meanSAMFR(:,w) = mean(temp3,2);
            
            CorCoeff = calcCorr(temp2,temp3); %für Anzahl an Stimulationen
            meanCorr(:,w) = CorCoeff;
            
            temp4 = MFRdataampl{2,w,s};
            temp4 = cell2mat(temp4(2:end,:));
            CorAmpl = calcCorr(temp2,temp4);
            meanCorrAmp(:,w) = CorAmpl;
            
                        
        %end
    end
    containerMFR(:,:,s) = meanRelMFR;
    containerSD(:,:,s) = stdRelMFR;
    containerCV(:,:,s) = RelCV;
    containerskewness(:,:,s) = RelSkewness;
    containerMFRev(:,:,s) = meanevMFR;
    containerMFRSA(:,:,s) = meanSAMFR;
    containerMCorr(:,:,s) =meanCorr;
    containerMCorrAmpl(:,:,s) = meanCorrAmp;
end

%% average over the sessions
meanMFR_together = mean(containerMFR,3); %averaged data over all sessions, over all electrodes per well
meanSD_together = mean(containerSD,3); 
meanCV_together = mean(containerCV,3);
meanSkew_together = mean(containerskewness,3);
meanMFRev_together = mean(containerMFRev,3);
meanMFRSA_together = mean(containerMFRSA,3);
meanCorrelation = mean(containerMCorr,3);
meanCorrAmp = mean(containerMCorrAmpl,3);

%% grouping
%wells in gouping list 

dataCell = cell(3+nbstim,nbWells,7);
dataCell{1,1,1} = 'MFR_norm_mean';
dataCell{1,1,2} = 'MFR_norm_mean_CV';
dataCell{1,1,3} = 'MFR_norm_mean_skew';
dataCell{1,1,4} = 'MFR_evoked_mean';
dataCell{1,1,5} = 'MFR_SA_mean';
dataCell{1,1,6} = 'MFR_Correlation';
dataCell{1,1,7} = 'MFR_CorrAmplification';

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
    dataCell{2,count,4} = listOfGroups(1,gr);
    dataCell{2,count,5} = listOfGroups(1,gr);
    dataCell{2,count,6} = listOfGroups(1,gr);
    dataCell{2,count,7} = listOfGroups(1,gr);
    dataCell(3,count:count + length(wellNam)-1,1) = wellNam;
    dataCell(3,count:count + length(wellNam)-1,2) = wellNam;
    dataCell(3,count:count + length(wellNam)-1,3) = wellNam;
    dataCell(3,count:count + length(wellNam)-1,4) = wellNam;
    dataCell(3,count:count + length(wellNam)-1,5) = wellNam;
    dataCell(3,count:count + length(wellNam)-1,6) = wellNam;
    dataCell(3,count:count + length(wellNam)-1,7) = wellNam;
    dataSub1 = meanMFR_together(:,log');
    dataSub2 = meanCV_together(:,log');
    dataSub3 = meanSkew_together(:,log');
    dataSub4 = meanMFRev_together(:,log');
    dataSub5 = meanMFRSA_together(:,log');
    dataSub6 = meanCorrelation(:,log');
    dataSub7 = meanCorrAmp(:,log');
    dataCell(4:end,count:count+length(wellNam)-1,1) = num2cell(dataSub1);
    dataCell(4:end,count:count+length(wellNam)-1,2) = num2cell(dataSub2);
    dataCell(4:end,count:count+length(wellNam)-1,3) = num2cell(dataSub3);
    dataCell(4:end,count:count+length(wellNam)-1,4) = num2cell(dataSub4);
    dataCell(4:end,count:count+length(wellNam)-1,5) = num2cell(dataSub5);
    dataCell(4:end,count:count+length(wellNam)-1,5) = num2cell(dataSub6);
    dataCell(4:end,count:count+length(wellNam)-1,5) = num2cell(dataSub7);
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
    'Sheet','Mean value _ normed');
writetable(array2table(dataCell(:,:,2)),reportFile,'WriteVariableNames',false,...
    'Sheet','Coeff. of variance _ normed');
writetable(array2table(dataCell(:,:,3)),reportFile,'WriteVariableNames',false,...
    'Sheet','Skewness _normed');
 writetable(array2table(dataCell(:,:,4)),reportFile,'WriteVariableNames',false,...
    'Sheet','Mean value_evoked');
 writetable(array2table(dataCell(:,:,5)),reportFile,'WriteVariableNames',false,...
    'Sheet','Mean value_SA');

end

function CorrCoeff = calcCorr(data_evoked,data_SA)
nbStim = size(data_evoked,1);
CorrCoeff = zeros(nbStim,1);
for st = 1:nbStim
    M = [data_SA(st,:); data_evoked(st,:)]';
    M = sortrows(M);
    R = corrcoef(M(:,1), M(:,2));
    R = R(1,2);
    CorrCoeff(st,1) = R;
end
end


