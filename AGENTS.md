# AGENTS.md – Railforge

## Ziel
Richtiges Spiel (kein Web-Spiel): zuerst Windows, macOS, Linux, später Android und iOS.
Automatisierung (Factorio, Satisfactory, Dyson Sphere Program) + Transport Tycoon
(Schienen, Frachtverträge, Wirtschaft) + RPG. Der Spieler startet mit nichts, baut von Hand ab,
automatisiert und baut am Ende Rakete und Dyson-Schwarm.

## Kernkonzept (Evoland-Prinzip)
Das Spiel durchläuft die Geschichte der Videospielgrafik.
Jede Phase ist eine Ära mit eigener Grafik UND neuen Mechaniken.
Der Wechsel passiert live per Meilenstein mit Übergangsanimation, der Spielstand bleibt erhalten.

## Etappen-Prinzip (Wichtig)
- Jede Phase wird in **Etappen (Schritte)** unterteilt (z. B. Phase 1.1, 1.2, …).
- Jede Etappe hat ein klares Done-Kriterium.
- Die Etappen bauen aufeinander auf; der Spielstand bleibt zwischen Etappen erhalten.
- **Fortschrittsanzeige:** Das Spiel zeigt jederzeit die aktuelle Phase und Etappe an
  (z. B. „Phase 1 – Etappe 1.2: Inventar"). Implementiert ab Phase 1.
- Phase 0 baut nur die Struktur; Spielcode beginnt in Phase 1 mit Etappe 1.1.

## Git-Strategie (Wichtig)
- **NUR `main`** als Arbeitsbranch. Kein Branch pro Phase.
- **Ein Commit pro Etappe** (z. B. `Phase 1.2: Handabbau & Inventar`).
- **Ein Git-Tag pro abgeschlossener Phase** (`phase-0-fundament`, `phase-1-monochrom`, …).
- **Kein PR pro Phase.** Review über Commits und Tags.
- Rollback per `git checkout <tag>`.

## Technik
Godot 4.3+, GDScript, GL Compatibility. Mobile-tauglich geplant:
Eingabe über Input-Map (Maus und Touch), skalierbare UI.

## Architektur
- `src/core/` Logik und Spielstand (RefCounted, keine Nodes, kein Rendering), testbar.
- `src/render/era_renderer.gd` Basisklasse, `src/render/eras/` ein Renderer pro Ära.
- `data/*.json` Daten (Ären, später Rezepte, Gebäude, Forschung).
- Ära 1-4 2D, ab Ära 5 3D (Low-Poly).
- Feature-Flags im Core schalten Mechaniken pro Ära frei.
- Debug-Menü: Ära wechseln, Ressourcen cheaten.
- Speichern mit Versionsnummer in `user://`.
- Fortschrittsanzeige: liest Phase/Etappe aus dem Spielstand und rendert sie im Renderer.

## Start
Godot 4.3+ öffnen → Importieren → `project.godot` → F5.

## Stil
Kommentare Deutsch, Variablen/Funktionen Englisch (snake_case), kleine Dateien, statische Typen.

## Regeln
- Arbeite auf `main`. Ein Commit pro Etappe. Ein Tag pro Phase. Kein Branch/PR pro Phase.
- Nach jeder Phase STOPP, auf Freigabe warten, nie selbst die nächste Phase beginnen.
- Innerhalb einer Phase: Etappen nacheinander umsetzen, jede mit Done-Kriterium.
- Am Phasenende aktualisieren: CHANGELOG.md, docs/PHASEN_GUIDE.md (Status), AGENTS.md,
  .clinerules, .github/copilot-instructions.md, README, docs/GDD.md.
- Tag am Phasenende setzen (`phase-N-…`).
- Frühere Ären bleiben spielbar.
- `.godot/` nie committen.

## Phasenplan
Siehe `docs/PHASEN_GUIDE.md`.

## Aktueller Stand
Phase 0 (Fundament und Dokumente): erledigt, wartet auf Freigabe.
Nächste: Phase 1 – Etappe 1.1 (Bewegung & Kamera).
