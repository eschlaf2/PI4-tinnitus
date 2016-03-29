% Creates a scatter plot (was a hist plot) of the counts of champions in
% order to compare which regions are present most often in common triples
% vs the regions which most often have large phase magnitudes.

fileid = 'cyclicity_*';
n = 5;

s = HWSetup();

% Order regions by phase magnitude and histogram results from all subjects.
% Then normalize counts using z-score norm.
file = dir(fileid);
load(file(1).name)
phase_mat = abs(cell2mat(phases));
r = size(phase_mat,1);
[~,sorted_ph] = sort(phase_mat,1,'descend');
top_ph_cts = histc(reshape(sorted_ph(1:n,:),[],1),(1:r));
normed_ph_cts = z_score_norm(top_ph_cts');
normed_ph_cts = normed_ph_cts - min(normed_ph_cts);
% normed_ph_cts = top5_ph_cts./max(top5_ph_cts);

% Segregate triples which are present in at least 70 percent of subjects,
% then count appearances of each region in the triples. Normalize results
% using z-score norm.
load('triples.mat')
cutoff70p = size(coords(coords(:,4) >= 140));
top70p_coords = coords(1:cutoff70p, 1:3);
coord_cts = histc(top70p_coords(:),(1:r));
normed_coord_cts = z_score_norm(coord_cts');
normed_coord_cts = normed_coord_cts - min(normed_coord_cts);

% bar([normed_ph_cts',normed_coord_cts'])
plot3(normed_ph_cts,normed_coord_cts,(1:length(normed_ph_cts)),'*');
view(0,90);
% legend({'phases';'coords'})
% set(gcf, 'units','normalized', 'position', [0 .5 1 .5])
% axis('tight')
xlabel('Phases');
ylabel('Triples');
title({'Champion Regions'; file(1).name(11:end-4)}, 'interpreter', 'none')
% hold on;

% [top5ph_cts,top5ph_regions] = sort(normed_ph_cts, 'descend');
% [top5coords_cts,top5coords_regions] = sort(normed_coord_cts, 'descend');
% plot(top5ph_regions(1:5),top5ph_cts(1:5),'b*',...
%     'linewidth',2,'markersize',10)
% plot(top5coords_regions(1:5),top5coords_cts(1:5),'r*',...
%     'linewidth',2,'markersize',10)

outid = ['scatter_n',num2str(n),'_',file(1).name(1:end-4)];
savefig(gcf, outid);
hgexport(gcf,outid,s);