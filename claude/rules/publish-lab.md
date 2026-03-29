# Publish Lab Reality

Automation rule for publishing research drafts to HTML pages on lab.dirtyreality.net.

## Source

```
draft/{id}/summary.md
draft/{id}/whitepaper.pdf   ← optional
```

`{id}` is a zero-padded number, e.g. `01`, `02`, `03`

## Output

```
reality/{id}/index.html     ← generated from template
reality/{id}/whitepaper.pdf ← copied from draft (if exists)
reality/index.json          ← updated automatically
```

## Steps

**1. Read draft**

Read `draft/{id}/summary.md`. Extract:
- **Title**: first line starting with `# ` (strip the `# ` prefix)
- **Executive Summary**: content between `# 1. Executive Summary` and `# 2.` (the next section heading)

**2. Convert Executive Summary to HTML**

Convert the extracted Executive Summary markdown to HTML:
- `# heading` → `<h1>heading</h1>`
- `## heading` → `<h2>heading</h2>`
- Paragraphs → `<p>...</p>`
- `**bold**` → `<strong>bold</strong>`
- `*italic*` → `<em>italic</em>`
- Tables → `<table>` with `<th>` and `<td>`
- Preserve all content — do not summarize or truncate

**3. Apply template**

Load `templates/reality_template.html`, replace:
- `{{ID}}` → id (e.g. `01`)
- `{{TITLE}}` → extracted title
- `{{SUMMARY}}` → converted HTML from step 2

**4. Save page**

Write output to `reality/{id}/index.html` using UTF-8 encoding.

**5. Copy PDF**

If `draft/{id}/whitepaper.pdf` exists, copy to `reality/{id}/whitepaper.pdf`.

**6. Update reality index**

Edit `reality/index.json`. Add entry if `id` not already present:

```json
{ "id": 1, "title": "Title here", "year": 2026 }
```

- `id` field is an integer (not string)
- Do not create duplicate entries — check first
- Sort by `id` ascending

**7. Notify subscribers via email**

Extract sapo: first non-empty paragraph from the Executive Summary markdown that is not a heading (`#`) and not a separator (`---`). Strip markdown formatting to plain text.

Call the notification endpoint using Bash:

```bash
curl -s "https://script.google.com/macros/s/AKfycbxMbWXIe56bCpGt3oywPv_6NU8FH-UkMgkHbut3fxvneMF905yT4fKP9JLSlygbofNIhA/exec?action=notify&secret=dirtyrealitysgnngsytilaerytrid14061986&title={{URL_ENCODED_TITLE}}&url={{URL_ENCODED_POST_URL}}&sapo={{URL_ENCODED_SAPO}}"
```

- Post URL format: `https://lab.dirtyreality.net/reality/{id}/`
- URL-encode all three params before inserting into the curl command
- Run using the Bash tool
- Skip this step only in Republish Mode

## Republish Mode

If `reality/{id}/index.html` already exists:
- Overwrite file content using the latest template
- Do NOT create duplicate entry in `reality/index.json`
- Do NOT send subscriber notification email

## Template Requirements

Every generated `reality/{id}/index.html` must include:

**In `<head>`:**
- `<meta charset="UTF-8">`
- Link to `../../assets/css/style.css`
- Google Analytics tag:
```html
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-SHC80VT5RE"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-SHC80VT5RE');
</script>
```

**In `<body>`:**
- Theme toggle: `<div id="themeToggle" class="theme-toggle">theme</div>`
- Back link: `<a href="/">← Dirty Reality Lab</a>`
- Subscribe form before footer:
```html
<hr>

<div class="subscribe-wrapper">
<div class="subscribe-label">Get new research delivered to your inbox.</div>
<form class="subscribe-form" onsubmit="handleSubscribe(event)">
    <input type="email" class="subscribe-input" placeholder="email@example.com" required>
    <button type="submit" class="subscribe-btn">Subscribe</button>
</form>
<div class="subscribe-msg"></div>
</div>

<hr>
```
- Subscribe JS before `</body>`:
```html
<script>
function handleSubscribe(e) {
  e.preventDefault();
  var form = e.target;
  var email = form.querySelector('input').value;
  var msg = form.parentElement.querySelector('.subscribe-msg');
  var btn = form.querySelector('button');
  btn.disabled = true;
  btn.textContent = '...';
  var url = 'https://script.google.com/macros/s/AKfycbxMbWXIe56bCpGt3oywPv_6NU8FH-UkMgkHbut3fxvneMF905yT4fKP9JLSlygbofNIhA/exec?email=' + encodeURIComponent(email) + '&source=lab.dirtyreality.net';
  fetch(url, { mode: 'no-cors' })
    .then(function() {
      form.style.display = 'none';
      msg.textContent = 'Subscribed! Thank you.';
    })
    .catch(function() {
      btn.disabled = false;
      btn.textContent = 'Subscribe';
      msg.textContent = 'Something went wrong. Please try again.';
    });
}
</script>
```
- Theme script: `<script src="../../assets/js/theme.js"></script>`

All of the above are already in `templates/reality_template.html`. If publishing via template, no manual injection needed — just verify they are present after replacing placeholders.

## Constraints

- Never publish raw markdown files to `reality/`
- Never modify files outside `reality/{id}/`, `reality/index.json`, and the draft folder
- Final URL must work at: `https://lab.dirtyreality.net/reality/{id}/`
