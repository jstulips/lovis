vidfile = '011_2014-04-12_11-00-01';
load([vidfile,'_trackedblobs']);

% compute pairwise distance matrix
T = length(trackCell);
distMat = zeros(T,T);
for f = 1 : T
    for g = 1 : T
        if (f == g)
            continue;        
        else
            P = trackCell{f}.fv;
            Q = trackCell{g}.fv;
            distMat(f,g) = chamferDist(P, Q, 25);    
        end
    end
    disp(['Computing distances from track ',num2str(f),' / ',num2str(T)]);
end

% normalize distance matrix (using min-max normalization)
distMat = normalization(distMat,'minmax');

% perform k-means clustering
disp(sprintf('\nPerforming k-means clustering...'));
clusterNum=7;
[centerIndex, U, objFun] = kMeansClusteringOnDist(distMat, clusterNum);
[clusterID tID] = find(U);

% show clustered tracks on video frame in coloured trajectories
mov = VideoReader([vidfile,'.avi']);
vidFrames = read(mov);
figure, imshow(vidFrames(:,:,:,1));
for f = 1 : T
    blobIdxs = trackCell{f}.blobIdxs;
    bbox = blobCell(blobIdxs, 4);
    bboxMat = cell2mat(bbox);
    line(bboxMat(:,2),bboxMat(:,1),'color', getColor(clusterID(f),1));
    hold on;
end

% histogram of clusters
H = hist(clusterID,clusterNum)'; 
figure
for i=1:numel(H)
  h = bar(i, H(i));
  %if i == 1, 
  hold on;
  %end
  set(h, 'FaceColor', getColor(i,1)) 
end  


