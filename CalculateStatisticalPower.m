
fileMeds="D:/Results/t-test/single drugs/StatisticsSingle/Risperidone_normal_data.xls";
data = readtable(fileMeds);
powers={};
for i=1:height(data)
    nRisp=str2double(data{i,6});
    nControl=data{i,3};
    mu0=str2double(data{i,7});
    sigma0=str2double(data{i,8});
    mu1=data{i,4};
    ratio=max(nRisp, nControl)/min(nRisp, nControl);
    pwrout = sampsizepwr('t2',[mu0,sigma0],mu1,[],min(nRisp, nControl),'Ratio',ratio);
    powers=[powers, pwrout];
end

powers=transpose(powers);

