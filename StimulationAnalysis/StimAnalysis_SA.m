% This function gets the PSTH according to Michela Chiappalone et al. 2008
% European Journal of NEuroscience

function sessiondata = StimAnalysis_SA(baseInfo,StimInfo,basePath,StimPath,validList,validWells,varargin)
binAll = 1000; %[in msec]
binSmall = 8;%[in msec]
discard_NonStim = 0;

if nargin == 7
    discard_NonStim = varargin{1};
end


nbstim = length(StimInfo); %should be 3 here

%% (2) get Stimulation information

StimData = AxisFile(fullfile(StimPath,StimInfo{1}));
[nameStimEl, nameStimWell] = generateElectrodeName(StimData); % name od stimulating electrode

%% reduce validList by discarding stimulating electrodes
reduce = cellfun(@(c)strcmp(c,validList),nameStimEl,'UniformOutput',false);
reduce = sum(vertcat(reduce{:}),1);
validListred = validList(reduce == 0);

%% reduce wellList by discarding wells without stimulations
if discard_NonStim == 0
    reduceW = cellfun(@(c)strcmp(c,validWells),nameStimWell,'UniformOutput',false);
    reduceW = sum(vertcat(reduceW{:}),1);
    wellListred = validWells(reduceW~=0);
    validWells = wellListred(1,:);
end

currNbWell = size(validWells,2);
dataStim = cell(currNbWell,nbstim);
dataPSTHvalues = cell(currNbWell,nbstim);


