v = [-0.6:1e-4:0.6];

v_data = v_mPs.Data; 
F_friction_data = F_friction_N.Data; 
plot(v_data,F_friction_data,'-')


% --- Geçiş Yumuşaklığı Parametresi ---
% Bu değer büyüdükçe 0'daki eğim azalır (daha eğimli geçer)
eps_smooth = 0.002; 

% --- Pozitif Yön (v > 0) ---
kv_p = 20; kc_p = 15; ks_p = 82.9; tau_p = 0.016;

% --- Negatif Yön (v < 0) ---
kv_n = 35; kc_n = 22; ks_n = 75.17; tau_n = 0.016;

% Yumuşatılmış yön fonksiyonu (sign yerine tanh)
% Bu fonksiyon -1 ile 1 arasında yumuşak bir geçiş sağlar
smooth_sign = tanh(v ./ eps_smooth);

% Asimetrik katsayı vektörleri oluşturma
% Hızın yönüne göre katsayıları seçiyoruz
kv = (v >= 0)*kv_p + (v < 0)*kv_n;
kc = (v >= 0)*kc_p + (v < 0)*kc_n;
ks = (v >= 0)*ks_p + (v < 0)*ks_n;
tau = (v >= 0)*tau_p + (v < 0)*tau_n;

% --- Sürtünme Kuvveti Hesaplama ---
% F_viscous + F_coulomb + F_stribeck
FF = (kv .* v) + (kc .* smooth_sign) + (ks .* smooth_sign .* exp(-abs(v./tau)));

% Görselleştirme
hold on;
plot(v, FF, 'LineWidth', 2.5);
grid on; hold on;

% Eksenleri merkeze al
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';

title('Yumuşatılmış (Eğimli) Asimetrik Stribeck Modeli');
xlabel('Hız (v)');
ylabel('Sürtünme Kuvveti (F_f)');