function anomalyhits = testSynthAnomaly(distMatFile, queryDate, exemplarSet, nfv)
% TESTSYNTHANOMALY Function to evaluate a synthetically generated anomalous 
%                  track.
%
%   Usage: ANOMALYHITS = TESTSYNTHANOMALY(DISTMATFILE, QUERYDATE, EXEMPLARSET, NFV) 
%
%   Input:
%       DISTMATFILE : full distance matrix MAT filename (string) 
%       QUERYDATE : query date in ISO 8601 format (yyyy-mm-dd)
%       EXEMPLARSET : exemplar set data 
%       NFV : feature vector of the generated anomalous track
%
%   Output:
%       ANOMALYHITS : vector containing anomaly confidence probability
%       scores for all evaluated tracks on the selected query date 
%       (including the new generated anomalous track)
%

db_path = 'D:\LOST\';
mat_dir_name = 'Mat Files\';
options.verbose = 1;
load(distMatFile,'dtn');

% load variables from 'exemplarSet' object
tracks = exemplarSet.tracks;
tdtn = exemplarSet.tdtn;
tt = exemplarSet.tt;
clusterID = exemplarSet.clusterID;
threshold = exemplarSet.threshold;
eta = exemplarSet.eta;

id = find(dtn==datenum(queryDate));

    % obtain MAT-file corresponding to the query date 
    camera_id = strtok(distMatFile,'_');    
    matfile_path = [db_path, camera_id, '\', mat_dir_name];
    matfile_folder = dir([matfile_path,'\*_trackedblobs.mat']);
    fileformat = [camera_id,'_',datestr(dtn(id),29)];
    k = strncmp(fileformat,cellstr(char(matfile_folder.name)), 14);
    matfilename = matfile_folder(find(k)).name;
    cd(matfile_path);
    load(matfilename);
    
clusterC = unique(clusterID);
T = length(trackCell);
trackCell2 = trackCell;

% inject anomalous track
trackCell2{T+1}.trackID = 9999;
trackCell2{T+1}.numFrames = 17;
trackCell2{T+1}.fv = nfv;

% append exemplar tracks (cluster centers)
exTracks = trackCell2;
nNewTracks = length(exTracks);
for k = 1 : length(clusterC)
    tmp = tracks{clusterC(k)};
    exTracks{nNewTracks+k,1} = tracks{clusterC(k)}; 
end

% compute distances between new tracks and the track exemplar set
options.detectAnomaly = 1;
options.clusterC = clusterC;
lambda = 25;            % setting used in LOST paper
distMatNT = computeChamferDistMat(exTracks, lambda, options);
distMatNT = distMatNT(:,end-length(clusterC)+1:end); % extract only what is needed

% compute track max likelihood probabilities and find anomalies
likeprob = computeTrackLikelihood(distMatNT, eta);
[maxlike exIdx] = max(likeprob,[],2);            % take column-wise max
clustThresholds = threshold(exIdx);
anomalyhits = maxlike(:) < clustThresholds(:);
anomalyhits = double(anomalyhits);      % convert from logical
anomalyIdx = find(anomalyhits);
if isempty(anomalyIdx)
    disp('Track anomalies: -');
else
    disp(['Track anomalies: ',num2str(anomalyIdx')]);
end
disp(['Number of anomalies: ',num2str(length(anomalyIdx))]);


% find datenumber corresponding to cluster center that is nearest to
% each anomaly found
dn = tdtn(clusterC(exIdx(anomalyIdx)));     

% compute nonlinear drop-off probability
maxT = 7;
vecIdx = find(unique(tdtn));
dropoff = sigmoid(vecIdx/max(vecIdx)*maxT);

% match date of origin of cluster centers with all dates in range
% and obtain influence probality for each anomaly
[tf, loc] = ismember(dn,unique(tdtn));
anomalyhits(anomalyIdx) = dropoff(loc);

if find(anomalyIdx == T+1)
    disp('Injected anomaly found!');
end

% display typical and anomalous tracks on the new query video frame
cd([db_path, camera_id]);   
vidfilename_q = matfilename(1:max(findstr(matfilename,'_'))-1);
mov_q = VideoReader([db_path, camera_id, '\', vidfilename_q, '.avi']);  
vidFrame_q = read(mov_q, 1);
%displaySingleTrack(vidFrame_q, nfv(:,1:2));

