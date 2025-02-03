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

        # 如果指定了 Format，直接使用 ParseExact
        if ($Format) { 
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

# 基本日期轉換
# Convert-ToDateTime "2023-12-31 23:59:59"
# Convert-ToDateTime "2023/12/31 下午 11:59:59"
# Convert-ToDateTime "2023/12/31 下午 11:59:59" -Culture 'zh-TW'
# Convert-ToDateTime "20231231235959" -Format "yyyyMMddHHmmss"

#==================================================================================================
# 使用者友善介面
#==================================================================================================
function Set-FileDateTime {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Specific')]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline = $true)]
        [IO.FileInfo[]] $File,
        
        [Parameter(Position = 1)]
        [string] $DateString,
        
        [Parameter()]
        [string] $DateFormat,
        
        [Parameter(ParameterSetName = 'Specific')]
        [switch] $Creation,
        
        [Parameter(ParameterSetName = 'Specific')]
        [switch] $Write,
        
        [Parameter(ParameterSetName = 'Specific')]
        [switch] $Access,
        
        [Parameter(ParameterSetName = 'All')]
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
    if ($All) {
        $setCreation = $true
        $setWrite = $true
        $setAccess = $true
    } else {
        $setCreation = $Creation
        $setWrite = $Write -or (!$Creation -and !$Access)  # 如果都沒選，預設修改 Write
        $setAccess = $Access
    }
    
    # 處理檔案
    foreach ($item in $File) {
        if ($PSCmdlet.ShouldProcess($item.FullName, "Modify file date")) {
            if ($setCreation) { $item.CreationTime = $dateTime }
            if ($setWrite)    { $item.LastWriteTime = $dateTime }
            if ($setAccess)   { $item.LastAccessTime = $dateTime }
        }
    }
}

# 使用範例
# Get-ChildItem *.txt | Set-FileDateTime "2023-12-31" -All 
# Get-Item "file.txt" | Set-FileDateTime "2023-12-31" -Creation -Write 