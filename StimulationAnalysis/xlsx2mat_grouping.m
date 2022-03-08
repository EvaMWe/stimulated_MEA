% This is a tool to extract the processed Data by main_MEA_Axion by group
% input is a List of groups provided as an Excel sheet containing the group
% names as variable names with the belonging wells 
% NAME PROPERTY PAIRS
% 'sheetname' - name of the spreadsheet that has to be read in
% 'nbGroups' - number of groups [scalar]
% 

function cellWithGroups = xlsx2mat_grouping(varargin)
%% defaults
nbGroups = 6;
sheetname = 'Tabelle1';

%%
nb = nargin;


for i = 1:2:nb-1
    switch varargin{i}
        case 'sheetname'
            sheetname = varargin{i+1};
        case 'nbGroups'
            nbGroups = varargin{i+1};
        case 'variableNames'
            variableNames = varargin{i+1};
        otherwise
            error ('invalid name of input argument')
    end
end

[file, path] = uigetfile('.xlsx','select grouping list');
filename = fullfile(path,file);
opts = detectImportOptions(filename);
opts.Sheet = sheetname;
if exist('variableNames','var')
    opts.VariableNames = variableNames;
end
opts.SelectedVariableNames = opts.VariableNames(1:nbGroups);
TableOfGroups = readtable(filename,opts);
subCell =table2cell(TableOfGroups);
cellWithGroups = cat(1,opts.SelectedVariableNames, subCell);

end



