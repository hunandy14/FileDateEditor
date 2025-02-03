#==================================================================================================
# 日期時間處理工具
#==================================================================================================
function Convert-ToDateTime {
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
            'zh-CN', 
            'ja-JP', 
            'en-US'
        )] [string] $Culture = 'CurrentCulture'
    )
    
    if ([string]::IsNullOrWhiteSpace($DateString)) { return Get-Date }
    
    try {
        # 如果 Format 為空，強制使用 Culture 參數集
        if ($Format) { 
            return [datetime]::ParseExact( 
                $DateString, $Format, [Globalization.CultureInfo]::InvariantCulture
            )
        }

        # 如果指定了 Format，直接使用 ParseExact
        if ($PSCmdlet.ParameterSetName -eq 'Format') {
            return [datetime]::ParseExact( 
                $DateString, $Format, [Globalization.CultureInfo]::InvariantCulture
            )
        }
        
        # 取得要嘗試的文化設定清單
        $cultures = if ($PSBoundParameters.ContainsKey('Culture')) { @($Culture) } else {
            $attributes = (Get-Command -Name $MyInvocation.MyCommand).Parameters['Culture'].Attributes
            $attributes.Where({ $_.GetType().Name -eq 'ValidateSetAttribute' }).ValidValues
        }
        
        # 設定較寬鬆的日期時間解析選項
        $styles = [Globalization.DateTimeStyles]::AllowWhiteSpaces -bor [Globalization.DateTimeStyles]::AssumeLocal

        $errors = @()
        foreach ($cultureName in $cultures) {
            try {
                $cultureInfo = switch ($cultureName) {
                    'CurrentCulture'   { [Globalization.CultureInfo]::CurrentCulture }
                    'InvariantCulture' { [Globalization.CultureInfo]::InvariantCulture }
                    default            { [Globalization.CultureInfo]::GetCultureInfo($cultureName) }
                }
                return [datetime]::Parse($DateString, $cultureInfo, $styles)
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

# Convert-ToDateTime "2023-12-30" -Format ""
# 基本日期轉換
# Convert-ToDateTime "2023-12-31"
# Convert-ToDateTime "2023-12-31 23:59:59"
# Convert-ToDateTime "2023/12/31 下午 11:59:59"
# Convert-ToDateTime "2023/12/31 下午 11:59:59" -Culture 'zh-TW'
# Convert-ToDateTime "20231231235959" -Format "yyyyMMddHHmmss"

#==================================================================================================
# 使用者友善介面
#==================================================================================================
function Set-FileDateTime {
    [CmdletBinding(DefaultParameterSetName = 'Specific')]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string] $DateString,
        
        [Parameter(Mandatory, ValueFromPipeline)]
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
        # $dateTime = Convert-ToDateTime $DateString -Format:$Format
        $dateTime = if ($Format) {
            Convert-ToDateTime $DateString -Format:$Format
        } else {
            Convert-ToDateTime $DateString
        }


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
# Get-Item .\Test\File.txt | Set-FileDateTime "2023-12-30"
# Get-Item "file.txt" | Set-FileDateTime "2023-12-31" -Creation -Write 