%
% Project Title: Simulador do modelo Tank
% 
% Desenvolvedor: Juan Carlos Ticona G.
% 
% Informações de contato: juancarlos.ticonag@gmail.com
%
clc;
clear;
close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Valores utilizados no Tank-Model
%Limite inferior de cada uma das variáveis de decisão:
VarMin=[5,10,20,30,10,10,10,10,0.09,0.09,0.09,0.01,0.001,0.01,0.01,0.001];   
%Limite superior de cada uma das variáveis de decisão:
VarMax=[50,50,100,500,70,45,70,70,0.5,0.5,0.5,0.1,0.01,0.1,0.1,0.1];       
parameters = {'HI1', 'HI2', 'HI3', 'HI4', 'HA1', 'HA2', 'HB1', 'HC1', 'a1', 'a2', 'b1', 'c1', 'd1', 'a0', 'b0', 'c0'}; 

Data_calibrationa = '01/01/2010'; %ijui = CAL 2010-2018; VAL 2003-2005 
currentDateAsNumber = datenum(Data_calibrationa)-1;
currentDate = datestr(currentDateAsNumber);


%% Inicialização
% comeca a ler os parametroscom com a distancia minima do frente das soluções nao dominadas
fileID1 = fopen('SPEAII_1.txt','r');                    
Par_min(1,:) = fscanf(fileID1,'%f %f %f %f %f %f %f',[1 16]);
fileID2 = fopen('NSGAII_1.txt','r');                    
Par_min(2,:) = fscanf(fileID2,'%f %f %f %f %f %f %f',[1 16]);
fileID3 = fopen('NSGAIII_1.txt','r');                   
Par_min(3,:) = fscanf(fileID3,'%f %f %f %f %f %f %f',[1 16]);

fileID = fopen('SPEAII_300.txt','r');                    % parametros do frente com a menor distancia media
Par_med = fscanf(fileID,'%f %f %f %f %f %f %f\n',[16 300]);               % vazao observado em m3/s
Par_med = Par_med';

%% IPH-II Loop principal
Qcal = @(x) TANK(x);  % Function Tank-Model

%% calculo das vazões com o Tank-Model
for i=1:3
    [Qcal_min(i,:), Qobs]=Qcal(Par_min(i,:));
    f1(i,:) = statistics(Qcal_min(i,:), Qobs);
end
time=length(Qcal_min);

for i=1:length(Par_med)
    [Qcal_med(i,:) Qobs] = Qcal(Par_med(i,:));
    %Par_nor(i,:) = (Par_med(i,:)-VarMin)./(VarMax - VarMin);
end
Qobs = Qobs';

%% Visualizar
%% figure hidrogram calculated and observed
X1 = (1:time)+currentDateAsNumber;
YMatrix1 = [Qcal_min; Qobs];
createfigure(X1, YMatrix1);

%% Escrever no excel
xlswrite(sprintf('Tank_Hidro.xlsx'),[Qcal_min; Qobs]')
%xlswrite(sprintf('Parametros_normal_SPEAII.xlsx'),Par_nor)
% % %% figure correlogram
% % X1 = Qobs;
% % Y1 = Qcal_min;
% % createCorrelogram(X1, Y1)

% %% figure hidrogramas non-dominate
% X1 = (1:time)+currentDateAsNumber;
% YMatrix1 = [Qobs;Qcal_med];
% createfigureM(X1, YMatrix1)
% %xlswrite(sprintf('Hidrograma_SPEAII.xlsx'),YMatrix1')
% %% figure Parameters normalized
% YMatrix1 = Par_nor';
% createParameters(YMatrix1)
beep; pause(0.5); beep; pause(0.5);
