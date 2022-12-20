%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���ƣ��̲�Page179��6.1��С��ʱ��FIR�˲������
% ʱ�䣺2014.04.08~2014.04.10
% ���ߣ�ղ��
% ���ܣ������ź�û��ȷ���������ʽ����Ƴ���ΪL��С��ʱ��FIR�˲������
%       �˴���δ������Ԫ�ĸ��������Ҳ����Ҫ�γɼ�Ȩ����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
clc;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%% part1: ������ʼ�� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���Ե�Ƶ�ź�LPM����
f0 = 1000;      % f0
f1 = 0.5*f0;    
fu = f0;        % f1��fuΪ��Ƶ�ź�Դ�����±߽�Ƶ�� 
fs = 5*f0;      % ����Ƶ��fs
Ts = 1/fs;      % �������Ts
N = 512;        % ��������512
T = N/fs;       % �źų���ʱ�䣬����T*fs = 512��������


% FIR�˲�������
L = 15;             % �˲�������L
tao = 0.12345*Ts;   % �����ӳ�����
fc = 0.4*fs;        % ͨ����ֹƵ��fc
f2 = 0.5*fs;        % ����Ƶ����Եֵ���޷�����
K = 100;            % ��ɢ��Ƶ�ʵ���K

STEP_d = f2/fs/K;    
F_PB = linspace(0,fc/fs,fc/f2*K+1); % �ӳ��˲�����ͨ��F_PB = [0,0.4]
fd_ideal = F_PB;
fd = 0:STEP_d:(f2/fs-STEP_d);       % ����Ƶ��fd = [0,0.5),fd = f/fs ȫƵ��

% �����ӳ�D������
if (tao>=-0.5*Ts && tao<0.5*Ts && mod(L,2)==1)  % LΪ�������ӡ�[-0.5Ts,0.5Ts)
    D = (L-1)/2;
elseif (tao>=0 && tao<0.5*Ts && mod(L,2)==0)    % LΪż�����ӡ�[0Ts,0.5Ts)
    D = L/2-1;
elseif (tao>=-0.5*Ts && tao<0 && mod(L,2)==0)   % LΪż�����ӡ�[-0.5Ts,0)
	D = L/2+1;
end
   
%%%%%%%%%%%%%%%%%%%%% part2: FIR�˲���������Ƶ����Ӧ %%%%%%%%%%%%%%%%%%%%%%%
Hd = exp(-1i*2*pi*fd_ideal*(D+tao/Ts)).'; % fd_ideal = [0,0.4]
Amplitude_Hd = 10*log10(abs(Hd));
Phase_Hd = angle(Hd)/pi*180;

%%%%%%%%%%%%%%%%%% part3: FIR�˲��������Ƶ����Ӧ L�޷���׼�� %%%%%%%%%%%%%%%
% ����Ȩϵ����k
% lambda_k = zeros(1,K);
% for i=1:length(F_PB)
%     lambda_k(i) = 1;
% end

