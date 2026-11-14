# Bölüm planı

Kullanıcı en az 10 bölüm ve artan zorluk istedi. Aşağıdaki 12+3 ayrıntılı plan öneridir; tam bölümler henüz yapılmadı. İngilizce adlar çalışma çevirileridir.

| No | Türkçe | English | Mekanik |
|---|---|---|---|
| 1 | Kahkaha Korusu | Giggle Grove | Hapşıran çiçekler, fırlatan mantarlar, meyve hırsızları; güvenli hareket eğitimi. |
| 2 | Şapır Şupur Nehri | Splashy River | Kütük raftingi, girdaplar, yüzücü dinozor sırtında atlayış. |
| 3 | Ters Akan Şelale | Upside-Down Falls | Su püskürmeleriyle yükseliş, şelale arkası sırlar, kayayla iniş. |
| 4 | Horultu Mağaraları | Snore Caverns | Horultuyla hareket eden platformlar, hapşırıkla açılan geçitler. |
| 5 | Çamur Banyosu | Mud Mayhem | Çamur kaydırakları, gaz kabarcıklarıyla yükselen taşlar. |
| 6 | Yumurta Ekspresi | Egg Express | Raylarda yumurta kabuğu sürüşü, makaslar, çatlayan kabuktan kaçış. |
| 7 | Gaga Hava Yolları | Beak Airlines | Kanatlı dosta binme, kaya kemerleri, hava akımları ve dalış. |
| 8 | Bulutların Pikniği | Cloud Picnic | Çöken bulutlar, yağmurla değişen yollar, gizli gökyüzü gölü. |
| 9 | Uzunboyun Lunaparkı | Longneck Land | Boyun köprüleri, kuyruk tahterevallileri, yaprak salıncakları. |
| 10 | Buz Gibi Şamata | Frosty Fiasco | Donmuş şelaleye tırmanma, buz kayışı, kartopu kovalamacası. |
| 11 | Acılı Yanardağ | Spicy Volcano | Buhar bacaları, hareketli taşlar, acı biber yiyen dinozor. |
| 12 | Büyük Pasta Kovalamacası | Great Cake Chase | Öğrenilen nehir, tırmanma, uçuş becerileriyle final. |

## Gizli bölüm önerileri
- Ay Peynir mi? / Is the Moon Cheese?: hafif yerçekimi ve zıplayan kraterler.
- Dev Dinozorun Buzdolabı / Dino's Giant Fridge: dev yiyecekler ve buz rafları.
- Tepetaklak Vadi / Topsy-Turvy Valley: yön değiştiren geçitler.

## Bölüm 01 üretim hedefi
64 px ızgara; yürüyüş → ilk zıplama → kontrol noktası → alternatif üst yol → gizli mağara → çıkış. Düşen kaya ve tırmanma sonraki tasarım diliminde eklenecek. Mevcut test alanı bölüm 01'in tamamı değildir.

## Dinozor davranış havuzu
Hapşıran küçük otçul; kayaya boynuzu takılan boynuzlu; platform görevi gören uzunboyun; meyve hırsızı hızlı tür; hıçkıran iri takipçi; binebilir kanatlı pterozor; taşıyıcı su sürüngeni; buzda kayan tüylü tür. Tarih öncesi canlılar mizahi biçimde bir arada; pterozor ve su sürüngenleri bilimsel olarak dinozor değildir.

## İlk çizim paketi uygulaması
Şelaleli vadi arka planı, kahraman pozları, çimli platformlar, meyve/tabela/mağara ve altı canlı hareket test alanına yerleştirildi. Bu sahne görsel dil denemesidir; Bölüm 1 tamamlandı veya Şelale bölümü oynanabilir oldu anlamına gelmez. Dinozorlar bu sürümde görsel yerleştirmedir.


## Güncel ilk bölüm uygulaması
`world/levels/01.json` altında **Çiçekli Vadi / Blooming Valley** çalışma adıyla 5120 birimlik ilk bölüm temeli kuruldu. Önceki Kahkaha Korusu adı hâlâ tasarım önerisidir; çalışma adı 12 bölümlük planın kesin onayı değildir.

