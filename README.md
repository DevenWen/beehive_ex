# BeehiveEx

[![Elixir](https://img.shields.io/badge/Elixir-1.14+-4B275F.svg?style=flat-square)](https://elixir-lang.org)
[![Phoenix](https://img.shields.io/badge/Phoenix-1.7-FF3653.svg?style=flat-square)](https://phoenixframework.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](./LICENSE)

BeehiveEx 是一个基于 Elixir 构建的微服务工具集，提供了高性能的 gRPC 服务框架、管理后台 API 和统一的协议定义管理等功能。

## 🚀 快速开始

详细的安装和运行指南请查看：[QUICKSTART.md](./QUICKSTART.md)

```bash
# 1. 安装依赖
mix deps.get

# 2. 编译项目
mix compile

# 3. 启动 bee_admin API 服务
cd apps/bee_admin
mix phx.server

# 4. 健康检查
curl http://localhost:4000/api/health
```

## 📦 项目架构

BeehiveEx 采用 **Elixir Umbrella** 项目架构，将相关功能拆分为多个独立的应用：

```
beehive_ex/
├── apps/
│   ├── bee_admin/      # Phoenix REST API 服务 (管理后台)
│   ├── bee_rpc/        # gRPC 服务端与客户端框架
│   ├── bee_proto/      # Protocol Buffers 协议定义与代码生成
│   └── bee_utils/      # 通用工具库
├── config/             # 全局配置
├── _build/            # 编译产物
└── deps/              # 外部依赖
```

## ✨ 核心特性

- 🎯 **模块化架构**: 基于 Elixir Umbrella 项目设计，低耦合高内聚
- ⚡ **高性能 RPC**: 基于 gRPC 的高效服务调用框架
- 🌐 **REST API**: 基于 Phoenix 1.7 的管理后台接口
- 🔍 **服务发现**: 支持 ETS 本地和 ETCD 分布式服务注册
- 📄 **协议管理**: 统一的 Protocol Buffers 定义与代码生成
- 🛠️ **工具集**: 提供 IP 地址处理等通用工具函数

## 🏗️ 应用详解

| 应用 | 端口 | 功能描述 |
|------|------|----------|
| **bee_admin** | 4000 | Phoenix REST API 服务，提供管理后台接口 |
| **bee_rpc** | 50051 | gRPC 服务端，响应 RPC 调用请求 |
| **bee_proto** | - | 协议定义管理，生成 Elixir/Python/Go 等多语言代码 |
| **bee_utils** | - | 共享工具库，提供通用函数 |

## 💻 技术栈

- **语言**: Elixir ~> 1.14 / 1.18
- **Web 框架**: Phoenix ~> 1.7.17
- **RPC 框架**: gRPC-elixir ~> 0.10
- **序列化**: Protocol Buffers
- **Web 服务器**: Bandit (替代 Cowboy)
- **数据库**: 待定 (当前未集成)
- **配置管理**: Elixir Config

## 📚 文档导航

- [快速开始指南](./QUICKSTART.md) - 5分钟快速上手
- [开发者指南](./CONTRIBUTING.md) - 开发环境搭建与贡献指南
- [架构设计](./docs/ARCHITECTURE.md) - 详细架构设计文档
- [API 文档](./apps/bee_admin/README.md) - bee_admin API 说明
- [gRPC 文档](./apps/bee_rpc/README.md) - bee_rpc 使用说明

## 🧪 运行测试

```bash
# 运行所有应用的测试
mix test

# 运行特定应用的测试
mix test --apps bee_admin
mix test --apps bee_rpc

# 生成测试覆盖率报告
mix test --cover
```

## 🛠️ 代码生成

```bash
# 生成 Protocol Buffers 代码
cd apps/bee_proto
mix gen.proto

# 生成 gRPC 代码
cd apps/bee_rpc
mix gen.grpc.proto
```

## 👥 贡献指南

我们欢迎所有形式的贡献！请查看 [CONTRIBUTING.md](./CONTRIBUTING.md) 了解详细信息。

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](./LICENSE) 文件了解详情。

## 🤝 联系方式

- 项目维护者: [@your-github](https://github.com/your-github)
- 问题反馈: [GitHub Issues](https://github.com/your-org/beehive_ex/issues)

---

<div align="center">

**使用 ❤️ 和 Elixir 构建**

</div>

