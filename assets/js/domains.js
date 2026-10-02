/* domains.js - Academy engine
   The domain identity system, in one place.

   Every surface that names an exam domain - dashboard cards, the sidebar, the
   lesson header, search results, review results, the coverage matrix - builds
   its domain mark here, so the four domains look identical everywhere and a
   change is made once.

   A domain mark is always three things together, never colour alone:

     colour   var(--d-NN)       tokens.css, contrast-checked per theme
     icon     a distinct SHAPE   from data/exam.js
     text     the short name     from data/exam.js

   The shapes differ in silhouette (round, horizontal, square, pointed) so the
   domains stay distinguishable in greyscale, under colour-vision deficiency,
   and in Windows high-contrast mode where the colour is thrown away.

   Official domain names still come from content/manifest.json. This file only
   adds the short learner-facing label and the icon; it never invents weights. */

(function (global) {
  'use strict';

  var SVG = 'http://www.w3.org/2000/svg';

  /* Labels and icons are exam data (data/exam.js), not engine code. */
  var EXAM = global.AcademyExam || { domains: {} };
  var DOMAINS = EXAM.domains;
  var ICONS = {};
  Object.keys(DOMAINS).forEach(function (k) { ICONS[k] = DOMAINS[k].icon; });

  function info(id) {
    var key = String(id || '').padStart ? String(id).padStart(2, '0') : String(id);
    return DOMAINS[key] || { short: 'Appendix', abbr: 'REF', exam: false };
  }

  function icon(id, size) {
    var key = DOMAINS[id] ? id : '00';
    var s = document.createElementNS(SVG, 'svg');
    s.setAttribute('viewBox', '0 0 16 16');
    s.setAttribute('width', String(size || 16));
    s.setAttribute('height', String(size || 16));
    s.setAttribute('aria-hidden', 'true');
    s.setAttribute('focusable', 'false');
    s.setAttribute('class', 'dom-icon');
    var p = document.createElementNS(SVG, 'path');
    p.setAttribute('d', ICONS[key]);
    p.setAttribute('fill', 'none');
    p.setAttribute('stroke', 'currentColor');
    p.setAttribute('stroke-width', '1.4');
    p.setAttribute('stroke-linecap', 'round');
    p.setAttribute('stroke-linejoin', 'round');
    s.appendChild(p);
    return s;
  }

  /* Paint an element with a domain: sets data-domain and the --d custom
     properties every learn.css component reads. */
  function paint(el, id) {
    var key = DOMAINS[id] ? id : '00';
    el.dataset.domain = key;
    el.style.setProperty('--d', 'var(--d-' + key + ')');
    el.style.setProperty('--d-ink', 'var(--d-' + key + '-ink)');
    el.style.setProperty('--d-tint', 'var(--d-' + key + '-tint)');
    return el;
  }

  /* The standard badge: [icon] Short name  (optional weight).
     opts.weight  - '20-25%' string from the manifest, shown as given
     opts.compact - abbreviation instead of the short name (still has a
                    title and an accessible name carrying the full label) */
  function badge(id, opts) {
    opts = opts || {};
    var d = info(id);
    var b = document.createElement('span');
    b.className = 'dom-badge';
    paint(b, id);
    b.appendChild(icon(id, opts.size || 14));

    var label = document.createElement('span');
    label.className = 'dom-badge__label';
    label.textContent = opts.compact ? d.abbr : d.short;
    b.appendChild(label);

    if (opts.compact) {
      b.title = d.short;
      label.setAttribute('aria-label', d.short);
    }
    if (opts.weight && opts.weight !== 'n/a') {
      var w = document.createElement('span');
      w.className = 'dom-badge__weight';
      w.textContent = String(opts.weight).replace('-', '\u2013');
      b.appendChild(w);
    }
    return b;
  }

  global.AcademyDomains = {
    info: info,
    icon: icon,
    paint: paint,
    badge: badge,
    ids: function () { return Object.keys(DOMAINS); }
  };
})(window);
