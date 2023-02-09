%data caching for whole TUH Corpus
download = functionsTuhDownload;

%cache whole corpus
%url = 'https://www.isip.piconepress.com/projects/tuh_eeg/downloads/';

%cache normal data
url = 'https://www.isip.piconepress.com/projects/tuh_eeg/downloads/tuh_eeg_abnormal/v2.0.0/edf/train/normal/01_tcp_ar/';
%url = 'https://www.isip.piconepress.com/projects/tuh_eeg/downloads/tuh_eeg_abnormal/v2.0.0/edf/eval/normal/01_tcp_ar/';

%create list of all files
folderCellArray = [];
filename='TUH_normal_train.xls';
download.listAllDirectories(url, folderCellArray, filename);
