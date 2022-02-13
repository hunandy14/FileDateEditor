# 建立日期格式
function New-DateTime {
    [CmdletBinding(DefaultParameterSetName = "FormatType")]
    param (
        [Parameter(Position = 0, ParameterSetName = "FormatType")]
        [Parameter(Position = 0, ParameterSetName = "Simple")]
        [Parameter(Position = 0, ParameterSetName = "JP")]
        [Parameter(Position = 0, ParameterSetName = "TW")]
        [string] $DateStr,
        [Parameter(Position = 1, ParameterSetName = "FormatType")]
        [string] $FormatType,
        [Parameter(ParameterSetName = "Simple")]
        [switch] $Simple,
        [Parameter(ParameterSetName = "JP")]
        [switch] $JP,
        [Parameter(ParameterSetName = "TW")]
        [switch] $TW
    )
    # 格式化日期
    if ($DateStr) {
        if ($FormatType) {                # 自訂格式
        }elseif ($Simple) {               # 轉換簡易格式
            $FormatType = "yyyy-MM-dd HH:mm:ss"
        } elseif ($JP) {                 # 轉換日本時間格式
            $FormatType = "yyyy/MM/dd tt hh:mm:ss"
            $DateStr = $DateStr -replace("午前", "AM")-replace("午後", "PM")
        } elseif($TW) {                 # 轉換台灣時間格式
            $FormatType = "yyyy/MM/dd tt hh:mm:ss"
            $DateStr = $DateStr -replace("上午", "AM")-replace("下午", "PM")
        } else {                        # 預設系統當前格式
            $Sys = ([cultureinfo]::CurrentCulture.DateTimeFormat)
            $FormatType = $Sys.ShortDatePattern + " " + $Sys.LongTimePattern
            $DateStr = $DateStr -replace($Sys.AMDesignator, "AM")-replace($Sys.PMDesignator, "PM")
        }
        # 建立日期物件
        try { $Date = [DateTime]::ParseExact( $DateStr, $FormatType, [CultureInfo]::InvariantCulture ) }
        catch { Write-Error "時間格式錯誤::輸入的字串 [$DateStr] 與當前格式 [$FormatType] 不符" }
        return $Date
    } else { # 沒有輸入則回傳當前時間
        return Get-Date
    }
}
# New-DateTime
# New-DateTime "1999/02/13 午前 04:15:45"
# New-DateTime "1999-05-12 12:00:00" "yyyy-MM-dd HH:mm:ss"
# New-DateTime "1999-05-12 12:00:00" -Simple
# New-DateTime "1999/02/13 午前 04:15:45" -JP
# New-DateTime "1999/02/13 上午 04:15:45" -TW
# return


# 獲取檔案日期
function FileDatePrinter {
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory=$true)]
        [System.Object] $Files
    )
    # $Files|Select-Object Name,CreationTime,LastWriteTime,LastAccessTime
    if (!($Files -is [array])) { $Files = @($Files) }
    for ($i = 0; $i -lt $Files.Count; $i++) {
        $File = $Files[$i]
        Write-Host "[$($i+1)]" $File.FullName -ForegroundColor:Yellow
        Write-Host "  建立日期::" -NoNewline
        Write-Host $File.CreationTime    -ForegroundColor:Cyan -NoNewline
        Write-Host "  修改日期::" -NoNewline
        Write-Host $File.LastWriteTime   -ForegroundColor:Cyan -NoNewline
        Write-Host "  存取日期::" -NoNewline
        Write-Host $File.LastAccessTime  -ForegroundColor:Cyan
    }
    Write-Host
}
# $Date = New-DateTime "2022/02/13 午前 04:55:55" -JP
# $File = Get-Item ".\README.md"
# $File = Get-ChildItem "Test" -Recurse
# FileDatePrinter $File
# FileDatePrinter (Get-ChildItem "Test" -Recurse)
# return

