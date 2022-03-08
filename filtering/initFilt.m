% to specify parameters: first input variabe = sampling frequency
%                        2.                  = low pass
%                        3.                  = high pass

function filterParameters = initFilt(varargin)
%default
samplingFrequency = 12500;
lowPass = 300;
highPass = 3000;
highPassNoise = 1500;

if nargin ~= 0
   nArg = length(varargin);
   for arg = 1:nArg
       argName = varargin{arg};
       switch argName
           case 'SamplingRate'
               samplingFrequency = varargin{arg+1};
           case 'LowPass'
               lowPass = varargin{arg+1};
           case 'HighPass'
               highPass = varargin{arg+1};
           case 'HighPassNoise' 
               highPassNoise = varargin{arg+1};
           otherwise
       end
   end
       

   
filterParameters.samplingFrequency = samplingFrequency; %[Hz]
filterParameters.lowPass = lowPass;             %[Hz]
filterParameters.highPass = highPass;           %[Hz]
filterParameters.HPNoise = highPassNoise;%[Hz]
end
