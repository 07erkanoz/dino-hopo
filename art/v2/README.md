# Dino Hop! — Taslak A varlık paketi / Concept A asset pack

Bu paket Job #140 için üretilir. Görsel yönün kaynağı `taslaklar/taslak-a.png` ve kullanıcının güncel iş talebidir. Eski çizgi film doğa aşaması kapsamını bu iş için genişleten karar kullanıcıya aittir. Bu dosyalar yeni görsel üretimdir; Godot'a entegrasyon, animasyon veya nihai kullanıcı onayı anlamına gelmez.

This pack is new artwork for Job #140, following the user's selected Concept A. Assets do not imply Godot integration, finished animation, or final visual approval.

## Üretim / Generation

Araç / Tool: OpenAI built-in `image_gen`, gerçek alfa istenerek ayrı doğa katmanları ve parçalı karakter/nesne paftaları üretildi. Tam istemler `sources/prompts.json` içindedir. Kaynak üretimler `sources/` altında saklanır. Python/Pillow yalnız parçaları ayırmak, tutarlı ölçüye getirmek, döşeme kenarlarını birleştirmek, pivotları kaydetmek ve istenen kompozitleri hazırlamak için kullanılır. Çizimler piksel sanat veya vektör yer tutucu değildir.

OpenAI built-in image generation produces the painted artwork. Python/Pillow handles atlas extraction, consistent sizing, tile-boundary preparation, metadata and requested composites. Full prompts and original generated sheets are retained under `sources/`.

## Tutarlılık kararları / Consistency decisions

- Kabul / Accepted: Taslak A; altın-sol üst ışık, krem bulut, turkuaz gökyüzü ve uzak plan, sıcak okr-turuncu kayalar, lime/teal bitkiler. Başka oyunların grafiklerini kopyalamaz.
- Kabul / Accepted: Çağan'ın onaylı kimliği ve adı korunur; kaynak paftalara yazılmaz. Yeni rig parçaları ayrıca üretilmiştir, mevcut onaylı PNG'lerin yerine geçmez.
- Teknik başlangıç / Technical starting point: Piksel pivotları yerel PNG koordinatıdır; `bind_position` rig koordinatıdır. `parent` alanları kemik sırasını tanımlar. Uzak uzuvlar önce çizilir. Eklemlerin yuvarlak uçları komşu parçanın altında örtüşür.
- Öneri / Proposal: İkinci düşman doğal oranlı küçük pterozordur; pas-turuncu sırt, altın kanat zarı, teal tepelik. Uçan tür için gövde, kafa, kuyruk, iki parçalı iki kanat ve iki ayak ayrılır. Davranış uygulanmamıştır.
- Öneri / Proposal: Manifestteki paralaks hızları ve sahne ölçekleri başlangıç değerleridir. Motor içi döşeme ve animasyon sanat yönetimi ayrıca incelenmelidir.

Second enemy: an original small flying pterosaur with rust-orange body, golden wing membranes and teal crest. Its two wings each have upper and outer pieces. No enemy behavior is implemented.

## Kullanım / Usage

`manifest.json` dosya boyutlarını, yerel pivotları, hiyerarşileri ve önerilen paralaks oranlarını içerir. Önizleme bir varlık kompozitidir; motor ekran görüntüsü değildir. İkonlarda dil bağımlı yazı yoktur. Puan/can metinleri entegrasyonda TR/EN yerelleştirilebilir. Kaynak paftalar doğrudan tek sprite olarak kullanılmaz; ayrı PNG parçaları kullanılır.

The manifest records dimensions, pivots, bone hierarchy and suggested parallax factors. The preview is an asset composite, not an engine capture. Icons have no embedded language-dependent text; score/lives labels should be localized during integration.

## Envanter ve doğrulama / Inventory and validation

4 adet 1920×1080 paralaks, 13 zemin/dekor, 41 ayrı rig parçası (Çağan 16, ceratopsian 16, pterozor 9), 3 birleşik rig önizlemesi, 6 toplanabilir, 7 UI PNG; iki ana kompozit ve 12 ham/düzeltilmiş üretim kaynağıyla toplam 88 PNG manifesttedir. Bütün parça ölçüleri ve pivotları manifestte bulunur. Çağan'ın 450 kaynak piksel referansı 128 mantıksal birime eşlenir. `bones` dizisi parent öncelikli sıradadır; konum ve dönüşler Godot'un parent yerel koordinatlarına çevrilmiştir. `parts.bind_position` mutlak pafta koordinatıdır.

Four 1920×1080 parallax layers, thirteen terrain/props, forty-one rig parts, three assembled rig previews, six pickups and seven UI images are included. With composites and twelve generation sources, the manifest inventories 88 PNG files. Godot bone transforms are parent-local; source part bind positions are absolute image coordinates.

İlk üç paralaks katmanında premultiplied alfa ile sarma/kenar eşleme; yakın bitkide saydamlık solması oluşturmayan aynalı bitki periyodu kullanıldı. Büyük kenar ağacı, `terrain/foreground-tree-frame.png` içinde ayrı ve **tekrarsız** dekor olarak tutulur; dört döşenebilir paralaksın yerine geçmez. Ot, toprak ve su X yönünde; toprak ayrıca Y yönünde döşenir. Sarmaşık üst pivotu destek ağacın dalına, ağaç kökü zemin yüzeyine bağlanmalıdır.

The foreground foliage uses a mirrored repeat without fading the tree silhouette. The large edge tree is a separate nonrepeating framing prop. Grass, soil and water repeat horizontally; soil also repeats vertically. Attach vines to supporting tree branches and tree roots to the terrain surface.

Verilen kabul komutu **exit 0**, `eksik: []`. Ek doğrulama **exit 0**: 88 PNG açılır, kayıtlı boyut/SHA-256 değerleri eşleşir; 4/4 yatay sınır sütunu eşittir; 41/41 pivot opak parçanın içindedir; hiyerarşiler döngüsüzdür; üretim kesitlerinde saydam RGB sıfır ve 1–7 alfa kalıntısı yoktur. Onaylı kahraman kaynaklarının SHA-256 değerleri 2/2 değişmemiştir. Ayrıntılar: `review/validation.json`.

Visual checks: `review/final-rigs-light-dark.jpg`, `review/parallax-repeat-check.jpg`, `compare-taslak-a.png`. Kompozit 1920×1080, karşılaştırma 3840×1080; karşılaştırmanın solu Taslak A, sağı yeni varlık kompozitidir. Yan yana inceleme altın ışık, turkuaz/teal uzak plan, okr kaya ve lime bitkilerin aynı görsel yönde olduğunu gösterir. Teknik kontroller kullanıcı estetik onayı sayılmaz. Dinamik eklem animasyonu ve motor içi entegrasyon bu işin kapsamı değildir.

İşlem ve karar kayıtları yalnız `art/v2/` yazma sınırına uymak için bu pakette tutulur: [DEVLOG](docs/DEVLOG.md), [DECISIONS](docs/DECISIONS.md), [ART_SPEC](docs/ART_SPEC.md). Mevcut kök `docs/` dosyaları değiştirilmedi.
