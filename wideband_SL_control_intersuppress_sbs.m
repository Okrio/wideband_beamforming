clc;
clear all;
close all;
%%
M=12;
f0=1000;
fl=f0/2;
fu=f0;
fs=3.125*f0;

Ts=1/fs;
c=1500;
d=c/fu/2*[0:M-1];

Fpb=(0.16:0.005:0.32);                                            %ͨ��
Fsb=[(0:0.005:0.13) (0.35:0.005:0.50)];                           %���

Fd=0:0.005:0.5;  
fpb=Fpb*fs;
fsb=Fsb*fs;
N_fk=length(Fpb);

theta=(-90:2:90);
thetaSL_left_lowfre=(-90:2:-24);
thetaSL_right_lowfre=(24:2:90);
thetaSL_lowfre=[thetaSL_left_lowfre thetaSL_right_lowfre];


thetaSL_left_highfre=(-90:2:-16);
thetaSL_right_highfre=(16:2:90);
thetaSL_highfre=[thetaSL_left_highfre thetaSL_right_highfre];

thetas=0;
thetai=50;
INR=30;   % �����30dB
WG_loss=2;
p_white_noise=1;
p_inter=10^(INR/10)*p_white_noise;
wf_norm_square=10^((WG_loss-10*log10(M))/10);
tau = d/c*sin(thetas/180*pi);
%% �˲�������
L=64;
D=L/2;
for ii=1:M    
   Tm(ii)=-round(tau(ii)/Ts+D)*Ts;    
end  
%% �԰���Ƹ����� -Ƶ����Ӵ���Ȩֵ�Ż����
SL=-25;  %�����԰꼶
for ii=1:N_fk
    
    if ii<N_fk/2
        p_theta_SL=exp(-1i*2*pi*fpb(ii)*d'*sin(thetaSL_lowfre/180*pi)/c);
    else
        p_theta_SL=exp(-1i*2*pi*fpb(ii)*d'*sin(thetaSL_highfre/180*pi)/c);
    end
    p_theta_S=exp(-1i*2*pi*fpb(ii)*d'*sin(thetas/180*pi)/c);
    p_theta_inter=exp(-1i*2*pi*fpb(ii)*d'*sin(thetai/180*pi)/c);
    R=p_inter.*(p_theta_inter*p_theta_inter')+p_white_noise.*eye(M);
    
    cvx_begin
    variable w_f(M,1) complex
    minimize (w_f'*R*w_f)
       
    subject to
    
    Beam_SL=w_f'*p_theta_SL;
    p_s=w_f'*p_theta_S;
    
    p_s==1
    abs(Beam_SL)<=10^(SL/20)
    norm(w_f,2)<=sqrt(wf_norm_square)
    cvx_end
    w_f_all(:,ii)=w_f;
end

 %%  FIR �˲����Ż����
error_constraint=0.01;
e_f_pass = exp(-1i*2*pi*(0:L-1).'*Fpb);
e_f_stop = exp(-1i*2*pi*(0:L-1).'*Fsb);
e_f_full = exp(-1i*2*pi*(0:L-1).'*Fd);  
    
delay_pb_matrix=exp(1i*2*pi*Tm'*Fpb*fs); % Ԥ�ӳ�ͨ����λ����
delay_fd_matrix=exp(1i*2*pi*Tm'*Fd*fs);  %Ԥ�ӳ�ȫƵ����λ����
Hd_pass=conj(w_f_all).*delay_pb_matrix;
    
for ii=1:M

       Hd_pass_m=Hd_pass(ii,:);
       cvx_begin
       variable h(1,L)
       minimize(norm(h*e_f_pass - Hd_pass_m,2))
       
       subject to
       max(abs(h*e_f_stop)) <= error_constraint
       cvx_end
       h_m(ii,:)=h;
end
    
W_FK=h_m*e_f_pass ; %FIRl�˲���ͨ��Ƶ�죨δԤ�ӳ٣�
H_m=h_m*e_f_full;  %FIR�˲���ȫƵ����Ӧ ��δԤ�ӳ٣�

%% PLOT
figure();
for ii=1:length(fpb)    
    w_ff=w_f_all(:,ii);
    a=exp(-1i*2*pi*fpb(ii)*d'*sin(theta/180*pi)/c);   
    Beam_fre_domain(ii,:)=w_ff'*a;
    plot(theta,20*log10(abs(Beam_fre_domain(ii,:))));
    hold on
end
xlim([-90 90])  
ylim([-100 5])
title('Ƶ����Ƹ��Ӵ�����ͼ')
ylabel('����/dB')
xlabel('��λ/(��)')

figure();
for ii=1:length(fpb)
    w_ff=W_FK(:,ii).*conj(delay_pb_matrix(:,ii));
    a=exp(-1i*2*pi*fpb(ii)*d'*sin(theta/180*pi)/c);   
    Beam_time_domain(ii,:)=w_ff.'*a;
    plot(theta,20*log10(abs(Beam_time_domain(ii,:))));
    hold on 
end
xlim([-90 90])
ylabel('����/dB')
xlabel('��λ/(��)')
title('FIR�����γ������Ӵ�����ͼ');

