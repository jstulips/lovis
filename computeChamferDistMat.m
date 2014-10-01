function distMat = computeChamferDistMat(trackCell, lambda, options)
% COMPUTECHAMFERDISTMAT Computes distance matrix of all considered tracks 
%                       based on assymmetrical Chamfer distance metric.
%                       Computation for anomaly mining/detection mode is
%                       faster as only the distances between the track
%                       exemplars and the new query tracks need to be
%                       computed.
%
%   Usage: DISTMAT = COMPUTECHAMFERDISTMAT(TRACKCELL, LAMBDA, OPTIONS) 
%
%   Input:
%       TRACKCELL : full distance matrix  
%       LAMBDA : multiplier for velocity variables (to normalise them against 
%                positional variables). 
%       OPTIONS : further options (optional)
%               OPTIONS.DETECTANOMALY : set to 1 when in anomaly
%                                       mining/detection mode
%               OPTIONS.CLUSTERC = define unique set of cluster centers,
%               set this if OPTIONS.DETECTANOMALY = 1
%
%   Output:
%       DISTMAT : distance matrix of all considered tracks
%                    

T = length(trackCell);    
if isfield(options,'detectAnomaly') & options.detectAnomaly    % using detect anomaly mode 
    if isfield(options,'clusterC')
        nC = length(options.clusterC);
        sourceRange = 1:T-nC;
        destRange = T-nC+1:T;
    else
        error('options.clusterC not defined for detectAnomaly mode!');
    end
    distMat = zeros(T-nC,nC);
else                        % normal mode
    sourceRange = 1:T;
    destRange = 1:T;
    distMat = zeros(T,T);
end

for f = sourceRange
    for g = destRange
        if (f == g)
            continue;        
        else
            P = trackCell{f}.fv;
            Q = trackCell{g}.fv;
            distMat(f,g) = chamferDist(P, Q, lambda);    
        end
    end
    if options.verbose
        disp(['Computing distances from track ',num2str(f),' / ',num2str(length(sourceRange))]);
    end
end
