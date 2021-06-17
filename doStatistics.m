%calculate statistics from edf files, returns several xls files and graphic

%add eeglab to path and start its init file%
addpath('eeglab2021.0\'); 
eeglab; 

%import necessary functions
d = functionsForTUHData;
funcEEGData = visualizeEEGData;

medicine = 'Test/CleanData';
folder = strcat('EDFData/', medicine);

listEDF = d.createFileList('edf',folder);


%calculate power from edf files, returns for each edf file several xls
%files that contain power for each frequency band
%uses spectopo from eeglab - for epoched data!
funcEEGData.calculatePowerForBandsEpochedData(listEDF, false);

filename = strcat(medicine, '_AllFreqAllChannel2.xlsx');
%combines all power data for all frequencies and all channels
funcEEGData.calcAllFreqAllChannel(folder, filename)

%read data into Matlab
%normal data is created in downloadNormalData.m
dataNormal = readcell('1_normal_allChannelAllFreq_all.xls');
%created in calcAllFreqAllChannel
data = readcell(filename);
 
% calculate statistics with sampling
funcEEGData.calcPValueAndMoreWithSampling(dataNormal, data, medicine, 20, 95, 95);

%created in calcPValueAndMoreWithSampling
filename = strcat(medicine, '_normal_data_sampling_201110.xls');
data = readcell(filename);

imageTitle = strcat(medicine, ' vs Normal - Relative');
%visualize previously created data
funcEEGData.visualizePValues(data, true, false, imageTitle);
