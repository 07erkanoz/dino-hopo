# Animasyon: iskelet (Skeleton2D) sistemi (Job #141, 2026-11-14)

Kullanıcı kararı: karakterler iskelet (kemik) animasyonuyla hareket eder. Parçalar `art/v2/rig/*`, pivotlar ve kemik sırası `art/v2/manifest.json` içindedir. Görseller değiştirilmedi. Hareketler kullanıcıdan henüz görsel onay almadı.

## Kurulum (`scripts/rig/rig.gd`)
- Manifestteki her kemik bir `Bone2D` olur (konum, dönüş, `rest`). Her parça, kendi kemiğinin altında bir `Sprite2D` olarak durur (`offset = -pivot`). Kemikler `Skeleton2D` altındadır. Çizim sırası manifestteki `draw_order × 2` ile `z_index` olarak verilir.
- Pozlar, kemik başına dinlenme açısına eklenen derece ve kök kemik için ofset olarak tanımlanır. Bacaklar iki kemikli **IK** ile çözülür: ayak hedefi verilir, uyluk, baldır ve ayak açıları hesaplanır, ayak tabanı yere paralel kalır.
- Her animasyon **bütün kemikleri** anahtarlar, bu yüzden AnimationTree karışımları tutarlıdır. Döngüler örneklenir (24–32 anahtar, doğrusal açı). Elle kurulan pozlar kübik açı ara değerlemesi kullanır.
- `AnimationPlayer` + `AnimationTree`: kök bir `AnimationNodeStateMachine`. Her durum, diğer her duruma yumuşatmalı (xfade) geçişle bağlıdır: saldırı 0,06 sn, hasar 0,05 sn, düşme 0,18 sn, diğerleri 0,12 sn. Yürüme ve koşma durumları `AnimationNodeTimeSeek` içerir ve evreleri **alınan yola** göre ilerler.
- Rigler kodla kurulur ve manifest değiştikçe yeniden oluşur. Ayrı `.tscn` rig dosyası yoktur (bkz. D39).

## Çağan (`scripts/rig/cagan_rig.gd`, 16 kemik, ölçek 128/450)
| Durum | Süre | Not |
|---|---|---|
| idle | 2,4 sn döngü | Nefes: pelvis 2 px iner, ayaklar IK ile yerde kalır, gövde, baş ve kollar gecikmeli sallanır |
| walk | yol tabanlı | Adım uzunluğu 176 art px ≈ 50 birim/döngü; basan ayak geriye tam gövde hızıyla kayar |
| run | yol tabanlı | Basma oranı 0,32 ve uçuş evresi; 312 art px ≈ 89 birim/döngü; öne eğilme ve geniş kol savruluşu |
| jump | 0,32 sn | Çömelme → gerilme → dizler yukarı |
| fall | 0,7 sn döngü | Bacaklar uzar, kollar dengede salınır |
| land | 0,24 sn | Çöküş ve toparlanma |
| attack | 0,58 sn | Hazırlık → vuruş → takip ve aşma (overshoot) → oturma; oyundaki 8 vuruş evresiyle eşleşir |
| hurt | 0,42 sn | Geriye savrulma |
| die | 1,2 sn | Diz kırılması → sırtüstü düşüş → sekme |
| climb | 0,8 sn döngü | Sarmaşıkta kollar ve bacaklar karşılıklı çalışır |

- **Ayak kayması yok**: `player.gd`, evreyi `yol / adım uzunluğu` ile ilerletir. Basan ayağın geriye kayışı IK ile tam bu uzunluğa ayarlanır. `animation_test`, sabit yürüyüşte basan ayağın dünya konumu değişimini **0,02 px** ölçtü (sınır 3 px).
- **Ağırlık**:
  - Kalkışta esneme, inişte düşme hızına göre ezilme (yay sönümlü `squash`).
  - Hız ve ivmeye göre öne veya arkaya eğilme (savrulma).
  - Başın ivmeye gecikmeli tepki vermesi (takip hareketi).
  - Saldırıda sopanın hedefi aşıp geri oturması.
- Vuruş algılama, sopa ucunu gerçek kemik dönüşümünden alır (`club_tip_global`).

## Düşmanlar
- **Ceratopsian** (`dino_rig.gd`, 16 kemik, 4 bacak IK, çapraz yürüyüş): idle, walk (yol tabanlı), windup (baş eğik, ayak eşeleme), charge (yol tabanlı), hurt, die (bacaklar yanlara açılarak çöküş). Yükseklik 196 birim.
- **Pterozor** (`ptero_rig.gd`, 9 kemik): fly (iki parçalı kanatta dış parça gecikir), swoop (dalış, kanatlar katlanır), hurt, die (gevşek kanatla düşüş).
- Hasar alınca beyaz parlama ve geri itilme oynar. Ölünce ölme animasyonu oynar ve beden 2,2 sn sonra solar.

## Önceki çalışma
`art/animation/*-study.png` kareli hareket çalışmaları ve `art/atlas-regions.json` bölgeleri arşivde duruyor. Çağan oyunda artık bu kareler yerine rigle çizilir. 02, 03 ve 04 numaralı kahramanların rig parçası henüz yok; onlar eski poz çizimleriyle çizilir.

## Görüntüler
`ciktilar/ekran/cagan-*.png` (her animasyondan bir kare), `rig-cagan.png`, `rig-dino.png`, `rig-ptero.png` (her animasyondan 6 örnek), `dusman-*.png`. Yeniden üretmek için: `bash tools/capture.sh`.
