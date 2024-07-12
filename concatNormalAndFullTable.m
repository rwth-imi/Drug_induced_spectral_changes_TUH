%put together drug data table and normal data table

drive="D:/";

%drug data table with receptor properties
savefile =strcat(drive, "Results\MixedModel\FullTableMixedModel.csv");
dataAll=readtable(savefile);

%normal data table (only patients that took no drugs) without receptor
%properties 
file2 =strcat(drive, "Results\MixedModel\Powerspectrum\NormalWOAllMixed_powerspectrum.csv");
dataNormal=readtable(file2);

%all drugs for mixed model
meds=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol", ...
    "Fluphenazine", "Perphenazine",...
    "Clozapin", ...
    "Citalopram", "Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Mirtazapine", ...
    "Trazodone", "Amitriptyline", "Clomipramin", "Doxepin", "Duloxetin", ...
    "Nortriptylin"];

%add receptor properties to normal data table
%add headers
%add drug names as headers
for j=1:length(meds)
    dataNormal.(meds{j})=zeros(size(dataNormal,1),1);
end
%add headers for drug groups
dataNormal.Antidepressant=zeros(size(dataNormal,1),1);
dataNormal.Antipsychotic=zeros(size(dataNormal,1),1);
%dataNormal.DrugGroup=zeros(size(dataNormal,1),1);
%add headers for categories
dataNormal.SGA=zeros(size(dataNormal,1),1);
dataNormal.FGA=zeros(size(dataNormal,1),1);
%add headers for receptor properties
receptorPropertiesFile=strcat(drive, "Results/MixedModel/DrugReceptorProperties.xlsx");
fileReceptor = readtable(receptorPropertiesFile);
header = fileReceptor.Properties.VariableNames;
%set all receptor properties zero
for j=4:length(header)
    dataNormal.(header{j})=zeros(size(dataNormal,1),1);
end

%concat Tables
newTable = [dataAll; dataNormal];

%save
savefile =strcat(drive, "Results\MixedModel\FullTableMixedModelNormal.csv");
writetable(newTable, savefile);
