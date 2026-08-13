# 📋 Standup Copy Block

Use this block verbatim in `live.md`; replace only `{standup HTML}`. Keeping one
canonical handler prevents regenerated sitreps from restoring a stale or
partially tested clipboard implementation.

```html
<div class="st-copy-block"><button class="st-copy-btn" onclick="var b=this,e=this.nextElementSibling,h=e.innerHTML,text=function(item){var copy=item.cloneNode(true);Array.prototype.forEach.call(copy.querySelectorAll('ul'),function(list){list.remove()});return copy.textContent.trim()},walk=function(list,depth){var lines=[];Array.prototype.forEach.call(list.children,function(item){if(item.tagName!=='LI')return;lines.push(Array(depth+1).join('  ')+'• '+text(item));var nested=Array.prototype.find.call(item.children,function(child){return child.tagName==='UL'});if(nested)lines=lines.concat(walk(nested,depth+1))});return lines},p=walk(e.querySelector('ul'),0).join('\n'),done=function(ok){b.textContent=ok?'Copied ✓':'Copy failed';setTimeout(function(){b.textContent='Copy'},1500)},plain=function(){return Promise.resolve().then(function(){if(!navigator.clipboard||typeof navigator.clipboard.writeText!=='function')throw new Error('Clipboard unavailable');return navigator.clipboard.writeText(p)})},rich=function(){return Promise.resolve().then(function(){if(!navigator.clipboard||typeof navigator.clipboard.write!=='function'||typeof window.ClipboardItem!=='function')throw new Error('Rich clipboard unavailable');return navigator.clipboard.write([new ClipboardItem({'text/html':new Blob([h],{type:'text/html'}),'text/plain':new Blob([p],{type:'text/plain'})})])})};rich().catch(plain).then(function(){done(true)}).catch(function(){done(false)})">Copy</button><div class="st-standup">{standup HTML}</div></div>
```

## 🧱 HTML hierarchy

`{standup HTML}` has one root `<ul>` and exactly three top-level `<li>` branches:

1. `👈🏽 Yesterday`
2. `👉🏽 Today`
3. `✋🏽 Blockers`

Each branch contains its item `<ul>`. Nested details belong inside their parent
item's `<ul>`; never emit sibling lists that visually detach details from the
item they explain.

## 🧪 Verification gate

Run these checks in a freshly loaded browser page. Clipboard access depends on
user activation, so dispatch the copy through the browser click tool rather
than `element.click()` inside `browser_evaluate`.

1. Assert `.st-copy-block` and `.st-standup` are contained by `.sitrep-col`.
2. Assert one root `<ul>`, three top-level `<li>` elements, and the exact heading
   order above.
3. Click `.st-copy-btn`; wait for `Copied ✓`. When clipboard readback is
   available, confirm the plain payload starts with `• 👈🏽 Yesterday`, uses
   `  •` for child items and `    •` for deeper details when present, and
   contains all three headings.
4. Force rich `write()` to reject while `writeText()` succeeds; confirm exactly
   one plain fallback and `Copied ✓`.
5. Force both paths to reject; confirm `Copy failed`.
6. Cover partial APIs and synchronous failures: missing `write`, a throwing
   `ClipboardItem` constructor, and synchronous `write()` failure must all
   reach the plain fallback.

Do not accept a mocked-call assertion by itself. It proves handler routing but
not browser gesture permissions, SilverBullet DOM freshness, or the actual
clipboard promise result.
