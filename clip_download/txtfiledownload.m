
%camera = {'001','002','003','004','005','006','007','008','009', '010', '011','013','014',...
  %  '015','016','017','018','019','020','021','022','024', '025','026'}; %index starts from 1 001,002, 015, 022, 025, 026 done with txt


camera_str = {'001','017'};


% hour = {'11', '18', '11', '11', '11', '17', '03',...
   % '04','07','11','11','17','10','09','11','11',...
   % '11','11','18','19','19','17','17','11'}; %correlated wth each camera
    
txt_type= {'blobs', 'tracks', 'timestamps'};


for i=1:2

for k=1:3
    cd('D:\LOST\');
   % mkdir([camera_str{i},'_', txt_type{k}]);
downloadURL = ['D:\LOST\',camera_str{i},'\',camera_str{i},'_',txt_type{k}];
    cd(downloadURL);

video_dir= dir(['D:\LOST\', camera_str{i},'\New folder']);

    for j=3:size(video_dir)
       video_name=video_dir(j).name;
      concat_video_name= video_name(1:23);
     % disp(concat_video_name)

                file_name= [ concat_video_name,'_',txt_type{k},'.txt'];
                url=['http://lost.cse.wustl.edu/static/camera/',camera_str{i},'/', concat_video_name,'/',txt_type{k},'.txt']; 
              %  disp(url)

                [output, status] = urlwrite_auth(url,'collaborator','bandwidth',...
                    downloadURL,file_name);
                        
    end
end
end

          


%     file_name= ['001_2013-10-28_11-00-01.avi'];
%     url = 'http://lost.cse.wustl.edu/static/camera/001/001_2013-10-28_11-00-01/001_2013-10-28_11-00-01.avi';
%              http://lost.cse.wustl.edu/static/camera/015/015_2010-08-08_09-00-03/blobs.txt