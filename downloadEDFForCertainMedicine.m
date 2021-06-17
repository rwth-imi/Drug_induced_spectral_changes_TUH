%downloads edf and txt files with certain medicine

%import necessary functions
funcs = scriptWorkWithExcelData;
download = functionsTuhDownload;

%gets cached TUH data
dataDirectory = 'cachedTUHEEGCorpusData';
fileStructure = dir(dataDirectory);
filenames = {fileStructure(:).name};

medicine = 'Clozapin';

foldersWithMedicine = {}; 
%searches for all folders in xls file that contain certain medicine
for i = 3:length(filenames)%entry one and two are just dots

    file = append(dataDirectory, '\', filenames{i}); 
    xlsData = readcell(file, 'DateTimeType', 'text'); 

    xlsTxtData = xlsData(strcmp(xlsData(:,3), 'txt'), :);

    pattern = '';
    if strcmp(medicine, 'Haloperidol')
        pattern=["haloperidol", "Haloperidolum", "PhEur", "Haloperidoli", "Haloperidoldecanoat"];
    elseif strcmp(medicine, 'Clozapin')
        pattern = ["clozapin","clozaril","clopine","fazaclo","denzapine"]; 
    elseif strcmp(medicine, 'Quetiapine')
        pattern = ["quetiapine","seroquel", "quetiapina", "quetiapinum", "quetiapin"];
    elseif strcmp(medicine, 'Dilantin')
        pattern= ["dilantin", "epilan", "phenytoin"];
    elseif strcmp(medicine, 'Olanzapine')
        pattern = ["olanzapine","zypadhera","zyprexa"];
    elseif strcmp(medicine, 'Risperidone')
        pattern =["risperidone", "risperdal", "belivon", "rispen", "risperidal", "rispolept", "risperin", "rispolin", "sequinan", "apexidone", "risperidonum", "risperidona", "psychodal", "spiron"];
    elseif strcmp(medicine, 'Aripiprazole')
        pattern = ["aripiprazole", "Aripiprazolum", "monohydricum", "Monohydrat","Aripiprazol"];
    else
        return;
    end

    fileWithMedicin = funcs.findFilesWithMedicine(xlsTxtData, pattern); 

    foldersWithMedicine = [foldersWithMedicine; findFolder(fileWithMedicin)]; 

end

%list all edf and txt files in folder
folderCellArray = {};
dd = cell(1, 4);
filesWithMedicine={};
for i = 1:length(foldersWithMedicine)
    url   = foldersWithMedicine{i, 1};
    dd{i} = download.listAllDirectories(url, folderCellArray, 'test.xls');
    filesWithMedicine= vertcat(filesWithMedicine,dd{i});
    
end

%download edf and txt files
folderName= strcat('EDFData/', medicine);
download.downloadFolderContentToHardDrive(filesWithMedicine, folderName);

%remove .html from edf files
directory = strcat('EDFData/', medicine, '/*.edf.html');
files = dir(directory);
for ii=1:length(files)
    oldname = fullfile(files(ii).folder,files(ii).name);
    [path,newname,ext] = fileparts(oldname);
    movefile(oldname,fullfile(path, newname));
end
    

%This function gives you the corresponding folder of each file. 
%It the deletes the last part after the last ‘/’

function cellArray = findFolder(cellArray)
    for i= 1:size(cellArray,1)
        if ismissing(cellArray{i})
        else
            cellArray{i,1} = getFolderURLFromURLstring(cellArray{i});
            cellArray{i,3} = 'folder';
        end
    end 
end


function fileName = getFolderURLFromURLstring(url)

    fileName = url(1: find(url =='/', 1,'last'))
end

