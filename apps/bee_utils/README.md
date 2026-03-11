# BeeUtils

[![Elixir](https://img.shields.io/badge/Elixir-1.18+-4B275F.svg?style=flat-square)](https://elixir-lang.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](../../LICENSE)

BeeUtils 是 BeehiveEx 项目的**通用工具库**，为所有应用提供可复用的实用函数和工具模块。

## ✨ 核心特性

- 🛠️ **通用工具**: 提供跨应用共享的实用函数
- 🔌 **模块化设计**: 按功能划分独立的工具模块
- 📦 **轻量级**: 无外部依赖，快速加载
- 🔄 **可扩展**: 易于添加新的工具模块
- 🏗️ **Umbrella 共享**: 被所有 Umbrella 应用依赖和使用

## 🏗️ 模块结构

```
bee_utils/
├── lib/
│   ├── bee_utils.ex              # 主模块
│   ├── bee_utils/
│   │   ├── ip_util.ex            # IP 地址工具
│   │   ├── string_util.ex        # 字符串工具（规划中）
│   │   ├── datetime_util.ex      # 日期时间工具（规划中）
│   │   ├── crypto_util.ex        # 加密工具（规划中）
│   │   └── validation_util.ex    # 验证工具（规划中）
├── test/
└── mix.exs
```

## 🚀 快速开始

### 安装依赖

在您的 `mix.exs` 中添加依赖：

```elixir
def deps do
  [
    {:bee_utils, in_umbrella: true}
  ]
end
```

### 基本使用

```elixir
# 导入主模块
import BeeUtils

# 或导入特定工具
import BeeUtils.IPUtil
```

## 📚 工具模块文档

### BeeUtils 主模块

#### `hello/0`

返回问候语。

```elixir
iex> BeeUtils.hello()
:world
```

**用途**: 示例函数，展示模块的基本结构

---

### BeeUtils.IPUtil

IP 地址处理工具模块（开发中）

#### 计划功能

- IP 地址验证
- CIDR 网络计算
- IP 范围查询
- 公网/私网 IP 判断

#### 未来示例

```elixir
# 验证 IP 地址格式
iex> IpUtil.valid_ip?("192.168.1.1")
true

# 检查是否为私网 IP
iex> IpUtil.private_ip?("10.0.0.1")
true

# CIDR 网络计算
iex> IpUtil.network_address("192.168.1.100/24")
"192.168.1.0"
```

---

### 🔮 规划中的模块

#### BeeUtils.StringUtil

字符串处理工具：

- 字符串格式化
- 随机字符串生成
- URL 编码/解码
- 正则表达式辅助

#### BeeUtils.DateTimeUtil

日期时间工具：

- 时间戳转换
- 时区处理
- 相对时间格式化

#### BeeUtils.CryptoUtil

加密工具：

- Hash 计算（MD5, SHA256）
- Base64 编码/解码
- 随机令牌生成

#### BeeUtils.ValidationUtil

验证工具：

- 邮箱格式验证
- 手机号验证
- 身份证号验证
- 通用验证器

## 🧪 运行测试

```bash
# 运行所有测试
mix test

# 运行特定测试
mix test test/bee_utils_test.exs

# 测试覆盖率
mix test --cover
```

## 🛠️ 添加新工具模块

### 步骤 1: 创建模块

在 `lib/bee_utils/` 下创建新文件：

`lib/bee_utils/my_new_util.ex`:

```elixir
defmodule BeeUtils.MyNewUtil do
  @moduledoc """
  我的新工具模块

  ## 使用示例

      iex> BeeUtils.MyNewUtil.do_something()
      :ok
  """

  @doc """
  执行某项操作

  ## 参数

    - param: 参数描述

  ## 示例

      iex> BeeUtils.MyNewUtil.do_something("test")
      :ok
  """
  def do_something(param) do
    # 实现逻辑
    :ok
  end
end
```

### 步骤 2: 添加测试

`test/bee_utils/my_new_util_test.exs`:

```elixir
defmodule BeeUtils.MyNewUtilTest do
  use ExUnit.Case
  doctest BeeUtils.MyNewUtil

  test "do_something/1" do
    assert BeeUtils.MyNewUtil.do_something("test") == :ok
  end
end
```

### 步骤 3: 更新主模块（可选）

在 `lib/bee_utils.ex` 中导出：

```elixir
defmodule BeeUtils do
  def hello, do: :world

  # 导出新工具
  defdelegate do_something(param), to: BeeUtils.MyNewUtil, as: :do_something
end
```

## 📦 依赖说明

当前版本无外部依赖，保持轻量级特性。

## 🔧 开发指南

### 代码规范

- 使用 `snake_case` 命名文件
- 为所有公共函数添加 `@doc` 文档
- 为模块添加 `@moduledoc` 描述
- 为复杂函数提供示例
- 编写对应的单元测试

### 测试要求

- 所有公共函数必须有测试
- 使用 `doctest` 验证示例代码
- 测试覆盖率应达到 100%
- 测试命名应清晰描述测试场景

## 🐛 故障排除

### 常见问题

**Q: 无法导入模块**

```elixir
# 正确方式
import BeeUtils
import BeeUtils.IPUtil

# 或使用别名
alias BeeUtils.IPUtil, as: IP
```

**Q: 函数未定义**

确保模块已编译：
```bash
mix compile
iex -S mix
```

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [../../LICENSE](../../LICENSE)

## 🤝 贡献指南

我们欢迎贡献新的工具模块！

### 贡献流程

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 开启 Pull Request

### 贡献建议

- 优先添加通用性强的工具
- 保持模块功能单一和内聚
- 提供清晰的文档和示例
- 确保测试覆盖率

---

<div align="center">

**让代码更简洁 | BeehiveEx 系列应用**

</div>
