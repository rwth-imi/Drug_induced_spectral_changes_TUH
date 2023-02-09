%calculate t-test-statistics from powerspectrum files, 
%returns xls files: nameMed_powerspectrum_rmoutliers.xls and  nameMed_normal_data.xls

%import necessary functions
funcEEGData = visualizeEEGData;

%all drugs from Hyun
meds=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol", "Clozapin", ...
    "Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Mirtazapine", ...
    "Trazodone", "Valproate", "Lamotrigine", "Carbamazepine", "Topiramate", "Levetiracetam", "Lithium", ...
    "Lorazepam", "Clonazepam", "Diazepam", "Alprazolam"];
drive="D:/Results/t-test/single drugs/";

%groups
%meds=["AP","AD","AED","BDZ"];
%drive="D:/Results/t-test/drug groups/";

singleDrug=true;%only use files with single drug intake (only one drug from our list)


medicine = "Levetiracetam";
medicine2= "Carbamazepine";

fileMeds = strcat(drive,"Powerspectrum/",medicine,'_powerspectrumAverage.xls');%
fileMeds2 = strcat(drive,"Powerspectrum/",medicine2,'_powerspectrumAverage.xls');
if singleDrug == true
    fileMeds = strcat(drive,"Powerspectrum/",medicine,'_powerspectrumAverageSingleDrug.xls');%
    fileMeds2 = strcat(drive,"Powerspectrum/",medicine2,'_powerspectrumAverageSingleDrug.xls');
end

%read data into Matlab
%created with prepareData.m
data2 = readtable(fileMeds2);
data = readtable(fileMeds);

%calculate statistics
path=strcat(drive,"Statistics/");
if singleDrug == true
    path=strcat(drive,"StatisticsSingle/");
end
funcEEGData.calcPValueAndMore(data2, data, medicine, path, medicine2);

%created in calcPValueAndMore
filename = strcat(path, medicine, '_',medicine2,'_data.xls');
data = readcell(filename);

%visualize previously created data and saves figure
%visualizePValues(dataPValue, bAT, bAbsolut, sFigureName)
% bAbsolut      adjust function for absolut or relative value output
savepath=strcat(drive,"Figures/");
imageTitle = strcat(medicine, ' vs ',medicine2,' - Absolute');
if singleDrug == true
    imageTitle = strcat(medicine, ' vs ',medicine2,' - Absolute, single drug');
end
funcEEGData.visualizePValues(data, true, imageTitle, savepath, false, medicine2);
%with bonferoni correction for multiple tests
funcEEGData.visualizePValues(data, true, imageTitle, savepath, true, medicine2);

imageTitle = strcat(medicine, ' vs ',medicine2,' - Relative');
if singleDrug == true
    imageTitle = strcat(medicine, ' vs ',medicine2,' - Relative, single drug');
end
funcEEGData.visualizePValues(data, false, imageTitle, savepath, false, medicine2);
%with bonferoni correction for multiple tests
funcEEGData.visualizePValues(data, false, imageTitle, savepath, true, medicine2);
