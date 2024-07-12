%to be able to call single functions from this script 
function funcEEGData = functionsForEDFFiles
  funcEEGData.calculatePowerForBands=@calculatePowerForBands;%for mixed model
  funcEEGData.calculatePowerForBandsAveragePatient=@calculatePowerForBandsAveragePatient;%for t-test
  funcEEGData.calculatePowerForBandsTTest=@calculatePowerForBandsTTest;
  funcEEGData.averagePatientTTest=@averagePatientTTest;
  funcEEGData.cleanData=@cleanData;
end

% calcualtes power spectral density for data from EDF file for all its
% frequencies and channels - uses spectopo from eeglab
% eegData            expects reading EEG data from eeglab
% returns rows for alpha, beta, gamma, delta, theta ways for all channels
%   in the EEG data
function [powerAlpha, powerTheta, powerDelta, powerBeta, powerGamma] = calculatePowerSpectrum(eegData)
    %define various brain wave frequencies as told by Ekaterina
    theta=[3.5 7.5];
    alpha=[7.5 12.5];
    delta = [1 3.5]; 
    beta = [12.5 30];
    gamma = [30 60]; %gamma technically open ended
    
    %for Diazepam
    %beta = [12.5 20];
    %gamma = [20 60];
    
    channels = eegData.nbchan;
    
    %define rows of data
    rowsTheta = cell(channels, 1); 
    rowsAlpha = cell(channels, 1); 
    rowsDelta = cell(channels, 1);  
    rowsBeta  = cell(channels, 1); 
    rowsGamma = cell(channels, 1); 
    
    
    
    for i = 1:channels   
        test = eegData.data(i,:);
        [ps,f] = spectopo(eegData.data(i,:), 0, eegData.srate, 'plot',['off']);

        rowsTheta{i} = f > theta(1) & f < theta(2);
        rowsAlpha{i} = f > alpha(1) & f < alpha(2);
        rowsDelta{i} = f > delta(1) & f < delta(2); 
        rowsBeta{i} = f > beta(1) & f < beta(2); 
        rowsGamma{i} = f > gamma(1) & f < gamma(2);      

        %channel names
        channelName = eegData.chanlocs(i).labels;
        powerAlpha{1,i} = channelName;
        powerBeta{1,i}  = channelName;
        powerGamma{1,i} = channelName;
        powerDelta{1,i} = channelName;
        powerTheta{1,i} = channelName;
    
        % Compute absolute power.
         powerAlpha{2,i} = mean(10.^(ps(rowsAlpha{i})/10));
         powerBeta{2,i}  = mean(10.^(ps(rowsBeta{i})/10));
         powerGamma{2,i} = mean(10.^(ps(rowsGamma{i})/10));
         powerDelta{2,i} = mean(10.^(ps(rowsDelta{i})/10));
         powerTheta{2,i} = mean(10.^(ps(rowsTheta{i})/10));
         
         %powerAlpha{2,i} = 10.^mean((ps(rowsAlpha{i})/10));
         %powerBeta{2,i}  = 10.^mean((ps(rowsBeta{i})/10));
         %powerGamma{2,i} = 10.^mean((ps(rowsGamma{i})/10));
         %powerDelta{2,i} = 10.^mean((ps(rowsDelta{i})/10));
         %powerTheta{2,i} = 10.^mean((ps(rowsTheta{i})/10));
    end
        
end 

