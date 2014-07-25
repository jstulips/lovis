%vidfile = '006_2010-07-24_17-00-00';               % airport, sparse
%vidfile = '011_2014-04-12_11-00-01';               % open space in front of church            
%vidfile = '026_2012-03-20_11-00-01';               % plaza pedestrians
%vidfile = '015_2010-07-30_09-00-01';               % busy traffic scene
options.verbose = 0;
options.display = 0;
%[blobCell,trackCell,timesortedBlobs] = extractblob(vidfile,options);


camera = {'001','002','003','004','005','006','007','008','009', '010', '011','013','014',...
    '015','016','017','018','019','020','021','022','024', '025','026'}; %24 cameras

for i=1:1 % camera 001
    camera_folder= dir(['D:\LOST\', camera{i}]);  
    cd (['D:\LOST\', camera{i}]);
    mkdir('MAT Files');
    fileID = fopen('clustering_errors.txt','w');
    pwd

        for j=3:(size(camera_folder)-2)
            try
            vidfile=camera_folder(j).name;
            %if exist([pwd,'\', vidfile(1:3),'_blobs\',vidfile(1:23),'_blobs.txt'], 'file')==2 && ...
             %       exist([pwd,'\', vidfile(1:3),'_tracks\',vidfile(1:23),'_tracks.txt'], 'file')==2
            if exist(['D:\LOST\017\017_blobs\',vidfile(1:23),'_blobs.txt'], 'file')==2 && ...
               exist(['D:\LOST\017\017_tracks\',vidfile(1:23),'_tracks.txt'], 'file')==2
                % checks whether blob/track txt file exist
                
                blobtxt_path=['D:\LOST\017\', vidfile(1:3),'_blobs\']; % SY: folder that contains the blob/track.txt
                tracktxt_path=['D:\LOST\017\', vidfile(1:3),'_tracks\'];
                timetxt_path=['D:\LOST\017\', vidfile(1:3),'_timestamps\'];
                saveto_path='D:\LOST\017\MAT Files';
             % testing
             vidfile = '011_2014-04-12_11-00-01';
                [blobCell, trackCell, timesortedBlobs] =extractblob(vidfile(1:23),options);
            else
                fprintf(fileID,'Warning: Blob or Track file does not exist for %s:\n', vidfile )
                
            end
            catch e
                msgString = getReport(e);
                fprintf(fileID,'Error occurred for %s: %s\n', vidfile, msgString)
                continue
            end
        end
   
    fclose(fileID)
end

