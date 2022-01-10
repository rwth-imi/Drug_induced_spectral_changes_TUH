clear;
%create full table for mixed model from individual powerspectrum tables
%created in createPSForMixedModel.m

%all drugs for mixed model
% meds=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol", ...
%     "Cariprazine", "Asenapine", "Benperidol", "Bromperidol", "Chlorprotixene", "Flupentixole", ...
%     "Fluphenazine", "Fluspirilene", "Levomepromazine", "Melperone", "Perazin", "Perphenazine",...
%     "Pimozide", "Pipamperon", "Prothipendyl", "Sertindole", "Sulpiride", "Thioridazine",...
%     "Zuclopenthixol", "Clozapin", ...
%     "Citalopram", "Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Mirtazapine", ...
%     "Trazodone", "Agomelatin", "Amitriptyline", "Clomipramin", "Doxepin", "Duloxetin", "Imipramin", ...
%     "Maprotilin", "Mianserin", "Milnacipran", "Moclobemid", "Nortriptylin", "Reboxetin",...
%     "Tranylcypromin", "Trimipramin",...
%     "Lithium"];

meds=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol", ...
    "Fluphenazine", "Perphenazine",...
    "Clozapin", ...
    "Citalopram", "Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Mirtazapine", ...
    "Trazodone", "Amitriptyline", "Clomipramin", "Doxepin", "Duloxetin", ...
    "Nortriptylin", ...
    "Lithium"];
% meds=["Fluphenazine", "Perphenazine"];

dataAll = [];
drive="D:/";
%put together powerspectrum tables for individual drugs
for i=1:length(meds)
   %get drug table
   medicine = strcat(meds(i));
   disp(medicine);
   savefile = strcat(drive, 'Results\Powerspectrum\', medicine, '_powerspectrumMixedModel.xls');
   dataDrug = readtable(savefile);
   %add drug names as headers
   for j=1:length(meds)
        if meds{j}==medicine
            %set current drug to 1
            dataDrug.(meds{j})=ones(size(dataDrug,1),1);
        else
            dataDrug.(meds{j})=zeros(size(dataDrug,1),1);
        end
   end
    if isempty(dataAll)
        dataAll=dataDrug;
    else
        %add data
        PatientNr={0};
        SessionNr={0};
        FileNr={0};
        previous=table(PatientNr,SessionNr,FileNr);
        for j=1:size(dataDrug,1)
            entry=dataDrug(j,{'PatientNr' 'SessionNr', 'FileNr'});
            key=strcat(entry.PatientNr{1},entry.SessionNr{1},entry.FileNr{1});
            key2=strcat(previous.PatientNr{1},previous.SessionNr{1},previous.FileNr{1});
            %next file
            if ~strcmp(key,key2)
                %is this patient already in dataAll table?
                index = find(ismember(dataAll(:,{'PatientNr' 'SessionNr', 'FileNr'}),entry));
                %if entry is not in dataAll
                if isempty(index)
                    %find all corresponding entries in dataDrug
                    index = find(ismember(dataDrug(:,{'PatientNr' 'SessionNr', 'FileNr'}),entry));
                    %add entry in dataAll
                    dataAll = [dataAll; dataDrug(index,:)];
                else %if entry is already in dataAll
                    %set drug to 1 into same entry in dataAll
                    dataAll(index, medicine) = array2table(ones(size(index,1),1));
                end
                previous=entry;
            end
        end
    end
end
dataAll.Power = num2str(dataAll.Power);
%save file
savefile =strcat(drive, "Results\FullTableMixedModelWOReceptorProperties.csv");
writetable(dataAll, savefile);
disp("Receptor properties");
%calculate total drug properties
%add headers for drug groups
dataAll.Antidepressant=zeros(size(dataAll,1),1);
dataAll.Antipsychotic=zeros(size(dataAll,1),1);
%add headers for categories
dataAll.SGA=zeros(size(dataAll,1),1);
dataAll.FGA=zeros(size(dataAll,1),1);
%add headers for receptor properties
receptorPropertiesFile="D:/Results/DrugReceptorProperties.xlsx";
fileReceptor = readtable(receptorPropertiesFile);
header = fileReceptor.Properties.VariableNames;
for j=4:length(header)
    dataAll.(header{j})=zeros(size(dataAll,1),1);
end

for j=1:length(meds)
    medicine=meds(j);
    disp(medicine);
    %find all indexes where drug is 1
    index = find(ismember(dataAll.(medicine),1));
    %get receptor propeties for drug
    index2 = find(ismember(fileReceptor.DrugName, medicine));
    row = fileReceptor(index2,:);
    row = fillmissing(row,'constant',0, 'DataVariables', @isnumeric);
    properties=row;
    
    %update receptor profile
    %drug groups
    if strcmp(properties.DrugGroup, "AP")
        dataAll.Antipsychotic(index)=1;
    elseif strcmp(properties.DrugGroup, "AD")
        dataAll.Antidepressant(index)=1;
    end
    
    %categories
    if strcmp(properties.Category, "SGA")
        dataAll.SGA(index)=1;
    elseif strcmp(properties.Category, "FGA")
        dataAll.FGA(index)=1;
    end 
    
    %für jede Zeile von dataAll(index)
    for k=1:length(index)
        %für jeden Eintrag in properties
        n=9+length(meds);%number of entry where receptor properties start
        for i=4:size(properties,2)
            if dataAll{index(k),i+n}==0
                dataAll{index(k),i+n}=properties{1,i};
            elseif dataAll{index(k),i+n}==-1
                if properties{1,i}==0 || properties{1,i}==-1
                    dataAll{index(k),i+n}=-1;
                else
                    dataAll{index(k),i+n}=2;
                end
            elseif dataAll{index(k),i+n}==1
                if properties{1,i}==0 || properties{1,i}==1
                    dataAll{index(k),i+n}=1;
                else
                    dataAll{index(k),i+n}=2;
                end
                %if dataAll==2: it stays the same
            end

        end
    end
    savefile =strcat(drive, "Results\FullTableMixedModel.csv");
    writetable(dataAll, savefile);
end

%save file
%savefile =strcat(drive, "Results\FullTableMixedModel.csv");
%writetable(dataAll, savefile);



