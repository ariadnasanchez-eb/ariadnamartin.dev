#!/bin/bash
# Pre-publish checks for ariadnamartin.dev. Runs automatically before every `git push`.
# Exit code 1 blocks the push. Manual items live in CHECKLIST.md.
cd "$(dirname "$0")/.." || exit 1
fail=0
ok()   { echo "  ✅ $1"; }
bad()  { echo "  ❌ $1"; fail=1; }
PAGES="index.html legal.html 404.html"

echo "Pre-publish checks"

# 1. Required legal pages and links
[ -f legal.html ] && ok "Privacy & legal page exists" || bad "legal.html is missing"
grep -q 'href="legal.html"' index.html && ok "Footer links to the legal page" || bad "index.html does not link to legal.html"
grep -q 'hello@ariadnamartin.dev' legal.html && ok "Legal page shows the contact email" || bad "Contact email missing from legal.html"

# 2. No third-party embeds, trackers or cookies
ext=$(grep -o -E '(src|href)="https?://[^"]*"' $PAGES | grep -v -E 'ariadnamartin\.dev|calendly\.com|linkedin\.com|aepd\.es|tally\.so')
[ -z "$ext" ] && ok "No unexpected third-party resources" || bad "Unexpected external resources:\n$ext"
grep -q -i -E 'document\.cookie|localStorage|gtag\(|googletagmanager|facebook\.net|hotjar|<iframe' $PAGES && bad "Tracking, cookies or embeds found: add a cookie banner and update legal.html first" || ok "No tracking, cookies or embeds"

# 3. Accessibility basics
noalt=$(grep -o '<img[^>]*>' $PAGES | grep -v 'alt=')
[ -z "$noalt" ] && ok "Every image has alt text" || bad "Images without alt text:\n$noalt"
grep -q '<html lang=' index.html && ok "Page language is set" || bad "Missing <html lang>"
grep -q 'class="skip"' index.html && ok "Skip link present" || bad "Skip-to-content link missing"

# 4. Claims we can't back up
claims=$(grep -n -i -o -E 'many teams|most teams|clients (say|love)|trusted by|guarantee[ds]?|10x|revolutioni[sz]e|award-winning|[0-9]+\+? (happy )?clients' index.html)
[ -z "$claims" ] && ok "No unsupported claims or hype words" || bad "Check these claims:\n$claims"

# 5. Internal files referenced actually exist
missing=""
for ref in $(grep -o -E '(src|href)="[^"#:]+"' index.html legal.html | sed -E 's/.*="([^"]+)"/\1/' | grep -v '^/$' | sort -u); do
  [ -e "${ref#/}" ] || [ "$ref" = "./" ] || missing="$missing $ref"
done
[ -z "$missing" ] && ok "All internal files exist" || bad "Missing files:$missing"

# 6. External links respond (LinkedIn answers 999 to bots, which is fine)
for url in $(grep -o -E 'href="https://[^"]*"' index.html | sed 's/href="//;s/"$//' | sort -u | grep -v ariadnamartin.dev); do
  code=$(curl -s -o /dev/null -L -A 'Mozilla/5.0' --max-time 15 -w '%{http_code}' "$url")
  case "$code" in 200|999) ok "Link OK ($code): $url";; *) bad "Link broken ($code): $url";; esac
done

# 7. Impeccable design detector (cramped-padding is a known false positive on this layout)
IMP="$HOME/.claude/skills/impeccable/scripts/impeccable"
if [ -x "$IMP" ]; then
  issues=$("$IMP" detect --json $PAGES 2>/dev/null | python3 -c "
import json,sys
d=json.load(sys.stdin)
for x in d:
    if x['antipattern']=='cramped-padding': continue
    print('   -', x['file'].split('/')[-1], x['antipattern'], x['snippet'][:90])")
  [ -z "$issues" ] && ok "Impeccable detector: no issues" || bad "Impeccable detector found:\n$issues"
else
  echo "  ⚠️  Impeccable not installed, design detector skipped"
fi

echo
if [ $fail -eq 0 ]; then echo "All checks passed. Also review the manual items in CHECKLIST.md."; else echo "Fix the ❌ items before publishing."; fi
exit $fail
