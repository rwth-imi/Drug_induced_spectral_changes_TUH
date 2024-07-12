%%%calculates power spectrum of normal data for all the data files without a certain medicine
%can be used for t-tests and mixed model, just change 'medicine'

clear;
%import necessary functions
funcs = scriptWorkWithExcelData;
d = functionsTuhDownload;
funcEDF = functionsForEDFFiles;

%medicine = 'All';%for t-test-Model
medicine = 'AllMixed';%for mixed Model
fileNormal = 'Data_xls\Normal\tuh_eeg_normal.xls';
normalFiles = readcell(fileNormal, 'DateTimeType', 'text');

%get only edf and txt files
j=1;
k=1;
for i=1:length(normalFiles)
    type = normalFiles{i,3};
    if strcmp(type, 'txt')
        normalTxt{j,1} = normalFiles{i,1}; 
        normalTxt{j,2} = normalFiles{i,2};
        normalTxt{j,3} = normalFiles{i,3};
        normalTxt{j,4} = normalFiles{i,4}; 
        j = j+1; 
    end
    if strcmp(type, 'edf')
        normalEdf{k,1} = normalFiles{i,1}; 
        normalEdf{k,2} = normalFiles{i,2};
        normalEdf{k,3} = normalFiles{i,3};
        normalEdf{k,4} = normalFiles{i,4}; 
        k = k+1; 
    end
end

pattern=[];
resultFiles=[];
if strcmp(medicine,'All')
    %Group AP
    pattern = ["risperidone", "risperdal", "perseris", "risperdone"];
    pattern = [pattern,"zyprexa", "olanzapine"];    
    pattern = [pattern,"quetiapine", "seroquel"];
    pattern = [pattern,"aripiprazole", "abilify", "aristada"];
    pattern = [pattern, "ziprasidone", "geodon", "zeldox"];
    pattern = [pattern, "haloperidol", "haldol"];
    pattern = [pattern, "amisulpride", "barhemsys"];%no entries found!
    %Group CLZ
    pattern = [pattern, "clozapin","clozaril","clopine","fazaclo"];     
    %Group AD
    pattern = [pattern, "escitalopram", "lexapro"];
    pattern = [pattern, "sertraline", "zoloft"];
    pattern = [pattern, "paroxetine", "paxil", "brisdelle", "pexeva"];
    pattern = [pattern, "fluoxetine", "prozac", "sarafem", "rapiflux"];
    pattern = [pattern, "fluvoxamine", "luvox"];
    pattern = [pattern, "Bupropion", "Wellbutrin", "Zyban"];
    pattern = [pattern, "Venlafaxine", "Effexor"];
    pattern = [pattern, "Mirtazapine", "Remeron"];
    pattern = [pattern, "Trazodone", "Desyrel", "Oleptro"];
    %Group AED
    pattern = [pattern, "Valproate", "Depakene", "Depacon", "Stavzor"];
    pattern = [pattern, "Lamotrigine", "Lamictal", "Subvenite"];
    pattern = [pattern, "Carbamazepine", "Tegretol", "Carbatrol", "Epitol"];
    pattern = [pattern, "Topiramate", "Topamax", "Trokendi", "Qudexy"];
    pattern = [pattern, "Levetiracetam", "Elepsia", "Keppra", "Roweepra", "Spritam"];
    %Group Li
    pattern = [pattern, "Lithium", "Lithobid", "Eskalith", "Lithonate"];
    %Group BDZ
    pattern = [pattern, "Lorazepam", "Ativan"];
    pattern = [pattern, "Clonazepam", "Klonopin"];
    pattern = [pattern, "Diazepam", "Valium", "Valtoco", "Diastat"];
    pattern = [pattern, "Alprazolam", "Xanax", "Niravam"];
    resultFiles = funcs.findFilesWithoutMedicine(normalTxt, pattern);
elseif strcmp(medicine,'AllMixed')
    %all drugs for mixed model
%     meds=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol", ...
%         "Cariprazine", "Asenapine", "Benperidol", "Bromperidol", "Chlorprotixene", "Flupentixole", ...
%         "Fluphenazine", "Fluspirilene", "Levomepromazine", "Melperone", "Perazin", "Perphenazine",...
%         "Pimozide", "Pipamperon", "Prothipendyl", "Sertindole", "Sulpiride", "Thioridazine",...
%         "Zuclopenthixol", "Clozapin", ...
%         "Citalopram", "Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Mirtazapine", ...
%         "Trazodone", "Agomelatin", "Amitriptyline", "Clomipramin", "Doxepin", "Duloxetin", "Imipramin", ...
%         "Maprotilin", "Mianserin", "Milnacipran", "Moclobemid", "Nortriptylin", "Reboxetin",...
%         "Tranylcypromin", "Trimipramin",...
%         "Lithium"];
%     for i=1:size(meds,2)
%        pattern = [pattern, funcs.getTradeNames(meds(i))]; 
%     end
%     resultFiles = funcs.findFilesWithoutMedicine(normalTxt, pattern);
    resultFiles = funcs.findFilesWithMedicine(normalTxt, "none");
end

resultFiles( cellfun( @(c) isa(c,'missing'), resultFiles ) ) = {[]};

%save file
writecell(resultFiles, strcat('Results\Powerspectrum\normalWO', medicine, '.xls'));

k=1;
l=1;
for i=1:length(resultFiles)
    file = d.getFileNameFromURLstring(resultFiles{i,1});
    file = strsplit(file{1}, '.'); 
    file = file{1};
    for j=1:length(normalEdf)
        edf = d.getFileNameFromURLstring(normalEdf{j,1});
        if contains(edf,file)
            EDFfiles{l} =strcat('EDFData\NormalFull\CleanData\', edf{1});
            l=l+1;
            normal{k,1} = normalEdf{j,1}; 
            normal{k,2} = normalEdf{j,2};
            normal{k,3} = normalEdf{j,3};
            normal{k,4} = normalEdf{j,4}; 
            k = k+1; 

        end
    end
end
normal( cellfun( @(c) isa(c,'missing'), normal ) ) = {[]};
writecell(normal, strcat('Results\Powerspectrum\normalWO', medicine, 'EDF.xls'));

%calculate power spectrum 
%add eeglab to path and start its init file%
addpath('eeglab2021.0\'); 
eeglab;
savefile = strcat('Results\Powerspectrum\NormalWO', medicine, '_powerspectrum.xls');
if strcmp(medicine,'All')
    savefile = strcat('Results\Powerspectrum\NormalWO', medicine, '_powerspectrum.xls');
    funcEDF.calculatePowerForBandsAveragePatient(EDFfiles, savefile);
else
    savefile = strcat('Results\Powerspectrum\NormalWO', medicine, '_powerspectrum.csv');
    removedFiles = strcat('Results\Powerspectrum\', medicine, '_removedFilesEpochs.txt');
    funcEDF.calculatePowerForBands(EDFfiles, savefile, removedFiles);
end


