%to be able to call single functions from this script 
function funcEEGData = visualizeEEGData
  funcEEGData.calcAllFreqAllChannel=@calcAllFreqAllChannel;%old
  funcEEGData.calculatePowerForBands=@calculatePowerForBands;%old
  funcEEGData.calcPValueAndMore=@calcPValueAndMore;
  funcEEGData.calcPValueAndMoreWithSampling=@calcPValueAndMoreWithSampling;
  funcEEGData.visualizePValues=@visualizePValues;
  funcEEGData.calcDifferenceOfMeans=@calcDifferenceOfMeans;
  funcEEGData.barhGraph=@barhGraph;
  funcEEGData.createCompleteDrugsList=@createCompleteDrugsList;
  funcEEGData.countUniqueWords=@countUniqueWords;
  funcEEGData.setUpChannelsFrequencies=@setUpChannelsFrequencies;
end

% calculates accumulating power data for all frequencies and all channels 
% folder    name of the folder with xlsx files containing power density data
% filename  filename in which the function output data should be saved in 
function calcAllFreqAllChannel(folder, filename)
    
    funcs = functionsForTUHData; 
    list = funcs.createFileList('xlsx',folder);
    data = {}; 
    k = 1;
    
    %setup all channel and frequency names
    [channels, frequencies] = setUpChannelsFrequencies;
    %loop through all of them, takes a lot of time if the file list is long
    for i = 1:length(channels)
        for j= 1:length(frequencies)

            text = strcat(channels{i}, '_', frequencies{j});
            data{1,k} = text;
            
            %use createDataClozapine function if clozapine is calculated 
            x = table2cell(createData(list, channels{i}, frequencies{j}));
            data(2:length(x)+1,k) = x(1:length(x),1);
            
            str = strcat(channels{i},'_', frequencies{j}, '_____', int2str(k) , '/', int2str(19*5), '_done');
            k = k+1;
            disp(str);
        end

    end

    writecell(data, filename);
end

% calculates accumulating power data for one channel with one frequency 
% list      list of xlsx files
% channel   channel name e.g. F4, O1,...
% frequency freq name e.g. powerAlpha, powerBeta
function returnData = createData(list, channel, frequency)

    logical = not( cellfun( @isempty, strfind( list, frequency) ) ); 
    listFrequency = list(logical, :); %returns all xlsx files for certain frequency
    
    logical = not( cellfun( @isempty, strfind( list, 'channelData') ) );
    listChannel = list(logical,:);
    
    cellArrayData{1,1} = [];
    for i= 1:length(listFrequency)
        %channel
        dataChannel = readcell(listChannel{i});
        index = find(contains(dataChannel, channel));
        
        if length(index) > 1
            index = index(1,1);
        elseif length(index) == 0
            continue; 
        end
        
        %frequency
        data = readcell(listFrequency{i}); 
        mat = cell2mat(data);
        meanData = mean(mat,1); %returns row vector containing the mean of each column

        data = mat2cell(meanData, 1, length(meanData));
        temp = num2cell(data{1,1});
        cellArrayData(i,1) = temp(index);  
    end
    
        returnData = cell2table(cellArrayData); 
        
end

% calculates accumulating power data for one channel with one frequency 
% special function to deal with some of the clozapine files
% it was faster to hardcode for Clozapine than to rewirte the function 

% list      list of xlsx files
% channel   channel name e.g. F4, O1,...
% frequency freq name e.g. powerAlpha, powerBeta

% TODO  rewrite function to check for files with several parts (e.g. xxxx_t000.edf xxxx_t001.edf)
function returnData = createDataClozapine(list, channel, frequency)

    logical = not( cellfun( @isempty, strfind( list, frequency) ) ); 
    listFrequency = list(logical, :); 
    
    logical = not( cellfun( @isempty, strfind( list, 'channelData') ) );
    listChannel = list(logical,:);
    
    
    cellArrayData{1,1} = [];
    for i= 1:length(listFrequency)
        %channel
        dataChannel = readcell(listChannel{i});
        index = find(contains(dataChannel, channel));
        
        if length(index) > 1
            index = index(1,1);
        elseif length(index) == 0
            continue; 
        end
        
        %frequency
        data = readcell(listFrequency{i}); 
        mat = cell2mat(data);
        meanData = mean(mat,1); 

        data = mat2cell(meanData, 1, length(meanData));
        temp = num2cell(data{1,1});
        cellArrayData(i,1) = temp(index);  
    end
    
    clozapineArray = {}; 
    clozapineArray(1,1) = cellArrayData(1); %3264
   
    clozapineArray(2,1) = num2cell(mean(cell2mat(cellArrayData(2:3,:)))); %5019
    
    %5021
    clozapineArray(3,:) = num2cell(mean(cell2mat(cellArrayData(4:5,:))));
    
    clozapineArray(4:9,:) = cellArrayData(6:11,:); %5894, 5931, 9063, 9270, 9509, 10943
    
    %11905
    clozapineArray(10,:) = num2cell(mean(cell2mat(cellArrayData(12:13,:))));
    
    %12438_s2
    clozapineArray(11,:) = num2cell(mean(cell2mat(cellArrayData(14:15,:))));
    
    %12438_s3
    clozapineArray(12,:) = num2cell(mean(cell2mat(cellArrayData(16:26,:))));
    
    %12438_s4
    clozapineArray(13,:) = num2cell(mean(cell2mat(cellArrayData(27:29,:))));
    
    %14388
    clozapineArray(14,:) = num2cell(mean(cell2mat(cellArrayData(30:31,:))));
    
    returnData = cell2table(clozapineArray);
        
