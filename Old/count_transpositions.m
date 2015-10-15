function [transpositions] = count_transpositions(V1, V2)

V1 = keep_one_first(V1); V2 = keep_one_first(V2);
display_ = 0;

% Validate input
if length(V1) ~= length(V2)
    warning('Input should be two cycles of the same length')
    return
end
if not(find(size(V1)==1))
    warning('Input should be in the form of N by 1 arrays')
    return
end

% If the same return 0
if V1 == V2
    transpositions = 0;
    return
end

% Only compare differences in permutations
diff = V1 ~= V2;

V1d = V1(diff); V2d = V2(diff);
     

cycle = zeros(1,length(V1d)); active = ones(1,length(V1d));
start = V1d(1); 
active(1) = 0;
cycle(1) = start;
transpositions = 0;
from = start;
for i = 2:length(V2d)
    to = V2d(V1d == from);
    if to == start
        if display_
            display(cycle(find(cycle == start) : find(cycle == from)),'Cycle');
        end
        A = V2d(active==1);
        start = A(1);
        from = start;
        cycle(i) = start;
        continue
    end
    active(V1d == to) = 0;
    cycle(i) = to;
    transpositions = transpositions + 1;
    from = to;
end

if display_
    display(cycle(find(cycle == start) : find(cycle == from)), 'Cycle');
end

end
    
    