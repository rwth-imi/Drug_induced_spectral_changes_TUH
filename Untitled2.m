
 fig = figure('Name', "Test", 'visible','off'); 

 %frontal
%  area="frontal";
% colors=["#949494","white","white","white","white"] 
%temporal
% area="temporal";
% colors=["white","#949494","white","white","white"] 
% %central
% area="central";
% colors=["white","white","#949494","white","white"] 
% %parietal
% area="parietal";
% colors=["white","white","white","#949494","white"] 
% %occipital
area="occipital";
colors=["white","white","white","white","#949494"] 

font=15;

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
    r = 0.29; 
    c = [2.5,4.5];
    pos = [c-r 2*r 2*r];
    color = colors(1);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(2.25, 4.5, 'FP1', 'FontSize', font);

    %FP2 circle
    %r = 0.25; 
    c = [3.5,4.5];
    pos = [c-r 2*r 2*r]; 
    color = colors(1);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(3.25, 4.5, 'FP2', 'FontSize', font);

    %F7 circle
    %r = 0.25; 
    c = [1.75,4];
    pos = [c-r 2*r 2*r];

    color = colors(1);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(1.6, 4, 'F7', 'FontSize', font);

    %F3 circle
    %r = 0.25; 
    c = [2.35,3.75];
    pos = [c-r 2*r 2*r];

    color = colors(1);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(2.2, 3.75, 'F3', 'FontSize', font);

    %Fz circle
    %r = 0.25; 
    c = [3,3.75];
    pos = [c-r 2*r 2*r];

    color = colors(1);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(2.85, 3.75, 'Fz', 'FontSize', font);

    %F4 circle
    %r = 0.25; 
    c = [3.65,3.75];
    pos = [c-r 2*r 2*r];

    color = colors(1);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(3.5, 3.75, 'F4', 'FontSize', font);

    %F8 circle
    %r = 0.25; 
    c = [4.25,4];
    pos = [c-r 2*r 2*r];

    color = colors(1);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(4.1, 4, 'F8', 'FontSize', font);

    %T3 circle
    %r = 0.25; 
    c = [1.5,3];
    pos = [c-r 2*r 2*r];


    color = colors(2);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(1.35, 3, 'T3', 'FontSize', font);

    %C3 circle
    %r = 0.25; 
    c = [2.2,3];
    pos = [c-r 2*r 2*r];

    color = colors(3);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(2.05, 3, 'C3', 'FontSize', font);

    %Cz circle
    %r = 0.25; 
    c = [3,3];
    pos = [c-r 2*r 2*r];

    color = colors(3);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(2.85, 3, 'Cz', 'FontSize', font);

    %C4 circle
    %r = 0.25; 
    c = [3.8,3];
    pos = [c-r 2*r 2*r];

    color = colors(3);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(3.65, 3, 'C4', 'FontSize', font);

    %T4 circle
    %r = 0.25; 
    c = [4.5,3];
    pos = [c-r 2*r 2*r];

    color = colors(2);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(4.35, 3, 'T4', 'FontSize', font);

    %T5 circle
    %r = 0.25; 
    c = [1.75,2];
    pos = [c-r 2*r 2*r];

    color = colors(2);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(1.6, 2, 'T5', 'FontSize', font);

    %P3 circle
    %r = 0.25; 
    c = [2.35,2.25];
    pos = [c-r 2*r 2*r];

    color = colors(4);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(2.2, 2.25, 'P3', 'FontSize', font);

    %Pz circle
    %r = 0.25; 
    c = [3,2.25];
    pos = [c-r 2*r 2*r];

    color = colors(4);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(2.85, 2.25, 'Pz', 'FontSize', font);

    %P4 circle
    %r = 0.25; 
    c = [3.65,2.25];
    pos = [c-r 2*r 2*r];

    color = colors(4);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(3.5, 2.25, 'P4', 'FontSize', font);

    %T6 circle
    %r = 0.25; 
    c = [4.25,2];
    pos = [c-r 2*r 2*r];

    color = colors(2);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(4.1, 2, 'T6', 'FontSize', font);

    %O1 circle
    %r = 0.25; 
    c = [2.5,1.5];
    pos = [c-r 2*r 2*r];

    color = colors(5);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(2.35, 1.5, 'O1', 'FontSize', font);

    %O2 circle
    %r = 0.25; 
    c = [3.5,1.5];
    pos = [c-r 2*r 2*r];

    color = colors(5);  
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', color);
    text(3.35, 1.5, 'O2', 'FontSize', font);

    axis equal;

    %xlabel(freq, "FontSize", 20); 
     set(gca, 'xtick', [], 'YColor', 'none', 'XColor', 'none');    
    saveas(fig, strcat(area,'.png'));
    