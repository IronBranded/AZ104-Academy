/* smoke-test.js - Academy engine
   Headless smoke test: loads the site in jsdom against a running local copy,
   visits every route the manifest defines plus every study view, and fails if
   a page throws, renders an error box, or renders without a heading.

   It doesn't check layout or colour (tools/a11y-check.js does that in a real
   browser). It catches the regressions a static site can ship silently: a
   view that is no longer registered, a lesson whose structure the engine no
   longer recognises, a JSON file that stopped parsing.

   Dev-time only; jsdom is never shipped.
     npm install --no-save jsdom@24
     python -m http.server 8080 &
     node tools/smoke-test.js                    (BASE_URL to override)  */

'use strict';

const { JSDOM, VirtualConsole } = require('jsdom');

const BASE = (process.env.BASE_URL || 'http://localhost:8080/').replace(/\/?$/, '/');
const WAIT = parseInt(process.env.WAIT_MS || '900', 10);

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

(async () => {
  const manifest = await (await fetch(BASE + 'content/manifest.json')).json();
  const routes = ['#/'];
  manifest.domains.forEach(d => {
    d.modules.forEach(m => {
      routes.push('#/module/' + m.id);
      if (m.lab) routes.push('#/lab/' + m.id);
    });
    if (d.weight !== 'n/a') routes.push('#/domain/' + d.id);
  });
  (manifest.appendix || []).forEach((a, i) => routes.push('#/appendix/' + i));
  routes.push('#/map', '#/map/vm', '#/glossary', '#/compare', '#/coverage', '#/prep',
              '#/prep/needs-review', '#/exam', '#/cards', '#/review', '#/readiness', '#/cost', '#/preview');

  const errors = [];
  const vc = new VirtualConsole();
  vc.on('jsdomError', e => {
    const msg = String(e && (e.message || e));
    // Mermaid needs real SVG layout; its failures fall back to source text by design.
    if (/mermaid|getBBox|getComputedTextLength/i.test(msg + (e && e.stack || ''))) return;
    errors.push('jsdomError: ' + msg);
  });
  vc.on('error', m => { if (!/mermaid/i.test(String(m))) errors.push('console.error: ' + m); });

  const dom = await JSDOM.fromURL(BASE, {
    runScripts: 'dangerously', resources: 'usable', pretendToBeVisual: true, virtualConsole: vc,
    beforeParse(w) {
      w.fetch = (u, o) => fetch(new URL(String(u), w.location.href), o);
      w.matchMedia = w.matchMedia || (() => ({ matches: false, addListener() {}, removeListener() {}, addEventListener() {}, removeEventListener() {} }));
      w.scrollTo = () => {};
      w.HTMLElement.prototype.scrollIntoView = function () {};
      // Keep the 3.5 MB diagram renderer out of a DOM that can't lay it out.
      const orig = w.document.createElement.bind(w.document);
      w.document.createElement = function (tag, opts) {
        const el = orig(tag, opts);
        if (String(tag).toLowerCase() === 'script') {
          Object.defineProperty(el, 'src', { set(v) { if (!/mermaid/.test(v)) el.setAttribute('src', v); else setTimeout(() => el.onerror && el.onerror(), 0); }, get() { return el.getAttribute('src'); } });
        }
        return el;
      };
    }
  });
  const w = dom.window;
  await sleep(2500);

  let failed = 0;
  for (const r of routes) {
    const before = errors.length;
    w.location.hash = r;
    await sleep(WAIT);
    const c = w.document.getElementById('content');
    const h1 = c && c.querySelector('h1');
    const bad = c && Array.from(c.querySelectorAll('.empty')).map(e => e.textContent).filter(t => /did not load|unavailable|not found|could not load|missing/i.test(t));
    const problems = [];
    if (!h1) problems.push('no h1');
    if (bad && bad.length) problems.push('error box: ' + bad[0].slice(0, 120));
    if (errors.length > before) problems.push(...errors.slice(before));
    if (problems.length) { failed++; console.log('FAIL', r, '\n   ' + problems.join('\n   ')); }
    else console.log('ok  ', r, '-', h1.textContent.trim().slice(0, 60));
  }
  console.log('\n' + (routes.length - failed) + ' / ' + routes.length + ' routes rendered cleanly.');
  w.close();
  process.exit(failed ? 1 : 0);
})().catch(e => { console.error(e); process.exit(2); });
