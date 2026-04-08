dt = 1e-3; 
% t = t.Data; 
clc

v = v_mPs.Data; 
a = a_mPs2.Data; 
j = gradient(a,dt);
F_friction_test = F_friction_N.Data + 16.5;
% close all 

% --- Geçiş Yumuşaklığı Parametresi ---
% Bu değer büyüdükçe 0'daki eğim azalır (daha eğimli geçer)
eps_smooth = 0.0223;
% eps_smooth = 0.015;

%%%
kv_p = 12; Fc_p = 25; Fs_p  = 383; tau_p = 0.016;
kv_n = 35; Fc_n = 7.5; Fs_n = 183; tau_n = 0.02016;
%%%

% Buraya Lugre gelebilir belki

% Yumuşatılmış yön fonksiyonu (sign yerine tanh)
% Bu fonksiyon -1 ile 1 arasında yumuşak bir geçiş sağlar
smooth_sign = tanh(v ./ eps_smooth);

% Asimetrik katsayı vektörleri oluşturma
% Hızın yönüne göre katsayıları seçiyoruz
kv = (v >= 0)*kv_p + (v < 0)*kv_n;
Fc = (v >= 0)*Fc_p + (v < 0)*Fc_n;
Fs = (v >= 0)*Fs_p + (v < 0)*Fs_n;
tau = (v >= 0)*tau_p + (v < 0)*tau_n;
F_stribeck = (kv .* v) + (Fc .* smooth_sign) + (Fs .* smooth_sign .* exp(-abs(v./tau)));


% K_acc = 1.121235; 
% K_jerk = 0.056481; 


K_acc_p = 1.021235; 
K_acc_n = 0.0810121235; 

K_jerk_p = -0.05656481; 
K_jerk_n = 0.02056481; 

K_acc = (v>=0)*K_acc_p + (v<0)*K_acc_n; 
K_jerk = (v>=0)*K_jerk_p + (v<0)*K_jerk_n; 

F_friction_nodelay = F_stribeck + K_acc .* a  +  K_jerk.*j; 

% figure
clf
plot(v,F_stribeck,'.b')
hold on 
plot(v,F_friction_nodelay,'.r')
plot(v,F_friction_test,'.k')
grid on 
legend('F_stribeck','F_friction_nodelay','F_friction_test')

%%
% figure
% clf
% plot(t.Time,F_friction_test,'-k')
% hold on 
% plot(t.Time,F_friction_nodelay,'-r')
% grid on 
