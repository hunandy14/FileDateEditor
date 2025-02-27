變更檔案日期
===

舊版連結
https://github.com/hunandy14/FileDateEditor/tree/master/old


<br><br>

## 快速使用

修改檔案日期 (修改日期)

```ps1
irm bit.ly/4gkzM5D|iex; Set-FileDate -File "test\file.txt" "2025-2-4"
```

<br>

查看檔案日期

```ps1
Get-Item 'test/file.txt' | Select-Object Name, CreationTime, LastWriteTime, LastAccessTime
```



<br><br><br>

## 詳細使用

```ps1
# 載入函式
irm bit.ly/4gkzM5D|iex;

# 建立日期
Get-Item "test\file.txt" | Set-FileDate "2025-2-4" -Creation

# 修改日期
Get-Item "test\file.txt" | Set-FileDate "2025-2-4" -Write

# 存取日期
Get-Item "test\file.txt" | Set-FileDate "2025-2-4" -Access

# 日期字串
Get-Item "test\file.txt" | Set-FileDate "2025-02-04" -Format "yyyy-MM-dd"

```

<br><br><br>

## 生成測試檔案

```ps1
irm bit.ly/4gkzM5D|iex; 1..10 | ForEach-Object{
  $idx=$_.ToString('00')
  New-Item -ItemType File -Path "file_2025-02-$idx.txt" |
  Set-FileDate "2025-02-$idx"
}
```
