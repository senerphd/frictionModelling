%% Tran et al. (2012) Dynamic Friction Model Parameter Estimation
% Makale Referansı: "Modeling of dynamic friction behaviors of hydraulic cylinders"
% Özellik: Stribeck eğrisi anlık hıza (v) değil, gecikmeli film durumuna (s) bağlıdır.
% Ekstra: Yüksek hızlar için Kübik Viskozite (sigma3) korunmuştur.

close all;

% 1. BAŞLANGIÇ TAHMİNLERİ (x0)
% Yapı: [Fc, Fs, vs, s0, s1, s2, s3, tau] (Pozitif ve Negatif için)
% Toplam 16 Parametre

% Statik değerleri (Fc, Fs, vs) önceki analizlerinden makul yerlerden başlatalım.
% tau (Zaman sabiti) için makale 0.01 - 0.1 sn aralığını işaret ediyor.
x0 =   [19.0000,    19.5193, ...        % Fc
        45,         61.9233, ...        % Fs (Tepe)
        0.001,      0.02, ...           % vs
        210034.7,   237983.0, ...       % sigma0 (Sertlik)
        2590.7522,  3372.8709, ...      % sigma1 (Sönümleme)
        31.1023,    25.0000, ...        % sigma2 (Lineer Visc)
        0,          0, ...              % sigma3 (Kübik Visc)
        0.3238,     0.0071];            % tau (Film Gecikmesi - YENİ PARAMETRE)

x0 =   [19.0,  20.0,   45.0,   62.0,   0.005,  0.005,  2e5,    2e5,    2500,   3000,   30,     25,     0,      0,      0.02,   0.02]; 
% NOT: Tau başlangıcını 0.02 yaptık (Burası kritik).

% LB (Alt Limitler)

lb =   [21,         28,     38,     45,     0.001, 0.001,  10000,  10000,  0,     0,      0,    0,             20,    0.01,            0,       0.001];
ub =   [22.5,       29,     70,     50,     0.01,  0.01,   1e7,    1e7,    1e6,   1e6,    10,   100,     1e3,    1e3,         0.01,     0.01];


% 4. OPTİMİZASYON
options = optimoptions('lsqnonlin', ...
    'Display', 'iter', ...
    'Algorithm', 'levenberg-marquardt', ... 
    'MaxFunctionEvaluations', 100e3, ... % Adım sayısı artırıldı
    'StepTolerance', 1e-6, ...          % Tolerans hassaslaştırıldı
    'FunctionTolerance', 1e-12, ...
    'UseParallel', true,...
    'MaxIterations',1e3); % Paralel işlem açıksa hızlanır

fprintf('Tran et al. (Film Dynamics) Optimizasyonu Başlıyor...\n');

% Cost Function
cost_func = @(x) tran_model_cost(x, t_final, v_final, F_friction);

[x_opt, resnorm] = lsqnonlin(cost_func, x0, lb, ub, options);

%% 5. SONUÇLARI YAZDIR VE ÇİZ
% Parametreleri Çözümle
Fc_p=x_opt(1); Fc_n=x_opt(2); 
Fs_p=x_opt(3); Fs_n=x_opt(4);
vs_p=x_opt(5); vs_n=x_opt(6);
s0_p=x_opt(7); s0_n=x_opt(8);
s1_p=x_opt(9); s1_n=x_opt(10);
s2_p=x_opt(11); s2_n=x_opt(12);
s3_p=x_opt(13); s3_n=x_opt(14);
tau_p=x_opt(15); tau_n=x_opt(16); % Film Zaman Sabitleri

fprintf('\n--- TRAN et al. MODEL SONUÇLARI ---\n');
fprintf('PARAMETRE            |  POZİTİF (+)  |  NEGATİF (-) \n');
fprintf('----------------------------------------------------\n');
fprintf('Fc (Coulomb)         | %10.4f    | %10.4f\n', Fc_p, Fc_n);
fprintf('Fs (Static)          | %10.4f    | %10.4f\n', Fs_p, Fs_n);
fprintf('vs (Stribeck Vel)    | %10.6f    | %10.6f\n', vs_p, vs_n);
fprintf('sigma0 (Stiffness)   | %10.1f    | %10.1f\n', s0_p, s0_n);
fprintf('sigma1 (Damping)     | %10.4f    | %10.4f\n', s1_p, s1_n);
fprintf('sigma2 (Visc Lin)    | %10.4f    | %10.4f\n', s2_p, s2_n);
fprintf('sigma3 (Visc Cub)    | %10.4f    | %10.4f\n', s3_p, s3_n);
fprintf('tau_L (Film Lag)     | %10.4f s  | %10.4f s\n', tau_p, tau_n);
fprintf('----------------------------------------------------\n');

% Modeli Çalıştır
[~, F_model_opt, s_state] = tran_model_run(x_opt, t_final, v_final);

% R-Kare
r2 = 1 - sum((F_friction - F_model_opt).^2) / sum((F_friction - mean(F_friction)).^2);
fprintf('R-Squared: %.4f\n', r2);

% GRAFİKLER
figure('Name', 'Tran Model Analizi', 'Color', 'white');

