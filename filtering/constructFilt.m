% constract filters to extract or remove noise
% bandpassfilter for filtering noise 
% highpass to get the noise for thresholding
function filterSettings  = constructFilt(varargin)
%% intiate filter parameters
%% default
type = 'all';
set = 'no';
rate = 12500;

if nargin ~= 0
    nArg = length(varargin);
    for arg = 1:2:nArg
        nameArg =varargin{arg};
        switch nameArg
            case 'Type'
                type = varargin{arg+1};
            case 'Settings'
                filterSettings = varargin{arg+1};              
                set = 'yes'; 
            case 'SamplingRate'
                rate = varargin{arg+1};
            otherwise
        end
    end
end

%%  
if strcmp(set,'no')
    filterSettings = initFilt('SamplingRate',rate);
end
F0 = filterSettings.samplingFrequency;
lP = filterSettings.lowPass;
hP = filterSettings.highPass;
HPnoise = filterSettings.HPNoise;

FNyqu = F0/2;
lP_norm = lP/FNyqu;
hP_norm = hP/FNyqu;
HPnoise_norm = HPnoise/FNyqu;

%% contruction of filter
if strcmp(type,'bandpass')
    [b,a] = butter(2, [lP_norm hP_norm],'bandpass');
    filterSettings.fa = a;
    filterSettings.fb = b;
elseif strcmp(type, 'high')
    %thresholdFilter
    [nb,na] = butter(2, HPnoise_norm, 'high');
    filterSettings.na = na;
    filterSettings.nb = nb;
else
    [b,a] = butter(2, [lP_norm hP_norm],'bandpass');
    filterSettings.fa = a;
    filterSettings.fb = b;
    [nb,na] = butter(2, HPnoise_norm, 'high');
    filterSettings.na = na;
    filterSettings.nb = nb;
end

filterSettings.type = type;
end




