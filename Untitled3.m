
drive="D:/";

savefile =strcat(drive, "Results\MixedModel\FullTableMixedModelNormal.csv");
dataAll=readtable(savefile);

toDelete = dataAll.Lithium == 1;
dataAll(toDelete,:) = [];

dataAll.Lithium=[];

savefile =strcat(drive, "Results\MixedModel\FullTableMixedModelNormalWOLithium.csv");
writetable(dataAll, savefile);