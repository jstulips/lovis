function [likelihood, eta] = computeTrackLikelihood(distM, eta)
% COMPUTETRACKLIKELIHOOD Computes track likelihood probabilities.
%                        If parameter eta is not provided, this function
%                        computes it.
%
%   Usage: [LIKELIHOOD, ETA] = COMPUTETRACKLIKELIHOOD(DISTM, ETA) 
%
%   Input:
%       DISTM : square distance matrix  
%       ETA : parameter estimated by maximum likelihood estimation (MLE),  
%             define as the reciprocal of the mean distances learnt from  
%             the track distribution (expected value)
%
%   Output:
%       LIKELIHOOD : likelihood probability of the tracks considered
%       ETA : (as described above)
%

if nargin == 1
    eta = length(distM) / sum(distM);
elseif nargin < 1
    error('Error! Insufficient input arguments');
else
    eta = repmat(eta, size(distM,1), 1);
end
likelihood = exp(-(eta.*(distM)));

