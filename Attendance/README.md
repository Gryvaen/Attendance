# Attendance 子项目

这是 WPF 应用源码目录。完整项目说明、运行方式、配置项、数据准备、功能介绍和常见问题请查看根目录文档：

[../README.md](../README.md)

常用入口：

- 项目文件：`Attendance.csproj`
- 应用入口：`App.xaml`、`App.xaml.cs`
- 主窗口：`View/MainWindow.xaml`
- 配置文件：`appsettings.json`
- 运行时数据目录：输出目录下的 `db/`


### 本地天气凭据与发布

仓库中的 `appsettings.json` 只保留占位配置。请在 `Attendance/appsettings.local.json` 中填写自己的 `WeatherApi.ApiHost` 和 `WeatherApi.ApiKey`；该文件被 Git 忽略，并覆盖默认配置。不要提交真实密钥或学生数据库。

本地配置会复制到开发构建输出，发布时不会复制。不要分发本地 `bin/` 目录；对外发布请使用 `dotnet publish` 的输出，并检查其中没有 `appsettings.local.json`。已公开过的密钥必须在服务商后台撤销或轮换，删除提交不能使它失效。
