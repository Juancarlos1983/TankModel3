% =======================================================================
% -----------------------------------------------------------------------
% -----------------------   JUAN CARLOS TICONA  -------------------------
% ----------- INSTITUTO DE PESQUISAS HIDRAULICAS (IPH) UFRGS  -----------
% ----------------------------- Tank MOdel ------------------------------
% -------------------------- Dezembro do 2019 ---------------------------
% -----------------------------------------------------------------------
% =======================================================================

function [Q,QO] = TANK(x)
% =======================================================================
% O modelo de tanque foi desenvolvido originalmente para uso em solos 
% constantemente saturados, no Jap�o (Sugawara, 1979, 1995). Possui 4
% tanques e 12 parametros.

% Descri��o e unidades dos parametros:
% HI1, HI2, HI3 e HI4 altura de cada armazenamento inicial *[mm]*
% HA1, HA2, HB1 e HC1 altura de cada um dos orif�cios laterais *[mm]*
% a1, a2, b1, c1, d1 seus respectivos coeficientes de escoamento *[dia-1]*
% a0, b0 e c0 coeficiente de infiltra��o para os tanques *[dia-1]*

%     HI1 (armazenamento inicial do tanque 1)                    : X1
%     HI2 (armazenamento inicial do tanque 2)                    : X2
%     HI3 (armazenamento inicial do tanque 3)                    : X3

%     HA1 (altura do orificio a1 do tanque 1)                    : X4
%     HA2 (altura do orificio a2 do tanque 1)                    : X5
%     HB1 (altura do orificio do tanque 2)                       : X6

