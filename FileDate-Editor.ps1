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
        [Parameter(Position = 0, ParameterSetName = "FormatType", Mandatory=$true)]
        [Parameter(Position = 0, ParameterSetName = "JP", Mandatory=$true)]
        [string] $DateStr,
        [Parameter(Position = 1, ParameterSetName = "FormatType")]
        [string] $FormatType = "yyyy-MM-dd HH:mm:ss",
        [Parameter(Position = 1, ParameterSetName = "JP")]
        [switch] $JP
    )
    [DateTime] $Date = Get-Date
    # 轉換日本時間格式
    if ($JP) {
        $FormatType = "yyyy/MM/dd tt h:mm:ss"
        $DateStr = $DateStr -replace("午前", "AM")-replace("午後", "PM")
    }
    # 格式化日期
    if ($DateStr) {
        $Date = [DateTime]::ParseExact( $DateStr, $FormatType, [CultureInfo]::InvariantCulture )
    } return $Date
}
New-DateTime "2021-05-12 12:00:00"
New-DateTime "2022/02/13 午前 04:15:45" -JP

function FileDate-Editor {
    param (
        $OptionalParameters
    )
    
}