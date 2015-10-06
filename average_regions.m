function [roi_avg] = average_regions(coords, subj, varargin)

switch length(varargin)
    case 1
        if isfloat(varargin{1})
            radius = varargin{1};
        else
            warning('Wrong input type');
            return
        end
    case 0
        radius = 5;
    otherwise
        warning('Too many inputs');
        return
end

x = coords(1); y = coords(2); z = coords(3);

roi_avg = mean(subj(subj(:,1) >= x - radius & subj(:,1) <= x + radius & ...
    subj(:,2) >= y - radius & subj(:,2) <= y + radius & ...
    subj(:,3) >= z - radius & subj(:,3) <= z + radius,4:end));

end

