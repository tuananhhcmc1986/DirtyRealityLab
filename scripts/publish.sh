#!/bin/bash

ID=$1

echo "Publishing Reality $ID..."

mkdir -p reality/$ID

cp draft/reality/$ID/whitepaper.pdf reality/$ID/

cp -r draft/reality/$ID/diagrams reality/$ID/ 2>/dev/null

pandoc draft/reality/$ID/summary.md \
-o reality/$ID/summary.html

echo "Published Reality $ID"