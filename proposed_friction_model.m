function [Fr, dz, dh] = proposed_friction_model(v, dv_dt, z, h, params)
    % Makale Denklemleri Uygulaması:
    % v: hız, dv_dt: ivme, z: bristle defleksiyonu, h: film kalınlığı
    
    % Parametrelerin açılması
    sigma0 = params.sigma0; % Bristle sertliği [cite: 276]
    sigma1 = params.sigma1; % Mikro-vizkoz katsayısı [cite: 294]
    sigma2 = params.sigma2; % Vizkoz katsayısı [cite: 294]
    Fc     = params.Fc;     % Coulomb sürtünmesi [cite: 279]
    Fs     = params.Fs;     % Statik sürtünme [cite: 279]
    vs     = params.vs;     % Stribeck hızı [cite: 279]
    n      = params.n;      % Stribeck eksponenti [cite: 279]
    tau_h  = params.tau_h;  % Yağ filmi zaman sabiti [cite: 289]
    T      = params.T;      % Akışkan sürtünme dinamikleri zaman sabiti [cite: 363]
    h_ss   = params.h_ss;   % Kararlı durum film kalınlığı (K_f * |v|^(2/3)) [cite: 283]

    % 1. Stribeck Fonksiyonu g_s(v, h) [cite: 277]
    gs = Fc + ((1 - h) * Fs - Fc) * exp(-(v/vs)^n);

    % 2. Bristle Dinamiği dz/dt [cite: 274]
    dz = v - (sigma0 * abs(v) / gs) * z;

    % 3. Yağ Filmi Dinamiği dh/dt [cite: 281]
    dh = (1 / tau_h) * (h_ss - h);

    % 4. Önerilen Sürtünme Kuvveti Denklemi (Yeni Model) [cite: 362]
    % Fr = sigma0*z + sigma1*(dz/dt) + sigma2*(v + T*dv/dt)
    Fr = sigma0 * z + sigma1 * dz + sigma2 * (v + T * dv_dt);
end