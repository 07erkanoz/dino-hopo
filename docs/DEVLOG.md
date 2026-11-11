# Dino Hop! — İşlem günlüğü

Tarih: 2026-11-11 (Europe/Istanbul). Her anlamlı çalışma bu dosyaya eklenir.

## 001 — Planın kaydı
- Oyun adı, TR/EN, dört platform hedefi, iki oyuncu, en az 10 bölüm ve istenen mekanikler karar defterine işlendi.
- 12 ana + 3 gizli bölüm, kahraman adları ve hikâye öneri olarak ayrıldı.
- GAME_DESIGN, LEVELS, DECISIONS, ART_SPEC ve ROADMAP oluşturuldu.

## 002 — Görseller
- Sohbette üretilmiş konsept panosu kayıpsız olarak art/reference/visual-target-01.png içine kopyalandı.
- Özgün SVG yumurta simgesi eklendi. Konseptteki eski başlığın geçersizliği belgelendi.
- Tek pano doğrudan üretim sprite seti gibi sunulmadı; ölçü, katman ve ayrı varlık kuralları yazıldı.

## 003 — Godot başlangıcı
- Godot 4.6.3/GDScript projesi, TR/EN menü, tek/yerel iki oyuncu seçimi.
- Klavye/kontrolcü girişleri, çoklu dokunma düğmeleri, kısa zıplama ve kenar toleransı.
- Geçici şekillerle test alanı; meyve, kontrol noktası, düşüşte dönüş, bitiş.
- İlk testte kare zamanlaması nedeniyle checkpoint kontrolü erken çalıştı; test bir tam işlem döngüsünü bekleyecek biçimde düzeltildi.
- Godot verileri ev dizinine yazamadığı için doğrulama XDG dizinleri workspace/work altında çalıştırıldı.

## 004 — Doğrulama
- Godot headless editor import: geçti (XDG yollarıyla hatasız).
- tests/smoke.gd: TR/EN, tek/iki oyuncu, zemine iniş, gerçek tuş girdisiyle zıplama, kontrol noktası, düşüşte dönüş, meyve, dokunmatik giriş ve çıkış testleri geçti.
- Görsel arayüz ve fiziksel mobil/kontrolcü cihaz testi yapılmadı. İki ayrı cihazda ağ oyunu henüz yok.
- Tam bölümler, nihai çizgi film animasyonları, ses, saldırı, tırmanma, uçuş ve yüzme sonraki işler.

## 005 — GitHub hazırlığı
- dino-hop oluşturma çağrısı GitHub createRepository yetkisi eksikliğiyle reddedildi; depo oluşmadı.
- Kullanıcı dino-hopo deposunu oluşturduğunu bildirdi.
- 07erkanoz/dino-hopo doğrulandı: boş ve herkese açık. Görünürlük korunur.
- İlk kaynak kaydı `ce0840a` oluşturuldu ve GitHub main dalına başarıyla gönderildi.
- Bu işlem günlüğünün sonuç kaydı ayrı bir dokümantasyon commit’i ile gönderilir.


## 006 — Gerçek çizim paketi
- Kullanıcı iskelet yerine gerçek çizimlerin hazırlanmasını istedi.
- Şelaleli vadi arka planı, iki kahraman için 8 poz ve 6 çevre parçası ayrı PNG kaynakları olarak üretildi; art/ içine eklendi.
- 6 canlı içeren ilk set kullanıcı tarafından yapmacık bulundu; reddedilen sürüm olarak arşivlendi ve aktif sahneye alınmadı.
- Doğal oranlı v2 üretildi; atlas hücre sınırındaki sorunlar için v3 düzeltmesi yapıldı. v3 aktif çalışma çizimidir, kullanıcı onayı verilmiş değildir.
- Kaynaklar görsel üretim aracıyla oluşturuldu; v3 aynı araçla v2 düzenlemesidir. Kaynak dosyalar korunur, kesme/yeniden boyutlandırma motor içinde AtlasTexture bölgeleriyle yapılır.
- art/atlas-regions.json, art/README.md ve görsel sözleşmesi güncellendi. Önceki örnek pano ve yeni kaynaklar ayrıldı.

## 007 — Çizimlerin Godot'a bağlanması
- Geometrik kahraman çizimleri, 8 pozun bulunduğu atlas ile değiştirildi. İki pozla koşu, bekleme, zıplama, X aynalama ve ayak hizası uygulandı.
- Arka plan, zemin/platform, meyve, tabela, çıkış ve 6 canlı çizimleri sahneye bağlandı. Dinozor davranışları ve binme henüz eklenmedi.
- Menüye TR/EN çizim galerisi eklendi. Kaynaklar dört sekmede şeffaflıklarıyla görüntülenir.
- Gerçek Godot OpenGL görüntüsü, mevcut Xorg dummy sürücüsüyle yazılım render üzerinden açıldı. Dört ekran görüntüsü art/review/ altında alındı; kompozit veya hayali ekran değiller.
- İlk görüntü incelemesinde uzunboyun kafası platformun arkasında kalıyordu; konumu düzeltildi. Galeri fonu açıklaştırıldı.
- Doğrulama: Godot import geçti. Oynanış smoke testleri geçti. 20 atlas bölgesinde kaynak sınırı, RGBA, görünür çizim ve şeffaf çevre kontrolleri geçti.
- Kalan kapsam: akıcı tam animasyonlar, tam TileSet dikişleri ve köşeler, ayrı parallax katmanları, ses ve canlı davranışları. Bu paket ilk gerçek çizim teslimidir; tam oyunun tüm görselleri değildir.
