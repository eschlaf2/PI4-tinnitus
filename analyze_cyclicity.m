function [phases, perms, slm, evals] = analyze_cyclicity(dir_search)
% Returns cyclicity results for dir_search file in current
% directory. Saves results in 'cyclicity.mat'. dir_search should be a .mat
% file containing only time series data stored row wise.

files = dir(dir_search);
for norm_method = {'z-score','quad'}
	n = length(files);
	phases = cell(1,n); perms = cell(1,n); slm = cell(1,n); evals = cell(1,n); 
	subject = cell(1,n);
	i = 1;
	for file = files.'
		data_file = file.name;
	    sbj = strsplit(file.name,{'_','.'},'Collapsedelimiters',true);
	    subject{i} = sbj{3};
		[phases{i}, perms{i}, slm{i}, evals{i}] = cyclic_analysis(data_file, norm_method{:});
		i = i + 1;
	end
	save(['cyclicity_',norm_method{:},'.mat'], 'phases', 'perms','slm','evals','subject');
end
