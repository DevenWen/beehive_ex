# BeeRpc

[![Elixir](https://img.shields.io/badge/Elixir-1.18+-4B275F.svg?style=flat-square)](https://elixir-lang.org)
[![gRPC](https://img.shields.io/badge/gRPC-0.10-blue.svg?style=flat-square)](https://grpc.io)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](../../LICENSE)

BeeRpc 是基于 **gRPC** 的高性能 RPC 服务框架，为 BeehiveEx 项目提供服务注册、服务发现和 RPC 调用功能。

## ✨ 核心特性

- 🚀 **高性能 RPC**: 基于 gRPC-elixir 的高效远程调用
- 📋 **服务注册**: 支持 ETS 本地和 ETCD 分布式注册中心
- 🔍 **服务发现**: 动态服务发现与负载均衡
- 🏢 **多服务支持**: 支持同时注册多个 gRPC 服务
- 🔌 **客户端封装**: 简化的客户端 Stub 实现
- 🛠️ **监督树**: 基于 OTP 的服务监督机制

## 🏗️ 系统架构

```
┌─────────────────────────────────────┐
│           BeeRpc 架构                │
├─────────────────────────────────────┤
│  服务注册层 (BeeRpc.Register)       │
│  ┌──────────┐    ┌──────────┐      │
│  │ ETS 注册 │    │ ETCD 注册 │      │
│  └──────────┘    └──────────┘      │
├─────────────────────────────────────┤
│  服务层 (GRPC.Server)              │
│  ┌─────────────────────────────────┐ │
│  │ GreeterServer (示例服务)        │ │
│  └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│  客户端层 (BeeRpc.Client.Stub)     │
│  ┌─────────────────────────────────┐ │
│  │ 自动发现与通道管理               │ │
│  └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

## 🚀 快速开始

### 安装依赖

```bash
# 从根目录安装
mix deps.get

# 或进入应用目录
cd apps/bee_rpc
mix deps.get
```

### 生成 Protocol Buffers 代码

```bash
# 进入bee_rpc目录
cd apps/bee_rpc

# 生成gRPC代码
mix gen.grpc.proto
```

### 启动 gRPC 服务

```bash
# 开发模式
iex -S mix

# 在 IEx 中启动服务
iex> BeeRpc.Endpoint.start_server()
```

## 📡 使用示例

### 服务端实现

#### 1. 定义 Protocol Buffers 协议

`priv/services/echo.proto`:

```proto
syntax = "proto3";

package echo;

message EchoReq {
  string name = 1;
}

message EchoReply {
  string message = 1;
}

service Greeter {
  rpc SayHello(EchoReq) returns (EchoReply);
}
```

#### 2. 实现 gRPC 服务

`lib/services/greeter_server.ex`:

```elixir
defmodule BeeRpc.GreeterServer do
  use GRPC.Server, service: Echo.Greeter.Service

  @doc """
  处理 SayHello RPC 调用
  """
  def say_hello(%Echo.EchoReq{name: name}, _stream) do
    message = "Hello, #{name}!"
    %Echo.EchoReply{message: message}
  end
end
```

#### 3. 注册服务

在应用的 `start/2` 函数中注册服务：

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      # 启动服务注册器
      {BeeRpc.Register.ETS, server_infos: [
        %BeeRpc.Server.ServiceInfo{
          name: "Greeter",
          functions: ["SayHello"]
        }
      ]},
      # 启动 gRPC Endpoint
      {BeeRpc.Endpoint, port: 50051}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
```

### 客户端调用

#### 1. 创建客户端模块

```elixir
defmodule MyApp.GreeterClient do
  use BeeRpc.Client.Stub, service: Echo.Greeter.Service

  @doc """
  调用 SayHello 服务
  """
  def say_hello(name) do
    request = %Echo.EchoReq{name: name}

    # 自动从注册中心获取服务地址
    {:ok, channel} = BeeRpc.Discovery.get_channel("Greeter")

    # 调用 RPC
    Echo.Greeter.Service.SayHello.call(request, channel)
  end
end
```

#### 2. 客户端使用

```elixir
# 启动 IEx
iex -S mix

# 调用服务
iex> MyApp.GreeterClient.say_hello("World")
{:ok, %Echo.EchoReply{message: "Hello, World!"}}
```

## 📋 服务注册机制

### ETS 本地注册（默认）

适用于单机部署或开发环境：

```elixir
config :bee_rpc,
  register: [module: BeeRpc.Register.ETS]
```

### ETCD 分布式注册

适用于生产环境的多机部署：

```elixir
config :bee_rpc,
  register: [
    module: BeeRpc.Register.ETCD,
    hosts: ["http://etcd1:2379", "http://etcd2:2379"]
  ]
```

### 服务信息结构

```elixir
%BeeRpc.Server.ServiceInfo{
  name: "Greeter",              # 服务名称
  functions: ["SayHello"],      # 支持的函数列表
  endpoint: "localhost:50051", # 服务地址
  weight: 1                     # 负载权重
}
```

### 注册 API

```elixir
# 注册服务
BeeRpc.Register.register_service("Greeter", service_info)

# 注销服务
BeeRpc.Register.unregister_service("Greeter")

# 列出所有服务
BeeRpc.Register.list_services()

# 获取服务信息
BeeRpc.Register.get_service("Greeter")
```

## ⚙️ 配置说明

### Endpoint 配置

```elixir
config :bee_rpc,
  endpoint: [
    module: BeeRpc.Endpoint,
    opts: [
      port: 50051,              # gRPC 端口
      start_server: true        # 自动启动服务
    ]
  ]
```

### 客户端配置

```elixir
config :bee_rpc,
  client: [
    opts: [
      pool_size: 5,             # 连接池大小
      pool_max_overflow: 10     # 最大溢出连接
    ]
  ]
```

### 完整配置示例

```elixir
# config/config.exs
config :bee_rpc,
  register: [module: BeeRpc.Register.ETS],
  endpoint: [
    module: BeeRpc.Endpoint,
    opts: [
      port: 50051,
      start_server: true
    ]
  ],
  client: [
    opts: [
      pool_size: 5,
      pool_max_overflow: 10
    ]
  ]
```

## 🏗️ 项目结构

```
bee_rpc/
├── priv/
│   └── services/
│       └── echo.proto              # Protocol Buffers 定义
├── lib/
│   ├── bee_rpc.ex                  # 主模块
│   ├── bee_rpc/
│   │   ├── client/
│   │   │   └── stub.ex             # 客户端 Stub
│   │   ├── register/
│   │   │   ├── ets.ex              # ETS 注册实现
│   │   │   └── etcd.ex             # ETCD 注册实现
│   │   ├── server/
│   │   │   ├── sup.ex              # 监督树
│   │   │   └── service_info.ex     # 服务信息
│   │   └── endpoint.ex             # gRPC 端点
│   ├── example/
│   │   ├── greeter_server.ex       # 示例服务端
│   │   └── endpoint.ex             # 示例端点
│   └── services/
│       ├── echo.pb.ex              # 生成的 Protobuf 代码
│       └── echo.pb.go              # Go 客户端代码（可选）
├── test/
│   ├── test_helper.exs
│   └── ...
└── mix.exs
```

## 🧪 运行测试

```bash
# 运行所有测试
mix test

# 运行特定测试
mix test test/greeter_server_test.exs

# 测试覆盖率
mix test --cover
```

## 🛠️ 代码生成

### Protocol Buffers

```bash
# 在 bee_proto 中生成
cd apps/bee_proto
mix gen.proto
```

### gRPC 代码

```bash
# 在 bee_rpc 中生成
cd apps/bee_rpc
mix gen.grpc.proto
```

该命令会：
1. 编译 `priv/**/*.proto` 文件
2. 生成 Elixir gRPC 代码
3. 替换默认的 GRPC.Stub 为 BeeRpc.Client.Stub

## 🐛 故障排除

### 常见问题

**Q: 端口 50051 已被占用**

```bash
# 查看端口占用
lsof -i :50051

# 使用其他端口
config :bee_rpc, endpoint: [opts: [port: 50052]]
```

**Q: 客户端无法连接服务**

```elixir
# 检查服务是否注册
BeeRpc.Register.list_services()

# 检查注册器状态
:sys.get_state(BeeRpc.Register.ETS)
```

**Q: 生成代码失败**

```bash
# 确保 protoc 编译器已安装
protoc --version

# 确保 protoc-gen-elixir 已安装
mix escript.install hex protobuf
```

## 📦 依赖说明

主要依赖：

- **protobuf** (~> 0.14) - Protocol Buffers 序列化
- **grpc** (~> 0.10) - gRPC 实现
- **bee_utils** - 工具库依赖

## 📚 相关文档

- [Phoenix Framework](https://www.phoenixframework.org/) - Web 框架
- [gRPC 官方文档](https://grpc.io/docs/) - gRPC 指南
- [Protocol Buffers](https://protobuf.dev/) - Protobuf 文档

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [../../LICENSE](../../LICENSE)

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！详见 [../../CONTRIBUTING.md](../../CONTRIBUTING.md)

---

<div align="center">

**基于 gRPC 的高性能 RPC 框架 | BeehiveEx 系列应用**

</div>
