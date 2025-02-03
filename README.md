變更檔案日期
===

舊版連結
https://github.com/hunandy14/FileDateEditor/tree/master/old

## 快速使用

修改檔案日期
```ps1
irm bit.ly/4gkzM5D|iex; Get-Item 'test/file.txt' | Set-FileDate '2025-2-3'
```

查看檔案日期
```ps1
Get-Item 'test/file.txt' | Select-Object Name, CreationTime, LastWriteTime, LastAccessTime
```
