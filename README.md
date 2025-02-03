變更檔案日期
===

舊版連結
https://github.com/hunandy14/FileDateEditor/tree/master/old


<br><br>

## 快速使用

修改檔案日期 (修改日期)

```ps1
irm bit.ly/4gkzM5D|iex; Set-FileDate -File "test\file.txt" "2024-2-10"
```

<br>

查看檔案日期

```ps1
Get-Item 'test/file.txt' | Select-Object Name, CreationTime, LastWriteTime, LastAccessTime
```



<br><br><br>

詳細使用

```ps1
# 建立日期
Get-Item "test\file.txt" | Set-FileDate "2024-2-10" -Creation

# 修改日期
Get-Item "test\file.txt" | Set-FileDate "2024-2-10" -Write

# 存取日期
Get-Item "test\file.txt" | Set-FileDate "2024-2-10" -Access

# 全部
Get-Item "test\file.txt" | Set-FileDate "2024-2-10" -All

# 日期字串
Get-Item "test\file.txt" | Set-FileDate "2024-2-10" -DateString "2024-2-10"

# 日期字串
Get-Item "test\file.txt" | Set-FileDate "2024-2-10" -DateString "2024-2-10" -Format "yyyy-MM-dd"

```
