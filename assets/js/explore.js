/* explore.js - Academy engine
   Three reference views for a learner who is new to Azure.

     #/map[/<id>]      Resource map. Every resource answers the same ten
                       questions: what contains it, what it depends on, what
                       depends on it, who manages it, how it is networked,
                       monitored, protected and recovered, what it costs, and
                       how to remove it safely. Data: data/resources.json.
     #/compare[/<id>]  Structured comparisons: purpose, scope, layer, when to
                       use, key difference, important limitation, dependency,
                       how to validate, and the AZ-104 takeaway. Data:
                       data/comparisons.json. The same component renders
                       inside each lesson's Distinguish stage.
     #/glossary        Every term from every lesson's "Words you need to
                       know" table, with the lesson that teaches it. Built at
                       runtime by curriculum.js, so there is no second list.

   The map is a teaching model and the page says so. */

(function (global) {
  'use strict';

  function node(tag, cls, text) {
    var n = document.createElement(tag);
    if (cls) n.className = cls;
    if (text != null) n.textContent = text;
    return n;
  }
  function link(text, href, cls) { var a = node('a', cls || null, text); a.href = href; return a; }
  function D() { return global.AcademyDomains; }
  function C() { return global.AcademyCurriculum; }

  var resJob = null;
  function loadResources() {
    if (!resJob) {
      resJob = fetch('data/resources.json', { cache: 'no-cache' })
        .then(function (r) { return r.ok ? r.json() : null; })
        .catch(function () { return null; });
    }
    return resJob;
  }

  function lessonLinks(model, ids, exclude) {
    var frag = document.createDocumentFragment();
    (ids || []).filter(function (id) { return id !== exclude && model.lessons[id]; }).forEach(function (id, i) {
      if (i) frag.appendChild(document.createTextNode(', '));
      var l = model.lessons[id];
      var a = link(id + ' \u00b7 ' + l.title, '#/module/' + id, 'dom-link');
      D().paint(a, l.domainId);
      frag.appendChild(a);
    });
    return frag;
  }

  /* ------------------------------------------------- comparison component */

  var FIELDS = [
    ['purpose', 'Purpose'], ['scope', 'Scope'], ['layer', 'Layer'], ['when', 'When to use'],
    ['difference', 'Key difference'], ['limitation', 'Important limitation'],
    ['dependency', 'Depends on'], ['validate', 'How to validate']
  ];

  function render(c, model, opts) {
    opts = opts || {};
    var art = node('article', 'cmp cmp--grid');
    art.id = 'cmp-' + c.id;
    var home = (c.modules || []).map(function (id) { return model.lessons[id]; }).filter(Boolean)[0];
    if (home) D().paint(art, home.domainId);

    /* h3 inside a lesson section; h2 on the compare page, which has no section headings. */
    art.appendChild(node(opts.level || 'h3', 'cmp__title', c.title));
    if (c.question) art.appendChild(node('p', 'cmp__q', c.question));

    var wrap = node('div', 'table-scroll');
    wrap.setAttribute('tabindex', '0');
    wrap.setAttribute('role', 'region');
    wrap.setAttribute('aria-label', 'Comparison: ' + c.title);
    var t = node('table', 'cmp-grid');
    t.dataset.stack = 'true';
    var thead = node('thead'), hr = node('tr');
    var corner = node('th', null, 'Compare');
    corner.setAttribute('scope', 'col');
    hr.appendChild(corner);
    c.options.forEach(function (o) { var th = node('th', null, o.name); th.setAttribute('scope', 'col'); hr.appendChild(th); });
    thead.appendChild(hr);
    t.appendChild(thead);
    var tb = node('tbody');
    FIELDS.forEach(function (f) {
      if (!c.options.some(function (o) { return o[f[0]]; })) return;
      var tr = node('tr');
      var th = node('th', null, f[1]);
      th.setAttribute('scope', 'row');
      tr.appendChild(th);
      c.options.forEach(function (o) {
        var td = node('td', null, o[f[0]] || '\u2013');
        td.dataset.label = o.name;
        tr.appendChild(td);
      });
      tb.appendChild(tr);
    });
    t.appendChild(tb);
    wrap.appendChild(t);
    art.appendChild(wrap);

    if (c.takeaway) {
      var tk = node('aside', 'cmp__takeaway');
      tk.appendChild(node('strong', null, window.AcademyExam.code + ' takeaway '));
      tk.appendChild(document.createTextNode(c.takeaway));
      art.appendChild(tk);
    }
    if (c.note) art.appendChild(node('p', 'field__note', c.note));

    var meta = node('p', 'cmp__meta');
    (c.objectives || []).forEach(function (txt) {
      var b = model.bulletByNorm[C().norm(txt)];
      if (!b) return;
      var chip = node('span', 'obj-chip', b.id);
      chip.title = b.text;
      meta.appendChild(chip);
      meta.appendChild(document.createTextNode(' '));
    });
    var others = (c.modules || []).filter(function (id) { return id !== opts.here && model.lessons[id]; });
    if (others.length) {
      meta.appendChild(document.createTextNode(opts.here ? 'Also in ' : 'Taught in '));
      meta.appendChild(lessonLinks(model, others, opts.here));
    }
    if (opts.here) {
      meta.appendChild(document.createTextNode(others.length ? ' \u00b7 ' : ''));
      meta.appendChild(link('All comparisons', '#/compare/' + c.id));
    }
    art.appendChild(meta);
    return art;
  }

  function compareView(root, manifest, arg) {
    root.appendChild(node('h1', null, 'Compare options'));
    root.appendChild(node('p', 'lede',
      'Services and settings that are easy to confuse, compared on the same eight questions, each ending in what ' +
      window.AcademyExam.code + ' expects you to decide. Only comparisons supported by the current skills outline are included.'));
    var filters = node('div', 'explore-filter');
    filters.setAttribute('role', 'group');
    filters.setAttribute('aria-label', 'Filter comparisons by domain');
    root.appendChild(filters);
    var host = node('div', 'cmp-list');
    root.appendChild(host);
    C().load().then(function (model) {
      var list = model.comparisons || [];
      if (!list.length) { host.appendChild(node('p', 'empty', 'data/comparisons.json did not load.')); return; }
      var cards = list.map(function (c) { var el = render(c, model, { level: 'h2' }); host.appendChild(el); return el; });
      var current = 'all';
      function apply() {
        cards.forEach(function (el) { el.hidden = current !== 'all' && el.dataset.domain !== current; });
        filters.querySelectorAll('button').forEach(function (b) { b.setAttribute('aria-pressed', b.dataset.d === current ? 'true' : 'false'); });
      }
      [['all', 'All']].concat(model.domains.map(function (d) { return [d.id, D().info(d.id).short]; })).forEach(function (f) {
        var b = node('button', 'btn btn--toggle', f[1]);
        b.type = 'button';
        b.dataset.d = f[0];
        b.addEventListener('click', function () { current = f[0]; apply(); });
        filters.appendChild(b);
      });
      apply();
      if (arg) {
        var el = document.getElementById('cmp-' + arg);
        if (el) setTimeout(function () { el.scrollIntoView({ block: 'start' }); }, 0);
      }
    });
  }

  /* --------------------------------------------------------- resource map */

  var QUESTIONS = [
    ['contains', 'What contains it?'], ['dependsOn', 'What does it depend on?'], ['dependents', 'What depends on it?'],
    ['manage', 'Who can manage it?'], ['network', 'How is it networked?'], ['monitor', 'How is it monitored?'],
    ['protect', 'How is it protected?'], ['recover', 'How is it recovered?'], ['cost', 'What does it cost?'],
    ['remove', 'How is it removed safely?']
  ];

  function mapView(root, manifest, arg) {
    root.appendChild(node('h1', null, 'Resource map'));
    root.appendChild(node('p', 'lede',
      'How the resources you administer for ' + window.AcademyExam.code + ' contain and depend on each other. Choose a resource to see the ten questions every lesson answers about it.'));
    root.appendChild(node('p', 'field__note',
      'A conceptual teaching model, not a complete architecture. Containment (what a resource lives in) and dependency (what it needs to work) are different relationships, and both matter when you configure, troubleshoot or delete something.'));

    var layout = node('div', 'resmap');
    var side = node('div', 'resmap__side');
    var detail = node('section', 'resmap__detail');
    detail.setAttribute('aria-live', 'polite');
    detail.setAttribute('aria-label', 'Selected resource');
    layout.appendChild(side);
    layout.appendChild(detail);
    root.appendChild(layout);

    Promise.all([loadResources(), C().load()]).then(function (res) {
      var data = res[0], model = res[1];
      if (!data) { side.appendChild(node('p', 'empty', 'data/resources.json did not load.')); return; }
      var byId = {};
      data.resources.forEach(function (r) { byId[r.id] = r; });
      var buttons = {};

      function btn(id, cls) {
        var r = byId[id];
        var b = node('button', cls || 'resmap__btn', r ? r.name : id);
        b.type = 'button';
        b.dataset.id = id;
        b.addEventListener('click', function () { select(id, true); });
        (buttons[id] = buttons[id] || []).push(b);
        return b;
      }

      /* The containment chain from the brief, as a nested list. */
      side.appendChild(node('h2', null, 'The containment chain'));
      function tree(n) {
        var li = node('li');
        li.appendChild(btn(n.id, 'resmap__btn resmap__btn--tree'));
        if (n.children && n.children.length) {
          var ul = node('ul');
          n.children.forEach(function (ch) { ul.appendChild(tree(ch)); });
          li.appendChild(ul);
        }
        return li;
      }
      var tul = node('ul', 'resmap__tree');
      tul.appendChild(tree(data.tree));
      side.appendChild(tul);

      data.groups.forEach(function (g) {
        side.appendChild(node('h2', null, g.name));
        var row = node('div', 'resmap__group');
        g.ids.forEach(function (id) { row.appendChild(btn(id)); });
        side.appendChild(row);
      });

      function rel(ids) {
        var span = node('span', 'resmap__rel');
        (ids || []).forEach(function (id) { if (byId[id]) span.appendChild(btn(id, 'resmap__chip')); });
        return span;
      }

      function select(id, user) {
        var r = byId[id] || data.resources[0];
        Object.keys(buttons).forEach(function (k) {
          buttons[k].forEach(function (b) { b.setAttribute('aria-pressed', k === r.id ? 'true' : 'false'); });
        });
        detail.textContent = '';
        var home = (r.lessons || []).map(function (l) { return model.lessons[l]; }).filter(Boolean)[0];
        if (home) D().paint(detail, home.domainId);
        var h = node('h2', 'resmap__name', r.name);
        h.setAttribute('tabindex', '-1');
        detail.appendChild(h);
        if (r.type) detail.appendChild(node('p', 'resmap__type', r.type));
        detail.appendChild(node('p', 'resmap__plain', r.plain));
        var dl = node('dl', 'resmap__qs');
        QUESTIONS.forEach(function (q) {
          if (!r.q || !r.q[q[0]]) return;
          dl.appendChild(node('dt', null, q[1]));
          var dd = node('dd', null, r.q[q[0]]);
          var ids = r.rel && r.rel[q[0]];
          if (ids && ids.length) { dd.appendChild(document.createTextNode(' ')); dd.appendChild(rel(ids)); }
          dl.appendChild(dd);
        });
        detail.appendChild(dl);
        if (r.lessons && r.lessons.length) {
          var p = node('p', 'resmap__lessons');
          p.appendChild(node('strong', null, 'Learn it in: '));
          p.appendChild(lessonLinks(model, r.lessons));
          detail.appendChild(p);
        }
        if (user) {
          try { history.replaceState(null, '', '#/map/' + r.id); } catch (e) { /* file:// */ }
          h.focus({ preventScroll: false });
        }
      }
      select(arg && byId[arg] ? arg : data.tree.id, false);
    });
  }

  /* ------------------------------------------------------------- glossary */

  function glossaryView(root) {
    root.appendChild(node('h1', null, 'Glossary'));
    root.appendChild(node('p', 'lede',
      'Every term the lessons introduce, in plain English, with the lesson that teaches it. Official Microsoft names are used, so what you read here is what you will see in the portal and on the exam.'));
    var lab = node('label', 'explore-search');
    lab.appendChild(node('span', null, 'Filter terms '));
    var input = node('input');
    input.type = 'search';
    input.autocomplete = 'off';
    lab.appendChild(input);
    root.appendChild(lab);
    var count = node('p', 'field__note');
    count.setAttribute('aria-live', 'polite');
    root.appendChild(count);
    var dl = node('dl', 'gloss');
    root.appendChild(dl);

    C().load().then(function (model) {
      var by = {};
      model.glossary.forEach(function (g) {
        var k = g.term.toLowerCase();
        (by[k] = by[k] || { term: g.term, defs: [] }).defs.push(g);
      });
      var entries = Object.keys(by).sort().map(function (k) { return by[k]; });
      var rows = entries.map(function (e) {
        var wrap = node('div', 'gloss__item');
        wrap.appendChild(node('dt', null, e.term));
        e.defs.forEach(function (d) {
          var dd = node('dd');
          dd.appendChild(document.createTextNode(d.meaning + ' '));
          var l = model.lessons[d.lessonId];
          if (l) {
            var a = link(d.lessonId, '#/module/' + d.lessonId, 'dom-link');
            a.title = l.title;
            D().paint(a, l.domainId);
            dd.appendChild(a);
          }
          wrap.appendChild(dd);
        });
        wrap.dataset.hay = (e.term + ' ' + e.defs.map(function (d) { return d.meaning; }).join(' ')).toLowerCase();
        dl.appendChild(wrap);
        return wrap;
      });
      function apply() {
        var q = input.value.trim().toLowerCase(), shown = 0;
        rows.forEach(function (r) { var on = !q || r.dataset.hay.indexOf(q) !== -1; r.hidden = !on; if (on) shown++; });
        count.textContent = shown + ' of ' + rows.length + ' terms';
      }
      input.addEventListener('input', apply);
      apply();
    });
  }

  global.AcademyViews = global.AcademyViews || {};
  global.AcademyViews.map = mapView;
  global.AcademyViews.compare = compareView;
  global.AcademyViews.glossary = glossaryView;
  global.AcademyCompare = { render: render };
})(window);
