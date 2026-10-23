# 高情商回复键盘（ReplyKey）

一个只给自己用的 iOS 键盘：**复制对方的消息 → 切到这个键盘 → 点一下 → 出 3 条 AI 回复 → 点一条直接上屏。**

不用 Mac、不用交 99 美元、不用上架 App Store。代码在云端编译，在你的 Windows 电脑上用 Sideloadly 签名装进 iPhone。

---

## 它到底是怎么工作的

```
微信里长按消息 → 复制
        ↓
切到「高情商回复」键盘
        ↓
点「高情商回复」按钮
        ↓
键盘读剪贴板 → 请求大模型 → 拿回 3 条候选
        ↓
点一条 → 直接插入输入框
```

注意事项（先说清楚，免得以为是 bug）：

- 键盘是**整块替换**系统键盘的，iOS 不允许「悬浮在系统键盘上」。中文打字还是用苹果键盘，需要回话时按地球键切过来。
- 必须开**「允许完全访问」**，否则键盘不能联网、不能读剪贴板。
- 第一次读剪贴板，iOS 可能弹一次**「允许粘贴」**，点允许就行。
- 密码框、锁屏密码这类输入框，系统会强制切回苹果键盘，绕不过。

---

## 你需要准备

| 东西 | 说明 | 花钱吗 |
|---|---|---|
| Windows 电脑 | 你已经有 | 否 |
| iPhone | iOS 16 以上 | 否 |
| Apple ID | 平时下载 App 那个就行 | 否 |
| GitHub 账号 | 用来云端编译 | 否 |
| AI 接口 Key | 推荐 DeepSeek | 充值 10 元够用很久 |

---

# 第一部分：把代码送到 GitHub

> 只做一次，大约 20 分钟。

## 1. 装 Git

去 https://git-scm.com/download/win 下载，一路 Next 装完。

装完在开始菜单搜 `Git Bash` 打开，输入：

```bash
git --version
```

能显示版本号就行。

## 2. 注册 GitHub

https://github.com/signup

## 3. 建仓库

右上角 **+** → **New repository**：

- Repository name：`ReplyKey`
- 选 **Public**（重要：Public 仓库的 macOS 编译额度才免费无限）
- 不要勾 Add a README
- 点 **Create repository**

> 代码会公开可见。API Key 不会——它走 Secrets，只在编译产物里，不会出现在仓库文件里。

## 4. 上传代码

打开 **Git Bash**，一条条执行（把 `<你的用户名>` 换成你的 GitHub 用户名）：

```bash
cd /c/Users/ck176/replykey
git init
git add .
git commit -m "init"
git branch -M main
git remote add origin https://github.com/<你的用户名>/ReplyKey.git
git push -u origin main
```

第一次 push 会弹出浏览器让你登录 GitHub，登录授权即可。

> 如果 `git add .` 之后发现 `.github` 没进去，检查一下是不是被 `.gitignore` 挡了——本项目的 `.gitignore` 没有排除它，正常应该能进去。用 `git status` 确认一下。

## 5. 申请 AI Key

以 DeepSeek 为例：

1. 打开 https://platform.deepseek.com
2. 注册 → 实名 → 充值 10 元
3. 左侧 **API keys** → **创建 API key**
4. 复制那串 `sk-...`（只显示一次，先存记事本）

> 用别家也行，只要兼容 OpenAI 接口格式即可，见文末「换模型」。

## 6. 配 Secret

回到 GitHub 仓库页面：

**Settings** → 左侧 **Secrets and variables** → **Actions**

点 **New repository secret**：

- Name：`API_KEY`
- Secret：粘贴你的 `sk-...`

点 **Add secret**。

（可选，不改就用默认值）切到 **Variables** 标签页，可以加：

| Name | Value |
|---|---|
| `API_BASE_URL` | `https://api.deepseek.com` |
| `MODEL` | `deepseek-chat` |

## 7. 编译

仓库顶部 **Actions** → 左侧 **Build IPA** → 右侧 **Run workflow** → 绿色按钮。

等 5 分钟左右，看到绿勾。点进那次运行，页面最下方 **Artifacts** → 下载 `ReplyKey-ipa.zip`。

解压得到 `ReplyKey.ipa`。

> 第一次 90% 会失败。失败了就点进失败的那一步，把红色报错整段复制给我，我来改。

---

# 第二部分：装进 iPhone

> 大约 20 分钟。

## 8. 装两个 Windows 软件

