# Üretim sırası — esas çalışma planı

2026-11-12 tarihli kullanıcı düzeltmesi bu planın dayanağıdır. Önceki prototipte arazi/doğa oturmadan oyun, düşman ve dövüş eklendi; bu yaklaşım bırakıldı.

## Şu an:1 — Harita

Aktif sahne `scenes/nature_workspace.tscn`, veri `world/nature/01-map.json`. F5 harita atölyesini açar. Veri yalnız coğrafya, rotalar, su bağlantıları ve ağaç/dal yerleşim taslağı içerir. Düşman, silah, meyve, görev veya kahraman hareketi eklenmez.

[İlk harita planı](maps/01-map-plan.md). Harita **taslaktır**; çizgi film doğası veya bitmiş oynanabilir bölüm değildir.6144×1536 ölçüsü ve bölge sınırları teknik çalışma önerisidir, kullanıcı tarafından kesinleştirilmedi.

## Sıra

| Aşama | Yapılacak iş | Sonraki aşamaya geçiş ölçütü |
|---|---|---|
| **1 Harita** | Arazi profili, ana akış, alt/üst yollar, nehir yatağı, şelale kaynağı, mağara ve bağlantılar | Bütün alan bir harita olarak okunur; yollar ve coğrafya tutarlı, boşluk/bağlantılar açık olur. |
| **2 Doğa** | Haritaya göre ağaç, dal, kök, kaya, toprak, su ve bitki kompozisyonu | Tek bir çizim dili/ölçek; doğal bağlantılar; uçan sarmaşık, kesilen parça ve uyumsuz doku kalmaz. Bu aşama tamamlanmadan oyun nesneleriyle örtülmez. |
| **3 Engeller ve zorluklar** | Tamamlanan doğanın geçişlerine uygun engeller ve zorluk eğrisi | Doğaya anlamlı yerleşim ve okunabilir risk; yalnız tekrar eden zıplama dizisi olmaz. |
| **4 Dinozorlar ve yaratıklar** | Tür, ölçek, habitat, karşılaşma alanı ve davranış | Her canlı için yeterli alan ve çevreyle tutarlı hareket vardır. |
| **5 Bulmacalar ve görevler** | Keşif, geri dönüş, alternatif yollar ve amaçlar | Harita akışını kullanan, anlaşılır görev/bulmaca düzeni vardır. |
| **6 Kahraman/doğa hareketleri** | Tam hareket setleri, çevre tepkileri, etkileşim ve zamanlama | Kahraman, canlı, doğa ve ses bir olay zinciri olarak çalışır; yalnız parça sayısı veya teknik test yeterli sayılmaz. |

Kullanıcının belirttiği sıradır. Harita/doğa eksiklerini yeni animasyon, efekt veya görev ekleyerek gizlemek yerine ilgili aşamada düzeltiriz. Yeni çalışmada bu aşamadan ileri özellik geliştirilmez. Doğa inceleme sırasında görülen sorunlar önce giderilir.

## Bağlantı kuralları

- Ağaç ayağı arazi yüzeyinden türetilir; rasgele ayrı Y konumu verilmez.
- Sarmaşığın başlangıcı `tree_id + branch_id` ile belirlenir. Serbest havada bir başlangıç noktası tanımlanamaz.
- Fiziksel destek ağacı, dal ve sarmaşık aynı dünya katmanında ve koordinat sistemindedir. Parallax yalnız bağımsız uzak dekor içindir.
- Şelalede besleyen akış, kaya eşiği, düşüş, havuz ve çıkış birlikte planlanır.
- Mağara girişi, iç hacmi ve çıkışı haritada birbirine bağlanır.
- Kahraman çizimleri ölçek referansıdır; bu aşamada oynanabilir kahraman eklenmez. Haritada128 birim cetvel bulunur.

## Önceki denemelerin durumu

`scenes/main.tscn` ve mevcut oyun/animasyon dosyaları silinmedi. Bunlar eski deneylerdir; doğanın tamamlandığına kanıt veya üretim sırasını atlama gerekçesi değildir. Manuel F6 ile eski sahne açılabilir, varsayılan başlangıç değildir.

Kesilmiş ayak, efektin sopayı kapatması ve eski sarmaşık görünümü önceki denemenin bilinen sorunlarıdır. Ayak için üretilmiş yeni aday `art/review/cagan-attack-gutter-candidate.png` olarak saklandı; doğrulanmış/aktif düzeltme sayılmaz. Kahraman/efekt üzerinde yeni çalışma bu sıranın yerine geçmez.

## Doğrulama

`tests/nature_plan_smoke.gd` veri ayrımını, bölge sürekliliğini, ağaç–zemin ve sarmaşık–dal referanslarını ve yalnız haritayla başlayan sahneyi kontrol eder. Bu yapısal kontrol, doğanın güzel veya tamamlanmış olduğunu göstermez.
