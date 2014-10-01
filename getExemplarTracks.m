function [clusterID, bc, errorFlag] = getExemplarTracks(distMat, ocflag)
% GETEXEMPLARTRACKS Function to cluster and obtain exemplar tracks from all 
%                   considered tracks from a single day
%
%   Usage: [CLUSTERID, BC, ERRORFLAG] = GETEXEMPLARTRACKS(DISTMAT, OCFLAG) 
%
%   Input:
%       CLUSTERID : vector containing cluster IDs of all exemplar tracks
%       BC : histogram count for each bin after performing clustering
%       ERRORFLAG : error flag, indicating problem in the affinity matrix
%                   (values mostly 0 or NaN), exit function immediately, 
%                   feedback error
%
%   Output:
%       DISTMAT : distance matrix       
%       OCFLAG : over-clustering flag - set to 1 to enable over-clustering
%                step
%

if nargin == 1
    ocflag = 1;     % default: overclustering ON
end

errorFlag = 0;      % default, no errors

% normalize distance matrix (using min-max normalization)
distMat2 = normalization(distMat,'minmax');
% if all(all(distMat))
     distMat = distMat2;
% end

% compute affinity matrix (Gaussian kernel) from distance matrix
sigma = 1; 
AMat = exp(-distMat./(sigma^2));

% perform over-clustering with k-means to obtain only main tracks
minClustSize = 4;
if length(distMat) >= 2*minClustSize
    if ocflag
        [mainTracks, Ntt] = overclustering(distMat, minClustSize);

        % re-format AMat using only the main tracks 
        minorTracks = setdiff(1:length(AMat),mainTracks)';  
        AMat(minorTracks, :) = [];      
        AMat(: , minorTracks) = [];
    else
        Ntt = ones(length(distMat),1);
    end
else
    if all(all(AMat == eye(length(distMat)))) 
        errorFlag = 1;
        clusterID = [];
        bc = [];
        return;
    end
    Ntt = ones(length(distMat),1);
end
    
% clustering with affinity propagation
prefvector = median(AMat,2);        % take row-wise median values as preference vector weighted by number of true tracks
[clusterID,netsim,dpsim,expref] = apcluster(AMat, prefvector);   % use default settings

% count size of bins (to determine original number of true tracks)
[bc, bins] = histc(clusterID, unique(clusterID));
disp(['Number of clusters: ',num2str(length(bc))]);


