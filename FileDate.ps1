#==================================================================================================
# 從字串轉換成日期時間物件
#==================================================================================================
function Convert-ToDate {
    [CmdletBinding(DefaultParameterSetName = 'Culture')]
    param (
        [Parameter(Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
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
    try {
        if (-not $DateString) { return }
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
# "" | Convert-ToDate

#==================================================================================================
# 設定檔案日期時間
#==================================================================================================
function Set-FileDate {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string] $DateString,
        
        [Parameter(Mandatory, Position = 1, ParameterSetName = 'Path')]
        [ValidateNotNullOrEmpty()]
        [string] $Path,
        
        [Parameter(Mandatory, Position = 1, ValueFromPipeline, ParameterSetName = 'File')]
        [ValidateNotNullOrEmpty()]
        [IO.FileInfo] $File,

        [Parameter()]
        [string] $Format,
        
        [Parameter()]
        [switch] $Creation,
        
        [Parameter()]
        [switch] $Write,
        
        [Parameter()]
        [switch] $Access
    )
    
    begin {
        $dateTime = Convert-ToDate $DateString -Format $Format
        $setCreation = $All -or $Creation
        $setWrite    = $All -or $Write -or -not ($Creation -or $Access)
        $setAccess   = $All -or $Access
    }
    
    process {
        if ($Path) {
            $File = Get-Item $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
        } if (-not $File) { return }
        
        if ($setCreation) { $File.CreationTime   = $dateTime }
        if ($setWrite)    { $File.LastWriteTime  = $dateTime }
        if ($setAccess)   { $File.LastAccessTime = $dateTime }
    }
}

# 使用範例
# Get-Item test\file.txt | Set-FileDate "2024-2-3"
# Get-Item test\file.txt | Set-FileDate "2024-02-03"
# Get-Item test\file.txt | Set-FileDate "2024-02-03 12:00:00"
# Get-Item test\file.txt | Set-FileDate "2024-02-03 12:00:00" -Format "yyyy-MM-dd HH:mm:ss"
# Set-FileDate "2024-2-10" "test\..\test\file.txt"
# Set-FileDate "2024-2-10" "test\..\test\file2.txt"
# Set-FileDate "2024-2-10" "test\..\test\file2.txt" -ErrorAction Stop
# Set-FileDate ""
# @($null) | Set-FileDate "2024-2-3"
