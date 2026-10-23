#!/usr/bin/env bash
# Build the PDF versions of the proposal and report (needs pandoc + a LaTeX install).
set -euo pipefail
cd "$(dirname "$0")"
for doc in proposal report; do
  [ -f "$doc.md" ] || continue
  pandoc "$doc.md" -o "$doc.pdf" --pdf-engine=xelatex --resource-path=.:.. \
    -V mainfont="Helvetica Neue" -V linkcolor=blue -V urlcolor=blue \
    -H <(printf '%s\n' '\usepackage{float}' '\floatplacement{figure}{H}' \
         '\usepackage{etoolbox}' '\AtBeginEnvironment{longtable}{\small}' \
         '\renewenvironment{quote}{\begin{list}{}{\leftmargin=1.2em\rightmargin=0em}\item\small\sffamily}{\end{list}}')
  echo "built docs/$doc.pdf"
done
