%
% Copyright (c) 2015, Yarpiz (www.yarpiz.com)
% All rights reserved. Please read the "license.txt" for license terms.
%
% Project Code: YPEA120
% Project Title: Non-dominated Sorting Genetic Algorithm II (NSGA-II)
% Publisher: Yarpiz (www.yarpiz.com)
%
% Desenvolvedor: S. Mostapha Kalami Heris (Member of Yarpiz Team)
%
% Informações de contato: sm.kalami@gmail.com, info@yarpiz.com
%
t = zeros(2,20);
for arquivo = 1:20
    save ('salva.mat','arquivo','t');    
    clc;
    clear;
    close all;
    load ('salva.mat');
    disp(arquivo);
    tic;
    primeira = 0;
    Count = 0;
    Count_Max = 10;
    F1min = 1.0;
    F2min = 0.0;
    d = [];
    numPop = [];
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Valores utilizados no Tank-Model
    nVar = 12;    %Variáveis de decisão. 
    % Parâmetros do Tank-Model a serem calibrados.
    % X = [HI1, HI2, HI3, HI4, HA1, HA2, HB1, HC1, a1, a2, b1, c1, d1, a0, b0, c0]
    %Limite inferior de cada uma das variáveis de decisão:
    VarMin=[5,10,20,10,10,10,0.09,0.09,0.09,0.01,0.01,0.01];   
    %Limite superior de cada uma das variáveis de decisão:
    VarMax=[50,50,100, 70,45,70,0.5,0.5,0.5,0.1,0.1,0.1];       

    VarSize = [1 nVar]; % Size of Decision Variables Matrix
    FO = @(x) FO_TANK(x);  % Function Objective
    % Número de funções objetivas
    nObj = numel(FO(VarMin + (VarMax - VarMin)*rand));
    
    
    %% NSGA-II Parâmetros
    
    MaxIt = 500; %arquivo*100;      % Número Máximo de Iterações
    
    nPop = 100;        % Tamanho da população
    
    pCrossover = 0.7;                         % Crossover Percentage
    nCrossover = 2*round(pCrossover*nPop/2);  % Number of Parnets (Offsprings)
    
    pMutation = 0.5;                          % Mutation Percentage
    nMutation = round(pMutation*nPop);        % Number of Mutants
    
    mu = 0.02;                    % Mutation Rate
    
    sigma = 0.1*(VarMax - VarMin);  % Mutation Step Size
    
    %% Inicialização
    
    disp('Staring NSGA-II ...');
    
    empty_individual.Position = [];
    empty_individual.Cost = [];
    empty_individual.Rank = [];
    empty_individual.DominationSet = [];
    empty_individual.DominatedCount = [];
    empty_individual.CrowdingDistance = [];
    
    pop=repmat(empty_individual,nPop,1);
% %     for i=1:nPop
% %         pop(i).Position = VarMin + (VarMax - VarMin)*rand;
% %         pop(i).Cost = FO(pop(i).Position);
% %     end
% % 
% %     save(sprintf('população100_%d.mat',arquivo),'pop')
    population = load (sprintf('população100_%d.mat',arquivo));
    for i = 1:nPop
        pop(i).Position = population.pop(i).Position;
        pop(i).Cost = population.pop(i).Cost;
    end
    
    % Classificação não Dominada
    [pop, F] = NonDominatedSorting(pop);
    
    % Calcular a distância de aglomeração
    pop = CalcCrowdingDistance(pop,F);
    
    % Ordenar População
    [pop, F] = SortPopulation(pop);
    
    
    % NSGA-II Loop principal
    
    for it = 1:MaxIt
        
        % Crossover
        popc = repmat(empty_individual,nCrossover/2,2);
        for k = 1:nCrossover/2
            
            i1 = randi([1 nPop]);
            p1 = pop(i1);
            
            i2 = randi([1 nPop]);
            p2 = pop(i2);
            
            [popc(k,1).Position, popc(k,2).Position] = Crossover(p1.Position,p2.Position);
            
            popc(k,1).Cost = FO(popc(k,1).Position);
            popc(k,2).Cost = FO(popc(k,2).Position);
            
        end
        popc = popc(:);
        
        % Mutação
        popm = repmat(empty_individual,nMutation,1);
        for k = 1:nMutation
            
            i = randi([1 nPop]);
            p = pop(i);
            
            popm(k).Position = Mutate(p.Position,mu,sigma,VarMin,VarMax);
            
            popm(k).Cost=FO(popm(k).Position);
            
        end
        
        % Mesclar
        pop = [pop 
            popc 
            popm]; % #ok
        
        % Classificação não Dominada
        [pop,F] = NonDominatedSorting(pop);
        
        % Calcular a distância de aglomeração
        pop = CalcCrowdingDistance(pop,F);
        
        % Ordenar População
        pop = SortPopulation(pop);
        
        % Truncar
        pop = pop(1:nPop);
        
        % Classificação não Dominada
        [pop,F] = NonDominatedSorting(pop);
        
        % Calcular a distância de aglomeração
        pop = CalcCrowdingDistance(pop,F);
        
        % Ordenar População
        [pop,F] = SortPopulation(pop);
        
        % Store F1
        F1 = pop(F{1});
        
        % Calculo de distancia ao origem
        for i = 1:length(F{1})
            d(i) = sqrt((1 - F1(i,1).Cost(1) - F1min)^2 + (F1(i,1).Cost(2) - F2min)^2);
        end
        numPop(it) = length(F{1});
        dmin(it) = min(d);
        dmed(it) = sum(d)/length(d);
        
        %% Results
        Melhores = [];
        for i = 1:length(F{1})
            Melhores(i,:) = [F1(i).Position 1 - F1(i,1).Cost(1) F1(i,1).Cost(2) d(i)];
        end
        
        % Criterio de parada das iterações
        if length(F{1}) > nPop - 1 && sum(isnan(Melhores(:,18))) == 0 && sum(isnan(Melhores(:,17))) == 0 && it > MaxIt/2
            Count = Count + 1;
        else
            Count=0;
        end
        
        %% Criterio novo
        if Count > Count_Max && primeira == 0
            disp('parou por primeira vez');
            A=[(1:1:it); numPop; dmin]';
            Melhores = sortrows(Melhores,19);
            xlswrite(sprintf('pareto NSGAII_1+IPHII_%d pop.xlsx',arquivo*100),Melhores,num2str(it))
            xlswrite(sprintf('desempenho NSGAII_1+IPHII_%d pop.xlsx',arquivo*100),A,num2str(it))
            
            primeira = 1;
            %break;
            t(1,arquivo) = toc;
        end
        %% Criterio padrao
        if it == MaxIt     
            A=[(1:1:it); numPop; dmin; dmed]';
            Melhores = sortrows(Melhores,19);
            xlswrite(sprintf('pareto NSGAII_0+IPHII_%d pop.xlsx',arquivo*100),Melhores,num2str(it))
            xlswrite(sprintf('desempenho NSGAII_0+IPHII_%d pop.xlsx',arquivo*100),A,num2str(it))
            t(2,arquivo) = toc;
            break;
        end
    end
end
save ('salva_tempo100.mat','t');
disp('Optimization Terminated.');
disp(t/60);