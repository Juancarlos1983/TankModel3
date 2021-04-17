clc;
clear;

load('data.txt')
X = data(:,2);
Y = data(:,1);
outpath = ('D:\documentos\Juan\artigo MOEA\Resultados com criterio de parada\IPH-II simulação');
outname = ('plot.png');
numbins = 20;                              % Define a densidade das cores
markersize = 30;                             % Tamanho dos pontos
marker = '.';                               % Marca dos pontos
xlab = 'In-situ Observations/W.m^-^2';
ylab = 'CERES Observations/W.m^-^2';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mandatory:
%            X                  [x,1] array containing variable X
%            Y                  [y,1] array containing variable Y
%            outpath            path where the output-file should be saved.
%                                leave blank for current working directory
%            outname            name of the output-file. if outname contains
%                                filetype (e.g. png), this type will be used.
%                                Otherwise, a pdf-file will be generated
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[values, centers] = hist3([X Y], [numbins numbins]);
centers_X = centers{1,1};
centers_Y = centers{1,2};
binsize_X = abs(centers_X(2) - centers_X(1)) / 2;
binsize_Y = abs(centers_Y(2) - centers_Y(1)) / 2;
bins_X = zeros(numbins, 2);
bins_Y = zeros(numbins, 2);
for i = 1:numbins
    bins_X(i, 1) = centers_X(i) - binsize_X;
    bins_X(i, 2) = centers_X(i) + binsize_X;
    bins_Y(i, 1) = centers_Y(i) - binsize_Y;
    bins_Y(i, 2) = centers_Y(i) + binsize_Y;
end
scatter_COL = zeros(length(X), 1);
onepercent = round(length(X) / 100);

fprintf('Generating colormap...\n');

for i = 1:length(X)
    if (mod(i,onepercent) == 0)
        fprintf('.');
    end
    last_lower_X = NaN;
    last_higher_X = NaN;
    id_X = NaN;
    c_X = X(i);
    last_lower_X = find(c_X >= bins_X(:,1));
    if (~isempty(last_lower_X))
        last_lower_X = last_lower_X(end);
    else
        last_higher_X = find(c_X <= bins_X(:,2));
        if (~isempty(last_higher_X))
            last_higher_X = last_higher_X(1);
        end
    end
    if (~isnan(last_lower_X))
        id_X = last_lower_X;
    else
        if (~isnan(last_higher_X))
            id_X = last_higher_X;
        end
    end
    last_lower_Y = NaN;
    last_higher_Y = NaN;
    id_Y = NaN;
    c_Y = Y(i);
    last_lower_Y = find(c_Y >= bins_Y(:,1));
    if (~isempty(last_lower_Y))
        last_lower_Y = last_lower_Y(end);
    else
        last_higher_Y = find(c_Y <= bins_Y(:,2));
        if (~isempty(last_higher_Y))
            last_higher_Y = last_higher_Y(1);
        end
    end
    if (~isnan(last_lower_Y))
        id_Y = last_lower_Y;
    else
        if (~isnan(last_higher_Y))
            id_Y = last_higher_Y;
        end
    end
    scatter_COL(i) = values(id_X, id_Y);
    
end

fprintf(' Done!\n');

fprintf('Plotting...');

f = figure();
scatter(X, Y, markersize, scatter_COL, marker);

% Calculo de estatisticas
[r,p] = corr(X, Y);
% Root mean square error
RMSE=sqrt(sum((X(:)-Y(:)).^2)/numel(X));
% Mean bias error
MBE=sum((X(:)-Y(:)))/numel(X);
% Legenda
str = {sprintf('MBE: %.3f W.m^-^2', MBE), sprintf('RMSE: %.3f W.m^-^2', RMSE), sprintf('corr: %.3f', r)};
annotation('textbox', [0.2 0.80 0.1 0.1], 'String', str, 'EdgeColor', 'none');

hold on
plot([0,max(max(X,Y))], [0, max(max(X,Y))], 'k');
hold off

% Etiquetas dos eixos
xlabel(xlab);
ylabel(ylab);
xlim([0 max(max(X,Y))]);
ylim([0 max(max(X,Y))]);

[p,n,r] = fileparts(outname);
if (isempty(r))
    r = '.pdf';
end
outname = strcat(p,n,r);
outfile = fullfile(outpath, outname);
saveas(f, outfile);
fprintf(' Done!\n');