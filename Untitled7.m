folder = strcat("D:\",'EDFData\', 'Risperidone', '\CleanData');

listEDF = d.createFileList('edf',folder);

EEGData = pop_biosig(listEDF{0},'importevent','off','importannot','off'); 