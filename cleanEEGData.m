
%add eeglab to path and start its init file%
addpath('eeglab2021.0\'); 
eeglab;

medicine = 'Test';
folder = strcat('EDFData/', medicine);

d = functionsForTUHData;
listEDF = d.createFileList('edf',folder);

%createEpochs(listEDF);

%folder = strcat(folder, '\CleanData');
%listEDF = d.createFileList('edf',folder);

cleanData(listEDF);

%remove artifacts from data, save data in in new folder 'CleanData'
%listEDFFiles   list of edf files
function cleanData(listEDFFiles)

    for i = 1:length(listEDFFiles)
        %read edf file
        EEGData = pop_biosig(listEDFFiles{i},'importevent','off','importannot','off'); 
        
        %remove artifacts
        EEGClean = clean_artifacts(EEGData);
        
        %create epochs - default 1s
        %EEGCleanEpoch = eeg_regepochs(EEGClean);
        
        %EEGDataEpoch = eeg_regepochs(EEGData);
        
        %visualize the removed artifacts
        %vis_artifacts(EEGClean,EEGData);
        
        %get folder path for the file
        %folder path seperator in here \ not / 
        temp = strsplit(listEDFFiles{i}, '\'); 
        filename = temp(end); 
        temp(end) = '';
        folderpath = strcat(strjoin(temp, '\'), '\'); 
        
        %create new folder
        mkdir(folderpath, 'CleanData');
        
        %save edf files
        newFilename = strcat(folderpath, 'CleanData\', filename{1});
        pop_writeeeg(EEGClean, newFilename, 'TYPE','EDF');
    end 
end 

%creates epoched edf files
%list   list of edf files
%saves epoched edf files in new folder 'CleanData'
function createEpochs(list)
    
    for i = 1:length(list)
        %read edf file
        EEGData = pop_biosig(list{i},'importevent','off','importannot','off'); 
        %create epochs - default 1s
        EEGData = eeg_regepochs(EEGData);
        
        %get folder path for the file
        %folder path seperator in here \ not / 
        temp = strsplit(list{i}, '\'); 
        filename = temp(end); 
        temp(end) = '';
        folderpath = strcat(strjoin(temp, '\'), '\'); 
        
        %create new folder
        mkdir(folderpath, 'CleanData');
        
        %save epoched edf files
        newFilename = strcat(folderpath, 'CleanData\', filename{1});
        pop_writeeeg(EEGData, newFilename, 'TYPE','EDF');
        
        %is not saved as epoched data!
        EEGDataNew = pop_biosig(newFilename,'importevent','off','importannot','off'); 
        
    end
end