param(
    [string]$id
)

Write-Host "Publishing Reality $id..."

New-Item -ItemType Directory -Force -Path "reality/$id"

Copy-Item "draft/reality/$id/whitepaper.pdf" "reality/$id/" -ErrorAction SilentlyContinue

Copy-Item "draft/reality/$id/diagrams" "reality/$id/" -Recurse -ErrorAction SilentlyContinue

pandoc "draft/reality/$id/summary.md" -o "reality/$id/summary.html"

Write-Host "Published Reality $id"