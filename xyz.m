% XYZ 
% Test experimental script to perform clustering on all tracks in one day
%
db_path = 'D:\LOST\';
mat_dir_name = 'Mat Files\';
options.verbose = 0;
options.display = 0;
distMatFile = '017_chamfer25_distMat';
querydate = '2013-11-07';           % yyyy-mm-dd

camera_id = strtok(distMatFile,'_');
matfile_path = [db_path, camera_id, '\', mat_dir_name];
cd(matfile_path);
load(distMatFile); 

idx = find(dtn == datenum(querydate));
if ~isempty(idx)
    distMat = distMatFull{idx};
    if isempty(distMat)
        disp('Problem: Distance matrix is empty.');
        disp(['Likely there are no tracks available on selected date ',querydate]);
        return;
    else
        matfile_folder = dir([matfile_path,'\*_trackedblobs.mat']);
        fileformat = [camera_id,'_',querydate];
        k = strncmp(fileformat,cellstr(char(matfile_folder.name)), 14);
        matfilename = matfile_folder(find(k)).name;
        load(matfilename);
    end
else
    error('Invalid query date! Information does not exist.');
end
%---------------------------------------------------------------------------------------------------------
% Clustering

% normalize distance matrix (using min-max normalization)
distMat = normalization(distMat,'minmax');

% compute affinity matrix (Gaussian kernel) from distance matrix
sigma = 1;   % sigma = 5 as reported in paper seems like a really bad value...
AMat = exp(-distMat./(sigma^2));

<<<<<<< HEAD
% perform k-means clustering
disp(sprintf('\nPerforming k-means clustering...'));
clusterNum = 7;
[centerIndex, U, objFun] = kMeansClusteringOnDist(distMat, clusterNum);
[clusterID tID] = find(U);
=======
% perform over-clustering with k-means to obtain only main tracks
minClustSize = 4;
[mainTracks, Ntt] = overclustering(distMat, minClustSize);

% re-format AMat using only the main tracks 
minorTracks = setdiff(1:length(AMat),mainTracks)';
AMat(minorTracks, :) = [];      % discard rows of minorTracks
AMat(: , minorTracks) = [];      % discard columns of minorTracks

% clustering with affinity propagation
prefvector = median(AMat,2) ./ Ntt;        % take row-wise median values as preference vector
[clusterID,netsim,dpsim,expref] = apcluster(AMat, prefvector);   % use default settings
clusterCenters = unique(clusterID);
clusterNum = length(clusterCenters);

% histogram of clusters
[bincount2, clusterbin] = histc(clusterID,clusterCenters);
disp(['Number of clusters: ',num2str(length(bincount2))]);
>>>>>>> lovis-suyin

% show clustered tracks on video frame in coloured trajectories
cd('D:\LOST\001\');
vidfile = matfilename(1:max(findstr(matfilename,'_'))-1);
mov = VideoReader([vidfile,'.avi']);
vidFrame = read(mov, 1);

displayTracks(vidFrame, clusterID, trackCell, blobCell, 'over-clustered', mainTracks);
displayTracks(vidFrame, clusterID, trackCell, blobCell, 'exemplar', mainTracks);

% draw histogram bar
displayHist(bincount2); 



