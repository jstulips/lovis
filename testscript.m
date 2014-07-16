%vidfile = '006_2010-07-24_17-00-00';               % airport, sparse
%vidfile = '011_2014-04-12_11-00-01';               % open space in front of church            
%vidfile = '026_2012-03-20_11-00-01';               % plaza pedestrians
%vidfile = '015_2010-07-30_09-00-01';               % busy traffic scene
options.verbose = 1;
options.display = 0;
%[blobCell,trackCell,timesortedBlobs] = extractblob(vidfile,options);


camera = {'001','002','003','004','005','006','007','008','009', '010', '011','013','014',...
    '015','016','017','018','019','020','021','022','024', '025','026'}; %24 cameras

for i=9:9 % camera 009
camera_folder= dir(['F:\Camera\', camera{i}]);
cd (['F:\Camera\', camera{i}]);
%mkdir('MAT Files');
pwd
try
    %for j=3:size(camera_folder('/*.avi'))
    for j=8:(size(camera_folder)-4)
    vidfile=camera_folder(j).name;
    extractblob(vidfile(1:23),options);
    %extractblob('001_2010-07-27_11-00-01',options); This video's data is
    %weird
    end
catch e
     sprintf('Error occurred for %s', vidfile)
    continue
end
end

