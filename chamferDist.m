function d = chamferDist(P, Q, lambda_v)
% CHAMFERDIST Computes Chamfer distance from feature A to feature B
%   A and B can be of different length, but contains the same N features
%   d: Chamfer distance from A to B
%
mult = [1 1 lambda_v lambda_v];

% for each sample in A, compute minimum distance from samples in B
for p = 1:size(P,1)
    c = repmat(P(p,:), size(Q,1), 1) - Q;
    df = (c.^2) * mult';
    mq(p) = min(df);
end
d = mean(mq);           % compute mean of all minimum distances