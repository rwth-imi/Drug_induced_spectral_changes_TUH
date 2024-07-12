% calculates powerspectrum tables for drug groups from Hyun by combining
% powerspectrum tables from single drugs and averaging over patients

clear;

%import necessary functions
funcEDF = functionsForEDFFiles;

psFolder = "D:/Results/t-test/single drugs/Powerspectrum/";%powerspecrta for single drugs
resultFolder = "D:/Results/t-test/drug groups/Powerspectrum/";%result folder
drugGroup="AED";%change to group to be calculated

meds="";
drug="";

singleDrug=true;%only use files with single drug intake (only one drug from our list)

%drug groups from Hyun
if drugGroup == "AP"
    medsFull=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol"];%no files for Amisulpride, Paliperidone
elseif drugGroup == "AD"
    medsFull = ["Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Trazodone"];
elseif drugGroup == "AED"
    medsFull=["Carbamazepine", "Valproate", "Lamotrigine", "Topiramate", "Levetiracetam"];
elseif drugGroup == "BDZ"
    medsFull = ["Lorazepam", "Clonazepam", "Diazepam", "Alprazolam"];
end

for j=1:length(medsFull)
   drug = medsFull(j);
   disp(drug);
   meds=medsFull;
   meds(j)=[];

    %get powerspectrum files
    data={};
    for i=1:length(meds)
        medicine = strcat(meds(i));

        %get powerspectrum data
        if singleDrug
            psfile = strcat(psFolder, medicine, '_powerspectrumSingleDrug.xls');
        else
            psfile = strcat(psFolder, medicine, '_powerspectrum.xls');
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
    psFile= strcat(resultFolder, drugGroup, 'WO',drug,'_powerspectrum.xls');
    dataWODuplicate( cellfun( @(c) isa(c,'missing'), dataWODuplicate ) ) = {[]};
    writecell(dataWODuplicate, psFile);

    %average over patients
    psFileAverage= strcat(resultFolder, drugGroup, 'WO',drug,'_powerspectrumAverage.xls');
    funcEDF.averagePatientTTest(psFile, psFileAverage);

end

