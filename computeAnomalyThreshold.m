function [threshold, eta] = computeAnomalyThreshold(clusterID, distExMat)
% COMPUTEANOMALYTHRESHOLD Computes the anomaly threshold for each track
%                         exemplar or cluster
%
%   Usage: [THRESHOLD, ETA] = COMPUTETRACKLIKELIHOOD(CLUSTERID, DISTEXMAT) 
%
%   Input:
%       CLUSTERID : vector containing cluster IDs of all exemplar tracks
%       DISTEXMAT : distance matrix of the exemplar tracks
%
%   Output:
%       LIKELIHOOD : likelihood probability of the tracks considered
%       ETA : parameter estimated by maximum likelihood estimation (MLE),  
%             define as the reciprocal of the mean distances learnt from  
%             the track distribution (expected value)
%

clusterC = unique(clusterID);
[n, clusterbin] = histc(clusterID, clusterC);

dist2C = [];
for k = 1 : length(clusterC)            % known problem: what if there's only one data point?
    tr = find(clusterbin==k);
    if length(tr) > 1
        tr(find(tr==clusterC(k))) = [];
        dist2C = distExMat(tr,clusterC(k));
        [prob, eta(k)] = computeTrackLikelihood(dist2C);
        threshold(k) = min(prob);
        while (min(prob) < 1e-4)
            prob(find(prob < 1e-4)) = [];
            threshold(k) = min(prob);
        end
    else
        threshold(k) = 0;       % only one data point in cluster, that is the exemplar itself
    end
        
end