% Ƶ����Ӧ���� e(f) = [1,exp(-j2��f/fs),...,exp(-j(L-1)2��f/fs)].' 
%        |      1              ...        1                |
% e(f) = | exp(-j2��fd(1))     ...   exp(-j2��fd(81))      |  
%        |     ...             ...        ...              |
%        |exp(-j(L-1)2��fd(1)) ...   exp(-j(L-1)2��fd(81)) |
%       
e_f = exp(-1i*2*pi*kron((0:L-1).',fd_ideal));
e_f_full = exp(-1i*2*pi*kron((0:L-1).',fd));

% L��-norm:optimal Chebyshev filter formulation
cvx_begin
    variable h_Inf(L,1)
    minimize(max(abs(e_f.'*h_Inf - Hd)))
cvx_end

% check if problem was successfully solved
disp(['Problem is ' cvx_status])
if ~strfind(cvx_status,'Solved')
  h_Inf = [];
end

% ʹ��L�޷���׼����Ƴ���FIR�˲���
H_Inf = e_f_full.'*h_Inf;
Amplitude_H_Inf = 10*log10(abs(H_Inf));
Phase_H_Inf = angle(H_Inf)/pi*180;

%%%%%%%%%%%%%%%%%% part4: FIR�˲��������Ƶ����Ӧ L1����׼�� %%%%%%%%%%%%%%%
% L1-norm
cvx_begin
    variable h_1(L,1)
    minimize(norm(e_f.'*h_1 - Hd,1))
cvx_end

% check if problem was successfully solved
disp(['Problem is ' cvx_status])
if ~strfind(cvx_status,'Solved')
  h_1 = [];
end

% ʹ��L1����׼����Ƴ���FIR�˲���
H_1 = e_f_full.'*h_1;
Amplitude_H_1 = 10*log10(abs(H_1));
Phase_H_1 = angle(H_1)/pi*180;

%%%%%%%%%%%%%%%%%% part5: FIR�˲��������Ƶ����Ӧ L2����׼�� %%%%%%%%%%%%%%%
% L2-norm
cvx_begin
    variable h_2(L,1)
    minimize(norm(e_f.'*h_2 - Hd,2))
cvx_end

% check if problem was successfully solved
disp(['Problem is ' cvx_status])
if ~strfind(cvx_status,'Solved')
  h_2 = [];
end

% ʹ��L1����׼����Ƴ���FIR�˲���
H_2 = e_f_full.'*h_2;
Amplitude_H_2 = 10*log10(abs(H_2));
Phase_H_2 = angle(H_2)/pi*180;

%%%%%%%%%%%%%%%%%%%% part6: �����ӳٲ�����FIR�˲����ӳٲ��� %%%%%%%%%%%%%%%%%
t = (0:1:N-1)./fs;
s_ideal_LPM = zeros(1,length(t));
s_delay_LPM = zeros(1,length(t));
for i=1:length(t)
    s_ideal_LPM(i) = sin(2*pi*(f1+(fu-f1)/(2*T)*t(i))*t(i));
	s_delay_LPM(i) = sin(2*pi*(f1+(fu-f1)/(2*T)*(t(i)-tao))*(t(i)-tao));
end

% L��,L1,L2׼��С��ʱ���˲���
y_FIR_delay = zeros(3,length(t)+L-1);       % ���������źų���512+L-1
y_FIR_delay(1,:) = conv(s_ideal_LPM,h_Inf);	% L��
ww=filter(h_Inf,1,s_ideal_LPM);
y_FIR_delay(2,:) = conv(s_ideal_LPM,h_1);   % L1
y_FIR_delay(3,:) = conv(s_ideal_LPM,h_2);   % L2

% �����ӳ�D=7������
y_FIR_delay_valid = zeros(3,length(t));
for i=1:length(t)
    y_FIR_delay_valid(1,i) = y_FIR_delay(1,D+i); % L��
    y_FIR_delay_valid(2,i) = y_FIR_delay(2,D+i); % L1
    y_FIR_delay_valid(3,i) = y_FIR_delay(3,D+i); % L2
end

%%%%%%%%%%%%%%%%%%%%%% part7: plot all figures %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure1: FIR�˲���������Ӧ 
subplot(2,1,1);
plot(fd_ideal,Amplitude_Hd,'or',...                     % FIR������Ӧ
                           'MarkerEdgeColor','r',...
                           'MarkerFaceColor','r',...
                           'MarkerSize',2);
hold on;
plot(fd,Amplitude_H_Inf,':k','LineWidth',2);    % L��
hold on;
plot(fd,Amplitude_H_1,'--b','LineWidth',2);     % L1
hold on;
plot(fd,Amplitude_H_2,'-g','LineWidth',2);      % L2
legend('����ֵ','{\itL}_��׼��','{\itL}_1׼��','{\itL}_2׼��','Location','SouthWest');
ylabel('����/dB');
axis([0 0.5 -1.5 0.25]);

% figure2: FIR�˲�����λ��Ӧ
subplot(2,1,2);
plot(fd_ideal,Phase_Hd,'or',...                     % FIR������Ӧ
                       'MarkerEdgeColor','r',...
                       'MarkerFaceColor','r',...
                       'MarkerSize',2);
hold on;
plot(fd,Phase_H_Inf,':k','LineWidth',2);        % L��  
hold on;
plot(fd,Phase_H_1,'--b','LineWidth',2);         % L1
hold on;
plot(fd,Phase_H_2,'-g','LineWidth',2);          % L2
xlabel('����Ƶ��{\itf}_d');
ylabel('��λ/(��)');
axis([0 0.5 -200 200]);

% figure3: ������
figure;
plot(fd_ideal,abs(H_Inf(1:length(F_PB))-Hd),':k','LineWidth',2);    % L��
hold on;
plot(fd_ideal,abs(H_1(1:length(F_PB))-Hd),'--b','LineWidth',2);     % L1
hold on;
plot(fd_ideal,abs(H_2(1:length(F_PB))-Hd),'-g','LineWidth',2);      % L2
legend('{\itL}_��׼��','{\itL}_1׼��','{\itL}_2׼��','Location','NorthWest');
xlabel('{\itf}_d');
ylabel('|{\itH}({\itf}_d)-{\itH}_d({\itf}_d)|');
axis([0 0.4 0 8*10^(-3)]);

% figure4: ������ζԱ�
figure;
subplot(4,1,1);
plot(t*fs,s_delay_LPM);     % �����ӳٲ���
ylabel('�����ӳٲ���');
axis([0 N-1 -1.2 1.2]);

subplot(4,1,2);
plot(t*fs,y_FIR_delay_valid(1,:));   % L�� ׼�����
ylabel('{\itL}_��׼��');
axis([0 N-1 -1.2 1.2]);

subplot(4,1,3);
plot(t*fs,y_FIR_delay_valid(2,:));   % L1׼�����
ylabel('{\itL}_1׼��');
axis([0 N-1 -1.2 1.2]);

subplot(4,1,4);
plot(t*fs,y_FIR_delay_valid(3,:));   % L2׼�����
xlabel('\iti');
ylabel('{\itL}_2׼��');
axis([0 N-1 -1.2 1.2]);

% ����׼���£��������
figure;
subplot(3,1,1);
plot(t*fs,y_FIR_delay_valid(1,:)-s_delay_LPM);   % L�� ׼��
axis([0 N-1 -5*10^(-3) 5*10^(-3)]);
ylabel('{\itL}_��׼�������');

subplot(3,1,2);
plot(t*fs,y_FIR_delay_valid(2,:)-s_delay_LPM);   % L1׼��
axis([0 N-1 -5*10^(-3) 5*10^(-3)]);
ylabel('{\itL}_1׼�������');

subplot(3,1,3);
plot(t*fs,y_FIR_delay_valid(3,:)-s_delay_LPM);   % L2׼��
axis([0 N-1 -5*10^(-3) 5*10^(-3)]);
xlabel('\iti');
ylabel('{\itL}_2׼�������');
