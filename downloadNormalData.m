%downloads normal data set, takes several hours (ca. 10h)

%add eeglab to path and start its init file%
addpath('eeglab2021.0\'); 
eeglab; 

%import necessary functions
d = functionsForTUHData;
funcEEGData = visualizeEEGData;
download = functionsTuhDownload;

folderName = 'EDFData/Normal';
fileNormal = 'Data_xls\TUH_Corpus\data_abnormalevalnormal.xls'
normalFiles = readcell(fileNormal, 'DateTimeType', 'text'); 

%delete folders
normalFilesWithoutFolders=[];
for i=1:length(normalFiles)
    type = normalFiles(i,3);
     if ~strcmp(type, 'folder')  
       normalFilesWithoutFolders=[normalFilesWithoutFolders;normalFiles(i,:)];
     end  
end

%download edf and txt files
download.downloadFolderContentToHardDrive(normalFilesWithoutFolders, folderName);

%delete .html from edf files
directory = strcat(folderName, '/*.edf.html');
files = dir(directory);
for ii=1:length(files)
    oldname = fullfile(files(ii).folder,files(ii).name);
    [path,newname,ext] = fileparts(oldname);
    movefile(oldname,fullfile(path, newname));
end

%calculate power from edf files, returns for each edf file several xls
%files that contain power for each frequency band
listNormal = d.createFileList('edf',folderName);
funcEEGData.calculatePowerForBands(listNormal,1,0.5);

%combines all power data for all frequencies and all channels
filename = '1_normal_allChannelAllFreq_all.xls';
funcEEGData.calcAllFreqAllChannel(folderName, filename)





