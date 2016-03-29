function [phases, perms, slm, evals] = ...
    analyze_cyclicity(dir_search, lines, norm_method, field)
% Returns cyclicity results for dir_search file in current
% directory. Saves results in 'cyclicity.mat'. dir_search should be a .mat
% file containing time series data stored row wise.
% Inputs:
%   dir_search:     regular expression for files to be analyzed
%   lines:          which lines to use from data (can use [])
%                   (default: all)
%   norm_method:    'quad' or 'z-score' (or [])
%                   (default: 'quad')
%   field:          if the given files are saved as structs, field
%                   indicates which field of the struct contains the data
%                   (default: 'data')

defaultLines = 'a';
defaultNorm = 'quad';
defaultField = 'data';

switch nargin
    case 1
        lines = defaultLines;
        norm_method = defaultNorm;
        field = defaultField;
    case 2
        norm_method = defaultNorm;
        field = defaultField;
    case 3
        field = defaultField;
        if isempty(lines)
            lines = defaultLines;
        end
    case 4
        if isempty(lines)
            lines = defaultLines;
        end
        if isempty(norm_method)
            norm_method = defaultNorm;
        end
    otherwise
        error('Wrong number of arguments')
end
            
% if ~exist('lines','var')
%     lines = 'a';
%     norm_method = 'quad';
% elseif ~exist('norm_method','var')
%     norm_method = 'quad';
% end
%     
files = dir(dir_search);
n = length(files);
phases = cell(1,n); perms = cell(1,n); slm = cell(1,n); evals = cell(1,n); 
subject = cell(1,n);
i = 1;
for file = files.'
    data_file = importdata(file.name);
    if isstruct(data_file)
        data_file = data_file.(field);
    end
            
    if ~ischar(lines)
        data_file = data_file(lines,:);
    end
    sbj = strsplit(file.name,{'_','.'},'Collapsedelimiters',true);
    subject{i} = sbj{end - 1};
    fprintf('%s\n',subject{i});
    [phases{i}, perms{i}, slm{i}, evals{i}] = cyclic_analysis(data_file, norm_method);
    i = i + 1;
end
save(['cyclicity_',norm_method,'.mat'], ...
    'phases', 'perms','slm','evals','subject');
fprintf('Done\n');
