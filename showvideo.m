%vidfile = '006_2010-07-24_17-00-00';
vidfile = '017_2013-07-27_11-00-01'; 
%vidfile ='001_2011-09-14_11-00-00';
load(['\LOST\017\MAT Files\',vidfile, '_trackedblobs.mat']);

% Video playback
reader = video.MultimediaFileReader([vidfile,'.avi']);
hdvp = video.DeployableVideoPlayer;
hdvp.Location = [150 -75];
hdvp.FrameRate = 5;

% Write video to disk
%hmfw = video.MultimediaFileWriter([vidfile,'_visuals.avi'],'AudioInputPort',false,'VideoInputPort',true);
%hmfw.FrameRate = hdvp.FrameRate;        % use same frame rate as original

% Initialize graphic objects
shapes = video.ShapeInserter('BorderColor','Custom',...
    'CustomBorderColor',[0 255 0],'Antialiasing',1);
    
shapes2 = video.ShapeInserter('Fill',1,'FillColor','white','Opacity',0.5);

tracklines = video.ShapeInserter('Shape','Lines',...
    'BorderColorSource','Input port','Antialiasing',1);
linecolor =[[0,255,0];          % green
            [255,0,255];        % magenta 
            [0,255,255];        % cyan
            [255,255,0];        % yellow
            [255,0,0];          % red
            [0,0,255];          % blue
            [255,255,255];      % white
           ];                   % to differentiate 7 tracks at the same time
linecolor = single(linecolor);
colorLookUpTab = [];

centroidmarker = video.MarkerInserter('Shape','Circle','Size',2,...
    'Fill',1,'FillColor','Custom','CustomFillColor',[255 0 0],...
    'Antialiasing',1);

framenumtext = video.TextInserter('%d','LocationSource','Input port',...
    'Color', [0, 0, 0],'FontSize', 10);

f = 0;                              % initialize frame counter
warning off;                        % turn off object locking warning
while ~isDone(reader)
    frame = step(reader);
    
    bIdx = find(timesortedBlobs(:,2)==f);           % find indices
    if ~isempty(bIdx)
        % calculate graphic regions
        bKeys = timesortedBlobs(bIdx,1:2);                % get keys
        currentTracks = bKeys(:,1);                       % track numbers
        currentTracks = int32(currentTracks); 
        
        [~,indx] = ismember(bKeys,cell2mat(blobCell(:,1:2)),'rows');   % search
        bROI = cell2mat(blobCell(indx, 4));
        bbrects = [bROI(:,3) bROI(:,4) bROI(:,6) bROI(:,5)]';     % [row col height width]
        centroids = bROI(:,1:2)';
        xOffset = 0;
        fntextpos = [bROI(:,3)-xOffset bROI(:,4)]';
            
        n = length(currentTracks);
        
        % update track-color lookup table
        for i=1:n
            if isempty(colorLookUpTab)
                colorLookUpTab = [currentTracks(i) linecolor(1,:)];
                linecolor = circshift(linecolor,-1);     % shift order of colors
            elseif isempty(find(currentTracks(i)==colorLookUpTab(:,1)))
                colorLookUpTab = [colorLookUpTab; [currentTracks(i) linecolor(1,:)]];
                linecolor = circshift(linecolor,-1);     % shift order of colors
            end           
        end
        
        % plot track lines
        for i=1:n     
            if eval(['exist(''T' num2str(currentTracks(i)) ''')'])
                eval(['T' num2str(currentTracks(i)) ' = [T' num2str(currentTracks(i)) ' bROI(i,1:2)];']);
                colorIdx = find(currentTracks(i)==colorLookUpTab(:,1)); 
                eval(['frame = step(tracklines,frame,T' num2str(currentTracks(i)) ',single(colorLookUpTab(colorIdx,2:4)));']);                 
            else
                eval(['T' num2str(currentTracks(i)) ' = [bROI(i,1:2)];']);
            end                
        end
          
        frame = step(shapes,frame,bbrects);   % overlay green object rectangle
        frame = step(shapes2,frame,bbrects);  % overlay shading rectangle
        frame = step(centroidmarker,frame,centroids);
       
        % *** NOTE: INSERTING TEXT REAL-TIME CAUSES VIDEO TO LAG
        % overlay track number in box
        frame = step(framenumtext, frame, currentTracks, fntextpos);
        
        % release all locked objects
        release(shapes);
        release(shapes2);
        release(centroidmarker);
        release(tracklines);
        release(framenumtext);
    end
    step(hdvp, frame);
    %step(hmfw, frame);      % WRITE FRAME TO FILE
    f = f+1;                % keep track of frame number
end
release(reader);       
release(hdvp);
clear all;