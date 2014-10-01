function [mainTracks, Ntt] = overclustering(distMat, minClustSize)
% OVERCLUSTERING Perform over-clustering step on tracks to remove outliers
%                or data samples that are far from the true cluster
%                centers. MINCLUSTSIZE defines the minimum cluster size
%                whereby any smaller clusters will be discarded 
%
%   Usage: [MAINTRACKS, NTT] = OVERCLUSTERING(DISTMAT, MINCLUSTSIZE) 
%
%   Input:
%       DISTMAT : full distance matrix  
%       MINCLUSTSIZE : minimum cluster size (any smaller will be discarded 
%                      in this over-clustering procudure 
%
%   Output:
%       MAINTRACKS : vector containing the track number of tracks that have 
%                    been retained after over-clustering 
%       NTT : vector containing the number of "true tracks", or actual 
%             tracks discarded from this process, associated with each 
%             retained track 
%

option.messageDisplay = 0;
option.maxIter = 100;
option.minImprovement = 1e-5;

disp('-- 1st k-means pass...'); 
Nclust = floor(size(distMat,1)/minClustSize);
[centerIdx, U, objFun] = kMeansClusteringOnDist(distMat, Nclust, option);
[clustID tID] = find(U);
[bincount1, clustbin] = histc(clustID, unique(clustID));
mainTracks = [];
for k = 1 : Nclust
    clustMembers = find(clustID == k);
    if length(clustMembers) >= minClustSize
        mainTracks = [mainTracks; clustMembers];
    end
    mainTracks = sort(mainTracks);
end
% compute number of true tracks for each over-clustered track
% 2nd k-means pass
disp('-- 2nd k-means pass...');
[centerIdx, U, objFun] = kMeansClusteringOnDist(distMat, length(mainTracks), option);
[cID tID] = find(U);
[Ntt, cb] = histc(cID, unique(cID));

disp(['Original number of tracks: ',num2str(length(clustID))]);
disp(['Over-clustered tracks: ',num2str(length(Ntt))]);