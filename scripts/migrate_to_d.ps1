# migrate_to_d.ps1 - 把C盘大文件迁移到D盘，自动创建分类目录
# 用法: powershell -ExecutionPolicy Bypass -File migrate_to_d.ps1 -SourcePath "C:\path\to\folder" -Category "桌面文件"
param(
  [Parameter(Mandatory=$true)]
  [string]$SourcePath,
  [Parameter(Mandatory=$true)]
  [ValidateSet("我的文档", "桌面文件", "AI模型", "应用资源", "其他")]
  [string]$Category
)

$ErrorActionPreference = "Stop"

# 创建D盘根目录和分类目录
$dBase = "D:\C盘迁移"
New-Item -ItemType Directory -Path "$dBase\$Category" -Force | Out-Null

Write-Output "=== 开始迁移文件 ==="
Write-Output "源路径: $SourcePath"
Write-Output "目标路径: $dBase\$Category\"

# 检查源路径是否存在
if (-not (Test-Path $SourcePath)) {
  Write-Output "错误: 源路径不存在"
  exit 1
}

# 获取源文件大小
$sourceSize = (Get-ChildItem $SourcePath -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
Write-Output ("源文件总大小: {0} GB" -f [math]::Round($sourceSize/1GB,2))

# 执行迁移
Write-Output "正在迁移，请稍等..."
Move-Item -Path $SourcePath -Destination "$dBase\$Category\" -Force -ErrorAction Continue

# 检查目标路径
$destPath = Join-Path "$dBase\$Category" (Split-Path $SourcePath -Leaf)
if (Test-Path $destPath) {
  Write-Output "`n✅ 迁移完成！"
  Write-Output "文件已保存到: $destPath"
  Write-Output "释放C盘空间: $([math]::Round($sourceSize/1GB,2)) GB"
} else {
  Write-Output "`n⚠️ 迁移可能未完全成功，请检查目标路径"
}

# 显示当前C盘剩余空间
$cFree = (Get-PSDrive C).Free
Write-Output ("`n当前C盘剩余空间: {0} GB" -f [math]::Round($cFree/1GB,1))
