#==================================================================================================
# 建立日期格式
#==================================================================================================
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
            $FormatType = "yyyy/M/d tt hh:mm:ss"
            $DateStr = $DateStr -replace("午前", "AM")-replace("午後", "PM")-replace("年|月", "/")-replace("日|,", "")
        } elseif($TW) {                 # 轉換台灣時間格式
            $FormatType = "yyyy/M/d tt hh:mm:ss"
            $DateStr = $DateStr -replace("上午", "AM")-replace("下午", "PM")-replace("年|月", "/")-replace("日|,", "")
        } else {                        # 預設系統當前格式 [ToString() 的格式]
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
# New-DateTime "1999-05-12 12:00:00" "yyyy-MM-dd HH:mm:ss"
# New-DateTime "1999-08-31 23:59:59" -Simple
#
# New-DateTime "1999/02/13 午前 04:15:45"
# New-DateTime "1999年02月13日 午前 04:15:45"
# New-DateTime "1999年02月13日, 午前 04:15:45"
# New-DateTime "1999/02/13 午前 04:15:45" -JP
# New-DateTime "2022年02月13日 午前 04:55:55" -JP
# New-DateTime "2022年02月13日, 午前 04:55:55" -JP
# New-DateTime "1999/02/13 上午 04:15:45" -TW
# New-DateTime "1999年02月13日 上午 04:15:45" -TW
# New-DateTime "1999年02月13日, 上午 04:15:45" -TW
# return

#==================================================================================================
# 獲取檔案日期
#==================================================================================================
function FileDatePrinter {
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory=$true)]
        [System.Object] $Files
    )
    if (!($Files -is [array])) { $Files = @($Files) }
    for ($i = 0; $i -lt $Files.Count; $i++) {
        $File = $Files[$i]
        # $CreationTime   = $File.CreationTime.ToLongDateString()   + " " + $File.CreationTime.ToLongTimeString()
        # $LastWriteTime  = $File.LastWriteTime.ToLongDateString()  + " " + $File.LastWriteTime.ToLongTimeString()
        # $LastAccessTime = $File.LastAccessTime.ToLongDateString() + " " + $File.LastAccessTime.ToLongTimeString()
        $CreationTime   = $File.CreationTime.ToString()
        $LastWriteTime  = $File.LastWriteTime.ToString()
        $LastAccessTime = $File.LastAccessTime.ToString()
        Write-Host "[$($i+1)]" $File.FullName -ForegroundColor:Yellow
        Write-Host "  建立日期::" -NoNewline
        Write-Host "'$CreationTime'"    -ForegroundColor:Cyan -NoNewline
        Write-Host "  修改日期::" -NoNewline
        Write-Host "'$LastWriteTime'"   -ForegroundColor:Cyan -NoNewline
        Write-Host "  存取日期::" -NoNewline
        Write-Host "'$LastAccessTime'"  -ForegroundColor:Cyan
    }
}
# FileDatePrinter (Get-ChildItem "Test" -Recurse)
# FileDatePrinter (Get-Item ".\README.md")
# return


#==================================================================================================
# 修改檔案日期
#==================================================================================================
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
        [DateTime] $LastWriteTime,
        [Parameter(ParameterSetName = "Time")]
        [DateTime] $LastAccessTime,
        [Parameter(ParameterSetName = "")]
        [switch] $Force,
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
        # 檔案是否為複數
        if (!($Files -is [array])) { $Files = @($Files); }
        if ($Files.Count -eq 1) { $Force=$true }
        # 警告
        if (!$Force -and !$Preview) {
            $response = Read-Host "  確認是否大量變更檔案日期。輸入[N]僅預覽而不變更。 (Y/N) "
            if (($response -ne "Y") -or ($response -ne "Y")) { $Preview = $true } else { $Preview = $false }
        }
        # 修改日期
        for ($i = 0; $i -lt $Files.Count; $i++) {
            $File = $Files[$i]
            Write-Host "[$($i+1)]" $File.FullName -ForegroundColor:Yellow -NoNewline
            if ($Preview) { Write-Host "::Preview"-ForegroundColor:Green } 
            else { Write-Host "::Writed"-ForegroundColor:Green }
                Write-Host "  " $File.CreationTime   "--> " -NoNewline
                Write-Host $CreationTime -ForegroundColor:Blue
                Write-Host "  " $File.LastWriteTime  "--> " -NoNewline
                Write-Host $LastWriteTime -ForegroundColor:Blue
                Write-Host "  " $File.LastAccessTime "--> " -NoNewline
                Write-Host $LastAccessTime -ForegroundColor:Blue
            if (!$Preview) {
                if ($CreationTime  ) { $File.CreationTime   = $CreationTime   }
                if ($LastWriteTime ) { $File.LastWriteTime  = $LastWriteTime  }
                if ($LastAccessTime) { $File.LastAccessTime = $LastAccessTime }
            }
        }
    }
}
# $Date = New-DateTime "2022-02-13 21:00:00" -Simple
# $File = Get-Item ".\README.md"
# $File = Get-ChildItem "Test" -Recurse
# FileDateEditor $File $Date -Force
# FileDateEditor $File $Date -Preview
#
# FileDateEditor $File -AllDate:$Date -Force
# FileDateEditor $File -LastAccessTime:$Date -LastWriteTime:$Date -Force
# FileDateEditor $File $Date -Force
# FileDateEditor $File -Force
#
# FileDateEditor $File -CreationTime:$Date -Force
# FileDateEditor $File -LastWriteTime:$Date -Force
# FileDateEditor $File -LastAccessTime:$Date -Force
# FileDateEditor $File
# return



#==================================================================================================
# 變更 修改日期
#==================================================================================================
function ChangeWriteTime {
    [CmdletBinding(DefaultParameterSetName = "Time")]
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory=$true)]
        [string] $Path,
        [Parameter(Position = 1, ParameterSetName = "Time")]
        [string] $Date,
        [Parameter(ParameterSetName = "")]
        [switch] $Simple,
        [Parameter(ParameterSetName = "")]
        [System.Object] $Filter,
        [Parameter(ParameterSetName = "")]
        [switch] $Force,
        [Parameter(ParameterSetName = "")]
        [switch] $Preview
    )
    if (Test-Path $Path -PathType:Leaf) {
        $Files = @(Get-Item $Path)
    } elseif (Test-Path $Path -PathType:Container) {
        $Files = Get-ChildItem $Path -Recurse -Include:$Filter
    }
    if ($Date -eq "") {
        FileDateEditor $Files
    } else {
        $Date2  = New-DateTime $Date -Simple:$Simple
        FileDateEditor $Files $Date2 -Force:$Force -Preview:$Preview
    }
}
# ChangeWriteTime "README.md"
# ChangeWriteTime "README.md" "1999/02/13 午前 06:15:45"
# ChangeWriteTime "README.md" "1999-02-13 23:59:59" -Simple
# ChangeWriteTime "Test" "1999/02/13 午前 06:15:45" -Preview
# ChangeWriteTime "Test" "1999/02/13 午前 06:15:45" -Force
# ChangeWriteTime "Test" "1999-02-13 23:59:59" -Simple -Force
# ChangeWriteTime "Test" "1999-02-13 23:59:59" -Simple -Preview

# ChangeWriteTime "Test" "1999-02-13 23:59:59" -Simple -Filter:"txt|md" -Force
# ChangeWriteTime "Test" "1999-02-13 23:59:59" -Simple -Filter:@("*.txt","*.md") -Force
# ==================================================================================================
