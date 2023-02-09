% calculates powerspectrum tables for drug groups from Hyun by combining
% powerspectrum tables from single drugs and averaging over patients

%import necessary functions
funcEDF = functionsForEDFFiles;

psFolder = "D:/Results/t-test/single drugs/Powerspectrum/";%powerspecrta for single drugs
resultFolder = "D:/Results/t-test/drug groups/Powerspectrum/";%result folder

drugGroup="AED";
meds="";
singleDrug=true;%only use files with single drug intake (only one drug from our list)

%drug groups from Hyun
if drugGroup == "AP"
    meds=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol"];
    %no files for Amisulpride, Paliperidone
elseif drugGroup == "CLZ"
    meds = ["Clozapin"];
elseif drugGroup == "AD"
    meds = ["Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Trazodone"];
elseif drugGroup == "AED"
    meds=["Valproate", "Lamotrigine", "Carbamazepine", "Topiramate", "Levetiracetam"];
elseif drugGroup == "LI"
    meds = ["Lithium"];
elseif drugGroup == "BDZ"
    meds = ["Lorazepam", "Clonazepam", "Diazepam", "Alprazolam"];
end

%get powerspectrum files
data={};
for i=1:length(meds)
    medicine = strcat(meds(i));
        
    %get powerspectrum data
    psfile = strcat(psFolder, medicine, '_powerspectrum.xls');
    if singleDrug == true
        psfile = strcat(psFolder, medicine, '_powerspectrumSingleDrug.xls');
    end
    power=readcell(psfile);
    s=size(power,1);
    if i==1
        data(1,:)=power(1,:);
    end
    data=[data;power(2:s,:)];
end
%remove duplicate entries
l=size(data,2);
[~,idx]=unique(data(:,l) , 'rows');
idx=sort(idx);
dataWODuplicate=data(idx,:);

%save powerspectrum for group
psFile= strcat(resultFolder, drugGroup, '_powerspectrum.xls');
if singleDrug == true
    psFile= strcat(resultFolder, drugGroup, '_powerspectrumSingleDrug.xls');
end
dataWODuplicate( cellfun( @(c) isa(c,'missing'), dataWODuplicate ) ) = {nan};
writecell(dataWODuplicate, psFile);

%average over patients
psFileAverage= strcat(resultFolder, drugGroup, '_powerspectrumAverage.xls');
if singleDrug == true
    psFileAverage= strcat(resultFolder, drugGroup, '_powerspectrumAverageSingleDrug.xls');
end
funcEDF.averagePatientTTest(psFile, psFileAverage);



