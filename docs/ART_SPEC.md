# Görsel üretim sözleşmesi

## Envanter
- `../art/reference/visual-target-01.png`: sohbet sırasında üretilen özgün ilk konsept panosu. Eski proje adı görselin içinde; güncel ad Dino Hop!. Üretim varlığı değil; karakter ölçüleri ve dikişleri piksel doğruluğuyla garanti edilmez.
- `../art/source/dino-hop-icon.svg`: proje için yeni vektör yumurta simgesi; geçici ikon.
- `../art/backgrounds/waterfall-valley.png`: 1672×941 ayrı arka plan çizimi, sahne ve menüye bağlandı.
- `../art/characters/heroes-poses.png`: 1536×1024 RGBA; 8 poz, 2 kahraman; motor içi AtlasTexture, ayağa göre pivot.
- `../art/environment/jungle-props.png`: 1536×1024 RGBA; 6 çevre parçası; sahneye bağlandı.
- `../art/creatures/creatures-natural-v3.png`: 1536×1024 RGBA; 6 doğal oranlı canlı çizimi; görsel yerleştirme, davranış/animasyon değil. Kullanıcı onayı beklenir.
- `../art/atlas-regions.json`: 20 sprite için gerçek kaynak sınırları; alpha≥128 içeriğinin sınır kutuları üzerinden okunur. Kaynak PNG'ler değiştirilmedi.
- `../art/review/*-in-engine.png`: menü, oyun sahnesi, kahraman ve canlı galerilerinin gerçek Godot çıktıları.
- `../art/review/creatures-v1-rejected.png`: kullanıcı tarafından yapmacık bulunan ilk tasarım; aktif oyunda kullanılmaz.
- `../art/review/creatures-natural-v2.png`: daha doğal oranlı ara çizim; atlas hücre sınırları sorunlu olduğu için v3 ile değiştirildi.
- Ayrıntılı görsel dizin ve kaynak kaydı: [art/README.md](../art/README.md).

## Uygulama ölçüleri
1280×720 mantıksal ekran, geniş ekranlarda uyarlanan canvas. 64×64 zemin modülleri; karakter için 64×96 çizim alanı. Fizik kapsülü görselden küçük. Telefonda en az 80×80 mantıksal dokunma alanı ve güvenli kenar boşlukları.

Arka plan katmanları: gökyüzü, uzak dağ, orta bitki, ön dekor. Ön/arka değer farkı oynanabilir yüzeyi belirgin tutmalı. Platform üstleri yatay, kamera yandan ortografik.

## Üretim kontrol listesi
- Karakter: şeffaf PNG atlasları; idle/run/jump/fall/climb/action/hurt, sabit pivot ve kare ölçüsü.
- Zemin: 64×64 tekrarlanabilir üst/orta/alt/kenar/iç-dış köşe; dikişsiz birleşim testi.
- Dinozorlar: tür başına davranış, hitbox ve animasyon listesi.
- UI: ayrı SVG/PNG düğmeler; yazıları görsele gömmeyin, TR/EN metinleri kodda tutun.
- Her asset için kaynak, boyut, pivot, kullanım durumu ve lisans kaydı.
- Oyun ekranı tasarımının onayı sonrası parçalar ayrı üretilir; tek konsept resmini kesmek birebir üretim kalitesi sağlamaz.

## 2026-11-11 çizim uygulaması
İlk geometrik kahraman ve çevre yer tutucuları çizilmiş PNG'lerle değiştirildi. Hero sprite boyu yaklaşık 94–99 mantıksal piksel; fizik kapsülü önceki hareket ayarını korur. Yön değiştirme X aynalaması, zıplama pozu ve iki pozlu koşu gösterimi motor içinde yapılır.

Tamamlanmamış üretim işleri: daha akıcı animasyon ara kareleri, tırmanma/saldırı/hasar durumları, tam TileSet köşeleri ve dikiş testi, ayrı parallax katmanları, dinozor hareket setleri. Bu ilk çizim paketi, tüm oyunun bütün görselleri olarak işaretlenmez.

## Dinozor görsel yönü
Kullanıcı ilk bebek/oyuncak görünümünü reddetti. Dev göz, şişkin oyuncak gövde ve plastik görünüm kullanılmaz. Daha doğal hayvan oranları, türlere özgü duruş ve daha sade boyalı yüzeyler denenir. Mizah hareket ve durumdan gelir. v3 bu yönün yeni önerisidir; kullanıcı henüz onaylamadı.


