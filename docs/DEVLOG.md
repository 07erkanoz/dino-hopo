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

## 008 — GitHub teslimi
- İlk çizim paketi, motor bağlantısı ve gerçek ekran görüntüleri `a141dab` kaydıyla GitHub main dalına başarıyla gönderildi.
- Bu sonuç kaydı ayrı dokümantasyon commit’iyle aynı dala gönderilir.


## 009 — Dört kahramanın onayı ve isimleri
- Kullanıcı 2 erkek + 2 kadın, toplam4 seçilebilir kahraman istedi. Önceki2 kişilik araştırma ayrı arşive alındı.
- Yeni kadro paftası ve16 hareket pozu üretildi. Kullanıcı bu karakterleri onayladı ve birebir korunmasını istedi.
- 01 Çağan, 03 Deniz olarak adlandırıldı; 02/04 için isim uydurulmadı.
- Kaynak PNG'ler depoya alındı; SHA-256 kaydı ve otomatik bütünlük kontrolü eklendi.
- Seçim ekranı, her oyuncunun ayrı seçim yapması ve kontrol yuvasının görsel kimlikten ayrılması uygulandı.

## 010 — Silah kararları
- Sopa ve bumerang ekipman/efekt atlası üretildi; kahraman kaynaklarına dokunmadan elde ekipman çizimi uygulandı.
- Kullanıcı bumerangın sıradan sınırsız atış olmasını istemedi. Önerilen3 atış modeli daha sonra kullanıcı tarafından değiştirildi.
- Son kural uygulandı: bulunarak kazanılır, dönerse tekrar kullanılır; araziye takılırsa kaybedilir. Her iki yönde ray çarpışması ve tek aktif atış sınırı var.
- Dinozorlarda kısa fizik devriyesi ve yıldızlı sersemleme, sopa menzili ve boomerang hedef kontrolü eklendi.

## 011 — Dünya yaklaşımının düzeltilmesi
- İlk Amazon poster çizimi kullanıcı tarafından kahramanlara uyumsuz bulundu; reddedilen çizim olarak arşivlendi, oyuna alınmadı.
- Sabit tam resim önünde hareket etme istenmediği için bağımsız nesneli üç Parallax2D katmanı kuruldu; su, kelebek ve rüzgâr hareketleri ayrı.
- İlk modüler sahne de kullanıcı tarafından tekrar eden yuvarlak ağaçlar, büyük çiçekler, bulanık arka/ön ayrımı ve uyumsuz kayalar nedeniyle reddedildi.
- Prehistorik2 orman ekranı yalnız çalışma klasöründe referans olarak incelendi; dosya depoya/oyuna eklenmedi.
- Sisli renk karışımı kaldırıldı; arka katmanlar keskin sınırlı paletle ayrıldı. Sıradan çiçekler22–35, kahraman128 birime ayarlandı; büyük buket gizleme dekoru eğreltiyle değişti.
- Dallanan iki farklı ağaç, köklü doğal kaya ve toprak için yeni habitat atlası üretildi. Tekrarlı yuvarlak ağaçlar ve ayrı gri kaya dekoru aktif sahneden kaldırıldı.
- Havada duran eş kutular yerine zemine ulaşan köklü kaya yükseltileri kondu; çarpışmalar da buna göre güncellendi.
- Ekrandaki kalıcı tuş/debug satırları kontrol yardımına taşındı; mobil tuşlar yalnız dokunmatik cihazda görünür.
- Yeni dünya görünümü henüz kullanıcı tarafından onaylanmadı; teknik çalışması görsel tamamlanma olarak sunulmaz.

