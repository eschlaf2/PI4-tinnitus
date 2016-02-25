function [phases, perms, slm, evals] = ...
    analyze_cyclicity(dir_search, lines, norm_method)
% Returns cyclicity results for dir_search file in current
% directory. Saves results in 'cyclicity.mat'. dir_search should be a .mat
% file containing only time series data stored row wise.
% Optional second input is which lines of the file to use.

if ~exist('lines','var')
    lines = 'a';
    norm_method = 'quad';
elseif ~exist('norm_method','var')
    norm_method = 'quad';
end
    
files = dir(dir_search);
n = length(files);
phases = cell(1,n); perms = cell(1,n); slm = cell(1,n); evals = cell(1,n); 
subject = cell(1,n);
i = 1;
for file = files.'
    data_file = importdata(file.name);
    if ~ischar(lines)
        data_file = data_file(lines,:);
    end
    sbj = strsplit(file.name,{'_','.'},'Collapsedelimiters',true);
    subject{i} = sbj{4};
    fprintf('%s\n',subject{i});
    [phases{i}, perms{i}, slm{i}, evals{i}] = cyclic_analysis(data_file, norm_method);
    i = i + 1;
end
save(['cyclicity_',norm_method,'.mat'], 'phases', 'perms','slm','evals','subject');
fprintf('Done\n');
