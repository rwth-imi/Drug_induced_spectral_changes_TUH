 
sFigureName="";
fig = figure('Name', sFigureName, 'visible','off'); 


    for i = 1:7
        
        freq = ''; 
   
        h3=subplot(2, 4, i);
        set(h3, 'Units', 'normalized');
        if i==1
            set(h3, 'Position', [0.13, .5838, .1566, .3412]);
        elseif i==2
            set(h3, 'Position', [0.26, .5838, .1566, .3412]);
        elseif i==3
            set(h3, 'Position', [0.39, .5838, .1566, .3412]);
        elseif i==4
            set(h3, 'Position', [0.57, .5838, .1566, .3412]);
        elseif i==5
            set(h3, 'Position', [0.13, .25, .1566, .3412]);
        elseif i==6
            set(h3, 'Position', [0.26, .25, .1566, .3412]);
        elseif i==7
            set(h3, 'Position', [0.39, .25, .1566, .3412]);            
        end
        switch i
            case 1
                freq = 'Frontal';
                dataPValue=[]
            case 2
                freq = 'Central';
            case 3
                freq = 'Occipital';
            case 4
                freq = 'parietal';
            case 5
                freq = 'temporal';

            otherwise
                disp('error switch case visualizePValue')
        end
        if ~strcmp(freq,'none')
            plotFace(dataPValue, freq, 0, 0)
        end

    end
   
    %legend subplot
    h3=subplot(2,4,8);
    set(h3, 'Position', [0.57, .25, .1566, .3412]);
    plotLegend(bonferoni);
    
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'PaperPosition', [0 0 45 25]);
    %savefig(strcat('Results/',sFigureName));

    saveas(fig, strcat(savepath,sFigureName, '.png'));
    