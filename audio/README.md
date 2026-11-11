# İlk çizgi film darbe sesleri

Bu dört WAV proje için özgün olarak matematiksel sentezle üretildi. Dış örnek, stok efekt, konuşma kaydı veya müzik kullanılmadı.

- `sfx/swing.wav`: savuruş sırasında kısa filtrelenmiş hava sesi.
- `sfx/wood_hit.wav`: yalnız isabette tahta darbesi.
- `sfx/recoil_a.wav`, `recoil_b.wav`: lastiksi çizgi film geri tepme seslerinin iki çeşidi. Konuşma/hayvan seslendirmesi değildir.

Yeniden üretim: `python tools/generate_sfx.py`. Python standart kütüphanesi kullanır;44.1kHz16bit mono WAV. Oyun içinde düşük ses seviyesi ve küçük pitch değişimleriyle oynar. Menüde Sesler Açık/Kapalı bulunur. Menü ayarı bu oturum içindir, diske kalıcı ayar yazılmaz.

İlk sesler yalnız saldırı/isabet akışını kapsar. Müzik, adım, ortam, dinozor seslendirmesi ve tam ses tasarımı henüz yoktur. Son vuruş videosunda gerçek oyun miksajından alınmış AAC ses kanalı bulunur.
