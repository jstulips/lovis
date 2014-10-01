% GENERATEANOMALY Script for synthetically generating an anomalous track
%

% clear old variables, if they exist
clear freespace nfv pts randomvelo bw mask bwUsableSpace bwSpaceNotUsed;

pos = []; startpos = []; velo = [];
for i = 1 : length(exemplarSet)
    trs = exemplarSet{i}.tracks;
    for j = 1 : length(trs)
        len(i,j) = length(trs{j}.blobIdxs);
        startpos = [startpos; trs{j}.fv(1,1:2)];
        pos = [pos; trs{j}.fv(:,1:2)]; 
        velo = [velo; trs{j}.fv(:,3:4)];
    end
end
avglen = round(mean(mean(len)));
avgvelo = mean(velo);
sigmavelo = std(velo);
uniquepos = unique(pos,'rows');

% union of track convex hulls to find previously travelled regions
convhullframe = vidFrame;
[rows cols channels] = size(convhullframe); 
mask = zeros(rows, cols);
%figure, imshow(convhullframe); hold on;
for i = 1 : length(exemplarSet)
    trs = exemplarSet{i}.tracks;
    for j = 1 : length(trs)
        x = trs{j}.fv(:,1);
        y = trs{j}.fv(:,2);
        k = convhull(x, y);
        [x_hull, y_hull] = poly2cw(x(k), y(k));
        bw = poly2mask(y_hull, x_hull, rows, cols);
        mask = mask | bw;
        %fill(y_hull, x_hull, 'r', 'EdgeColor', 'r');
    end
end

% manually define region where motion is expected to happen
%motionArea = [0 281; 97 257; 96 208; 375 221; 640 236; 641 480; 0 480];     % for camera 001 (camera-specific)
motionArea = [0 336; 162 171; 640 174; 640 463; 0 463];    % for camera 017
bwUsableSpace = poly2mask(motionArea(:,1), motionArea(:,2), size(convhullframe,1), size(convhullframe,2));
bwSpaceNotUsed = xor(mask,bwUsableSpace) & bwUsableSpace;

% get a random start point from unused locations in the region
[freespace(:,1), freespace(:,2)] = find(bwSpaceNotUsed);
startpt = freespace(round(rand*length(freespace)),:);

% randomly generate path using mean track length and mean velocities
% assumption: 1 frame/sec since velocity is already obtained first
m = 2;
pts = startpt;
randomvelo(1,:) = [0 0];
for p = 1 : avglen-1
     randomvelo(p+1,:) = round(random('normal', avgvelo, m*sigmavelo));
     pts(p+1,:) = pts(p,:) + randomvelo(p+1,:);
end
displaySingleTrack(vidFrame, pts)
nfv = [pts randomvelo];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXTRA VISUALIZATIONS - not used eventually
% vidframe = zeros(size(vidFrame));
% for j = 1: size(uniquepos,1)
%     vidframe(uniquepos(j,1), uniquepos(j,2), 1) = 255;
%     vidframe(uniquepos(j,1), uniquepos(j,2), 2) = 255;
%     vidframe(uniquepos(j,1), uniquepos(j,2), 3) = 255;
% end
% for k = 1: size(startpos,1)
%     vidframe(startpos(k,1)-1:startpos(k,1)+1, startpos(k,2)-1:startpos(k,2)+1, 1) = 255;
%     vidframe(startpos(k,1)-1:startpos(k,1)+1, startpos(k,2)-1:startpos(k,2)+1, 2) = 0;
%     vidframe(startpos(k,1)-1:startpos(k,1)+1, startpos(k,2)-1:startpos(k,2)+1, 3) = 0; 
% end
% figure, imshow(vidframe);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%