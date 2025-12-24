# Migration zu eigenständigem Traefik

## Überblick

Das Traefik-Reverse-Proxy wurde aus dem hugo-sites Projekt in ein eigenständiges Repository extrahiert: [docker-traefik](https://github.com/tobias-weiss-ai-xr/docker-traefik)

## Vorteile

- **Modularität** - Traefik kann nun unabhängig von hugo-sites verwaltet werden
- **Wiederverwendbarkeit** - Andere Projekte können dasselbe Traefik-Instanz nutzen
- **Isolierung** - Getrennte Lebenszyklen für Proxy und Applikationen
- **Einfachere Wartung** - Klare Trennung der Zuständigkeiten

## Voraussetzungen

1. docker-traefik Repository geklont und eingerichtet
2. Traefik-Netzwerk erstellt: `docker network create traefik-web`

## Migrationsschritte

### 1. Traefik einrichten

```bash
cd /opt/git/docker-traefik
cp .env.example .env
# Editiere .env und setze ACME_EMAIL
docker-compose up -d
```

### 2. hugo-sites aktualisieren

Die docker-compose.yml wurde bereits aktualisiert, um das externe `traefik-web` Netzwerk zu verwenden.

### 3. Container neu erstellen

```bash
cd /opt/git/hugo-sites
docker-compose down
docker-compose up -d
```

## Verifikation

Prüfen, ob alle Services korrekt mit Traefik kommunizieren:

```bash
# Prüfe, ob Container im traefik-web Netzwerk sind
docker network inspect traefik-web

# Prüfe Traefik Dashboard
curl https://traefik.yourdomain.com/dashboard/

# Prüfe einzelne Services
curl https://chemie-lernen.org/
curl https://graphwiz.ai/
curl https://tobias-weiss.org/
```

## Netzwerk-Topologie

**Vorher:**
```
hugo-sites (lokal)
├── traefik
├── hugo-chemie-lernen-org
├── hugo-graphwiz-ai
└── hugo-tobias-weiss-org
Alle im 'web' Netzwerk
```

**Nachher:**
```
docker-traefik
└── traefik (im 'traefik-web' Netzwerk)

hugo-sites
├── hugo-chemie-lernen-org (im 'traefik-web' Netzwerk)
├── hugo-graphwiz-ai (im 'traefik-web' Netzwerk)
└── hugo-tobias-weiss-org (im 'traefik-web' Netzwerk)
```

## Fehlersuche

### Container starten nicht

```bash
# Prüfe ob traefik-web Netzwerk existiert
docker network ls | grep traefik-web

# Erstelle es falls nötig
docker network create traefik-web
```

### SSL Zertifikate werden nicht erneuert

Das liegt jetzt in der Verantwortung von docker-traefik. Prüfe:

```bash
cd /opt/git/docker-traefik
docker-compose logs -f traefik
```

## Rollback

Falls Probleme auftreten, kann einfach die alte Konfiguration wiederhergestellt werden:

```bash
git checkout HEAD~1 docker-compose.yml traefik.yml
docker-compose down
docker-compose up -d
```

## Weiterführende Informationen

- [docker-traefik Repository](https://github.com/tobias-weiss-ai-xr/docker-traefik)
- [Traefik Dokumentation](https://doc.traefik.io/traefik/)
- [Let's Encrypt Best Practices](https://letsencrypt.org/docs/client-options/)
