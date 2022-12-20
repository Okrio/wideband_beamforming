clc 
clear all 
close all 

%%  ��������
deg2rad = pi/180;        % deg -> rad
rad2deg = 180/pi;        % rad -> deg
jay = sqrt(-1);          % Ϊ�˱����ѭ������i,j����

%% ���м� �źŲ�������
N_array = 12;           % ��Ԫ��
N_snap = 512;           % ������ 
f0=125;
fl = f0/2;              % ����LFM�ź����Ƶ��
fu = f0;               % ����LFM�ź����Ƶ��
fs = 5*f0;              % ����Ƶ��(˵�����������õ�fu��fsǡ���ܱ�֤�ź���������Ԫ����ӳ�Ϊһ�����ĵ�)
T = 1/fs;               % ����ʱ����
t = 0:T:(N_snap-1)*T;   % ����ʱ��� 
TT = (N_snap-1)*T;      % �źų���ʱ��
s = sin(2*pi*(fl+(fu-fl)/(2*TT)*t).*t); % ��������169ҳ��ʽ����LFM�ź�


c = 1500;                      % ���� 
lamda = c/fu;                  % ���� 
d = lamda/2;                   % ��Ԫ��� 
ang_deg = [30];                % ��Դ��λ��(�Ƕ�)  
ang_rad = ang_deg * deg2rad;   % ��Դ��λ��(����)
tau = d/c*sin(ang_rad);        % ������Ԫ���ӳ�ʱ�䣬Ϊ-0.002����-T

%% ������Ԫ�����ź�
for i=1:N_array                
    tt(i,:)=t-(i-1)*tau;
    ttt=tt(i,:);
    ttt(find(ttt<0))=0;
    ttt(find(ttt>TT))=0;
    ss(i,:)= sin(2*pi*(fl+(fu-fl)/(2*TT)*ttt).*ttt);
end

%%  FIR�˲�������
L = 15;             % �˲�������L
f2=0.5*fs;
tao=mod(tau,T);


% �����ӳ�D������
if (tao>=-0.5*T && tao<0.5*T && mod(L,2)==1)  % LΪ�������ӡ�[-0.5Ts,0.5Ts)
    D = (L-1)/2;
elseif (tao>=0 && tao<0.5*T && mod(L,2)==0)    % LΪż�����ӡ�[0Ts,0.5Ts)
    D = L/2-1;
elseif (tao>=-0.5*T && tao<0 && mod(L,2)==0)   % LΪż�����ӡ�[-0.5Ts,0)
	D = L/2+1;
end

%% ���Ӵ� ��һ��Ƶ�㻮��
PB_f1=fl/fs;
PB_fh=fu/fs;
K = 160;                         % ��ɢ��Ƶ�ʵ���K
STEP_d = f2/fs/K;    
F_PB = PB_f1:STEP_d:PB_fh; 
fd = 0:STEP_d:f2/fs-STEP_d;      

%% %%%%%%%%%%%%%%%%%%% part2: FIR�˲���������Ƶ����Ӧ %%%%%%%%%%%%%%%%%%%%%%%

