# 贡献指南

感谢您对 BeehiveEx 项目的兴趣！我们欢迎所有形式的贡献，包括但不限于：

- 🐛 报告 Bug
- 💡 提出新功能建议
- 📝 完善文档
- 🔧 提交代码修复
- ✨ 添加新功能

## 📋 目录

- [行为准则](#行为准则)
- [开发环境搭建](#开发环境搭建)
- [开发流程](#开发流程)
- [代码规范](#代码规范)
- [测试要求](#测试要求)
- [提交规范](#提交规范)
- [Pull Request 流程](#pull-request-流程)
- [发布流程](#发布流程)

## 🌟 行为准则

### 我们的承诺

为了营造一个开放和包容的社区，我们承诺，无论年龄、体型、残疾、族裔、性别认同、经验水平、教育、社会经济地位、国籍、个人外貌、种族、宗教或性取向和性身份，我们都不会歧视任何人。

### 我们的标准

促进积极环境的行为示例包括：

- ✅ 使用友好和包容的语言
- ✅ 尊重不同的观点和经验
- ✅ 优雅地接受建设性批评
- ✅ 关注对社区最有利的事情
- ✅ 对其他社区成员表示同理心

不可接受的行为示例包括：

- ❌ 使用色情语言或图像
- ❌ 恶意评论或人身攻击
- ❌ 公开或私人骚扰
- ❌ 未经明确许可发布他人的私人信息
- ❌ 在专业环境中可能被合理认为不当的其他行为

## 🛠️ 开发环境搭建

### 前置要求

- **Elixir**: 1.14+ (bee_admin) / 1.18+ (其他应用)
- **Erlang**: 24+
- **Git**: 最新版本
- **protoc**: Protocol Buffers 编译器 (用于 bee_rpc 和 bee_proto)

### 1. Fork 并克隆仓库

```bash
# Fork 本仓库到您的 GitHub 账户
# 然后克隆您的 fork
git clone https://github.com/YOUR_USERNAME/beehive_ex.git
cd beehive_ex

# 添加上游仓库
git remote add upstream https://github.com/ORIGINAL_OWNER/beehive_ex.git
```

### 2. 安装依赖

```bash
# 安装所有依赖
mix deps.get

# 编译项目
mix compile
```

### 3. 验证安装

```bash
# 运行测试套件
mix test

# 启动 bee_admin
cd apps/bee_admin
mix phx.server

# 在另一个终端测试
curl http://localhost:4000/api/health
```

### 4. 安装代码生成工具（可选）

如果您要修改 Protocol Buffers 或 gRPC 代码：

```bash
# 安装 protoc-gen-elixir
mix escript.install hex protobuf

# 添加到 PATH
echo 'export PATH="$HOME/.mix/escripts:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## 🔄 开发流程

### 分支管理

我们使用 **GitFlow** 分支模型：

- `main`: 生产就绪代码
- `develop`: 开发分支
- `feature/*`: 新功能分支
- `bugfix/*`: Bug 修复分支
- `hotfix/*`: 紧急热修复分支

### 创建功能分支

```bash
# 更新主分支
git checkout main
git pull upstream main

# 创建功能分支
git checkout -b feature/your-feature-name

# 或修复分支
git checkout -b bugfix/issue-number-description
```

### 开发步骤

1. **编写代码**
2. **编写/更新测试**
3. **运行测试** `mix test`
4. **检查覆盖率** `mix test --cover`
5. **格式化代码** `mix format`
6. **代码检查** `mix credo` (可选)
7. **提交更改** `git commit -m "feat: add new feature"`
8. **推送到 fork** `git push origin feature/your-feature-name`
9. **创建 Pull Request**

## 📏 代码规范

### Elixir 编码规范

我们遵循 [Elixir 官方风格指南](https://github.com/christopheradams/elixir_style_guide)：

#### 1. 格式化

使用标准格式：

```bash
mix format
```

#### 2. 命名约定

```elixir
# 模块名：PascalCase
defmodule UserService do
  # 函数名：snake_case
  def get_user(id) do
    # 变量名：snake_case
    user_id = String.to_integer(id)
  end
end

# 常量：SCREAMING_SNAKE_CASE
@max_retries 3
```

#### 3. 文档规范

```elixir
defmodule MyModule do
  @moduledoc """
  模块的简短描述。

  ## 使用示例

      iex> MyModule.some_function()
      :ok

  更多详细信息...
  """

  @doc """
  函数的详细描述。

  ## 参数

    - param1: 参数1的描述
    - param2: 参数2的描述

  ## 返回值

  返回值的描述。

  ## 示例

      iex> MyModule.some_function("hello")
      "hello world"
  """
  @spec some_function(String.t()) :: String.t()
  def some_function(param1) do
    # 实现
  end
end
```

#### 4. 注释规范

```elixir
# 单行注释前空一行
# 这是注释内容

# 对于复杂逻辑，在代码上方注释
# 这个函数执行复杂的递归计算
# 从叶子节点向上聚合结果
def complex_function do
  # ...
end
```

### Umbrella 项目特殊规范

#### 1. 应用间依赖

```elixir
# 在 apps/bee_rpc/mix.exs 中
defp deps do
  [
    # 正确：使用 in_umbrella: true
    {:bee_proto, in_umbrella: true},
    {:bee_utils, in_umbrella: true}
  ]
end
```

#### 2. 模块命名

每个应用应使用唯一的前缀：

```elixir
# bee_admin
defmodule BeeAdminWeb.ApiController

# bee_rpc
defmodule BeeRpc.GreeterServer

# bee_proto
defmodule BeeProto.ProtocolGenerator

# bee_utils
defmodule BeeUtils.IPUtil
```

#### 3. 配置管理

- 全局配置在 `config/config.exs`
- 环境特定配置在 `config/{env}.exs`
- 应用特定配置在各应用的 `config/` 目录

## 🧪 测试要求

### 测试标准

- **覆盖率**: 所有公共函数必须有测试
- **单元测试**: 每个模块单独测试
- **集成测试**: 测试模块间交互
- **文档测试**: `@doc` 中的示例代码可运行

### 运行测试

```bash
# 运行所有测试
mix test

# 运行特定应用测试
mix test --apps bee_admin
mix test --apps bee_rpc

# 运行特定文件测试
mix test test/bee_admin_web/controllers/api_controller_test.exs

# 查看详细输出
mix test --trace

# 生成覆盖率报告
mix test --cover

# 打开覆盖率报告
open cover/excentage.html  # macOS
xdg-open cover/excentage.html  # Linux
```

### 编写测试

```elixir
defmodule BeeAdminWeb.ApiControllerTest do
  use BeeAdminWeb.ConnCase

  describe "GET /api/health" do
    test "返回健康状态", %{conn: conn} do
      conn = get(conn, ~p"/api/health")

      assert json_response(conn, 200) == %{
        "status" => "healthy",
        "timestamp" => _
      }
    end
  end
end
```

### 测试工具推荐

```elixir
# mix.exs 中添加测试工具
def deps do
  [
    {:credo, "~> 1.7", only: [:dev, :test]},
    {:dialyxir, "~> 1.4", only: [:dev]},
    {:ex_doc, "~> 0.27", only: :dev}
  ]
end
```

运行代码检查：

```bash
mix format --check-formatted
mix credo
mix dialyzer
```

## 📝 提交规范

我们使用 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

### 格式

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### 类型 (type)

- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更改
- `style`: 代码格式（不影响代码运行）
- `refactor`: 重构
- `test`: 添加或修改测试
- `chore`: 构建过程或辅助工具的变动
- `perf`: 性能优化
- `ci`: CI 配置文件和脚本的变动

### 示例

```bash
# 新功能
git commit -m "feat(bee_admin): add user management API"

# Bug 修复
git commit -m "fix(bee_rpc): resolve connection timeout issue"

# 文档
git commit -m "docs: update README with new installation steps"

# 重构
git commit -m "refactor(bee_utils): simplify IP validation logic"
```

### 提交消息示例

```bash
feat(bee_rpc): implement ETCD service discovery

- Add ETCD client integration
- Implement service registration
- Add health check mechanism
- Update configuration docs

Closes #123
```

## 🔀 Pull Request 流程

### 创建 PR

1. 确保您的代码遵循所有规范
2. 运行完整测试套件
3. 更新相关文档
4. 使用 PR 模板创建 Pull Request

### PR 模板

```markdown
## 📝 更改描述

简要描述本次 PR 的目的和内容。

## ✨ 新增功能

- [ ] 功能1
- [ ] 功能2

## 🐛 修复问题

- [ ] 问题1 (Closes #issue_number)
- [ ] 问题2

## 🧪 测试

- [ ] 添加了新的测试
- [ ] 所有测试通过
- [ ] 手动测试验证

## 📋 检查清单

- [ ] 代码遵循项目规范
- [ ] 自评代码审查
- [ ] 文档已更新
- [ ] 测试覆盖率未下降

## 📸 截图（如适用）

添加相关截图或 GIF。
```

### 代码审查流程

1. **自动检查**
   - CI 运行所有测试
   - 代码覆盖率检查
   - 格式检查

2. **人工审查**
   - 至少一名维护者审查
   - 检查代码质量、规范、测试
   - 提供反馈

3. **修改与重新提交**
   - 根据反馈修改代码
   - 重新运行测试
   - 回复审查意见

4. **合并**
   - 获得至少 1 个 approve
   - 所有检查通过
   - 维护者合并 PR

### PR 标题规范

使用与提交消息相同的格式：

```
feat(bee_admin): add user login endpoint
fix(bee_rpc): handle empty service list
docs: update installation guide
```

## 🚀 发布流程

### 版本号规范

我们使用 [Semantic Versioning](https://semver.org/) (SemVer)：

- **MAJOR**: 不兼容的 API 变更
- **MINOR**: 向后兼容的功能性变更
- **PATCH**: 向后兼容的问题修复

### 发布步骤

1. **准备发布**
   ```bash
   git checkout develop
   git pull upstream develop

   # 合并到 main
   git checkout main
   git merge develop
   ```

2. **更新版本号**
   ```elixir
   # 在各应用的 mix.exs 中
   version: "1.0.0"  # 更新版本号
   ```

3. **创建发布标签**
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push upstream v1.0.0
   ```

4. **更新 CHANGELOG**
   ```bash
   # 记录所有新功能和修复
   ```

5. **构建和部署**
   - CI 自动构建
   - 自动发布到 Hex (如果是库)

## 💬 获取帮助

如果您需要帮助或有疑问：

- **GitHub Issues**: 报告 Bug 或提出功能请求
- **GitHub Discussions**: 讨论问题、分享想法
- **邮件联系**: maintainer@beehiveex.org

## 🎉 致谢

感谢所有为 BeehiveEx 做出贡献的开发者和用户！

---

**再次感谢您的贡献！每一份力量都让 BeehiveEx 变得更好。** ❤️
