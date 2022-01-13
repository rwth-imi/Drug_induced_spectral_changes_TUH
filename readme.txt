Drug_induced_spectral changes is a pipeline designed to work with the TUH EEG Corpus: https://isip.piconepress.com/projects/tuh_eeg/  
It can be used to mine for data from the Corpus, process and clean the data, calculate the powerspectrum and compare "normal" data to data from patients that used certain drugs. A list of the used drugs can be found under ListOfDrugs.txt. For processing and cleaning of the eeg-data EEGLAB was used.

----------------------------------------------------------------------------------------------------------------------------------------
DATA MINIG
----------------------------------------------------------------------------------------------------------------------------------------

chacheTUH.m
Chache data: create xls-file that contains a list of all available data in the TUH EEG Corpus including the used drugs for each patient

downloadEDFForCertainMedicine.m
downloads all edf files where patients took drugs from a list of drugs

downloadNormalData.m
downloads all files from "TUH Abnormal Corpus" where files are classified as "normal"

---------------------------------------------------------------------------------------------------------------------------------------
PREPROCESSING AND SPECTRAL ANALYSIS
---------------------------------------------------------------------------------------------------------------------------------------

cleanData.m
cleans the downloaded data using the EEGLAB-function clean_artifacts

prepareData.m
calculates the powerspectrum for the cleaned data

prepareNormalData.m
removes all "normal" files that contain drugs from the list and calculates the powerspectrum


---------------------------------------------------------------------------------------------------------------------------------------
STATISTICAL PREPARATION, ANALYSIS AND VISUALIZATION 
---------------------------------------------------------------------------------------------------------------------------------------

doStatistics.m
removes outliers, averages per patient, computes relative powers and conducts a Welch's test to compare normal and drug groups, visualizes data

---------------------------------------------------------------------------------------------------------------------------------------
ADDITIONAL INFORMATION - CLASSES
---------------------------------------------------------------------------------------------------------------------------------------

AbstractFeatureExtraction.m 	Abstact class for feature extractin classes
FeatureExtractionManager.m	    Class that manages feature extraction classes
InformationExtractor.m	        Class that includes methods that extract patient information from the corresponding txt file
WaveletExtraction.m             Class that performs a wavelet decomposition and extracts features
                                Inherits from AbstractFeatureExtraction

---------------------------------------------------------------------------------------------------------------------------------------
ADDITIONAL INFORMATION - FUNCTIONS
---------------------------------------------------------------------------------------------------------------------------------------

functionsForEDFFiles.m	

Contains functions to clean edf-files and to calculate the powerspectrum from them
•	calculatePowerForBands: calculates powerspectrum for mixed model
•	calculatePowerForBandsAveragePatient: calculates powerspectrum for t-tests
•	cleanData: cleans edf-files

---------------------------------------------------------------------------------------------------------------------------------------

functionsForTUHData.m	

is a collection of functions that can be used to work with the TUH EEG Corpus.
It includes function for the acess of the TUH data, the extraction of features such as the alpha/theta power,
extraction of medication information, classifiers and the measuring of the performance for these classifiers.

•	functionsForTUHData
•	splitAnd(medications): splits medications into vector
•	createCorrelationTable(drugs,antipsychTable,usedDrugsId,slowing): This methode creates the distribution tabels for anti-psychotics 
    and as slow labeld records 
    o	drugs contains the results from method 
    o	antipsychtable conatins the names of the differndt anti-psychotics, 
    o	uesedDrugsId contains the idnice of antipsychotics that are applied in the TUH corpus and
    o	slowing contains the labels for slow records.
•	findDiffernetMedicines(medication): This function extract the differnt drugs found in the medication vectors
•	searchClozapine(medication): Look for clozapine in the extracted medication
•	matchResults(clinicalreports,results,edfFiles): this function matches the information extracted from the clinicl reports with the 
    results of the record detection on the full TUH EEG corpus
•	createresult(list)
•	createFileList(typ,folder): creates list of files of the defined type that are included in the folder
•	extractInformations(fileList,drugTable): creates a matrix for the detected antipsychotic drugs in the clincal reports. Each row in 
    drugs corresponds to a record in clinicalReportsList and each coulmn corresponds to a drug of antipsychTable. 
    o	filelist consists of a list of paths of clinical reports. 
    o	drugtable contains the brand and generica names of antipsychotic drugs. 
