# 讀取檔案日期
function readFileDate {
    param (
        [string]$FileName
    )
    $file = Get-Item $FileName;
    Write-Host "建立日期" $file.CreationTime;     #建立日期
    Write-Host "修改日期" $file.LastWriteTime;    #修改日期
    Write-Host "存取日期" $file.LastAccessTime;   #存取日期
}



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


function Get-FileDate {
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory=$true)]
        [System.Object] $File
    )
    if (!($Files -is [array])) { $Files = @($Files) }
    for ($i = 0; $i -lt $Files.Count; $i++) {
        $File = $Files[$i]
        Write-Host "[$($i+1)]" $File.FullName -ForegroundColor:Yellow
        Write-Host "  建立日期::" -NoNewline
        Write-Host $File.CreationTime    -ForegroundColor:Cyan
        Write-Host "  修改日期::" -NoNewline
        Write-Host $File.LastWriteTime   -ForegroundColor:Cyan
        Write-Host "  存取日期::" -NoNewline
        Write-Host $File.LastAccessTime  -ForegroundColor:Cyan
    }
}
# Get-FileDate (Get-Item "README.md")



function FileDate-Editor {
    [CmdletBinding(DefaultParameterSetName = "Time")]
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory=$true)]
        [System.Object] $Files,
        [Parameter(ParameterSetName = "AllDate")]
        [DateTime] $AllDate,
        [Parameter(ParameterSetName = "Time")]
        [DateTime] $CreationTime,
        [Parameter(ParameterSetName = "Time")]
        [DateTime] $LastWriteTime,
        [Parameter(Position = 1, ParameterSetName = "Time")]
        [DateTime] $LastAccessTime,
        [switch] $Preview
    )

    if (($null -eq $LastAccessTime) -and
        ($null -eq $LastWriteTime) -and
        ($null -eq $CreationTime) -and
        ($null -eq $AllDate))
    {
        Get-FileDate $Files
    } else {
        if ($AllDate) {
            $CreationTime = $AllDate
            $LastWriteTime = $AllDate
            $LastAccessTime = $AllDate
        }

        if (!($Files -is [array])) { $Files = @($Files) }
        for ($i = 0; $i -lt $Files.Count; $i++) {
            $File = $Files[$i]

            if ($Preview) {
                Write-Host "[$($i+1)]" $File.FullName -ForegroundColor:Yellow
                Write-Host "  " $File.CreationTime   "--> " -NoNewline
                Write-Host $CreationTime -ForegroundColor:DarkBlue
                Write-Host "  " $File.LastWriteTime  "--> " -NoNewline
                Write-Host $LastWriteTime -ForegroundColor:DarkBlue
                Write-Host "  " $File.LastAccessTime "--> " -NoNewline
                Write-Host $LastAccessTime -ForegroundColor:DarkBlue
            }

            if ($CreationTime) {
                $File.CreationTime = $CreationTime
            }
            if ($LastWriteTime) {
                $File.LastWriteTime = $LastWriteTime
            }
            if ($LastAccessTime) {
                $File.LastAccessTime = $LastAccessTime
            }
        }

        # if ($CreationTime) {
        #     $File.CreationTime = $CreationTime; #建立日期
        # } if ($LastWriteTime) {
        #     $File.LastWriteTime = $LastWriteTime; #修改日期
        # } if ($LastAccessTime) {
        #     $File.LastAccessTime = $LastAccessTime; #存取日期
        # }
    }
}
# FileDate-Editor (Get-Item "README.md") "2022/02/13 午前 04:00:02"
$Date = New-DateTime "2022/02/13 午前 04:55:55" -JP
# $File = Get-Item ".\README.md"
$File = Get-ChildItem "Test" -Recurse

# FileDate-Editor -File:$File -AllDate:$Date -Preview
# FileDate-Editor -File:$File -LastAccessTime:$Date -Preview
# FileDate-Editor -File:$File $Date -Preview
# FileDate-Editor $File -Preview

# FileDate-Editor $File -CreationTime:$Date -Preview
# FileDate-Editor $File -LastWriteTime:$Date -Preview
# FileDate-Editor $File -LastAccessTime:$Date -Preview
# FileDate-Editor $File
