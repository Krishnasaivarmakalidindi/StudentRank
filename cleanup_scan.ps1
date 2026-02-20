$dirs = @(
    '.dart_tool\chrome-device',
    '.dart_tool',
    'android\.gradle',
    'android\build'
)

foreach ($d in $dirs) {
    if (Test-Path $d) {
        $items = Get-ChildItem -Path $d -Recurse -Force -ErrorAction SilentlyContinue
        $sum = ($items | Measure-Object -Property Length -Sum).Sum
        $mb = [math]::Round($sum / 1MB, 2)
        Write-Host "${d}: ${mb} MB"
    } else {
        Write-Host "${d}: NOT FOUND"
    }
}

# Total project size
$total = (Get-ChildItem -Path '.' -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
$totalMB = [math]::Round($total / 1MB, 2)
Write-Host "TOTAL PROJECT: ${totalMB} MB"
