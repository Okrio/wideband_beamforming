close all;    %�ر������������еĴ���
clear ;    %��ջ���
clc;          %���� �����


%%  parameter
M=12;          %����ռ� ���е� ��Ԫ��Ŀ M=8
d_=0.5;       %��Ϊ����dһ������Ϊ�����˵�һ�룬���Դ˴�ֱ���d/��=0.5
theta=-30*pi/180;
W=2*pi*d_.*sin(theta);    % ����ʸ���У������ź�Դ�Ŀռ���λ
f0=100;       %���Ե�Ƶ�ź�
f1=f0/2;
fu=f0;
fs=5*f0;
N=512;
T=N/fs;   %��ʱ�䳤��
i=0:N;
t=i/fs;   %ʱ�����

s=sin(2*pi*(f1+((fu-f1)/2*T)*t).*t);  %LFM
noise=wgn(M,N+1,0);                   %������



%%  
for m=1:M                       % ��ѭ��Ϊ ������ԪM
     for q=1:N+1                   % Сѭ�� Ϊÿ��������Ԫ�Ͻ��յ���1000�������źŵ��ֵ��q��1 ��1000��Ĭ�ϲ���Ϊ1
         Y=[s(q)];  % �������Y������Ԫ��Ϊ��qʱ�̣������ź�Դ�Ľ�����ֵ��
                                 % m����ڼ�����Ԫ��q��������źŵ�ʱ�̵�
         f=f1+(fu-f1)*q/(fs*T);
         X(m,q)=Y(1)*exp(-j*(m-1)*W(1)*f/1500);
                                 %X(m��q)������ǵ�m����Ԫ����qʱ���յ����ź�
                                 %���У�W��i���ǵ�i���ź�Դ�ļ�Ȩֵ��
     end
end

 X=X;
 syms XK
 for h=1:M
     eval(['XK',num2str(h),'=fft(X(h,:))']);
 end
 
 XKS=[];
 
for h=1:M
    XKS= eval(['[XKS; XK' num2str(h) ']']);
end

v=1:M;
 theta0=-30;                     % ����50�ȣ�������ź�ͨ�������������˳�
 theta0=theta0.*pi/180;          % ��Ϊ������ʽ
 fy0=2*pi*d_.*sin(theta0);
 
 for q=1:N+1
      f=f1+(fu-f1)*q/(fs*T);
 a0=exp(j*(v-1)*fy0*f/1500);           % ������ʸ�� a(��)�е�Ԫ�ر�ʾ����������ֵ��a0
 W0(q,1:12)=a0/M;
 end
 
 K=zeros(1,N+1);
 
 for k=1:N+1
    K(k)=W0(k,:)*XKS(:,k);
 end
KI=ifft(K);
 
%%  PLOT 
figure(1)
plot(real(KI));
xlabel('����');
ylabel('���� ');
title('ʱ���β������');
grid on;                    % �� ��ǰ�����������Ҫ�ĸ��


deta=abs(s)-abs(KI);
figure(2)
plot(deta);
xlabel('����');
ylabel('��� ');
title('DFT�������������');
grid on;                    % �� ��ǰ�����������Ҫ�ĸ��