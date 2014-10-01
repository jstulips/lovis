function displaySingleTrack(vidFrame, track, blobCell)
% DISPLAYSINGLETRACK Displaying/visualising a single track on
% video image. To display a new generated track, only the first two input
% arguments suffice. To display an existing track from database, the third
% input argument (blobCell) is required.
%
%   Usage: DISPLAYTRACKS(VIDFRAME, TRACK, BLOBCELL) 
%
%   Input:
%       VIDFRAME : video image frame
%       TRACK : track points (x and y positions)
%       BLOBCELL : blob cell data (optional, only for display an existing
%       track from database that requires blob data)
%
%   ** Usage example **
%
%   displaySingleTrack(vidFrame, track);
%   displaySingleTrack(vidFrame, track, blobCell);
%
if nargin == 2
    blobCell = {};
end

figure, imshow(vidFrame);
title('A single track');
 
if isstruct(track)
    blobIdxs = track.blobIdxs;
    bbox = blobCell(blobIdxs, 4);
    bboxMat = cell2mat(bbox);   
    h = line(bboxMat(:,2),bboxMat(:,1));
else   
    h = line(track(:,2),track(:,1));    
end
set(h, 'color', [1 1 1]); 
set(h, 'LineWidth', 2);
hold on;