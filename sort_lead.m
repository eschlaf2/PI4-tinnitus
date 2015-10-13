function [eig_vec, permutation, sorted_lead_matrix, spectrum]=sort_lead(a, varargin)
% The first input should be the matrix to be sorted, the second should be
% the title of an ROI to be used as a baseline.
% On July 2 I changed the output so that phases outputs an angle rather
% than the associated complex number and the lowest phase is always zero.
% On July 14 I changed the output so that a chosen ROI can be used as a
% baseline.


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
%      shift = pi - median(mod(angle(u(:,1).'), 2*pi));
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
     %eig_vec = eig_vec(permutation,:);
end
