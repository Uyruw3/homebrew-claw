class Claw < Formula
  desc "Bot de deberes y exámenes para WhatsApp"
  homepage "https://github.com/ClawProject/El-Repositorio-de-Claw"
  url "https://github.com/ClawProject/El-Repositorio-de-Claw/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "c6d0c05edd65f7f0bb5f77a00223b30341160cd6d62a93beca0497ea72d28c61"
  license :cannot_represent

  depends_on "ffmpeg"
  depends_on "node"
  depends_on "python@3.12"

  def install
    libexec.install Dir["*"]
    libexec.install ".env.example" if File.exist?(".env.example")

    node_bin = formula_opt_bin("node")
    python = formula_opt_bin("python@3.12")/"python3.12"

    (bin/"claw").write <<~SH
      #!/bin/bash
      set -euo pipefail
      export CLAW_HOME="${CLAW_HOME:-$HOME/.local/share/claw}"
      export PICKLEBRAIN_DATA_DIR="${PICKLEBRAIN_DATA_DIR:-$CLAW_HOME/data}"
      export PATH="#{node_bin}:$PATH"
      mkdir -p "$CLAW_HOME" "$PICKLEBRAIN_DATA_DIR"

      if ! cmp -s "#{libexec}/package-lock.json" "$CLAW_HOME/package-lock.json" 2>/dev/null || [ ! -d "$CLAW_HOME/node_modules" ]; then
        cp "#{libexec}/package.json" "#{libexec}/package-lock.json" "$CLAW_HOME/"
        echo "Instalando dependencias de Claw en $CLAW_HOME..."
        ( cd "$CLAW_HOME" && npm install --omit=dev --no-audit --no-fund )
      fi

      ln -sfn "$CLAW_HOME/node_modules" "#{libexec}/node_modules"
      cd "#{libexec}"
      exec node src/index.js "$@"
    SH
    chmod 0755, bin/"claw"

    (bin/"claw-ia").write <<~SH
      #!/bin/bash
      set -euo pipefail
      export CLAW_HOME="${CLAW_HOME:-$HOME/.local/share/claw}"
      export PICKLEBRAIN_DATA_DIR="${PICKLEBRAIN_DATA_DIR:-$CLAW_HOME/data}"
      export PYTHON_MODELS_DIR="${PYTHON_MODELS_DIR:-$CLAW_HOME/data/models}"

      if [ ! -x "$CLAW_HOME/.venv/bin/python" ]; then
        echo "Falta el entorno Python en $CLAW_HOME/.venv"
        echo "Créalo con:"
        echo "  #{python} -m venv $CLAW_HOME/.venv"
        echo "  $CLAW_HOME/.venv/bin/pip install -r #{libexec}/python/requirements.txt"
        exit 1
      fi

      exec "$CLAW_HOME/.venv/bin/python" "#{libexec}/python/server.py" "$@"
    SH
    chmod 0755, bin/"claw-ia"
  end

  def caveats
    <<~EOS
      La primera ejecución de `claw` instala las dependencias de Node en:
        ~/.local/share/claw

      Los datos, la base de datos y la sesión de WhatsApp se guardan en:
        ~/.local/share/claw/data

      Servicio Python opcional (voz e imágenes):
        export CLAW_HOME="$HOME/.local/share/claw"
        #{formula_opt_bin("python@3.12")}/python3.12 -m venv "$CLAW_HOME/.venv"
        "$CLAW_HOME/.venv/bin/pip" install -r "#{opt_libexec}/python/requirements.txt"
        "$CLAW_HOME/.venv/bin/pip" install -r "#{opt_libexec}/python/requirements-images.txt"
        claw-ia

      Sin GPU NVIDIA, instala antes torch para CPU:
        "$CLAW_HOME/.venv/bin/pip" install torch --index-url https://download.pytorch.org/whl/cpu

      Arranque automático (opcional):
        brew services start claw
    EOS
  end

  service do
    run [opt_bin/"claw"]
    keep_alive true
    working_dir var
    log_path var/"log/claw.log"
    error_log_path var/"log/claw.log"
  end

  test do
    assert_predicate bin/"claw", :executable?
    assert_predicate bin/"claw-ia", :executable?
    assert_match "picklebrain", (libexec/"package.json").read
  end
end
