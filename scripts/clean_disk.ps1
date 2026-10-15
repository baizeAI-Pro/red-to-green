# clean_disk.ps1 - 安全清理C盘垃圾缓存
# 用法:
#   预演(只看删多少不真删): powershell -ExecutionPolicy Bypass -File clean_disk.ps1 -DryRun
#   实际清理: powershell -ExecutionPolicy Bypass -File clean_disk.ps1
#   连回收站一起清: powershell -ExecutionPolicy Bypass -File clean_disk.ps1 -IncludeRecycleBin
param(
  [switch]$DryRun,
  [switch]$IncludeRecycleBin
)
$ErrorActionPreference = "SilentlyContinue"
$freed = 0

function CleanDir($label, $path) {
  if (-not (Test-Path $path)) { return }
  $size = (Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
  if (-not $size) { $size = 0 }
  if ($DryRun) {
    Write-Output "[预演] $label : 可清理 $([math]::Round($size/1MB)) MB"
  } else {
    Get-ChildItem $path -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    $after = (Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    if (-not $after) { $after = 0 }
    $delta = $size - $after
    $script:freed += $delta
    Write-Output "[完成] $label : 释放 $([math]::Round($delta/1MB)) MB"
  }
}

Write-Output "=== C盘清理开始 $(if($DryRun){'(预演模式)'}) ==="
$before = (Get-PSDrive C).Free

# 清理临时文件
CleanDir "用户临时文件" $env:TEMP
CleanDir "系统临时文件" "C:\Windows\Temp"

# Windows更新缓存
$wuWasRunning = (Get-Service wuauserv).Status -eq "Running"
if (-not $DryRun) { Stop-Service wuauserv -Force }
CleanDir "Windows更新缓存" "C:\Windows\SoftwareDistribution\Download"
if (-not $DryRun -and $wuWasRunning) { Start-Service wuauserv }

# 浏览器缓存
CleanDir "Edge浏览器缓存" "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
CleanDir "Chrome浏览器缓存" "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"

# 系统日志和转储
CleanDir "系统日志" "C:\Windows\Logs"
CleanDir "错误报告WER" "$env:ProgramData\Microsoft\Windows\WER"

# 缩略图缓存
$thumbDir = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
$tsize = (Get-ChildItem $thumbDir -Filter "thumbcache_*" | Measure-Object Length -Sum).Sum
if (-not $DryRun) {
  Get-ChildItem $thumbDir -Filter "thumbcache_*" | Remove-Item -Force
  $tafter = (Get-ChildItem $thumbDir -Filter "thumbcache_*" | Measure-Object Length -Sum).Sum
  $freed += ($tsize - $tafter)
}

# 回收站
if ($IncludeRecycleBin) {
  if ($DryRun) {
    $rb = (New-Object -ComObject Shell.Application).NameSpace(0xA).Items() | Measure-Object Size -Sum
    Write-Output "[预演] 回收站: 可清空 $([math]::Round($rb.Sum/1GB,1)) GB"
  } else {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Output "[完成] 回收站已清空"
  }
}

if (-not $DryRun) {
  $after = (Get-PSDrive C).Free
  Write-Output "`n=== 清理完成 ==="
  Write-Output "总释放空间: $([math]::Round($freed/1GB,2)) GB"
  Write-Output "C盘剩余: $([math]::Round($before/1GB,1)) GB → $([math]::Round($after/1GB,1)) GB"
  Write-Output "未触碰: 个人文件、已安装软件、系统文件"
}
