#==================================================================================================
# 日期時間處理工具
#==================================================================================================
function Convert-ToDateTime {
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string] $DateString,
        
        [Parameter()]
        [string] $Format,
        
        [Parameter()]
        [Globalization.CultureInfo] $Culture = [Globalization.CultureInfo]::CurrentCulture
    )
    
    if ([string]::IsNullOrWhiteSpace($DateString)) {
        return Get-Date
    }
    
    try {
        # 設定較寬鬆的日期時間解析選項
        $styles = [Globalization.DateTimeStyles]::AllowWhiteSpaces -bor 
                 [Globalization.DateTimeStyles]::AssumeLocal

        if ($Format) {
            return [datetime]::ParseExact($DateString, $Format, $Culture)
        } else {
            return [datetime]::Parse($DateString, $Culture, $styles)
        }
    }
    catch {
        $cultureName = $Culture.Name
        Write-Error "無法解析日期字串: '$DateString' (使用文化設定: $cultureName)`n$($_.Exception.Message)"
        return $null
    }
}

# 基本日期轉換
# Convert-ToDateTime "2023-12-31 23:59:59"
Convert-ToDateTime "2023/12/31 下午 11:59:59"
# Convert-ToDateTime "20231231235959" "yyyyMMddHHmmss"
#
# 使用特定文化
# $twCulture = [System.Globalization.CultureInfo]::GetCultureInfo("zh-TW")
# Convert-ToDateTime "2023年12月31日 下午 11:59:59" -Culture $twCulture

#==================================================================================================
# 檔案日期設定
#==================================================================================================
function Set-FileDateTime {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline = $true)]
        [System.IO.FileInfo] $File,
        
        [Parameter()]
        [datetime] $CreationTime,
        
        [Parameter()]
        [datetime] $WriteTime,
        
        [Parameter()]
        [datetime] $AccessTime
    )
    
    if ($PSCmdlet.ShouldProcess($File.FullName, "修改檔案日期")) {
        if ($PSBoundParameters.ContainsKey('CreationTime')) { 
            $File.CreationTime = $CreationTime 
        }
        if ($PSBoundParameters.ContainsKey('WriteTime')) { 
            $File.LastWriteTime = $WriteTime 
        }
        if ($PSBoundParameters.ContainsKey('AccessTime')) { 
            $File.LastAccessTime = $AccessTime 
        }
    }
}

# 直接設定檔案日期
# Get-Item "file.txt" | Set-FileDateTime -WriteTime (Get-Date)
# Get-Item "file.txt" | Set-FileDateTime `
#     -CreationTime (Get-Date "2023-01-01") `
#     -WriteTime (Get-Date "2023-06-15") `
#     -AccessTime (Get-Date "2023-12-31")

#==================================================================================================
# 使用者友善介面
#==================================================================================================
function Update-FileDateTime {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline = $true)]
        [string[]] $Path,
        
        [Parameter(Position = 1)]
        [string] $DateString,
        
        [Parameter()]
        [string] $DateFormat,
        
        [Parameter()]
        [switch] $Creation,
        
        [Parameter()]
        [switch] $Write,
        
        [Parameter()]
        [switch] $Access,
        
        [Parameter()]
        [switch] $All
    )
    
    # 轉換日期
    $dateTime = if ($DateFormat) {
        Convert-ToDateTime $DateString $DateFormat
    } else {
        Convert-ToDateTime $DateString
    }
    
    if ($null -eq $dateTime) { return }
    
    # 準備參數
    $params = @{}
    
    if ($All) {
        $params['CreationTime'] = $dateTime
        $params['WriteTime'] = $dateTime
        $params['AccessTime'] = $dateTime
    } else {
        if ($Creation) { $params['CreationTime'] = $dateTime }
        if ($Write)    { $params['WriteTime'] = $dateTime }
        if ($Access)   { $params['AccessTime'] = $dateTime }
        # 如果都沒選，預設修改 Write
        if ($params.Count -eq 0) { 
            $params['WriteTime'] = $dateTime 
        }
    }
    
    # 處理檔案
    foreach ($item in $Path) {
        $file = Get-Item -LiteralPath $item
        if ($file -is [System.IO.FileInfo]) {
            $file | Set-FileDateTime @params -WhatIf:$WhatIfPreference
        }
    }
}

# 使用友善介面
# Update-FileDateTime "file.txt" "2023-12-31" -All
# Update-FileDateTime "file.txt" "2023-12-31" -Creation -Write
# Get-ChildItem *.txt | Update-FileDateTime "2023-12-31" -All 