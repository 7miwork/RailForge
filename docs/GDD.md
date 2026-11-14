# Game Design Dokument – Railforge

## Vision
Der Spieler startet mit nichts auf einem Planeten und baut sich über Handabbau, Automatisierung,
Forschung, Transport und Handel bis zu Rakete und Dyson-Schwarm hoch.
Das Spiel erzählt dabei die Geschichte der Videospielgrafik (Evoland-Prinzip).

## Plattformen
Zuerst Windows, macOS, Linux. Später Android und iOS (Touch-Steuerung von Anfang an mitdenken).

## Vorbilder
Factorio, Satisfactory, Dyson Sphere Program (Automatisierung), Transport Tycoon Deluxe
(Schienen, Frachtverträge), RPGs (Skills, Story).

## Säulen
1. **Automatisierung:** von Hand zu Fabriken, Förderbändern, Strom.
2. **Fortschritt durch Ären:** Grafik und Mechaniken entwickeln sich gemeinsam.
3. **Skills:** manuelle Fähigkeiten steigen durch Wiederholung, aufwändig.
4. **Forschung:** großer Tech-Baum schaltet Gebäude und Rezepte frei.
5. **Transport und Handel:** Schienen, Frachtverträge, KI-Firmen als Handelspartner.
6. **RPG:** Story, NPCs, Quests, Fraktionen.

## Ära-System
Spielstand und Logik sind ären-unabhängig. Nur der Renderer wird getauscht.
Meilensteine lösen den Wechsel live aus, mit Übergangsanimation.

## Ära 1 – Monochrom (Game Boy)
Erster spielbarer Stand: reine Handarbeit ohne Maschinen.
Optik im Game-Boy-Stil: 4-Grün-Palette (`#0f380f`, `#306230`, `#8bac0f`, `#9bbc0f`),
16×16-Tiles, 8×8-Spieler, Low-Res-Rendering via 160×144-SubViewport mit Integer-Scaling.
Alle Texturen werden zur Laufzeit prozedural erzeugt – keine binären Assets im Repo.
Mechanik: Bewegen, Abbauen (Holz, Stein, Erz), Inventar (20 Slots), Crafting
(Brett, Steinziegel, Steinspitzhacke, Eisenguss), Speichern/Laden, Debug-Overlay.


## Ära 2 – 8-Bit-Farbe (NES)
Farbe statt Game-Boy-Grün: NES-Palette (~17 Farben), 256×240-Auflösung.
Ära-Wechsel per Meilenstein: 5 gecraftete Eisenbarren schalten Ära 2 frei
(`EraUnlocks` prüft `eras.json`-Bedingungen gegen GameState-Stats).
`EraManager` tauscht Renderer, Viewport-Auflösung und Welt-Skins
(Tiles, Backdrop) live aus; `EraTransition` spielt eine ~1,5-s-Flacker-
Animation mit Eingabe-Lock. Fortlaufend: Skills, Bau-Modus, Miner,
Förderbänder, Schmelzofen (Etappen 2.2–2.5).

## Etappen-System
Jede Phase ist in Etappen (Schritte) unterteilt. Jede Etappe hat ein Done-Kriterium.
Eine Fortschrittsanzeige im Spiel zeigt Phase + Etappe an.
Phase 0 baut nur die Struktur; Phase 1 ist in Etappen 1.1–1.6 gegliedert.

## Git-System
Arbeit auf `main`. Commit pro Etappe. Tag pro Phase (`phase-N-…`). Kein Branch/PR pro Phase.

## Offen
Setting/Story, Freischalt-Meilensteine, Balancing, Multiplayer (erst nach Phase 8).
