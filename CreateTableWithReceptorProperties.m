%all drugs where we found data
meds=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol", ...
    "Fluphenazine", "Perphenazine",...
    "Clozapin", ...
    "Citalopram", "Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Mirtazapine", ...
    "Trazodone", "Amitriptyline", "Clomipramin", "Doxepin", "Duloxetin", ...
    "Nortriptylin", ...
    "Lithium"];

drive="D:/";
savefile =strcat(drive, "Results\FullTableMixedModelWOReceptorProperties.csv");
%savefile =strcat(drive, "Results\Test.csv");
dataAll=readtable(savefile);
disp("Receptor properties");
%calculate total drug properties
%add headers for drug groups
dataAll.DrugGroup=zeros(size(dataAll,1),1);
%dataAll.Antidepressant=zeros(size(dataAll,1),1);
%dataAll.Antipsychotic=zeros(size(dataAll,1),1);
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
    for k=1:length(index)
        if dataAll.DrugGroup(index(k))==0 %no drug
            if strcmp(properties.DrugGroup, "AP")
                dataAll.DrugGroup(index(k))=-1;
            elseif strcmp(properties.DrugGroup, "AD")
                dataAll.DrugGroup(index(k))=1;
            end
        elseif dataAll.DrugGroup(index(k))==1%AD
            if strcmp(properties.DrugGroup, "AP")
                dataAll.DrugGroup(index(k))=2;
            end
        elseif dataAll.DrugGroup(index(k))==-1%AP
            if strcmp(properties.DrugGroup, "AD")
                dataAll.DrugGroup(index(k))=2;
            end
        end
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
        n=8+length(meds);%number of entry where receptor properties start
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


