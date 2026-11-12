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

## Etappen-System
Jede Phase ist in Etappen (Schritte) unterteilt. Jede Etappe hat ein Done-Kriterium.
Eine Fortschrittsanzeige im Spiel zeigt Phase + Etappe an.
Phase 0 baut nur die Struktur; Phase 1 ist in Etappen 1.1–1.6 gegliedert.

## Git-System
Arbeit auf `main`. Commit pro Etappe. Tag pro Phase (`phase-N-…`). Kein Branch/PR pro Phase.

## Offen
Setting/Story, Freischalt-Meilensteine, Balancing, Multiplayer (erst nach Phase 8).
