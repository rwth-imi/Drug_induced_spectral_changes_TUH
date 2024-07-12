%to be able to call single functions from this script 
function excelDataFunctions = scriptWorkWithExcelData
   
    excelDataFunctions.createAlphaTheta = @createAlphaTheta; 
    excelDataFunctions.createBrainwaves = @createBrainwaves; 
    excelDataFunctions.getMedicalDataFromExcelSheet = @getMedicalDataFromExcelSheet; 
    excelDataFunctions.findClozapineInCellArray = @findClozapineInCellArray; 
    excelDataFunctions.findFilesWithMedicine = @findFilesWithMedicine; 
    excelDataFunctions.findFilesWithoutMedicine = @findFilesWithoutMedicine; 
    excelDataFunctions.getDataAndSubfoldersFromStringInCellArray = @getDataAndSubfoldersFromStringInCellArray; 
    excelDataFunctions.getTradeNames = @getTradeNames; 
end 

% calcualtes power spectral density for data from an EDF file for all its
% frequencies and channels
% data              expects readin EEG data from eeglab
% srate             sampling rate
% windowsize        windows size to analyze the EEG data
% overlap           overlapt between the windows 
% returns rows for alpha, beta, gamma, delta, theta ways for all channels
%   in the EEG data
% returns times from spectrogram function 
%   "a vector of time instants, t, at which the spectrogram is computed."
function [powerAlpha, powerTheta, powerDelta, powerBeta, powerGamma, times] = createBrainwaves(data,srate,windowsize,overlap)
    %define various brain wave frequencies as told by Ekaterina
    theta=[3.5 7.5];
    alpha=[7.5 12.5];
    delta = [1 3.5]; 
    beta = [12.5 30];
    gamma = [30 60]; %gamma technically open ended
   

    [channels, length] = size(data);
    windowsize = windowsize*srate;
    if windowsize > length
        windowsize = length;
        overlap = 0;
    end
    
    overlap = overlap*srate;
    
    %define rows of data
    rowsTheta = cell(channels, 1); 
    rowsAlpha = cell(channels, 1); 
    rowsDelta = cell(channels, 1);  
    rowsBeta  = cell(channels, 1); 
    rowsGamma = cell(channels, 1);     
    
    for i = 1:channels
        %fshort time fourier transform on the data.
        %get data per channel 
        channelData = data(i,:); 
        [~ , f, times, ps] = spectrogram(channelData, windowsize, overlap, [], srate);        
        
        rowsTheta{i} = f > theta(1) & f < theta(2);
        rowsAlpha{i} = f > alpha(1) & f < alpha(2);
        rowsDelta{i} = f > delta(1) & f < delta(2); 
        rowsBeta{i} = f > beta(1) & f < beta(2); 
        rowsGamma{i} = f > gamma(1) & f < gamma(2);      
        
        powerAlpha{1,i}= sum(ps(rowsAlpha{i},:)); 
        powerBeta{1,i} = sum(ps(rowsBeta{i},:)); 
        powerGamma{1,i} = sum(ps(rowsGamma{i},:)); 
        powerDelta{1,i} = sum(ps(rowsDelta{i},:)); 
        powerTheta{1,i} = sum(ps(rowsTheta{i},:)); 
        
    end
   
end 


%works, needs to be rewritten with try catch and without breaktime
%needs a better name since it's downloading the txt data and not read the
%medicin from xls data
%TODO
function getMedicalDataFromExcelSheet(xlsTxtData, medsCell, breaktime)
    import matlab.net.http.*

    for i = 1:length(xlsTxtData)

        % get all the txt file
        creds = Credentials('Username', 'nedc_tuh_eeg', 'Password', 'nedc_tuh_eeg'); 
        options = HTTPOptions('Credentials', creds); 
        url = xlsTxtData{5 + i , 1};
        resp = RequestMessage().send(url, options);

        textHTML = extractHTMLText(resp.Body.Data); 
        %temp save file
        fileID = fopen('temp.txt', 'w'); 
        fprintf(fileID, '%s', resp.Body.Data); 
        fclose(fileID); 

        obj = InformationExtraxtor('temp.txt', 'txt'); 
        meds = extractMedication(obj); 
        medsCell{i+1, 1} = url; 
        medsCell{i+1,2} = meds; 

        pause(breaktime);

    end 

