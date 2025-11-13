# PowerShell script to update the color in the static HTML page
# Usage: .\scripts\update-color.ps1 <color>
# Example: .\scripts\update-color.ps1 "#ff6b6b"
# Example: .\scripts\update-color.ps1 "#10b981" (green)
# Example: .\scripts\update-color.ps1 "#f59e0b" (orange)

param(
    [Parameter(Mandatory=$false)]
    [string]$Color = "#667eea"
)

$HtmlFile = "static-app/index.html"

if (-not (Test-Path $HtmlFile)) {
    Write-Host "❌ Error: $HtmlFile not found" -ForegroundColor Red
    exit 1
}

Write-Host "🎨 Updating color to: $Color" -ForegroundColor Cyan

# Read the file
$content = Get-Content $HtmlFile -Raw

# Update background gradient in body style (line ~20)
$content = $content -replace 'background:\s*linear-gradient\([^;]+;', "background: $Color;"

# Update background-color in .color-box style (line ~47)
$content = $content -replace '(\.color-box[^}]*background-color:)\s*[^;]+;', "`$1 $Color;"

# Update default color in JavaScript (line ~143)
$content = $content -replace "('COLOR_PLACEHOLDER'\s*\|\|\s*')([^']+)(')", "`$1$Color`$3"

# Write back to file
Set-Content -Path $HtmlFile -Value $content -NoNewline

Write-Host "✅ Color updated in $HtmlFile" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Review changes: git diff $HtmlFile" -ForegroundColor White
Write-Host "   2. Commit: git add $HtmlFile; git commit -m 'chore: update color to $Color'" -ForegroundColor White
Write-Host "   3. Push: git push origin main" -ForegroundColor White
Write-Host "   4. Watch GitHub Actions workflow deploy automatically!" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Popular colors to try:" -ForegroundColor Cyan
Write-Host "   - Green: #10b981" -ForegroundColor Green
Write-Host "   - Red: #ef4444" -ForegroundColor Red
Write-Host "   - Orange: #f59e0b" -ForegroundColor Yellow
Write-Host "   - Purple: #8b5cf6" -ForegroundColor Magenta
Write-Host "   - Pink: #ec4899" -ForegroundColor Magenta
Write-Host "   - Blue: #3b82f6" -ForegroundColor Blue

