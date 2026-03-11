# BeeProto

[![Elixir](https://img.shields.io/badge/Elixir-1.18+-4B275F.svg?style=flat-square)](https://elixir-lang.org)
[![Protocol Buffers](https://img.shields.io/badge/Protocol%20Buffers-3.0-blue.svg?style=flat-square)](https://protobuf.dev/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](../../LICENSE)

BeeProto 是 BeehiveEx 项目中的 **Protocol Buffers 协议定义和代码生成工具**，负责统一管理所有 .proto 文件，并生成多语言的序列化代码。

## ✨ 核心特性

- 📝 **协议定义管理**: 集中管理所有 Protocol Buffers 定义
- 🔧 **多语言代码生成**: 支持 Elixir、Go、Python、Java 等语言
- 🔄 **自动化生成**: 通过 Mix 任务一键生成所有代码
- 📦 **版本兼容**: 支持 Proto3 语法规范
- 🔗 **依赖管理**: 自动处理 proto 文件间的依赖关系
- 🏗️ **模块化设计**: 与 bee_rpc 无缝集成

## 🏗️ 目录结构

```
bee_proto/
├── priv/
│   └── proto/                     # Protocol Buffers 定义目录
│       ├── v1/                    # 版本化的协议
│       │   ├── common/            # 通用消息
│       │   ├── user/              # 用户相关协议
│       │   └── service/           # 服务协议
│       └── v2/                    # 版本2协议（可选）
├── lib/
│   ├── bee_proto.ex               # 主模块
│   └── generators/
│       ├── elixir_generator.ex    # Elixir 代码生成器
│       └── grpc_generator.ex      # gRPC 代码生成器
├── test/
└── mix.exs
```

## 🚀 快速开始

### 1. 安装 protoc-gen-elixir

```bash
# 安装 Elixir Protocol Buffers 生成器
mix escript.install hex protobuf

# 添加到 PATH
export PATH="$HOME/.mix/escripts:$PATH"
```

### 2. 创建 Protocol Buffers 文件

在 `priv/proto/` 目录下创建您的协议文件：

`priv/proto/v1/common/ping_pong.proto`:

```proto
syntax = "proto3";

package common.v1;

option go_package = "github.com/yourorg/beehive_ex/gen/go/common/v1";
option elixir_module_prefix = "Common.V1";

// 通用 Ping 消息
message PingReq {
  string message = 1;
  int64 timestamp = 2;
}

// Pong 响应消息
message PongReply {
  string message = 1;
  int64 timestamp = 2;
}

// 服务定义
service PingPongService {
  rpc Ping(PingReq) returns (PongReply);
  rpc StreamPing(stream PingReq) returns (stream PongReply);
}
```

### 3. 生成代码

```bash
# 进入 bee_proto 目录
cd apps/bee_proto

# 生成所有语言的代码
mix gen.proto

# 查看生成帮助
mix help gen.proto
```

### 4. 使用生成的代码

生成的代码将被保存到以下位置：

- **Elixir**: `lib/generated/` 目录
- **Go**: `gen/go/` 目录
- **Python**: `gen/python/` 目录
- **Java**: `gen/java/` 目录

在 Elixir 中使用：

```elixir
defmodule MyApp.PingPongClient do
  use GRPC.Stub, service: Common.V1.PingPongService

  def ping(message) do
    request = %Common.V1.PingReq{
      message: message,
      timestamp: System.system_time(:second)
    }

    Common.V1.PingPongService.Ping.call(request, channel)
  end
end
```

## 📋 协议定义规范

### 1. 文件命名规范

- 使用小写字母和下划线：`user_service.proto`
- 按功能模块组织目录结构
- 版本化协议：`v1/`, `v2/`

### 2. 包名规范

```proto
package {organization}.{project}.{version};

# 示例
package beehive.ex.v1;
package mycompany.chat.v2;
```

### 3. 消息命名规范

- 使用 PascalCase：`UserInfo`, `LoginRequest`
- 添加清晰的后缀：`Request`, `Reply`, `Response`

### 4. 字段命名规范

- 使用 snake_case：`user_name`, `created_at`
- 添加字段编号：`int64 user_id = 1;`

### 5. 完整示例

`priv/proto/v1/user/user_service.proto`:

```proto
syntax = "proto3";

package beehive.ex.v1.user;

option elixir_module_prefix = "User.V1";
option go_package = "github.com/yourorg/beehive_ex/gen/go/user/v1";

import "common/v1/types.proto";

// 用户信息
message User {
  int64 id = 1;
  string name = 2;
  string email = 3;
  common.v1.Timestamp created_at = 4;
}

// 创建用户请求
message CreateUserRequest {
  string name = 1;
  string email = 2;
}

// 创建用户响应
message CreateUserReply {
  User user = 1;
}

// 用户服务
service UserService {
  rpc CreateUser(CreateUserRequest) returns (CreateUserReply);
  rpc GetUser(GetUserRequest) returns (GetUserReply);
  rpc ListUsers(ListUsersRequest) returns (ListUsersReply);
  rpc UpdateUser(UpdateUserRequest) returns (UpdateUserReply);
  rpc DeleteUser(DeleteUserRequest) returns (DeleteUserReply);
}

// 获取用户请求
message GetUserRequest {
  int64 id = 1;
}

// ... 其他消息定义
```

## 🔧 代码生成任务

### mix gen.proto

生成所有语言的 Protocol Buffers 代码：

```bash
# 生成所有语言
mix gen.proto

# 仅生成 Elixir 代码
mix gen.proto --lang elixir

# 仅生成 Go 代码
mix gen.proto --lang go

# 生成并覆盖现有文件
mix gen.proto --force
```

### 支持的语言

| 语言 | 描述 | 生成目录 |
|------|------|----------|
| **Elixir** | 序列化/反序列化 | `lib/generated/` |
| **Go** | gRPC 客户端/服务端 | `gen/go/` |
| **Python** | 客户端库 | `gen/python/` |
| **Java** | Android/服务端 | `gen/java/` |

## 🧪 运行测试

```bash
# 运行所有测试
mix test

# 生成测试覆盖率报告
mix test --cover

# 运行特定测试
mix test test/bee_proto_test.exs
```

## 🔄 与 bee_rpc 集成

BeeProto 与 BeeRpc 紧密集成，提供完整的 gRPC 开发体验：

### 1. 在 bee_rpc 中使用

bee_rpc 会自动依赖 bee_proto：

```elixir
# apps/bee_rpc/mix.exs
defp deps do
  [
    {:bee_proto, in_umbrella: true},
    {:grpc, "~> 0.10"}
  ]
end
```

### 2. 生成 gRPC 代码

在 bee_rpc 中使用专用任务：

```bash
cd apps/bee_rpc
mix gen.grpc.proto
```

这将：
1. 从 bee_proto 获取 .proto 文件
2. 生成 gRPC 特定的代码
3. 使用 BeeRpc.Client.Stub 替换默认 Stub

### 3. 完整工作流

```bash
# 1. 定义协议
cd apps/bee_proto
vim priv/proto/v1/service/my_service.proto

# 2. 生成代码
mix gen.proto

# 3. 在 bee_rpc 中生成 gRPC 代码
cd ../bee_rpc
mix gen.grpc.proto

# 4. 实现服务
vim lib/services/my_service_server.ex
```

## 📦 依赖说明

主要依赖：

- **bee_rpc** (in_umbrella: true) - gRPC 服务框架
- **protobuf** (开发依赖) - protoc Elixir 插件

## 🐛 故障排除

### 常见问题

**Q: protoc-gen-elixir 未找到**

```bash
# 检查是否安装
mix escript.list

# 重新安装
mix escript.install hex protobuf --force

# 添加到 PATH
echo 'export PATH="$HOME/.mix/escripts:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Q: 生成失败**

```bash
# 检查 .proto 语法
protoc --version

# 验证 .proto 文件
protoc --proto_path=priv/proto priv/proto/v1/service/my_service.proto
```

**Q: 依赖文件找不到**

```proto
# 确保使用正确的 import 路径
import "common/v1/types.proto";  # 正确

# 而不是
import "types.proto";  # 错误
```

## 📚 相关文档

- [Protocol Buffers 官方文档](https://protobuf.dev/)
- [Proto3 语言指南](https://protobuf.dev/programming-guides/style/)
- [Elixir protobuf 库](https://github.com/elixir-protobuf/protobuf)
- [gRPC 官方文档](https://grpc.io/docs/)

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [../../LICENSE](../../LICENSE)

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！详见 [../../CONTRIBUTING.md](../../CONTRIBUTING.md)

---

<div align="center">

**统一的 Protocol Buffers 协议管理 | BeehiveEx 系列应用**

</div>
