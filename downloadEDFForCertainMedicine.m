%downloads edf and txt files for certain medicine
clear;

%import necessary functions
funcs = scriptWorkWithExcelData;
download = functionsTuhDownload;

%gets cached TUH data
dataDirectory = 'cachedData/cachedTUHEEGCorpusData';
fileStructure = dir(dataDirectory);
filenames = {fileStructure(:).name};


%all drugs for mixed model
meds=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol", ...
    "Cariprazine", "Asenapine", "Benperidol", "Bromperidol", "Chlorprotixene", "Flupentixole", ...
    "Fluphenazine", "Fluspirilene", "Levomepromazine", "Melperone", "Perazin", "Perphenazine",...
    "Pimozide", "Pipamperon", "Prothipendyl", "Sertindole", "Sulpiride", "Thioridazine",...
    "Zuclopenthixol", "Clozapin", ...
    "Citalopram", "Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Mirtazapine", ...
    "Trazodone", "Agomelatin", "Amitriptyline", "Clomipramin", "Doxepin", "Duloxetin", "Imipramin", ...
    "Maprotilin", "Mianserin", "Milnacipran", "Moclobemid", "Nortriptylin", "Reboxetin",...
    "Tranylcypromin", "Trimipramin",...
    "Lithium"];

%all drugs from Hyun
% meds=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol", "Clozapin", ...
%     "Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Mirtazapine", ...
%     "Trazodone", "Valproate", "Lamotrigine", "Carbamazepine", "Topiramate", "Levetiracetam", "Lithium", ...
%     "Lorazepam", "Clonazepam", "Diazepam", "Alprazolam"];

 meds=["Levetiracetam"];
drive="D:/";

for i=1:length(meds)
    
    medicine = meds(i);

    foldersWithMedicine = {}; 
    %searches for all folders in xls file that contain certain medicine
    for i = 3:length(filenames)%entry one and two are just dots

        file = append(dataDirectory, '\', filenames{i}); 
        xlsData = readcell(file, 'DateTimeType', 'text'); 

        xlsTxtData = xlsData(strcmp(xlsData(:,3), 'txt'), :);

        pattern = funcs.getTradeNames(medicine);

        fileWithMedicin = funcs.findFilesWithMedicine(xlsTxtData, pattern); 

        foldersWithMedicine = [foldersWithMedicine; findFolder(fileWithMedicin)]; 

    end

    %list all edf and txt files in folder
    folderCellArray = {};
    %files = cell(1, 4);
    files = {};
    filesWithMedicine={};
    l=size(foldersWithMedicine,1);
    for i = 1:l
        url   = foldersWithMedicine{i, 1};
        files = download.listAllDirectories(url, folderCellArray, 'test.xls');
        for j = 1:length(files)
            filetype = files{j,3};
            if strcmp(filetype, 'edf')||strcmp(filetype, 'txt') %download only edf and text files
                filesWithMedicine= vertcat(filesWithMedicine,files(j,:));
            end
        end
        files = {};

    end

    %download edf and txt files
    folderName= strcat(drive,'EDFData/', medicine);
    patientData = download.downloadFolderContentToHardDrive(filesWithMedicine, folderName);

    %save list of all patients
    filename = strcat(drive,'EDFData/', medicine, '/listOfPatients', medicine, '.xls');
    %writecell(patientData, filename);
    writecell(filesWithMedicine, filename);

    %remove .html from edf files
     directory = strcat(drive,'EDFData/', medicine, '/*.edf.html');
     files = dir(directory);
     for ii=1:length(files)
         oldname = fullfile(files(ii).folder,files(ii).name);
         [path,newname,ext] = fileparts(oldname);
         movefile(oldname,fullfile(path, newname));
     end
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

    fileName = url(1: find(url =='/', 1,'last'));
end

