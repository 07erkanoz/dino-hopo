# Dino Hop!

Türkçe / English · Godot 4.6.3 · GDScript · 2D platform adventure

GitHub: https://github.com/07erkanoz/dino-hopo

## Güncel çalışma: önce harita ve doğa

Üretim sırası kullanıcı düzeltmesiyle yeniden kuruldu: **harita → doğa → engeller/zorluklar → canlılar → bulmaca/görevler → hareket/etkileşim**.

**F5 artık Harita Atölyesi'ni açar.** Burada yalnız teknik harita taslağı vardır; düşman, silah, görev veya oynanabilir kahraman yoktur. Doğa çiziminin tamamlandığı iddia edilmez.

[Esas üretim planı](docs/PRODUCTION_PLAN.md) · [İlk harita taslağı](docs/maps/01-map-plan.md)

- Sürükle: haritada gezin; tekerlek: yakınlaş.
- Genel plan/bölge düğmeleri; R: genel plan; Tab: rotalar; TR/EN: dil.
- Veri: `world/nature/01-map.json`; sahne: `scenes/nature_workspace.tscn`.
- Yapısal kontrol: `godot --headless --path . --script tests/nature_plan_smoke.gd`.

Aşağıdaki oynanış kayıtları ve eski sahne **önceki denemelerin arşividir**. Oyun denemesi `scenes/main.tscn` olarak korunur, varsayılan açılmaz.

---

## Önceki oyun denemesi

**İlk oynanabilir dünya geliştirme sürümü.** Onaylı dört kahraman oyuna bağlı; dünya görseli kullanıcı eleştirileriyle yeniden tasarlanıyor. Tamamlanmış oyun veya nihai bölüm değildir.

[Yeni sesli vuruş/tepki kaydı](art/review/combat-hit-v3.mp4) · [Önceki hareket çalışması](art/review/motion-study-v2.mp4) · [Önceki oynanış kaydı](art/review/forest-playtest.mp4) · [Görseller](art/README.md) · [İşlem günlüğü](docs/DEVLOG.md)

![Dört kahraman seçimi](art/review/character-select-in-engine.png)

## Önceki denemeyi elle açma
Godot'ta `scenes/main.tscn` dosyasını açıp F6 kullanılır. Güncel varsayılan F5 girişi harita atölyesidir; bu eski oyun menüsünü açmaz.

| Kontrol | Oyuncu 1 | Oyuncu 2 |
|---|---|---|
| Hareket | A / D | ← / → |
| Zıplama | W veya Boşluk | ↑ veya Shift |
| Sarmaşığa tırman / in | W / S | ↑ / ↓ |
| Sarmaşıktan ayrıl | Boşluk | Shift |
| Sopa | F | K |
| Bumerang | G | L |

R: kontrol noktasına dön. Esc: menü. Kontrolcü: sol çubuk, alt yüz düğmesi zıplama, sol yüz düğmesi sopa, üst yüz düğmesi bumerang. Dokunmatik cihazda yön, zıplama, sopa ve bumerang düğmeleri; sarmaşık yanında zıplamaya basılı tutarak tırmanma. Fiziksel kontrolcü/mobil cihaz doğrulaması henüz yapılmadı.

## Güncel içerik
- 01 **Çağan**, 03 **Deniz**, ayrıca ismi belirlenmemiş 02 ve04. Onaylı kaynak çizimler SHA-256 ile korunur.
- Yerel tek/iki oyuncu; her oyuncu dört kahramandan birini seçer. Aynı kahraman da seçilebilir.
- Sürekli kaydırılan5120 birimlik alan; üç parallax katmanı, bağımsız ağaçlar/bitkiler, hareketli su ve kelebekler.
- Köklü toprak ve tabana oturan kayalık yükseltiler; nehir, şelale, sarmaşık, üst keşif alanı, düşen kayalar.
- Sopa ile sersemletme; bulunarak edinilen, geri döndükçe tekrar atılan, araziye takılırsa kaybolan bumerang.
- 19 meyve, kontrol noktası ve bölüm çıkışı.
- Çağan için8 kareli gövde+sopa saldırısı; gerçek temasla4 kareli büyük dinozor tepkisi, geri itilme, darbe bulutu ve ses. Menüde ses aç/kapat. Bu tam set diğer kahraman/türler için henüz bitmedi.
- **Yeni hareket pilotu:** Çağan için8 adımlı koşu ve iniş/hazırlık; ilk büyük dinozor için8 fazlı yürüyüş, uyarılı hamle ve toparlanma. Tür ölçekleri, çarpışma,3 can ve geri savurma güncellendi. Diğer kahraman/tür animasyonları hâlâ eski deneme düzeyinde; tüm hareketler tamamlanmadı.

Henüz yapılmayanlar: tam animasyon döngüleri, tam ses/müzik tasarımı, yüzme, kanatlı dosta binme, ağ/PC-mobil co-op, kalan bölümler ve dağıtım paketleri.

## Tasarım ve kararlar
[Vuruş ve tepki](docs/HIT_FEEDBACK.md) · [Hareket çalışması](docs/ANIMATION.md) · [Karakterler](docs/CHARACTERS.md) · [Dünya](docs/WORLD.md) · [Silahlar](docs/COMBAT.md) · [Oyun tasarımı](docs/GAME_DESIGN.md) · [Bölümler](docs/LEVELS.md) · [Kararlar](docs/DECISIONS.md) · [Görsel sözleşmesi](docs/ART_SPEC.md) · [Yol haritası](docs/ROADMAP.md)

## Kontroller / Tests
```
godot --headless --path . --editor --import --quit
godot --headless --path . --script tests/smoke.gd
godot --headless --path . --script tests/art_smoke.gd
godot --headless --path . --script tests/world_smoke.gd
godot --headless --path . --script tests/motion_smoke.gd
godot --headless --path . --script tests/combat_smoke.gd
```
Grafik ekranında `godot --path . --script tests/capture_art.gd` gerçek Godot ekran görüntülerini yeniler. `tests/record_demo.gd` gerçek tuş girdileriyle kısa bir otomatik oynanış kaydı içindir, kamera ışınlamaz.

Linux/Windows/Android/iOS hedeflenir. Henüz derlenmiş platform paketleri yok. Export templates gerekir; Android için SDK/JDK; iOS son paketleme ve imzalama için Mac/Xcode gerekir.

## English
The active stage is now **map first, then nature**. F5 opens a geography-only map workspace with pan/zoom, region views and TR/EN labels. This is a layout draft, not finished scenery or a playable level. Gameplay/creatures/quests/animation follow the map and nature stages. The previous game prototype is preserved at `scenes/main.tscn` and can be opened manually with F6. See `docs/PRODUCTION_PLAN.md`.
