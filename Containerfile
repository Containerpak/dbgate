FROM ubuntu:26.04 AS source

ADD --checksum=sha256:70e945c64443e17c06d3596cd61a896a77d794d31a738e2a7381a4b257f235cd https://github.com/dbgate/dbgate/releases/download/v7.2.5/dbgate-7.2.5-linux_x86_64.AppImage /tmp/source

RUN chmod 0755 /tmp/source && \
    cd /tmp && \
    ./source --appimage-extract >/dev/null && \
    mv /tmp/squashfs-root /out

FROM ghcr.io/containerpak/gtk3:main

COPY --from=source /out /opt/dbgate
COPY --from=source /out/dbgate.desktop /usr/share/applications/org.dbgate.DbGate.desktop

RUN apt-get update && \
    apt-get install -y --no-install-recommends libasound2t64 libnss3 && \
    sed -i -e 's|^Exec=.*|Exec=dbgate %U|' -e 's|^Icon=.*|Icon=org.dbgate.DbGate|' \
      /usr/share/applications/org.dbgate.DbGate.desktop && \
    find /opt/dbgate/usr/share/icons/hicolor -type f -name 'dbgate.png' -exec sh -c 'size=$(basename "$(dirname "$(dirname "$1")")"); install -Dm644 "$1" "/usr/share/icons/hicolor/$size/apps/org.dbgate.DbGate.png"' _ {} \; && \
    cpak-clean-junk

COPY dbgate /usr/bin/dbgate
