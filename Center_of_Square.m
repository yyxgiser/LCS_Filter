CanswerA=[1 2 1;3 10 4;19 3 2];
for i=1:1:numel(CanswerA(:,1))

    th = 0:pi/50:2*pi;%for loop for creating circle
    CB = 1;
            xunit = (CanswerA(i,3) ) * cos(th) + CanswerA(i,2);%equation of circle :D
            yunit = (CanswerA(i,3) ) * sin(th) + CanswerA(i,1);
            ploti = plot(xunit, yunit,'g');% Ellipse
    hold on    
end
Cv_Y=(mean(CanswerA(:,1))) % Virtual Center of Y for Square 
Cv_X=(mean(CanswerA(:,2))) %Virtual Center of Y for Square 
plot(Cv_X,Cv_Y,'- xb','MarkerSize', 18,'LineWidth' , 2.5)  

% CanswerAN=CanswerA(:,1)-Cv_Y
% CanswerAN=CanswerA(:,2)-Cv_X

TempYPositive=max(CanswerA(:,1)-Cv_Y+CanswerA(:,3)) %Y 
TempYNegaitive=min(CanswerA(:,1)-Cv_Y-CanswerA(:,3)) %Y 
TempXPositive=max(CanswerA(:,2)-Cv_X+CanswerA(:,3)) %Y 
TempXNegaitive=min(CanswerA(:,2)-Cv_X-CanswerA(:,3)) %Y    

Y_o=((TempYPositive-TempYNegaitive)/2)+Cv_Y
X_o=((TempXPositive-TempXNegaitive)/2)+Cv_X
a=abs(TempYPositive-TempYNegaitive)/2+Cv_Y; %height
b=abs(TempXPositive-TempXNegaitive)/2+Cv_X;
plot(X_o,Y_o,'- *b','MarkerSize', 18,'LineWidth' , 2.5)  

plot([X_o-b X_o-b],[Y_o-a Y_o+a],'r')
plot([X_o-b X_o+b],[Y_o-a Y_o-a],'r')
plot([X_o+b X_o-b],[Y_o+a Y_o+a],'r')
plot([X_o+b X_o+b],[Y_o+a Y_o-a],'r')