% Stribeck ve Histeresis
subplot(2,2,1);
plot(v_final, F_friction, 'b.', 'MarkerSize', 2); hold on;
plot(v_final, F_model_opt, 'r.', 'MarkerSize', 2);
title('Stribeck Eğrisi (Histeresis)'); 
xlabel('Hız (m/s)'); ylabel('Kuvvet (N)'); grid on;
legend('Deneysel', 'Tran Model');

% Zaman Düzlemi
subplot(2,2,2);
plot(t_final, F_friction, 'b'); hold on;
plot(t_final, F_model_opt, 'r--');
title('Zaman Düzlemi'); 
xlabel('Zaman (s)'); ylabel('Kuvvet (N)'); grid on;

% Film Durumu (s) vs Gerçek Hız (v) - MAKALE ANALİZİ
% Makalede bu ikisi arasındaki gecikme vurgulanır.
subplot(2,2,3);
plot(t_final(1:1000), abs(v_final(1:1000)), 'k'); hold on;
plot(t_final(1:1000), s_state(1:1000), 'g--');
title('Film Dinamiği: Hız(v) vs Film Durumu(s)');
legend('|v|', 's (lagged)'); grid on;
xlim([t_final(1) t_final(1000)]);

% Histeresis Zoom (Merkez)
subplot(2,2,4);
plot(v_final, F_friction, 'b.', 'MarkerSize', 3); hold on;
plot(v_final, F_model_opt, 'r.', 'MarkerSize', 2);
xlim([-0.05 0.05]); 
title('Zoom: Sıfır Geçiş Bölgesi'); grid on;


%% --- YARDIMCI FONKSİYONLAR ---

function diff = tran_model_cost(x, t, v, F_real)
    [~, F_model, ~] = tran_model_run(x, t, v);
    diff = F_real - F_model;
    % Histeresis bölgesine (düşük hız) ağırlık verelim
    weights = ones(size(diff));
    weights(abs(v) <= 0.03) = 20; 
    diff = diff .* weights;
end

function [z, F, s_vec] = tran_model_run(x, t, v)
    % TRAN et al. (2012) MODEL IMPLEMENTATION
    
    N = length(t);
    dt = mean(diff(t));
    
    % Sub-stepping (Hassasiyet için)
    sub_steps = 10;
    dt_sub = dt / sub_steps;
    
    z = zeros(N, 1); 
    F = zeros(N, 1);
    s_vec = zeros(N, 1); % Film State Kaydı
    
    % Parametreleri Çöz
    Fc_p=x(1); Fc_n=x(2); Fs_p=x(3); Fs_n=x(4); vs_p=x(5); vs_n=x(6);
    s0_p=x(7); s0_n=x(8); s1_p=x(9); s1_n=x(10); s2_p=x(11); s2_n=x(12);
    s3_p=x(13); s3_n=x(14);
    tau_p=x(15); tau_n=x(16); % Zaman Sabitleri
    
    z(1) = 0;
    s = 0; % Başlangıç film durumu (Hız 0 ise s 0'dır)
    
    for i = 1:N-1
        vel = v(i);
        abs_vel = abs(vel);
        
        % Parametre Seçimi
        if vel >= 0
            Fc=Fc_p; Fs=Fs_p; vs=vs_p; s0=s0_p; s1=s1_p; s2=s2_p; s3=s3_p; tau=tau_p;
        else
            Fc=Fc_n; Fs=Fs_n; vs=vs_n; s0=s0_n; s1=s1_n; s2=s2_n; s3=s3_n; tau=tau_n;
        end
        
        % --- SUB-STEPPING INTEGRATION ---
        z_curr = z(i);
        s_curr = s;
        
        for k = 1:sub_steps
            % 1. FİLM DİNAMİĞİ (Eq. 16 in Paper)
            % ds/dt = (1/tau) * (|v| - s)
            % Implicit Euler ile kararlı çözüm:
            % s_new = (s_old + dt/tau * |v|) / (1 + dt/tau)
            s_curr = (s_curr + (dt_sub/tau) * abs_vel) / (1 + dt_sub/tau);
            
            % 2. STRIBECK FONKSİYONU (Eq. 17 in Paper)
            % ÖNEMLİ: g(v) değil g(s) kullanıyoruz!
            g_s = Fc + (Fs - Fc) * exp(-(s_curr/vs)^2);
            
            % 3. BRISTLE DİNAMİĞİ (Standard LuGre Eq)
            % dz/dt = v - sigma0 * |v| * z / g(s)
            term_ratio = (s0 * abs_vel) / g_s;
            z_curr = (z_curr + dt_sub * vel) / (1 + dt_sub * term_ratio);
        end
        
        z(i+1) = z_curr;
        s = s_curr; % Bir sonraki adım için sakla
        s_vec(i) = s;
        
        % --- KUVVET ÇIKIŞI ---
        % Çıkış denklemi için anlık dz/dt
        % Makalede F = sigma0*z + sigma1*dz + sigma2*v deniyor.
        % g(s) kullanarak dz hesapla:
        g_s_out = Fc + (Fs - Fc) * exp(-(s/vs)^2);
        term_ratio_out = (s0 * abs_vel) / g_s_out;
        dz = vel - term_ratio_out * z(i+1);
        
        F(i) = s0*z(i+1) + s1*dz + s2*vel + s3*(vel^3);
    end
    
    F(N) = F(N-1);
    z(N) = z(N-1);
    s_vec(N) = s_vec(N-1);
end