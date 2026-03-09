% -------------------------------------------------------------------
% Figure defaults
% -------------------------------------------------------------------
set(0,'defaultAxesFontName','Times New Roman'); 
set(0,'defaultAxesFontSize', 18);
set(0,'defaultTextFontSize', 16); 
set(0,'defaultLineLineWidth',2);
set(0,'defaultfigureposition',[400 300 400 320]);

% -------------------------------------------------------------------
% Extract data
% -------------------------------------------------------------------
errorLevelIdx = 1:6;
snrIdx = 2;
boxData = squeeze(abs(pcc(:,snrIdx,errorLevelIdx)));

% -------------------------------------------------------------------
% Draw boxplot
% -------------------------------------------------------------------
figure;
hLines = boxplot(boxData, 'Color','k', 'symbol','o',...                                  
                    'Notch','on', 'OutlierSize',4, 'Whisker', 5);
set(hLines,'LineWidth',1)  
hold on;

% -------------------------------------------------------------------
% Colorize boxes 
% -------------------------------------------------------------------
boxColors = [0, 115, 189; 217, 84, 26; 237, 176, 33; 
             125, 46, 143; 120, 171, 48; 77, 191, 237]./255;
boxColors = flipud(boxColors);

boxObjs = findobj(gca, 'Tag', 'Box');  
medianObjs = findobj(gca, 'Tag', 'Median');  

for i = 1:length(boxObjs)
    patch(get(boxObjs(i), 'XData'), get(boxObjs(i), 'YData'), boxColors(i, :), 'FaceAlpha',0.5);
    set(medianObjs(i), 'LineWidth', 3);
end

% -------------------------------------------------------------------
% Reference line and axes
% -------------------------------------------------------------------
xlim = get(gca, 'XLim');
refY = 1/sqrt(2);
plot([xlim(1), xlim(2)], [refY, refY], '--', 'Color',[246,83,20]/255, 'LineWidth', 2);

ylim([-0.1 1.1]);
xticklabels({'0','1','2','3','4','5'});
set(gca, 'FontWeight', 'bold', 'FontName', 'Times New Roman');

% -------------------------------------------------------------------
% Labels and Title
% -------------------------------------------------------------------
% xlabel({'$\textbf{Gain error (\%)}$'},'interpreter','latex','FontName','Times New Roman');
% ylabel('$\rho_{2}$','interpreter','latex','FontName','Times New Roman');
% title({'$\textbf{Source distance: 8 mm}$'},'interpreter','latex','FontName','Times New Roman');

% xlabel({'$\textbf{Crosstalk (\%)}$'},'interpreter','latex','FontName','Times New Roman');
% ylabel('$\rho_{2}$','interpreter','latex','FontName','Times New Roman');
% title({'$\textbf{Source distance: 4 mm}$'},'interpreter','latex','FontName','Times New Roman');

xlabel({'$\textbf{Position error (mm)}$'},'interpreter','latex','FontName','Times New Roman');
ylabel('$\rho_{2}$','interpreter','latex','FontName','Times New Roman');
title({'$\textbf{Source distance: 8 mm}$'},'interpreter','latex','FontName','Times New Roman');

% xlabel({'$\textbf{Angular error ($^\circ$)}$'},'interpreter','latex','FontName','Times New Roman');
% ylabel('$\rho_{2}$','interpreter','latex','FontName','Times New Roman');
% title({'$\textbf{Source distance: 8 mm}$'},'interpreter','latex','FontName','Times New Roman');