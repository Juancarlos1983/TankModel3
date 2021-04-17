function createCorrelogram(X1, Y1)
%CREATEFIGURE1(X1,Y1,S1,C1)
%  X1:  scatter x
%  Y1:  scatter y
%  S1:  scatter s
%  C1:  scatter c

% Create figure
figure1 = figure('InvertHardcopy','off','Color',[1 1 1]);

% Create axes
axes1 = axes('Parent',figure1,'FontSize',12,'FontName','times');
hold(axes1,'all');

% Create scatter
% % scatter(X1,Y1,10,'k','x');
% % xlim([0 max([X1 Y1])])
% % ylim([0 max([X1 Y1])])

% Create title
%title('Corelograma de vazões','FontSize',12,'FontName','times');

% Create xlabel
xlabel('Observed Flow(m^3/s)','FontSize',12,'FontName','times');

% Create ylabel
ylabel('Calculated Flow(m^3/s)','FontSize',12,'FontName','times');

