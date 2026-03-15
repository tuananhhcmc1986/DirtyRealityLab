param(
    [string]$id
)

Write-Host "Publishing Reality $id..."

$draft = "draft/$id"
$public = "reality/$id"

New-Item -ItemType Directory -Force -Path $public | Out-Null

Copy-Item "$draft/whitepaper.pdf" $public -ErrorAction SilentlyContinue
Copy-Item "$draft/diagrams" $public -Recurse -ErrorAction SilentlyContinue

pandoc "$draft/summary.md" -o "$public/summary.html"

$summary = Get-Content "$public/summary.html" -Raw
$template = Get-Content "templates/reality_template.html" -Raw

$titleLine = Select-String "^# " "$draft/summary.md" | Select-Object -First 1
$title = $titleLine.Line.Substring(2)

$page = $template.Replace("{{ID}}",$id)
$page = $page.Replace("{{TITLE}}",$title)
$page = $page.Replace("{{SUMMARY}}",$summary)

$page | Set-Content "$public/index.html"

Write-Host "Reality page generated."

# -----------------------------
# Update reality index.json
# -----------------------------

$indexFile = "reality/index.json"

if (Test-Path $indexFile) {
    $json = Get-Content $indexFile -Raw | ConvertFrom-Json
} else {
    $json = @()
}

$exists = $json | Where-Object { $_.id -eq [int]$id }

if (-not $exists) {

    $entry = [PSCustomObject]@{
        id = [int]$id
        title = $title
        year = (Get-Date).Year
    }

    $json += $entry

    $json | ConvertTo-Json -Depth 3 | Set-Content $indexFile

    Write-Host "Reality index updated."

} else {

    Write-Host "Reality already in index."

}

Write-Host "Publish complete."