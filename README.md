# homebrew-claw

Tap de [Homebrew](https://brew.sh) para **Claw**, el bot de deberes y exámenes
para WhatsApp.

## Instalación

```bash
brew tap Uyruw3/claw
brew install claw
```

La primera ejecución de `claw` descarga las dependencias de Node en
`~/.local/share/claw` y guarda los datos en `~/.local/share/claw/data`.

```bash
claw
```

La primera vez muestra un QR de WhatsApp. Escanéalo en
**Ajustes → Dispositivos vinculados → Vincular un dispositivo**.

## Servicio Python (voz e imágenes)

Es opcional: sin él, Claw usa ffmpeg + Whisper en Node y `sd-cli` para imágenes.

```bash
export CLAW_HOME="$HOME/.local/share/claw"
PYTHON="$(brew --prefix python@3.12)/bin/python3.12"

"$PYTHON" -m venv "$CLAW_HOME/.venv"
"$CLAW_HOME/.venv/bin/pip" install -r "$(brew --prefix claw)/libexec/python/requirements.txt"

# Solo si quieres generar imágenes con diffusers:
"$CLAW_HOME/.venv/bin/pip" install -r "$(brew --prefix claw)/libexec/python/requirements-images.txt"

claw-ia
```

Si no tienes GPU NVIDIA, instala torch para CPU antes de las imágenes:

```bash
"$CLAW_HOME/.venv/bin/pip" install torch --index-url https://download.pytorch.org/whl/cpu
```

## Datos y configuración

- Código instalado por Homebrew: `$(brew --prefix claw)/libexec`
- Datos y sesión: `~/.local/share/claw/data`
- Configuración: crea `~/.local/share/claw/data/.env` a partir de
  [`libexec/.env.example`](https://github.com/ClawProject/El-Repositorio-de-Claw/blob/main/.env.example)
  o copia el ejemplo:

```bash
cp "$(brew --prefix claw)/libexec/.env.example" "$HOME/.local/share/claw/data/.env"
```

Puedes cambiar la carpeta con `CLAW_HOME` y `PICKLEBRAIN_DATA_DIR`.

## Arranque automático

```bash
brew services start claw
```

Los registros quedan en `$(brew --prefix)/var/log/claw.log`.

## Actualizar

```bash
brew update
brew upgrade claw
```

## Documentación

- [Guía de instalación completa](https://github.com/ClawProject/El-Repositorio-de-Claw/blob/main/INSTALL.md)
- [README del proyecto](https://github.com/ClawProject/El-Repositorio-de-Claw)

## Nota

La fórmula instala una etiqueta de la rama de desarrollo mientras el servicio
Python está en revisión. Cuando se fusione, se cambiará a la rama `main`.
