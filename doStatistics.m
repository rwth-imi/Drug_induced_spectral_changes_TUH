%calculate t-test-statistics from powerspectrum files, 
%returns xls files: nameMed_powerspectrum_rmoutliers.xls and  nameMed_normal_data.xls

%import necessary functions
funcEEGData = visualizeEEGData;

%all drugs from Hyun
meds=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol", "Clozapin", ...
    "Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Mirtazapine", ...
    "Trazodone", "Valproate", "Lamotrigine", "Carbamazepine", "Topiramate", "Levetiracetam", "Lithium", ...
    "Lorazepam", "Clonazepam", "Diazepam", "Alprazolam"];
meds=["Risperidone"];
drive="D:/Results/t-test/single drugs/";

%groups
%meds=["AP","AD","AED","BDZ"];
%drive="D:/Results/t-test/drug groups/";

singleDrug=true;%only use files with single drug intake (only one drug from our list)

for i=1:length(meds)
    medicine = strcat(meds(i));
    disp(medicine);
    
    fileMeds = strcat(drive,"Powerspectrum/",medicine,'_powerspectrumAverage.xls');%
    if singleDrug == true
        fileMeds = strcat(drive,"Powerspectrum/",medicine,'_powerspectrumAverageSingleDrug.xls');%
    end
    fileNormal = strcat(drive,"Powerspectrum/",'NormalWOAll_powerspectrum.xls');

    %read data into Matlab
    %created with prepareData.m
    dataNormal = readtable(fileNormal);
    data = readtable(fileMeds);

    %calculate statistics
    path=strcat(drive,"Statistics/");
    if singleDrug == true
        path=strcat(drive,"StatisticsSingle/");
    end
    funcEEGData.calcPValueAndMore(dataNormal, data, medicine, path, "normal");

%     %created in calcPValueAndMore
%     filename = strcat(path, medicine, '_normal_data.xls');
%     data = readcell(filename);
% 
%     %visualize previously created data and saves figure
%     %visualizePValues(dataPValue, bAT, bAbsolut, sFigureName)
%     % bAbsolut      adjust function for absolut or relative value output
%     savepath=strcat(drive,"Figures/");
%     imageTitle = strcat(medicine, ' vs Normal - Absolute');
%     if singleDrug == true
%         imageTitle = strcat(medicine, ' vs Normal - Absolute, single drug');
%     end
%     funcEEGData.visualizePValues(data, true, imageTitle, savepath, false);
%     %with bonferoni correction for multiple tests
%     funcEEGData.visualizePValues(data, true, imageTitle, savepath, true);
%     
%     imageTitle = strcat(medicine, ' vs Normal - Relative');
%     if singleDrug == true
%         imageTitle = strcat(medicine, ' vs Normal - Relative, single drug');
%     end
%     funcEEGData.visualizePValues(data, false, imageTitle, savepath, false);
%     %with bonferoni correction for multiple tests
%     funcEEGData.visualizePValues(data, false, imageTitle, savepath, true);

end
