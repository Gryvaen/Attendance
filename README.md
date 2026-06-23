# Attendance

Attendance 是一个基于 WPF 的桌面端课堂点名与信息看板应用。项目集成了班级/学生管理、随机点名、Excel/CSV 学生导入、古诗文展示与搜索、天气时间信息、每日一言以及可切换主题背景等功能。

## 功能概览

- 班级管理：新增、重命名、删除班级，双击进入班级详情。
- 学生管理：新增、编辑、删除学生，保存学号、姓名、性别和所属班级。
- 批量导入：支持从 Excel 和 CSV 导入学生名单，自动识别表头。
- 随机点名：支持按抽取人数、性别、学号末尾数字过滤候选学生。
- 点名动画：单人、双人、三人抽取有独立动画，四到十人使用通用动画。
- 古诗文展示：随机展示诗词内容，支持刷新和鼠标悬停暂停滚动。
- 古诗文搜索：支持按诗词、作者、名句搜索，最多展示 50 条结果。
- 天气时间看板：展示系统时间、日期、星期、IP 定位城市、天气、空气质量、日出日落、月相、太阳高度角、天气预警和降水预报等。
- 每日内容：展示本地诗句库中的随机诗句，以及来自 Hitokoto 的每日一言。
- 主题背景：支持浅色/深色主题，也支持导入本地图片作为背景；各区域分割线可拖动调整。

## 技术栈

- .NET 8
- WPF
- SQLite
- Microsoft.Data.Sqlite
- SQLitePCLRaw
- ClosedXML
- Microsoft.Extensions.Configuration.Json
- Microsoft.Xaml.Behaviors.Wpf
- SharpVectors
- PP.Wpf

## 运行环境

开发和运行建议使用 Windows 环境：

- Windows 10/11
- .NET 8 SDK
- Visual Studio 2022 或 Rider，需安装 .NET 桌面开发相关工作负载
- 可访问外网时，天气、IP 定位、海拔和每日一言功能才能正常加载在线数据

## 快速开始

### 1. 克隆项目

```bash
git clone <repo-url>
cd Attendance
```

如果仓库使用了子模块或单独的数据包保存古诗文数据，请一并拉取：

```bash
git submodule update --init --recursive
```

### 2. 准备古诗文数据

诗词数据库会在应用首次启动时由 JSON 数据自动导入生成。项目代码期望数据位于：

```text
Attendance/Resources/chinese-gushiwen/
```

目录结构应包含：

```text
Attendance/Resources/chinese-gushiwen/
├── guwen/
│   ├── guwen0-1000.json
│   ├── guwen1001-2000.json
│   └── ...
├── sentence/
│   └── sentence1-10000.json
└── writer/
    ├── writer0-1000.json
    ├── writer1001-2000.json
    └── ...
```

古诗文数据来源：<https://github.com/caoxingyu/chinese-gushiwen>

如果该目录为空，应用仍可启动，但诗词展示、诗词搜索和每日诗句相关功能无法正常生成完整数据。

### 3. 配置天气 API

天气功能依赖和风天气：<https://www.qweather.com/>

配置文件位于：

```text
Attendance/appsettings.json
```

配置格式：

```json
{
  "WeatherApi": {
    "ApiHost": "https://your-qweather-api-host",
    "ApiKey": "your-api-key"
  }
}
```

建议使用自己的和风天气 API Host 与 Key。不要在公开仓库中提交真实生产密钥。

### 4. 还原依赖

```bash
dotnet restore Attendance.sln
```

### 5. 启动应用

```bash
dotnet run --project Attendance/Attendance.csproj
```

也可以用 Visual Studio 打开 `Attendance.sln`，将 `Attendance` 设为启动项目后运行。

## 发布打包

发布示例：

```bash
dotnet publish Attendance/Attendance.csproj -c Release -r win-x64 --self-contained false
```

发布产物通常位于：

```text
Attendance/bin/Release/net8.0-windows/win-x64/publish/
```

如需免安装 .NET 运行时，可以改为自包含发布：

```bash
dotnet publish Attendance/Attendance.csproj -c Release -r win-x64 --self-contained true
```

项目历史发布包地址：

<https://github.com/Gryvaen/Attendance/releases/tag/v1.0>

## 数据与配置文件

应用运行时会在程序输出目录下创建或读取以下文件：

```text
db/classes.db      # 班级与学生数据
db/poems.db        # 古诗文、作者、名句数据
user_theme.json    # 用户主题、前景色、背景图路径配置
appsettings.json   # 天气 API 配置
```

说明：

- `classes.db` 由班级初始化逻辑自动创建。
- `poems.db` 由 `Resources/chinese-gushiwen` 中的 JSON 数据首次导入生成。
- `user_theme.json` 会在用户切换主题或导入背景图后保存。
- 如果需要重建诗词数据库，可关闭程序后删除输出目录中的 `db/poems.db`，再重新启动应用。

## 学生导入格式

支持的文件格式：

- `.xlsx`
- `.xls`
- `.csv`

推荐表头：

