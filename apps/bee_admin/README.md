# BeeAdmin

BeeAdmin 是 BeehiveEx 项目中的管理后台 API 服务应用，基于 Phoenix 框架构建。它是一个纯 RESTful API 服务，为前端应用提供管理功能接口。

## 功能

- 提供管理后台所需的 RESTful API 端点
- 支持健康检查等基础服务功能

## API 路由

- `GET /api/health` - 服务健康检查端点

## 开发

要启动您的应用程序:

1. 安装依赖: `mix deps.get`
2. 启动服务器: `mix phx.server` 或 `iex -S mix phx.server`

现在访问 http://localhost:4000/api/health 您应该会看到类似以下的响应：
```json
{
  "status": "healthy",
  "timestamp": "2025-10-11T15:30:00Z"
}
```

## 测试

运行测试: `mix test`

## 项目结构

这是一个 Elixir umbrella 项目的一部分，依赖于父级项目的配置和依赖管理。

## 学习资源

- 官方文档: https://hexdocs.pm/phoenix/overview.html
- 指南: https://hexdocs.pm/phoenix guides.html
- 论坛: https://elixirforum.com/c/phoenix-forum
- 社区: https://discord.gg/x7r8pF8J