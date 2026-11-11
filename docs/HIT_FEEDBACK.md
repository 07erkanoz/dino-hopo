# Savuruş → temas → tepki çalışması

Tarih:2026-11-12. Kullanıcı sopanın döndürülmesini kötü buldu; görünür vuruş ve darbe tepkisi/komiklik olmadığını belirtti. Bu çalışma önce Çağan ve ilk büyük boynuzlu dinozor içindir.

## Gövdeyle saldırı
`art/animation/cagan-club-attack-study.png`:8 ayrı poz. Hazır → çömelerek hazırlık → geriye alma → öne uzanan temas → takip hareketi → kısa komik dengesizlik → toparlanma → hazır.

Sopa bu hareket karelerinde gerçekten elde çizilidir. Bu animasyon sırasında ayrı sopa sprite'ı tekrar çizilmez. Onaylı kahraman kaynakları değiştirilmedi; bu yeni hareket çalışması ayrı dosyadır, henüz kullanıcı görsel onayı yoktur.

Süreler:0.04/0.08/0.08/0.055/0.075/0.08/0.08/0.07s; toplam0.58s. Yalnız3 ve4 indeksli temas/takip kareleri aktiftir. Yerde savuruş sırasında hız frenlenir, bakış yönü kilitlenir; gövdeyi savururken ters yöne kayıp dönmez.

## Gerçek temas
`player.club_tip()` çizilmiş sopa başının yaklaşık konumunu verir. `game.on_club_hit` önceki/güncel uç arasındaki süpürülmüş segmenti hedef alanıyla karşılaştırır; oyuncunun arkasına vurulmaz, arazi ray kontrolü aradaki kayadan geçişi önler.

Her savuruşta hedef başına yalnız bir isabet kaydedilir. Boşa vuruşta yalnız gövde hareketi/savuruş sesi olur; dinozor tepki vermez ve darbe bulutu üretilmez. Çarpışma çizilmiş sopanın yaklaşık temas hacmidir, piksel hassasiyetli maske değildir.

## Birleşik tepki
- `dino.receive_hit`: kısa fiziksel geri itilme, hafif ağırlık tepkisi ve tehlikeli saldırının kesilmesi.
- `art/animation/ceratopsian-hit-study.png`: irkilme, dengesizlik, dizlere çökme ve sersemleme pozları. İlk0.43s bu dört poz, ardından sersemlemiş duruş.
- Vuran karakter0.045s, vurulan0.055s yerel darbe duraklaması. Global zaman değiştirilmez; diğer oyuncu durdurulmaz.
- Çok kısa krem renkli darbe parlaması; doğal doku rengi normal durumda korunur.
- Temas noktasında genişleyip sönen çizgi film bulutu ve küçük yıldızlar.
- En fazla3.5 mantıksal piksel, hızla sönen kamera tepkisi.
- Gerçek AudioStreamPlayer ile tahta darbesi ve iki çeşit lastiksi geri tepme sesi. Savuruş sesi temas öncesindeki geriye alma fazındadır.

Bumerang da isabette aynı hedef tepki/efekt kanalını daha düşük itmeyle kullanır. Dönüş ve kayıp kuralları değişmedi.

## Kaynak düzeltmesi
İlk saldırı PNG'si yeterince şeffaf değildi; aktif atlas testi bunu yakaladı. Görsel aracıyla yalnız arka plan temizlendi, aynı pozlar korundu. Başarısız sürüm `art/review/cagan-attack-rejected-matte.png` içinde arşivdir, oyunda kullanılmaz. Temizlenmiş kaynakta alpha0 çevre doğrulandı.

## Kontrol
`tests/combat_smoke.gd`:8 saldırı fazı; isabetsiz/ters yön/duvar durumunda vurulmaması; tek savuruşta tek temas;4 gövde tepki fazı; geri itilme; yerel duraklama; efekt ve gerçekten oynayan ses düğümleri; dolu ses dosyaları.

[6s sesli Godot kaydı](../art/review/combat-hit-v3.mp4). Karşılaşma bölgesinden başlatılır; sonra normal tuş girdileriyle iki savuruş ve ters yöne bir boş savuruş yapılır. Film sesi gerçek oyun miksajıdır. Bu kayıt, komikliğin veya görsel kalitenin kullanıcı tarafından onaylandığı anlamına gelmez.

Kalan kapsam: diğer3 kahramana tam gövde saldırı setleri, diğer türlerin özel darbe tepkileri, tam seslendirme ve dövüş dengesi. Eski kahramanların mantıksal temas/geri tepme sistemi günceldir; çizim setleri bu ilk pilotla aynı tamamlanma düzeyinde değildir.
