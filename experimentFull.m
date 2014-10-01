% EXPERIMENTFULL
% Driver script for automating entire anomalous track mining experiment on
% the LOST dataset. Only can be carried out for one selected camera at a time.
%
db_path = 'D:\LOST\';
mat_dir_name = 'Mat Files\';
cameraID = '017';
options.verbose = 1;
options.display = 0;
distMatFile = [cameraID,'_chamfer25_distMat'];
load(distMatFile); 

% camera 001/017 settings
firstDateNum = 735732;     % 001-start: 734785, 017-original: 735469    
lastDateNum = 735775;      % 001-end: 735453, 017-end: 735775 
startDate = [28 7 30];
stride = {'week', '', ''};
trackClass = [];
counter = 0;
errors = 0;

for d = firstDateNum : lastDateNum
    
    endDate = datestr(d, 29);    
    queryDate = datestr(d+1, 29);
    
    queryIdx = find(dtn == datenum(queryDate));
    if isempty(queryIdx)
        disp(['Day skipped. No tracks available for date: ',queryDate]);
        continue;
    end
    
    % ----------------------------------------------------------------
    % Anomaly mining
    anomhits = [];
    for i = 1 : 3   % iterations corresponding to time-scales
        [exemplarSet{i}, errors] = getExemplarsInRange(distMatFile, startDate(i), endDate, stride{i}); 
        if errors
            break;
        end
        anomhits(:,i) = testAnomaly(distMatFile, queryDate, exemplarSet{i});
        close all;
    end
    if errors   % provide escape route for errors
        continue;
    end
    
    omega = 0.5;        % anomaly threshold
    anomprob = mean(anomhits,2);
    anomTimescale = (anomhits > omega);
    anomFound = (anomprob > omega);
    disp(['Anomalies found: ',num2str(find(anomFound'))]);
    
    trackClass = [trackClass; size(anomhits,1) sum(anomTimescale) sum(anomFound) ];
    
    % store values
    counter = counter + 1;
    anomalyData{counter}.queryDate = queryDate;
    anomalyData{counter}.anomFound = anomFound;
    anomalyData{counter}.anomTimescale = anomTimescale;
    anomalyData{counter}.anomProbs = anomhits;
    anomalyData{counter}.trackClass = trackClass;
    anomalyData{counter}.omega = omega;
    
    % ----------------------------------------------------------------
    % Synthetic anomaly generation
    getFrame;
    generateAnomaly;
    % ---
    
    % Classifying injected anomaly
    for i = 1 : 3
        anomhits2(:,i) = testSynthAnomaly(distMatFile, queryDate, exemplarSet{i}, nfv);
    end
    omega = 0.5;        % anomaly threshold
    anomalyprob2 = mean(anomhits2,2);
    overallAnomalyHits2 = (anomalyprob2 > omega);
    disp(['Final anomalies: ',num2str(find(overallAnomalyHits2'))]);
    
    classification(counter) = overallAnomalyHits2(size(anomhits2,1));
   
    % display current accuracy on command window
    %sum(classification)/length(classification)*100
    
    if classification(counter)
        disp('--> Injected anomaly found!');
    end
    % ----------------------------------------------------------------
    
    % clean garbage and stuff;
    clear anomhits anomhits2 anomalyprob2 anomprob anomTimescale anomFound;
    close all;
end  
    

