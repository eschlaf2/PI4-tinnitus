function [eig_vec, phases, permutation, sorted_lead_matrix, spectrum]=sort_lead(a, varargin)
% sorts the given lead matrix. Takes optional arguments: 1) a list of ROIS
% if different from existing 'ROIS' variable (used when we looked at
% average of left and right regions); 2) base roi - a region to be used as
% the base.


   	 [eig_vec,spectrum]=eig(a);
     spectrum = diag(spectrum);
     sorted_ang = sort(mod(angle(eig_vec(:,1)),2*pi));
     [~, shift] = max(abs(diff([sorted_ang; sorted_ang(1) + 2*pi])));
     if shift == numel(eig_vec(:,1))
         shift = 1; 
     else
         shift = shift + 1;
     end
     shift = sorted_ang(shift);
	 [phases,permutation]=sort(mod(mod(angle(eig_vec(:,1).'), 2*pi) - shift, 2*pi));
          
%      Phase adjust
switch nargin
    case 3
        ROIS = varargin{1};
        baseroi = varargin(2);
        try
            angle_adjust = phases(permutation == find(strcmp([ROIS(:,1)], baseroi)));
        catch ME
            warning('baseroi not found. Input ignored.')
            [eig_vec, permutation, sorted_lead_matrix, spectrum] = sort_lead(a);
            return
        end
    case 2
        error('Optional arg 1 should be the ROIS; optional arg 2 should be base roi')
    case 1
        angle_adjust = min(phases);
    otherwise
        error('Too many arguments')
end

     phases = phases - ones(size(phases)) .* angle_adjust;
	 sorted_lead_matrix=a(permutation,permutation);
     eig_vec = eig_vec(permutation,:);
end
