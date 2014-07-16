function  [output,status]=urlwrite_auth(url, user, password,location,wanted) 
%URLWRITE_AUTH Like URLWRITE, with basic authentication 
% 
% location is where you want the file saved
% wanted is the name of the file you want
% Returns the output file which is now saved to location. 
% 
% Examples: 
% sampleUrl = 'http://browserspy.dk/password-ok.php'; 
% [output,status] = urlwrite_auth(sampleUrl, 'user', 'password', location, wanted); 


% Matlab's urlread() doesn't do HTTP Request params, so work directly with Java 
jUrl = java.net.URL(url); 
conn = jUrl.openConnection(); 
conn.setRequestProperty('Authorization', ['Basic ' base64encode([user ':' password])]); 
conn.connect()
%note this calls the function below

% Specify the full path to the file so that getAbsolutePath will work when the
% current directory is not the startup directory and urlwrite is given a
% relative path.
file = java.io.File(location);

% the path.
try
    file = file.getCanonicalFile;
catch
    error('MATLAB:urlwrite:InvalidOutputLocation','Could not resolve file    "%s".',char(file.getAbsolutePath));
end

% Open the output file.
pathy=strcat(location,'\',wanted);
try
    fileOutputStream = java.io.FileOutputStream(pathy);
catch
    error('MATLAB:urlwrite:InvalidOutputLocation','Could not open output file "%s".',char(file.getAbsolutePath));
end

% Read the data from the connection.
try
    %byteArrayOutputStream = java.io.ByteArrayOutputStream;    NOT USED
    inputStream = conn.getInputStream;
        import com.mathworks.mlwidgets.io.InterruptibleStreamCopier; 
    % This StreamCopier is unsupported and may change at any time.
    isc = InterruptibleStreamCopier.getInterruptibleStreamCopier; 
    isc.copyStream(inputStream,fileOutputStream);
    %isc.copyStream(inputStream,byteArrayOutputStream);       NOT USED
    
    inputStream.close;
    %byteArrayOutputStream.close;                   NOT USED
    fileOutputStream.close;
   
    output = char(file.getAbsolutePath);            
    %output = typecast('byteArrayOutputStream.toByteArray','uint8'); NOT USED
catch
    fileOutputStream.close;
    output = char(file.getAbsolutePath);
    status = 0;
    delete(wanted);    
    return
    %if catchErrors, return
    %else error('MATLAB:urlwrite:ConnectionFailed','Error downloading URL. Your network     connection may be down or your proxy settings improperly configured.');
    %end
end

status = 1;


function out = base64encode(str) 
% Uses Sun-specific class, but we know that is the JVM Matlab ships with 
encoder = sun.misc.BASE64Encoder(); 
out = char(encoder.encode(java.lang.String(str).getBytes())); 
%this is the bit of code that makes it connect!!!!