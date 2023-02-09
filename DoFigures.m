%create figures

%import necessary functions
%d = functionsForTUHData;
funcEEGData = visualizeEEGData;
%funcEDF = functionsForEDFFiles;

%all drugs from Hyun
meds=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol", "Clozapin", ...
    "Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Mirtazapine", ...
    "Trazodone", "Valproate", "Lamotrigine", "Carbamazepine", "Topiramate", "Levetiracetam", "Lithium", ...
    "Lorazepam", "Clonazepam", "Diazepam", "Alprazolam"];
meds=["Risperidone", "Carbamazepine"];

drive="D:/Results/t-test/single drugs/";

%drug groups
%meds=["AD", "AED", "AP", "BDZ", "Clozapin", "Lithium"]

%drive="D:/Results/t-test/drug groups/";

singleDrug=true;%only use files with single drug intake (only one drug from our list)

path=strcat(drive,"Statistics/");
if singleDrug == true
    path=strcat(drive,"StatisticsSingle/");
end

for i=1:length(meds)
    medicine = strcat(meds(i));
    disp(medicine);
    %created in calcPValueAndMore
    filename = strcat(path, medicine, '_normal_data.xls');
    data = readcell(filename);

    %visualize previously created data and saves figure
    %visualizePValues(dataPValue, bAT, bAbsolut, sFigureName)
    % bAbsolut      adjust function for absolut or relative value output
    savepath=strcat(drive,"Figures/");
    imageTitle = strcat(medicine, ' vs Normal - Absolute');
    if singleDrug == true
        imageTitle = strcat(medicine, ' vs Normal - Absolute, single drug');
    end
    funcEEGData.visualizePValues(data, true, imageTitle, savepath, false, "normal");
    %with bonferoni correction for multiple tests
    funcEEGData.visualizePValues(data, true, imageTitle, savepath, true, "normal");
    
    imageTitle = strcat(medicine, ' vs Normal - Relative');
    if singleDrug == true
        imageTitle = strcat(medicine, ' vs Normal - Relative, single drug');
    end
    funcEEGData.visualizePValues(data, false, imageTitle, savepath, false, "normal");
    %with bonferoni correction for multiple tests
    funcEEGData.visualizePValues(data, false, imageTitle, savepath, true, "normal");
    
end