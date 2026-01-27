# BavariaByte Scripts Repository

Sammel-Repo für verschiedene Admin, Setup und Automation Scripts.  
Ausführung als One-Liner direkt aus GitHub möglich (ohne Download und `chmod`).

## Inhaltsverzeichnis

1. [Prinzip](#prinzip)
2. [Sicherer One Liner Standard](#sicherer-one-liner-standard)
3. [One Liner Templates](#one-liner-templates)
   1. [Standard](#standard)
   2. [Mit Parametern](#mit-parametern)
   3. [Mit Environment Variablen](#mit-environment-variablen)
4. [Scripts](#scripts)
   1. [Docker](#docker)
   2. [Storage und Shares](#storage-und-shares)
   3. [Kali Setup](#kali-setup)
   4. [Proxmox](#proxmox)
5. [Neues Script hinzufügen](#neues-script-hinzufügen)
6. [Konventionen](#konventionen)

---

## Prinzip

• Scripts werden bevorzugt als One Liner ausgeführt  
• Parameter werden über `bash -s -- ...` weitergereicht  
• Optional können Variablen per Environment gesetzt werden

---

## Sicherer One Liner Standard

Wenn möglich, nutze `-fsSL` und `sudo bash` nur, wenn root wirklich benötigt wird.

```bash
curl -fsSL "<RAW_URL>" | sudo bash
````

---

## One Liner Templates

### Standard

```bash
curl -fsSL "https://raw.githubusercontent.com/<USER>/<REPO>/<REF>/<PATH>.sh" | sudo bash
```

### Mit Parametern

```bash
curl -fsSL "https://raw.githubusercontent.com/<USER>/<REPO>/<REF>/<PATH>.sh" | sudo bash -s -- --arg1 value1 --arg2 value2
```

### Mit Environment Variablen

```bash
curl -fsSL "https://raw.githubusercontent.com/<USER>/<REPO>/<REF>/<PATH>.sh" | sudo VAR1=value1 VAR2=value2 bash
```

---

## Scripts

Hier sind die aktuell verfügbaren Scripts nach Kategorien sortiert.

### Docker

#### docker setup

```bash
curl -fsSL "https://raw.githubusercontent.com/BavariaByte/scripts/refs/heads/main/docker-setup.sh" | sudo bash
```

---

### Storage und Shares

#### mount share (NFS)

```bash
curl -fsSL "https://raw.githubusercontent.com/BavariaByte/scripts/refs/heads/main/mount-share.sh" | sudo bash -s -- -i 172.16.10.5 -s projektdaten
```

---

### Kali Setup
```bash
curl -fsSL "https://raw.githubusercontent.com/BavariaByte/scripts/refs/heads/main/kali-setup.sh" | sudo bash
```

---

### Proxmox

#### create cloud init template

Cloud Init Template auf Proxmox Node erstellen:

```bash
curl -fsSL "https://raw.githubusercontent.com/BavariaByte/scripts/refs/heads/main/create-cloud-init-template.sh" | bash -s -- -s local-lvm -d ubuntu24
```

##### Parameter

| Parameter | Default     | Beschreibung                                      |
| --------- | ----------- | ------------------------------------------------- |
| `-i`      | `9000`      | Template VMID                                     |
| `-s`      | `local-lvm` | Storage Pool                                      |
| `-d`      | `ubuntu24`  | Distribution (`ubuntu24`, `ubuntu22`, `debian12`) |
| `-b`      | `vmbr0`     | Network Bridge                                    |

##### Beispiele

Ubuntu 24.04 auf local zfs:

```bash
curl -fsSL "https://raw.githubusercontent.com/BavariaByte/scripts/refs/heads/main/create-cloud-init-template.sh" | bash -s -- -s local-zfs -d ubuntu24
```

Debian 12 mit custom VMID:

```bash
curl -fsSL "https://raw.githubusercontent.com/BavariaByte/scripts/refs/heads/main/create-cloud-init-template.sh" | bash -s -- -i 9001 -s local-lvm -d debian12
```

---

## Neues Script hinzufügen

1. Script hinzufügen oder verlinken
   • im Repo ablegen oder auf anderes Repo zeigen, wenn es thematisch passt
2. README Eintrag ergänzen
   • Kategorie wählen oder neue Kategorie erstellen
   • Kurze Beschreibung
   • One Liner Beispiel
   • Parameter Tabelle, falls relevant
3. Namensschema empfehlen
   • `kebab-case.sh`
   • sprechender Name statt Abkürzungen

---

## Konventionen

### URLs

Empfohlen

```text
https://raw.githubusercontent.com/BavariaByte/scripts/refs/heads/main/<script>.sh
```

### Parameter Handling

Empfohlen in Scripts
• `getopts` für Flags (`-i`, `-s`, `-d`)
• `--help` oder `-h` für Usage Output
• sinnvolle Defaults, die in README dokumentiert sind

### Minimal Logging

• klare Status Zeilen
• bei Fehlern Exit Codes setzen (`set -euo pipefail` falls passend)