end

%filters out all txt data with soem pattern as a medicament
%from a cellarray (aka big xls file with server folder structure)
% xlsTxtData    extracted drugs data from the txt files for each edf file
% medsCell      cellArray
% pattern       pattern for a drug which should be looked for 
function medsCell = findClozapineInCellArray(xlsTxtData, medsCell, pattern)
    %funcs=functionsForTUHData;
    j = 2; 
    for i = 1:size(xlsTxtData, 1)
        meds = xlsTxtData{i,4};  
        %bClozapineExists = funcs.searchClozapine(meds); 
        bClozapineExists = searchForMedication(meds, pattern);
       if bClozapineExists
            medsCell{j,1} = xlsTxtData{i,1}; 
            medsCell{j,2} = xlsTxtData{i,4};  
            j = j+1; 
        end 
    end 

end 

%find all files (edf and txt) where patient took certain medicine
function medsCell = findFilesWithMedicine(xlsTxtData, pattern)
    j = 1; 
    medsCell={};
    for i = 1:size(xlsTxtData, 1)
        meds = xlsTxtData{i,4};  
        bMedExists = searchForMedication(meds, pattern);
       if bMedExists
            medsCell{j,1} = xlsTxtData{i,1}; 
            medsCell{j,2} = xlsTxtData{i,2};
            medsCell{j,3} = xlsTxtData{i,3};
            medsCell{j,4} = xlsTxtData{i,4}; 
            j = j+1; 
        end 
    end 

end 

%find all files (edf and txt) where patient did not take certain medicine
function medsCell = findFilesWithoutMedicine(xlsTxtData, pattern)
    j = 1; 
    medsCell={};
    for i = 1:size(xlsTxtData, 1)
        meds = xlsTxtData{i,4};  
        type = xlsTxtData{i,3};
        if strcmp(type, 'txt')
            bMedExists = searchForMedication(meds, pattern);
           if ~bMedExists
                medsCell{j,1} = xlsTxtData{i,1}; 
                medsCell{j,2} = xlsTxtData{i,2};
                medsCell{j,3} = xlsTxtData{i,3};
                medsCell{j,4} = xlsTxtData{i,4}; 
                j = j+1; 

           end
        end
    end 

end 

%filters out all folder strings with the same starting substring
%use case: get all subfolders from a patient with a specific medicine 
% cellArray         cell array in which a prefix is to be found
% substring         folder/url prefix string 
%might be buggy, needs more tests
function cellArray = getDataAndSubfoldersFromStringInCellArray(cellArray, substring)

    len = length(substring); 
    cellArray = cellArray(strncmp(substring, cellArray(:,1), len), :);
end


%searches for drugs for a pattern
% medication    original string data in which drug is searched
% pattern       pattern for a drug to be searched for
function medsIntake=searchForMedication(medication, pattern)
    clozapinePatterns=pattern;
    medsIntake=false;
    
    %check what kind of input was given to the function
    if ischar(medication)
        medication = lower(medication); 
    elseif ismissing(medication) || isa(medication, 'double')
        return;  
    else 
        medication=lower(medication{:,:});
    end
    for patternNr=1:size(clozapinePatterns,2)
        if sum(contains(medication,clozapinePatterns(patternNr),'IgnoreCase',true)>0)
            medsIntake=true;
            break;
        end
    end
end

