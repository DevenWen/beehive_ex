# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

BeehiveEx 是一个 Elixir Umbrella 项目，包含四个独立的应用模块，采用模块化架构设计。

### 应用结构

- **bee_admin** - Phoenix 框架构建的 REST API 服务，提供管理后台接口
- **bee_rpc** - gRPC 服务端和客户端实现，支持服务注册与发现
- **bee_proto** - Protocol Buffers 协议定义和代码生成工具
- **bee_utils** - 通用工具库

### 核心依赖

- Elixir ~> 1.14 (bee_admin) / ~> 1.18 (其他应用)
- Phoenix ~> 1.7.17 (bee_admin)
- grpc 和 protobuf (bee_rpc)
- Bandit (Web 服务器)

## 常用开发命令

### 环境准备
```bash
# 安装依赖
mix deps.get

# 编译项目
mix compile
```

### 运行和测试
```bash
# 运行所有测试
mix test

# 在特定应用目录运行测试
cd apps/bee_admin && mix test
cd apps/bee_rpc && mix test

# 启动 bee_admin 开发服务器
cd apps/bee_admin
mix phx.server
# 或交互模式
iex -S mix phx.server

# 启动 bee_rpc 服务
cd apps/bee_rpc
iex -S mix
```

### 代码生成
```bash
# 在 bee_proto 中生成 Protocol Buffers 代码
mix gen.proto

# 在 bee_rpc 中生成 gRPC 代码
mix gen.grpc.proto
```

### 代码格式化
```bash
# 格式化所有代码
mix format
```

## 代码架构

### bee_admin 应用
- **位置**: `apps/bee_admin/`
- **框架**: Phoenix 1.7 (API 模式)
- **端口**: 默认 4000
- **主要文件**:
  - `lib/bee_admin_web/router.ex` - API 路由定义
  - `lib/bee_admin_web/controllers/api_controller.ex` - 控制器
  - `config/config.exs` - 应用配置

**API 端点**:
- `GET /api/health` - 健康检查

### bee_rpc 应用
- **位置**: `apps/bee_rpc/`
- **框架**: gRPC/GRPC
- **端口**: 50051 (可配置)
- **主要文件**:
  - `priv/services/echo.proto` - Protocol Buffers 定义
  - `lib/bee_rpc/server/` - gRPC 服务端实现
  - `lib/bee_rpc/client/` - gRPC 客户端 Stub
  - `lib/bee_rpc/register/` - 服务注册实现 (支持 ETS/ETCD)

**关键模块**:
- `BeeRpc.Endpoint` - gRPC 端点配置
- `BeeRpc.Register` - 服务注册抽象层
- `BeeRpc.Server.Sup` - 服务监督树

### bee_proto 应用
- **位置**: `apps/bee_proto/`
- **用途**: 集中管理 Protocol Buffers 定义
- **命令**: 需要安装 `protoc-gen-elixir`

### bee_utils 应用
- **位置**: `apps/bee_utils/`
- **用途**: 提供通用工具函数
- **模块**: `BeeUtils`, `BeeUtils.IPUtil`

## 服务间依赖关系

```
bee_proto (协议定义)
    ↓
bee_rpc (依赖 bee_proto)
    ↓
bee_admin (可调用 bee_rpc 服务)
    ↑
bee_utils (所有应用共享)
```

## 配置说明

### 全局配置
- **根配置**: `config/config.exs`
- **应用配置**: 各应用的 `config/` 目录

### bee_rpc 配置
```elixir
config :bee_rpc,
  register: [module: BeeRpc.Register.ETS],  # 或 BeeRpc.Register.ETCD
  endpoint: [module: BeeRpc.Endpoint, opts: [port: 50051]],
  client: [opts: [pool_size: 5, pool_max_overflow: 10]]
```

### bee_admin 配置
```elixir
config :bee_admin, BeeAdminWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_error: [formats: [json: BeeAdminWeb.ErrorJSON]]
```

## 开发注意事项

1. **Umbrella 项目结构**: 根目录的 `mix.exs` 管理所有子应用
2. **依赖管理**: 子应用可在 `mix.exs` 中声明 `in_umbrella: true` 的依赖
3. **代码共享**: bee_utils 可被所有其他应用使用
4. **协议定义**: 在 bee_proto 中定义 .proto 文件，通过任务生成代码
5. **服务注册**: bee_rpc 支持基于 ETS 或 ETCD 的服务发现机制
6. **测试**: 每个应用都有自己的 `test/` 目录，可独立运行测试

## 项目状态

当前项目处于早期阶段，大多数应用的 README 仍标记为 "TODO: Add description"。bee_admin 提供了基础的健康检查端点，bee_rpc 实现了基本的 gRPC 框架。