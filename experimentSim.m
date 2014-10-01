% EXPERIMENTSIM
% Driver script for performing anomalous track mining on the LOST dataset
% based on a selected query date.
%
db_path = 'D:\LOST\';
mat_dir_name = 'Mat Files\';
options.verbose = 1;
options.display = 0;
distMatFile = '001_chamfer25_distMat';
load(distMatFile);

% parameters for 3 time-scales; to generate 3 sets of exemplar sets:
% 1) last 4-5 similar-days (weekly stride)
% 2) last 7 days (a week)
% 3) last 30 days (a month)
startDate = [28 7 30];
endDate = '2012-01-30';
queryDate = '2012-01-31';
stride = {'week', '', ''};

% GOOD VALUES: 001 - end date: 2012-01-30, query date: 2012-01-31

for i = 1 : 3   % iterations corresponding to time-scales
    exemplarSet{i} = getExemplarsInRange(distMatFile, startDate(i), endDate, stride{i}); 
    anomalyhits(:,i) = testAnomaly(distMatFile, queryDate, exemplarSet{i});
end
omega = 0.5;        % anomaly threshold
anomalyprob = mean(anomalyhits,2);
overallAnomalyHits = (anomalyprob > omega);
disp(['Final anomalies: ',num2str(find(overallAnomalyHits'))]);

% draw final anomalous tracks on video frame
getFrame
displayTracks(vidFrame, single(overallAnomalyHits), trackCell, blobCell, 'anomaly');
%----------------------------

% generate synthetic anomalous track and classify it thereafter
generateAnomaly;
for i = 1 : 3
    anomalyhits2(:,i) = testSynthAnomaly(distMatFile, queryDate, exemplarSet{i}, nfv);
end
omega = 0.5;        % anomaly threshold
anomalyprob2 = mean(anomalyhits2,2);
overallAnomalyHits2 = (anomalyprob2 > omega);
disp(['Final anomalies: ',num2str(find(overallAnomalyHits2'))]);
displayTracks(vidFrame, single(overallAnomalyHits2), trackCell, blobCell, 'anomaly');

if any(find(overallAnomalyHits2 == size(anomalyhits,1)))
    disp('Injected anomaly found!');
end    