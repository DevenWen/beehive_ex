# BeeAdmin

[![Phoenix](https://img.shields.io/badge/Phoenix-1.7-FF3653.svg?style=flat-square)](https://phoenixframework.org)
[![Elixir](https://img.shields.io/badge/Elixir-1.14+-4B275F.svg?style=flat-square)](https://elixir-lang.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](../../LICENSE)

BeeAdmin 是 BeehiveEx 项目中的管理后台 API 服务应用，基于 **Phoenix 1.7** 框架构建。它是一个纯 RESTful API 服务，为前端应用提供管理功能接口。

## ✨ 核心功能

- 🎯 提供管理后台所需的 RESTful API 端点
- ❤️‍🩹 支持健康检查等基础服务功能
- 📊 为前端应用提供数据接口
- 🔌 可扩展的模块化架构

## 🚀 快速开始

### 安装依赖

```bash
# 从根目录安装所有依赖
mix deps.get

# 或进入应用目录
cd apps/bee_admin
mix deps.get
```

### 启动服务器

```bash
# 生产模式启动
mix phx.server

# 开发模式（带交互式 shell）
iex -S mix phx.server
```

服务器将在 `http://localhost:4000` 启动。

## 📡 API 文档

### 健康检查

#### GET /api/health

检查服务健康状态。

**请求示例:**

```bash
curl http://localhost:4000/api/health
```

**成功响应 (200 OK):**

```json
{
  "status": "healthy",
  "timestamp": "2025-10-11T15:30:00Z"
}
```

**响应字段说明:**

| 字段 | 类型 | 描述 |
|------|------|------|
| `status` | string | 服务状态，当前为 "healthy" |
| `timestamp` | ISO8601 string | UTC 时间戳 |

## 🏗️ 项目结构

```
bee_admin/
├── lib/
│   ├── bee_admin.ex              # 应用主模块
│   ├── bee_admin/
│   │   └── application.ex        # OTP 应用启动配置
│   └── bee_admin_web/
│       ├── bee_admin_web.ex      # Web 根模块
│       ├── endpoint.ex           # Phoenix Endpoint
│       ├── router.ex             # 路由定义
│       ├── telemetry.ex          # 遥测配置
│       ├── controllers/          # 控制器
│       │   ├── api_controller.ex
│       │   └── error_json.ex
│       └── gettext.ex            # 国际化支持
├── test/
│   ├── bee_admin_web/
│   │   └── controllers/
│   │       ├── api_controller_test.exs
│   │       └── error_json_test.exs
│   ├── support/
│   │   └── conn_case.ex
│   └── test_helper.exs
├── priv/
└── mix.exs
```

## ⚙️ 配置说明

### 环境配置

应用支持三种环境配置：

- **开发环境** (`config/dev.exs`): 热重载启用
- **测试环境** (`config/test.exs`): 独立测试数据库
- **生产环境** (`config/prod.exs`): 高性能配置

### 关键配置项

```elixir
# config/config.exs
config :bee_admin, BeeAdminWeb.Endpoint,
  url: [host: "localhost"],           # 主机地址
  adapter: Bandit.PhoenixAdapter,     # Web 服务器适配器
  render_errors: [
    formats: [json: BeeAdminWeb.ErrorJSON],  # JSON 错误格式
    layout: false
  ],
  pubsub_server: BeeAdmin.PubSub,     # PubSub 服务器
  live_view: [signing_salt: "..."]    # LiveView 盐值
```

### 端口配置

默认端口为 **4000**。可通过环境变量修改：

```bash
# 设置自定义端口
PORT=8080 mix phx.server
```

## 🧪 运行测试

```bash
# 运行所有测试
mix test

# 运行特定文件的测试
mix test test/bee_admin_web/controllers/api_controller_test.exs

# 运行测试并生成覆盖率报告
mix test --cover

# 运行测试并查看详细输出
mix test --trace
```

### 测试文件说明

| 测试文件 | 测试范围 |
|----------|----------|
| `api_controller_test.exs` | API 控制器功能测试 |
| `error_json_test.exs` | 错误处理测试 |

## 📦 依赖说明

主要依赖项：

- **Phoenix** (~> 1.7.17) - Web 框架
- **Bandit** (~> 1.5) - HTTP 服务器
- **Jason** (~> 1.2) - JSON 解析
- **Telemetry** (~> 1.2) - 指标收集
- **Gettext** (~> 0.20) - 国际化
- **DNS Cluster** (~> 0.1.1) - DNS 集群支持

## 🔧 开发指南

### 添加新的 API 端点

1. 在 `lib/bee_admin_web/router.ex` 中添加路由：

```elixir
scope "/api", BeeAdminWeb do
  pipe_through :api

  get "/health", ApiController, :health_check
  get "/users", UserController, :index  # 新增
end
```

2. 创建控制器：

```elixir
defmodule BeeAdminWeb.UserController do
  use BeeAdminWeb, :controller

  def index(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{data: []})
  end
end
```

### 代码格式化

```bash
# 格式化代码
mix format

# 检查格式
mix format --check-formatted
```

### 代码检查

```bash
# 运行 Credo 代码检查
mix credo

# 运行 Dialyzer 类型检查
mix dialyzer
```

## 🐛 故障排除

### 常见问题

**Q: 端口 4000 已被占用**

```bash
# 查看占用进程
lsof -i :4000

# 使用其他端口
PORT=4001 mix phx.server
```

**Q: 依赖安装失败**

```bash
# 清理并重新安装
mix deps.clean --all
mix deps.get
```

**Q: 热重载不生效**

确保在开发环境中运行：
```bash
MIX_ENV=dev iex -S mix phx.server
```

## 📚 学习资源

- **Phoenix 官方文档**: https://hexdocs.pm/phoenix/overview.html
- **Phoenix 指南**: https://hexdocs.pm/phoenix/Phoenix.html
- **Elixir 论坛**: https://elixirforum.com/c/phoenix-forum
- **Discord 社区**: https://discord.gg/x7r8pF8J

## 📄 许可证

本应用采用 MIT 许可证 - 详见 [../../LICENSE](../../LICENSE)

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！详见 [../../CONTRIBUTING.md](../../CONTRIBUTING.md)

---

<div align="center">

**使用 Phoenix 1.7 构建 | BeehiveEx 系列应用**

</div>