end

%  calculates the power spectral density for a list of edf files
%  list         List of edf files with folder paths 
%  windowSize   window size for the time data in the edf files, e.g. 1s
%  overlapSize  overlap between the windows, e.g. 0,5sec
%  removeArtifacts  if true, artifacts are being removed in eeg data
function calculatePowerForBands(list, windowSize, overlapSize, removeArtifacts)

    for i = 1:length(list)
        %get folder path for the file
        %folder path seperator in here \ not / 
        temp = strsplit(list{i}, '\'); 
        filename = temp(end); 
        temp(end) = '';
        folderpath = strcat(strjoin(temp, '\'), '\'); 

        %read edf file
        EEGData = pop_biosig(list{i},'importevent','off','importannot','off'); 
        if removeArtifacts == true
            EEGData = clean_artifacts(EEGData);
        end
        srate = EEGData.srate;

        %calculate power spectral density 
        eegFunctions = scriptWorkWithExcelData;    
        [powerAlpha, powerTheta, powerDelta, powerBeta, powerGamma, times] = eegFunctions.createBrainwaves(EEGData.data,srate,windowSize,overlapSize);

        %saved in txt file for each edf file 
        %transpose cellArrays, otherwise too many columns
        t_powerAlpha = cellfun(@transpose, powerAlpha, 'UniformOutput', false); 
        t_powerBeta = cellfun(@transpose, powerBeta, 'UniformOutput', false);
        t_powerGamma = cellfun(@transpose, powerGamma, 'UniformOutput', false);
        t_powerDelta = cellfun(@transpose, powerDelta, 'UniformOutput', false);
        t_powerTheta = cellfun(@transpose, powerTheta, 'UniformOutput', false);

        %only has one row/column
        t_times = transpose(times);
        writematrix(t_times,strcat(folderpath, filename{1}, '_times.xlsx'));
        
        %save channel data
        channelData = struct2cell(EEGData.chanlocs);
        channelData = channelData(1,:); 
        writecell(channelData, strcat(folderpath, filename{1}, '_channelData.xlsx'));
        
        
        %all power channels have the same size
        %write powers into excel files, xlsx file type is a must since
        %available dimensions in xls are too small
        for j = 1: size(powerAlpha, 2)
            %TODO test if I can write all data into one xls file and not several
            column = strcat(xlscol(j), '1'); 
            writematrix(t_powerAlpha{j}, strcat(folderpath, filename{1}, '_powerAlpha.xlsx'), 'Range', column);
            writematrix(t_powerBeta{j}, strcat(folderpath, filename{1}, '_powerBeta.xlsx'), 'Range', column);
            writematrix(t_powerGamma{j}, strcat(folderpath, filename{1}, '_powerGamma.xlsx'),  'Range', column);
            writematrix(t_powerDelta{j}, strcat(folderpath, filename{1}, '_powerDelta.xlsx'),  'Range', column);
            writematrix(t_powerTheta{j}, strcat(folderpath, filename{1}, '_powerTheta.xlsx'),  'Range', column);

        end 
    end 
end 

% calculates statistics for normal and medical data
% dataNormal   accumulated power data for normal set           
% dataMeds     accumulated power data for drug set
% nameMeds     name of the medicine from the dataMeds set
function calcPValueAndMore(dataNormal, dataMeds, nameMeds)

    data = {};
    
    %remove rows with values > 100
%     for j=1:size(dataNormal,2)
%         dataNormal(dataNormal{:, j}>100, :)= [];
%     end
%     for j=1:size(dataMeds,2)
%         dataMeds(dataMeds{:, j}>100, :)= [];
%     end

    %remove outliers of entire matrix 
    dataN = rmoutliers(dataNormal, 'mean');
    dataM = rmoutliers(dataMeds, 'mean');
    
    %dataN=dataNormal;
    %dataM=dataMeds;
    
    %save data
    fileName = strcat('Results/',nameMeds, '_powerspectrum_rmoutliers.xls'); 
    writetable(dataM, fileName); 
    fileName = strcat('Results/Normal_powerspectrum_rmoutliers.xls'); 
    writetable(dataN, fileName); 

    for i = 1:size(dataNormal,2)
        normal = dataN(:, i);
        meds = dataM(:,i);
        %datatype: matrix
        normal = normal{:,:};
        meds = meds{:,:};
              
        %check if channel and frequency are the same 
        %should always be the same 
        if strcmp(dataN.Properties.VariableNames{i}, dataM.Properties.VariableNames{i})

            %after every 5th set we have enough data to calcuate alpha/band
            %and alpha/theta
            x = mod(i,5);
            switch x
                case 1
                    alphaNormal =  (normal);
                    alphaMeds = (meds); 
                case 2
                    betaNormal = (normal);
                    betaMeds = (meds);
                case 3
                    gammaNormal = (normal);
                    gammaMeds = (meds);
                case 4
                    deltaNormal = (normal);
                    deltaMeds = (meds);
                case 0
                    thetaNormal = (normal);
                    thetaMeds = (meds);
                    
                    data{1,6} = 'alpha/theta mean Normal';
                    normalAT = alphaNormal./thetaNormal;
                    data{i+1,6} = mean(normalAT,'omitnan'); 
                    
                    data{1,7} = strcat('alpha/theta mean', nameMeds);
                    medsAT = alphaMeds./thetaMeds;
                    data{i+1,7} = mean(medsAT,'omitnan');
                    
                    [h,p] = ttest2(normalAT, medsAT);
                    data{1,8} = strcat('alpha/theta pvalue', nameMeds);
                    data{i+1,8} = p;
                    
                    
                    data{1,9} = 'alpha/band mean Normal';
                    %calculate first otherwise dimenions might not work out
                    normalAB = alphaNormal./(alphaNormal + betaNormal + gammaNormal + deltaNormal + thetaNormal);

                    data{i+1,9} = mean(normalAB,'omitnan');
                   
                    data{1,10} = strcat('alpha/band mean', nameMeds);
                    %calculate first otherwise dimenions might not work out
                    medsAB = alphaMeds./(alphaMeds + betaMeds + gammaMeds + deltaMeds + thetaMeds);
                    data{i+1,10} = mean(medsAB,'omitnan');
                    
                    [h,p] = ttest2(normalAB, medsAB);
                    data{1,11} = 'alpha/band pValue';
                    data{i+1,11} = p;
                   
                    normalBB = betaNormal./(alphaNormal + betaNormal + gammaNormal + deltaNormal + thetaNormal);

                    medsBB = betaMeds./(alphaMeds + betaMeds + gammaMeds + deltaMeds + thetaMeds);

                    [h,p] = ttest2(normalBB, medsBB);

                    data{1,15} = 'beta/band pValue';
                    data{i+1,15} = p;

                    normalGB = gammaNormal./(alphaNormal + betaNormal + gammaNormal + deltaNormal + thetaNormal);

                    medsGB = gammaMeds./(alphaMeds + betaMeds + gammaMeds + deltaMeds + thetaMeds);                  

                    [h,p] = ttest2(normalGB, medsGB);

                    data{1,16} = 'gamma/band pValue';
                    data{i+1,16} = p;

                    normalDB = deltaNormal./(alphaNormal + betaNormal + gammaNormal + deltaNormal + thetaNormal);

                    medsDB = deltaMeds./(alphaMeds + betaMeds + gammaMeds + deltaMeds + thetaMeds);                   

                    [h,p] = ttest2(normalDB, medsDB);

                    data{1,17} = 'delta/band pValue';
                    data{i+1,17} = p; 

                    normalTB = thetaNormal./(alphaNormal + betaNormal + gammaNormal + deltaNormal + thetaNormal);

                    medsTB = thetaMeds./(alphaMeds + betaMeds + gammaMeds + deltaMeds + thetaMeds);                    %medsTB = rmoutliers(medsTB, 'percentiles', [0 outlierPercentageMeds]);                   

                    [h,p] = ttest2(normalTB, medsTB);

                    data{1,18} = 'theta/band pValue';
                    data{i+1,18} = p; 

                otherwise
                    disp('not supposed to reach this');
            end
            %save values            
            [h,p] = ttest2(normal, meds);

            data{1,1} = 'Channel_Frequency';
            data{i+1,1} = dataN.Properties.VariableNames{i};

            data{1,2} = strcat('pValue ', nameMeds, ' & normal');
            data{i+1,2} = p;

            data{1,3} = 'data points normal';
            data{i+1,3} = size(normal,1);

            data{1,4} = 'mean normal';
            data{i+1,4} = mean(normal,'omitnan');         

            data{1,5} = 'std normal'; 
            data{i+1,5} = std(normal,'omitnan');         
            
            data{1,12} = strcat('data points ', nameMeds);
            data{i+1,12} = size(meds,1);       

            data{1,13} = strcat('mean ', nameMeds);
            data{i+1,13} = mean(meds,'omitnan'); 

            data{1,14} = strcat('std ', nameMeds);
            data{i+1,14} = std(meds,'omitnan'); 
            
            
        end

    end
    
    fileName = strcat('Results/',nameMeds, '_normal_data.xls'); 
    data = cell2table(data);
    writetable(data, fileName); 

end

% calculates statistics for normal and medical data with sampling
% dataNormal   accumulated power data for normal set           
% dataMeds     accumulated power data for drug set
% nameMeds     name of the medicine from the dataMeds set
% outlierPercentageNormal percentage to remove outliers for normal set e.g. 95
% outlierPercentageMeds   percentage to remove outliers for drug set e.g. 95
function calcPValueAndMoreWithSampling(dataNormal, dataMeds, nameMeds, timesSampling, outlierPercentageNormal, ourlierPercentageMeds)
    
    %lots of set ups
    data = {};
    pValueNormalMeds(1:95) = num2cell(0);
    
    %temporary data for one sampling step 
    tempData = {}; 
    %fill out first row 
    tempData{1,1} = 'alpha/theta mean Normal';
    tempData{1,2} = strcat('alpha/theta mean ', nameMeds);
    tempData{1,3} = strcat('alpha/theta pvalue ', nameMeds);
    tempData{1,4} = 'alpha/band mean Normal';
    tempData{1,5} = strcat('alpha/band mean', nameMeds);
    tempData{1,6} = 'alpha/band pValue';
    tempData{1,7} = 'beta/band pValue';
    tempData{1,8} = 'gamma/band pValue';
    tempData{1,9} = 'delta/band pValue';
    tempData{1,10} = 'theta/band pValue';
    %fill out with zeros, otherwise we get data type errors during calculation
    tempData(2:20, 1:10) = num2cell(0);
    
    sampleDataNormal = dataNormal;
    %remove first line with string data, since it could get chosen by
    %randsample and calc won't be possible with string data in it
    sampleDataNormal(1,:) = [];     
    
    %todo: remove outliers! Maybe not here?
%     dataMeds(1,:) = [];
%     
%     sampleDataNormal = cell2mat(sampleDataNormal); 
%     dataMeds = cell2mat(dataMeds);
%     
%     sampleDataNormal = rmoutliers(sampleDataNormal, 'mean');
%     dataMeds = rmoutliers(dataMeds, 'mean');
   
    for j = 1:timesSampling
     
        % pick random sample of the size of the medicine from normal set
        y = randsample(size(sampleDataNormal,1),size(dataMeds,1));
        data = sampleDataNormal(y,:); 
       
        counter = 1; 
        len = size(dataNormal,2); 
        % calc all values concerning p values
        for i = 1:len
            normal = {};
            meds = {};

            normal = cell2mat(data(2:size(data,1), i));
            meds = cell2mat(dataMeds(2:size(dataMeds,1),i));   
            
            %check if channel and frequency are the same 
            %should always be the same 
            channelNormal = dataNormal(1,i);
            channelMeds = dataMeds(1,i);
            if strcmp(channelNormal, channelMeds)
                %after every 5th set we have enough data to calcuate alpha/band
                %and alpha/theta
                x = mod(i,5);         
                switch x
                    case 1
                        alphaNormal = (normal);
                        alphaMeds = (meds); 
                    case 2
                        betaNormal = (normal);
                        betaMeds = (meds);
                    case 3
                        gammaNormal = (normal);
                        gammaMeds = (meds);
                    case 4
                        deltaNormal = (normal);
                        deltaMeds = (meds);
                    case 0
                        thetaNormal = (normal);
                        thetaMeds = (meds);
                        counter = counter +1; 
                        
                        
                        %sum up all the sampling data, we calculate the
                        %mean in the next loop, 
                        %TODO find a more elegant version around
                        normalAT = alphaNormal./thetaNormal;
                        normalAT = rmoutliers(normalAT, 'percentiles', [0 outlierPercentageNormal]);%todo: braucht man das hier?
                        tempData{counter,1} = tempData{counter,1} + mean(normalAT(~isnan(normalAT))); 
                        
                        medsAT = alphaMeds./thetaMeds;
                        medsAT = rmoutliers(medsAT, 'percentiles', [0 ourlierPercentageMeds]);
                        tempData{counter,2} = tempData{counter,2} + mean(medsAT(~isnan(medsAT)));

                        [h,p] = ttest2(normalAT, medsAT);
                        tempData{counter,3} = tempData{counter,3}+p;
                        
                        normalAB = alphaNormal./(alphaNormal + betaNormal + gammaNormal + deltaNormal + thetaNormal);
                        normalAB = rmoutliers(normalAB, 'percentiles', [0 outlierPercentageNormal]);
                        tempData{counter,4} = tempData{counter,4} + mean(normalAB(~isnan(normalAB)));
                        
                        medsAB = alphaMeds./(alphaMeds + betaMeds + gammaMeds + deltaMeds + thetaMeds);
                        medsAB = rmoutliers(medsAB, 'percentiles', [0 ourlierPercentageMeds]);
                        tempData{counter,5} = tempData{counter,5}+ mean(medsAB(~isnan(medsAB)));

                        [h,p] = ttest2(normalAB, medsAB);
                        
                        tempData{counter,6} = tempData{counter,6} + p;
                        
                        normalBB = betaNormal./(alphaNormal + betaNormal + gammaNormal + deltaNormal + thetaNormal);
                        normalBB = rmoutliers(normalBB, 'percentiles', [0 outlierPercentageNormal]);
                        
                        medsBB = betaMeds./(alphaMeds + betaMeds + gammaMeds + deltaMeds + thetaMeds);
                        medsBB = rmoutliers(medsBB, 'percentiles', [0 ourlierPercentageMeds]);
                        
                        [h,p] = ttest2(normalBB, medsBB);
                        
                        tempData{counter,7} = tempData{counter,7} + p;
                        
                        normalGB = gammaNormal./(alphaNormal + betaNormal + gammaNormal + deltaNormal + thetaNormal);
                        normalGB = rmoutliers(normalGB, 'percentiles', [0 outlierPercentageNormal]);
                        
                        medsGB = gammaMeds./(alphaMeds + betaMeds + gammaMeds + deltaMeds + thetaMeds);
                        medsGB = rmoutliers(medsGB, 'percentiles', [0 ourlierPercentageMeds]);                   
                        
                        [h,p] = ttest2(normalGB, medsGB);
                        
                        tempData{counter,8} = tempData{counter,8} + p;
 
                        normalDB = deltaNormal./(alphaNormal + betaNormal + gammaNormal + deltaNormal + thetaNormal);
                        normalDB = rmoutliers(normalDB, 'percentiles', [0 outlierPercentageNormal]);
                        
                        medsDB = deltaMeds./(alphaMeds + betaMeds + gammaMeds + deltaMeds + thetaMeds);
                        medsDB = rmoutliers(medsDB, 'percentiles', [0 ourlierPercentageMeds]);                   
                        
                        [h,p] = ttest2(normalDB, medsDB);
                        
                        tempData{counter,9} = tempData{counter, 9} + p; 
                        
                        normalTB = thetaNormal./(alphaNormal + betaNormal + gammaNormal + deltaNormal + thetaNormal);
                        normalTB = rmoutliers(normalTB, 'percentiles', [0 outlierPercentageNormal]);
                        
                        medsTB = thetaMeds./(alphaMeds + betaMeds + gammaMeds + deltaMeds + thetaMeds);
                        medsTB = rmoutliers(medsTB, 'percentiles', [0 ourlierPercentageMeds]);                   
                        
                        [h,p] = ttest2(normalTB, medsTB);
                        
                        tempData{counter,10} = tempData{counter, 10} + p; 
                        
                        
                        
                    otherwise
                        disp('not supposed to reach this');
                end %switch
                

            
            normal = rmoutliers(normal, 'percentiles', [0 outlierPercentageNormal]);
            meds = rmoutliers(meds, 'percentiles', [0 ourlierPercentageMeds]);

            [h,p] = ttest2(normal, meds);
            pValueNormalMeds{i} = pValueNormalMeds{i} + p;
            test{j, i} = p; 
            
            else
                disp('visualizeEEGData:calcPValueAndMoreWithSampling: channels do not match!');
            end %if            
            
        end %for i

    end %for j
    
    %reset data cell array and counter
    data = {}; 
    counter = 1; 
    
    % calc the rest of the statistics and fill in pvalue data from previous
    % loop
    for i = 1:size(dataNormal,2)

        normal = {};
        meds = {};

        normal = cell2mat(dataNormal(2:size(dataNormal,1), i));
        meds = cell2mat(dataMeds(2:size(dataMeds,1),i)); 

            if strcmp(dataNormal(1,i), dataMeds(1,i))

                x = mod(i,5);
                if x == 0 
                    counter = counter + 1;
                    % enter sampling numbers divided by times of sampling
                    % aka mean of the sampling data
                    
                    data{1,6} = 'alpha/theta mean Normal';
                    data{i+1,6} = tempData{counter,1}/timesSampling; 

                    data{1,7} = strcat('alpha/theta mean_', nameMeds);
                    data{i+1,7} = tempData{counter,2}/timesSampling; 

                    data{1,8} = strcat('alpha/theta pvalue_', nameMeds);
                    data{i+1,8} = tempData{counter,3}/timesSampling;

                    data{1,9} = 'alpha/band mean Normal';
                    data{i+1,9} = tempData{counter,4}/timesSampling;

                    data{1,10} = strcat('alpha/band mean', nameMeds);
                    data{i+1,10} = tempData{counter,5}/timesSampling;

                    data{1,11} = 'alpha/band pValue';
                    data{i+1,11} = tempData{counter,6}/timesSampling;
                    
                    data{1, 15} = 'beta/band pValue';
                    data{i+1, 15} = tempData{counter, 7}/timesSampling; 
                    
                    data{1, 16} = 'gamma/band pValue';
                    data{i+1, 16} = tempData{counter, 8}/timesSampling;
                    
                    data{1, 17} = 'delta/band pValue';
                    data{i+1, 17} = tempData{counter, 9}/timesSampling;
                    
                    data{1, 18} = 'theta/band pValue';
                    data{i+1, 18} = tempData{counter, 10}/timesSampling;
                    
                end             

                normal = rmoutliers(normal, 'percentiles', [0 outlierPercentageNormal]);
                meds = rmoutliers(meds, 'percentiles', [0 ourlierPercentageMeds]);

                data{1,1} = 'Channel_Frequency';
                data{i+1,1} = dataNormal(1,i);

                data{1,2} = strcat('pValue_', nameMeds, ' & normal');
                data{i+1,2} = pValueNormalMeds{1,i}/timesSampling;

                data{1,3} = 'data points normal';
                data{i+1,3} = size(normal,1);

                data{1,4} = 'mean normal';
                data{i+1,4} = mean(normal);         

                data{1,5} = 'std normal'; 
                data{i+1,5} = std(normal);         

                data{1,12} = strcat('data points_', nameMeds);
                data{i+1,12} = size(meds,1);       

                data{1,13} = strcat('mean_', nameMeds);
                data{i+1,13} = mean(meds); 

                data{1,14} = strcat('std_', nameMeds);
                data{i+1,14} = std(meds); 


            end

    end
    
    %save calcualted data into an excel sheet   
    fileName = strcat(nameMeds, '_normal_data_sampling_201110.xls'); 
    data = cell2table(data);
    writetable(data, fileName); 
end

%setup function for used strings for channels and frequencies 
function [channels, frequencies] = setUpChannelsFrequencies()

    %constants 
    %channels of EDF files/EEG Data
    channels{1} = 'FP1';
    channels{2} = 'FP2';
    channels{3} = 'F3';
    channels{4} = 'F4';
    channels{5} = 'C3'; 
    channels{6} = 'C4';
    channels{7} = 'P3';
    channels{8} = 'P4';
    channels{9} = 'O1';
    channels{10} = 'O2';
    channels{11} = 'F7';
    channels{12} = 'F8';
    channels{13} = 'T3';
    channels{14} = 'T4';
    channels{15} = 'T5';
    channels{16} = 'T6';
    channels{17} = 'FZ';
    channels{18} = 'CZ';
    channels{19} = 'PZ';

    %frequencies extracted from EDF files/EEG Data
    frequencies{1} = 'powerAlpha';
    frequencies{2} = 'powerBeta';
    frequencies{3} = 'powerGamma';
    frequencies{4} = 'powerDelta';
    frequencies{5} = 'powerTheta';


end

%draws the plots for pvalue data
% dataPValue    cellarray, calculated data from calcPValueAndMore functions output
% bAT           adjust function for alpha/theta output
% bAbsolut      adjust function for absolut or relative value output
% sFigureName   Headline for figure output
function visualizePValues(dataPValue, bAbsolut, sFigureName)

    fig = figure('Name', sFigureName, 'visible','off'); 

    %for alpha, beta, gamma/alpha by theta, delta, theta 
    for i = 1:7
        
        freq = ''; 
   
        subplot(2, 4, i);
        switch i
            case 1
                freq = 'Alpha';
            case 2
                freq = 'Beta';
            case 3
                %if bAT
                 %   freq = 'A/T';
                %else
                    freq = 'Gamma';
                %end
            case 4
                text(0, 0.4, sFigureName);
                text(0, 0.3, 'number of patients');
                numberNormal = dataPValue(3,3);
                numberNormal = num2str(numberNormal{1});
                text(0, 0.2, strcat('normal group: ',numberNormal));
                numberDrug = dataPValue(3,12);
                text(0, 0.1, strcat('drug group: ',numberDrug));
             	set(gca, 'xtick', [], 'YColor', 'none'); 
                freq='none';
            case 5
                freq = 'Delta';
            case 6
                freq = 'Theta';
            case 7
                freq = 'A/T';
            otherwise
                disp('error switch case visualizePValue')
        end
        if ~strcmp(freq,'none')
            plotFace(dataPValue, freq, bAbsolut)
        end

    end
   
    %legend subplot
    subplot(2,4,8);
    plotLegend();
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 45 25]);
    %savefig(strcat('Results/',sFigureName));
    saveas(fig, strcat('Results/',sFigureName, '.png'));
end

function plotFace(dataPValue, freq, bAbsolut)
    %nose circle
    r = 0.25; 
    c = [3,5];
    pos = [c-r 2*r 2*r];
    rectangle('Position',pos,'Curvature',[1 1]);

    %big head circle
    r = 2; %// radius
    c = [3 3]; %// center
    pos = [c-r 2*r 2*r];
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', 'white');

    %FP1 circle
    r = 0.25; 
    c = [2.5,4.5];
    pos = [c-r 2*r 2*r];

    pValue = getPValueFromCellArray(dataPValue, 'FP1', freq, bAbsolut);

    color = getColorForPValue(pValue);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(2.35, 4.5, 'FP1');

    %FP2 circle
    r = 0.25; 
    c = [3.5,4.5];
    pos = [c-r 2*r 2*r]; 
    pValue = getPValueFromCellArray(dataPValue, 'FP2', freq, bAbsolut);
    color = getColorForPValue(pValue);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(3.35, 4.5, 'FP2');

    %F7 circle
    r = 0.25; 
    c = [1.75,4];
    pos = [c-r 2*r 2*r];

    pValue = getPValueFromCellArray(dataPValue, 'F7', freq, bAbsolut);
    color = getColorForPValue(pValue);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(1.65, 4, 'F7');

    %F3 circle
    r = 0.25; 
    c = [2.35,3.75];
    pos = [c-r 2*r 2*r];

    pValue = getPValueFromCellArray(dataPValue, 'F3', freq, bAbsolut);
    color = getColorForPValue(pValue);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(2.25, 3.75, 'F3');

    %Fz circle
    r = 0.25; 
    c = [3,3.75];
    pos = [c-r 2*r 2*r];

    pValue = getPValueFromCellArray(dataPValue, 'FZ', freq, bAbsolut);
    color = getColorForPValue(pValue);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(2.9, 3.75, 'Fz');

    %F4 circle
    r = 0.25; 
    c = [3.6,3.75];
    pos = [c-r 2*r 2*r];

    pValue = getPValueFromCellArray(dataPValue, 'F4', freq, bAbsolut);
    color = getColorForPValue(pValue);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(3.5, 3.75, 'F4');

    %F8 circle
    r = 0.25; 
    c = [4.25,4];
    pos = [c-r 2*r 2*r];

    pValue = getPValueFromCellArray(dataPValue, 'F8', freq, bAbsolut);
    color = getColorForPValue(pValue);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(4.15, 4, 'F8');

    %T3 circle
    r = 0.25; 
    c = [1.5,3];
    pos = [c-r 2*r 2*r];


    pValue = getPValueFromCellArray(dataPValue, 'T3', freq, bAbsolut);
    color = getColorForPValue(pValue);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(1.4, 3, 'T3');

    %C3 circle
    r = 0.25; 
    c = [2.2,3];
    pos = [c-r 2*r 2*r];

    pValue = getPValueFromCellArray(dataPValue, 'C3', freq, bAbsolut);
    color = getColorForPValue(pValue);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(2.1, 3, 'C3');

    %Cz circle
    r = 0.25; 
    c = [3,3];
    pos = [c-r 2*r 2*r];

    pValue = getPValueFromCellArray(dataPValue, 'CZ', freq, bAbsolut);
    color = getColorForPValue(pValue);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(2.9, 3, 'Cz');

    %C4 circle
    r = 0.25; 
    c = [3.8,3];
    pos = [c-r 2*r 2*r];

    pValue = getPValueFromCellArray(dataPValue, 'C4', freq, bAbsolut);
    color = getColorForPValue(pValue);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(3.7, 3, 'C4');

    %T4 circle
    r = 0.25; 
    c = [4.5,3];
    pos = [c-r 2*r 2*r];

    pValue = getPValueFromCellArray(dataPValue, 'T4', freq, bAbsolut);
    color = getColorForPValue(pValue);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(4.4, 3, 'T4');

    %T5 circle
    r = 0.25; 
    c = [1.75,2];
    pos = [c-r 2*r 2*r];

    pValue = getPValueFromCellArray(dataPValue, 'T5', freq, bAbsolut);
    color = getColorForPValue(pValue);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(1.65, 2, 'T5');

    %P3 circle
    r = 0.25; 
    c = [2.35,2.25];
    pos = [c-r 2*r 2*r];

    pValue = getPValueFromCellArray(dataPValue, 'P3', freq, bAbsolut);
    color = getColorForPValue(pValue);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(2.25, 2.25, 'P3');

    %Pz circle
    r = 0.25; 
    c = [3,2.25];
    pos = [c-r 2*r 2*r];

    pValue = getPValueFromCellArray(dataPValue, 'PZ', freq, bAbsolut);
    color = getColorForPValue(pValue);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(2.9, 2.25, 'Pz');

    %P4 circle
    r = 0.25; 
    c = [3.6,2.25];
    pos = [c-r 2*r 2*r];

    pValue = getPValueFromCellArray(dataPValue, 'P4', freq, bAbsolut);
    color = getColorForPValue(pValue);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(3.5, 2.25, 'P4');

    %T6 circle
    r = 0.25; 
    c = [4.25,2];
    pos = [c-r 2*r 2*r];

    pValue = getPValueFromCellArray(dataPValue, 'T6', freq, bAbsolut);
    color = getColorForPValue(pValue);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(4.15, 2, 'T6');

    %O1 circle
    r = 0.25; 
    c = [2.5,1.5];
    pos = [c-r 2*r 2*r];

    pValue = getPValueFromCellArray(dataPValue, 'O1', freq, bAbsolut);
    color = getColorForPValue(pValue);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(2.4, 1.5, 'O1');

    %O2 circle
    r = 0.25; 
    c = [3.5,1.5];
    pos = [c-r 2*r 2*r];

    pValue = getPValueFromCellArray(dataPValue, 'O2', freq, bAbsolut);
    color = getColorForPValue(pValue);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(3.4, 1.5, 'O2');

    axis equal;
    xlabel(freq); 
    set(gca, 'xtick', [], 'YColor', 'none'); 
end

function plotLegend()
    width=0.55;
    % positive p values -> red hue
    color = getColorForPValue(0.0001); 
    rectangle('Position', [1, 1, width, 0.5], 'FaceColor', color); 
    text(1.01, 1.25, 'Increase, p < 0.001');
    
    color = getColorForPValue(0.005); 
    rectangle('Position', [1, 1.5, width, 0.5], 'FaceColor', color); 
    text(1.01, 1.75, 'Increase, p < 0.01');
    
    color = getColorForPValue(0.04); 
    rectangle('Position', [1, 2, width, 0.5], 'FaceColor', color);
    text(1.01, 2.25, 'Increase, p < 0.05');
    
    color = getColorForPValue(0.06); 
    rectangle('Position', [1, 2.5, width, 0.5], 'FaceColor', color); 
    text(1.01, 2.75, 'Increase, p < 0.1');
    
    color = getColorForPValue(0.15); 
    rectangle('Position', [1,3, width, 0.5], 'FaceColor',color);
    text(1.01, 3.25, 'Increase, p > 0.1');
    
    %color = getColorForPValue(0.5); 
    %rectangle('Position', [1,3, width, 0.5], 'FaceColor',color); 
    %text(1.01, 3.25, 'Increase, 0.2 < p'); 
    
    % negative p values -> blue hue
    color = getColorForPValue(-0.0001); 
    rectangle('Position', [1.6, 1, width, 0.5], 'FaceColor', color); 
    text(1.61, 1.25, 'Decrease, p < 0.001');
    
    color = getColorForPValue(-0.001); 
    rectangle('Position', [1.6, 1.5, width, 0.5], 'FaceColor', color);  
    text(1.61, 1.75, 'Decrease, p < 0.01');
    
    color = getColorForPValue(-0.04); 
    rectangle('Position', [1.6, 2, width, 0.5], 'FaceColor', color);  
    text(1.61, 2.25, 'Decrease, p < 0.05');
    
    color = getColorForPValue(-0.06); 
    rectangle('Position', [1.6, 2.5, width, 0.5], 'FaceColor', color); 
    text(1.61, 2.75, 'Decrease, p < 0.1');
    
    color = getColorForPValue(-0.15); 
    rectangle('Position', [1.6, 3, width, 0.5], 'FaceColor', color); 
    text(1.61, 3.25, 'Decrease, p > 0.1');
    
    %color = getColorForPValue(-0.5); 
    %rectangle('Position', [1.6, 3, width, 0.5], 'FaceColor', color); 
    %text(1.61, 3.25, 'Decrease, 0.2 < p'); 
    
    xlabel('Legend'); 
    set(gca, 'xtick', [], 'YColor', 'none'); 
end
% gets correct value from summary data file 
%  dataArray    data from summary data file
%  channel      string with channel name
%  frequency    frequencyName (Alpha, Beta, Gamma, Delta, Theta, AT)
%  bAbsolut     bool for either absolut or relative numbers
function pValue = getPValueFromCellArray(dataArray, channel, frequency, bAbsolut)

    if strcmp(frequency, 'A/T')
        %FYI no data in dataArray with relative alpha/theta 
        %wasn't necessary so far
        compareString = strcat(channel, '_power', 'Theta');
        for i = 1:length(dataArray)
            if strcmp(compareString, dataArray{i,1})
                pValue = dataArray{i, 8};
                
                dataMeds = dataArray{i,7};
                dataNormal = dataArray{i,6};
                meanDiff = dataMeds - dataNormal;
                break;
            end
        end
    else
        compareString = strcat(channel, '_power', frequency);
        for i = 1:length(dataArray)
            if strcmp(compareString, dataArray{i,1})
                %absolut or relative values 
                if bAbsolut
                    pValue = dataArray{i,2};  
                else
                    x = mod(i-2,5);
                    switch x
                        case 1 %alpha
                            pValue = dataArray{i+4,11};
                        case 2 %beta
                            pValue = dataArray{i+3,15};
                        case 3 %gamma
                            pValue = dataArray{i+2,16};
                        case 4 %delta
                            pValue = dataArray{i+1,17};
                        case 0 %theta
                            pValue = dataArray{i,18};
                    end
                end
                
                dataMeds = dataArray{i, 13};
                dataMeds = str2double(dataMeds);
                dataNormal = dataArray{i, 4};
                %dataNormal = str2double(dataNormal);
                meanDiff = dataMeds - dataNormal; 

            end
        end
    end
    isNumber = ~isnan(str2double(pValue)); 
    if isNumber
        pValue = str2double(pValue);
    end
    % check for mean difference
    % sign codifies if it's red (positive) or blue (negative)
    if meanDiff < 0
        pValue = pValue * -1;
    end
    
end

% retuns a color for a given p Value
% positive values are a hue of red
% negative values are a hue of blue
function color = getColorForPValue(pValue)

    if pValue > 0 && pValue <= 0.001
        color = '#A40000'; % Dark Candy Apple Red
    elseif pValue > 0.001 && pValue <= 0.01
        color = '#CC0000'; % Boston Univeristy Red
    elseif pValue > 0.01 && pValue <= 0.05
        color = '#E34234'; % Cinnabar
    elseif pValue > 0.05 && pValue <= 0.1
        color = '#FF6961'; % Pastel Red
    elseif pValue > 0.1 && pValue <= 0.2
        color = '#FFFFFF';%'#F4C2C2'; %Baby Pink
    elseif pValue > 0.2
        color = '#FFFFFF';
    elseif -0.2 > pValue
        color = '#FFFFFF';%'#CCCCFF'; % Lavender Blue
    elseif -0.1 >= pValue && pValue > -0.2
        color = '#FFFFFF';%'#92A1CF'; % Ceil
    elseif -0.05 >= pValue && pValue > -0.1
        color = '#aed6f1'; % Ceil
    elseif -0.01 >= pValue && pValue > -0.05
        color = '#5dade2'; % cerulean blue
    elseif -0.001 >= pValue && pValue > -0.01
        color = '#2e86c1'; % dark blue
    elseif 0 >= pValue && pValue > -0.001
        color = '#21618c'; % royal blue
    else
        color = '#399a33'; %green: something went wrong!
    end
end

% calculates the difference of means 
% data  output from calcPValueAndMore functions
function diffOfMeans = calcDifferenceOfMeans(data)

%get mean data
dataMeds = data(3:97, 13);
dataNormal = data(3:97, 4);

%subtract and take absolut value
diffOfMeans = cellfun(@minus,dataNormal,dataMeds,'UniformOutput',false);
%diffOfMeans = cellfun(@abs,C);

end

% draws a bar graph for a channel for its mean data
% data      output from calcPValueAndMore functions
% channel   string of a channel name e.g. FP1, Pz, ...
% sDrugs     string for drug name 
function barhGraph(data, data2, channel, sDrugs)

    meanDataNormal = [];
    meanDataMeds = [];
    meanDataMeds2 = []; 
    %look for channel
    compareString = strcat(channel, '_power', 'Alpha');
    for i = 1:length(data)
        if strcmp(compareString, data{i,1})
            meanDataNormal = cell2mat(data(i:i+4, 4)); 
            meanDataMeds = cell2mat(data(i:i+4, 13)); 
            meanDataMeds2 = cell2mat(data2(i:i+4, 13));
        end
    end
    x = categorical({'Alpha', 'Beta', 'Gamma', 'Delta', 'Theta'}); 
    b = barh(x,[meanDataNormal, meanDataMeds, meanDataMeds2]); 
    b(1).FaceColor = '#0072BD';
    b(2).FaceColor = '#77AC30';
    legend('normal', sDrugs, 'risperidone');
    xlabel(strcat('Mean for channel', {' '}, channel));
end

function createCompleteDrugsList(path)

    %path = 'xls'; 
    a = functionsForTUHData;
    list = a.createFileList('xls',path); 

    meds = {}; 
    temp = {}; 
    for i=1:size(list)
        temp = {}; 
        temp = meds; 
        data = readcell(list{i,1}, 'DateTimeType', 'text'); 
        x = data(:,4); 
        y = x(cellfun(@ischar,x));
        meds = [temp; y]; 
    end
    
    writecell(meds, 'meds.xls');

    
end

function frequencies =  countUniqueWords()
    filename = 'meds.txt';
    fid = fopen(filename);
    words = textscan(fid, '%s');
    status = fclose(fid);
      
    
    unique_words = unique(words{1,1}); 
    frequencies = zeros(numel(unique_words), 1);
    for i = 1:numel(unique_words)
        if max(unique_words{i} ~= ' ')
            for j = 1:numel(words{1,1})
               if strcmp(words{1,1}(j), unique_words{i})
                          frequencies(i) = frequencies(i) + 1;                      
               end
            end
        end
    end
end
