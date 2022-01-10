% calculates powerspectrum tables for drug groups from Hyun

%add eeglab to path and start its init file%
addpath('eeglab2021.0\'); 
eeglab;

drugGroup="BDZ";
meds="";

%drug groups from Hyun
if drugGroup == "AP"
    meds=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol"];%no files for Amisulpride, Paliperidone
elseif drugGroup == "CLZ"
    meds = ["Clozapin"];
elseif drugGroup == "AD"
    meds = ["Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Trazodone"];
elseif drugGroup == "AED"
    meds=["Valproate", "Lamotrigine", "Carbamazepine", "Topiramate", "Levetiracetam"];
elseif drugGroup == "LI"
    meds = ["Lithium"];
elseif drugGroup == "BDZ"
    meds = ["Lorazepam", "Clonazepam", "Diazepam", "Alprazolam"];
end

%import necessary functions
d = functionsForTUHData;
funcEDF = functionsForEDFFiles;

listEDF=[];
%get list of edf-files
for i=1:length(meds)
    medicine = strcat(meds(i));
    folder = strcat('EDFData\', medicine, '\CleanData');
    listEDF = [listEDF; d.createFileList('edf',folder)];
end
%remove duplicate entries
listEDFWODuplicate = [listEDF(1)];
for i=2:length(listEDF)
    filePath = listEDF(i);
    fileSplit = split(filePath,"\");
    fileName = fileSplit(length(fileSplit));
    duplicate = false;
    for j=1:length(listEDFWODuplicate)
        filePath = listEDF(j);
        fileSplit = split(filePath,"\");
        fileName2 = fileSplit(length(fileSplit));
        if strcmp(fileName, fileName2)%file is duplicate
            duplicate = true;
        end
    end
    if ~duplicate
        listEDFWODuplicate = [listEDFWODuplicate; listEDF(i)];
    end
end

%calculate power from edf files, returns for each edf file several xls
%files that contain power for each frequency band
%uses spectopo from eeglab - for epoched data!
%funcEDF.calculatePowerForBands(listEDF, savefile);
savefile = strcat('Results\Powerspectrum\', drugGroup, '_powerspectrum.xls');
removedFilesName = strcat('Results\Powerspectrum\', drugGroup, '_removedFiles.txt');
funcEDF.calculatePowerForBandsAveragePatient(listEDFWODuplicate, savefile, removedFilesName);


