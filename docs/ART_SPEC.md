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
