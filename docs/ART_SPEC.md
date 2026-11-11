# Görsel üretim sözleşmesi

## Envanter
- `../art/reference/visual-target-01.png`: sohbet sırasında üretilen özgün ilk konsept panosu. Eski proje adı görselin içinde; güncel ad Dino Hop!. Üretim varlığı değil; karakter ölçüleri ve dikişleri piksel doğruluğuyla garanti edilmez.
- `../art/source/dino-hop-icon.svg`: proje için yeni vektör yumurta simgesi; geçici ikon.
- Prototip: `scripts/player.gd` ve `scripts/game.gd` ile çizilen geçici şekiller. Nihai çizgi film görseli yerine kullanılamaz.

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
