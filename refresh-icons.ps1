param([Parameter(Mandatory)][string]$Root)

Add-Type -Namespace Win32 -Name Shell -MemberDefinition @'
[DllImport("shell32.dll", CharSet = CharSet.Unicode)]
public static extern void SHChangeNotify(int wEventId, uint uFlags, string dwItem1, IntPtr dwItem2);
[DllImport("shell32.dll")]
public static extern void SHChangeNotify(int wEventId, uint uFlags, IntPtr dwItem1, IntPtr dwItem2);
'@

$SHCNE_UPDATEITEM    = 0x00002000
$SHCNE_UPDATEDIR     = 0x00001000
$SHCNE_ASSOCCHANGED  = 0x08000000
$SHCNF_PATHW         = 0x0005
$SHCNF_FLUSH         = 0x1000

# 대상 폴더: Root, Root 하위, _Archive 하위
$dirs = @($Root) + (Get-ChildItem -LiteralPath $Root -Directory -Force -Recurse -Depth 2 -ErrorAction SilentlyContinue | ForEach-Object FullName)

foreach ($d in $dirs) {
    $ini = Join-Path $d 'desktop.ini'
    if (Test-Path -LiteralPath $ini) {
        [Win32.Shell]::SHChangeNotify($SHCNE_UPDATEITEM, $SHCNF_PATHW -bor $SHCNF_FLUSH, $d, [IntPtr]::Zero)
        [Win32.Shell]::SHChangeNotify($SHCNE_UPDATEDIR,  $SHCNF_PATHW -bor $SHCNF_FLUSH, $d, [IntPtr]::Zero)
    }
}

# 아이콘 캐시 전체 무효화
[Win32.Shell]::SHChangeNotify($SHCNE_ASSOCCHANGED, $SHCNF_FLUSH, [IntPtr]::Zero, [IntPtr]::Zero)
