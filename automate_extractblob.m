db_path = 'D:\LOST\';
mat_dir_name = 'Mat Files';
camera = {'001','002','003','004','005','006','007','008','009', '010', '011','013','014',...
    '015','016','017','018','019','020','021','022','024', '025','026'}; %24 cameras
options.verbose = 1;
options.display = 0;

for i = 16 : 16 % camera 017
    camera_folder= dir([db_path, camera{i}, '\*.avi']);
    camera_path = [db_path, camera{i}, '\'];
    
    cd(camera_path);
    mkdir(mat_dir_name);
    savepath = [camera_path, mat_dir_name];

        for j = 1 : length(camera_folder) 
            
            vidfile = camera_folder(j).name;
            vidfilename = strtok(vidfile,'.avi');
            
            % if file already generated, skip iteration
            cd(savepath);
            if all(exist([vidfilename,'_trackedblobs.mat']))
                disp(['Extraction of ',vidfilename,' skipped']);
                continue;      
            end
            
            blobtxt_path = [camera_path, camera{i}, '_blobs\', vidfilename, '_blobs.txt'];
            tracktxt_path = [camera_path, camera{i}, '_tracks\', vidfilename, '_tracks.txt'];
            timetxt_path = [camera_path, camera{i}, '_timestamps\', vidfilename, '_timestamps.txt'];
            
            % Error checking
            if exist(blobtxt_path) ~= 2
                error('Blob file not found!');
            elseif exist(tracktxt_path) ~= 2
                error('Track file not found!');
            elseif exist(timetxt_path) ~= 2
                error('Timestamps file not found!');
            end
          
            mov = VideoReader([camera_path,vidfile]);      
            paths = {blobtxt_path, tracktxt_path, timetxt_path};
            [blobCell, trackCell, timesortedBlobs] = extractblob(mov, paths, options);

            % save variables to MAT-file
            cd(savepath);
            save([vidfilename,'_trackedblobs.mat'],'blobCell','trackCell','timesortedBlobs');  
        end
end

