%calculate t-test-statistics from edf files, returns several xls files and graphic

clear;

%import necessary functions
d = functionsForTUHData;
funcEEGData = visualizeEEGData;
funcEDF = functionsForEDFFiles;

%change folders and drug group
drive="D:/Results/t-test/drug groups/";
driveS="D:/Results/t-test/single drugs/";
group="AP";
group="AED";

if group == "AP"
    meds=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol", "Clozapin"];%no files for Amisulpride, Paliperidone
    meds=["Risperidone"];
elseif group == "AD"
    meds = ["Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Trazodone"];
elseif group == "AED"
    meds=["Valproate", "Lamotrigine", "Carbamazepine", "Topiramate", "Levetiracetam"];
    meds=["Carbamazepine"];
elseif group == "BDZ"
    meds = ["Lorazepam", "Clonazepam", "Diazepam", "Alprazolam"];
end

singleDrug=true;%only use files with single drug intake (only one drug from our list)

for i=1:length(meds)
    medicine = strcat(meds(i));
    disp(medicine);
    
    fileMeds = strcat(driveS,"Powerspectrum/",medicine,'_powerspectrumAverage.xls');%
    if singleDrug == true
        fileMeds = strcat(driveS,"Powerspectrum/",medicine,'_powerspectrumAverageSingleDrug.xls');%
    end
    fileGroup = strcat(drive,"Powerspectrum/",group,'WO',medicine,'_powerspectrumAverage.xls');

    %read data into Matlab
    %created with prepareData.m
    dataNormal = readtable(fileGroup);
    data = readtable(fileMeds);

    %calculate statistics
    path=strcat(driveS,"StatisticsGroup/");
    if singleDrug == true
        path=strcat(driveS,"StatisticsSingle/");
    end
    filenameGroup=strcat(group,'WO',medicine);
    %funcEEGData.calcPValueAndMore(dataNormal, data, medicine, path, filenameGroup);

    %created in calcPValueAndMore
    filename = strcat(path, medicine, '_', filenameGroup, '_data.xls');
    data = readcell(filename);

    %visualize previously created data and saves figure
    %visualizePValues(dataPValue, bAT, bAbsolut, sFigureName)
    % bAbsolut      adjust function for absolut or relative value output
    savepath=strcat(driveS,"FiguresGroup/");
    imageTitle = strcat(medicine, {' vs '},group,' - Absolute');
    if singleDrug == true
        imageTitle = strcat(medicine, {' vs '},group,' - Absolute, single drug');
    end
    funcEEGData.visualizePValues(data, true, imageTitle, savepath, false, group);
    %with bonferoni correction for multiple tests
    funcEEGData.visualizePValues(data, true, imageTitle, savepath, true, group);
    
    imageTitle = strcat(medicine, {' vs '},group,' - Relative');
    if singleDrug == true
        imageTitle = strcat(medicine, {' vs '},group,' - Relative, single drug');
    end
    funcEEGData.visualizePValues(data, false, imageTitle, savepath, false, group);
    %with bonferoni correction for multiple tests
    funcEEGData.visualizePValues(data, false, imageTitle, savepath, true, group);

end
