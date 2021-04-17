clc;
clear;
close all;
number = 1;
i = 1;
Alphabet = {'ABCDEFGHIJKLMNOPQRSTUVWXYZ'};
%% Inicialização    
disp('Staring ...');    
for arquivo = 20:-1:1
    A = num2str(arquivo*100);
    A = strcat('pareto NSGAII_0+IPHII_',A,' pop.xlsx');
    %A = strcat('pareto NSGAII_1+IPHII_',A,' pop.xlsx');
    filename = fullfile(A);
    [status,sheets,xlFormat] = xlsfinfo(filename);
    [D,txt,raw] = xlsread(filename,sheets{4},'M1:N500');
    
    if number <= 26
        letters = Alphabet{1}(number);    
        xlRange = strcat(letters,'1');
    else
        number1 = floor(number/26);
        number2 = mod(number,26);
        letters1 = Alphabet{1}(number1);
        letters2 = Alphabet{1}(number2);
        xlRange = strcat(letters1,letters2,'1');       
    end 
    
    sheet = 1;
    xlswrite('pareto NSGAII_0_TankModel.xlsx',D,sheet,xlRange); 
    %xlswrite('pareto NSGAII_1_TankModel.xlsx',D,sheet,xlRange); 
    disp(xlRange);
    disp(number);
    number = i*2 + 1;    
    i = i + 1;
end
disp('Terminated');