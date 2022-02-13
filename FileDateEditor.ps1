# 建立日期格式
function New-DateTime {
    [CmdletBinding(DefaultParameterSetName = "FormatType")]
    param (
        [Parameter(Position = 0, ParameterSetName = "FormatType")]
        [Parameter(Position = 0, ParameterSetName = "JP")]
        [string] $DateStr,
        [Parameter(Position = 1, ParameterSetName = "FormatType")]
        [string] $FormatType,
        [Parameter(Position = 1, ParameterSetName = "JP")]
        [switch] $JP
    )
    # 格式化日期
    if ($DateStr) {
        if ($JP) { # 轉換日本時間格式
            $FormatType = "yyyy/MM/dd tt h:mm:ss"
            $DateStr = $DateStr -replace("午前", "AM")-replace("午後", "PM")
        } elseif($TW) { # 轉換台灣時間格式
            # 待完成
        } else { # 預設格式
            $FormatType = "yyyy-MM-dd HH:mm:ss"
        }
        return [DateTime]::ParseExact( $DateStr, $FormatType, [CultureInfo]::InvariantCulture )
    } else {
        return Get-Date
    }
}
# New-DateTime
# New-DateTime "2021-05-12 12:00:00"
# New-DateTime "2021-05-12 12:00:00" "yyyy-MM-dd HH:mm:ss"
# New-DateTime "2022/02/13 午前 04:15:45" -JP
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

# FileDateEditor -File:$File -AllDate:$Date -Preview
# FileDateEditor -File:$File -LastAccessTime:$Date -Preview
# FileDateEditor -File:$File $Date -Preview
# FileDateEditor -File:$File -Preview

# FileDateEditor -File:$File -CreationTime:$Date -Preview
# FileDateEditor -File:$File -LastAccessTime:$Date -Preview
# FileDateEditor -File:$File -LastAccessTime:$Date -Preview
# FileDateEditor -File:$File

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
# ChangeWriteTime_JP -Path:"Test" -Date:"2022/02/01 午前 00:00:00"