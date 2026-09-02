# Source Videos (git ignored)

源视频放在这里供 `./scripts/transcode.sh` 读取：

- `scene1-source.mp4` — 背景视频原文件（透明背景的角色动画）
- `scene2-source.mp4` — 滚动触发的第二场景原文件

文件命名规范：`scene{N}-source.mp4`，转码后会输出 `public/videos/bg{N}-{vp9.webm,hevc.mp4,h264.mp4}` 三套。

获取方式：
- 从本地其他位置 cp 进来（参考之前 ~/Downloads 下的原始素材）
- 或修改 `scripts/transcode.sh` 中的 `SRC` 路径指向其他目录

⚠️ 这些文件**不会被 git 追踪**（在 .gitignore 里），仓库只保存转码后的产物（`public/videos/`）。
