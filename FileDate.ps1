#==================================================================================================
# 日期時間處理工具
#==================================================================================================
function Convert-ToDate {
    [CmdletBinding(DefaultParameterSetName = 'Culture')]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string] $DateString,
        
        [Parameter(ParameterSetName = 'Format')]
        [string] $Format,
        
        [Parameter(ParameterSetName = 'Culture')]
        [ValidateSet(
            'CurrentCulture', 
            'InvariantCulture', 
            'zh-TW', 
            'ja-JP', 
            'en-US'
        )] [string] $Culture = 'CurrentCulture'
    )
    
    if ([string]::IsNullOrWhiteSpace($DateString)) { return Get-Date }
    
    try {
        # 如果指定了 Format 且不為空，直接使用 ParseExact
        if ($PSCmdlet.ParameterSetName -eq 'Format' -and $Format) {
            return [datetime]::ParseExact( 
                $DateString, $Format, [Globalization.CultureInfo]::InvariantCulture
            )
        }
        
        # 其他情況使用 Culture 解析
        $cultures = if ($PSBoundParameters.ContainsKey('Culture')) { @($Culture) } else {
            $attributes = (Get-Command -Name $MyInvocation.MyCommand).Parameters['Culture'].Attributes
            $attributes.Where({ $_.GetType().Name -eq 'ValidateSetAttribute' }).ValidValues
        }
        
        # 設定較寬鬆的日期時間解析選項
        $styles = [Globalization.DateTimeStyles]::AllowWhiteSpaces -bor [Globalization.DateTimeStyles]::AssumeLocal
        
        # 建立 CultureInfo 快取
        $cultureInfoCache = @{
            'CurrentCulture'   = [Globalization.CultureInfo]::CurrentCulture
            'InvariantCulture' = [Globalization.CultureInfo]::InvariantCulture
        }

        $errors = @()
        foreach ($cultureName in $cultures) {
            try { # 如果快取中沒有該文化設定，則建立新的 CultureInfo 物件
                if (-not $cultureInfoCache.ContainsKey($cultureName)) {
                    $cultureInfoCache[$cultureName] = [Globalization.CultureInfo]::GetCultureInfo($cultureName)
                } # 解析日期時間
                return [datetime]::Parse($DateString, $cultureInfoCache[$cultureName], $styles)
            }
            catch {
                $errors += @{
                    Culture = $cultureName
                    Error = $_.Exception.Message
                }
            }
        }
        
        # 如果所有嘗試都失敗，才顯示警告和錯誤
        if ($errors.Count -eq $cultures.Count) {
            $errors | ForEach-Object { Write-Warning "[$($_.Culture)] $($_.Error)" }
            Write-Error "Unable to parse date string with any culture: '$DateString' (Attempted: $($errors.Culture -join ', '))"
        }
    }
    catch {
        Write-Error $_.Exception.Message
    }
}

# 基本日期轉換
# Convert-ToDate "2023-12-31"
# Convert-ToDate "2023-12-31 23:59:59"
# Convert-ToDate "2023/12/31 下午 11:59:59"
# Convert-ToDate "2023/12/31 下午 11:59:59" -Culture 'zh-TW'
# Convert-ToDate "20231231235959" -Format "yyyyMMddHHmmss"

#==================================================================================================
# 使用者友善介面
#==================================================================================================
function Set-FileDate {
    [CmdletBinding(DefaultParameterSetName = 'Specific')]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string] $DateString,
        
        [Parameter(Mandatory, ValueFromPipeline, Position = 1)]
        [IO.FileInfo] $File,
        
        [Parameter()]
        [string] $Format,
        
        [Parameter(ParameterSetName = 'Specific')]
        [switch] $Creation,
        
        [Parameter(ParameterSetName = 'Specific')]
        [switch] $Write,
        
        [Parameter(ParameterSetName = 'Specific')]
        [switch] $Access,
        
        [Parameter(ParameterSetName = 'All')]
        [switch] $All
    )
    
    begin {
        # 轉換日期
        $dateTime = Convert-ToDate $DateString -Format $Format
        # 準備參數
        $setCreation = $All -or $Creation
        $setWrite    = $All -or $Write -or -not ($Creation -or $Access)
        $setAccess   = $All -or $Access
    }
    
    process {
        if ($setCreation) { $File.CreationTime = $dateTime }
        if ($setWrite)    { $File.LastWriteTime = $dateTime }
        if ($setAccess)   { $File.LastAccessTime = $dateTime }
    }
}

# 使用範例
# Get-Item test\file.txt | Set-FileDate "2024-2-3"
# Get-Item test\file.txt | Set-FileDate "2024-02-03"
# Get-Item test\file.txt | Set-FileDate "2024-02-03 12:00:00"
# Get-Item test\file.txt | Set-FileDate "2024-02-03 12:00:00" -Format "yyyy-MM-dd HH:mm:ss"
# Set-FileDate "2024-2-10" "test\file.txt"