## Güncel onaylı kadro ve dünya kaynakları
- `art/characters/approved-four-heroes-board.png`: onaylı dört kahraman paftası.
- `art/characters/approved-four-heroes-poses.png`: onaylı 1254×1254 RGBA, 4×4 poz atlası; sütunlar 01/02/03/04, satırlar bekleme/koşu-temas/koşu-geçiş/zıplama.
- `art/characters/approved-sha256.json`: kaynak bütünlüğü; değişiklik testi hata verir.
- `art/equipment/club-boomerang-effects.png`: ayrı sopa, bumerang, çizgi film vuruş bulutu ve yıldızlar.
- `art/environment/jungle-modules.png`: ilk modüler orman denemesi. Büyük yuvarlak ağaçlar ve gri taş artık aktif ormanda kullanılmaz; sarmaşık, küçük çiçek ve eğrelti parçaları kullanılır.
- `art/environment/forest-habitat-v2.png`: iki doğal dallanan ağaç, köklü kaya çıkıntısı ve köklü toprak dokusu. İlk modüler tasarım eleştirisinden sonra üretildi. Henüz kullanıcı görsel onayı yok.
- `art/review/amazon-background-rejected.png`: kullanıcı tarafından reddedilen poster; oyun sahnesinde kullanılmaz.
- `art/review/warm-forest-style-study.png`: yalnız stil denemesi; oyun arka planı değildir.
- `art/review/duo-exploration-before-four-heroes.png`: dört kişilik kadrodan önceki iki karakter araştırması, güncel kadro değil.

Motor aynı PNG'leri bölgelerle okur, kaynak çizimleri kesip yeniden boyutlandırarak değiştirmez. Oyun dünyasında arka plan tek resim değildir: ayrı sprite düğümleri ve üç Parallax2D katmanı kullanılır. Menü dekoru ayrı tam resim olabilir.

Yeni ölçütler: kahraman boyu yaklaşık128, fizik kapsülü88, çiçek22–35. Teknik ilk paftadaki64×96 karakter hedefi görsel okunabilirlik için bu prototipte değişmiştir. 64px yerleşim referansı korunur; karmaşık dış kaya silüeti dikdörtgen fizik üstüyle birebir piksel temas garantisi değildir. Tam TileSet iç/dış köşeleri ve tüm animasyonlar sonraki üretim işidir.

## Hareket çalışması kaynakları — 2026-11-12
`art/animation/cagan-locomotion-study.png` ve `ceratopsian-walk-study.png` ile20 yeni kare, toplam62 aktif atlas bölgesi. Ayrı dosyalar, onaylanmış PNG'lerin üzerine yazılmadı. Tam hücre bölgeleri/ortak pivotla oynatılır. Yeni hareket çizimleri henüz kullanıcı onayı almadı. [Hareket sözleşmesi](ANIMATION.md).

## Darbe animasyonları
8 saldırı+4 tepki karesi ile aktif atlas74 bölge oldu. Kaynaklar `art/animation/cagan-club-attack-study.png` ve `ceratopsian-hit-study.png`. İlk saldırı çiziminin mat arka planı, görsel düzenleme aracıyla temizlendi; başarısız sürüm review arşivindedir. Onaylı ana kaynaklar değiştirilmedi, yeni hareketler ayrı onay bekler.

## Harita aşamasına dönüş
`art/planning/01-map-overview.png` Godot harita atölyesinden teknik şemadır, doğa/oyun resmi değildir. `art/review/cagan-attack-gutter-candidate.png` önceki ayak kesilmesi için üretilen aday kaynaktır; bu aşama değişikliği nedeniyle aktif kaynak olarak doğrulanmadı/bağlanmadı. Kaynaklar korunur; yeni karakter/efekt işi yerine önce harita ve doğa ele alınır.

## Yeni çizgi film doğa seti
`art/nature/cartoon-trees-01.png`:2 ağaç; `cartoon-ground-plants-01.png`:6 parça; `cartoon-soil-quiet-01.png`:opak sade dolgu. Eski gerçekçi ağaç/kaya kaynakları bu doğa sahnesine alınmadı. Harita ve stil manifesti `world/nature/` içindedir. Dal pikseli opak kahverengi kaynak üzerinden ölçülür; sarmaşık Marker2D çocuğudur. İnce sarmaşık görseli motor içinde çizilir, büyük yapraklı eski resim kullanılmaz.

`art/nature/review-*.png` gerçek Godot doğa görüntüleridir. İlk fazla desenli kök dolgusu yerine sade toprak kullanıldı. Yeni kaynaklar/stil kullanıcı tarafından henüz nihai onay almadı. Kahraman kaynakları değişmedi.

## art/v2 kullanım durumu (Job #141, 2026-11-14)
- Oyunda kullanılanlar:
  - 4 paralaks katmanı.
  - Zemin: ot, toprak, kaya platform, su, şelale, çalı, eğrelti, kayalar, kütük, sarmaşık, iki ağaç, çerçeve ağacı.
  - 41 rig parçası (Çağan, ceratopsian, pterozor).
  - 6 toplanabilir ve 7 UI görseli.
- Görseller değiştirilmedi; ölçek ve pivotlar manifestten okunur.
- `assembled-rest.png`, `preview-composite.png` ve `compare-taslak-a.png` yalnızca referans, oyunda kullanılmaz.
- Eksikler kodla geçici olarak karşılandı (D45): kontrol noktası bayrağı, çıkış kapısı ve bumerang dokunmatik tuşu (eski ekipman görseli). 02–04 kahramanlarının rig parçası yok.
