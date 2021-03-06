function [Y_ef1,X_ef1,A_n,B_n] = EstimSquare(X_e,Y_e,X_o,Y_o,a_1,b_1,Delta_r) %A_n on X axis B_n on Y Axis
% ESTIMSQUARE : this code is based on Elipse_Angle.m
%
global x_1 y_2 ICX ICY Flag1 Flag2
% Inputs:
% X_e, Y_e : elipse center coordinate
% X_o, Y_o : the original coordinate
% a_l, b_l : ellipse minor & major past
% Delta_r  : estimated shift on R_e
%
% Outputs:
% X_ef1, Y_ef1, A_n, B_n: the new estimated ellipse
%
% Notes:
% Issue: the singularity still may happen in very rare cases.
% To plot output, make: config_plot_on = true
% What is global variable x_1, y_2 for?
% Do we have to change the value of x0?
%%
b_config_plot_on = false;
 hold on
x0 = [Y_e X_e 0 0];

Flag1=0; % means 0-> x_1 F(1) 1-> y_1 F(1)
Flag2=0; % means 0-> x_1 F(1) 1-> y_1 F(1)
% Solver m`y increase computation time, may solve it algebrically in future.
REF = [X_e+2*eps,Y_e+2*eps,X_o+2*eps,Y_o+2*eps,a_1+2*eps,b_1+2*eps];


f = @(x) FindTangentx1(x,REF); % function of dummy variable y
%555
%fsolve doesnt give multiple solutons
opts = optimoptions(@fsolve,'Algorithm', 'levenberg-marquardt');
F = fsolve(f,x0,opts);

Point1(1,1) = real(x_1(1,1));
Point2(1,1) = real(F(1,1));

Point1(2,1) = real(F(1,2));
Point2(2,1) = real(y_2(1,1));

%% Plot the results!
if b_config_plot_on
    hold on
    %subplot(2,2,4)
    th = 0:pi/50:2*pi;%for loop for creating circle
    xunit = (a_1) * cos(th) + X_e;%equation of circle :D
    yunit = (b_1) * sin(th) + Y_e;
    plot(xunit, yunit,'r','LineWidth' , 2);% Ellipse
    hold on
    %  plot(X_o,Y_o,'- *b','MarkerSize', 18,'LineWidth' , 2.5)
    plot(X_o,Y_o,'- *b','MarkerSize', 3,'LineWidth' ,1)
    hold on
    plot(Point1(1,1),Point2(1,1),'- xr','MarkerSize', 10,'LineWidth' , 1)
    hold on
    plot(Point1(2,1),Point2(2,1),'- xr','MarkerSize', 10,'LineWidth' , 1)
    plot(X_e,Y_e,'- om','MarkerSize', 3,'LineWidth' , 1)
    hold on
    drawnow;
end
%plot(ICX,ICY,'- *b','MarkerSize', 18,'LineWidth' , 2.5)

%%
%   R_e R_o
R_e = sqrt((Y_e-Y_o)^2 + (X_e-X_o)^2); %Orignal to Elipse
R_o1 = sqrt((Point2(1,1)-Y_o)^2 + (Point1(1,1)-X_o)^2); %Orignal to contact 1
R_o2 = sqrt((Point2(2,1)-Y_o)^2 + (Point1(2,1)-X_o)^2); %Orignal to contact 2

% for two different side!!! trignomatic
if R_e > R_o1 %Hypto
    alpha1 = acos(R_o1/R_e);
else
    alpha1 = acos(R_e/R_o1);
end

if R_e > R_o2
    alpha2 = acos(R_o2/R_e);
else
    alpha2 = acos(R_e/R_o2);
end


%% Estimated Delta
if R_e > R_o1 %Hypto
	DRo1 = (R_e+Delta_r)*cos(alpha1) - R_o1;
else
	DRo1 = (1/cos(alpha1))*((R_e+Delta_r) - R_o1*cos(alpha1));
end

if R_e > R_o2 %Hypto
	DRo2 = (R_e+Delta_r)*cos(alpha2) - R_o2;
else
	DRo2 = (1/cos(alpha2))*((R_e+Delta_r) - R_o2*cos(alpha2));
end


%% Finding New Tangent points
m_ro1 = ((Point1(1,1)-X_o)/(Point2(1,1)-Y_o+eps)); %the slope of tangent line Ro1
m_ro2 = ((Point1(2,1)-X_o)/(Point2(2,1)-Y_o+eps));%the slope of tangent line Ro2
m_re = ((X_e-X_o)/(Y_e-Y_o+eps)); %the slope of Re (elipse position)


%% Solving for finding (X_n1, Y_n1) and (X_n2,Y_n2)
    Y_nf1 = Point2(1,1)+sqrt(DRo1^2/(m_ro1^2+1));
    X_nf1 = Point1(1,1)+m_ro1*(Y_nf1-Point2(1,1));
    Y_nf2 = Point2(2,1)+sqrt(DRo2^2/(m_ro2^2+1));
    X_nf2 = Point1(2,1)+m_ro2*(Y_nf2-Point2(2,1));
    Lengtholdf1=sqrt((Point2(1,1)-Y_o)^2+(Point1(1,1)-X_o)^2);
    Lengtholdf2=sqrt((Point2(2,1)-Y_o)^2+(Point1(2,1)-X_o)^2);
    Lengthnewf1=sqrt((Y_nf1-Y_o)^2+(X_nf1-X_o)^2);
    Lengthnewf2=sqrt((Y_nf2-Y_o)^2+(X_nf2-X_o)^2);
    if Lengtholdf1 >= Lengthnewf1
        Y_nf1 = Point2(1,1)-sqrt(DRo1^2/(m_ro1^2+1));
        X_nf1 = Point1(1,1)+m_ro1*(Y_nf1-Point2(1,1));
    end

    if Lengtholdf2 >= Lengthnewf2
        Y_nf2 = Point2(2,1)-sqrt(DRo2^2/(m_ro2^2+1));
        X_nf2 = Point1(2,1)+m_ro2*(Y_nf2-Point2(2,1));
    end
%if distance (cross to origin) less then  change sign

hold on
% Algebric results
if b_config_plot_on
    hold on
    plot(X_nf1, Y_nf1,'- xb','MarkerSize', 3,'LineWidth' , 1)
    hold on
    plot(X_nf2, Y_nf2,'- xb','MarkerSize', 3,'LineWidth' , 1)
end

%% Solved Algebriclly
if Y_o < Y_e % working Solution
	Y_ef1 = Y_e+sqrt(Delta_r^2/(m_re^2+1));
	X_ef1 = X_e+m_re*(Y_ef1-Y_e);
else
	Y_ef1 = Y_e-sqrt(Delta_r^2/(m_re^2+1));
	X_ef1 = X_e+m_re*(Y_ef1-Y_e);
end

if b_config_plot_on
    hold on
    plot(X_ef1,Y_ef1,'- ok','MarkerSize', 3,'LineWidth' , 1)
end

B_n = sqrt(abs((((X_o-X_nf1)*(Y_nf1-Y_ef1)^2)-((X_nf1-X_ef1)*(Y_o-Y_nf1)*(Y_nf1-Y_ef1))) / ((X_o-X_nf1+eps))));
A_n = sqrt(abs((B_n^2*(X_o-X_nf1)*(X_nf1-X_ef1)) / ((Y_o-Y_nf1+eps)*(Y_nf1-Y_ef1+eps))));


%% plot
if b_config_plot_on
    hold on
    th = 0:pi/50:2*pi;
    xunit = (abs(A_n)) * cos(th) + X_ef1;%equation of circle :D
    yunit = (abs(B_n)) * sin(th) + Y_ef1;
    plot(xunit, yunit,'b','LineWidth' , 1);% Ellipse
    drawnow;
end




end
