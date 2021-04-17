function f = statistics(Q,QO)

%% function f = evaluate_objective(x, M, V)
% x é o vetor dos parametros.
% Q vazão calculada
% QO vazão observada

%% Calculo das funçoes objetivo
%Inicializa variáveis utilizadas no cálculo das funções objetivo
nt=length(Q);
SFNS=0.0;
SF=0.0;
SF1=0.0;
SF2=0.0;
SF3=0.0;
SQ=0.0;
sobs=0.0;
nsf=0;
Sprod=0.0;

for J = 1:nt
	if QO(J)>0.0                            %VERIFICA FALHA
        nsf=nsf+1;
		SFNS=SFNS+(QO(J)-Q(J))^2.0;         %DESVIO QUADRADO (F.O.PADRÃO)
		SF=SF+abs(QO(J)-Q(J));              %DESVIO ABSOLUTO
		SF1=SF1+((QO(J)-Q(J))^2)/(QO(J));   %DESVIO QUADRADO RELATIVO
		SF3=SF3+(abs(QO(J)-Q(J)))/QO(J);    %DESVIO RELATIVO
		SQ=SQ+Q(J);                         %SOMATORIA Q CALCULADAS
		sobs=sobs+QO(J);                    %SOMATORIA Q OBSERVADAS
		AUXI2=0;
            if Q(J)<0.01
                AUXI=0.00001;
                AUXI2=1;
            end
            if AUXI2==1			
                SF2=SF2+(1./QO(J)-1./AUXI)^2.0;      %DESVIO QUADRADO INVERSO DAS VAZOES
            else
                SF2=SF2+(1./QO(J)-1./Q(J))^2.0;      %DESVIO QUADRADO INVERSO DAS VAZOES
            end
            
            %para calculo do KGE **********************************************************
            %SQ somatoria de vazoes calculadas
            %sobs somatoria de vazoes observadas
            Sprod=Sprod+Q(J)*QO(J);
            %******************************************************************************
	end
end

%para o KGE****************************************************************************
MED_Sim_KGE = SQ/(nsf);
MED_Obs_KGE = sobs/(nsf);
DesPad_Sim_KGE = 0.0;
DesPad_Obs_KGE = 0.0;
%**************************************************************************************
for j = 1:nt
    if(QO(j)>0.0)
        DesPad_Sim_KGE = DesPad_Sim_KGE + ((1./(nsf))*((Q(j)-MED_Sim_KGE)^2));
        DesPad_Obs_KGE = DesPad_Obs_KGE + ((1./(nsf))*((QO(j)-MED_Obs_KGE)^2));
    end
end
DesPad_Sim_KGE = DesPad_Sim_KGE^.5;
DesPad_Obs_KGE = DesPad_Obs_KGE^.5;
Cov_KGE = (1./(nsf))*(Sprod-(SQ*sobs/(nsf)));

Corr_KGE = Cov_KGE/(DesPad_Sim_KGE * DesPad_Obs_KGE);
Alfa_KGE = DesPad_Sim_KGE/DesPad_Obs_KGE;
Beta_KGE = MED_Sim_KGE/MED_Obs_KGE;

KGE = 1. - ((Corr_KGE-1.)^2+(Alfa_KGE-1.)^2+(Beta_KGE-1.)^2)^.5;
%**************************************************************************************

VAZMED=sobs/nsf;
somnash=0.0;
for j = 1:nt
	somnash=somnash+((QO(j)-VAZMED)^2.0);
end

%CALCULO DAS FO -----------------------------
OF(1)=(1. -(SFNS/somnash));        %COEFICIENTE DE NASH-SUTCLIFFE: OF(1)=1.-(SFNS/somnash);
% para a minimização.
OF(2)=(SF2/nsf)^0.5;                    %UNIDADES DE 1/M3/S (AVALIA VAZÕES BAIXAS) ***************
OF(3)=SF1/nsf;                      %DESVIO QUADRADO RELATIVO MEDIO "Relative Mean squared deviation " 
OF(4)=SF/nsf;                       %DESVIO ABSOLUTO MEDIO "Mean Absolute Error"
OF(5)=SF3/nsf;                      %DESVIO RELATIVO MEDIO "Mean relative error"
OF(6)=abs((SQ/sobs-1.)*100.);       %ERRO NO VOLUME - UNIDADE % "percent error"
OF(7)=KGE;                       %RMSE (Kling-Gupta - UNIDADES DE M3/S) ********
f=OF; %Retorna os valores das funções objetivo.
end