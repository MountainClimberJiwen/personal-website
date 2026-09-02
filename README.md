# Personal Website

个人 IP 网站，部署在 `https://1boss.tech/me/`。

## 概述

- **入口**：https://1boss.tech/me/
- **服务器**：centos（IP `124.221.22.70`，nginx 1.20.1）
- **远端部署目录**：`/var/www/personal/`（由 nginx `location ^~ /me/` 直接服务静态文件）
- **本地源**：`~/personal-website/`

## 目录结构

```
personal-website/
├── index.html              # 主页 HTML
├── style.css               # 样式
├── src/
│   └── videos/             # 原始视频（git ignored，大文件）
│       ├── scene1-source.mp4
│       └── scene2-source.mp4
├── public/                 # rsync 到远端的内容
│   ├── index.html
│   ├── style.css
│   └── videos/
│       ├── bg-vp9.webm          # Scene 1, VP9 + alpha
│       ├── bg-hevc.mp4          # Scene 1, HEVC 10-bit
│       ├── bg-h264.mp4          # Scene 1, H.264 + 米色合成背景
│       ├── bg2-vp9.webm         # Scene 2, VP9 + alpha
│       ├── bg2-hevc.mp4         # Scene 2, HEVC 10-bit
│       └── bg2-h264.mp4         # Scene 2, H.264 + 米色合成背景
└── scripts/
    ├── transcode.sh        # ffmpeg 三套转码
    └── deploy.sh           # rsync 到 centos
```

## 视频转码

两个场景各有三套格式覆盖主流浏览器：

| 格式 | alpha | 用途 |
|---|---|---|
| VP9 + alpha (webm) | ✅ | Chrome / Firefox / Safari 17+ |
| HEVC 10-bit (mp4) | ❌ | Safari 14-16 fallback（ffmpeg/libx265 当前不支持 alpha plane 输出） |
| H.264 + 米色合成背景 (mp4) | ❌ | 其他浏览器兜底 |

**重新转码**：

```bash
./scripts/transcode.sh
```

脚本会自动探测 ffmpeg（PATH → `/Applications/MiniMax Design.app/Contents/Resources/ffmpeg/ffmpeg` → brew 路径），如找不到会报错。

## 部署

**一键部署到 centos**：

```bash
./scripts/deploy.sh
```

默认用 `~/.ssh/config` 里的 `centos` 别名，把 `public/` rsync 到 `/var/www/personal/`。可覆盖：

```bash
CENTOS_HOST=other-host ./scripts/deploy.sh
REMOTE_DIR=/other/path ./scripts/deploy.sh
```

nginx 不需要 reload（纯静态文件）。

## 浏览器 fallback 链

```html
<video>
  <source src="videos/bg2-vp9.webm" type="video/webm">
  <source src="videos/bg2-hevc.mp4" type='video/mp4; codecs="hvc1"'>
  <source src="videos/bg2-h264.mp4" type="video/mp4">
</video>
```

**两个视频都是 fixed 全屏背景**，通过 `data-scene` 属性 + JS IntersectionObserver 切换显示：

- `data-scene="1"` → 视频 1 显示（Hero / About）
- `data-scene="2"` → 视频 2 显示（我的世界 / 作品 / 联系方式）

`rootMargin: -15% 0px -70% 0px` 让触发只在视口顶部窄带发生，避免多个 section 同时可见时频繁跳切。

## 已知限制

- ffmpeg 6.1.1-tessus + libx265 这条链**不输出 alpha plane**（HEVC 即使加 `-x265-params alpha=1` 也无效）。需要 HEVC 真 alpha 的话，得用 x265 CLI 直接调。
- Safari 14-16 用户看不到透明背景（HEVC fallback 是合成米色背景），不影响功能。

## 本地访问

DNS 未解析时，本机浏览器要访问需要临时改 `/etc/hosts`：

```bash
sudo sh -c 'echo "124.221.22.70 1boss.tech www.1boss.tech" >> /etc/hosts'
# 浏览器打开 https://1boss.tech/me/

# 看完后清理：
sudo sed -i '' '/1boss.tech$/d; /www.1boss.tech$/d' /etc/hosts
```
