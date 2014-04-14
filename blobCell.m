function blobCell = extractblob(vidfile, options)
% EXTRACTBLOB Extract tracked blobs from LOST dataset based on
%             textfile data provided
%
%   BLOBCELL = EXTRACTBLOB(VIDFILE, OPTIONS) 
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
%       BLOBCELL = cell array, containing extracted tracked blob image                    
%                   (in uint8 type)
%
%   Example of usage:
%       vidfile = '006_2010-07-24_17-00-00';
%       blobcell = extractblob(vidfile);
%
%   --Copyright LoViS, 2014
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

[tr, tfr, tx1, ty1]=textread([vidfile,'_tracks.txt'], '%d %d %d %d',-1);
trackMat = [tr tfr tx1 ty1];
[fr, x, y, w, h]= textread([vidfile,'_blobs.txt'], '%d %d %d %d %d',-1);
blobMat = [fr x y w h];

n_lines = size(trackMat, 1);        % take number of lines from tracks.txt
blobCell = cell(n_lines,1);         % create blob cell variable

for i=1:n_lines
    % re-assign some variables for convenience           
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
    
    % Read image from video object and extract blob
    img = read(mov,fr1);
    blob_img = img(sy:esy,sx:esx);
    if options.verbose
        disp(['Size of blob #',num2str(i),': ',num2str(size(blob_img))]); 
    end

    % store in cell variable containing extracted blob images
    blobCell{i} = blob_img;
        if options.display      
            imshow(blob_img);
            title(['T ',num2str(fr1),' | F ',num2str(fr1)]);
            pause(0.5);         
            close all;
        end
    
    % [SHELVED] imwrite to the disk to store a copy of the extracted blob
    % For now, just store in .mat workspace file for more compact storage
end

% Save blob cell variable to storage
save([vidfile,'_trackedblobs'],'blobCell');  
