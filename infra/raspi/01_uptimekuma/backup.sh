#!/bin/bash

DOCKER_CONTAINER="uptime-kuma"
# Setzen Sie den Namen Ihres Docker-Containers

# Setzen Sie das Verzeichnis, in dem die Backups gespeichert werden sollen
BACKUP_DIR="/mnt/unraid-backup-share/06_config_backup/01_uptimekuma-rasp"

# Setzen Sie den Namen des Docker-Volumes
DOCKER_VOLUME="uptime-kuma"

# Erstellen Sie einen eindeutigen Namen für das Backup mit Datum und Uhrzeit
BACKUP_NAME="backup-$(date +\%Y\%m\%d-\%H\%M\%S)"

# Slack-Webhook-URL
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/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"

# Container zuerst stoppen
docker stop $DOCKER_CONTAINER

# Erstellen Sie das Docker-Container-Image, um das Volume zu sichern
if docker run --rm -v $DOCKER_VOLUME:/data -v $BACKUP_DIR:/backup ubuntu tar czf /backup/$BACKUP_NAME.tar.gz -C /data .; then
  # Erfolgsmeldung an Slack senden
  MESSAGE="Das Backup von $DOCKER_VOLUME wurde erfolgreich erstellt ($BACKUP_NAME)."
  COLOR="#36a64f"  # Grün
else
  # Fehlermeldung an Slack senden
  MESSAGE="Fehler beim Erstellen des Backups von $DOCKER_VOLUME."
  COLOR="#ff0000"  # Rot
fi

# Container wieder starten
docker start $DOCKER_CONTAINER

# Slack-Nachricht formatieren und senden
curl -X POST -H "Content-type: application/json" --data "{
  \"attachments\": [
    {
      \"fallback\": \"$MESSAGE\",
      \"color\": \"$COLOR\",
      \"text\": \"$MESSAGE\"
    }
  ]
}" $SLACK_WEBHOOK_URL
