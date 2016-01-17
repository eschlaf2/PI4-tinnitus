% Returns cyclicity results for processed subject data in current
% directory. Saves results in 'cyclicity.mat'.
files = dir('processed*');
for norm_method = {'z-score','frob'}
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
