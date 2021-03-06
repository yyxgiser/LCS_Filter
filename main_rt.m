clc
clear m cam lambda psi En Er C alpha Trs Trcr Cr
addpath('./helpers/')

%--------------------------- Parameters
CAM_WIDTH = 640;
CAM_HEIGHT = 480;

%--------------------------- Open Camera
%cam = webcam('USB Camera'); %camera name  USB2.0 Camera USB Video Device
%cam = webcam('Logitech HD Pro Webcam C920');
cam = webcam(1);
cam.Resolution = sprintf('%dx%d', CAM_WIDTH, CAM_HEIGHT);
%preview(cam)

% Main intial conditions
%--------------------------- Algorithm Constants
lambda = 0;
psi = 0; %first is x next is y? O_
En = 0;
Er = 0;
C  = 0;
Cr = 0;
S = 0;
delta = zeros(5, 4); %[0 0 0 0;0 0 0 0;0 0 0 0;0 0 0 0;0 0 0 0];
%----------------------------
alpha = [0 0 0 0 0 0 0];
global Trs Trcr Trmax TrsSq TrcrSq TrmaxSq
global frame Av Vv deltay deltaz
Trs = 3;
Trcr = 2;
Trmax = 5;
delta = 0;
Dv = .1;
Trs   = 3; %Circle Expert Trust
Trcr  = 2; %Circle Expert Critical Trust
Trmax = 5; % Circle Expert Maximum Trust

TrsSq=4; %Square Expert Trust
TrcrSq=3; %Square Expert Critical Trust
TrmaxSq=6; % Square Expert Maximum Trust
SCREEN_X = 640; %Image Dim.
SCREEN_Y = 480; % Image Dim.

global ICX ICY
ICX = SCREEN_X / 2+eps;  %2
ICY = SCREEN_Y / 2+eps;  %1
%-------- Sensors
%m = mobiledev;
pause(5);

%---------
while(1)
    tic
    img = snapshot(cam);% begin snap
    i = img;
    % Make image greyscale
    if length(size(i)) == 3
        im = double(i(:,:,2));
    else
        im = double(i);
    end

    %c9 = fast9(im, 30, 1);      % run fast9 edge detection
    c9 = detectFASTFeatures(rgb2gray(i),'MinContrast',0.2);
    c9 = c9.Location;
    %c9 = corner(rgb2gray(i), 'MinimumEigenvalue');

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


    c9 = [c9(:,2),c9(:,1)];     % swap x and y columns

    Edge = c9;

    %%
    % Transision V
    hold on
    Edge = Line(lambda,psi,Edge);
    frame = toc;
    

    %% IMU Sensor Data
%-------Trail With IMU
%     [a, t] = accellog(m);
%     [o, t] = orientlog(m);
%     Av = a(end,1) - a(end-10,1);
%     Vv = abs(cumtrapz(a(end-2:end,1) - a(end-10,1)));
%     Vv = Vv(end,1);
%     deltay = abs(180-abs(o(end,1))) + 2;
%     deltaz = abs(o(end,3)) + 2;
% 
%     wf = 1;
%     wm = 1;
%     quest = QUEST(fb, mb, fn, mn, wf, wm); % Quest Filter Observer (IMU)
%     [Quest1, Quest2, Quest3] = ... %Angles

%------ Trail without IMU
    Av = 0.0005; % Accelertion in Direction of motion
    Vv = .03; % Velocity in direction of motion
    deltay = 9; % Calculated Angular error along y axis
    deltaz = 9; % Calculated Angular error along z axis
    
        %% Kinematic Rotation of Location/Angles Parameters
    %The locations, angles and origins are updated 
    if En==0
        
    else
