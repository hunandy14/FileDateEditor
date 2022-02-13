修改檔案期限
===

## 變更修改日期
把最常用的選項拉出來減少輸入，比較方便。

```
# 查看日期(目錄或單一檔案都可以)
irm bit.ly/34DB0Kb|iex; ChangeWriteTime "Test"

# 變更修改日期(台灣)
irm bit.ly/34DB0Kb|iex; ChangeWriteTime "Test" -Date:"2022/2/1 上午 00:00:00"

# 變更修改日期(日本)
irm bit.ly/34DB0Kb|iex; ChangeWriteTime "Test" -Date:"2022/2/1 午前 00:00:00"
```

## 變更日期
這個是完整的功能，日期與讀檔案要自己處理

```
# 日期
$Date = New-DateTime "2022-02-13 21:00:00" -Simple
# 讀取檔案
$File = Get-Item ".\README.md"
$File = Get-ChildItem "Test" -Recurse

# 查看檔案日期
# FileDateEditor $File

# 變更檔案修改日期(簡潔版)
FileDateEditor $File $Date

# 變更個別日期
FileDateEditor $File -CreationTime:$Date -Preview
FileDateEditor $File -LastWriteTime:$Date -Preview
FileDateEditor $File -LastAccessTime:$Date -Preview

# 變更 [建立、修改、存取] 日期
# FileDateEditor $File -AllDate:$Date -Preview

# 變更 [修改、存取] 日期 (其他自己類推可任意組合)
# FileDateEditor $File -LastAccessTime:$Date -LastWriteTime:$Date -Preview
```

## 日期解決方案
這個程式的API範例，推薦優先使用1，2和3是方便用的效能較差。

```
# 日期1
New-DateTime "2022-02-13 21:00:00" -Simple
New-DateTime "1999-05-12 12:00:00" "yyyy-MM-dd HH:mm:ss"

# 日期2
New-DateTime "1999/02/13 午前 04:15:45" -JP
New-DateTime "2022年02月13日 午前 04:55:55" -JP
New-DateTime "2022年02月13日, 午前 04:55:55" -JP
New-DateTime "1999/02/13 上午 04:15:45" -TW
New-DateTime "1999年02月13日 上午 04:15:45" -TW
New-DateTime "1999年02月13日, 上午 04:15:45" -TW

# 日期3 - 可以省掉後面國家自動偵測當前系統格式
New-DateTime "1999/02/13 午前 04:15:45"
New-DateTime "1999年02月13日 午前 04:15:45"
New-DateTime "1999年02月13日, 午前 04:15:45"
New-DateTime "1999/02/13 上午 04:15:45"
New-DateTime "1999年02月13日 上午 04:15:45"
New-DateTime "1999年02月13日, 上午 04:15:45"
```