% GETFRAME 
% Global script for getting the video frame (for display purposes)
% from a given query date

id = find(dtn==datenum(queryDate));
camera_id = strtok(distMatFile,'_');    
matfile_path = [db_path, camera_id, '\', mat_dir_name];
matfile_folder = dir([matfile_path,'\*_trackedblobs.mat']);
fileformat = [camera_id,'_',datestr(dtn(id),29)];
k = strncmp(fileformat,cellstr(char(matfile_folder.name)), 14);
matfilename = matfile_folder(find(k)).name;
cd(matfile_path);
load(matfilename);

cd([db_path, camera_id]);
vidfilename = matfilename(1:max(findstr(matfilename,'_'))-1);
mov = VideoReader([db_path, camera_id, '\', vidfilename, '.avi']);
vidFrame = read(mov, 1);