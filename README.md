# wxdevtool

WeChat WebDevTool in Docker(With LXDE)

## Run

```bash
docker run -d --name wxdevtool -p 8080:80 -v /path/to/projects:/projects seancheung/wxdevtool:latest
```

## Commands

```bash
docker exec -t wxdevtool wxdevtool help

# forwar built-in commands
docker exec -t wxdevtool wxdevtool exec [..args]
# login
docker exec -t wxdevtool wxdevtool exec --login
```

See [Reference](https://developers.weixin.qq.com/miniprogram/dev/devtools/cli.html)

## HTPP Service

The IDE HTTP service is exposed at port 9000.

```bash
# mapping container port 9000 to local port 8083
docker run -d --name wxdevtool -p 8083:9000 -p 8080:80 -v /path/to/projects:/projects seancheung/wxdevtool:latest

# open project
curl localhost:8083/open?projectpath=path_to_project
```

See [Reference](https://developers.weixin.qq.com/miniprogram/dev/devtools/http.html)

## Tags

|  Tag   |   Version    |
| :----: | :----------: |
| latest |    1.02.1909111    |
| rc |    1.02.1909111    |
|  1.02  | 1.02.1909111 |
|  1.02-rc  | 1.02.1909111 |
|  1909111  | 1.02.1909111 |
|  1909111-rc  | 1.02.1909111 |
|  1902010  | 1.02.1902010 |
|  1902010-rc  | 1.02.1902010 |

### RC Tags

rc tags are automated images which are not configured yet. To config manullay:

1. Pull an RC image

```bash
docker pull seancheung/wxdevtool:1.02-rc
```

2. Run

```bash
docker run -d --name wxdevtool-rc -p 8080:80 seancheung/wxdevtool:1.02-rc
```

3. Config Wine

Open Browser at _http://localhost:8080 wait until noVNC is up. Then run

```bash
docker exec -t wxdevtool-rc winecfg
```

Follow wine's instructions in UI. The attached shell will automatically quit when done.

> When being prompted by Wine, cancel all installation suggestions.

4. Config wxdevtool to enable IDE service port

```bash
docker exec -t wxdevtool-rc wxdevtool start
```

Open Browser at _http://localhost:8080_, Open Wechat WebDevTool's settings and enable IDE service port. See [Referece](https://developers.weixin.qq.com/miniprogram/dev/devtools/cli.html)

5. Restart container

```bash
docker restart wxdevtool-rc
```

### Custom build Args

**WXURL**

https://servicewechat.com/wxa-dev-logic/download_redirect?type=x64&from=mpwiki

> Always fetch the latest

**NODE_URL**

https://nodejs.org/dist/v${version}/node-v${version}-linux-x64.tar.gz

Mirror:

https://npm.taobao.org/mirrors/node/v${version}/node-v${version}-linux-x64.tar.gz

**NWJS_URL**

https://dl.nwjs.io/v${version}/nwjs-sdk-v${version}-linux-x64.tar.gz

Mirror:

https://npm.taobao.org/mirrors/nwjs/v${version}/nwjs-sdk-v${version}-linux-x64.tar.gz
