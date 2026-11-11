# Dino Hop!

Türkçe / English · Godot 4.6.3 · GDScript · 2D platform adventure

GitHub: https://github.com/07erkanoz/dino-hopo

**İlk oynanabilir dünya geliştirme sürümü.** Onaylı dört kahraman oyuna bağlı; dünya görseli kullanıcı eleştirileriyle yeniden tasarlanıyor. Tamamlanmış oyun veya nihai bölüm değildir.

[Gerçek oynanış kaydı](art/review/forest-playtest.mp4) · [Görseller](art/README.md) · [İşlem günlüğü](docs/DEVLOG.md)

![Dört kahraman seçimi](art/review/character-select-in-engine.png)

## Başlatma
Godot 4.6 ile `project.godot` dosyasını açın, **F5** ile çalıştırın. Komut satırından `godot --path .`.
Menüden tek/iki oyuncu, ardından dört kahramandan seçim yapılır.

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

Henüz yapılmayanlar: tam animasyon döngüleri, sesler, yüzme, kanatlı dosta binme, ağ/PC-mobil co-op, kalan bölümler ve dağıtım paketleri.

## Tasarım ve kararlar
[Karakterler](docs/CHARACTERS.md) · [Dünya](docs/WORLD.md) · [Silahlar](docs/COMBAT.md) · [Oyun tasarımı](docs/GAME_DESIGN.md) · [Bölümler](docs/LEVELS.md) · [Kararlar](docs/DECISIONS.md) · [Görsel sözleşmesi](docs/ART_SPEC.md) · [Yol haritası](docs/ROADMAP.md)

## Kontroller / Tests
```
godot --headless --path . --editor --import --quit
godot --headless --path . --script tests/smoke.gd
godot --headless --path . --script tests/art_smoke.gd
godot --headless --path . --script tests/world_smoke.gd
```
Grafik ekranında `godot --path . --script tests/capture_art.gd` gerçek Godot ekran görüntülerini yeniler. `tests/record_demo.gd` gerçek tuş girdileriyle kısa bir otomatik oynanış kaydı içindir, kamera ışınlamaz.

Linux/Windows/Android/iOS hedeflenir. Henüz derlenmiş platform paketleri yok. Export templates gerekir; Android için SDK/JDK; iOS son paketleme ve imzalama için Mac/Xcode gerekir.

## English
An early local co-op platform adventure featuring four approved illustrated heroes, including Çağan and Deniz. One continuous world prototype includes independent parallax scenery, climbing vines, warning rocks, collectibles, checkpoints, clubs and discoverable returning boomerangs that can be lost on terrain. The scenery is under revision; this is not a finished game. Open `project.godot` in Godot4.6 and press F5. English is selectable in the menu.
