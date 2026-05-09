# Fusion

## 功能特性

- RSS/Atom 订阅管理
- 文章已读/未读/星标
- 全文搜索
- OPML 导入导出
- 键盘快捷键
- 多语言支持（默认中文）
- 单二进制部署（Go + React 内嵌）

## 快速部署

```bash
docker run -d \
  -p 8080:8080 \
  -v $(pwd)/data:/data \
  --name fusion-zh \
  wsng911/fusion-zh:latest
```

访问 `http://localhost:8080`
