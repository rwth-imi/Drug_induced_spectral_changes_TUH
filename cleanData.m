%clean all edf-files for list of drugs

clear;
%add eeglab to path and start its init file%
addpath('eeglab2021.0\'); 
eeglab;

%all drugs from Hyun
% meds=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol", "Clozapin", ...
%     "Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Mirtazapine", ...
%     "Trazodone", "Valproate", "Lamotrigine", "Carbamazepine", "Topiramate", "Levetiracetam", "Lithium", ...
%     "Lorazepam", "Clonazepam", "Diazepam", "Alprazolam"];



%all drugs for mixed model
meds=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol", ...
    "Cariprazine", "Asenapine", "Benperidol", "Bromperidol", "Chlorprotixene", "Flupentixole", ...
    "Fluphenazine", "Fluspirilene", "Levomepromazine", "Melperone", "Perazin", "Perphenazine",...
    "Pimozide", "Pipamperon", "Prothipendyl", "Sertindole", "Sulpiride", "Thioridazine",...
    "Zuclopenthixol", "Clozapin", ...
    "Citalopram", "Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Mirtazapine", ...
    "Trazodone", "Agomelatin", "Amitriptyline", "Clomipramin", "Doxepin", "Duloxetin", "Imipramin", ...
    "Maprotilin", "Mianserin", "Milnacipran", "Moclobemid", "Nortriptylin", "Reboxetin",...
    "Tranylcypromin", "Trimipramin",...
    "Lithium"];

meds=["Levetiracetam"];
drive="D:/";

%import necessary functions
d = functionsForTUHData;
funcEDF = functionsForEDFFiles;

%clean data
for i=1:length(meds)

    medicine = strcat(meds(i));
    folder = strcat(drive,'EDFData\', medicine);

    listEDF = d.createFileList('edf',folder);

    %log errors
    diary 'logTest.txt';
    diary on;

    funcEDF.cleanData(listEDF);

    diary off;

end