%  calculates the power spectral density for a list of edf files for mixed model- uses
%  functions from eeglab
%  list              List of edf files with folder paths (sorted by name)
%  saveFile          Name of file that saves power data
%  removedFilesName  name of file that saves which files are excluded from
%       analysis
%  medicine          name of medicine
function calculatePowerForBands(list, saveFile, removedFilesName) 
    removedFiles=[]; 
    j=2;
    
    %header of data table
    data = {'PatientNr', 'SessionNr', 'FileNr', ...
        'Frequency Band', 'Electrode','Electrode Location', 'Side',  'Power'};       
    
    %setup all channel and frequency names
    visEEG = visualizeEEGData;
    [channels, frequencies] = visEEG.setUpChannelsFrequencies();
    
    for i = 1:length(list)
        %status update
        disp(['Calculate power for bands: file number ' num2str(i)  ' of ' num2str(length(list))]);
        
        %get patient number, session number and file number
        filename=strsplit(list{i},'\');
        filename=filename(end);
        filename = string(filename);
        id = strsplit(filename, '_');
        patientNr = id(1);
        sessionNr = id(2);
        fileNr = id(3);
        id=strsplit(fileNr, '.');
        fileNr=id(1);
        
        try
        %read edf file
        EEGData = pop_biosig(list{i},'importevent','off','importannot','off'); 
        
        %remove epochs with too low or high amplitudes
        %remove all channels for corupted epochs
        EEGData = eeg_regepochs(EEGData, 5);
        removeEpoch = false;
        newData=[];
        for epoch = 1: size(EEGData.data,3)
            for channel = 1:size(EEGData.data,1)
                amplitudes = EEGData.data(channel, 1:size(EEGData.data,2), epoch);
                meanAmp = mean(abs(amplitudes));
                if meanAmp>100
                    %remove epoch
                    removeEpoch = true;
                    break;
                end
            end
            if ~removeEpoch
                newData = cat(3, newData, EEGData.data(:, :, epoch));
            end
        end
        EEGData.data = newData;
        if length(newData)~=0
            %calculate power spectral density for one edf file  
            [powerAlpha, powerTheta, powerDelta, powerBeta, powerGamma] = calculatePowerSpectrum(EEGData);
            
            %update data table
            for k = 1:length(channels)
                data = getData(data, j, patientNr, sessionNr, fileNr, 'alpha', channels{k}, powerAlpha);
                j=j+1;
                data = getData(data, j, patientNr, sessionNr, fileNr, 'theta', channels{k}, powerTheta);
                j=j+1;
                data = getData(data, j, patientNr, sessionNr, fileNr, 'delta', channels{k}, powerDelta);
                j=j+1;
                data = getData(data, j, patientNr, sessionNr, fileNr, 'beta', channels{k}, powerBeta);
                j=j+1;
                data = getData(data, j, patientNr, sessionNr, fileNr, 'gamma', channels{k}, powerGamma);
                j=j+1;
            end
        else
            removedFiles=[removedFiles, filename];
        end
        catch 
           disp(['Error in calculatePowerForBandsAveragePatient for file ' filename '!']);
        end
    end     
    %save data    
    writecell(data, saveFile);
    
    %save what files were removed
    fid=fopen(removedFilesName,'w');
    for i=1:length(removedFiles)
        fprintf(fid, '%s\n', removedFiles{i});
    end
    fclose(fid);
end 

%puts given data in right place in data table
function data = getData(data, j, patientNr, sessionNr, fileNr, frequencyBand, electrode, powerData)
    data{j,1}=patientNr;
    data{j,2}=sessionNr;
    data{j,3}=fileNr;
    data{j,4}=frequencyBand;%frequency band
    data{j,5}= electrode;%electrode
    data{j,6}=ElectrodeLocation(electrode);%electrode location
    data{j,7}=SideElectrodes(electrode);%side
    data{j,8}=getPowerData2(electrode, powerData);%power
end

%returns electrode location for given electrode
function loc = SideElectrodes(channel)
    rightElectrodes=["FP2", "F4", "F8", "T4", "T6", "C4", "P4", "O2"];
    leftElectrodes=["FP1", "F3", "F7", "T3", "T5", "C3", "P3", "O1"];
    centerElectrodes=["FZ","PZ","CZ"];
    
    if find(strcmp(leftElectrodes,channel))
        loc = 'left';
    elseif find(strcmp(rightElectrodes,channel))
        loc = 'right';
    elseif find(strcmp(centerElectrodes,channel))
        loc = 'midline';
    else
        loc='';
    end
end

%returns on which side is the electrode for given electrode
function loc = ElectrodeLocation(channel)
    frontalElectrodes=["FP1", "FP2", "F3","F4","F7", "F8", "FZ"];
    centralElectrodes=["C3", "CZ", "C4"];
    temporalElectrodes=["T3", "T4", "T5", "T6"];
    parietalElectrodes=["P3","PZ", "P4"];
    occipitalElectrodes=["O1","O2"];
    if find(strcmp(frontalElectrodes,channel))
        loc = 'frontal';
    elseif find(strcmp(centralElectrodes,channel))
        loc = 'central';
    elseif find(strcmp(temporalElectrodes,channel))
        loc = 'temporal';
    elseif find(strcmp(parietalElectrodes,channel))
        loc = 'parietal';
    elseif find(strcmp(occipitalElectrodes,channel))
        loc = 'occipital';
    end
end

%  calculates the power spectral density for a list of edf files and saves them in a file for t-test - uses
%  functions from eeglab
%  list         List of edf files with folder paths (sorted by name)
%  saveFile     filename of saved file
%  removedFilesName  name of file that saves which files are excluded from
%       analysis
function calculatePowerForBandsTTest(list, saveFile, removedFilesName)

    data={};
    removedFiles=[];
    listResult=[];
    
    powerAlpha={};
    powerTheta={};
    powerDelta={};
    powerBeta={};
    powerGamma={};
    
    %setup all channel and frequency names
    visEEG = visualizeEEGData;
    [channels, frequencies] = visEEG.setUpChannelsFrequencies();
    
    j=1;
    i=1;
    for nrEDF = 1:length(list)
        %status update
        disp(['Calculate power for bands: file number ' num2str(nrEDF)  ' of ' num2str(length(list))]);
               
        %read edf file
        try
        EEGData = pop_biosig(list{nrEDF},'importevent','off','importannot','off');

        %check for reference method here: LE -> average, AR -> nothing,
%everything else -> report
        %find reference method
        labels=EEGData.chanlocs.labels;
        if contains(labels,"LE")
            EEGData=pop_reref(EEGData, []);
        elseif not(contains(labels,"REF"))
            disp(['Unknown reference method for file ' list{nrEDF} ]);
            removedFiles=[removedFiles; string(list{nrEDF})];
            continue;
        end
        
        
        %remove epochs with too low or high amplitudes
        %remove all channels for corupted epochs
        EEGData = eeg_regepochs(EEGData, 5);
        removeEpoch = false;
        newData=[];
        for epoch = 1: size(EEGData.data,3)
            for channel = 1:size(EEGData.data,1)
                amplitudes = EEGData.data(channel, 1:size(EEGData.data,2), epoch);
                meanAmp = mean(abs(amplitudes));
                if meanAmp>100
                    %remove epoch
                    removeEpoch = true;
                    break;
                end
            end
            if ~removeEpoch
                newData = cat(3, newData, EEGData.data(:, :, epoch));
            end
        end
        EEGData.data = newData;
        if length(newData)~=0
            %calculate power spectral density for one edf file  
            [powerAlpha{i}, powerTheta{i}, powerDelta{i}, powerBeta{i}, powerGamma{i}] = calculatePowerSpectrum(EEGData);
        
            listResult{i}=list{nrEDF};
            i=i+1;
        else
            removedFiles=[removedFiles; string(list{nrEDF})];
        end
        catch 
            disp(['Error in calculatePowerForBandsTTest for file ' list{nrEDF} '!']);
            removedFiles=[removedFiles; string(list{nrEDF})];
        end
        
    end   
    %update data table
    for k = 1:length(channels)
        data = getPowerData(data, channels{k}, powerAlpha, '_powerAlpha', j);
        j=j+1;
        data = getPowerData(data, channels{k}, powerBeta, '_powerBeta', j );
        j=j+1;
        data = getPowerData(data, channels{k}, powerGamma, '_powerGamma', j );
        j=j+1;
        data = getPowerData(data, channels{k}, powerDelta, '_powerDelta', j );
        j=j+1;
        data = getPowerData(data, channels{k}, powerTheta, '_powerTheta', j );
        j=j+1;
    end
    data{1,j}="File";
    for l = 1:length(listResult)
        %get patient number, session number and file number
        filename=strsplit(listResult{l},'\');
        filename=filename(end);
        filename = string(filename);
        %add patient nr
        data{l+1,j}=filename;
    end
    %save data
    writecell(data, saveFile);
    %save what files were removed
    fid=fopen(removedFilesName,'w');
    for i=1:length(removedFiles)
        fprintf(fid, '%s\n', removedFiles(i));
    end
    fclose(fid);
end

%  takes average of each patient for previously calculated powerspectrum in
%  function calculatePowerForBandsTTest
%  powerFile     filename of file with powerspectrum created in calculatePowerForBandsTTest
function averagePatientTTest(powerFile, saveFile)

    lastPatient='';
    j=1;
    nrPatient=1;
    
    %read file
    power=readcell(powerFile);
    l=size(power,2);
    s=size(power,1);
    
    data(1,:)=power(1,:);
    data{1,l}="Patient Nr";
    
    %powerPatient(1,:)=power(1,1:l-1);%column names
    
    for nrEDF = 2:s
        %status update
        %disp(['average: file number ' num2str(nrEDF-1)  ' of ' num2str(s-1)]);
        
        %average over patients
        %filename=strsplit(power{nrEDF,l},'\');
        %filename=filename(end);
        filename = string(power{nrEDF,l});
        id = strsplit(filename, '_');
        patientNr = id(1);
        
        if ~strcmp(lastPatient,patientNr) && ~strcmp(lastPatient,'')
            %average over patient
            %emptyIndex = cellfun(@ismissing, powerPatient, 'UniformOutput', false);     % Find indices of missing cells
            %powerPatient(emptyIndex) = {nan};                    % Fill missing cells with empty cell
            powerPatient( cellfun( @(c) isa(c,'missing'), powerPatient ) ) = {nan};
            powerPatient = cell2mat(powerPatient);
            if size(powerPatient,1)>1
                %remove outliers
                powerPatient = rmoutliers(powerPatient, 'mean');
                %take mean
                powerPatient=mean(powerPatient,'omitnan');
            end
            powerPatient = [powerPatient, str2double(lastPatient)];
            powerPatient=num2cell(powerPatient);
            data = [data; powerPatient];
            
            powerPatient={};
            nrPatient=nrPatient+1;
            j=1;
        end
        
        lastPatient = patientNr;
        
        %get power for bands
        powerPatient(j,:)=power(nrEDF,1:l-1);
        j=j+1;

    end   
    %average over patient
    %emptyIndex = cellfun(@ismissing, powerPatient);     % Find indices of missing cells
    %powerPatient(emptyIndex) = {nan};                    % Fill missing cells with empty cell
    powerPatient( cellfun( @(c) isa(c,'missing'), powerPatient ) ) = {nan};
    powerPatient = cell2mat(powerPatient);
    if size(powerPatient,1)>1
        %remove outliers
        powerPatient = rmoutliers(powerPatient, 'mean');
        %take mean
        powerPatient=mean(powerPatient,'omitnan');
    end
    powerPatient = [powerPatient, str2double(lastPatient)];
    powerPatient=num2cell(powerPatient);
    data = [data; powerPatient];%save data

    writecell(data, saveFile);
end 

%  calculates the power spectral density for a list of edf files and saves them in a file for t-test - uses
%  functions from eeglab, takes average of each patient
%  list         List of edf files with folder paths (sorted by name)
%  saveFile     filename of saved file
%  removedFilesName  name of file that saves which files are excluded from
%       analysis
function calculatePowerForBandsAveragePatient(list, saveFile, removedFilesName)

    lastPatient='';
    j=1;
    data={};
    nrPatient=1;
    removedFiles=[];
    
    powerAlpha={};
    powerTheta={};
    powerDelta={};
    powerBeta={};
    powerGamma={};
    
    for nrEDF = 1:length(list)
        %status update
        disp(['Calculate power for bands: file number ' num2str(nrEDF)  ' of ' num2str(length(list))]);
        
        %average over patients
        filename=strsplit(list{nrEDF},'\');
        filename=filename(end);
        filename = string(filename);
        id = strsplit(filename, '_');
        patientNr = id(1);
        
        if ~strcmp(lastPatient,patientNr) && ~strcmp(lastPatient,'')
            data = averagePatient(data, nrPatient, powerAlpha, powerBeta, powerGamma, powerDelta, powerTheta, str2double(lastPatient));
            nrPatient=nrPatient+1;
            j=1;
            powerAlpha={};
            powerTheta={};
            powerDelta={};
            powerBeta={};
            powerGamma={};
        end
        
        lastPatient = patientNr;
        
        %read edf file
        try
        EEGData = pop_biosig(list{nrEDF},'importevent','off','importannot','off');
        
        %remove epochs with too low or high amplitudes
        %remove all channels for corupted epochs
        EEGData = eeg_regepochs(EEGData, 5);
        removeEpoch = false;
        newData=[];
        for epoch = 1: size(EEGData.data,3)
            for channel = 1:size(EEGData.data,1)
                amplitudes = EEGData.data(channel, 1:size(EEGData.data,2), epoch);
                meanAmp = mean(abs(amplitudes));
                if meanAmp>100
                    %remove epoch
                    removeEpoch = true;
                    break;
                end
            end
            if ~removeEpoch
                newData = cat(3, newData, EEGData.data(:, :, epoch));
            end
        end
        EEGData.data = newData;
        if length(newData)~=0
            %calculate power spectral density for one edf file  
            [powerAlpha{j}, powerTheta{j}, powerDelta{j}, powerBeta{j}, powerGamma{j}] = calculatePowerSpectrum(EEGData);
            j=j+1;
        else
            removedFiles=[removedFiles, filename];
        end
        catch 
            disp(['Error in calculatePowerForBandsAveragePatient for file ' filename '!']);
        end
        
    end   
    data = averagePatient(data, nrPatient, powerAlpha, powerBeta, powerGamma, powerDelta, powerTheta, str2double(patientNr));
    %save data
    writecell(data, saveFile);
    %save what files were removed
    fid=fopen(removedFilesName,'w');
    for i=1:length(removedFiles)
        fprintf(fid, '%s\n', removedFiles{i});
    end
    fclose(fid);
end 

%used in averagePatient
%inserts the power spectrum data into a given data set, returns this data
%set
%data: data set where power data is inserted
%channel: 

function data = getPowerData(data, channel, power, powerName, k)
    text = strcat(channel, powerName);
    data{1,k} = text;

    for j = 1:length(power)
        ps=power{1,j};
        if ~(isempty(ps))
            index = strfind(ps(1,:),channel);
            index = find(~cellfun(@isempty,index));
            
        else
            index=[];
        end
        if isempty(index)
            data{j+1,k} = [NaN];
        elseif isscalar(index)
            data(j+1,k) = ps(2,index);
        else%zwei Einträge gefunden...
             disp('two entries in getPowerData');
             index = index(1);
             data(j+1,k) = ps(2,index);
        end
    end
end

%used in calculatePowerForBands 
function data = getPowerData2(channel, power)
    data = [NaN];
    for j = 1:length(power)
        %ps=power{1,j};
        index = strfind(power(1,:),channel);
        index = find(~cellfun(@isempty,index));
        if isempty(index)
            data = [NaN];
        elseif isscalar(index)
            data = power{2,index};
            break;
        else%zwei Einträge gefunden...
             disp('two entries in getPowerData');
             index = index(1);
             data = power{2,index};
             break;
        end
    end
end

%removes outliers and takes the mean over all data from one patient
function data = averagePatient(data, nrPatient, powerAlpha, powerBeta, powerGamma, powerDelta, powerTheta, patientNr)
    %setup all channel and frequency names
    visEEG = visualizeEEGData;
    [channels, frequencies] = visEEG.setUpChannelsFrequencies();
    dataOnePatient = {}; 
    k = 1;
    for nrChannel = 1:length(channels)

        dataOnePatient = getPowerData(dataOnePatient, channels{nrChannel}, powerAlpha,'_powerAlpha', k); 
        k = k+1;

        dataOnePatient = getPowerData(dataOnePatient, channels{nrChannel}, powerBeta,'_powerBeta', k);
        k = k+1;

        dataOnePatient = getPowerData(dataOnePatient, channels{nrChannel}, powerGamma,'_powerGamma', k);
        k = k+1;

        dataOnePatient = getPowerData(dataOnePatient, channels{nrChannel}, powerDelta,'_powerDelta', k);
        k = k+1;

        dataOnePatient = getPowerData(dataOnePatient, channels{nrChannel}, powerTheta,'_powerTheta', k);
        k = k+1;
    end
    header=dataOnePatient(1,:);
    if nrPatient==1
       data = [header, 'patient number']; 
    end
    test = size(dataOnePatient,1);
    if size(dataOnePatient,1)>1
        dataOnePatient=dataOnePatient(2:size(dataOnePatient,1),:);
        dataOnePatient = cell2mat(dataOnePatient);
        if size(dataOnePatient,1)>1
            %remove outliers
            dataOnePatient = rmoutliers(dataOnePatient, 'mean');
            %take mean
            dataOnePatient=mean(dataOnePatient,'omitnan');
        end
        dataOnePatient = [dataOnePatient, patientNr];
        dataOnePatient=num2cell(dataOnePatient);
        data = [data; dataOnePatient];
    end
end

%remove artifacts from data, save data in in new folder 'CleanData'
%listEDFFiles   list of edf files
function cleanData(listEDFFiles)
    numberOfSmallFiles=0;
    numberOfDeletedFiles=0;
    numberOfNotSavedFiles=0;
    
    %create new folder
    temp = strsplit(listEDFFiles{1}, '\');
    temp(end) = '';
    folderpath = strcat(strjoin(temp, '\'), '\');
    mkdir(folderpath, 'CleanData');
    
    for i = 1:length(listEDFFiles)
        %get folder path for the file
        %folder path seperator in here \ not / 
        temp = strsplit(listEDFFiles{i}, '\'); 
        filename = temp(end);  

        %read edf file
        errorLoad=false;
        try
        EEGData = pop_biosig(listEDFFiles{i},'importevent','off','importannot','off'); 
        catch
            disp('Error in cleanData - file is excluded');
            disp(strcat('Filename: ',listEDFFiles{i}));
            numberOfDeletedFiles=numberOfDeletedFiles+1;
            errorLoad=true;
        end
        
        if ~errorLoad
            %log-file
            disp('');
            disp('###############################################################################');
            disp(['File number ' num2str(i)  ' of ' num2str(length(listEDFFiles))]);
            disp(strcat('Filename: ',listEDFFiles{i}));
            disp('');

            if EEGData.pnts > 3000%if not enough data points clean-artifacts produces an error

                error = false;

                try
                    %remove artifacts
                    %EEGClean = clean_artifacts(EEGData);
                    EEGClean = clean_artifacts(EEGData, 'BurstCriterion', 3, 'WindowCriterion', 0.05, 'ChannelCriterionMaxBadTime', 0.15, 'BurstRejection', 'on');
                catch
                    disp('Error in cleanData - file is excluded');
                    disp(strcat('Filename: ',listEDFFiles{i}));
                    numberOfDeletedFiles=numberOfDeletedFiles+1;
                    error = true;
                end

                %create epochs - default 1s
                %EEGCleanEpoch = eeg_regepochs(EEGClean);

                %EEGDataEpoch = eeg_regepochs(EEGData);

                %visualize the removed artifacts
                %vis_artifacts(EEGClean,EEGData);

                if ~error
                    try
                        %save edf files
                        newFilename = strcat(folderpath, 'CleanData\', filename{1});
                        pop_writeeeg(EEGClean, newFilename, 'TYPE','EDF');
                    catch
                        disp('Error: cleaned file could not be saved!');
                        disp(strcat('Filename: ',listEDFFiles{i}));
                        numberOfNotSavedFiles=numberOfNotSavedFiles+1;
                    end
                else
                    error = false;
                end

            else
                numberOfSmallFiles=numberOfSmallFiles+1;
            end
        end
    end 
    fileID = fopen(strcat(folderpath, 'CleanData\', 'deletedFiles.txt'),'w');
    fprintf(fileID,'Number of files that were too small to be cleaned: %i\n',numberOfSmallFiles);
    fprintf(fileID,'Number of files that could not be cleaned due to error: %i\n',numberOfDeletedFiles);
    fprintf(fileID,'Number of files that could not be saved due to error: %i\n',numberOfNotSavedFiles);
    fclose(fileID);
end 

%creates epoched edf files
%list   list of edf files
%saves epoched edf files in new folder 'CleanData' -> does not work!!!!
% function createEpochs(list)
%     
%     for i = 1:length(list)
%         %read edf file
%         EEGData = pop_biosig(list{i},'importevent','off','importannot','off'); 
%         %create epochs - default 1s
%         EEGData = eeg_regepochs(EEGData);
%         
%         %get folder path for the file
%         %folder path seperator in here \ not / 
%         temp = strsplit(list{i}, '\'); 
%         filename = temp(end); 
%         temp(end) = '';
%         folderpath = strcat(strjoin(temp, '\'), '\'); 
%         
%         %create new folder
%         mkdir(folderpath, 'CleanData');
%         
%         %save epoched edf files
%         newFilename = strcat(folderpath, 'CleanData\', filename{1});
%         pop_writeeeg(EEGData, newFilename, 'TYPE','EDF');
%         
%         %is not saved as epoched data!
%         EEGDataNew = pop_biosig(newFilename,'importevent','off','importannot','off'); 
%         
%     end
% end