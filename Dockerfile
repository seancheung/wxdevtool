FROM dorowu/ubuntu-desktop-lxde-vnc:bionic
LABEL maintainer="Sean Cheung <theoxuanx@gmail.com>"

ARG TIMEZONE=Asia/Shanghai
ARG WXURL=https://servicewechat.com/wxa-dev-logic/download_redirect?type=x64&from=mpwiki
ARG NODE_URL=https://nodejs.org/dist/v11.14.0/node-v11.14.0-linux-x64.tar.gz
ARG NWJS_URL=https://dl.nwjs.io/v0.38.0/nwjs-sdk-v0.38.0-linux-x64.tar.gz

ENV LANG C.UTF-8
ENV DISPLAY :1.0
ENV HOME /root
ENV USERPROFILE /root
ENV ROOT_DIR=/wxdevtool
ENV CONFIG_DIR "$USERPROFILE/.config/wxdevtool"
ENV WINEARCH win32
ENV WINEPREFIX "$HOME/.wine32"

RUN set -ex \
    && export DEBIAN_FRONTEND=noninteractive \
    && echo "Installing Dependencies..." \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        curl ca-certificates openssl tzdata libgconf-2-4 gnupg2 dbus gnupg-agent \
        locales jq python2.7 inotify-tools \
        p7zip-full build-essential software-properties-common apt-transport-https \
    && echo $TIMEZONE > /etc/timezone \
    && ln -fs "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime \
    && locale-gen zh_CN.UTF-8 \
    && dpkg-reconfigure -f noninteractive tzdata \
    && dpkg --add-architecture i386 \
    && curl -sL https://dl.winehq.org/wine-builds/winehq.key | apt-key add - \
    && apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main' \
    && apt-get update \
    && apt-get install -y winehq-stable \
    && mkdir -p "$ROOT_DIR" /tmp/node \
    && curl -sL $NODE_URL | tar -xzv --strip-components=1 -C /tmp/node \
    && cp -rf /tmp/node/bin /tmp/node/lib "$ROOT_DIR/" \
    && echo "Downloading nwjs from '$NWJS_URL'..." \
    && mkdir -p /tmp/nwjs \
    && curl -sL $NWJS_URL | tar -xzv --strip-components=1 -C /tmp/nwjs \
    && find /tmp/nwjs/locales -not -name 'zh-CN.pak' -not -name 'en-US.pak' -name '*.pak' | xargs rm -f \
    && cp -rf /tmp/nwjs/* "$ROOT_DIR/" \
    && echo "Fetching wxdevtool info from '$WXURL'..." \
    && export url=$(curl -sL -o /dev/null -w %{url_effective} $WXURL) \
    && export version=$(echo $url | grep -oP --color=never '(?<=wechat_devtools_)[\d\.]+(?=_x64\.exe)') \
    && echo "Downloading wxdevtool $version..." \
    && export filename="/tmp/wx.exe" \
    && curl -sL -o $filename $WXURL \
    && echo "Decompressing '$filename'..." \
    && export tmp_dir="/tmp/wx" \
    && mkdir -p $tmp_dir \
    && export tmp_pkg='$APPDATA/Tencent/微信开发者工具/package.nw' \
    && 7z x -y -o"$tmp_dir" $filename $tmp_pkg \
    && echo "Copying files..." \
    && cp -rf "$tmp_dir/$tmp_pkg" "$ROOT_DIR/" \
    && echo "Configuring package..." \
    && export pkgname="$ROOT_DIR/package.nw" \
    && sed -ri -e 's#AppData/Local/\$\{global.userDirName\}/User Data#.config/\$\{global.userDirName\}#g' "$pkgname/js/common/cli/index.js" \
    && sed -ri -e 's#`./\$\{global.appname\}.exe`#i.join(__dirname, "../../../../bin/wxstart")#g' "$pkgname/js/common/cli/index.js" \
    && sed -ri -e 's#微信开发者工具#wxdevtool#g' "$pkgname/package.json" \
    && cd "$pkgname/node_modules/node-sync-ipc" \
    && "$ROOT_DIR/bin/node" "$ROOT_DIR/bin/npm" i --unsafe-perm --scripts-prepend-node-path \
    && rm -rf "$pkgname/node_modules/node-sync-ipc-nwjs" \
    && cp -rf "$pkgname/node_modules/node-sync-ipc" "$pkgname/node_modules/node-sync-ipc-nwjs" \
    && mkdir -p $HOME/.wine32 \
    && for f in $pkgname/js/vendor/*.exe; do \
        mv $f "$ROOT_DIR/"; \
        export filename=`basename $f`; \
        echo "LC_ALL=zh_CN.UTF-8 wine $ROOT_DIR/$filename \$@" > $f; \
        chmod +x $f; \
        export filehash=$(md5sum $filepath | awk '{ print $1 }'); \
        jq ".\"$filename\" |= \"$filehash\"" "$pkgname/js/vendor/config.json"; \
        done \
    && echo $version > "$ROOT_DIR/.version" \
    && echo "Clean Up..." \
    && apt-get remove -y --purge p7zip build-essential software-properties-common apt-transport-https \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

COPY wxdevtool /wxdevtool/bin/wxdevtool
COPY wxstart /wxdevtool/bin/wxstart
COPY portwatcher /wxdevtool/bin/portwatcher
COPY wxdevtool.conf /etc/supervisor/conf.d/

ENV PATH "$ROOT_DIR/bin":$PATH