| 学号 | 名字 | 性别 |
| --- | --- | --- |
| 1001 | 张三 | 男 |
| 1002 | 李四 | 女 |

导入规则：

- 表头顺序不限。
- 至少包含“名字”或“学号”相关表头时即可导入。
- 数据不完整时会使用默认值：
  - 学号：`0`
  - 名字：空字符串
  - 性别：`null`
- 不支持的文件扩展名会被拒绝导入。

## 点名规则

点名设置支持：

- 抽取人数
- 性别偏好：全部、男、女
- 学号末尾数字：0 到 9，或不限制

切换班级后，点名设置会重置为默认值：

- 性别：全部
- 学号末尾数字：不限制

## 古诗文系统

古诗文系统分为展示和搜索两部分。

展示模块：

- 从本地 SQLite 诗词库随机展示诗词。
- 支持刷新。
- 鼠标悬停时暂停滚动。

搜索模块：

- 诗词搜索：从标题和内容中匹配。
- 作者搜索：从作者姓名和简介中匹配。
- 名句搜索：从名句内容和来源中匹配。
- 每次最多返回 50 条结果。

## 天气与每日内容

天气模块会调用多个在线服务：

- `ip-api.com`：根据 IP 获取经纬度。
- 和风天气：获取城市、实时天气、空气质量、预警、月相、日出日落和降水等数据。
- `api.open-elevation.com`：根据经纬度获取海拔。

每日内容模块：

- 每日诗句来自本地 `poems.db` 的 `Sentences` 表。
- 每日一言来自 <https://v1.hitokoto.cn/>

如果网络不可用或 API 配置不正确，相关区域会显示加载失败信息，但不会影响班级和点名等本地功能。

## 项目结构

```text
.
├── Attendance.sln
├── README.md
├── LICENSE.txt
└── Attendance/
    ├── Attendance.csproj
    ├── App.xaml
    ├── appsettings.json
    ├── Animation/          # 点名动画
    ├── Behaviors/          # WPF 行为
    ├── Classes/            # 班级、学生和 SQLite 存储
    ├── Converters/         # XAML 绑定转换器
    ├── DailyWord/          # 每日诗词、每日一言
    ├── Importer/           # Excel/CSV 导入
    ├── Poems/              # 古诗文数据库初始化和模型
    ├── PoemsSearch/        # 古诗文搜索
    ├── Resources/          # 图片、图标、古诗文数据目录
    ├── Theme/              # 主题与用户背景配置
    ├── Utils/              # ObservableObject、RelayCommand 等工具类
    ├── View/               # 主窗口、班级详情、编辑窗口、设置窗口
    └── weather/            # 天气卡片和天气数据模型
```

## 界面预览

### 点名设置

<img width="2559" height="1364" alt="点名设置" src="https://github.com/user-attachments/assets/6cd3c628-5c83-45fd-90ca-6c22dbe67247" />

### 诗词展示

<img width="655" height="521" alt="诗词展示" src="https://github.com/user-attachments/assets/b80b125c-91c3-4dbe-b1a8-93af659fcd4c" />

### 诗词搜索

<img width="896" height="461" alt="诗词搜索" src="https://github.com/user-attachments/assets/64c08427-fff2-41e7-a36e-3d381c9036f2" />

### 天气看板

<img width="654" height="1294" alt="天气看板" src="https://github.com/user-attachments/assets/75b9d01f-b785-4a8f-b0d4-a8dcb2f0485e" />

<img width="897" height="850" alt="天气详情" src="https://github.com/user-attachments/assets/4d554921-d9eb-482d-8efe-3f5db7a7b2d9" />

### 每日一言

<img width="713" height="522" alt="每日一言" src="https://github.com/user-attachments/assets/257e31cd-516d-46ee-be97-0133d00e5f89" />

### 整体一览

<img width="2559" height="1367" alt="整体一览" src="https://github.com/user-attachments/assets/cab68279-517f-4c39-bc17-5a8cd7e2a2ee" />

## 常见问题

### 启动后诗词为空或导入失败

检查 `Attendance/Resources/chinese-gushiwen` 下是否存在 `guwen`、`writer`、`sentence` 数据目录，以及对应 JSON 文件是否被复制到输出目录。

### 天气显示加载失败

检查：

- `Attendance/appsettings.json` 中的 `WeatherApi:ApiHost` 和 `WeatherApi:ApiKey` 是否有效。
- 当前网络是否可以访问和风天气、`ip-api.com` 和 `api.open-elevation.com`。
- 和风天气账号是否开通了对应 API。

### 导入 Excel 或 CSV 失败

检查：

- 文件扩展名是否为 `.xlsx`、`.xls` 或 `.csv`。
- 表头是否包含“学号”“名字”“性别”中的有效字段。
- 文件是否被其他程序占用。

### 背景图不显示

背景图路径保存在输出目录的 `user_theme.json` 中。如果图片被移动或删除，应用会无法加载原背景图，需要重新导入。

## 许可证

本项目许可证见 [LICENSE.txt](LICENSE.txt)。
