# Plan

| # | İş | Sınıf | Model | Durum | Bitmiş sayılır |
|---|---|---|---|---|---|
| 136 | Mevcut oyunun incelenmesi | derin | claude-code/opus | bitti | Rapor teknolojiyi, çalıştırma/derleme sonucunu, mevcut hareket ve animasyon listesini, varlık listesini ve gerekçeli 'devam mı taşıma mı' önerisini içeriyor. |
| 137 | Prehistorik 2 oynanış ve görsel araştırması | arastirma | claude-code/sonnet | bitti | rapor.md hareket seti, düşmanlar, toplanabilirler, bölüm tasarımı, görsel yön ve uyarlama önerileri bölümlerini içeriyor; en az 4 ekran görüntüsü kaynaklarıyla  |
| 138 | Üç farklı görünüm taslağı | derin | codex/gpt-6.1-terra | bitti | taslaklar/ altında 1920x1080 boyutunda üç PNG ve README.md var; her taslakta paralaks doğa, oyuncu, 2 düşman, yiyecek, HUD ve dokunmatik kontroller görülüyor; ü |
| 139 | Taslak dosyalarını bul, listele ve tek sayfada göster | hizli | codex/gpt-6-luna | bitti | taslaklar/ içinde en az 3 PNG, OKU.md ve index.html var. OKU.md'de mutlak yollar yazıyor. Cevapta klasörün mutlak yolu ve PNG adları raporlanmış. |
| 140 | Taslak A yönünde doğa katmanları, iskelet parçaları ve düşman görselleri | gorsel | codex/imagegen | bitti | art/v2/manifest.json geçerli ve içinde listelenen her PNG var. En az 4 parallax katmanı, Çağan rigi ve iki düşman rigi parçalarıyla mevcut. preview-composite.pn |
| 141 | Oyunu inceleme ve geliştirme: iskelet animasyonu, hareket fiziği, bölüm, düşmanlar, dokunmatik kontroller, dışa aktarma | derin | claude-code/opus | bitti | tools/verify.sh hatasız bitiyor: proje içe aktarılıyor, tüm testler geçiyor, Linux ve Windows dışa aktarmaları üretiliyor, Android ya üretiliyor ya da eksik SDK |
| 143 | Denetim: #141 Oyunu inceleme ve geliştirme: iskelet animasyonu, hareket fiziği, bölüm, düşmanlar, dokunmatik kontroller, dışa aktarma | derin | codex/gpt-6.1-terra | bitti | Kanıtlı bir karar |
| 144 | Android SDK kurulumu ve Linux, Windows, Android dışa aktarmaları | standart | codex/gpt-6-luna | iptal | build/linux/oyun.x86_64, build/windows/oyun.exe ve build/android/oyun-debug.apk boş olmayan dosyalar olarak var. Duman testleri geçiyor. |
| 145 | Denetim: #141 Oyunu inceleme ve geliştirme: iskelet animasyonu, hareket fiziği, bölüm, düşmanlar, dokunmatik kontroller, dışa aktarma | standart | codex/gpt-6-luna | bitti | Kanıtlı bir karar |
| 146 | Yalnızca Linux dışa aktarması | standart | codex/gpt-6-luna | bitti | build/linux/oyun.x86_64 var ve çalıştırılabilir. Headless modda 10 saniye içinde hatasız açılıp kapanıyor. |
