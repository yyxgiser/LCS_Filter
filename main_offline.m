% main_offline.m
clc
clear lambda psi En Er C alpha Trs Trcr Cr ploti
clear delta
close all
%set(0,'DefaultTextInterpreter','Latex');
%addpath('./helpers/')

%% intial conditions
% screen parameteres
SCREEN_X = 640;
SCREEN_Y = 480;
global ICX ICY b_config_plot_on
b_config_plot_on = true; %Ploting Graph
ICX = SCREEN_X / 2+eps;  %2
ICY = SCREEN_Y / 2+eps;  %1

% algorithm constants
lambda = 0;
psi = 0; %first is x next is y? O_
En = 0;
Er = 0;
C  = 0;
Cr = 0;
S = 0;
delta = zeros(5, 4); %[0 0 0 0;0 0 0 0;0 0 0 0;0 0 0 0;0 0 0 0];

%% algoritm parameters
alpha = [0 0 0 0 0 0 0];
global Trs Trcr Trmax TrsSq TrcrSq TrmaxSq
global frame Av Vv deltay deltaz

frame = 1; %Every Sec one frame! Works

% trust parameters
Trs   = 3;
Trcr  = 2;
Trmax = 5;

TrsSq=5;
TrcrSq=3;
TrmaxSq=7;

% kinematic variables (simulated)
Dv = 0.1;
Av = 0.0005;
Vv = .03;
deltay = 9;
deltaz = 9;
Fcount=1;
%% main code begins
drs = './example_pictures'; % in current directory
dr1 = dir([drs '/*.jpg']);  % get all png files in the folder
f1 = {dr1.name};           % get filenames to cell

%mkdir('./results')          % dir for saving results

% loop for each image
for c = 1:length(f1)
 %   tic

    % read one image
    i = imread([drs '/' f1{c}]);

    %BL=100; %boundery layer Cylindrical-tin

    % convert image into greyscale
    if b_config_plot_on
    figure(c)
    end
    if length(size(i)) == 3
        im = double(i(:,:,2));
    else
        im = double(i);
    end

    %c9 = fast9(im, 30, 1);      % run fast9 edge detection
    c9 = detectFASTFeatures(rgb2gray(i),'MinContrast',0.18);
    c9 = c9.Location;
    %c9 = corner(rgb2gray(i), 'MinimumEigenvalue');
if b_config_plot_on
    axis image
    colormap(gray)

    subplot(2,2,1)
    hold on
    imshow(im / max(im(:)));
    plot(c9(:,1),c9(:,2),'r.'); % edges

    subplot(2,2,2)
    hold on
    imshow(im / max(im(:)));

    subplot(2,2,3)
    hold on
    imshow(im / max(im(:)));

        subplot(2,2,4)
    hold on
    imshow(im / max(im(:)));
end

    c9 = [c9(:,2),c9(:,1)];     % swap x and y columns
    if c == 1
        Size(c,1) = numel(c9(:,1));
    else
        Size(c,1) = numel(c9(:,1))+Size(c-1,1);
    end
    Size(c,6) = numel(c9(:,1));
    Edge = c9;
    %--------Algo begins HERE ......!!!!!
    Edge = Line(lambda,psi,Edge);
    [En,Er,C,Cr,psi,lambda,alpha,delta] = Circle(Edge,C,Cr,En,Er,psi,delta,Vv,Dv,lambda,alpha);
