function a = testTSC(distExMat, AExMat, tt)
% TESTTSC Function to evaluate Tightness and Separation Criterion (TSC)
%         with different alpha values. Automatically returns a near-optimal
%         value for alpha based on a set of heuristical criterion
%
%   Usage: A = TESTTSC(DISTEXMAT, AEXMAT, TT) 
%
%   Input:
%       DISTEXMAT : distance matrix for exemplar tracks
%       AEXMAT : affinity matrix for exemplar tracks
%       TT : vector containing number of child ('over-clustered') tracks
%       represented by each exemplar track
%
%
alpha = [0.5:0.25:4]; % range of coefficient alpha
[pmin, pmax] = preferenceRange(AExMat);

for i = 1 : length(alpha)   
    disp(['Evaluating TSC for ',num2str(alpha(i)),'...']);
    % take row-wise median values as preference vector
    prefExvector = median(AExMat,2).*tt ./ (alpha(i) * mean(tt));
    prefExvector(prefExvector>pmax) = pmax;
    prefExvector(prefExvector<pmin) = pmin;
    
    [clusterID,netsim,dpsim,expref] = apcluster(AExMat, prefExvector); 
    ns(i) = netsim;
    
    % compute Tightness and Separation Criterion (TSC)
    clusterC = unique(clusterID);
    [n, clusterbin] = histc(clusterID, clusterC);
    csz(i) = length(n); 
    
    dist2Centroid = [];
    distBtCentroids = [];
    for k = 1 : length(clusterC)
        tr = find(clusterbin==k);
        dist2Centroid = [dist2Centroid; (distExMat(tr,clusterC(k)).^2)];
        
        otherCentroids = setdiff(clusterC, clusterC(k));
        distBtCentroids = [distBtCentroids; (distExMat(clusterC(k),otherCentroids).^2)'];          
    end
    tsratio = mean(dist2Centroid) / min(distBtCentroids);
    if isempty(tsratio)
        tsc(i) = eps;
    else
        tsc(i) = tsratio;
    end
end

% Plots
fg1 = figure; 
[ax1, h1, h2] = plotyy(alpha, tsc, alpha, csz);
hold on;
set(h2,'color','red')
set(ax1,{'ycolor'},{'b';'r'})

fg2 = figure; 
gtsc2 = gradient(gradient(tsc));
gcsz2 = gradient(gradient(csz));
Ylimits = [min([gtsc2(:); gcsz2(:)]) max([gtsc2(:); gcsz2(:)])];
[ax2, h1, h2] = plotyy(alpha, gtsc2, alpha, gcsz2);
hold on; 
set(h1,'marker','o');
set(h2,'color','red', 'marker', '*')
set(ax2,{'ycolor'},{'b';'r'})
set(ax2(1),'YLim',Ylimits);
set(ax2(2),'YLim',Ylimits);

% Heuristics for selecting alpha value
lowthres = 0.01; % 1 percent

% heuristic 1
q1 = lowthres;
graddiff = abs(gtsc2-gcsz2);
while(isempty(find(graddiff < max(graddiff)*q1)))
    q1 = q1*2;
end
id1 = min(find(graddiff < max(graddiff)*q1));

% heuristic 2
q2 = lowthres;
while(isempty(find(tsc < max(tsc)*q2)))
    q2 = q2*2;
end
id2 = min(find(tsc < max(tsc)*q2));

id = max(id1,id2);

a = alpha(id)
%a = input('Manual selection of alpha value: ');

disp(['Alpha selected: ',num2str(a)]);

%close(fg1);
%close(fg2);
