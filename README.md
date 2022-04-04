變更檔案 建立日期 修改日期 存取日期
===

## 變更修改日期
把最常用的選項拉出來減少輸入，比較方便。
先用查看日期然後直接複製回傳的時間格式，貼在同一個指令後方修改日期期可。

```ps1
# 載入函式
irm bit.ly/34DB0Kb|iex

# 查看日期
irm bit.ly/34DB0Kb|iex; ChangeWriteTime "README.md"
irm bit.ly/34DB0Kb|iex; ChangeWriteTime "Test"

# 過濾資料夾檔案
ChangeWriteTime "Test" "1999-02-13 23:59:59" -Simple -Filter:@("*.txt","*.md") -Force

# 變更修改日期(通用格式)
ChangeWriteTime "Readme.md" "1999-02-13 23:59:59" -Simple

# 變更修改日期(繁體中文)
ChangeWriteTime "Test" "2022/02/01 上午 00:00:00"

# 變更修改日期(日文)
ChangeWriteTime "Test" "2022/02/01 午前 00:00:00"

# 變更所有日期
ChangeWriteTime "Readme.md" "2022/02/01 上午 00:00:00" -AllDate
```

## 變更日期
這個是完整的功能，日期與讀檔案要自己處理

```ps1
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
FileDateEditor $File -CreationTime:$Date
FileDateEditor $File -LastWriteTime:$Date
FileDateEditor $File -LastAccessTime:$Date

# 變更 [建立、修改、存取] 日期
# FileDateEditor $File -AllDate:$Date

# 變更 [修改、存取] 日期 (其他自己類推可任意組合)
# FileDateEditor $File -LastAccessTime:$Date -LastWriteTime:$Date
```

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