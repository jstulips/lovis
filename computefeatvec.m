function fv = computefeatvec(t, trackCell, blobCell, tdiff)
% COMPUTEFEATVEC Compute feature vector for a single track from LOST dataset
%
%   Usage: FV = COMPUTEFEATVEC(T, TRACKCELL, BLOBCELL, TDIFF) 
%
%   Input:
%       T : track number
%       TRACKCELL : track cell (from dataset)
%       BLOBCELL : blob cell (from dataset)
%       TDIFF : time difference between successive frames in track
%       
%   Output:
%       FV : feature vector matrix, consisting of four variables
%           X position, Y position, X velocity, Y velocity           
%
%
blobIds = trackCell{t}.blobIdxs;
blobFns = trackCell{t}.blobFrameNums;

for i=1:length(blobIds)
    bbroi = blobCell{blobIds(i),4};
    fv(i,1:2) = bbroi(1:2);         % x (row) and y (col) positions
end

% compute velocities (v_x, v_y) at frame i of the track
tdiffs = repmat(tdiff(blobFns(2:end)),1,2);
movm = diff(fv);
vel = [0 0; movm./tdiffs];

% concat back to fv
fv = [fv vel];