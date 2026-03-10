function hydraulic_friction_fixed()
    % --- AYARLAR ---
    % SİSTEMİN "SERTLİĞİNDEN" DOLAYI ÇOK KÜÇÜK ADIM GEREKİYOR
    dt = 1e-5;   % 0.00001 s (Önceki 0.0005 idi, patlamayı önlemek için küçülttük)
    T_end = 2.5; % Simülasyon süresi (s) - Döngüyü görmek için 2.5 sn yeterli
    t = 0:dt:T_end;
    
    % --- GİRİŞLER (Makale Şekil 11a benzeri) ---
    f = 0.5;     % Frekans (Hz)
    v_mag = 0.2; % Hız genliği (m/s)
    
    % Hız ve İvme vektörleri
    v = v_mag * sin(2*pi*f*t); 
    a = v_mag * 2*pi*f * cos(2*pi*f*t);
    
    % --- PARAMETRELER (Tip 1 Silindir - Tablo 2 ve 3'ten) ---
    p.sigma0 = 2.0e7;  % Kıl sertliği (N/m) 
    p.sigma1 = 0.1;    % Mikro sönümleme (Ns/m)
    p.sigma2 = 280;    % Viskoz sürtünme (Ns/m)
    
    p.Fc = 72;         % Coulomb sürtünmesi (N) (Ortalama alındı)
    p.Fs = 550;        % Statik sürtünme (N)
    p.vs = 0.02;       % Stribeck hızı (m/s)
    p.n  = 0.5;        % Üs
    
    % Proposed Model Ekstra Parametreleri
    p.T = 0.07;        % Proposed model zaman sabiti (s) [cite: 670]
    p.Kf = 1;          % Film katsayısı (Normalize varsayıldı)
    
    % Zaman sabitleri (Hızlanma ve yavaşlama için farklı - Tablo 3)
    p.tau_hp = 0.25; 
    p.tau_hn = 1.0;  
    p.tau_h0 = 40;
    
    % --- BAŞLANGIÇ KOŞULLARI ---
    N = length(t);
    z = zeros(1, N);
    h = zeros(1, N);
    Fr = zeros(1, N);
    
    % Başlangıçta sistem duruyor varsayımı
    h(1) = 0;
    z(1) = 0;
    
    fprintf('Simülasyon başladı... (Adım sayısı: %d)\n', N);
    
    % --- HESAPLAMA DÖNGÜSÜ ---
    for k = 1:N-1
        vk = v(k);
        ak = a(k);
        zk = z(k);
        hk = h(k);
        
        % 1. Stribeck Fonksiyonu g(v,h) [cite: 277]
        % (1-h) terimi filmin etkisini gösterir.
        gs_term = p.Fc + ((1 - hk)*p.Fs - p.Fc) * exp(-(abs(vk)/p.vs)^p.n);
        
        % Güvenlik: gs çok küçülürse patlamaması için alt limit
        gs = max(gs_term, 0.1); 
        
        % 2. Kıl Dinamiği (dz/dt) [cite: 274]
        % Standart LuGre formülasyonu: |v| kullanımı pasifliği garanti eder.
        dz_dt = vk - (p.sigma0 * zk / gs) * abs(vk);
        
        % 3. Film Dinamiği (dh/dt) [cite: 280-283]
        % Kararlı durum film kalınlığı
        h_ss = p.Kf * abs(vk)^(2/3);
        
        % Zaman sabiti seçimi (Hızlanma/Yavaşlama durumuna göre) [cite: 282]
        if vk == 0
            tau = p.tau_h0;
        elseif hk <= h_ss
            tau = p.tau_hp; % Hızlanma (film artıyor)
        else
            tau = p.tau_hn; % Yavaşlama (film inceliyor)
        end
        
        dh_dt = (1/tau) * (h_ss - hk);
        
        % 4. Euler Entegrasyonu
        z(k+1) = zk + dz_dt * dt;
        h(k+1) = hk + dh_dt * dt;
        
        % 5. Sürtünme Kuvveti (Proposed Model) [cite: 362]
        % Fr = sigma0*z + sigma1*dz/dt + sigma2*(v + T*dv/dt)
        Fr(k) = p.sigma0 * zk + p.sigma1 * dz_dt + ...
                p.sigma2 * (vk + p.T * ak);
    end
    
    % Son noktayı tamamla
    Fr(N) = Fr(N-1); 
    
    fprintf('Simülasyon tamamlandı.\n');

    % --- ÇİZDİRME ---
    figure('Color', 'w');
    
    subplot(2,1,1);
    plot(t, v, 'b', 'LineWidth', 1.5); grid on;
    xlabel('Zaman (s)'); ylabel('Hız (m/s)');
    title('Giriş Hızı');
    
    subplot(2,1,2);
    plot(v, Fr, 'r', 'LineWidth', 1.5); grid on;
    xlabel('Hız (m/s)'); ylabel('Sürtünme Kuvveti (N)');
    title('Tran et al. (2012) Proposed Model - Histeresis Döngüsü');
    
    % Görseli güzelleştirme
    xlim([-0.25 0.25]);
    ylim([-1000 1000]); % Makaledeki ölçeklere yakın
end