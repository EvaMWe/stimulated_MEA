% This function calculates the PSTHare according to sum(Msp*binSmall)
% with Msp is the mean number of spikes over all stimulation within on bin
% on one electrod
% binSmall is the time of one bin
% sum is over all bins and refers to one electrode

% NEW: calculation of the mean firing rate (MFR)
% sum(Msp/binSmall)/nbBins

function [MFRList,MFRSA,MFRev,Ampl] = StimAnalysis_pairedPulse(baseInfo,StimInfo,SAInfo,basePath,StimPath,validList, validWells,varargin)
binAll = 1000; %[in msec]
binSmall = 8;%[in msec]
discard_NonStim = 0;

if nargin == 9
    discard_NonStim = varargin{1};
end


nbstim = length(SAInfo); %should be 3 here


%% (2) get Stimulation information

StimData = AxisFile(fullfile(StimPath,StimInfo{1}));
[nameStimEl, nameStimWell] = generateElectrodeName(StimData); % name od stimulating electrode

%% reduce validList by discarding stimulating electrodes
reduce = cellfun(@(c)strcmp(c,validList),nameStimEl,'UniformOutput',false);
reduce = sum(vertcat(reduce{:}),1);
validListred = validList(reduce == 0);
MFRstore = MFRstore(:,reduce == 0);

%% reduce wellList by discarding wells without stimulations
% MFR liste muss noch angepasst werden, für diese Option
if discard_NonStim == 0
    reduceW = cellfun(@(c)strcmp(c,validWells),nameStimWell,'UniformOutput',false);
    reduceW = sum(vertcat(reduceW{:}),1);
    wellListred = validWells(reduceW~=0);
    validWells = wellListred(1,:);
end

nbEl = size(MFRstore,2);
currNbWell = size(validWells,2);
% dataStim = cell(currNbWell,nbstim);
% dataMFRvalues = cell(nbEl,nbstim);


%% (3) calcualtion
MFRvalues = zeros(nbstim,nbEl);
for stim = 1:nbstim
    StimData = AxisFile(fullfile(StimPath,StimInfo{stim}));
    StimEvents = sort([StimData.StimulationEvents(:).EventTime]);
    StimEvents = StimEvents.*1000; %in ms; %=time stamps of stimulation events
%    [nameStimEl, ~] = generateElectrodeName(StimData); % name od stimulating electrode
    
    TimeWindows = repmat(StimEvents',1,binAll/binSmall+1);
    intervals = 0:binSmall:binAll;
    intervals = repmat(intervals,size(TimeWindows,1),1);
    TimeWindows = TimeWindows + intervals;

      
    spikeList = getList('nameList',validListred,'folder',basePath,'file',baseInfo{stim});
    
    spikeData = spikeList.data;
    
   
    nbStim = size(TimeWindows,1); %number of stimulations per run
    nbBin = size(TimeWindows,2)-1;      
   
    spikeTimes = spikeData;
    
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
    MFRevoke = sum(((dataArray./nbStim)./binSmall),2)./nbBin;    %in msec
    MFRvalues(stim,:) = MFRevoke; %for each stimulation (row) for each electrode
end
MFRvalues = MFRvalues.*1000; %in sec 

MFRrel = MFRvalues./MFRstore;
Amplitude = MFRvalues-MFRstore;  %difference between evoked and spontaneous activity (base)

MFRcell_rel = cell(nbstim+1,nbEl);
MFRcell_rel(1,:) = validListred;
MFRcell_rel(2:end,:) = num2cell(MFRrel);

MFRcell_ev = cell(nbstim+1,nbEl);
MFRcell_ev(1,:) = validListred;
MFRcell_ev(2:end,:) = num2cell(MFRvalues);

MFRcell_SA = cell(nbstim+1,nbEl);
MFRcell_SA(1,:) = validListred;
MFRcell_SA(2:end,:) = num2cell(MFRstore);


MFRcell_amp = cell(nbstim+1,nbEl);
MFRcell_amp(1,:) = validListred;
MFRcell_amp(2:end,:) = num2cell(Amplitude);

[MFRList, ~] = getWells(MFRcell_rel, -1, validWells);
[MFRSA, ~] = getWells(MFRcell_SA, -1, validWells);
[MFRev, ~] = getWells(MFRcell_ev, -1, validWells);
[Ampl, ~] = getWells(MFRcell_amp, -1, validWells);
 

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