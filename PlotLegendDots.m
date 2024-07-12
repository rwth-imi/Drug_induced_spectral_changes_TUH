

fig = figure('Name', "Legend", 'units','centimeters','position',[0 0 13 1.5]); 
%get(gca,'fontname')  % shows you what you are using.
%set(gca,'FontName','times')  % Set it to times
width=0.1;
height=0.1;
posx=1;
posy=1;

% positive p values -> red hue
color = getColorForPValue(0.0001); 
rectangle('Position', [posx+0.4, posy, width, height]); 
rectangle('Position',[posx+0.405,posy+0.025, 0.01,0.035],'Curvature',[1 1], 'FaceColor', color);
text(1.41, posy+0.05, '  {\it P} < .001','FontName','times');

color = getColorForPValue(0.005); 
rectangle('Position', [posx+0.3, posy, width, height]); 
rectangle('Position',[posx+0.305,posy+0.025, 0.01,0.035],'Curvature',[1 1], 'FaceColor', color);
text(1.31, posy+0.05, '  {\it P} < .01','FontName','times');

color = getColorForPValue(0.04); 
rectangle('Position', [posx+0.2, posy, width, height]);
rectangle('Position',[posx+0.205,posy+0.025, 0.01,0.035],'Curvature',[1 1], 'FaceColor', color);
text(1.21, posy+0.05, '  {\it P} < .05','FontName','times');

%color = getColorForPValue(0.06); 
%rectangle('Position', [posx+0.1, posy, width, height]); 
%rectangle('Position',[posx+0.105,posy+0.041, 0.01,0.015],'Curvature',[1 1], 'FaceColor', color);
%text(1.11, posy+0.05, 'p < 0.1');

color = getColorForPValue(0.15); 
rectangle('Position', [posx+0.1,posy, width, height]);
rectangle('Position',[posx+0.105,posy+0.025, 0.01,0.035],'Curvature',[1 1], 'FaceColor', color);
text(posx+0.11, posy+0.05, '  {\it P} > .1','FontName','times');

rectangle('Position', [posx+0, posy, width, height], 'FaceColor', 'white'); 
text(posx+0.01, posy+0.05, 'Increase','FontName','times');

% negative p values -> blue hue

posy=0.9;
color = getColorForPValue(-0.0001); 
rectangle('Position', [posx+0.4, posy, width, height]); 
rectangle('Position',[posx+0.405,posy+0.025, 0.01,0.035],'Curvature',[1 1], 'FaceColor', color);
text(1.41, posy+0.05, '  {\it P} < .001','FontName','times');

color = getColorForPValue(-0.001); 
rectangle('Position', [posx+0.3, posy, width, height]); 
rectangle('Position',[posx+0.305,posy+0.025, 0.01,0.035],'Curvature',[1 1], 'FaceColor', color);
text(1.31, posy+0.05, '  {\it P} < .01','FontName','times');

color = getColorForPValue(-0.04); 
rectangle('Position', [posx+0.2, posy, width, height]);
rectangle('Position',[posx+0.205,posy+0.025, 0.01,0.035],'Curvature',[1 1], 'FaceColor', color);
text(1.21, posy+0.05, '  {\it P} < .05','FontName','times');

color = getColorForPValue(-0.06); 
rectangle('Position', [posx+0.1,posy, width, height]);
rectangle('Position',[posx+0.105,posy+0.025, 0.01,0.035],'Curvature',[1 1], 'FaceColor', color);
text(1.11, posy+0.05, '  {\it P} > .1','FontName','times');

%color = getColorForPValue(-0.15); 
%rectangle('Position', [posx+0.1, posy, width, height], 'FaceColor', color); 
%text(1.11, posy+0.05, 'p < 0.1');

rectangle('Position', [posx+0, posy, width, height], 'FaceColor', 'white'); 
text(1.01, posy+0.05, 'Decrease','FontName','times');

%xlabel('Legend'); 
set(gca, 'xtick', [], 'YColor', 'none'); 




function color = getColorForPValue(pValue)

    if pValue > 0 && pValue <= 0.001
        %color = '#CC0000'; % Dark Candy Apple Red
        color = '#ff0000';
    elseif pValue > 0.001 && pValue <= 0.01
        %color = '#E34234'; % Boston Univeristy Red
        color = '#ff9933';
    elseif pValue > 0.01 && pValue <= 0.05
        %color = '#FF6961'; % Cinnabar
        color = '#ffff00';
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
        %color = '#aed6f1'; % cerulean blue
        color='#00ffff';
    elseif -0.001 >= pValue && pValue > -0.01
        %color = '#5dade2'; % dark blue
        color='#00c2eb';
    elseif 0 >= pValue && pValue > -0.001
        %color = '#2e86c1'; % royal blue
        color='#0066cc';
    else
        color = '#399a33'; %green: something went wrong!
    end
end