%     a1  (coeficiente de escoamento 1, do tanque 1)             : X7
%     a2  (coeficiente de escoamento 2, do tanque 1)             : X8
%     b1  (coeficiente de escoamento do tanque 2)                : X9
%     c1 (coeficiente de escoamento do tanque 3                  : X10

%     a0 (coeficiente de infiltra��o do tanque 1 para o tanque 2): X11
%     b0 (coeficiente de infiltra��o do tanque 2 para o tanque 3): X12

% X = [HI1, HI2, HI3, HA1, HA2, HB1, a1, a2, b1, c1, a0, b0]

%% =======================================================================
% Come�a a ler os dados de entrada
QO = textread('vaz_canoas.txt','%f');                % vaz�o observado em m3/s
P = textread('prec_canoas.txt','%f');          % Precitac�o em mm/dia
ETR  = textread('evap_canoas.txt','%f');  % Evapotranspira��o mm/dia
NT=length(QO);
PAR = x; % Le os parametros em uma coluna
Area = 56.8; % km^2
Area = 86.4/Area;  % convers�o vaz�o em unidades de m^3/s

    for I = 1:NT

        X = PAR;

        %% CALCULOS DO PRIMEIRO DIA
        if I == 1
            %% Calcula armazenamento no Tanque 1 e se h� evapotranspira��o no 2o tanque
            if X(1) + P(I) - ETR(I) <0
                S1(I) = 0;
                ETR2(I) = abs(X(1) + P(I) - ETR(I));
            else
                S1(I) = X(1) + P(I) - ETR(I);
                ETR2(I) = 0;
            end

            %% Calcula infiltra��o do 1o para o 2o tanque
            qi1(I) = X(11)*S1(I);

            %% Calcula armazenamento no Tanque 1 e se h� evapotranspira��o no 2o tanque
            if X(2) + qi1(I) - ETR2(I) < 0
                S2(I) = 0;
                ETR3(I) = abs(X(2) + qi1(I) - ETR2(I));
            else
                S2(I) = X(2) + qi1(I) - ETR2(I);
                ETR3(I) = 0;
            end

            %% Calcula infiltra��o do 2o para o 3o tanque
            qi2(I) = X(12)*S2(I);

            %% Calcula armazenamento no Tanque 3 
            if X(3) + qi2(I) - ETR3(I) < 0
                S3(I) = 0;
               
            else
                S3(I) = X(3) + qi2(I) - ETR3(I);
                
            end


            %% Calcula escoamento do primeiro orificio do 1o tanque
            if  S1(I) > X(4)
                qs1(I) = X(7)*(S1(I) - X(4));
            else
                qs1(I) = 0;
            end
            %% Calcula escoamento do segundo orificio do 1o tanque
            if  S1(I) > X(5)
                qs2(I) = X(8)*(S1(I) - X(5));
            else
                qs2(I) = 0;
            end
            %% Calculo do escoamento dos orificios do 1o tanque
            qst1(I) = qs1(I) + qs2(I);

            %% Calcula o escoamento do orificio do 2o tanque
            if  S2(I) > X(6)
                qs3(I) = X(9)*(S2(I) - X(6));
            else
                qs3(I) = 0;
            end
            qst2(I) = qs3(I);

            %% Calcula o escoamento do orificio do 3o tanque
            
                qs4(I) = X(12)*(S3(I));
  

  
            %% Calculo do armazenamento final dos tanques
            S1f(I) = S1(I) - qst1(I) - qi1(I);
            S2f(I) = S2(I) - qst2(I) - qi2;
            S3f(I) = S3(I) - qs4(I);


            %% Escoamento total que chega ao exut�rio
            Q(I) = qs1(I) + qs2(I) + qs3(I) + qs4(I);
        end

        %% CALCULOS DOS OUTROS DIAS
        if I>1
            %% Calcula armazenamento do tanque1 e se h� evapotranspira��o no 2o tanque
            if (S1f(I - 1) + P(I) - ETR(I)) < 0
                S1(I) = 0;
                ETR2(I) = abs(S1f(I - 1) + P(I) - ETR(I));
            else
                S1(I) = S1f(I - 1) + P(I) - ETR(I);
                ETR2(I) = 0;
            end

            %% Calcula infiltra��o do 1o para o 2o tanque
            qi1(I) = X(11)*S1(I);

            %% Calcula armazenamento do tanque2 e se h� evapotranspira��o no 3o tanque
            if (S2f(I - 1) + qi1(I) - ETR2(I)) < 0
                S2(I) = 0;
                ETR3(I) = abs(S2f(I - 1) + qi1(I) - ETR2(I));
            else
                S2(I) = S2f(I - 1) + qi1(I) - ETR2(I);
                ETR3(I) = 0;
            end

            %% Calcula infiltra��o do 2o para o 3o tanque
            qi2(I) = X(12)*S2(I);

            %% Calcula armazenamento do tanque3 
            if S3f(I - 1) + qi2(I) - ETR3(I) < 0
                S3(I) = 0;
            
            else
                S3(I) = S3f(I - 1) + qi2(I) - ETR3(I);
            
            end


            %% Calcula escoamento do primeiro orificio do 1o tanque
            if  S1(I) > X(4)
                qs1(I) = X(7)*(S1(I) - X(4));
            else
                qs1(I) = 0;
            end
            %% calcula escoamento do segundo orificio do 1o tanque
            if  S1(I) > X(5)
                qs2(I) = X(8)*(S1(I) - X(5));
            else
                qs2(I) = 0;
            end
            %% Calculo do escoamento dos orificios do 1o tanque
            qst1(I) = qs1(I) + qs2(I);

            %% calcula o escoamento do orificio do 2o tanque
            if  S2(I) > X(6)
                qs3(I) = X(9)*(S2(I) - X(6));
            else
                qs3(I) = 0;
            end
            qst2(I) = qs3(I);

            %% calcula o escoamento do orificio do 3o tanque
    
                qs4(I) = X(10)*(S3(I)); 

    

            %% Calculo do armazenamento final dos tanques
            S1f(I) = S1(I) - qst1(I) - qi1(I);
            S2f(I) = S2(I) - qst2(I) - qi2(I);
            S3f(I) = S3(I) - qs4(I);
          

            %% Escoamento total que chega ao exut�rio
            Q(I) = qs1(I) + qs2(I) + qs3(I) + qs4(I);
        end
    end
    QO = Area*QO;
end