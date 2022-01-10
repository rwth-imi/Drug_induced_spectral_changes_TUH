%put together drug data table and normal data table

%drug data table with receptor properties
savefile ="Results\FullTableMixedModel2.csv";
dataAll=readtable(savefile);

%normal data table (only patients that took no drugs) without receptor
%properties 
file2 ="Results\Powerspectrum\NormalWOAllMixed_powerspectrum.csv";
dataNormal=readtable(file2);

%all drugs for mixed model
meds=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol", ...
    "Fluphenazine", "Perphenazine",...
    "Clozapin", ...
    "Citalopram", "Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Mirtazapine", ...
    "Trazodone", "Amitriptyline", "Clomipramin", "Doxepin", "Duloxetin", ...
    "Nortriptylin", ...
    "Lithium"];

%add receptor properties to normal data table
%add headers
%add drug names as headers
for j=1:length(meds)
    dataNormal.(meds{j})=zeros(size(dataNormal,1),1);
end
%add headers for drug groups
dataNormal.Antidepressant=zeros(size(dataNormal,1),1);
dataNormal.Antipsychotic=zeros(size(dataNormal,1),1);
%add headers for categories
dataNormal.SGA=zeros(size(dataNormal,1),1);
dataNormal.FGA=zeros(size(dataNormal,1),1);
%add headers for receptor properties
receptorPropertiesFile="Results/DrugReceptorProperties.xlsx";
fileReceptor = readtable(receptorPropertiesFile);
header = fileReceptor.Properties.VariableNames;
%set all receptor properties zero
for j=4:length(header)
    dataNormal.(header{j})=zeros(size(dataNormal,1),1);
end

%concat Tables
newTable = [dataAll; dataNormal];

%save
savefile =strcat("Results\FullTableMixedModelNormal.csv");
writetable(newTable, savefile);
