%fits different mixed model
clear;

file="Results/FullTableMixedModelNormal.csv";
table = readtable(file);

%set if columns are categorical
table.PatientNr = categorical(table.PatientNr);
table.Antidepressant = categorical(table.Antidepressant);
table.Antipsychotic = categorical(table.Antipsychotic);
table.ElectrodeLocation = categorical(table.ElectrodeLocation);
table.FrequencyBand = categorical(table.FrequencyBand);
table.TotalSerotonin = categorical(table.TotalSerotonin);
table.TotalDopamine = categorical(table.TotalDopamine);
table.TotalNorepinephrine = categorical(table.TotalNorepinephrine);
table.TotalHistamine = categorical(table.TotalHistamine);
table.TotalAcetylcholine = categorical(table.TotalAcetylcholine);

%fit different mixed models
%lme = fitlme(table,"Power ~ FrequencyBand*ElectrodeLocation*Antipsychotic*Antidepressant+ (1|SessionNr) + (1|ElectrodeLocation:Side:Electrode)");

%lme = fitlm(table,"Power ~ Antidepressant + ElectrodeLocation + FrequencyBand + PatientNr");

%lme = fitlm(table,"Power ~ Risperidone*Olanzapine*Quetiapine*Aripiprazole*Ziprasidone*Haloperidol*Fluphenazine*Perphenazine*Clozapin*Citalopram*Escitalopram*Sertraline*Paroxetine*Fluoxetine*Bupropion*Venlafaxine*Mirtazapine*Trazodone*Amitriptyline*Clomipramin*Doxepin*Duloxetin*Nortriptylin*Lithium + ElectrodeLocation + FrequencyBand + PatientNr");

%lme = fitlme(table,"Power ~ (Risperidone+Olanzapine+Quetiapine+Aripiprazole+Ziprasidone+Haloperidol+Fluphenazine+Perphenazine+Clozapin+Citalopram+Escitalopram+Sertraline+Paroxetine+Fluoxetine+Bupropion+Venlafaxine+Mirtazapine+Trazodone+Amitriptyline+Clomipramin+Doxepin+Duloxetin+Nortriptylin+Lithium|Antidepressant) + ElectrodeLocation + FrequencyBand + PatientNr");

%lme = fitlme(table,"Power ~ Risperidone + Olanzapine + ElectrodeLocation + FrequencyBand + PatientNr + (1|Antidepressant)");

%Model 1
%lme = fitlme(table,"Power ~ Antidepressant + Side + FrequencyBand +  (1|PatientNr)");

%lme = fitlme(table,"Power ~ Antidepressant + Side + FrequencyBand +  (1+Antidepressant + ElectrodeLocation + FrequencyBand|PatientNr)");

%Model 2
%lme = fitlme(table,"Power ~ Antidepressant + Side + FrequencyBand +  (1|PatientNr) + (1|PatientNr:SessionNr)");

%lme = fitlme(table,"Power ~ Antidepressant + Side + FrequencyBand +  (1|PatientNr) + (1|PatientNr:SessionNr)+ (1|PatientNr:SessionNr:FileNr)");%Model 6

%Model 3
%lme = fitlme(table,"Power ~  Side + FrequencyBand + TotalSerotonin + TotalDopamine + TotalNorepinephrine + TotalHistamine + TotalAcetylcholine + (1|PatientNr)");

%Model 4: did not work, not enough data for this complexitiy
%lme2 = fitlme(table,"Power ~  Side + FrequencyBand * TotalSerotonin * TotalDopamine * TotalNorepinephrine * TotalHistamine * TotalAcetylcholine + (1|PatientNr)");

%Model 5
%lme = fitlme(table,"Power ~  Side +  FrequencyBand*TotalSerotonin + FrequencyBand*TotalDopamine + FrequencyBand*TotalNorepinephrine + FrequencyBand*TotalHistamine + FrequencyBand*TotalAcetylcholine + (1|PatientNr)");

%Model 6
%lme = fitlme(table,"Power ~  ElectrodeLocation +  FrequencyBand*TotalSerotonin + FrequencyBand*TotalDopamine + FrequencyBand*TotalNorepinephrine + FrequencyBand*TotalHistamine + FrequencyBand*TotalAcetylcholine + (1|PatientNr)");

%Model 7
lme2 = fitlme(table,"Power ~  ElectrodeLocation*FrequencyBand*TotalSerotonin + ElectrodeLocation*FrequencyBand*TotalDopamine + ElectrodeLocation*FrequencyBand*TotalNorepinephrine + ElectrodeLocation*FrequencyBand*TotalHistamine + ElectrodeLocation*FrequencyBand*TotalAcetylcholine + (1|PatientNr)");


%Model 8
lme = fitlme(table,"Power ~  ElectrodeLocation*FrequencyBand*Antidepressant + ElectrodeLocation*FrequencyBand*Antipsychotic + (1|PatientNr)");


%lme2


%%%%%%%%%%%%%%%%%%%%%compare models%%%%%%%%%%%%%%%%%%%%%%%%%%
compare(lme, lme2)

%%%%%%%%%%%%%%%%%%%%F-test%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%pVal = coefTest(lme);
%pVal

%anova(lme)

%%%%%%%%%%%%%%%%%%%estimated marginal means%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%done in R

%%%%%%%%%%%%%%%%%%Plot fitted response vs observed response%%%%%%%%%%%%%%%%
% F = fitted(lme);
% R = response(lme);
% figure();
% plot(R,F,'rx')
% xlabel('Response')
% ylabel('Fitted')

%%%%%%%%%%% plot residuals %%%%%%%%%%%%%%%%%%%%%%%%%
% figure();
% plotResiduals(lme,'fitted')


%%%%%%%%%%%%%%save output in file %%%%%%%%%%%%%%%%%%%%%%%
% mdlOutput = evalc('disp(lme2)');
% fid = fopen("Results\Model6.txt",'wt'); 
% fprintf(fid,'%s',mdlOutput); 
% fclose(fid);