function displayHist(bincount)
% DISPLAYHIST Display histogram with different coloured bars
%
%   Usage: DISPLAYHIST(BINCOUNT) 
%
%   Input:
%           BINCOUNT : M-by-N matrix, with M groups of N vertical bars. 
%

figure;  
for i=1:numel(bincount)
  h = bar(i, bincount(i));
  set(h, 'FaceColor', getColor(i,1) ); 
  hold on;
end 
set(gca, 'XTick',1:numel(bincount));