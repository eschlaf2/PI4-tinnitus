function [s] = HWSetup(varargin)
ss = size(varargin);
if ss
    ColorSet = varycolor(varargin{1});
else 
    ColorSet = varycolor(5);
end

set(0,'DefaultAxesColorOrder',ColorSet);
set(0,'defaultAxesLineStyleOrder','-|--|:')

s = hgexport('readstyle','PowerPoint'); %'PowerPoint' for presentations
s.Format = 'eps';
s.FontSizeMin = '18';


%hgexport(gcf,'test',s);
