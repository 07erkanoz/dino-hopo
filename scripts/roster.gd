extends RefCounted
## Approved visual identities. Proper names remain unchanged in both languages.
const HEROES := [
	{"id": "01", "name": "Çağan", "tr": "Turuncu tunik", "en": "Orange tunic"},
	{"id": "02", "name": "", "tr": "Kırmızı tunik", "en": "Red tunic"},
	{"id": "03", "name": "Deniz", "tr": "Turkuaz tunik", "en": "Teal tunic"},
	{"id": "04", "name": "", "tr": "Mor tunik", "en": "Purple tunic"}
]

static func hero_name(index: int, language: String = "tr") -> String:
	var hero: Dictionary = HEROES[index]
	if hero.name != "":
		return hero.name
	return ("Kahraman " if language == "tr" else "Hero ") + hero.id

static func frame(index: int, pose: int) -> int:
	return pose * 4 + index