1. **Apple Devices**（微软商店搜）或 iTunes——给 Windows 提供 iPhone 驱动。装了才能连上手机。
2. **Sideloadly**：https://sideloadly.io 下载 Windows 版。

## 9. 打开开发者模式

iPhone 上：**设置 → 隐私与安全性 → 开发者模式 → 打开 → 重启 → 确认**。

> 如果找不到这一项，先做第 10 步装一次，装完这一项就会出现。

## 10. 签名安装

1. iPhone 用数据线连电脑，手机上点「信任」
2. 打开 Sideloadly
3. 把 `ReplyKey.ipa` 拖进窗口
4. **Apple ID** 填你的 Apple ID
5. 点 **Start**
6. 弹出框里输入 Apple ID 密码，可能要双重认证验证码
7. 等它跑完

## 11. 信任证书

iPhone：**设置 → 通用 → VPN与设备管理 → 开发者APP → 你的 Apple ID → 信任**

## 12. 启用键盘

1. **设置 → 通用 → 键盘 → 键盘 → 添加新键盘 → 高情商回复**
2. 点进列表里的「高情商回复」
3. 把 **允许完全访问** 打开（必须）

## 13. 用起来

微信里长按对方消息 → **复制** → 点输入框 → **长按地球键** 切到「高情商回复」→ 点 **高情商回复** → 点一条候选。

---

# 每周维护（免费签名的代价）

免费 Apple ID 签名的 App **7 天后失效**，键盘会突然打不开。

续命方法：手机连电脑 → 打开 Sideloadly → 把同一个 `ReplyKey.ipa` 拖进去 → Start → 覆盖安装。不用重新配置，数据都还在。

嫌烦的话，交 99 美元/年 加入 Apple Developer Program，签名有效期变成 1 年。

---

# 出问题了

| 现象 | 原因 / 处理 |
|---|---|
| Actions 红了 | 把失败步骤的红色日志复制给我 |
| 提示找不到 `macos-15` 运行器 | 把 `.github/workflows/build.yml` 第 8 行改成 `runs-on: macos-latest` |
| Sideloadly 报 "bundle identifier 不可用" | 把 `project.yml` 里两处 `com.replykey.` 改成 `com.你的名字拼音.replykey.`，重新提交 |
| 键盘列表里没有「高情商回复」 | 重启手机；或 Sideloadly 没把扩展签进去（把 Sideloadly 的日志给我） |
| 点了按钮提示「还没配置 API Key」 | Secret 名字必须是 `API_KEY`，改完要重新跑一次 Actions |
| 点了按钮提示「连不上」 | 确认「允许完全访问」已开；确认手机能上网 |
| 接口返回 401 | Key 错了或余额不足 |
| 提示「未受信任的开发者」 | 回到第 11 步 |
| 键盘一闪就退回 | 多半是签名/内存问题，把 Sideloadly 日志和 iPhone 的「设置 → 隐私与安全性 → 分析与改进 → 分析数据」里带 App 名字的崩溃日志给我 |

---

# 想改什么，改哪里

| 想改 | 位置 |
|---|---|
| 回复的风格、条数、语气 | `Shared/AppConfig.swift` 里的 `systemPrompt` |
| 键盘高度 | `Keyboard/KeyboardViewController.swift` 里的 `292` |
| 颜色、按钮文案 | `Keyboard/KeyboardView.swift` |
| 换成别家模型 | 仓库 Variables 里的 `API_BASE_URL` / `MODEL`，不用改代码 |

换模型的填法：

| 服务商 | API_BASE_URL | MODEL |
|---|---|---|
| DeepSeek | `https://api.deepseek.com` | `deepseek-chat` |
| 阿里通义 | `https://dashscope.aliyuncs.com/compatible-mode/v1` | `qwen-plus` |
| 智谱 | `https://open.bigmodel.cn/api/paas/v4` | `glm-4-flash` |
| Kimi | `https://api.moonshot.cn/v1` | `moonshot-v1-8k` |
| OpenAI | `https://api.openai.com/v1` | `gpt-4o-mini` |

---

# 下一步可以加什么

- 本地固定话术库（不联网也能用，按「哄人 / 拒绝 / 道歉 / 暧昧」分类）
- 多套人设切换（对老板、对朋友、对对象，语气不一样）
- 候选条长按复制、点按插入
- 历史记录，看看哪些回复真的被用了
- 中文拼音输入（要内嵌 Rime 引擎，是另一个量级的工程）
