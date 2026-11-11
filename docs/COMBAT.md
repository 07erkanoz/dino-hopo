# Dino Hop! — Sopa ve bumerang

## Son karar
- **Sopa:** temel ve sürekli kullanılabilir yakın dövüş silahı. Kısa vuruş animasyonu ve bekleme süresi; yakındaki dinozoru sersemletir. Kan veya öldürme animasyonu yok.
- **Bumerang:** başlangıçta otomatik verilmez. Bölümde keşfedilerek bulunur.
- Geri döndüğünde yakalanır ve tekrar kullanılabilir. Atış hakkı/enerji harcanmaz.
- Gidişte veya dönüşte araziye takılırsa kaybedilir. Başka bir bumerang bulunmalıdır.
- Tek kahramanın aynı anda yalnız bir bumerangı havada olur. İki oyuncunun envanteri ayrıdır.

Önce önerilmiş 3 atış hakkı ve rüzgâr taşı fikri **kullanıcının son kararıyla kaldırıldı**; uygulanmadı. Öneri geçmişi güncel mekanik gibi sunulmaz.

## Uygulama
`player.gd`: silah girdileri, sopa salınımı ve elde çizim.
`boomerang.gd`: gidiş, dönüş, sahibini takip, süpürülmüş hedef kontrolü, her iki yönde arazi ray kontrolü ve kayıp.
`dino.gd`: arazi fiziği, kısa devriye ve yıldızlı sersemleme. Tam düşman davranış sistemi ve tür başına animasyonlar henüz yok.
`game.gd`: keşif nesneleri, sahiplik, yakın vuruş ve HUD.

Kontroller: P1 F/G, P2 K/L; kontrolcü sol/üst yüz düğmeleri; mobil ayrı sopa ve bumerang simgeleri. Temel vuruş ve atış klavye/dokunmatik testlerinde kontrol edilir; fiziksel kontrolcü cihaz testi yapılmadı.

Bumerang takıldığında şu an kayıp mesajıyla kaldırılır. Dala asılı kalma, tekrar gidip alma veya kırılma sinematiği henüz yapılmadı. Kaybolunca bölümdeki diğer keşif noktası aranabilir; yeni bölüme/yeniden denemeye girince bölüm nesneleri sıfırlanır.

## Karşılaşma ve darbe güncellemesi
2026-11-12: Büyük boynuzlu tür208, küçük hızlı türler140 birim; vuruş/hedef hacimleri buna göre ayarlı. Dinozor gövdesi kahramanla fiziksel olarak çarpışır. İlk büyük karşılaşma geniş açıklığa taşındı;0.7s uyarı, hamle, toparlanma ve sersemleme durumları var. Kahramanda3 can, geri savurma ve hasar aralığı eklendi; kaya darbeleri de bu can sistemini kullanır. Can bitince kontrol noktasına dönüş. Tam dövüş animasyonu/denge bitmiş değildir.