DAngy=deltay; %angular differences
DAngx=deltax;
Rx=[1 0 0;0 cos(DAngx) -sin(DAngx);0 sin(DAngx) cos(DAngx)];
Ry=[cos(DAngy) 0 sin(DAngy);0 1 0;-sin(DAngy) 0 cos(DAngy)];
R=Ry*Rx;
LEn=[En(:,1),En(:,2),zeros(numel(En(:,1)),1)]*R;
En(:,1:2)=[LEn(:,1:2)];
LEr=[Er(:,1),Er(:,2),zeros(numel(Er(:,1)),1)]*R;
Er(:,1:2)=[LEr(:,1:2)];
LCn=[C(:,1),C(:,2),zeros(numel(C(:,1)),1)]*R;
C(:,1:2)=[LCn(:,1:2)];
LCr=[Cr(:,1),Cr(:,2),zeros(numel(Cr(:,1)),1)]*R;
Cr(:,1:2)=[LCr(:,1:2)];
LS=[S(:,1),S(:,2),zeros(numel(S(:,1)),1)]*R;
S(:,1:2)=[LS(:,1:2)];


    end

%%
    [En,Er,C,Cr,psi,lambda,alpha,delta] = Circle(Edge,C,Cr,En,Er,psi,delta,Vv,Dv,lambda,alpha);
    [S, psi] = Square(S, C, Cr, delta, Vv, Dv, psi);
    %delta
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
            ploti = plot(xunit, yunit,'g');%Plot the boys :v
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
            ploti = plot(xunit, yunit,'r');%Plot the boys :v
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
    hold on
    plot([TempXNegaitive TempXPositive],[TempYPositive TempYPositive],'m','LineWidth' , 2)
    plot([TempXNegaitive TempXNegaitive],[TempYNegaitive TempYPositive],'m','LineWidth' , 2)
    plot([TempXNegaitive TempXPositive],[TempYNegaitive TempYNegaitive],'m','LineWidth' , 2)
    hold on
            %ploti = plot(xunit, yunit,'r');%Plot the boys :v
            xlim([1 SCREEN_X])
            ylim([1 SCREEN_Y])
        end
       end
    drawnow


    hold on
    subplot(2,2,2)

    hold on
    xlabel('${E}_n, {E}_r$, $\tilde{E}_n$ and $\tilde{E}_r$','FontSize',16,'Interpreter','latex')
    hold on
    subplot(2,2,1)
    %txt = ['Frame ',num2str(c)];
    %title(txt,'FontSize',16)
    hold on
    xlabel('${\chi}, {\lambda}, \psi$','FontSize',16,'Interpreter','latex')
    subplot(2,2,4)
    %txt = ['Frame ',num2str(c)];
    %title(txt,'FontSize',16)
    hold on
    xlabel('${S},\psi_S$','FontSize',16,'Interpreter','latex')
    subplot(2,2,3)
    %txt = ['Frame ',num2str(c)];
    %title(txt,'FontSize',16)
    hold on
    xlabel('${C}_n,{C}_r, \psi_C$','FontSize',16,'Interpreter','latex')

    clear figure
    delta = [0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 0 0; 0 0 0 0];
end % end of while: dont touch while !!!

%----------
clear(cam)


%
%     hold on
%     subplot(1,2,1)
%     plot(En(:,2),En(:,1),'bs')
%     xlim([1 CAM_WIDTH])
%     ylim([1 CAM_HEIGHT])
%     hold on
%     th = 0:pi/50:2*pi;% for loop for creating circle
%     CB = 1;
%     hold on
%     if C == 0
%         % pass
%     else
%         for i = 1:1:(numel(C(:,1)))
%             xunit = (C(i,3) + CB) * cos(th) + C(i,2);% equation of circle :D
%             yunit = (C(i,3) + CB) * sin(th) + C(i,1);
%             subplot(1,2,2)
%             plot(xunit, yunit,'g');% Plot the boys :v
%             xlim([1 CAM_WIDTH])
%             ylim([1 CAM_HEIGHT])
%         end
%     end
%     hold on
%     CB = 1;
%     if Cr == 0
%         % pass
%     else
%         for i = 1:1:(numel(Cr(:,1)))
%             xunit = (Cr(i,3)+CB) * cos(th) + Cr(i,2);% equation of circle :D
%             yunit = (Cr(i,3)+CB) * sin(th) + Cr(i,1);
%             subplot(1,2,2)
%             plot(xunit, yunit, 'r');% Plot the boys :v
%             xlim([1 CAM_WIDTH])
%             ylim([1 CAM_HEIGHT])
%         end
%     end
%     size(En)
%     size(Er)