19 meyve, iki sarmaşık, üst keşif alanı, iki bumerang bulma noktası, dört devriyeli dinozor, iki düşen-kaya bölgesi, kontrol noktası ve çıkış bulunur. Bölümün beş parçası aynı sürekli alanda ilerler. Eski basit test sahnesinden farklı olarak kamera 1280'lik tek sahnede kalmaz.

Son kullanıcı geri bildirimine göre eş yükselen kutular ve dev çiçekler kaldırıldı; tabana bağlı doğal kaya/zemin görseli ve çarpışmaları kullanılır. Görsel düzen hâlâ kullanıcı değerlendirmesine açıktır; tamamlandı olarak işaretlenmez.

## İlk karşılaşmanın yeniden düzenlenmesi
Kullanıcı küçük/robotik dinozorları ve yalnız zıplama akışını eleştirdi. İlk büyük dinozor için1280–2176 arasındaki açıklık genişletildi; sık engeller azaltıldı, girişte tırmanma/kaçınma seçeneği var. Güncel toplam3 düşman,4 sarmaşık; önceki4 düşman/2 sarmaşık sayıları tarihsel kayıttır. Tam bölüm tasarımı hâlâ onay bekliyor.

## Güncel başlangıç: harita taslağı
Önceki oynanış dosyası arşivde kalır. Yeni ilk harita `world/nature/01-map.json`;6144×1536 ve altı coğrafi bölge çalışma taslağıdır. Engel, canlı, görev ve hareket aşamaları harita/doğa sonrasına bırakıldı. [Harita belgesi](maps/01-map-plan.md).

## Doğa çalışması
Aynı ilk haritanın doğa görünümü hazırlanıyor. Temel akış/altı bölge korunur; kaynak ağaca göre dal yuvaları ve yerel kök zeminleri netleştirildi. Şelale havuzu yüzeye, dere nehir seviyesine bağlandı. Bu aşama yalnız doğa kompozisyonudur; engel/düşman/görev veya oynanabilir yeni bölüm tamamlandı anlamına gelmez.

## Bölüm 01, oynanabilir sürüm (Job #141, 2026-11-14)
Veri: `world/levels/01.json`. Genişlik 5120. Doğuş noktası 150. Kontrol noktası 1560. Çıkış 5010. `kill_y` 720 (su).

| Bölge | Aralık | İçerik |
|---|---|---|
| Çiçekli koru | 0–1100 | Başlangıç, basamak taş, sarmaşık (590) → sütun üstünde **gizli çiçek bahçesi** (+1500, taş tablet, bumerang) |
| Su çukuru 1 | 1100–1280 | Şelale ve havuz; düşen 1 can kaybeder |
| Nehir kıyısı | 1280–2176 | Kontrol noktası, ceratopsian 1 (1700), et, sarmaşıklar |
| Kayalık şelale | 2176–2944 | Yüksek zemin, sütun (yumurta), platform (kalp), düşen kayalar, arka plan şelalesi |
| Dev ağaçlar | 2944–3712 | **Su çukuru 2** (3244–3400), yüzen kaya (yıldız), pterozor 1 (3240), sarmaşık, sütun |
| Yüksek düzlük | 3712–4224 | Ceratopsian 2 (3950), yüzen kaya, düşen kayalar |
| Gizli geçit | 4224–5120 | Pterozor 2 (4510), basamak kaya → sütun (yumurta), çıkış kapısı |

- Toplam 19 meyve ve 8 bonus (et 2, yumurta 2, kalp, yıldız, tablet, meyve).
- `level_test`, oyuncunun dışa açılmış zıplama ve koşu değerleriyle çıkışın ve 28 toplanabilirin tamamına erişilebildiğini kontrol eder.
- Bölüm düzeni teknik başlangıçtır; kullanıcı onayı almadı.
