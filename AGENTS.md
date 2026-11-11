# Dino Hop! çalışma kuralları
- Motor Godot 4.6, dil GDScript. Oyun adı Dino Hop!.
- Her anlamlı işlem sonunda docs/DEVLOG.md içine tarih, işlem, doğrulama ve sınırlamaları yaz.
- Tasarım kararlarını docs/DECISIONS.md içinde durumuyla kaydet: kabul, öneri, teknik başlangıç.
- Bölüm değişikliklerinde docs/LEVELS.md güncelle; önerileri kullanıcı kabulü gibi sunma.
- Her yeni görseli art/ altına al, docs/ART_SPEC.md envanterini ve kullanım durumunu güncelle.
- Kullanıcı metinleri Türkçe ve İngilizce olmalı.
- Prototip çizimlerini nihai varlık diye sunma. Çevrim içi oyun uygulanmadan desteklendiğini söyleme.
- Sırları depoya ekleme. .godot/ ve builds/ Git dışında kalmalı.

- Onaylanan kahraman kaynakları immutable: art/characters/approved-four-heroes-*.png. Kullanıcı yeni çizim istemedikçe yeniden üretme; SHA-256 kontrolünü çalıştır. 01 Çağan,03 Deniz; özel adları EN'de değiştirme.
- Dört kahraman vardır, kontrol yuvası ve hero_index ayrıdır. 02/04 için isim uydurma.
- Dünya görsel kuralları docs/WORLD.md içinde: tek sabit poster, blur/sis, dev sıradan çiçek, tekrarlı yuvarlak ağaç duvarı ve kopuk kaya stilleri reddedildi. Teknik test geçmesini görsel onay gibi sunma.
- Bumerangda son karar: keşifle edinilir, dönerse tekrar kullanılır, araziye takılırsa kaybedilir. Eski3 atış önerisini geri getirme.

- EN GÜNCEL ÖNCELİK: docs/PRODUCTION_PLAN.md. Kullanıcı sırası harita→doğa→engeller/zorluklar→canlılar→bulmaca/görevler→hareket/etkileşim. Kullanıcı doğa aşamasına geçirdi; şu an aşama2, yeni dövüş/düşman/animasyon ekleme. Doğa eksiklerini efekt/oyunla örtme.
- F5 varsayılanı nature_workspace.tscn; eski main.tscn arşiv denemesidir. F5 doğa görünümüyle açılır, Harita/Doğa düğmesiyle taslağa dönülür. Doğa çalışmasını bitmiş oyun veya onaylı nihai doğa gibi sunma.
- Sarmaşık serbest koordinatla başlamaz; aynı dünya katmanındaki destek ağacı ve dalına referans verir. Ağaç kökü terrain yüzeyinden türetilir.

- Doğa stili: docs/NATURE_STYLE.md. Kullanıcı gerçekçi çizim değil, çizgi film doğası istedi. Aynı renk/çizgi ailesi, küçük normal çiçekler, sade toprak ve kaynak pikselden ölçülen dal yuvaları.
