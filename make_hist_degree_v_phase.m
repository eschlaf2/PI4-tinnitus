fileid = 'cyclicity_*';

file = dir(fileid);
load(file(1).name)
phase_mat = abs(cell2mat(phases));
[~,sorted_ph] = sort(phase_mat,1,'descend');
top5_ph_cts = histc(reshape(sorted_ph(1:5,:),[],1),(1:size(sorted_ph,1)));
normed_ph_cts = top5_ph_cts./max(top5_ph_cts);

load('triples.mat')
cutoff70p = size(coords(coords(:,4) >= 140));
top70p_coords = coords(1:cutoff70p, 1:3);
coord_cts = histc(top70p_coords(:),(1:size(normed_ph_cts,1)));
normed_coord_cts = coord_cts./max(coord_cts);

bar([normed_ph_cts,normed_coord_cts])
legend({'phases';'coords'})
set(gcf, 'units','normalized', 'position', [0 .5 1 .5])