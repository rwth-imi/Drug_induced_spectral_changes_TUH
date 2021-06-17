%add eeglab to path and start its init file%
addpath('eeglab2021.0\'); 
eeglab;

medicine = 'Test\CleanData';
folder = strcat('EDFData/', medicine);

d = functionsForTUHData;
listEDF = d.createFileList('edf',folder);

calculatePowerForBands(listEDF, false, 'EDFData/Test\CleanData\TestEpoched.xls');

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
    
    channels = eegData.nbchan;
    
    %define rows of data
    rowsTheta = cell(channels, 1); 
    rowsAlpha = cell(channels, 1); 
    rowsDelta = cell(channels, 1);  
    rowsBeta  = cell(channels, 1); 
    rowsGamma = cell(channels, 1); 
    
    
    
    for i = 1:channels      
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
    end
        
end 

%  calculates the power spectral density for a list of edf files - uses
%  functions from eeglab
%  list         List of edf files with folder paths 
%  windowSize   window size for the time data in the edf files, e.g. 1s
%  overlapSize  overlap between the windows, e.g. 0,5sec
%  removeArtifacts  if true, artifacts are being removed in eeg data
function calculatePowerForBands(list, removeArtifacts, saveFile)

        
    for i = 1:length(list)
        %get folder path for the file
        %folder path seperator in here \ not / 
        temp = strsplit(list{i}, '\'); 
        filename = temp(end); 
        temp(end) = '';
        folderpath = strcat(strjoin(temp, '\'), '\'); 

        %read edf file
        EEGData = pop_biosig(list{i},'importevent','off','importannot','off'); 
        EEGDataFull=EEGData;
        
        if removeArtifacts == true
            EEGData = clean_artifacts(EEGData);
        end
        
        %makes no difference!
        %EEGData = eeg_regepochs(EEGData);

        %calculate power spectral density for one edf file  
        [powerAlpha{i}, powerTheta{i}, powerDelta{i}, powerBeta{i}, powerGamma{i}] = calculatePowerSpectrum(EEGData);
                 
    end 
    
    %save data
    
    %setup all channel and frequency names
    visEEG = visualizeEEGData;
    [channels, frequencies] = visEEG.setUpChannelsFrequencies();
    
    data = {}; 
    k = 1;
    for i = 1:length(channels)

        data = getPowerData(data, channels{i}, powerAlpha,'_powerAlpha', k) 
        str = strcat(channels{i},'_', 'powerAlpha', '_____', int2str(k) , '/', int2str(19*5), '_done');
        k = k+1;
        disp(str);
        
        data = getPowerData(data, channels{i}, powerBeta,'_powerBeta', k)
        str = strcat(channels{i},'_', 'powerBeta', '_____', int2str(k) , '/', int2str(19*5), '_done');
        k = k+1;
        disp(str);
        
        data = getPowerData(data, channels{i}, powerGamma,'_powerGamma', k)
        str = strcat(channels{i},'_', 'powerGamma', '_____', int2str(k) , '/', int2str(19*5), '_done');
        k = k+1;
        disp(str);
        
        data = getPowerData(data, channels{i}, powerDelta,'_powerDelta', k)
        str = strcat(channels{i},'_', 'powerDelta', '_____', int2str(k) , '/', int2str(19*5), '_done');
        k = k+1;
        disp(str);
        
        data = getPowerData(data, channels{i}, powerTheta,'_powerTheta', k)
        str = strcat(channels{i},'_', 'powerTheta', '_____', int2str(k) , '/', int2str(19*5), '_done');
        k = k+1;
        disp(str);
    end
    
    writecell(data, saveFile);
end 

function data = getPowerData(data, channel, power, powerName, k)
    text = strcat(channel, powerName);
    data{1,k} = text;

    for j = 1:length(power)
        ps=power{1,j};
        index = strfind(ps(1,:),channel);
        index = find(~cellfun(@isempty,index));
        if isempty(index)
            data{j+1,k} = [0];
        else
            data(j+1,k) = ps(2,index);
        end
    end
end