FROM ghcr.io/containerpak/mesa:main

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl libfuse2t64 && \
    curl -fsSL https://github.com/dbgate/dbgate/releases/download/v7.2.0/dbgate-7.2.0-linux_x86_64.AppImage \
      -o /tmp/dbgate.AppImage && \
    echo '261b645daa4fc37e37da4c85f76c54f4d7e685ce5216635a335c76ee9a6c0042  /tmp/dbgate.AppImage' | sha256sum -c - && \
    chmod +x /tmp/dbgate.AppImage && \
    cd /tmp && ./dbgate.AppImage --appimage-extract && \
    mv /tmp/squashfs-root /opt/dbgate && \
    ln -s /opt/dbgate/AppRun /usr/bin/dbgate && \
    install -Dm644 /opt/dbgate/dbgate.desktop /usr/share/applications/org.dbgate.DbGate.desktop && \
    desktop-file-edit --set-key=Exec --set-value='dbgate %U' \
      /usr/share/applications/org.dbgate.DbGate.desktop && \
    desktop-file-edit --set-key=Icon --set-value=org.dbgate.DbGate \
      /usr/share/applications/org.dbgate.DbGate.desktop && \
    find /opt/dbgate/usr/share/icons/hicolor -type f -name 'dbgate.png' -exec sh -c 'size=$(basename "$(dirname "$(dirname "$1")")"); install -Dm644 "$1" "/usr/share/icons/hicolor/$size/apps/org.dbgate.DbGate.png"' _ {} \; && \
    cpak-clean-junk
