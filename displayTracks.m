function displayTracks(vidFrame, clusterID, trackCell, blobCell, varargin)
% DISPLAYTRACKS Multi-purpose function for displaying/visualising tracks on
% video image. Overlays colored track lines on video image.
%
%   Usage: DISPLAYTRACKS(VIDFRAME, CLUSTERID, TRACKCELL, BLOBCELL, VARARGIN) 
%
%   Input:
%       VIDFRAME : video image frame
%       CLUSTERID : vector containing cluster IDs of all tracks
%       TRACKCELL : track cell data
%       BLOBCELL : blob cell data
%       VARARGIN : variable input arguments:
%           'exemplar' to indicate exemplar display mode
%           'over-clustered' to indicate over-clustered tracks display mode
%           'anomaly to indicate anomaly display mode
%
%   ** Usage example **
%   
%   Show all tracks in different clusters (colored)
%   displayTracks(vidFrame, clusterID, tracks, blobs_bbox);
%   
%   Show exemplar tracks only
%   displayTracks(vidFrame, clusterID, tracks, blobs_bbox, 'exemplar');
%
%   Show anomalous tracks (red) among all normal tracks (white)
%   displayTracks(vidFrame, anomalyhits, trackCell, blobCell, 'anomaly');
%
if nargin < 5 
    mode = 'all';  
elseif nargin >= 5      % standard number of inputs
    mode = char(varargin{1});
    if ~strcmp(char(varargin{1}),'all') & exist('mainTracks')
       mainTracks = varargin{2};
    end
elseif nargin < 4       % insufficient inputs
    error('Insufficient number of input arguments');
end

figure, imshow(vidFrame);

% obtain/set more variables
clusterCenters = unique(clusterID);
[n, clusterbin] = histc(clusterID, clusterCenters);
exemplarmode = 0;
blobsmode = 0;

if size(blobCell,2) ~= 4  % blobs_bbox are used as inputs
    blobsmode = 1;
end

switch mode
    case {'all','anomaly'}
        if blobsmode
            T = numel(clusterID);
        else
            T = length(trackCell);
        end
        title('All tracks');
        tIDx = 1:T;
        cIDx = clusterbin(1:T);
    case 'over-clustered'
        T = length(mainTracks);
        title('All tracks (after over-clustering step)');
        tIDx = mainTracks(1:T);
        cIDx = clusterbin(1:T);
    case 'exemplar'
        exemplarmode = 1;
        T = numel(n);
        title('Exemplar tracks');
        if blobsmode
            tIDx = clusterCenters(1:T); 
        else
            tIDx = mainTracks(clusterCenters(1:T));
        end
        cIDx = clusterbin(clusterCenters(1:T));
    otherwise
        error('Invalid mode option!');
end

% loop for drawing track lines
for f = 1 : T
    if blobsmode
        if exemplarmode
            bboxMat = blobCell{clusterCenters(f)};
        else
            bboxMat = blobCell{f};
        end
    else
        blobIdxs = trackCell{tIDx(f)}.blobIdxs;
        bbox = blobCell(blobIdxs, 4);
        bboxMat = cell2mat(bbox);   
    end
    
    h = line(bboxMat(:,2),bboxMat(:,1)); % draw the line
    
    % for anomalies, use only two specific colours
    if strcmp(mode,'anomaly')     
        if cIDx(f) == 1         % white: typical track
            set(h, 'color', [1 1 1]);
        elseif cIDx(f) == 2     % red: anomalous track    
            set(h, 'color', [1 0 0]);   
            set(h, 'LineWidth', 2);
        end
    else
        set(h, 'color', getColor(cIDx(f),1));
    end
        
    if exemplarmode
        set(h, 'LineWidth', 2);
        % draw circle marker to indicate destination
        line(bboxMat(end,2),bboxMat(end,1), 'Marker', 'o', 'MarkerSize', 4, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', getColor(cIDx(f),1));
        % add track exemplar number
        textpos = [bboxMat(1,2) bboxMat(1,1)-12 ];
        text(textpos(1),textpos(2),num2str(f),'FontSize',10, 'FontWeight', 'bold', 'Color', [1 1 1]);
    end
    
    hold on;
end
