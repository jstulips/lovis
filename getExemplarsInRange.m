function [exemplarSet, errors] = getExemplarsInRange(distMatFile, startDate, endDate, stride)
% GETEXEMPLARSINRANGE Function to get all exemplar tracks from a specified 
%                     range of dates and stride
%
%   Usage: [EXEMPLARSET, ERRORS] = GETEXEMPLARSINRANGE(DISTMATFILE, STARTDATE, ENDDATE, STRIDE) 
%
%   Input:
%       DISTMATFILE : full distance matrix MAT filename (string)
%       STARTDATE : start date in ISO 8601 format (yyyy-mm-dd)
%       ENDDATE : end date in ISO 8601 format (yyyy-mm-dd) 
%       STRIDE : stride interval - default specifies daily stride (1 day). 
%                'week' specifies weekly stride (7 days)
%
%   Output:
%       EXEMPLARSET : exemplar set data
%       ERRORS : return errors on the date availability (if dates do not have data),
%                stopping process altogether
%

errors = 0;     % default, no error
if nargin < 4
    stride = '';      % no stride struct specified
end

% define paths
db_path = 'D:\LOST\';
mat_dir_name = 'Mat Files\';
options.verbose = 0;
options.display = 0;

camera_id = strtok(distMatFile,'_');
matfile_path = [db_path, camera_id, '\', mat_dir_name];
cd(matfile_path);
load(distMatFile); 

% check (if startDate or endDate are numerical ranges) and parse inputs
if isnumeric(startDate) & isnumeric(endDate)
    error('Input error. Both startDate and endDate are numerics');
elseif isnumeric(startDate)
    startDate = datestr(datenum(endDate) - startDate + 1, 29);
elseif isnumeric(endDate)        
    endDate = datestr(datenum(startDate) + endDate - 1, 29);
end

if isstr(startDate) & isstr(endDate)
    startIdx = find(dtn == datenum(startDate));
    endIdx = find(dtn == datenum(endDate));
end
if isempty(startIdx) | isempty(endIdx)
    errors = 1;
    exemplarSet = [];
    disp(['Day skipped. Insufficient training data for query date!']);
    return;
else
    dateRange = startIdx : endIdx;
end

exemplarSet.startDate = startDate;      % store
exemplarSet.endDate = endDate;          % store

if exist('stride') & strcmp(stride,'week') 
    queryDate = datestr(datenum(endDate) + 1, 29);
    queryIdx = find(dtn == datenum(queryDate));
    queryDay = weekday(dtn(queryIdx));
    newdateRange = dateRange(find(weekday(dtn(dateRange)) == queryDay));
    dateRange = newdateRange; 
    exemplarSet.stride = stride;
end

tracks = [];
tdtn = [];
tt = [];        % true tracks
if ~isempty(startIdx) 
    if ~isempty(endIdx)
        d = 0;           % internal counter for day
        tr = 0;          % internal counter for track
        for id = dateRange
            if isempty(distMatFull{id}) | (dtn(id)==735545) | (dtn(id)==735657) 
                disp(['No tracks available for date: ',datestr(dtn(id),29)]);
                disp('Action: Skipped. Day not considered.');
                continue;
            else 
                d = d + 1;
                distMat = distMatFull{id};
               
                % get exemplar tracks from all tracks from a single day     
                disp(['Extract exemplar tracks from ', datestr(dtn(id),29)]);
                [clusterID, bcount, errorflag] = getExemplarTracks(distMat, 1);
                if errorflag
                    disp('Affinity matrix is an identity matrix.');
                    disp('Action: Skipped. Day not considered.');
                    continue;
                end
                
                % load trackedblobs MAT-file
                matfile_folder = dir([matfile_path,'\*_trackedblobs.mat']);
                fileformat = [camera_id,'_',datestr(dtn(id),29)];
                k = strncmp(fileformat,cellstr(char(matfile_folder.name)), 14);
                matfilename = matfile_folder(find(k)).name;
                load(matfilename);
                
                % get track and blob bbox information of the exemplars
                clusterC = unique(clusterID);
                tracks = [tracks; trackCell(clusterC)];
                tt = [tt; bcount];
                for k = 1 : length(clusterC)
                    tr = tr + 1;
                    blobs_bbox{tr} = cell2mat(blobCell(trackCell{clusterC(k)}.blobIdxs, 4));
                    tdtn = [tdtn; dtn(id)];
                end
            end
        end
    else
        error('Invalid END DATE! Information does not exist for this date.');
    end
else
    error('Invalid START DATE! Information does not exist for this date.');
end

options.verbose = 1;
lambda = 25;            % setting used in LOST paper
distExMat = computeChamferDistMat(tracks, lambda, options);
distExMatNorm = normalization(distExMat,'minmax');
sigma = 1; 
AExMat = exp(-distExMatNorm./(sigma^2));

alpha = testTSC(distExMat, AExMat, tt);         % test for TSC and obtain best alpha value

[pmin, pmax] = preferenceRange(AExMat); 
prefExvector = median(AExMat,2).*tt ./ (alpha*mean(tt));
prefExvector(prefExvector>pmax) = pmax;
prefExvector(prefExvector<pmin) = pmin;
[clusterID,netsim,dpsim,expref] = apcluster(AExMat, prefExvector);  

% compute anomaly thresholds for each track cluster, and eta value
[threshold, eta] = computeAnomalyThreshold(clusterID, distExMat);

%------------------------------------------------------------------
% display stuff...
% display histogram of track clusters
clusterC = unique(clusterID);
[n, clusterbin] = histc(clusterID, clusterC);
displayHist(n);

% display all tracks and exemplar tracks from the date range
cd([db_path, camera_id]);
vidfilename = matfilename(1:max(findstr(matfilename,'_'))-1);
mov = VideoReader([db_path, camera_id, '\', vidfilename, '.avi']);
vidFrame = read(mov, 1);
displayTracks(vidFrame, clusterID, tracks, blobs_bbox);
displayTracks(vidFrame, clusterID, tracks, blobs_bbox, 'exemplar');

% transfer variables to output variable 'exemplarSet'
exemplarSet.days = d;
exemplarSet.tracks = tracks;
exemplarSet.tdtn = tdtn;
exemplarSet.tt = tt;
exemplarSet.clusterID = clusterID;
exemplarSet.threshold = threshold;
exemplarSet.eta = eta;
exemplarSet.alpha = alpha;                   