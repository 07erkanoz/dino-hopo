# Job #141 doğrulama rehberi

Diff büyük; çoğu ekran görüntüsü ve `.import` dosyası. Bu rehber her maddeyi kod, test ve görüntüyle eşler; tam diff'i okumak gerekmez.

**Tek komut:** `bash tools/verify.sh`. Çıktı sırası:
1. içe aktarma;
2. 13 test, her biri PASS ya da FAIL;
3. **Animation evidence** bölümü: Çağan'ın 9 animasyonu, iki düşman rigi ve ayak kayması değeri;
4. **Screenshots** bölümü: görüntü gruplarının sayıları;
5. Linux, Windows ve Android dışa aktarmaları;
6. `build/` çıktılarının boyutları.

Bir madde eksikse betik sıfırdan farklı kodla çıkar.

| Madde | Kod | Test | Görüntü |
|---|---|---|---|
| Hareket fiziği | `scripts/player.gd:23-37` (`@export`: ivme, `jump_cut`, `coyote_time` 0,1, `jump_buffer_time` 0,12) | `tests/physics_test.gd` | — |
| Çağan iskeleti | `scripts/rig/rig.gd:93` (IK), `rig.gd:173` (AnimationTree + xfade + TimeSeek), `scripts/rig/cagan_rig.gd:15` (durumlar) | `tests/animation_test.gd` (9 animasyon, geçişler, ayak kayması 0,02 px) | `ekran/cagan-01..10-*.png`, `ekran/cagan-animasyonlar.png`, `ekran/rig-cagan.png` |
| Düşman rigleri | `scripts/rig/dino_rig.gd:12`, `scripts/rig/ptero_rig.gd:5`, `scripts/dino.gd` | `tests/animation_test.gd`, `tests/enemy_test.gd` (hasar → ölüm → puan) | `ekran/dusman-*.png`, `ekran/rig-dino.png`, `ekran/rig-ptero.png` |
| Doğa | `scripts/forest.gd:62` (CanvasModulate), `forest.gd:83` (4 × Parallax2D), `forest.gd:162` (su ve şelale) | `tests/world_smoke.gd`, `tests/nature_*_smoke.gd` | `ekran/01..04-oyun-*.png` |
| Oynanış | `world/levels/01.json` (çıkış, gizli alan, düşmanlar, bonuslar), `scripts/game.gd:395` (toplama), `game.gd:430` (kazanma ve oyun bitti) | `tests/score_test.gd`, `tests/level_test.gd` (çıkışa ve 28 toplanabilire erişim, yeniden başlama) | `ekran/02-oyun-savas.png` |
| Kontroller | `tools/setup_input.gd` (InputMap), `scripts/touch_controls.gd:15` (yalnız dokunmatik cihazda) | `tests/touch_test.gd` | `ekran/05-mobil-dokunmatik-*.png` (20:9, 16:9, 4:3) |
| Dışa aktarma | `export_presets.cfg` (Linux, Windows Desktop, Android arm64 yatay; anahtar deposu ortam değişkeninden, satır 68-69) | `tools/verify.sh` | — |
| Taslak A | — | — | `ekran/06-taslak-a-karsilastirma.png` |

**Android:** Bu makinede JDK ve Android SDK yok, kurulmadı. Betik `ANDROID EXPORT SKIPPED` yazar ve başarısız saymaz.

**Görüntüleri yeniden üretmek:** `bash tools/capture.sh`. Betik sırayla xvfb-run, başsız kwin_wayland ya da `$DISPLAY` kullanır.
