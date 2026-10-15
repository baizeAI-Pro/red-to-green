# 🧹 c-disk-cleaner - Windows C盘空间急救工具

一键释放C盘30-60GB空间，专治"C盘红了"、"磁盘空间不足"，扫描+清理+迁移+长期预防全流程自动化。

---

## ✨ 效果展示

| 指标 | 清理前 | 清理后 |
|------|--------|--------|
| C盘可用空间 | 22.4 GB | 86 GB |
| 总释放空间 | - | **60+ GB** |
| 耗时 | - | 5分钟 |

![效果对比](https://cdn.jsdelivr.net/gh/baizeAI-Pro/red-to-green@main/docs/images/comparison.png)

---

## 🚀 解决什么问题？

很多Windows用户都遇到过：
- C盘突然红了，提示"磁盘空间不足"
- 翻遍了桌面、文档、下载，没发现什么大文件
- 回收站攒了几十GB不知道
- 微信、飞书、浏览器偷偷往C盘写缓存
- 每次清理完过两个月又满了

**c-disk-cleaner 就是为了解决这些问题而生的。**

---

## 📦 项目结构

```
c-disk-cleaner/
├── SKILL.md                # Agent技能描述文件
├── scripts/
│   ├── scan_disk.ps1       # 🔍 只读扫描：找出C盘空间大头
│   ├── clean_disk.ps1      # 🧹 安全清理：自动删缓存、临时文件
│   └── migrate_to_d.ps1    # 📁 文件迁移：自动分类把C盘大文件移到D盘
├── references/
│   └── methodology.md      # 完整方法论和踩坑指南
└── README.md
```

---

## 🛠️ 使用方法

### 方式一：作为Agent Skill使用（推荐）
把整个文件夹放到你的Agent skills目录下，当你说"C盘满了"，Agent会自动调用这个Skill完成全流程：
1. 自动扫描C盘空间占用，出清理方案
2. 你确认后自动清理安全缓存
3. 需要的话自动把大文件迁移到D盘，自动创建分类目录
4. 可选：自动配置缓存路径到D盘，一劳永逸

### 方式二：手动运行脚本
打开PowerShell，进入scripts目录：
```powershell
# 第一步：先扫描，看看空间被谁占了
.\scan_disk.ps1 -BigFiles

# 第二步：预演清理，看看能删多少（不真删）
.\clean_disk.ps1 -DryRun

# 第三步：实际清理（不加-IncludeRecycleBin就不清空回收站）
.\clean_disk.ps1

# 第四步：连回收站一起清（会清空所有回收站文件，不可恢复！）
.\clean_disk.ps1 -IncludeRecycleBin

# 第五步：迁移大文件到D盘
.\migrate_to_d.ps1 -SourcePath "C:\Users\你的用户名\Desktop\大文件夹" -Category "桌面文件"
```

---

## 🧠 核心原理

![工作流程](https://cdn.jsdelivr.net/gh/baizeAI-Pro/red-to-green@main/docs/images/workflow.png)

### 为什么C盘总是莫名其妙满了？
三个隐形空间杀手：
1. **回收站**：你以为删了的文件其实还在C盘，攒几个月就能有几十GB
2. **AppData软件缓存**：微信、飞书、浏览器、AI Agent的缓存都偷偷存在这里，用户看不到
3. **系统临时文件**：Windows默认把所有临时文件都存C盘，越攒越多

### 标准清理流程
1. **先扫描，不瞎删**：找出空间大头，再动手
2. **按优先级清理**：从最安全、释放最多的开始（回收站→临时文件→浏览器缓存→软件缓存）
3. **迁移大文件到D盘**：在D盘建分类目录，把个人大文件移过去
4. **长期预防**：把TEMP、npm、pip缓存路径改到D盘，以后再也不写满C盘

---

## ⚠️ 安全说明

- ✅ 所有清理操作严格分级，不会误删你的个人文件
- ✅ 只删可再生的缓存和临时文件，不碰系统核心文件
- ✅ 迁移文件自动分类，不会乱
- ⚠️ 清空回收站会永久删除文件，脚本会明确提示
- ❌ 永远不会碰 System32、WinSxS 等系统目录

---

## 📋 D盘迁移分类模板
```
D:\C盘迁移\
├── 我的文档\      # 项目、资料
├── 桌面文件\      # 桌面大文件、安装包、视频
├── AI模型\        # 大模型、数据集
├── 应用资源\      # 工具资源、素材
└── 回收站文件\    # 从回收站救出来的重要文件
```

---

## 🤝 贡献
欢迎提Issue和PR！如果你有更好的清理方法或者脚本，欢迎一起完善这个项目。

## 📄 License
MIT License，随便用，记得点个Star就行~
