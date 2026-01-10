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
snrIdx = 1:3;
groupData1 = squeeze(abs(pcc(:,snrIdx(1),errorLevelIdx)));
groupData2 = squeeze(abs(pcc(:,snrIdx(2),errorLevelIdx)));
groupData3 = squeeze(abs(pcc(:,snrIdx(3),errorLevelIdx)));
boxData = [groupData1, groupData2, groupData3];


numErrors = length(errorLevelIdx);
numGroups = 3;

% -------------------------------------------------------------------
% Box positions
% -------------------------------------------------------------------
basePos = 1:numErrors; 
positions = [basePos-0.25, basePos, basePos+0.25];     

% -------------------------------------------------------------------
% Draw boxplot
% -------------------------------------------------------------------
figure;
hLines = boxplot(boxData,'Color','k', 'symbol','o',...                                  
                    'Notch','on','OutlierSize',4,'Whisker', 15, ...
                    'positions', positions);
set(hLines,'LineWidth',1)  
hold on;

% -------------------------------------------------------------------
% Colorize boxes 
% -------------------------------------------------------------------
boxColors = [0, 115, 189; 217, 84, 26; 237, 176, 33; 
             125, 46, 143; 120, 171, 48; 77, 191, 237]./255;
alphas = [0.9, 0.7, 0.5]; 

boxObjs = findobj(gca, 'Tag', 'Box');
medianObjs = findobj(gca, 'Tag', 'Median'); 

for k = 1:length(boxObjs )

    errorLevelK = ceil(k/numGroups);
    groupK = mod(k-1, numGroups) + 1; 

    colorRow = length(errorLevelIdx) + 1 - errorLevelK; 

    patch(get(boxObjs(k), 'XData'), get(boxObjs(k), 'YData'), ...
        boxColors(colorRow, :), 'FaceAlpha', alphas(groupK));
    set(medianObjs(k), 'LineWidth', 1.5);
end

% -------------------------------------------------------------------
% Reference line and axes
% -------------------------------------------------------------------
xlim = get(gca, 'XLim');
% refY = 1/sqrt(2);
refY = 1;
plot([xlim(1), xlim(2)], [refY, refY], '--', 'Color',[246,83,20]/255, 'LineWidth', 2);

ylim([-0.1 1.1]);
set(gca, 'XTick', basePos, 'XTickLabel', {'0','1','2','3','4','5'});
set(gca, 'FontWeight', 'bold', 'FontName', 'Times New Roman');

xlabel({'$\textbf{Position error (mm)}$'},'interpreter','latex','FontName','Times New Roman');
ylabel('$\rho_{1}$','interpreter','latex','FontName','Times New Roman');
% title({'$\textbf{Source distance: 8 mm}$'},'interpreter','latex','FontName','Times New Roman');

% xlabel({'$\textbf{Angular error ($^\circ$)}$'},'interpreter','latex','FontName','Times New Roman');
% ylabel('$\rho_{1}$','interpreter','latex','FontName','Times New Roman');
% title({'$\textbf{Source distance: 8 mm}$'},'interpreter','latex','FontName','Times New Roman');

% xlabel({'$\textbf{Gain error (\%)}$'},'interpreter','latex','FontName','Times New Roman');
% ylabel('$\rho_{1}$','interpreter','latex','FontName','Times New Roman');
% title({'$\textbf{Source distance: 8 mm}$'},'interpreter','latex','FontName','Times New Roman');

% xlabel({'$\textbf{Crosstalk (\%)}$'},'interpreter','latex','FontName','Times New Roman');
% ylabel('$\rho_{1}$','interpreter','latex','FontName','Times New Roman');
% title({'$\textbf{Source distance: 8 mm}$'},'interpreter','latex','FontName','Times New Roman');

