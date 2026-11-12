# Phasen-Guide
Jede Phase = eine Grafik-Ära + neue Mechaniken, unterteilt in **Etappen (Schritte)**.
Status: ⬜ offen · 🟨 in Arbeit · ✅ fertig.
Der Freischalt-Meilenstein jeder Ära wird in der Vorgängerphase festgelegt.
Jede Etappe hat ein sichtbares Done-Kriterium und wird im Spiel als Fortschritt angezeigt
(Phase + Etappe). Die Fortschrittsanzeige wird ab Phase 1 implementiert.

## Git-Konvention
- Arbeit auf `main`. Kein Branch pro Phase, kein PR pro Phase.
- Ein Commit pro Etappe (z. B. `Phase 1.2: Handabbau & Inventar`).
- Ein Git-Tag pro abgeschlossener Phase (`phase-0-fundament`, `phase-1-monochrom`, …).
- Rollback per `git checkout <tag>`.

## Phase 0 – Fundament ✅ `tag: phase-0-fundament`
- **Ziel:** Projektgerüst und Dokumente, kein Spielcode, nur Struktur.
- **Done:** Projekt öffnet in Godot 4.3+ und zeigt „Railforge – Phase 0", alle Dokumente vorhanden.
- **Test:** Godot → Importieren → `project.godot` → F5.

## Phase 1 – Ära Monochrom (Game Boy) ⬜ `tag: phase-1-monochrom`
Die Phase ist in Etappen unterteilt. Jede Etappe ist ein eigener Commit mit Done-Kriterium.
Die Etappen bauen aufeinander auf; der Spielstand bleibt zwischen Etappen erhalten.
Eine Fortschrittsanzeige im Spiel zeigt Phase und Etappe.

### Etappe 1.1 – Bewegung & Kamera ⬜
- Spieler-Figur, Bewegung über Input-Map (Tastatur + Touch), Kamera folgt.
- Fortschrittsanzeige: zeigt „Phase 1 – Etappe 1.1".
- **Done:** Spieler bewegt sich in alle Richtungen, Touch funktioniert.

### Etappe 1.2 – Handabbau & Inventar ⬜
- Ressourcen per Hand abbauen, Inventar mit Slots und Stack-Größen.
- **Done:** Abbauen füllt Inventar, Inventar-UI zeigt Items.

### Etappe 1.3 – Handcrafting ⬜
- Rezepte als JSON in `data/`, Crafting-UI, Freischalten einfacher Rezepte.
- **Done:** Spieler crafted ein Item aus abgebauten Ressourcen.

### Etappe 1.4 – Speichern/Laden & Debug-Menü ⬜
- Speichern mit Versionsnummer in `user://`, Laden beim Start.
- Debug-Menü: Ära wechseln, Ressourcen cheaten.
- **Done:** Spielstand übersteht Neustart, Debug-Menü funktioniert.

### Etappe 1.5 – Fortschrittsanzeige & GUT-Tests ⬜
- Sichtbare Fortschrittsanzeige (Phase + Etappe) aus dem Spielstand.
- Erste GUT-Tests für Core-Logik (Inventar, Crafting, Save/Load).
- **Done:** Anzeige korrekt, Tests grün.

### Etappe 1.6 – Game-Boy-Look & Polish ⬜
- 4 Grünstufen, 2D-Tiles, top-down, Übergangsanimation zum Ära-Wechsel vorbereiten.
- **Done:** Ära 1 sieht wie Game Boy aus, spielbar von Start bis Etappe 1.6.

- **Freischaltung Ära 2:** Meilenstein wird in Etappe 1.6 festgelegt.

## Phase 2 – Ära 8-Bit-Farbe (NES) ⬜ `tag: phase-2-nes`
- **Grafik:** NES-Palette, Ära-Wechsel mit Übergangsanimation.
- **Mechaniken:** Skills durch Wiederholung, Miner, Förderbänder, Schmelzöfen.
- Etappen werden bei Freigabe der Phase festgelegt.

## Phase 3 – Ära 16-Bit (SNES) ⬜ `tag: phase-3-snes`
- **Grafik:** mehr Farben, Parallax.
- **Mechaniken:** Assembler, Strom, großer Forschungsbaum.
- Etappen werden bei Freigabe der Phase festgelegt.

## Phase 4 – Ära Isometrisch 2.5D ⬜ `tag: phase-4-iso`
- **Grafik:** Isometrisch (Transport-Tycoon-Stil).
- **Mechaniken:** Schienen, Züge, Stationen, Routen, Frachtverträge.
- Etappen werden bei Freigabe der Phase festgelegt.

## Phase 5 – Ära Früh-3D (PS1-Look) ⬜ `tag: phase-5-ps1`
- **Grafik:** 3D, Low-Poly, Kugel-Planet.
- **Mechaniken:** Wirtschaft, KI-Firmen als Handelspartner/Konkurrenten, Märkte, schwankende Preise.
- Etappen werden bei Freigabe der Phase festgelegt.

## Phase 6 – Ära Modernes 3D ⬜ `tag: phase-6-modern`
- **Mechaniken:** RPG mit Story, NPCs, Quests, Fraktionen.
- Etappen werden bei Freigabe der Phase festgelegt.

## Phase 7 – Ära Endgame ⬜ `tag: phase-7-endgame`
- **Mechaniken:** Rakete, weitere Planeten, Dyson-Schwarm, moderne Effekte.
- Etappen werden bei Freigabe der Phase festgelegt.

## Phase 8 – Balancing, Export, Mobile ⬜ `tag: phase-8-release`
Balancing, Performance, Exporte für Windows/macOS/Linux, danach Android und iOS
(iOS braucht Mac und Apple-Entwicklerkonto).
Etappen werden bei Freigabe der Phase festgelegt.
