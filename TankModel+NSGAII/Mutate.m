%
% Copyright (c) 2015, Yarpiz (www.yarpiz.com)
% All rights reserved. Please read the "license.txt" for license terms.
%
% Project Code: YPEA120
% Project Title: Non-dominated Sorting Genetic Algorithm II (NSGA-II)
% Publisher: Yarpiz (www.yarpiz.com)
% 
% Developer: S. Mostapha Kalami Heris (Member of Yarpiz Team)
% 
% Contact Info: sm.kalami@gmail.com, info@yarpiz.com
%% A função aleatoriamente escolhe um dos parametros do vetor "x" e é mudado
% gerando o novo vetor de parametros "y"
function y=Mutate(x,mu,sigma,VarMin,VarMax)

    nVar=numel(x);      %tamanho do vetor x: 7
    
    nMu=ceil(mu*nVar);  %aredonda o valor a um inteiro positivo:1

    j=randsample(nVar,nMu); %nMu valores aleatorios entre 0-nVar:1,2,3,4,5,6,7   
    if numel(sigma)>1
        sigma = sigma(j);
    end
    
    y=x;
    y(j)=x(j)+sigma.*randn(size(j)); % Mutando e criando o novo vetor de parametros 
    
    while (y(j)<VarMin(j)) || (VarMax(j)<y(j))
        y(j)=x(j)+sigma.*randn(size(j));
        %fprintf('%d ,erro, y= %4.2f \n',j,y(j));
    end
end