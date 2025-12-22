# Chemie Lernen - Projekt-Überblick

## Zusammenfassung

**Chemie Lernen** ist eine innovative Bildungsplattform, die **Virtual Reality (VR)** mit webbasierten Lernressourcen kombiniert, um Chemie auf interaktive und fesselnde Weise zu vermitteln. Das Projekt ist unter `chemie-lernen.org` erreichbar und stellt einen interdisziplinären Ansatz für die chemische Ausbildung dar, der modernste Technologien nutzt.

## Projektarchitektur

### 1. Statische Website (Hugo)
- **Technologie**: Hugo statischer Site-Generator mit Bootstrap-basiertem "hugo-cards" Theme
- **Sprache**: Deutsch (`de-de`)
- **Zweck**: Dient als Haupt-Website und Bildungsressourcen-Hub
- **Hauptmerkmale**:
  - Bildungsblog-Beiträge über VR im Chemieunterricht
  - Projekt-Roadmap mit zukünftigen Entwicklungsplänen
  - Kontakt- und Über-uns-Seiten
  - Integrationslinks zu VR-Umgebungen und Wiki

### 2. Virtual Reality Komponente (Mozilla Hubs)
- **Plattform**: Mozilla Hubs - webbasierte VR-Plattform
- **Zweck**: Bietet immersive 3D-Lernumgebungen
- **Aktuelle Funktionen**:
  - Interaktives Periodensystem-Visualisierung
  - Virtuelle Chemieexperimente
  - Multi-User-Kollaborationsmöglichkeiten
- **URL**: `https://hubs.chemie-lernen.org/`

### 3. Wiki-Integration
- **URL**: `https://wiki.chemie-lernen.org/`
- **Zweck**: Kollaborative Dokumentation und Wissensdatenbank
- **Technologie**: XWiki-Instanz (in hubs-compose-Umgebung integriert)

## Technologie-Stack

### Frontend/Statische Website
- **Hugo**: Schneller statischer Site-Generator
- **Bootstrap**: CSS-Framework für responsives Design
- **Theme**: hugo-cards (minimalistisches Bootstrap-basiertes Theme)
- **Sprache**: Deutsche Inhalte

### VR-Plattform
- **Mozilla Hubs**: Webbasierte virtuelle Realität
- **Docker**: Containerisierte Bereitstellung
- **Services**:
  - Hubs & Spoke (Web-Client und Szeneneditor)
  - Reticulum (Phoenix-basiertes Backend)
  - Dialog (WebRTC-Media-Server)
  - PostgREST (RESTful API)

### Infrastruktur
- **Docker Compose**: Orchestrierung aller Services
- **HAProxy**: Load Balancer und SSL-Terminierung
- **Let's Encrypt**: SSL-Zertifikatsverwaltung
- **Mutagen**: Dateisynchronisation für Hubs

## Hauptmerkmale und Inhalte

### Aktuelle Bildungsinhalte
1. **Periodensystem-Visualisierung**: Interaktive 3D-Darstellung chemischer Elemente
2. **Virtuelle Chemieexperimente**: Sichere, interaktive Laborerfahrungen
3. **Bildungsforschung**: Veröffentlichte Forschung über interdisziplinäre VR-Zusammenarbeit in der Hochschulbildung
4. **Deutsche Sprachinhalte**: Alle Bildungsmaterialien auf Deutsch

### Roadmap-Funktionen (Geplant)
1. **Immersive VR-Szenarien**:
   - Subatomare Reisen (interaktiver Atombau)
   - Molekülgalerie (3D-Molekülstrukturen)
   - Gefahrfreie Labore (gefährliche Experimente in VR)

2. **Gamified Learning**:
   - Chemie-Escape-Räume
   - Element-Schnitzjagden
   - Geführte historische Erzählungen

3. **Bildungsressourcen**:
   - Stundenentwürfe für Lehrkräfte
   - Multi-User-Laborsitzungen
   - Bewertungswerkzeuge

4. **Technische Verbesserungen**:
   - WebGL-Unterstützung für Nicht-VR-Nutzer
   - Verbesserte Wiki-Integration
   - Interaktives 3D-Periodensystem-Portal

## Projekthöhepunkte

### Innovative Aspekte
- **Web-basiertes VR**: Keine teure Hardware erforderlich - funktioniert in Browsern
- **Multi-User-Kollaboration**: Schüler können gemeinsam in virtuellen Räumen lernen
- **Sicherheit**: Ermöglicht Experimentierung mit gefährlichen Chemikalien in virtueller Umgebung
- **Barrierefreiheit**: Hybrid-Ansatz unterstützt sowohl VR- als auch traditionelle Webnutzer

### Forschungsgrundlage
- Veröffentlichte Forschungsarbeit über interdisziplinäre VR-Zusammenarbeit in der Hochschulbildung
- Fokus auf Verbesserung der Behaltensrate im Vergleich zu traditionellen Methoden
- Zusammenarbeit zwischen akademischen Disziplinen

### Produktionsreife Infrastruktur
- Vollständig selbstgehostete Lösung mit Docker Compose
- Automatisierte SSL-Zertifikatsverwaltung
- Skalierbare Architektur mit HAProxy Load Balancing
- Integrierte Entwicklungs- und Bereitstellungspipelines

## Integrationspunkte

Die Chemie-Lern-Plattform ist nahtlos in eine größere selbstgehostete Cloud-Infrastruktur integriert, die umfasst:
- Mailserver (mailcow)
- Statische Sites für andere Projekte
- Wissensmanagementsystem (XWiki)
- HAProxy-basiertes Routing und SSL-Management

## Bildungsphilosophie

Das **Chemie Lernen** Projekt basiert auf der Überzeugung, dass moderne Technologie das Lernen komplexer wissenschaftlicher Konzepte verbessern kann. Durch die Kombination von:
- **Visuellem Lernen** (3D-Modelle und Animationen)
- **Experientiellem Lernen** (virtuelle Experimente)
- **Kollaborativem Lernen** (Multi-VR-Umgebungen)
- **Gamification** (spielerische Lernelemente)

schafft die Plattform ein umfassendes Lernerlebnis, das traditionelle Lehrmethoden ergänzt und erweitert.

---

*Zuletzt aktualisiert: 22. Dezember 2025*