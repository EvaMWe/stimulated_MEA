% filterElectrode
% apply a filter (butterworth) on a recorded voltage trace derived from an
% electrode
%
% SYNTAX
% D = filterElectrode(E,f)
% 1D signal data (E), indicated as vector, are filtered by applying filter
%
% DISCRIPTION
% f (butterworth); filtered Data D has the same size as E;
% S = threshold calculated from noise;


function [D, S] = filterSignal(E,filterParameters,type)

% default

% if needed write varargin into input arguments
% if nargin ~= 0
% nArg = length(varargin);
% for arg = 1:2:nArg
%     argName = varargin{arg};
%     switch argName
%         case 'Type'
%           type = varargin{arg +1};
%         otherwise
%     end
% end
% end          

if strcmp(type,'bandpass')
    fb = filterParameters.fb;
    fa = filterParameters.fa;
    D = filter(fb,fa,E);
elseif strcmp(type,'high')
    nb = filterParameters.nb;
    na = filterParameters.na;
    D = filter(nb,na,E); %it's the noise
end

S = std(D);

end