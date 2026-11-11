# Çizgi film doğası — Aşama2

2026-11-12: Kullanıcı harita aşamasından doğaya geçilmesini ve gerçekçi çizimler yerine çizgi film benzeri doğa istedi. Eski oyun özelliklerine dönülmedi.

## Görsel yön

Sade ve açık biçimler; sıcak umber kontur; turuncu/kestane ağaç gövdesi; yeşil, lime ve teal yapraklar; küçük coral/mor/sarı çiçekler. Fotoğrafik kabuk/taş ayrıntısı, parlak3D yüzey, sis/blur ve koyu çizgili tekrarlı dekor kullanılmaz. Onaylı kahraman paftası yalnız stil referansıdır; dosyaları değişmedi ve kahramanlar bu sahnede oynatılmaz.

## Kaynaklar

| Kaynak | İçerik | Kullanım |
|---|---|---|
| `art/nature/cartoon-trees-01.png` | İki farklı tam ağaç, açık dallar ve görünür kökler | Aynı çizim dünyasından destek/dekor ağaçları |
| `art/nature/cartoon-ground-plants-01.png` | Toprak denemesi, eğrelti, çiçek, kaya, mağara ağzı, çalı | Altı ayrı şeffaf bölge; ilk desenli toprak ana dolgu olarak kullanılmaz |
| `art/nature/cartoon-soil-quiet-01.png` | Sade, düşük kontrastlı toprak dolgusu | Tekrarlı büyük kök deseninin yerine aktif dolgu |
| `world/nature/style-01.json` | Bölgeler, kök pikselleri, dal yuvası pikselleri ve ölçek | Kaynak resimden dünya koordinatına eşleme |

Üç görsel bu proje için görsel üretim aracıyla üretildi. PNG'ler kesilerek veya yeniden boyutlandırılarak değiştirilmedi; motor atlas bölgeleri kullanır. Opaque toprak dolgusu dışındaki iki kaynak RGBA ve gerçekten şeffaf çevreye sahiptir.

## Yerleşim ve bağlantılar

- Ağaç ayağı `NaturePlan.surface_at` yüzeyinden gelir. Eğimde geniş köklerin altı boş kalmasın diye veride ağaç kimliğine bağlı, yumuşak toprak yükseltileri vardır.
- Dal başlangıcı kaynakta gerçekten görünen kahverengi/opak ağaç pikselinden ölçüldü. Sarmaşık bu dala ait Marker2D'nin çocuğudur; serbest dünya konumu yoktur.
- Sarmaşık kalın, büyük yapraklı bir resim olarak gerilmez. Dalı saran küçük bir kıvrım, ince gövde ve küçük yapraklar motor içinde çizilir. Dünya kalınlığı parent ölçeğinden bağımsız korunur.
- Sarmaşık uzunluğu zeminin altına inmez; ağaç/dal/sarmaşık aynı dünya katmanında kalır.
- İki uzak parallax katmanı ayrı ağaç sprite'larıdır. Keskin sınırlı yakın renklerle ayrılır; bulanık tam ekran manzara kullanılmaz.
- Normal çiçekler22–34, eğreltiler48–65, kayalar58–87 birim;128 birim kahraman referansı korunur. Dev çiçek eklenmedi.
- Şelale beslemesi kaya eşiğindedir. Havuz konumu arazi yüksekliğine göre, dere ise nehir seviyesine akacak biçimde düzenlendi. Sert kare kenarlar yuvarlatıldı.
- Mağara için yeraltı kesiti ve aynı stilde köklü ağız birlikte görünür. Mağara/şelale kompozisyonu hâlâ görsel inceleme aşamasındadır.

## İnceleme

F5 Doğa Atölyesi: bölge düğmeleri, sürükleme, tekerlekle zoom, Harita/Doğa, TR/EN. H paneli gizler. R genel görünüm.

[10 saniyelik doğa gezintisi](../art/nature/nature-tour-01.mp4): gerçek Godot kamerası hareket eder, nesneler/parallax ve dal bağlantıları görünür. Kahraman veya doğa animasyonu eklenmedi; yalnız inceleme kamerası hareketidir. Ses/müzik bu aşamada yoktur.

Gerçek Godot/OpenGL çıktıları:

- [Giriş korusu](../art/nature/review-grove.png)
- [Kökler ve dal bağlantısı](../art/nature/review-roots.png)
- [Şelale](../art/nature/review-falls.png)
- [Mağara](../art/nature/review-cave.png)

Bunlar tek parça bir resmin sahneye yapıştırılması değildir; ayrı nesneler, doku dolgusu ve arazi verisiyle çizilir. Kayıt sırasında yalnız inceleme panelleri gizlendi.

## Durum ve sınır

İlk çizgi film doğa çalışmasıdır; kullanıcı henüz nihai görsel onay vermedi. Animasyon, düşman, fizik engeli, görev veya dövüş eklenmedi. Doğa hareketleri de bu aşamanın sonucuymuş gibi sunulmaz. Bu sahnede gezinme kamerası ve parallax incelemesi vardır.

`nature_plan_smoke` veri ayrımını ve destek referanslarını; `nature_style_smoke` şeffaf kaynakları, onaylı kahraman hash'lerini, gerçek kaynak dalına bağlı görsel sarmaşıkları, çiçek ölçeğini ve oyun nesnesi yokluğunu doğrular. Bu testler estetik onay yerine geçmez.
