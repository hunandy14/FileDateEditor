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
# New-DateTime "2022/02/13 午前 04:15:45" -JP



function Get-FileDate {
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory=$true)]
        [System.Object] $File
    )
    Write-Host $File.FullName -ForegroundColor:Yellow
    Write-Host "  建立日期::" $File.CreationTime     #建立日期
    Write-Host "  修改日期::" $File.LastWriteTime    #修改日期
    Write-Host "  存取日期::" $File.LastAccessTime   #存取日期
}
# Get-FileDate (Get-Item "README.md")



function Set-FileDate {
    [CmdletBinding(DefaultParameterSetName = "FormatType")]
    param (
        [Parameter(Position = 0, ParameterSetName = "", Mandatory=$true)]
        [System.Object] $Files,
        [Parameter(Position = 1, ParameterSetName = "FormatType", Mandatory=$true)]
        [Parameter(Position = 1, ParameterSetName = "JP", Mandatory=$true)]
        [string] $DateStr,
        [Parameter(Position = 2, ParameterSetName = "FormatType")]
        [string] $FormatType = "yyyy-MM-dd HH:mm:ss",
        [Parameter(Position = 2, ParameterSetName = "JP")]
        [switch] $JP,
        [switch] $Preview
        
    )
    $All = $true
    
    if ($All) {
        $AllDate = New-DateTime $DateStr -JP
        $CreationTime   = $AllDate
        $LastWriteTime  = $AllDate
        $LastAccessTime = $AllDate
    }    
    
    
    if (!($Files -is [array])) { $Files = @($Files) }
    for ($i = 0; $i -lt $Files.Count; $i++) {
        $File = $Files[$i]
        
        if ($CreationTime) {
            $File.CreationTime   = $CreationTime
        }
        if ($LastWriteTime) {
            $File.LastWriteTime  = $LastWriteTime
        }
        if ($LastAccessTime) {
            $File.LastAccessTime = $LastAccessTime
        }
    
        if ($Preview) {
            Write-Host "[$($i+1)]" $File.FullName -ForegroundColor:Yellow
            Write-Host "  " $File.CreationTime   "--> " -NoNewline
            Write-Host $CreationTime -ForegroundColor:DarkBlue
            Write-Host "  " $File.LastWriteTime  "--> " -NoNewline
            Write-Host $LastWriteTime -ForegroundColor:DarkBlue
            Write-Host "  " $File.LastAccessTime "--> " -NoNewline
            Write-Host $LastAccessTime -ForegroundColor:DarkBlue
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
# Set-FileDate (Get-Item "README.md") "2022/02/13 午前 04:00:02"
Set-FileDate (Get-ChildItem "Test" -Recurse) "2022/02/13 午前 04:02:00" -Preview



function FileDate-Editor {
    param (
        $OptionalParameters
    )
    
}