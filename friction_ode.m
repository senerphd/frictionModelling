function dy = friction_ode(t, y, t_signal, v_signal, params, Kf)
    % Durum değişkenleri
    z = y(1); % Bristle defleksiyonu [cite: 273]
    h = y(2); % Yağ filmi kalınlığı [cite: 271]
    
    % Zaman sinyalinden hızı enterpole et
    v = interp1(t_signal, v_signal, t, 'linear', 0);
    
    % Statik parametreler ve Stribeck fonksiyonu g_s(v, h)
    gs = params.Fc + ((1 - h) * params.Fs - params.Fc) * exp(-(v/params.vs)^params.n); % [cite: 277]
    
    % Kararlı durum yağ filmi kalınlığı h_ss [cite: 283, 284]
    v_b = 0.09; % Type 1 için örnek [cite: 489]
    if abs(v) <= v_b
        h_ss = Kf * abs(v)^(2/3);
    else
        h_ss = Kf * v_b^(2/3);
    end
    
    % Dinamik zaman sabiti tau_h seçimi [cite: 282]
    % (Not: Basitleştirme için burada sabit bir tau_h veya h_ss'ye göre yön seçilebilir)
    tau_h = params.tau_hp; % Varsayılan
    
    % Türevler
    dz_dt = v - (params.sigma0 * abs(v) / gs) * z; % [cite: 274]
    dh_dt = (1 / tau_h) * (h_ss - h);              % [cite: 281]
    
    dy = [dz_dt; dh_dt];
end