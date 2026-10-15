# scan_disk.ps1 - C盘空间扫描脚本（只读，不修改任何内容）
# 用法: powershell -ExecutionPolicy Bypass -File scan_disk.ps1
param([switch]$BigFiles)
$ErrorActionPreference = "SilentlyContinue"

function MB($bytes) { [math]::Round($bytes/1MB) }
function GB($bytes) { [math]::Round($bytes/1GB, 1) }
function DirSize($path) { if (Test-Path $path) { (Get-ChildItem $path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum } else { 0 } }

Write-Output "=== 磁盘空间概览 ==="
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
  Write-Output ("{0} 总 {1} GB / 剩余 {2} GB ({3}%)" -f $_.DeviceID, (GB $_.Size), (GB $_.FreeSpace), [math]::Round($_.FreeSpace/$_.Size*100))
}

Write-Output "`n=== C盘一级目录大小排行 ==="
Get-ChildItem C:\ -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
  $size = (Get-ChildItem $_.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
  [PSCustomObject]@{文件夹=$_.Name; 大小GB=(GB $size)}
} | Sort-Object 大小GB -Descending | Select-Object -First 10 | Format-Table -AutoSize

Write-Output "`n=== 用户目录 AppData 缓存占用Top 10 ==="
Get-ChildItem "$env:LOCALAPPDATA" -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
  $size = (Get-ChildItem $_.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
  [PSCustomObject]@{文件夹=$_.Name; 大小GB=(GB $size)}
} | Sort-Object 大小GB -Descending | Select-Object -First 10 | Format-Table -AutoSize

Write-Output "`n=== 可安全清理空间预估 ==="
$items = [ordered]@{
  "用户临时文件 %TEMP%"        = DirSize $env:TEMP
  "Windows更新缓存"            = DirSize "C:\Windows\SoftwareDistribution\Download"
  "Edge浏览器缓存"             = DirSize "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
  "Chrome浏览器缓存"           = DirSize "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
  "缩略图缓存"                 = (Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\Explorer" -Filter "thumbcache_*" | Measure-Object Length -Sum).Sum
  "系统日志"                   = DirSize "C:\Windows\Logs"
}
$total = 0
foreach ($k in $items.Keys) { $total += $items[$k]; Write-Output ("{0}: {1} MB" -f $k, (MB $items[$k])) }
Write-Output ("--- 合计安全可清理: {0} GB ---" -f (GB $total))

$rb = (New-Object -ComObject Shell.Application).NameSpace(0xA).Items() | Measure-Object -Property Size -Sum
Write-Output ("`n回收站大小: {0} GB (需用户确认后清空)" -f (GB $rb.Sum))

if ($BigFiles) {
  Write-Output "`n=== 用户目录大文件 >500MB (仅报告，不删除) ==="
  foreach ($d in @("$env:USERPROFILE\Downloads","$env:USERPROFILE\Desktop","$env:USERPROFILE\Documents","$env:USERPROFILE\Videos")) {
    Get-ChildItem $d -Recurse -File -ErrorAction SilentlyContinue | Where-Object Length -gt 500MB |
      Sort-Object Length -Descending | Select-Object -First 20 |
      ForEach-Object { Write-Output ("{0} MB`t{1}" -f (MB $_.Length), $_.FullName) }
  }
}

Write-Output "`n扫描完成（未做任何修改）"
