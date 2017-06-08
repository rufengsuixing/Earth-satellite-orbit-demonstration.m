clc;
clear;
close all;
%cla reset;
load topo;
global a e;
%输入参数部分
disp('请输入半长轴a，轨道偏心率e，轨道倾角i（角度），升交点赤经Ω（角度），近地点辐角w（角度），真近点角v（角度）');
AA=input('格式是[a e i Ω w v]，中间用空格或逗号隔开：  ');
a=AA(1); e=AA(2); ii=AA(3)/180*pi; o=AA(4)/180*pi; w=AA(5)/180*pi; v=AA(6)/180*pi;
global x1 y1 z1 x2 y2 z2;
x1 = cos(o) * cos(w) - sin(o) * sin(w) * cos(ii);
y1 = sin(o) * cos(w) + cos(o) * sin(w) * cos(ii);
z1 = sin(w) * sin(ii);
x2 = -cos(o) * sin(w) - sin(o) * cos(w) * cos(ii);
y2 = -sin(o) * sin(w) + cos(o) * cos(w) * cos(ii);
z2 = cos(w) * sin(ii);
%画出理想地球
[x,y,z] = sphere(45);
x=x*0.64e4;
y=y*0.64e4;
z=z*0.64e4;
ax = axes();
s = surface(x,y,z,'linestyle','none','FaceColor','texturemap','CData',topo);
colormap(topomap1);
brighten(.6)
%campos([1.3239  -14.4250  9.4954]);
lighting phong;
camlight;
t = hgtransform('Parent',ax);
set(s,'Parent',t);
axis vis3d;
axis equal;
set(gcf,'Renderer','opengl');
drawnow;
Rz=eye(4);
view(3)
Sxy=Rz;
hold on;
[xp,yp,zp]=culxyz(v);
dingdian=plot3(xp,yp,zp,'*');
v1=0:0.02:2*pi;
[xl,yl,zl]=culxyz(v1);
quxian=plot3(xl,yl,zl);
%set(quxian,'LineSmoothing','on');
title('指定轨道与地球相对图像（单位km）');
word=['卫星当前位置为：(',num2str(xp) ',' num2str(yp) ',' num2str(zp),')'];
text(xp,yp,zp,word);
%h=legend('卫星当前位置','卫星理想轨道','卫星模拟运行');
%set(h,'Location','best');
x11=xlabel('X轴');
x22=ylabel('Y轴');
x3=zlabel('Z轴');
set(x11,'Rotation',30);
set(x22,'Rotation',-30);
grid on;
%{
[xcp1,ycp1,zcp1]=culxyz(a,e,ii,o,w,0);
[xcp2,ycp2,zcp2]=culxyz(a,e,ii,o,w,pi);
xcp=xcp1+xcp2;
ycp=ycp1+ycp2;
zcp=zcp1+zcp2;
T=(a^3/35786^3)^(1/2);
r=0:0.02:2*pi;
r1=(v+pi+r)./T;
[xrp,yrp,zrp]=culxyz(a,e,ii,o,w,r1);
xrp=xcp-xrp;
yrp=ycp-yrp;
zrp=zcp-zrp;
%}
r=v;
er=0;
der=100000/42300^(3/2);     %42300——地球同步轨道高度
for cout=1:60000
    if isempty(get(0,'children'))
        return
    end
    [xd,yd,zd]=culxyz(r);
    dp=plot3(xd,yd,zd,'*');
    h=legend([t,dingdian,quxian,dp],'地球','卫星当前位置','卫星理想轨道','卫星模拟运行');
    set(h,'Location','best');
    Rz=makehgtform('zrotate',er);
    set(t,'Matrix',Rz);
    drawnow;
    %pause(0.1)
    delete(dp);
    dr=100000/(xd^2+yd^2+zd^2)^(3/4);
    er=er+der;
    r=r+dr;
end


function [x3,y3,z3]=culxyz(v)
%画出要求的地球椭圆轨道
%半长轴、偏心率、轨道倾角、近地点幅角、升交点赤经、真近点角
%a, e, ii, w, o , v
global a e;
r = a*(1-e*e)./(1+e*cos(v));
%计算相关参数
global x1 y1 z1 x2 y2 z2;
%计算卫星指定位置
x3=x1*(r .* cos(v))+x2*(r .* sin(v));
y3=y1*(r .* cos(v))+y2*(r .* sin(v));
z3=z1*(r .* cos(v))+z2*(r .* sin(v));
end



% Modify azimuth (horizontal rotation) and update drawing
%{
for az = -50 : .2 : 30
    view(az, 40)
    drawnow
end
  
  
% Modify elevation (vertical rotation) and update drawing
for el = 40 : -.2 : -30
    view(30, el)
    drawnow
end


%多点拟合卫星轨道
v1=0:0.01:2*pi;
r1=a*(1-e*e)./(1+e*cos(v1));
x4=x1*(r1 .* cos(v1))+x2*(r1 .* sin(v1));
y4=y1*(r1 .* cos(v1))+y2*(r1 .* sin(v1));
z4=z1*(r1 .* cos(v1))+z2*(r1 .* sin(v1));




%}
%{
 %卫星的三个方向的初始位置和速度
 y0=[2043922.166765 8186504.631471 4343461.714791 -5379.544693 -407.095342 3516.052656];
[t,result]=ode45(@vdp,[0:1:9000],y0);
X=result(:,1);
Y=result(:,2);
Z=result(:,3);
plot3(X,Y,Z);
axis  vis3d;

function fy=vdp(t,x)
r=x(1)^2+x(2)^2+x(3)^2;
G=3.986005e14;
A=-G/r^(3/2);
fy=[x(4)
    x(5)
    x(6)
    A*x(1)
    A*x(2)
    A*x(3)];
end

%}