%     if S==0
%     S=[100 100 40 30 6 60 .1 200 160;112 134 20 20 4 30 .05 100 180];
%     end
    [S, psi] = Square(S, C, Cr, delta, Vv, Dv, psi);

    % Square() add square here
    Size(c,2) = numel(En(:,1));
    Size(c,3) = numel(Er(:,1));
    Size(c,4) = numel(C(:,1));
    Size(c,5) = numel(Cr(:,1));
    Size(c,6) = numel(S(:,1));
  %  Size(c,9) = toc;
    if Fcount<6 % 5 Frame Sum
        Ptemp(Fcount)= numel(c9(:,1));
        Size(c,7) = sum(Ptemp);
        Fcount=Fcount+1;
    else
        Fcount=1;
        Ptemp(Fcount)= numel(c9(:,1));
        Size(c,7) = sum(Ptemp);
    end
    %***************************************************! Add step k
    %velocity to C and S and Subtract the vel. of k-1*!
    %delta
    %delta=[0 0 0 0;0 0 0 0;0 0 0 0;0 0 0 0;0 0 0 0];
  if b_config_plot_on  
    hold on
    subplot(2,2,2)
    ploti = plot(En(:,2),En(:,1),'bs');
    xlim([1 640])
    ylim([1 480])
    hold on
    th = 0:pi/50:2*pi;%for loop for creating circle
    CB = 1;
    hold on
    %plot(ICX,ICY,'- *b','MarkerSize', 18,'LineWidth' , 2.5)
    if C == 0
        % pass
    else
        for i = 1:1:(numel(C(:,1)))
            xunit = (C(i,3) + CB) * cos(th) + C(i,2);%equation of circle :D
            yunit = (C(i,3) + CB) * sin(th) + C(i,1);
            subplot(2,2,3)
            ploti = plot(xunit, yunit,'g','LineWidth' , 1.5);%Plot the boys :v
            xlim([1 SCREEN_X])
            ylim([1 SCREEN_Y])
        end
    end
    CB = 10;
    if Cr == 0
        % pass
    else
        for i = 1:1:(numel(Cr(:,1)))
            xunit = (Cr(i,3) + CB) * cos(th) + Cr(i,2);%equation of circle :D
            yunit = (Cr(i,3) + CB) * sin(th) + Cr(i,1);
            subplot(2,2,3)
            ploti = plot(xunit, yunit,'r','LineWidth' , 2);%Plot the boys :v
            xlim([1 SCREEN_X])
            ylim([1 SCREEN_Y])
        end
    end
       if S == 0
        % pass
        else
        for i = 1:1:(numel(S(:,1)))
            subplot(2,2,4)
            hold on
            TempYPositive= S(i,1)+S(i,3); %
            TempYNegaitive=S(i,1)-S(i,3); %
            TempXPositive=S(i,2)+S(i,4); %
            TempXNegaitive=S(i,2)-S(i,4); %
            %plot(X_o,Y_o,'- *b','MarkerSize', 18,'LineWidth' , 2.5)
            plot([TempXPositive TempXPositive],[TempYNegaitive TempYPositive],'m','LineWidth' , 2)
            plot([TempXNegaitive TempXPositive],[TempYPositive TempYPositive],'m','LineWidth' , 2)
            plot([TempXNegaitive TempXNegaitive],[TempYNegaitive TempYPositive],'m','LineWidth' , 2)
            plot([TempXNegaitive TempXPositive],[TempYNegaitive TempYNegaitive],'m','LineWidth' , 2)
            %ploti = plot(xunit, yunit,'r');%Plot the boys :v
            xlim([1 SCREEN_X])
            ylim([1 SCREEN_Y])
        end
       end


    hold on
    subplot(2,2,2)

    hold on
    xlabel('$\bf{E}_n, \bf{E}_r$, $\bf{\tilde{E}}_n$ and $\bf{\tilde{E}}_r$','FontSize',16,'Interpreter','latex')
    hold on
    subplot(2,2,1)
    %txt = ['Frame ',num2str(c)];
    %title(txt,'FontSize',16)
    hold on
    xlabel('\boldmath${\chi}$, \boldmath${\lambda}$ and \boldmath${\psi}$','FontSize',16,'Interpreter','latex')
    subplot(2,2,4)
    %txt = ['Frame ',num2str(c)];
    %title(txt,'FontSize',16)
    hold on
    xlabel('$\bf{S}$ and \boldmath${\psi}_S$','FontSize',16,'Interpreter','latex')
    subplot(2,2,3)
    %txt = ['Frame ',num2str(c)];
    %title(txt,'FontSize',16)
    hold on
    xlabel('$\bf{C}_n,\bf{C}_r$ and \boldmath${\psi}_C$','FontSize',16,'Interpreter','latex')

    subplot(2,2,1)
    hold on
    txt = ['Frame ',num2str(c)];
    text(900,600,txt,'FontSize',16)
  %  set(gca,'OuterPosition',[0 0.15 0.31 0.7]);
    subplot(2,2,2)
    hold on
   %  set(gca,'OuterPosition',[0.35 0.15 0.29 0.7]);
    subplot(2,2,3)
    hold on
    % set(gca,'OuterPosition',[0.7 0.15 0.31 0.7]);

    set(gcf,'Units','Inches','renderer','Painters');
   % set(gcf,'Units','Inches');
    pos = get(gcf,'Position');

    %---------- Save Plot
    set(gcf, 'Position',  [100, 100, 1920, 1080])
    set(gcf, 'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(2)*3.3, pos(3)*1.3])

    fig_filename = ['./results/fig', num2str(c),'.png'];
    saveas(gca, fig_filename);
    % %--------------------
  end
  %  toc
end

clear figure
