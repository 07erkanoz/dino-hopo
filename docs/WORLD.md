# Dino Hop! — İlk dünyanın temeli

## Görsel ölçüt
Kullanıcı Prehistorik 2 benzeri sürekli ilerleyen doğa, orman, ağaç, kaya ve keşif çeşitliliği istiyor. Kahramanların onaylanan çizgi film tarzı korunur. Sabit manzara önünde yürüme, bulanık sisli arka planla ayrı duran ön plan, dev sıradan çiçekler ve birbirini tekrarlayan yuvarlak ağaç duvarları reddedildi.

Referans incelemesi: [Prehistorik 2 orman ekranı](https://bestdosgames.com/uploads/2025/05/6645930-prehistorik-2-dos-stage-5-in-the-forest.png). Yalnızca kompozisyon/ölçek/doğa okuması için incelendi; kaynak görsel depoya veya oyuna eklenmedi, oyunun sprite'ları kopyalanmadı. Kullanıcı piksel sanat istemedi; kendi onaylı çizgi film kahramanları kullanılır.

## Gerçek sahne nesneleri
- `forest.gd`: üç ayrı Parallax2D katmanı (0.18 / 0.46 / 0.78); bağımsız ağaç sprite'ları, farklı ölçek ve yansıma, ayrı yaprak/çiçek düğümleri.
- `foliage.gd`: düğümlerin düşük açılı rüzgâr hareketi.
- Uzak katmanlar sis/blur yerine net, sınırlı renk paletiyle ayrılır. Kahraman dokuları bu palet işlemine sokulmaz.
- İki farklı dallanan doğal ağaç, köklü kaya çıkıntısı ve toprak kesiti aynı habitat atlasından gelir.
- Sıradan çiçekler yaklaşık 22–35 birim, eğreltiler 38–55 birim; kahraman 128 birim. Gevşek uyumsuz gri kaya dekorları kaldırıldı.
- Oynanış sırasında eski tam ekran arka plan resmi kullanılmaz. Menü/seçim ekranındaki dekoratif resim ayrı konudur.
- Nehir ve şelale zamana bağlı ayrı su çizimleri; kelebekler bağımsız dünya konumlarında kanat hareketi yapar.

## Bölüm verisi
`world/levels/01.json`: 5120 birim uzunluk, fizik platformları, meyveler, kontrol noktası, sarmaşıklar, keşif alanı, bumerang, dinozorlar, kaya bölgeleri ve çıkış.

Beş ilerleme bölgesi: çiçekli koru → nehir kıyısı → kayalık şelale → dev ağaçlar → çıkış geçidi. Bunlar aynı ilerleyen bölümün parçalarıdır; beş tamamlanmış bölüm değildir. Görsel dağılım ve zorluk hâlâ tasarım denemesidir.

İlk denemedeki havada duran eş kutuların yerine zemine uzanan köklü kaya çıkıntıları kondu. Çarpışma alanları da görsel yükseltilerle beraber güncellendi. Platform üstleri fizik için yatay; dış kaya silüeti düzensizdir. Alt/üst rota akışı sonraki kullanıcı değerlendirmesiyle iyileştirilecek.

## Etkileşimler
- Sarmaşığa W/↑ veya mobilde zıplamaya basılı tutarak tırmanma; S/↓ ile iniş, Boşluk/Shift ile ayrılma.
- Üst yolda eğrelti arkasında keşif alanı ve bumerang.
- Kayadan önce küçük taş uyarısı, ardından gerçekten düşen ve araziye çarpan kaya.
- Fizikli kısa devriyeli dinozorlar; sopa/bumerangla geçici sersemleme.
- Kontrol noktası, düşüşte dönüş, meyve ve bölüm çıkışı.

## Doğrulama ve sınır
Headless hareket, seçim, atlas, kaynak görsel bütünlüğü ve dünya etkileşim testleri; ayrıca Godot/OpenGL gerçek ekran kontrolü. Bu ilk bölüm başlangıcıdır, nihai görsel onay veya tamamlanmış 12 bölüm değildir. Tam animasyonlar, sesler, yüzme/kanatlı dosta binme, ağ co-op ve mağaza paketleri henüz yapılmadı.

## Oynanış geri bildirimi sonrası
İlk boynuzlu dinozor1700 civarındaki geniş açıklığa taşındı.1450/1760/2060 çevresindeki sık kaya sütunları kaldırıldı; 500'de küçük basamak, ilk üst rota için sarmaşık ve açıklık öncesinde1400'de kaçınma sarmaşığı eklendi. Toplam3 düşman ve4 sarmaşık var. Büyük hayvana gövde çarpışması, uyarı/hamle/toparlanma ve oyuncuya3 can/geri savurma eklendi. Hareket ve ölçek çalışması [ANIMATION.md](ANIMATION.md) içinde.

## Önce harita/doğa — güncel çalışma ayrımı
Bu dosyanın önceki motor/sahne anlatımı eski denemeye aittir. Güncel varsayılan yalnız harita atölyesidir. `world/nature/01-map.json` eski düşman/silah verisinden ayrıdır. [Esas üretim planı](PRODUCTION_PLAN.md) ve [harita taslağı](maps/01-map-plan.md) yeni çalışmayı tanımlar. Doğa tamamlanmış sayılmaz.

## Aşama2 doğa görünümü
Harita verisi korunarak `nature_scenery.gd`, `nature_assets.gd` ve `nature_vine.gd` eklendi. Yeni çizgi film kaynakları ayrı doğa nesneleri olarak yerleşir. Araziye küçük kök destekleri eklendi; şelale havuzu gerçek arazi seviyesinden türetildi. Varsayılan çalışma hâlâ kahramansız/düşmansız doğa-harita atölyesidir. [Görsel sözleşme](NATURE_STYLE.md).
