
clear;
%check if this is the right folder, folders must exists!
drive="D:/";% folder with edf files
resultFolder = "D:/Results/t-test/single drugs/Powerspectrum/";% result folder

%import necessary functions
d = functionsForTUHData;
funcEDF = functionsForEDFFiles;
TUHDownload = functionsTuhDownload;
excelFuncs = scriptWorkWithExcelData;

%all drugs from Hyun
meds=["Risperidone", "Olanzapine", "Quetiapine", "Aripiprazole", "Ziprasidone", "Haloperidol", "Clozapin", ...
    "Escitalopram", "Sertraline", "Paroxetine", "Fluoxetine", "Bupropion", "Venlafaxine", "Mirtazapine", ...
    "Trazodone", "Valproate", "Lamotrigine", "Carbamazepine", "Topiramate", "Levetiracetam", "Lithium", ...
    "Lorazepam", "Clonazepam", "Diazepam", "Alprazolam"];

for i=1:length(meds)
    medicine = strcat(meds(i));
    disp(medicine);
    %filter for single drug use
    filename = strcat(drive,'EDFData/', medicine, '/listOfPatients', medicine, '.xls');%file with filenames and drug use
    file = readcell(filename,  'DateTimeType', 'text');

    pattern=["others"];

    %         pattern=["Cariprazine", "Asenapine", "Benperidol", "Bromperidol", "Chlorprotixene", "Flupentixole", ...
    %     "Fluphenazine", "Fluspirilene", "Levomepromazine", "Melperone", "Perazin", "Perphenazine",...
    %     "Pimozide", "Pipamperon", "Prothipendyl", "Sertindole", "Sulpiride", "Thioridazine",...
    %     "Zuclopenthixol", "Citalopram", "Agomelatin", "Amitriptyline", "Clomipramin", "Doxepin", "Duloxetin", "Imipramin", ...
    %     "Maprotilin", "Mianserin", "Milnacipran", "Moclobemid", "Nortriptylin", "Reboxetin","Tranylcypromin", "Trimipramin"];
    %         
    %Group AP
    if medicine~="Risperidone"
        pattern = [pattern, "risperidone", "risperdal", "perseris", "risperdone"];
    end
    if medicine~="Olanzapine"
        pattern = [pattern,"zyprexa", "olanzapine"];  
    end
    if medicine~="Quetiapine"
        pattern = [pattern,"quetiapine", "seroquel"];
    end
    if medicine~="Aripiprazole"
        pattern = [pattern,"aripiprazole", "abilify", "aristada"];
    end
    if medicine~="Ziprasidone"
        pattern = [pattern, "ziprasidone", "geodon", "zeldox"];
    end
    if medicine~="Haloperidol"
        pattern = [pattern, "haloperidol", "haldol"];
    end
    if medicine~="Amisulpride"
        pattern = [pattern, "amisulpride", "barhemsys"];
    end

    %Group CLZ
    if medicine~="Clozapin"
        pattern = [pattern, "clozapin","clozaril","clopine","fazaclo"]; 
    end
    %Group AD
    if medicine~="Escitalopram"
        pattern = [pattern, "escitalopram", "lexapro"];
    end
    if medicine~="Sertraline"
        pattern = [pattern, "sertraline", "zoloft"];
    end
    if medicine~="Paroxetine"
        pattern = [pattern, "paroxetine", "paxil", "brisdelle", "pexeva"];
    end
    if medicine~="Fluoxetine"
        pattern = [pattern, "fluoxetine", "prozac", "sarafem", "rapiflux"];
    end
    if medicine~="Fluvoxamine"
        pattern = [pattern, "fluvoxamine", "luvox"];
    end
    if medicine~="Bupropion"
        pattern = [pattern, "Bupropion", "Wellbutrin", "Zyban"];
    end
    if medicine~="Venlafaxine"
        pattern = [pattern, "Venlafaxine", "Effexor"];
    end
    if medicine~="Mirtazapine"
        pattern = [pattern, "Mirtazapine", "Remeron"];
    end
    if medicine~="Trazodone"
        pattern = [pattern, "Trazodone", "Desyrel", "Oleptro"];
    end

    %Group AED
    if medicine~="Valproate"
        pattern = [pattern, "Valproate", "Depakene", "Depacon", "Stavzor"];
    end
    if medicine~="Lamotrigine"
        pattern = [pattern, "Lamotrigine", "Lamictal", "Subvenite"];
    end
    if medicine~="Carbamazepine"
        pattern = [pattern, "Carbamazepine", "Tegretol", "Carbatrol", "Epitol"];
    end
    if medicine~="Topiramate"
        pattern = [pattern, "Topiramate", "Topamax", "Trokendi", "Qudexy"];
    end
    if medicine~="Levetiracetam"
        pattern = [pattern, "Levetiracetam", "Elepsia", "Keppra", "Roweepra", "Spritam"];
    end
    %Group Li
    if medicine~="Lithium"
        pattern = [pattern, "Lithium", "Lithobid", "Eskalith", "Lithonate"];
    end
    %Group BDZ
    if medicine~="Lorazepam"
        pattern = [pattern, "Lorazepam", "Ativan"];
    end
    if medicine~="Clonazepam"
        pattern = [pattern, "Clonazepam", "Klonopin"];
    end
    if medicine~="Diazepam"
        pattern = [pattern, "Diazepam", "Valium", "Valtoco", "Diastat"];
    end
    if medicine~="Alprazolam"
        pattern = [pattern, "Alprazolam", "Xanax", "Niravam"];
    end

    resultFiles = excelFuncs.findFilesWithoutMedicine(file, pattern);%single drug text files 
    resultFiles( cellfun( @(c) isa(c,'missing'), resultFiles ) ) = {[]};

    %save file
    writecell(resultFiles, strcat(resultFolder, medicine,'SingleDrugTxt.xls'));%single drug text files 

    folder = strcat(drive,'EDFData\', medicine, '\CleanData');
    listEDF = d.createFileList('edf',folder);
    k=1;
    l=1;
    EDFfiles={};
    for i=1:length(resultFiles)
        file = TUHDownload.getFileNameFromURLstring(resultFiles{i,1});
        file = strsplit(file{1}, '.'); 
        file = file{1};
        for j=1:length(listEDF)
            edf = TUHDownload.getFileNameFromURLstring(listEDF{j,1});
            if contains(edf,file)
                EDFfiles{l} =strcat(drive, edf{1});
                l=l+1;
            end
        end
    end

     EDFfiles=transpose(EDFfiles);
     writecell(EDFfiles, strcat(resultFolder, medicine, 'SingleDrugEDF.xls'));

     %take powerspectrum file
     psFilename = strcat(resultFolder, medicine, "_powerspectrum");
     psData = readcell(psFilename);
     %psData = psData{:,:};
     
     %make new powerspectrum file only with the files from listEDF
     newPSTable={};
     newPSTable(1,:)=psData(1,:);
     j=2;
     for i = 1:size(EDFfiles)
         edfFile=EDFfiles{i};
         edfFile=strsplit(edfFile,"\");
         edfFile=edfFile(end);
         %check if filename is in list with single drugs
         column=psData(:,96);
         row = find(column == edfFile);
         if row
            newPSTable(j,:)=psData(row,:);
            j=j+1;
         end 
  
     end
     %save table
     psfile = strcat(resultFolder, medicine, '_powerspectrumSingleDrug.xls');
     psFileAverage= strcat(resultFolder, medicine, '_powerspectrumAverageSingleDrug.xls');
     
     newPSTable( cellfun( @(c) isa(c,'missing'), newPSTable ) ) = {[]};
     writecell(newPSTable, psfile);

     %average over patient
     funcEDF.averagePatientTTest(psfile, psFileAverage);
end
     
     
     
     