for ii=1:length(F_PB)
        
     weight_all(:,ii)= exp(-jay*2*pi*F_PB(ii)*fs*d/c*sin(ang_rad).*[0:N_array-1]')./N_array; % ���沨���γɣ���Ȩ������Ϊÿ��Ƶ�㴦������Ӧ����

end

for ii=1:N_array    
    
    Tm(ii)=-round(tau*(ii-1)/T+D)*T;
    Hd_pass(:,ii)=(conj(weight_all(ii,:)).*exp(jay*2*pi*F_PB*fs*Tm(ii))).';
    
end

%% %%%%%%%%%%%%%%%% part3: FIR�˲��������Ƶ����Ӧ  2����Լ��׼�� %%%%%%%%%%%%%%%

% Ƶ����Ӧ���� e(f) = [1,exp(-j2��f/fs),...,exp(-j(L-1)2��f/fs)].' 
%        |      1              ...        1                |
% e(f) = | exp(-j2��fd(1))     ...   exp(-j2��fd(81))      |  
%        |     ...             ...        ...              |
%        |exp(-j(L-1)2��fd(1)) ...   exp(-j(L-1)2��fd(81)) |
%       
e_f_pass = exp(-1i*2*pi*(0:L-1).'*F_PB);
e_f_full = exp(-1i*2*pi*(0:L-1).'*fd);  


for ii=1:N_array
    Hd_pass_m=Hd_pass(:,ii);
    cvx_begin
        variable h_2(L,1)
        minimize(norm(e_f_pass.'*h_2 - Hd_pass_m,2))
    cvx_end

    % check if problem was successfully solved
    disp(['Problem is ' cvx_status])
    if ~strfind(cvx_status,'Solved')
      h_2 = [];
    end
    
    h_m(ii,:)=h_2;                    % ��ͬ��Ԫ���˲���ϵ���� ����Ϊ��Ԫ ������Ϊ h(m)
    H_norm_2(:,ii) = e_f_full.'*h_2;  %��ͬ��Ԫ��FIR ��Ӧ  ��Ϊ��Ԫ  ��Ϊ��ͬƵ����Ӧ
    
end

%% filtering 

y_out=zeros(1,N_snap);

for ii=1:N_array
    
   T_m=round(tau*(ii-1)/T+D) ;
   ss_delay =[ ss(ii,1:end) ];
   y_FIR_out=filter(h_m(ii,:),1,ss_delay);
   temp=length(y_FIR_out(T_m+1:end));
   y_add=[y_FIR_out(T_m+1:end) zeros(1,N_snap-temp)];
   y_out=y_out+ y_add;
   
end

%% ��ͼ 

figure()
plot(1:length(t),s); % LFM�ź�ʱ����
xlim([1 N_snap]);
xlabel('(fs = 500Hz,512������)'); 
ylabel(''); 
title('LFM�ź�ʱ����') 

ffts = fft(s);
% ffts = ffts/fs;%����ʱ���������һ�� 1/Ts��˥�������Ա������TsҲ������fs  
df = fs/N_snap;%Ƶ�ʷֱ���  
f = [0:df:df*(N_snap-1)] - fs/2;%Ƶ�ʵ�ת  

%����Ƶ��ͼ
figure() 
% plot(f,abs(ffts));%ֱ�ӻ���FFT���
plot(f,fftshift(abs(ffts)));%�Ȱ������Ұ벿�ֺ���벿�ֶԵ���Ϊ��ʵƵ��
title('LFM�źŷ�Ƶ����');  
xlabel('f/Hz')

% plot all channel signal
figure();
max_value=max(ss(1,:));
for ii=1:size(ss,1)
    
    plot(ss(ii,:)+(ii-1)*max_value*2);
    hold on
    
end
 yticks([0:max_value*2:size(ss,1)*max_value*2])
for i=1:size(ss,1)
    ticklabels{i} = num2str(i);
end
yticklabels(ticklabels)
xlabel('ʱ�����i');
ylabel('��Ԫ���m');
ylim([-2 24])
xlim([0 N_snap])
title('����Ԫ�����źŲ���')



Amplitude_Hd_pass = 20*log10(abs(Hd_pass(:,2)));  % �ڶ�����Ԫ��Ӧ��FIR�˲����� ���� ����λ ��Ӧ
Phase_Hd_pass = angle(Hd_pass(:,2))/pi*180;

Amplitude_H_norm_2 = 20*log10(abs(H_norm_2(:,2)));
Phase_H_norm_2 = angle(H_norm_2(:,2))/pi*180;

figure()
subplot(2,1,1);
plot(F_PB,Amplitude_Hd_pass,'or',...                     % FIR������Ӧ
                           'MarkerEdgeColor','r',...
                           'MarkerFaceColor','r',...
                           'MarkerSize',2);
hold on;
plot(fd,Amplitude_H_norm_2,':k','LineWidth',1);         

legend('����ֵ','���ֵ','Location','SouthWest');
ylabel('����/dB');
xlabel('��һ��Ƶ��');
ylim([-26 -20])
title('��2����Ԫ��ӦFIR�˲������������Ƶ����Ӧ');

subplot(2,1,2);
plot(F_PB,Phase_Hd_pass,'or',...                     % FIR������Ӧ
                       'MarkerEdgeColor','r',...
                       'MarkerFaceColor','r',...
                       'MarkerSize',2);
hold on;
plot(fd,Phase_H_norm_2,':k','LineWidth',1);        % L��  

ylabel('��λ/(��)');
xlabel('��һ��Ƶ��');


figure()
subplot(2,1,1);
plot(y_out);
xlim([0 N_snap])
xlabel('ʱ�����i')
ylabel('y(i)')
title('FIR����������м��ź�Դ����ʧ���С')


subplot(2,1,2);
plot(y_out-s);
xlim([0 N_snap])
ylabel('y(i)-s(i)')
xlabel('ʱ�����i')
ylim([-2*1e-8 2*1e-8])