# Script One-Liner (Copy & Paste)

Scripts direkt aus GitHub ausführen, ohne Download und `chmod`.

## Template
```bash
curl -fsSL "https://raw.githubusercontent.com/<USER>/<REPO>/<REF>/<PATH>.sh" | sudo bash
````

## Beispiele

### Docker Install

```bash
curl -fsSL "https://raw.githubusercontent.com/BavariaByte/scripts/refs/heads/main/docker-setup.sh" | sudo bash
```

### mount-share (NFS)

```bash
curl -fsSL "https://raw.githubusercontent.com/BavariaByte/scripts/refs/heads/main/mount-share.sh" | sudo bash -s -- -i 172.16.10.5 -s projektdaten
```


### Script mit Parametern

```bash
curl -fsSL "https://raw.githubusercontent.com/<USER>/<REPO>/<REF>/scripts/<script>.sh" | sudo bash -s -- --arg1 value1
```

### Script mit Environment-Variablen

```bash
curl -fsSL "https://raw.githubusercontent.com/<USER>/<REPO>/<REF>/scripts/<script>.sh" | sudo VAR1=value1 VAR2=value2 bash
```
