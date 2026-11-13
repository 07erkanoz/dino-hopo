# Dino Hop! — Görünüm taslakları / Visual concepts

Bu üç görsel seçim için üretilmiş, oyun içi ekranı temsil eden taslaklardır; Godot çıktısı, onaylı nihai varlık veya uygulanmış oyun değildir. Paralaks derinliği resimde temsil edilir; PNG'ler bağımsız katmanlar içermez. Karakterler parçalı animasyona uygun silüet fikrini gösterir; ayrı animasyon parçaları değildir. Çağan'ın onaylı renk ve giysi fikirlerinden esinlenilmiştir; onaylı kaynaklar değiştirilmemiştir. Üç yön de seçim önerisidir.

These are selection concepts representing gameplay screens, not Godot captures, approved final assets, or implemented gameplay. Parallax depth is depicted within each flattened PNG; character silhouettes suggest separable animation parts but are not rig-ready assets. They draw on Çağan's approved clothing and color ideas without modifying the approved source files. All three directions await selection.

## A — Güneşli tropik / Sunny tropical
- Palet / Palette: altın, turuncu, turkuaz ve canlı yeşil / gold, orange, turquoise and vivid green.
- Işık ve oran / Light and proportions: sıcak gün ışığı, sevimli ve abartılı karakterler / warm daylight, cute exaggerated characters.
- Stil istemi / Style prompt: “sunny vivid tropical prehistoric forest, warm golden orange and teal greens, lively playful exaggerated cartoon proportions, richly hand-painted animation backgrounds.”

## B — Ilıman orman / Temperate forest
- Palet / Palette: zeytin, toprak kahvesi ve doğal yeşiller / olive, earth brown and natural greens.
- Işık ve oran / Light and proportions: yumuşak ışık hüzmeleri, daha oranlı çizgi film karakterleri / soft light shafts, more proportionate cartoon characters.
- Stil istemi / Style prompt: “temperate prehistoric woodland, clear air without fog or blur, soft warm shafts of light, restrained natural olive and sienna palette, more proportionate but still cartoon characters, detailed hand-painted look.”

## C — Masal guajı / Storybook gouache
- Palet / Palette: adaçayı, pudra pembe, okr ve gök mavisi / sage, dusty rose, ochre and sky blue.
- Işık ve oran / Light and proportions: yumuşak gündüz ışığı, kalın konturlu, sevimli karakterler / soft daylight, bold outlined, playful characters.
- Stil istemi / Style prompt: “fairy tale storybook gouache and watercolor on textured paper, pastel sage, dusty rose, ochre and sky blue, expressive thick outlined cartoon characters, whimsical painted foliage.”

## Yöntem ve ortak istem / Method and shared prompt

OpenAI image generation ile her yön ayrı üretildi; sonuçlar 1920×1080'e merkezden kırpılıp Lanczos ile yeniden boyutlandırıldı. Sis/blur içermeyen B, mevcut doğa kararlarıyla uyumluluk için seçildi. Görseller özgündür; başka bir oyunun grafikleri kopyalanmadı.

Each direction was generated separately with OpenAI image generation, then center-cropped and resized to 1920×1080 using Lanczos. B avoids fog and blur in line with existing nature decisions. The illustrations are original and do not copy another game's graphics.

Ortak istem / Shared prompt: “Create an original wide 16:9 2D side-scrolling platform game screenshot mockup, no reference to any existing game's art. Landscape composition has clearly distinct sky, distant mountains/forest, and close detailed foliage layers for implied parallax, irregular earth ground and raised platforms, small natural flowers, waterfall and stream. Full-body friendly caveman hero inspired by an original design: stocky build, messy dark hair with blue feather, orange spotted tunic and turquoise belt, holding a wooden club; readable separate head torso limbs and club. Two clearly separate enemies: small cute dinosaur AND wild boar. Scattered collectible fruit. Along the top a readable game HUD with score numbers, three hearts and fruit icon counter. Bottom left translucent direction buttons with arrows, bottom right translucent circular jump and attack buttons. All elements visible with generous spacing, actual gameplay view, not a collage or character sheet. Hand painted detailed 2D, no pixel art, no flat vectors, no logos. The image is an early concept, not actual in-engine gameplay.”
