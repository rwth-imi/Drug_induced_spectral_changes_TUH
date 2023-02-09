%downloads normal data set, takes several hours (ca. 10h)

%add eeglab to path and start its init file%
addpath('eeglab2021.0\'); 
eeglab; 

%import necessary functions
download = functionsTuhDownload;

folderName = 'EDFData/NormalFull2';
fileNormal = 'cachedData\Normal\normalData2.xlsx'
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