•	And many more!

---------------------------------------------------------------------------------------------------------------------------------------

functionsTuhDownload.m	

Functions to download data

•  listAllDirectories: Get list of files from server depending on url
        Recursive, will go through all subfolder
        Will save file format, data of creation
        If it’s a text file it looks for medical information 
•  Download specified/sorted edf files from tuh server
    downloadFolderContentToCellArray(folderCellArrayData)
        Function not recursive 
        Downloads everything to the current matlab on path folder 

---------------------------------------------------------------------------------------------------------------------------------------

ScriptWorkWithExcelData.m	

Functions to work with excel data

•  (Optional) Filter by medicine 
•   medsCell = findClozapineInCellArray(xlsTxtData, medsCell, pattern)
        Takes the read in data returned from listAllDirectories and looks for a pattern in all read in medical data
        Returns a cell array with same layout as foldercellarray

---------------------------------------------------------------------------------------------------------------------------------------

visualizeEEGData.m	

Functions to calculate data from edf-files, do statistics and plot the results
•	calcAllFreqAllChannel: calculates accumulating power data for all frequencies and all channels 
•	createData: calculates accumulating power data for one channel with one frequency 
    o	used by calcAllFreqAllChannel
•	createDataClozapine: calculates accumulating power data for one channel with one frequency
    o	used by calcAllFreqAllChannel
•	calculatePowerForBands: calculates the power spectral density for a list of edf files
        calculates Power for all the bands by Fourier frequencies stuff, allows to specify window and overlapSize for calculation 
        List of edf files for which they are supposed to be created 
        Creates a lot of excel files overall in the folder of the edf file
•	calcPValueAndMore: calculates statistics for normal and medical data
        Calculates a lot of statistics from the data created in calculatePowerForBands
            Removes outliers as well
            Clozapine has not a lot of data and usually needs a higher outlier removal percentage 
            Statistics
            Alpha/Theata
            Alpha/Band 
                Band = alpha + beta + gamma + theta + delta
            Amount of data points
            mean
            Std 
            pvalues
            Alpha/tetha between medicine and normal
            Alpha/band between medicine and normal
            In general between medicine and normal data
•	calcPValueAndMoreWithSampling: calculates statistics for normal and medical data
         same as function above but with sampling 
•	setUpChannelsFrequencies: setup function for used strings for channels and frequencies 
    o	used by calcAllFreqAllChannel
•	visualizePValues: draws the plots for pvalue data
•	getPValueFromCellArray: gets correct value from summary data file
    o	used in visualizePValues
•	getColorForPValue: retuns a color for a given p Value
    o	used in visualizePValues
•	calcDifferenceOfMeans: calculates the difference of means
•	barhGraph: draws a bar graph for a channel for its mean data
•	createCompleteDrugsList
•	countUniqueWords
•	(Optional) returnData = createDataForBoxplots(list, channel, frequency)
        Accumulates the data necessary to draw boxplots in matlab
        Requires a list of  excel files 


---------------------------------------------------------------------------------------------------------------------------------------

xlscol.m	

---------------------------------------------------------------------------------------------------------------------------------------
ADDITIONAL INFORMATION - SCRIPTS
---------------------------------------------------------------------------------------------------------------------------------------

cacheTUH	                    Cache portion of TUH corpus
cleanData	                    Cleans all edf-files for list of drugs
concatNormalAndFullTable	    Concatenates normal data table and full data table for mixed model
createPSForMixedModel	        Creates powerspectrum table for mixed model for each drug in list
createTableMixedModel	        Creates full table for mixed model from powerspectrum tables for individual drugs 
                                (created in createPSForMixedModel.m) and receptor properties table
doStatistics	                Does t-tests for each drug in list and visualizes the results
downloadEDFForCertainMedicine	Download edf/text-files for all drugs in list
downloadNormalData	            Download edf/text-files for normal files
drugGroups	                    Calculates powerspectrum for all drug groups from Hyun
fitMixedModel	                Fits and compares different mixed models
prepareData	                    Clean data and calculate powerspectrum for t-tests for list of drugs
prepareNormalData	            Get normal data used for mixed model or t-tests and calculate powerspectrum