function pattern = getTradeNames(medicine)
    pattern = '';
    %Group AP
    if strcmp(medicine, 'Risperidone')
        pattern = ["risperidone", "risperdal", "perseris", "risperdone"];
    elseif strcmp(medicine, 'Olanzapine')
        pattern = ["zyprexa", "olanzapine"];
    elseif strcmp(medicine, 'Quetiapine')
        pattern = ["quetiapine", "seroquel"];
    elseif strcmp(medicine, 'Aripiprazole')
        pattern = ["aripiprazole", "abilify", "aristada"];
    elseif strcmp(medicine, 'Ziprasidone')
        pattern = ["ziprasidone", "geodon", "zeldox"];
    elseif strcmp(medicine, 'Haloperidol')
        pattern = ["haloperidol", "haldol"];
    elseif strcmp(medicine, 'Amisulpride')
        pattern = ["amisulpride", "barhemsys"];%no entries found!
    elseif strcmp(medicine, 'Paliperidone')
        pattern = ["paliperidone", "invega"];
    elseif strcmp(medicine, 'Cariprazine')
        pattern = ["cariprazine", "vraylar"];
    elseif strcmp(medicine, 'Asenapine')
        pattern = ["asenapin", "saphris", "secuado"];
    elseif strcmp(medicine, 'Benperidol')
        pattern = ["benperidol", "anquil", "frenactil"];
    elseif strcmp(medicine, 'Bromperidol')
        pattern = ["bromperidol", "bromidol", "bromodol"];
    elseif strcmp(medicine, 'Chlorprotixene')
        pattern = ["chlorprotixene", "truxal", "taractan"];
    elseif strcmp(medicine, 'Flupentixole')
        pattern = ["flupentixole", "fluanxol"];
    elseif strcmp(medicine, 'Fluphenazine')
        pattern = ["fluphenazine", "prolixin", "permitil"];
    elseif strcmp(medicine, 'Fluspirilene')
        pattern = ["fluspirilene", "imap"];
    elseif strcmp(medicine, 'Levomepromazine')
        pattern = ["levomepromazine", "methotrimeprazine", "nozinan", "levoprome", "detenler", "hirnamin", "levotomin","neurocil"];
    elseif strcmp(medicine, 'Melperone')
        pattern = ["melperone", "buronil"];
    elseif strcmp(medicine, 'Perazin')
        pattern = ["perazin"];
    elseif strcmp(medicine, 'Perphenazine')
        pattern = ["perphenazine", "trilafon"];
    elseif strcmp(medicine, 'Pimozide')
        pattern = ["pimozide", "orap"];
    elseif strcmp(medicine, 'Pipamperon')
        pattern = ["pipamperon", "carpiperone", "floropipamide", "fluoropipamide", ...
            "dipiperon", "dipiperal", "piperonil", "piperonyl", "propitan"];
    elseif strcmp(medicine, 'Prothipendyl')
        pattern = ["prothipendyl", "dominal", "timovan", "tolnate", "azaphenothiazine", ...
            "phrenotropin"];
    elseif strcmp(medicine, 'Sertindole')
        pattern = ["sertindole", "serdolect"];
    elseif strcmp(medicine, 'Sulpiride')
        pattern = ["sulpiride"];
    elseif strcmp(medicine, 'Thioridazine')
        pattern = ["thioridazine", "mellaril"];
    elseif strcmp(medicine, 'Zuclopenthixol')
        pattern = ["zuclopenthixol", "clopixol"];
    %Group CLZ
    elseif strcmp(medicine, 'Clozapin')
        pattern = ["clozapin","clozaril","clopine","fazaclo"]; 
    %Group AD
    elseif strcmp(medicine, 'Citalopram')
        pattern = ["citalopram", "celexa"];
    elseif strcmp(medicine, 'Escitalopram')
        pattern = ["escitalopram", "lexapro"];
    elseif strcmp(medicine, 'Sertraline')
        pattern = ["sertraline", "zoloft"];
    elseif strcmp(medicine, 'Paroxetine')
        pattern = ["paroxetine", "paxil", "brisdelle", "pexeva"];
    elseif strcmp(medicine, 'Fluoxetine')
        pattern = ["fluoxetine", "prozac", "sarafem", "rapiflux"];
    elseif strcmp(medicine, 'Fluvoxamine')
        pattern = ["fluvoxamine", "luvox"];
    elseif strcmp(medicine, 'Bupropion')
        pattern = ["Bupropion", "Wellbutrin", "Zyban"];
    elseif strcmp(medicine, 'Venlafaxine')
        pattern = ["Venlafaxine", "Effexor"];
    elseif strcmp(medicine, 'Mirtazapine')
        pattern = ["Mirtazapine", "Remeron"];
    elseif strcmp(medicine, 'Trazodone')
        pattern = ["Trazodone", "Desyrel", "Oleptro"];
    elseif strcmp(medicine, 'Agomelatin')
        pattern = ["agomelatin", "melitor", "thymanax", "valdoxan"];
    elseif strcmp(medicine, 'Amitriptyline')
        pattern = ["amitriptyline", "elavil", "endep", "vanatrip"];
    elseif strcmp(medicine, 'Clomipramin')
        pattern = ["clomipramin", "anafranil"];
    elseif strcmp(medicine, 'Doxepin')
        pattern = ["doxepin", "silenor", "sinequan", "adapin"];
    elseif strcmp(medicine, 'Duloxetin')
        pattern = ["duloxetin", "cymbalta", "drizalma", "irenka"];
    elseif strcmp(medicine, 'Imipramin')
        pattern = ["imipramin", "tofranil"];
    elseif strcmp(medicine, 'Maprotilin')
        pattern = ["maprotilin", "ludiomil"];
    elseif strcmp(medicine, 'Mianserin')
        pattern = ["mianserin"];
    elseif strcmp(medicine, 'Milnacipran')
        pattern = ["milnacipran", "Savella"];
    elseif strcmp(medicine, 'Moclobemid')
        pattern = ["moclobemid"];
    elseif strcmp(medicine, 'Nortriptylin')
        pattern = ["nortriptylin", "pamelor", "aventyl"];
    elseif strcmp(medicine, 'Reboxetin')
        pattern = ["reboxetin"];
    elseif strcmp(medicine, 'Tranylcypromin')
        pattern = ["tranylcypromin", "parnate"];
    elseif strcmp(medicine, 'Trimipramin')
        pattern = ["trimipramin", "surmontil"];
    %Group AED
    elseif strcmp(medicine, 'Valproate')
        pattern = ["Valproate", "Depakene", "Depacon", "Stavzor"];
    elseif strcmp(medicine, 'Lamotrigine')
        pattern = ["Lamotrigine", "Lamictal", "Subvenite"];
    elseif strcmp(medicine, 'Carbamazepine')
        pattern = ["Carbamazepine", "Tegretol", "Carbatrol", "Epitol"];
        %pattern = ["Tegretol", "Carbatrol", "Epitol"];
    elseif strcmp(medicine, 'Topiramate')
        pattern = ["Topiramate", "Topamax", "Trokendi", "Qudexy"];
        %pattern = ["Topamax", "Trokendi", "Qudexy"];
    elseif strcmp(medicine, 'Levetiracetam')
        pattern = ["Levetiracetam", "Elepsia", "Keppra", "Roweepra", "Spritam"];
        %pattern = ["Elepsia", "Keppra", "Roweepra", "Spritam"];
    %Group Li
    elseif strcmp(medicine, 'Lithium')
        pattern = ["Lithium", "Lithobid", "Eskalith", "Lithonate"];
        %pattern = ["Lithobid", "Eskalith", "Lithonate"];
    %Group BDZ
    elseif strcmp(medicine, 'Lorazepam')
        pattern = ["Lorazepam", "Ativan"];
        %pattern = ["Ativan"];
    elseif strcmp(medicine, 'Clonazepam')
        pattern = ["Clonazepam", "Klonopin"];
        %pattern = ["Klonopin"];
    elseif strcmp(medicine, 'Diazepam')
        pattern = ["Diazepam", "Valium", "Valtoco", "Diastat"];
        %pattern = ["Valium", "Valtoco", "Diastat"];
    elseif strcmp(medicine, 'Alprazolam')
        pattern = ["Alprazolam", "Xanax", "Niravam"];
        %pattern = ["Xanax", "Niravam"];
    else
        return;
    end
end
