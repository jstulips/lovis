function xyz(vidfile)
vidfile = '001_2010-09-09_11-00-00';
load(['\LOST\001\MAT Files\',vidfile,'_trackedblobs'],'blobCell','trackCell');

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

% compute affinity matrix (Gaussian kernel) from distance matrix
sigma = 1;   % sigma = 5 as reported in paper seems like a really bad value...
AMat = exp(-distMat./(sigma^2));

% normalize distance matrix (using min-max normalization)
distMat = normalization(distMat,'minmax');

% perform k-means clustering
disp(sprintf('\nPerforming k-means clustering...'));
clusterNum = 41;
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


