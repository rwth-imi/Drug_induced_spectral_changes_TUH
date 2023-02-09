%calculates powerspectrum table for each drug in list for t-tests

clear;
%add eeglab to path and start its init file
addpath('eeglab2021.0\'); 
eeglab;

%check if this is the right folder, folders must exists!
drive="D:/";% folder with edf files
resultFolder = "D:/Results/t-test/single drugs/Powerspectrum/";% result folder

%import necessary functions
d = functionsForTUHData;
funcEDF = functionsForEDFFiles;
TUHDownload = functionsTuhDownload;
excel = scriptWorkWithExcelData;

%all drugs from Hyun
meds=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol", "Clozapin", ...
    "Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Mirtazapine", ...
    "Trazodone", "Valproate", "Lamotrigine", "Carbamazepine", "Topiramate", "Levetiracetam", "Lithium", ...
    "Lorazepam", "Clonazepam", "Diazepam", "Alprazolam"];

meds=["Risperidone"];
for i=1:length(meds)

    medicine = strcat(meds(i));
    folder = strcat(drive,'EDFData\', medicine, '\CleanData');

    listEDF = d.createFileList('edf',folder);
  
    psfile = strcat(resultFolder, medicine, '_powerspectrum.xls');
    removedFiles = strcat(resultFolder, medicine, '_removedFilesEpochs.txt');
    psFileAverage= strcat(resultFolder, medicine, '_powerspectrumAverage.xls');

    %calculate powerspectrum for each file
    funcEDF.calculatePowerForBandsTTest(listEDF, psfile, removedFiles);
    
    %average over patients
    funcEDF.averagePatientTTest(psfile, psFileAverage);
    
    %calculate power from edf files, returns for each edf file several xls
    %files that contain power for each frequency band
    %uses spectopo from eeglab - for epoched data!
    %funcEDF.calculatePowerForBandsAveragePatient(listEDF, psfile, removedFiles);

end




