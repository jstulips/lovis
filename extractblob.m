function [blobCell, trackCell, timesortedBlobs] = extractblob(vidfile, options)
% EXTRACTBLOB Extract tracked blobs from LOST dataset based on
%             textfile data provided
%
%   Usage: [BLOBCELL, TRACKCELL, TIMESORTEDBLOBS] = EXTRACTBLOB(VIDFILE, OPTIONS) 
%
%   Input:
%       VIDFILE = video filename without extension
%       OPTIONS = a selection of options 
%           OPTIONS.DISPLAY = display blob image extracted
%                            (1 = yes, 0 = no (default))    
%           OPTIONS.VERBOSE = show stepwise progress (per blob)
%                            (1 = yes (default), 0 = no)
%
%   Output:
%       BLOBCELL = M-by-4 cell array, containing information for
%                  M tracked blob images
%                     Column 1: Track number (data key)
%                     Column 2: Frame number (data key)
%                     Column 3: Blob image (RGB values, uint8)
%                     Column 4: Bounding box ROI (6 values), defining
%                          [yCenter xCenter yTopLeft xTopLeft width height]
%                               
%                             Note: Matlab handles image coordinates and
%                             graphic coordinates differently. For images,
%                             x denotes vertical axis (rows), y denotes
%                             horizontal axis (cols). For graphic/plotting,
%                             it follows typical graph figures, x for
%                             horizontal axis (cols), y for vertical axis 
%                             (rows)
%
%       TRACKCELL = cell array, containing track information:
%                   TRACKCELL.NUMFRAMES = number of frames in track
%                   TRACKCELL.LABEL = track label
%                   TRACKCELL.BLOBIDXS = IDs of tracked blobs, 
%                   corresponding to the indices in BLOBCELL
%                   TRACKCELL.BLOBFRAMENUMS = Frame number of tracked blobs 
%
%                   [Currently excluded] 
%                   TRACKCELL.BLOBSIZES = Sizes of blobs in track
%
%                   [ .. More track information will be added later .. ]
%
%       TIMESORTEDBLOBS = matrix containing same information in 'tracks'
%                         textfile, but sorted according to frame (time)
%
%   Example of usage:
%       vidfile = '006_2010-07-24_17-00-00';
%       options.display = 1;       
%       options.verbose = 1;
%       blobcell = extractblob(vidfile,options);
%
%   --Copyright LoViS, 2014, 17-04-2014
%
if nargin < 1
     error('Too few input arguments'); 
elseif nargin < 2
     options = struct('display',0,'verbose',1); 
end
if ~isfield(options,'display')
     options.display = 0; 
end
if ~isfield(options,'verbose')
     options.verbose = 1; 
end

mov = VideoReader([vidfile,'.avi']);            % assume AVI format for current use

[fr, x, y, w, h]= textread([vidfile,'_blobs.txt'], '%d %d %d %d %d',-1);
blobMat = [fr x y w h]; 

[tr, tfr, tx1, ty1]=textread([vidfile,'_tracks.txt'], '%d %d %d %d',-1);
% Clean up track information (remove rows with frame '0')
framezero = find(tfr==0);
for k=1:length(framezero)
    [tr,settings1] = removerows(tr,'ind',framezero(1));
    [tfr,settings2] = removerows(tfr,'ind',framezero(1));
    [tx1,settings3] = removerows(tx1,'ind',framezero(1));
    [ty1,settings4] = removerows(ty1,'ind',framezero(1));
    framezero = find(tfr==0);           % find again iteratively
end
trackMat = [tr tfr tx1 ty1];
% sort rows according to frame number (time)
timesortedBlobs = sortrows(trackMat,2);  

numBlobs = size(trackMat, 1);        % take number of lines from tracks.txt
numTracks = length(unique(tr));      % take unique number of tracks from tracks.txt
blobCell = cell(numBlobs,2);         % create blob cell variable
trackCell = cell(numTracks,1);       % create track cell variable

% Blob cell information
for i=1:numBlobs
    % Re-assign some variables for convenience           
    fr1 = tfr(i);
    x1 = tx1(i); 
    y1 = ty1(i);
    
    % Locate tracked object from "tracks_txt" in "blobs.txt"
    blobIdx = intersect(intersect(find(fr1==fr),find(x1==x)),find(y1==y));           
    
    if (fr1 == fr(blobIdx) && x1 == x(blobIdx) && y1 == y(blobIdx))
        sx = x1 - ceil(w(blobIdx)/2);       % Note: x moves horizontally (left to right) along width
        sy = y1 - ceil(h(blobIdx)/2);       % Note: y moves vertically (top to bottom) along height        
        esx = sx+w(blobIdx)-1;              % end position for x
        esy = sy+h(blobIdx)-1;              % end position for y
        
        % Fix boundary if blob region falls to either edge of image
        if (sx < 1) 
            sx = 1; 
        end
        if (sy < 1)
            sy = 1; 
        end
        if ((x1 + ceil(w(blobIdx)/2)-1) > mov.Width) 
            esx = mov.Width; 
        end
        if ((x1 + ceil(h(blobIdx)/2)-1) > mov.Width) 
            esy = mov.Height; 
        end
    end
    
    % Append track number and frame number (data keys) to blobCell
    blobCell{i,1} = tr(i);          % COL#1: track number    
    blobCell{i,2} = fr1;            % COL#2: frame number
    
    % Read image from video object and extract blob
    img = read(mov,fr1);
    blob_img = img(sy:esy,sx:esx,:);
    if options.verbose
        disp(['Processing blob ',num2str(i),' / ',num2str(numBlobs),'...']); 
    end
    blobsizes(i) = numel(blob_img)/3;    % Determine blob size
 
    % Store in cell variable -- extracted blob images & blob dimension info
    blobCell{i,3} = blob_img;       % COL#3: blob image
        if options.display      
            imshow(blob_img);
            title(['T ',num2str(fr1),' | F ',num2str(fr1)]);
            pause(0.25);         
            close all;
        end
    blobCell{i,4} = [y1 x1 sy sx w(blobIdx) h(blobIdx)];   % COL#4: bounding box
        
    % [SHELVED] imwrite to the disk to store a copy of the extracted blob
    % For now, just store in .mat workspace file for more compact storage
end

% Track cell information
trackCount = nonzeros(sparse(histc(tr,0:max(tr))));
trackIdx = unique(tr);

for t=1:numTracks
    trackCell{t}.trackID = trackIdx(t);
    trackCell{t}.numFrames = trackCount(t);
    trackCell{t}.label = '';
    trackCell{t}.blobIdxs = find(tr==trackIdx(t));
    trackCell{t}.blobFrameNums = tfr(trackCell{t}.blobIdxs);
    %trackCell{t}.blobSizes = blobsizes(trackCell{t}.blobIdxs)';
    
    % More track information to be appended over here
    % e.g. velocity, feature descriptor, etc. 
end

% Save important variables to storage
save([vidfile,'_trackedblobs'],'blobCell','trackCell','timesortedBlobs');  
