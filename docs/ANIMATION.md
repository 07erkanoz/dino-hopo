# Hareket çalışması — 2026-11-12

Kullanıcı kahraman/dinozor hareketlerini robotik, dinozorları küçük ve oynanışı yetersiz buldu. Bu çalışma önce Çağan ve ilk boynuzlu dinozorun hareketini iyileştiren bir pilot uygulamadır. Tüm karakter ve türler tamamlandı olarak sunulmaz.

## Kaynaklar
- `art/animation/cagan-locomotion-study.png`: 8 koşu fazı + bekleme/hazırlık/hava/iniş, toplam12 yeni hareket çizimi.
- `art/animation/ceratopsian-walk-study.png`: aynı yetişkin boynuzlu dinozor için8 dört ayaklı yürüyüş fazı.
- İki PNG, önceki onaylı kahraman/canlı tasarımları referans alınarak görsel üretim aracıyla üretildi. **Yeni animasyon çalışmaları ayrıca kullanıcı onayı almadı.**
- Onaylanmış dört kahraman paftası ve16 poz atlası değiştirilmedi; hash testleri geçer. Çağan'ın duruşu ve seçim resmi bu onaylı kaynaklardan kalır. Hareket çalışması ayrı kaynak dosyasıdır.
- Tam hücre bölgeleri ve ortak pelvis/ayak pivotu kullanılır; her kareyi ayrı boy/merkeze normalize etmekten doğan sıçramalar önlenir. Kaynak hücrelerinde kasıtlı gövde yükselmesi/alçalması korunur.

## Oynatma
Çağan'ın sekiz koşu fazı gerçek yatay yer değiştirmesine bağlıdır; global zamanla iki resim değişimi kaldırıldı. Durduğunda veya engelde kaldığında adımlar ilerlemez. Hızlanma, frenleme ve yön değişimi için farklı ivmeler; kısa sıçrama hazırlığı ve iniş toparlanması var. Sopa tutuş noktası da hareket karesine göre değişir.

Boynuzlu dinozorun yürüyüş fazı gerçek mesafeye bağlıdır. Boyu208, kahraman128 mantıksal birim; hızlı küçük türler140 birim. Büyük hayvanın çarpışması ve hedef hacmi de büyütüldü. Kahraman artık hayvanın gövdesinin içinden geçmez; çizim sırası kahramanın görünürlüğünü korur.

## İlk karşılaşma
Küçük sıkışık devriyeler yerine nehir sonrasında geniş açıklık oluşturuldu. Büyük dinozorun durumları: devriye →0.7s uyarı → hamle → toparlanma; sopa/bumerangla sersemleme. Uyarı ve toparlanma süresi karşılık verme/kaçınma fırsatıdır. Açıklık önündeki sarmaşık alternatif kaçınma yoludur.

Kahraman3 canla başlar. Darbe kısa geri savurma ve hasar dokunulmazlığı verir. Can bitince veya çukura düşünce kontrol noktasına döner. İlk vuruşta sürekli ışınlanma kaldırıldı.

## Kayıt ve doğrulama
[9 saniyelik motor kaydı](../art/review/motion-study-v2.mp4), testin karşılaşma açıklığından başlatılmasıyla alınır. Sonrasında yalnız tuş girdileri uygulanır; karakter veya kamera kare kare ışınlanmaz. Bu ilk hareket incelemesidir, nihai oyun kalitesi onayı değildir.

`tests/motion_smoke.gd`:8 adımın kullanılması, durunca ayak fazının durması, hızlanma, hazırlık/hava/iniş, büyük tür ölçeği, uyarı/hamle/toparlanma, can ve hasar aralığı.

Kalanlar: Deniz/02/04 için aynı kalitede hareket dizileri; küçük türlerin tam yürüyüşü, özel tırmanma ve saldırı kareleri; tam elle temizlenmiş/pürüzsüz üretim animasyonu ve ses eşleşmesi. Pilot koşu kareleri tek başına doğal animasyon kalitesini garanti etmez; hareketli görsel değerlendirme gerekir.