# 修改檔案日期
function FileDateEditor {
    [CmdletBinding(DefaultParameterSetName = "Time")]
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory=$true)]
        [System.Object] $Files,
        [Parameter(ParameterSetName = "AllDate")]
        [DateTime] $AllDate,
        [Parameter(ParameterSetName = "Time")]
        [DateTime] $CreationTime,
        [Parameter(Position = 1, ParameterSetName = "Time")]
        [DateTime] $LastAccessTime,
        [Parameter(ParameterSetName = "Time")]
        [DateTime] $LastWriteTime,
        [Parameter(ParameterSetName = "")]
        [switch] $Preview
    )

    if (($null -eq $LastAccessTime) -and
        ($null -eq $LastWriteTime) -and
        ($null -eq $CreationTime) -and
        ($null -eq $AllDate))
    {   # 檢視模式
        FileDatePrinter $Files
    } else {
        # 一次修改全部
        if ($AllDate) {
            $CreationTime = $AllDate
            $LastWriteTime = $AllDate
            $LastAccessTime = $AllDate
        }
        # 修改日期
        if (!($Files -is [array])) { $Files = @($Files) }
        for ($i = 0; $i -lt $Files.Count; $i++) {
            $File = $Files[$i]
            Write-Host "[$($i+1)]" $File.FullName -ForegroundColor:Yellow
            Write-Host "  " $File.CreationTime   "--> " -NoNewline
            Write-Host $CreationTime -ForegroundColor:DarkBlue
            Write-Host "  " $File.LastWriteTime  "--> " -NoNewline
            Write-Host $LastWriteTime -ForegroundColor:DarkBlue
            Write-Host "  " $File.LastAccessTime "--> " -NoNewline
            Write-Host $LastAccessTime -ForegroundColor:DarkBlue
            # if (!$Preview) {
                if ($CreationTime  ) { $File.CreationTime   = $CreationTime   }
                if ($LastWriteTime ) { $File.LastWriteTime  = $LastWriteTime  }
                if ($LastAccessTime) { $File.LastAccessTime = $LastAccessTime }
            # }
        }
    }
}
# $Date = New-DateTime "2022/02/13 午前 00:00:00" -JP
# $File = Get-Item ".\README.md"
# $File = Get-ChildItem "Test" -Recurse
# FileDateEditor -File:$File -AllDate:$Date
#
# FileDateEditor -File:$File -AllDate:$Date -Preview
# FileDateEditor -File:$File -LastAccessTime:$Date -Preview
# FileDateEditor -File:$File $Date -Preview
# FileDateEditor -File:$File -Preview
#
# FileDateEditor -File:$File -CreationTime:$Date -Preview
# FileDateEditor -File:$File -LastAccessTime:$Date -Preview
# FileDateEditor -File:$File -LastAccessTime:$Date -Preview
# FileDateEditor -File:$File
#
# FileDateEditor -File:$File LastAccessTime:$Date -Preview
# FileDateEditor
# return

function ChangeWriteTime_JP {
    [CmdletBinding(DefaultParameterSetName = "Time")]
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory=$true)]
        [string] $Path,
        [Parameter(Position = 1, ParameterSetName = "Time")]
        [string] $Date,
        [Parameter(ParameterSetName = "")]
        [switch] $Preview
    )
    if (Test-Path $Path -PathType:Leaf) {
        $Files = @(Get-Item $Path)
    } elseif (Test-Path $Path -PathType:Container) {
        $Files = Get-ChildItem $Path -Recurse
    }

    if ($Date -eq "") {
        FileDateEditor $Files
    } else {
        $Date2  = New-DateTime $Date -JP
        FileDateEditor $Files -LastWriteTime:$Date2 -LastAccessTime:$Date2 -Preview:$Preview
    }
}
# ChangeWriteTime_JP -Path:"README.md"
# ChangeWriteTime_JP -Path:"Test"
# ChangeWriteTime_JP -Path:"Test" -Date:"2022/02/01 午前 05:00:00"