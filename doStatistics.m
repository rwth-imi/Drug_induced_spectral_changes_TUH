%calculate t-test-statistics from edf files, returns several xls files and graphic

%add eeglab to path and start its init file%
%addpath('eeglab2021.0\'); 
%eeglab; 

%import necessary functions
d = functionsForTUHData;
funcEEGData = visualizeEEGData;
funcEDF = functionsForEDFFiles;

%all drugs from Hyun
meds=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol", "Clozapin", ...
    "Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Mirtazapine", ...
    "Trazodone", "Valproate", "Lamotrigine", "Carbamazepine", "Topiramate", "Levetiracetam", "Lithium", ...
    "Lorazepam", "Clonazepam", "Diazepam", "Alprazolam"];

meds=["Lithium"];
%meds=["Clozapin", "Risperidone", "Diazepam"];
%meds=["Clozapin"];
for i=1:length(meds)
    medicine = strcat(meds(i));
    
    fileMeds = strcat('Results/Powerspectrum/',medicine,'_powerspectrum.xls');%
    fileNormal = strcat('Results/Powerspectrum/NormalWOAll_powerspectrum.xls');

    %read data into Matlab
    %created with prepareData.m
    dataNormal = readtable(fileNormal);
    data = readtable(fileMeds);

    %calculate statistics
    funcEEGData.calcPValueAndMore(dataNormal, data, medicine);

    %created in calcPValueAndMore
    filename = strcat('Results/', medicine, '_normal_data.xls');
    data = readcell(filename);

    %visualize previously created data and saves figure
    %visualizePValues(dataPValue, bAT, bAbsolut, sFigureName)
    % bAbsolut      adjust function for absolut or relative value output
    imageTitle = strcat(medicine, ' vs Normal - Absolute');
    funcEEGData.visualizePValues(data, true, imageTitle);
    
    imageTitle = strcat(medicine, ' vs Normal - Relative');
    funcEEGData.visualizePValues(data, false, imageTitle);

end
