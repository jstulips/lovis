
camera = {'001','002','003','004','005','006','007','008','009', '010', '011','013','014',...
    '015','016','017','018','019','020','021','022','024', '025','026'}; %index starts from 1

hour = {'11', '18', '11', '11', '11', '17', '03',...
    '04','07','11','11','17','10','09','11','11',...
    '11','11','18','19','19','17','17','11'}; %correlated wth each camera


for i=15:1:15 %% for camera 015
    
    downloadURL = ['D:\LOST\',camera{i},'\',camera{i},'_tracks'];
    cd(downloadURL);
    
    for year=2010:1:2012 
        str_year=int2str(year);
        
        for month=1:1:12; 
            if month<=9
                str_month=['0',int2str(month)];
            else
                str_month=int2str(month);
            end
            
            for day=1:1:31; 
                if day<=9
                    str_day=['0',int2str(day)];
                else
                    str_day=int2str(day);
                end
                
                for min=0:1:2
                    if min<=9
                        str_min=['0',int2str(min)];
                    else
                        str_min=int2str(min);
                    end
                    
                    for sec=0:1:44
                        if sec<=9
                            str_sec=['0',int2str(sec)];
                        else
                            str_sec=int2str(sec);
                        end
                        
                        file_name= [ camera{i},'_', str_year,'-',str_month,'-',str_day,'_', hour{i}, '-', str_min, '-', str_sec,'_tracks.txt'];
                        url=['http://lost.cse.wustl.edu/static/camera/',camera{i},'/',camera{i},'_', str_year,'-',str_month,'-',...
                            str_day, '_', hour{i}, '-', str_min, '-', str_sec,'/tracks.txt']; 
                        
                   
                        [output, status] = urlwrite_auth(url,'collaborator','bandwidth',...
                            downloadURL,file_name);
                        
                        if status==1
                            break;
                        end
                        
                    end
                    if status==1
                        break;
                    end
                end
            end
        end
    end
end


%     file_name= ['001_2013-10-28_11-00-01.avi'];
%     url = 'http://lost.cse.wustl.edu/static/camera/001/001_2013-10-28_11-00-01/001_2013-10-28_11-00-01.avi';
%              http://lost.cse.wustl.edu/static/camera/015/015_2010-08-08_09-00-03/blobs.txt