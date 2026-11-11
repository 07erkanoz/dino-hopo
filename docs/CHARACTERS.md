# Dino Hop! — Onaylanan kahramanlar

| Kimlik | İsim | Tasarım |
|---|---|---|
| 01 | **Çağan** | Erkek; iri yapılı, dağınık koyu saç, mavi tüy, turuncu benekli tunik, turkuaz kuşak. |
| 02 | Henüz belirlenmedi | Erkek; ince yapılı, kıvırcık kısa saç, sarı baş bandı, kırmızı tunik, lacivert kuşak. |
| 03 | **Deniz** | Kadın; ince/atletik yapılı, yüksek at kuyruğu ve kemik toka, turkuaz tunik, sarı kuşak, meyve kesesi. |
| 04 | Henüz belirlenmedi | Kadın; güçlü yapılı, iki örgü, açık renk tüy, mor tunik, yeşil kuşak. |

Kullanıcı 4 karakteri onayladı ve 01/03'e çocuklarının isimlerini verdi. Çağan ve Deniz özel adları Türkçe ve İngilizcede aynı yazılır. 02/04 için isim uydurulmaz; seçim ekranında Kahraman 02/04 veya Hero 02/04 kullanılır.

## Görseli koruma
- Onaylanan pafta: `art/characters/approved-four-heroes-board.png`.
- Onaylanan hareket pozları: `art/characters/approved-four-heroes-poses.png`.
- SHA-256 kayıtları: `art/characters/approved-sha256.json`.
- Bu kaynak PNG dosyaları değiştirilmez, yeniden çizilmez veya üzerine silah boyanmaz. Motor içinde atlas bölgesi, orantılı ölçek ve yatay aynalama kullanılır.
- Silahlar ayrı sprite olarak takılır. İlk dört poz bekleme, koşu temas, koşu geçiş ve zıplamadır. Tam koşu/tırmanma/saldırı döngüsü değildir.
- Gerçek atlas 1254×1254; kare bölmeleri 313/314 piksel olabilir. Motor koordinatları gerçek dosyadan ölçülmüştür, varsayılan 1536 ölçüsü kullanılmaz.
- Oyundaki görsel boy yaklaşık 128 birim. Fizik kapsülü 88 birim, ayak pivotu sabit.

## Seçim ve denge
Tek oyuncu dört kahramandan birini seçer. Yerel iki oyuncu kendi kahramanını seçer; kontrol yuvası ile karakter kimliği birbirinden ayrıdır. Aynı kahramanın iki oyuncu tarafından seçilmesine de izin verilir; P1/P2 etiketleri ayırır. Tüm kahramanların hareket ve silah yetenekleri başlangıçta aynıdır; farklı istatistikler kullanıcı kararı olmadan eklenmez.

## Hareket pilotu
2026-11-12: Çağan için ayrı12 karelik hareket çalışması eklendi; diğer3 kahramanın animasyonları bu aşamada henüz güncellenmedi. Onaylı PNG'ler aynıdır. Yeni kareler ayrı görsel onay bekler; [ayrıntılar](ANIMATION.md).
