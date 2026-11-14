# dino-hopo

LifeOS Ekip tutar: ekip kaldığı yerden devam etmek için bu dosyaları okur.

**Hedef:** bu oyun incelenecek ve geliştirilecek, öncelikle Prehistorik 2 tarzında eğlenceli bir oyun olacak, doğa gerçekçi ve oyuna uyum sağlayacak, karakterlerin hareketleri düzenlenecek ve gerçekçi olacak

## Proje kartı

- **Amaç:** Mevcut oyunu inceleyip Godot 4'e taşımak ve Prehistorik 2 tarzında eğlenceli bir 2D platform oyununa dönüştürmek. Doğa oyunla uyumlu ve gerçekçi görünecek. Karakterler iskelet (kemik) animasyonuyla doğal ve akıcı hareket edecek. Görsel yön elle boyanmış, detaylı 2D; görünüm onaylanan taslak A'yı izleyecek. Oyun Linux, Windows ve Android'de oynanacak. iOS sürümü sonraya ertelendi.
- **Hedef kitle:** Prehistorik 2 gibi klasik platform oyunlarını seven, hem nostaljik hem modern görünüm isteyen oyuncular (çocuklar ve yetişkinler). Bilgisayarda klavye veya gamepad, telefon ve tablette dokunmatik ekranla oynarlar.
- **Kapsamda:** Mevcut oyunun kodunu, varlıklarını ve oynanışını incelemek; işe yarayan mantığı ve varlıkları Godot 4'e taşımak
- **Kapsamda:** Godot 4 (GDScript) ile proje yapısını kurmak: sahneler, oyuncu, düşmanlar, bölüm, arayüz
- **Kapsamda:** Prehistorik 2 tarzı oynanış: koşma, zıplama, sopayla vurma, düşmanlar, toplanabilir yiyecek ve bonuslar, gizli alanlar, puan
- **Kapsamda:** Elle boyanmış, detaylı 2D doğa: katmanlı (paralaks) arka planlar, bitki örtüsü, su, gökyüzü, ışık; renk, ışık ve kompozisyon taslak A'ya uygun
- **Kapsamda:** Oyuncu ve düşmanları parçalara ayrılmış görsellerle Skeleton2D/Bone2D iskelet animasyonuyla canlandırmak: bekleme, yürüme, koşma, zıplama, düşme, saldırı, hasar alma, ölme
- **Kapsamda:** Hareket fiziğini ayarlamak: ivmelenme, yavaşlama, zıplama yüksekliği, havada kontrol, coyote time, zıplama tamponu
- **Kapsamda:** Doğa, karakter ve düşman görsellerini yapay zekâyla özgün olarak üretmek ve tutarlı tutmak
- **Kapsamda:** Kontroller: masaüstünde klavye ve gamepad, mobilde ekran üstü dokunmatik tuşlar (yön, zıplama, vurma); yatay ekran; farklı ekran oranlarına uyum
- **Kapsamda:** Linux, Windows ve Android için Godot dışa aktarma ayarları (export preset)
- **Kapsam dışı:** Çok oyunculu / çevrimiçi oyun
- **Kapsam dışı:** Google Play ve App Store'da yayın, ödeme sistemi
- **Kapsam dışı:** Prehistorik 2'nin orijinal grafik, ses veya müziklerinin kopyalanması (telif)
- **Kapsam dışı:** 3D oyuna geçiş
- **Kapsam dışı:** Piksel sanat veya düz (flat) vektör görsel tarzı
- **Kapsam dışı:** iOS sürümü ve iOS dışa aktarması (şimdilik ertelendi; kod ve dokunmatik kontroller ileride iOS'a taşınabilecek biçimde yazılacak)
- **Başarı ölçütü:** Godot 4 projesi hatasız açılıyor, headless modda hata vermeden çalışıyor ve en az bir tam bölüm baştan sona oynanabiliyor
- **Başarı ölçütü:** Oyuncunun iskelet animasyonlu bekleme, koşma, zıplama, saldırı, hasar alma ve ölme hareketleri var; birbirine kesintisiz geçiyorlar
- **Başarı ölçütü:** Arka planda en az 3 paralaks katman var; doğa öğeleri (ağaç, kaya, su, gökyüzü) elle boyanmış detaylı 2D yönünde, tutarlı ve taslak A ile yan yana konunca aynı görsel yönde görünüyor
- **Başarı ölçütü:** Bölümde en az 2 düşman türü, toplanabilir bonuslar ve puan sayacı var
- **Başarı ölçütü:** Dokunmatik kontroller mobilde görünüyor, masaüstünde gizleniyor; klavye ve gamepad çalışıyor
- **Başarı ölçütü:** Otomatik testler (GUT veya headless test betiği) geçiyor; Linux, Windows ve Android dışa aktarmaları başarıyla üretiliyor; kabul için ekran görüntüleri üretiliyor

## Kararlar

- Görseller (doğa, karakter, düşman) nereden gelsin?: **Yapay zekâ ile üretim**
- Oyun hangi teknolojiyle geliştirilsin?: **Godot 4'e taşıma**
- Doğa ve karakterler için hangi görsel yönü istiyorsunuz?: **Elle boyanmış detaylı 2D**
- Karakter hareketleri hangi teknikle yapılsın?: **İskelet (kemik) animasyonu**
- Oyun hangi platformda oynanacak?: **linux, windows android ios
**
- iOS sürümü nasıl derlensin?: **iOS şimdilik ertelensin**
- Üç görünüm taslağından hangisiyle devam edelim? Ekran görüntüleri bu soruya ekli. Dosyalar projede taslaklar/ klasöründe, her taslağın açıklaması da yanında duruyor.: **taslak a olsun**
- Plan: **onaylandı**
- Bütçe: **Devam et: 1500 bin daha**
- Bütçe: **onaylandı**
- Bütçe: **Devam et: 13814 bin daha**
- Android SDK bu makinede kurulu değil. Android dosyası (APK) için ne yapalım?: **onaylandı**
