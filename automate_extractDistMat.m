% AUTOMATE_EXTRACTDISTMAT
% Script to automate extraction of distance matrix (by Chamfer distance),
% then storing it in a MAT-file

db_path = 'D:\LOST\';
mat_dir_name = 'Mat Files';
camera = {'001','002','003','004','005','006','007','008','009', '010', '011','013','014',...
    '015','016','017','018','019','020','021','022','024', '025','026'}; %24 cameras
options.verbose = 0;
options.display = 0;
et = 0;
disp('** Start extraction of distance matrices');

for i = 16 : 16 % camera 017
    camera_path = [db_path, camera{i}, '\'];
    matfile_path = [camera_path, mat_dir_name];
    cd(matfile_path);
    
    matfile_folder = dir([matfile_path,'\*_trackedblobs.mat']);
    
    for j = 1 : length(matfile_folder)     
        trackedblobsfile = matfile_folder(j).name;
        vidfilename = trackedblobsfile(1:max(findstr(trackedblobsfile,'_'))-1);
        tic;
        
        % get 'trackCell' from appropriate Mat file
        load(trackedblobsfile, 'trackCell');
        
        % if number of tracks < 2, skip and continue
        if length(trackCell) < 2      
            continue;
        end
        
        % if file already generated, skip iteration
        if ~all(exist(trackedblobsfile))
            disp(['Distance matrix extraction of ',trackedblobsfile,' skipped. File not found.']);
            continue;      
        end
        
        % compute distance matrix (Chamfer distance)
        lambda = 25;            % setting used in LOST paper
        distMat = computeChamferDistMat(trackCell, lambda, options);
        
        % append to full distance matrix
        distMatFull{j} = distMat;
        
        % get date number of video
        [token, remain] = strtok(vidfilename,'_');
        [dt, remain2] = strtok(remain,'_');
        dtn(j) = datenum(dt);
        
        et = et + toc;
        disp(['Finished extracting distMat from ',vidfilename,' ... ',num2str(length(distMat)),' tracks']);
        
        w = whos('distMatFull');
        timeleft = (et/j) * (length(matfile_folder)-j) / 3600;  % in hours
        disp([sprintf('\tdistMatFull size: %.3f MB, %.3f hours remaining',w.bytes/1024/1024, timeleft)]);
    end
    
    % save variables to MAT-file
    save([camera{i},'_chamfer',num2str(lambda),'_distMat.mat'], 'dtn', 'distMatFull');   
end
