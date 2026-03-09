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
dataSet = metricLE; % angleerr crosstalk gainerr poserr
barData = dataSet * 1000;

[numTrials, numSnrs, numLevels] = size(barData);
meanLE = zeros(numSnrs,numLevels);
stdLE  = zeros(numSnrs,numLevels);
for snrIdx = 1:numSnrs 
    meanLE(snrIdx,:) = mean(squeeze(barData(:,snrIdx,:)),1);
    stdLE(snrIdx,:)  = std(squeeze(barData(:,snrIdx,:)));
end
semLE = stdLE / sqrt(numTrials); 

% -------------------------------------------------------------------------
% Plot
% -------------------------------------------------------------------------
% figure;
% figure('Position', [100 100 800 310]); 
figure('Position', [100 100 530 450]);
barHandle = bar(1:numSnrs, meanLE, 0.8, 'EdgeColor', 'none');

xlabel({'$\textbf{SNR}$'},'interpreter','latex');
ylabel({'$\textbf{LE (mm)}$'},'interpreter','latex');
% title({'$\textbf{Q=3 $\rho$=0.8}$'},'interpreter','latex');
title({'$\textbf{Position error}$'},'interpreter','latex');

boxColors = [0, 115, 189; 217, 84, 26; 237, 176, 33; 
             125, 46, 143; 120, 171, 48; 77, 191, 237]./255;
for levelIdx = 1:numLevels
    barHandle(levelIdx).FaceColor = boxColors(levelIdx, :);
    barHandle(levelIdx).FaceAlpha = 0.8;  % 设置透明度为0.5
end
hold on;

% -------------------------------------------------------------------------
% Error bars 
% -------------------------------------------------------------------------
xPos = zeros(numSnrs, numLevels);
for levelIdx = 1:numLevels
    xPos(:, levelIdx) = barHandle(levelIdx).XEndPoints(:)';
end


errHandle = errorbar(xPos, meanLE, semLE, 'LineStyle', 'none');
for levelIdx = 1:numLevels
    set(errHandle(levelIdx), 'Color', barHandle(levelIdx).FaceColor);
end

% -------------------------------------------------------------------------
% Axes styling
% -------------------------------------------------------------------------
yLimRange  = [0 15];
set(gca, 'FontWeight', 'bold', 'FontName', 'Times New Roman', ...
         'XGrid', 'off', 'YGrid', 'on', 'Ylim' , yLimRange, ...
         'XTick', 1:numSnrs,'Xticklabel',{'0 dB' '5 dB' '10 dB' '15 dB'}, ...
         'TickDir', 'out', 'Box', 'off') 

xLim = get(gca, 'XLim');
yLim = get(gca, 'YLim');
plot(xLim, yLim(2)*ones(size(xLim)), 'k', 'LineWidth', 0.1);
plot(xLim(2)*ones(size(yLim)), yLim, 'k', 'LineWidth', 0.1);


% -------------------------------------------------------------------------
% Legend (choose one block and customize labels)
% -------------------------------------------------------------------------
% legendLabels = {'0%','1%','2%','3%','4%','5%'};
% legendLabels = {'0%','2%','4%','6%','8%','10%'};
legendLabels = {'0mm','1mm','2mm','3mm','4mm','5mm'};
% legendLabels = {'0°','1°','2°','3°','4°','5°'};

hLegend = legend(barHandle, legendLabels, ...
    'Location', 'NorthOutside', 'FontWeight', 'normal');
hLegend.NumColumns = numLevels;
hLegend.FontSize = 18;