# 快速开始指南

欢迎使用 BeehiveEx！本指南将帮助您在 **5 分钟** 内完成环境搭建并启动您的第一个服务。

## 📋 目录

- [🎯 目标](#目标)
- [📦 环境要求](#环境要求)
- [⚡ 快速安装](#快速安装)
- [🚀 启动服务](#启动服务)
- [🧪 验证安装](#验证安装)
- [🎓 下一步](#下一步)
- [🐛 常见问题](#常见问题)

## 🎯 目标

完成本指南后，您将能够：

- ✅ 运行 bee_admin API 服务
- ✅ 调用健康检查端点
- ✅ 了解项目的基本结构
- ✅ 准备进行开发

**预计用时**: 5 分钟

## 📦 环境要求

在开始之前，请确保您的系统已安装：

| 工具 | 版本要求 | 检查命令 |
|------|----------|----------|
| **Elixir** | 1.14+ (推荐 1.18) | `elixir --version` |
| **Erlang** | 24+ | `erl --version` |
| **Git** | 最新版 | `git --version` |
| **Mix** | Elixir 自带 | `mix --version` |

### 安装 Elixir

**macOS:**

```bash
# 使用 Homebrew
brew install elixir
```

**Ubuntu/Debian:**

```bash
# 添加 Erlang Solutions 仓库
wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
sudo dpkg -i erlang-solutions_2.0_all.deb
sudo apt-get update

# 安装 Elixir
sudo apt-get install elixir
```

**Windows:**

```bash
# 使用 Chocolatey
choco install elixir
```

### 验证安装

```bash
# 检查版本
elixir --version
# 应该显示: Elixir 1.14+ 或 1.18+

# 检查 Mix
mix --version
# 应该显示: Mix 1.14+ 或 1.18+
```

## ⚡ 快速安装

### 步骤 1: 克隆仓库

```bash
# 克隆项目
git clone https://github.com/your-org/beehive_ex.git
cd beehive_ex

# 或者从 fork 克隆
git clone https://github.com/YOUR_USERNAME/beehive_ex.git
cd beehive_ex
```

### 步骤 2: 安装依赖

```bash
# 安装所有项目的依赖
mix deps.get

# 这可能需要几分钟，请耐心等待...
```

**首次运行可能看到类似输出：**

```
Resolving Hex dependencies...
Dependency resolution completed:
New:
  ...
* Getting ... (hex)
* Getting ... (rebar3)

Generated app app_name
```

### 步骤 3: 编译项目

```bash
# 编译所有应用
mix compile

# 编译完成后应看到：
# Generated beehive_ex app
# Generated bee_admin app
# Generated bee_rpc app
```

### 步骤 4: 运行测试（可选）

```bash
# 运行所有测试
mix test
```

**预期输出：**

```
Compiling XX files (.ex)
Generated bee_admin app
Generated bee_rpc app
Generated bee_proto app
Generated bee_utils app

Running in XX.xx seconds
10 tests, 0 failures
```

## 🚀 启动服务

### 启动 bee_admin API 服务

**选项 1: 生产模式（推荐）**

```bash
# 进入 bee_admin 目录
cd apps/bee_admin

# 启动 Phoenix 服务器
mix phx.server

# 看到以下信息表示启动成功：
# [info] Running BeeAdminWeb.Endpoint with Bandit at http://localhost:4000
```

**选项 2: 开发模式（带 IEx）**

```bash
# 进入 bee_admin 目录
cd apps/bee_admin

# 启动带交互式 shell 的服务器
iex -S mix phx.server

# 优点：可以实时查看日志和调试
```

### 启动 bee_rpc 服务（可选）

如果您想测试 gRPC 服务：

```bash
# 在另一个终端窗口中
cd apps/bee_rpc
iex -S mix

# 在 IEx 中启动服务
iex(1)> BeeRpc.Endpoint.start_server()
# 或手动启动 GenServer
iex(1)> {:ok, _} = BeeRpc.Register.ETS.start_link([])
```

## 🧪 验证安装

### 1. 健康检查

打开新的终端窗口，运行：

```bash
# 测试 bee_admin API
curl http://localhost:4000/api/health
```

**预期响应：**

```json
{
  "status": "healthy",
  "timestamp": "2025-11-03T10:00:00Z"
}
```

### 2. 验证服务器状态

```bash
# 检查端口是否在监听
lsof -i :4000

# 应该看到类似输出：
# COMMAND  PID   USER   NAME
# beam.smp 12345 user    *:4000 (LISTEN)
```

### 3. 测试 RPC 服务（可选）

如果您启动了 bee_rpc：

```elixir
# 在运行 bee_rpc 的 IEx 中
iex> alias Echo.Greeter.Service, as: GreeterService
iex> request = %Echo.EchoReq{name: "World"}
iex> # (需要配置 channel 进行实际调用)
```

## 🎓 下一步

恭喜！您已成功运行 BeehiveEx。以下是一些后续步骤：

### 📚 学习资源

1. **阅读文档**
   - [项目架构](./README.md) - 了解整体设计
   - [应用文档](./apps/bee_admin/README.md) - 深入了解各组件
   - [开发者指南](./CONTRIBUTING.md) - 开始贡献代码

2. **探索代码**
   ```bash
   # 查看项目结构
   tree apps/ -L 2

   # 查看 bee_admin 的 API 控制器
   cat apps/bee_admin/lib/bee_admin_web/controllers/api_controller.ex
   ```

3. **运行示例**
   ```bash
   # 在 bee_admin 中查看路由
   cat apps/bee_admin/lib/bee_admin_web/router.ex
   ```

### 🔧 开发第一个功能

1. **创建一个新端点**

   编辑 `apps/bee_admin/lib/bee_admin_web/router.ex`：

   ```elixir
   scope "/api", BeeAdminWeb do
     pipe_through :api

     get "/health", ApiController, :health_check
     get "/hello", ApiController, :hello  # 新增
   end
   ```

2. **实现控制器**

   编辑 `apps/bee_admin/lib/bee_admin_web/controllers/api_controller.ex`：

   ```elixir
   def health_check(conn, _params) do
     conn
     |> put_status(:ok)
     |> json(%{status: "healthy", timestamp: DateTime.utc_now()})
   end

   def hello(conn, _params) do
     conn
     |> put_status(:ok)
     |> json(%{message: "Hello from BeehiveEx!"})
   end
   ```

3. **测试新端点**

   ```bash
   # 重启服务器（如果使用开发模式，按 Ctrl+C 重新启动）

   # 测试新端点
   curl http://localhost:4000/api/hello

   # 预期响应：
   # {"message":"Hello from BeehiveEx!"}
   ```

### 📦 理解 Umbrella 结构

```
beehive_ex/
├── apps/
│   ├── bee_admin/          # Web API 服务
│   ├── bee_rpc/            # gRPC 服务
│   ├── bee_proto/          # 协议定义
│   └── bee_utils/          # 工具库
├── config/                 # 全局配置
└── mix.exs                 # 根配置
```

**关键命令：**

```bash
# 从根目录运行所有应用的测试
mix test

# 从根目录编译所有应用
mix compile

# 进入特定应用目录
cd apps/bee_admin
cd apps/bee_rpc
```

### 🎯 尝试 gRPC

如果您想体验 gRPC：

1. **生成 Protocol Buffers 代码**

   ```bash
   cd apps/bee_proto
   mix gen.proto

   # 安装 protoc-gen-elixir（如未安装）
   mix escript.install hex protobuf
   export PATH="$HOME/.mix/escripts:$PATH"
   ```

2. **在 bee_rpc 中生成 gRPC 代码**

   ```bash
   cd apps/bee_rpc
   mix gen.grpc.proto
   ```

## 🐛 常见问题

### Q: 端口 4000 已被占用

**A:** 使用其他端口：

```bash
PORT=4001 mix phx.server
# 或编辑 config/dev.exs 修改端口
```

### Q: 依赖安装失败

**A:** 清理缓存并重新安装：

```bash
mix deps.clean --all
mix deps.get
mix compile
```

### Q: 编译错误：未找到模块

**A:** 确保在正确的目录中：

```bash
# 从根目录运行
mix compile

# 或进入特定应用
cd apps/bee_admin
mix compile
```

### Q: Elixir 版本不匹配

**A:** 使用 asdf 或 kiex 管理多个版本：

```bash
# 使用 asdf 安装特定版本
asdf install elixir 1.18.0
asdf local elixir 1.18.0

# 或使用 kiex
kiex install 1.18.0
kiex use 1.18.0
```

### Q: 测试失败

**A:** 检查测试环境配置：

```bash
# 确保处于测试环境
MIX_ENV=test mix deps.get
MIX_ENV=test mix test
```

### Q: 无法访问 localhost:4000

**A:** 检查防火墙和安全组：

```bash
# 检查服务是否启动
lsof -i :4000

# 查看详细日志（开发模式）
iex -S mix phx.server
```

### Q: protoc 命令未找到

**A:** 安装 Protocol Buffers 编译器：

**macOS:**

```bash
brew install protobuf
```

**Ubuntu/Debian:**

```bash
sudo apt-get install protobuf-compiler
```

**验证安装：**

```bash
protoc --version
# 应该显示: libprotoc x.x.x
```

### Q: mix phx.server 找不到

**A:** 确保在 bee_admin 目录中：

```bash
cd apps/bee_admin
mix phx.server
```

### Q: gRPC 服务启动失败

**A:** 检查端口冲突：

```bash
# 检查端口 50051
lsof -i :50051

# 修改 config 中的端口
```

## 🎉 完成

恭喜！您已完成 BeehiveEx 的快速开始之旅！

### 📞 获取帮助

- **文档**: [README.md](./README.md)
- **开发者指南**: [CONTRIBUTING.md](./CONTRIBUTING.md)
- **GitHub Issues**: 报告 Bug 或提出问题
- **GitHub Discussions**: 参与讨论

### 🌟 致谢

感谢您选择 BeehiveEx！我们期待您的贡献和反馈。

---

<div align="center">

**开始您的 BeehiveEx 开发之旅吧！** 🚀

</div>
