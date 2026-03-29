param(
    [string]$id
)

Write-Host ""
Write-Host "Publishing Reality $id..."
Write-Host ""

$draft = "draft/$id"
$public = "reality/$id"

New-Item -ItemType Directory -Force -Path $public | Out-Null

# -------------------------
# copy PDF
# -------------------------
if (Test-Path "$draft/whitepaper.pdf") {

    Copy-Item "$draft/whitepaper.pdf" "$public/whitepaper.pdf" -Force
    Write-Host "PDF copied."

} else {

    Write-Host "WARNING: whitepaper.pdf not found."

}

# -------------------------
# read markdown
# -------------------------
$md = Get-Content "$draft/summary.md" -Raw -Encoding UTF8

# extract title
$titleLine = Select-String "^# " "$draft/summary.md" | Select-Object -First 1
$title = $titleLine.Line.Substring(2)

# -------------------------
# extract Executive Summary
# -------------------------
$pattern = "(?s)# 1\. Executive Summary(.*?)# 2\."
$match = [regex]::Match($md,$pattern)

if ($match.Success) {
    $exec = "# Executive Summary`n" + $match.Groups[1].Value
} else {
    Write-Host "Executive Summary not found."
    $exec = ""
}

# -------------------------
# convert summary → html
# -------------------------
$execFile = "$draft/executive.md"
$exec | Set-Content $execFile -Encoding UTF8

pandoc $execFile `
-o "$public/summary.html" `
--metadata charset=UTF-8

$summary = Get-Content "$public/summary.html" -Raw -Encoding UTF8

# -------------------------
# load template
# GA tracking (G-00DD2QNWWZ) and subscribe form are included in the template
# -------------------------
$template = Get-Content "templates/reality_template.html" -Raw -Encoding UTF8

$page = $template.Replace("{{ID}}",$id)
$page = $page.Replace("{{TITLE}}",$title)
$page = $page.Replace("{{SUMMARY}}",$summary)

$page | Set-Content "$public/index.html" -Encoding UTF8

Write-Host "Reality page generated."

# -------------------------
# update index.json
# -------------------------
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
    $json | ConvertTo-Json -Depth 3 | Set-Content $indexFile -Encoding UTF8

}

Write-Host ""
Write-Host "Publish complete."
Write-Host ""