# Changelog
Format nach [Keep a Changelog](https://keepachangelog.com/de/). Ein Abschnitt pro Phase,
Etappen als Unterpunkte. Jede abgeschlossene Phase erhält einen Git-Tag `phase-N-…`.

## [Unreleased]

## [Phase 0] – Fundament `tag: phase-0-fundament`
### Hinzugefügt
- Godot-4-Projekt (GL Compatibility), Platzhalter-Szene
- `GameState`, `DataLoader`, `EraRenderer`-Basisklasse, `data/eras.json`
- AGENTS.md, .clinerules, .github/copilot-instructions.md
- docs/PHASEN_GUIDE.md, docs/GDD.md, README.md
- Etappen-Konzept und Fortschrittsanzeige in Docs/Regeln verankert
- Git-Strategie: nur `main`, Commit pro Etappe, Tag pro Phase

## [Phase 1] – Ära Monochrom (Game Boy) ✅ `tag: phase-1-monochrom`
### Hinzugefügt
- 1.1 Bewegung & Kamera (Input-Map, Camera2D-Smoothing, virtueller Joystick)
- 1.2 Handabbau & Inventar (ItemDB, Inventory 20 Slots, ResourceNode, Mining)
- 1.3 Handcrafting (RecipeDB, Crafting transaktional, Crafting-UI, Stats)
- 1.4 Speichern/Laden & Debug-Menü (SaveManager user://save.json, Debug-Overlay)
- 1.5 Fortschrittsanzeige & GUT-Tests (Progress statisch, HUD 4-zeilig,
  Milestone-Toasts, Coverage-Report, Edge Cases)
- 1.6 Game-Boy-Look & Polish (SubViewport 160×144, Tiles prozedural,
  GB-Palette in UI, EraTransition-Stub, TileMapLayer-Welt)

## [Phase 2] – Ära 8-Bit-Farbe (NES) `laufend`
### Hinzugefügt
- 2.1 Ära-Wechsel und NES-Renderer (EraManager mit Runtime-Renderer-Tausch,
  Era2Nes mit NES-Palette, TilesNES prozedural, 256×240-Viewport,
  echte EraTransition-Animation ~1,5 s mit Eingabe-Lock,
  Meilenstein 5× Eisenbarren → Ära 2, Multi-Phase progress.json,
  EraUnlocks Core-Logik, Debug-Ärawechsel echt)

## [Phase 3] – Ära 16-Bit (geplant)
## [Phase 4] – Ära Isometrisch (geplant)
## [Phase 5] – Ära Früh-3D (geplant)
## [Phase 6] – Ära Modernes 3D (geplant)
## [Phase 7] – Ära Endgame (geplant)
## [Phase 8] – Balancing, Export, Mobile (geplant)
