變更檔案 建立日期 修改日期 存取日期
===

## 快速使用
修改
```ps1
irm bit.ly/FileDateEditor|iex; ChangeWriteTime 'Readme.md' '2022-12-27 01:31:24'
```

查看
```ps1
irm bit.ly/FileDateEditor|iex; ChangeWriteTime 'Readme.md'
```

<br><br>

## 變更修改日期
常用的選項拉出來增加便利性，不知道格式可以先用查看後複製格式。

```ps1
# 載入函式
irm bit.ly/FileDateEditor|iex

# 查看日期
irm bit.ly/FileDateEditor|iex; ChangeWriteTime "README.md"
irm bit.ly/FileDateEditor|iex; ChangeWriteTime "Test"

# 一次修改多個檔案
ChangeWriteTime Test\a.txt,Test\b.txt "1999-01-01 06:15:45" -Force

# 過濾資料夾檔案
ChangeWriteTime "Test" "1999-02-13 23:59:59" -Filter:@("*.txt","*.md") -Force

# 變更修改日期(指定簡易格式)
ChangeWriteTime "Readme.md" "1999-02-13 23:59:59" -Simple

# 變更修改日期 (通用兩種日期格式)
ChangeWriteTime "Test" "2022/02/01 下午 00:00:00"
ChangeWriteTime "Test" "2022-02-01 24:00:00"

# 變更所有日期 (通用日文與中文格式)
ChangeWriteTime "Readme.md" "2022-02-01 上午 00:00:00" -AllDate
ChangeWriteTime "Readme.md" "2022-02-01 午前 00:00:00" -AllDate

# 變更指定日期
ChangeWriteTime .\README.md '2022-02-01 12:00:00' -CreationTime
ChangeWriteTime .\README.md '2022-12-23 22:11:02' -LastWriteTime
ChangeWriteTime .\README.md '2022-12-27 12:53:09' -LastAccessTime
```

<br><br>

## 變更日期
這個是完整的功能，日期與讀檔案要自己處理

```ps1
# 日期
$Date = New-DateTime "2022-02-13 21:00:00" -Simple
# 讀取檔案
$File = Get-Item ".\README.md"
$File = Get-ChildItem "Test" -Recurse

# 查看檔案日期
FileDateEditor $File

# 變更檔案修改日期(簡潔版)
FileDateEditor $File $Date

# 變更個別日期
FileDateEditor $File -CreationTime:$Date
FileDateEditor $File -LastWriteTime:$Date
FileDateEditor $File -LastAccessTime:$Date

# 變更 [建立、修改、存取] 日期
FileDateEditor $File -AllDate:$Date

# 變更 [修改、存取] 日期 (其他自己類推可任意組合)
FileDateEditor $File -LastAccessTime:$Date -LastWriteTime:$Date
```

<br><br>

## 日期解決方案
這個程式的API範例，推薦優先使用1，2和3是方便用的效能較差。

```ps1
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
