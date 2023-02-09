
fig = figure('Name', "Legend", 'units','centimeters','position',[0 0 15 5]); 
width=0.1;
height=0.1;
posx=1;
posy=1;

% positive p values -> red hue
color = getColorForPValue(0.0001); 
rectangle('Position', [posx+0.4, posy, width, height], 'FaceColor', color); 
text(1.41, posy+0.05, 'p < 0.001');

color = getColorForPValue(0.005); 
rectangle('Position', [posx+0.3, posy, width, height], 'FaceColor', color); 
text(1.31, posy+0.05, 'p < 0.01');

color = getColorForPValue(0.04); 
rectangle('Position', [posx+0.2, posy, width, height], 'FaceColor', color);
text(1.21, posy+0.05, 'p < 0.05');

color = getColorForPValue(0.06); 
rectangle('Position', [posx+0.1, posy, width, height], 'FaceColor', color); 
text(1.11, posy+0.05, 'p < 0.1');

color = getColorForPValue(0.15); 
rectangle('Position', [posx+0.1,posy, width, height], 'FaceColor',color);
text(posx+0.11, posy+0.05, 'p > 0.1');

rectangle('Position', [posx+0, posy, width, height], 'FaceColor', 'white'); 
text(posx+0.01, posy+0.05, 'Increase');

% negative p values -> blue hue

posy=0.9;
color = getColorForPValue(-0.0001); 
rectangle('Position', [posx+0.4, posy, width, height], 'FaceColor', color); 
text(1.41, posy+0.05, 'p < 0.001');

color = getColorForPValue(-0.001); 
rectangle('Position', [posx+0.3, posy, width, height], 'FaceColor', color); 
text(1.31, posy+0.05, 'p < 0.01');

color = getColorForPValue(-0.04); 
rectangle('Position', [posx+0.2, posy, width, height], 'FaceColor', color);
text(1.21, posy+0.05, 'p < 0.05');

color = getColorForPValue(-0.06); 
rectangle('Position', [posx+0.1,posy, width, height], 'FaceColor',color);
text(1.11, posy+0.05, 'p > 0.1');

color = getColorForPValue(-0.15); 
rectangle('Position', [posx+0.1, posy, width, height], 'FaceColor', color); 
text(1.11, posy+0.05, 'p < 0.1');

rectangle('Position', [posx+0, posy, width, height], 'FaceColor', 'white'); 
text(1.01, posy+0.05, 'Decrease');

%xlabel('Legend'); 
set(gca, 'xtick', [], 'YColor', 'none'); 




function color = getColorForPValue(pValue)

    if pValue > 0 && pValue <= 0.001
        color = '#CC0000'; % Dark Candy Apple Red
    elseif pValue > 0.001 && pValue <= 0.01
        color = '#E34234'; % Boston Univeristy Red
    elseif pValue > 0.01 && pValue <= 0.05
        color = '#FF6961'; % Cinnabar
    elseif pValue > 0.05 && pValue <= 0.1
        color = '#FFFFFF'; % Pastel Red
    elseif pValue > 0.1 && pValue <= 0.2
        color = '#FFFFFF';%'#F4C2C2'; %Baby Pink
    elseif pValue > 0.2
        color = '#FFFFFF';
    elseif -0.2 > pValue
        color = '#FFFFFF';%'#CCCCFF'; % Lavender Blue
    elseif -0.1 >= pValue && pValue > -0.2
        color = '#FFFFFF';%'#92A1CF'; % Ceil
    elseif -0.05 >= pValue && pValue > -0.1
        color = '#FFFFFF'; % Ceil
    elseif -0.01 >= pValue && pValue > -0.05
        color = '#aed6f1'; % cerulean blue
    elseif -0.001 >= pValue && pValue > -0.01
        color = '#5dade2'; % dark blue
    elseif 0 >= pValue && pValue > -0.001
        color = '#2e86c1'; % royal blue
    else
        color = '#399a33'; %green: something went wrong!
    end
end