## 012 — İlk bölümün motor temeli
- 5120 birimlik alan ve5 çevre bölgesi JSON verisine taşındı. Konum, geometri, meyve, keşif, sarmaşık, kaya, dinozor ve çıkış bu veriden kurulur.
- Tırmanma, kontrol noktası, üst keşif alanı, iki bumerang bulma noktası ve iki uyarılı düşen kaya bölgesi bağlandı.
- Kontrollerde klavye, kontrolcü ve dokunmatik eylemler bulunur; yerel iki oyuncu aynı dünya kamerasını kullanır.
- İlk testte kaya kontrolü yanlış düğümü seçiyordu; konum ve script kimliğiyle doğru kaya bölgesini seçecek biçimde düzeltildi. TypedArray içinde farklı Node türü araması log hatası yarattı; Parallax2D tür kontrolüyle giderildi.
- Godot import ve hareket testleri geçti. 42 atlas bölgesi ve onaylı kahraman PNG hash kontrolleri geçti. Dünya testleri: seçim/isim, sahiplik, yeniden atış, takılınca kayıp, yakın dövüş, tırmanma, sır, kamera ve düşen kaya geçti.
- Gerçek Godot/OpenGL ekran çıktıları güncelleniyor. Tam animasyon, ses, yüzme, uçan dosta binme, çevrim içi co-op ve platform paketleri hâlâ sonraki aşamalar.

## 013 — Hareketli kontrol kaydı
- Gerçek tuş girdilerini çalıştıran record_demo.gd ile Godot MovieMaker'da13 saniyelik kayıt alındı. Kamera otomatik karakter takibiyle kayar; video üretim aracıyla hayali sahne yapılmadı.
- Kaydın10. saniyesinde Çağan nehir kıyısı/kontrol noktası sonrası yükseltilerde,8/19 meyveyle ilerliyor; ilk geçişin oynanabilirliği gözlendi.
-44MB ara AVI yalnız work/ altında; depoya2.3MB sıkıştırılmış MP4 eklendi.
- Karakter seçimi, ilk alan ve şelale bölgesinin gerçek ekran görüntüleri son düzenle yenilendi. Bunlar görsel revizyon durumundadır, kullanıcı onayı yerine geçmez.

## 014 — 2026-11-12: robotik hareket ve ölçek geri bildirimi
- Kullanıcı kahraman/dinozor hareketlerini robotik, dinozorları küçük, motor/oynanışı yetersiz buldu. Teknik test geçmesi kalite onayı sayılmadı.
- Çağan için12 kareli ayrı hareket çalışması, ilk boynuzlu dinozor için8 kareli yürüyüş çalışması görsel aracıyla üretildi. Onaylı kaynak PNG'ler değiştirilmedi. Yeni kareler kullanıcı tarafından ayrıca onaylanmadı.
- Koşu/yürüyüş gerçek yer değiştirmesine bağlandı; sabit global zamanla iki poz değişimi kaldırıldı. Ortak hücre pivotu/ayak tabanı kullanılır. Hızlanma, frenleme, sıçrama hazırlığı ve iniş durumları eklendi.
- Büyük boynuzlu208, hızlı küçük türler140, kahraman128 birim. Fizik ve hedef hacimleri beraber değişti. Kahraman gövde içinden geçmez ve çizim sırası hayvanın arkasında kaybolmasını önler.
- İlk büyük karşılaşma açıklığa taşındı; uyarı/hamle/toparlanma ve can/geri savurma sistemi eklendi. Sık kaya sütunları azaltıldı, ek kaçınma sarmaşığı kondu.
- Devriye sınırında her kare ters yöne dönme hatası bulundu; yalnız sınırdan dışarı hareket ederken dönüş tetiklenecek biçimde düzeltildi.
- Dünya testinde idle işlenen pickup beklenmeden fizik karesinde okunuyordu; iki process_frame beklemesiyle gerçek olay döngüsü beklendi.
- Hareket, dünya, kaynak bütünlüğü/62 atlas ve temel oyun testlerinin dördü geçti. Yeni hareket testleri dururken ayakların durmasını, çoklu fazları, ivmeyi, sıçrama/inişi, büyük türü, saldırı durumlarını ve hasar aralığını kontrol eder.
-9s gerçek Godot MovieMaker kaydı açıklıkta başlatıldı, sonra yalnız tuş girdileri kullanıldı. Tam kaliteli oyun diye sunulmaz.
- Kullanıcı bütün kod ve görsellerin GitHub'a gönderilmesini tekrar istedi; yeni kaynaklar/video/belgeler ilk teslimle aynı depoya hazırlanıyor.
