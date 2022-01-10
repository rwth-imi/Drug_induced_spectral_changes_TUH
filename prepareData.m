%cleans data and calculates powerspectrum table for each drug in list for
%t-tests

clear;
%add eeglab to path and start its init file%
addpath('eeglab2021.0\'); 
eeglab;

%all drugs from Hyun
meds=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol", "Clozapin", ...
    "Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Mirtazapine", ...
    "Trazodone", "Valproate", "Lamotrigine", "Carbamazepine", "Topiramate", "Levetiracetam", "Lithium", ...
    "Lorazepam", "Clonazepam", "Diazepam", "Alprazolam"];

%meds=["NormalFull2"];
%meds=["Clozapin","Risperidone", "Diazepam"];
%meds=["Clozapin"];
%meds=["Test"];

for i=1:length(meds)

    medicine = strcat(meds(i));
    folder = strcat('EDFData\', medicine);

    %import necessary functions
    d = functionsForTUHData;
    funcEDF = functionsForEDFFiles;

    listEDF = d.createFileList('edf',folder);

    diary 'logTest.txt';
    diary on;

    %funcEDF.cleanData(listEDF);

    diary off;

    folder = strcat(folder, '\CleanData');
    listEDF = d.createFileList('edf',folder);
    savefile = strcat('Results\Powerspectrum\', medicine, '_powerspectrum.xls');
    removedFiles = strcat('Results\Powerspectrum\', medicine, '_removedFilesEpochs.txt');

    %calculate power from edf files, returns for each edf file several xls
    %files that contain power for each frequency band
    %uses spectopo from eeglab - for epoched data!
    funcEDF.calculatePowerForBandsAveragePatient(listEDF, savefile, removedFiles);

end