%% (3) calcualtion
for stim = 1:nbstim
    StimData = AxisFile(fullfile(StimPath,StimInfo{stim}));
    StimEvents = sort([StimData.StimulationEvents(:).EventTime]);
    StimEvents = StimEvents.*1000; %in ms; %=time stamps of stimulation events
    [nameStimEl, ~] = generateElectrodeName(StimData); % name od stimulating electrode
    
    TimeWindows = repmat(StimEvents',1,binAll/binSmall+1);
    intervals = 0:binSmall:binAll;
    intervals = repmat(intervals,size(TimeWindows,1),1);
    TimeWindows = TimeWindows + intervals;

    
    
    spikeList = getList('nameList',validListred,'folder',basePath,'file',baseInfo{stim});
    % get time interval
    
    spikeData = spikeList.data;
    [wellList, ~] = getWells(spikeData, -1, validWells);
    
    nbStim = size(TimeWindows,1); %number of stimulations per run
    nbBin = size(TimeWindows,2)-1;
    
    PSTHplate = cell(currNbWell,1);
    PSTHvalues = cell(currNbWell,1);
    
    for well = 1: currNbWell
        spikeTimes = wellList{2,well};  %electrodes of that well
        nbEl = size(spikeTimes,2);
        dataArray = zeros(nbEl,nbBin);
        for el = 1:nbEl
            dat = cell2mat(spikeTimes(2:end,el))* 1000; %[in msec]
            for bin = 1: nbBin
                a = TimeWindows(:,bin);
                b = TimeWindows(:,bin+1);
                %dat_ = (repmat(dat,1,length(a)))';
                withinWin = arrayfun(@(a,b) inWin(a,b,dat), a,b);
                nbSpk = sum(withinWin);
                dataArray(el,bin) = nbSpk;                
            end
        end
        PSTH = (dataArray./nbStim).*binSmall;
        PSTHarea = sum(PSTH,2);
        
        PSTHplate{well,1} = PSTHarea;
        PSTHvalues{well,1} = PSTH;
    end
    dataStim(:,stim) = PSTHplate;
    dataPSTHvalues(:,stim) = PSTHvalues;
end

Stimdiff = cell(currNbWell, 6);

for well = 1:currNbWell
    data = dataStim(well,:);
    Stimdiff{well,1} = abs(data{1,2}./data{1,1}-1);    
    Stimdiff{well,2} = abs(data{1,3}./data{1,1}-1);
    Stimdiff{well,3} = abs(data{1,3}./data{1,2}-1); 
    Stimdiff{well,4} = data{1,3}./data{1,1}-1; 
    Stimdiff{well,5} = data{1,3}./data{1,2}-1;
    Stimdiff{well,6} = data{1,2}./data{1,1}-1;
end

% Threshold for excluding non-responding electrodes: IF difference between
% stim2 and stim1 --> threshold > stim3 to stim1 and stim3 to stim1 THAN
% change in potentiation
thresh_ = vertcat(Stimdiff{:,1});
thresh_(isnan(thresh_) | ~isfinite(thresh_) | thresh_ == 1) = [];  %thresh_ == 1 --> number of spikes on Stim2 = 0 (electrode inactive)
thresh = median(thresh_) + std(thresh_);

PI = cell(currNbWell, 2);
nbMaxEl = max(max(cellfun(@length, dataStim)));
PSTHchange1 = cell(nbMaxEl, currNbWell); %PSTH area difference Stim3/Stim1
PSTHchange2 = cell(nbMaxEl, currNbWell); %PSTH area difference Stim3/Stim1
PSTHchange3 = cell(nbMaxEl, currNbWell); %PSTH area difference Stim3/Stim1
data_raw = cell(currNbWell,nbstim);

for well = 1:currNbWell
    
    data = dataStim(well,:);
    data_Stim2 = data{1,2};  %data during Stim2
    data_Stim1 = data{1,1}; %data during Stim1
    data_Stim3 = data{1,3}; %data during Stim3
    data_raw{well,1} = data_Stim1;
    data_raw{well,2} = data_Stim2;
    data_raw{well,3} = data_Stim3;     
    
    
    %Stim3/Stim1 absolut value
    data1 = Stimdiff{well,2};
    data1(data_Stim2 == 0 | data_Stim1 == 0) = []; %discard inactive electrodes in Stim1 and Stim2
    total = length(data1);
    data1(isnan(data1) | ~isfinite(data1) | data1 == 1) = [];
    data1(data1 < thresh) = [];
    changing = length(data1);
    PI_ = changing/total;
    PI{well,1} = PI_;
    
    %Stim3/Stim2 absolut value
    data2 = Stimdiff{well,3};
    data2(data_Stim2 == 0 | data_Stim1 == 0) = []; %discard inactive electrodes in Stim1 and Stim2
    total = length(data2);
    data2(isnan(data2) | ~isfinite(data2) | data2 == 1) = [];
    data2(data2 < thresh) = [];
    changing = length(data2);
    PI_ = changing/total;  %portion of changing electrodes compared to active ones
    PI{well,2} = PI_;
    
    %Stim3/Stim1 negative and positive 
    data3 = Stimdiff{well,4};  
    data3(data_Stim2 == 0 | data_Stim1 == 0) = []; %discard inactive electrodes in Stim1 and Stim2
    data3(isnan(data3) | ~isfinite(data3) | data3 == -1) = []; 
    %data3((data3 < thresh & data3 >= 0) | (data3 > -thresh & data3 < 0)) = [];
    changing = length(data3);
    PSTHchange1(1:changing,well) = num2cell(data3); %fold increase/decrease per active electrode  
    
    
    %Stim3/Stim2 negative and positive
    data4 = Stimdiff{well,5};    
    data4(data_Stim2 == 0 | data_Stim1 == 0) = []; %discard inactive electrodes in Stim1 and Stim2
    data4(isnan(data4) | ~isfinite(data4)| data4 == -1) = [];  %==-1 means no spikes were counted in Stim2 or Stim3 //exclude that
    %data4((data4 < thresh & data4 >= 0) | (data4 > -thresh & data4 < 0)) = [];
    changing = length(data4);
    PSTHchange2(1:changing,well) = num2cell(data4); %fold increase/decrease per active electrode
    
    %Stim2/Stim1 negative and positive
    data5 = Stimdiff{well,6};    
    data5(data_Stim2 == 0 | data_Stim1 == 0) = []; %discard inactive electrodes in Stim1 and Stim2
    data5(isnan(data5) | ~isfinite(data5)| data5 == -1) = [];  %==-1 means no spikes were counted in Stim2 or Stim3 //exclude that
    %data4((data5 < thresh & data5 >= 0) | (data5 > -thresh & data5 < 0)) = [];
    changing = length(data5);
    PSTHchange3(1:changing,well) = num2cell(data5); %fold increase/decrease per active electrode
    
    
end
sessiondata = struct('PSTH_area',1);
sessiondata.PSTH_area = dataStim;
sessiondata.PSTHdata = dataPSTHvalues; % for further evaluation maybe
sessiondata.stimulationChange = Stimdiff;
sessiondata.PSTHareaDiff_Stim3To1=PSTHchange1;
sessiondata.PSTHareaDiff_Stim3To2=PSTHchange2;
sessiondata.PSTHareaDiff_Stim2To1=PSTHchange3;
sessiondata.potentiationIndex = PI;
sessiondata.threshold = thresh;
sessiondata.wells = validWells';
sessiondata.stimulatingEl = nameStimEl;
sessiondata.activeElectrodes = validListred;
sessiondata.rawDataStim = data_raw;
end



function [nameElectrode, nameWell] = generateElectrodeName(StimData,varargin)
% letter indicates well row
% wellnumber indicates well column
% first el.number indicates electrode column
% second el. number indicates electrode row
if nargin == 1
    n=length(StimData.StimulationEvents(1,1).Electrodes);
else
    n = varargin{1};
end

nameElectrode = cell(n,1);
nameWell = cell(n,1);
for i = 1:n
    valueWell = StimData.StimulationEvents(1,1).Electrodes(1,i).WellRow;
    WellR = char(valueWell+'A'-1);
    WellC =StimData.StimulationEvents(1,1).Electrodes(1,i).WellColumn;
    eR = StimData.StimulationEvents(1,1).Electrodes(1,i).ElectrodeRow;
    eC = StimData.StimulationEvents(1,1).Electrodes(1,i).ElectrodeColumn;
    nameElectrode_ = sprintf('%s%i_%i%i',WellR,WellC,eC,eR);
    nameWell_ = sprintf('%s%i',WellR,WellC);
    nameElectrode(i,1) = cellstr(nameElectrode_);
    nameWell(i,1) = cellstr(nameWell_);
end
end

function between = inWin(start, stop, spikeData)
 between = sum(spikeData >= start & spikeData < stop);
end