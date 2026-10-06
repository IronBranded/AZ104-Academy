/* dashboard.js - Academy engine
   The home page, as a learning dashboard rather than a table of contents.

   It answers, in this order:
     1. What should I study next?            Continue learning
     2. How much of each domain have I done? Domain cards
     3. What needs another look?             Review queue counts

   Every number on this page is an observable count - sub-objectives studied,
   labs completed, sub-objectives whose questions you answered correctly. There
   is deliberately no single readiness percentage and no pass prediction: a
   blended score would hide exactly the gaps the counts expose.

   Units:
     Studied            official sub-objectives whose lesson is marked studied
     Practised          labs completed / labs that exist in the domain
     Knowledge checked  sub-objectives whose questions were all answered
                        correctly on their latest attempt, out of those that
                        have questions (the rest are reported, not hidden) */

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
  function P() { return global.AcademyProgress; }

  /* ------------------------------------------------------------ measures */

  function bulletState(model, b) {
    var lessons = b.lessonIds.map(function (id) { return model.lessons[id]; }).filter(Boolean);
    var studied = lessons.some(function (l) { return P().isComplete('module', l.id); });
    var labLessons = lessons.filter(function (l) { return l.hasLab && l.exam; });
    var lab = !labLessons.length ? 'na' : (labLessons.some(function (l) { return P().isComplete('lab', l.id); }) ? 'done' : 'todo');
    return {
      studied: studied,
      lab: lab,
      check: P().bulletCheck(b.questionIds, b.lessonIds, b.text),
      lessons: lessons
    };
  }

  function domainMeasures(model, dom) {
    var m = { bullets: dom.bulletIds.length, studied: 0, checked: 0, review: 0, withQ: 0, noQ: 0, labs: 0, labsDone: 0, labsValidated: 0, retained: 0, due: 0 };
    dom.bulletIds.forEach(function (bid) {
      var b = model.bulletById[bid];
      var st = bulletState(model, b);
      if (st.studied) m.studied++;
      if (st.check === 'noq') m.noQ++; else m.withQ++;
      if (st.check === 'checked') m.checked++;
      if (st.check === 'review') m.review++;
      var rt = P().retention(b.questionIds).state;
      if (rt === 'retained') m.retained++; else if (rt === 'due') m.due++;
    });
    dom.lessonIds.forEach(function (id) {
      var l = model.lessons[id];
      if (l && l.hasLab) { m.labs++; if (P().isComplete('lab', id)) m.labsDone++; if (P().isValidated(id)) m.labsValidated++; }
    });
    return m;
  }

  function lessonLeft(model, l) {
    var left = [];
    if (!P().isComplete('module', l.id)) left.push('lesson');
    if (l.hasLab && !P().isComplete('lab', l.id)) left.push('lab');
    var c = P().lessonCheck(l.id, l.questionIds);
    if (c !== 'checked' && c !== 'noq') left.push(c === 'review' ? 'review' : 'check');
    return left;
  }

  /* The single recommendation. Last-visited first, so a learner returning to
     the site lands where they stopped; then study order. */
  function recommend(model) {
    var skipFound = P().getPref && P().getPref('skipFoundations');
    var last = P().lastVisit();
    if (last && model.lessons[last.id]) {
      var l = model.lessons[last.id];
      var left = lessonLeft(model, l);
      if (left.length) return { lesson: l, kind: 'continue', left: left, via: last.kind };
    }
    for (var i = 0; i < model.order.length; i++) {
      var x = model.lessons[model.order[i]];
      if (skipFound && x.id.indexOf('0A-') === 0) continue;
      if (!P().isComplete('module', x.id)) return { lesson: x, kind: 'next', left: lessonLeft(model, x) };
    }
    for (var j = 0; j < model.order.length; j++) {
      var y = model.lessons[model.order[j]];
      var c = P().lessonCheck(y.id, y.questionIds);
      if (c === 'none' || c === 'partial' || c === 'review') return { lesson: y, kind: 'check', left: lessonLeft(model, y) };
    }
    return null;
  }

  var LEFT_TEXT = {
    lesson: 'Lesson not marked studied',
    lab: 'Lab not complete',
    check: 'Knowledge check not passed yet',
    review: 'Knowledge check has answers to review'
  };

  /* ------------------------------------------------------------- pieces */

  function meter(label, done, total, note) {
    var row = node('div', 'meter-row');
    var top = node('div', 'meter-row__top');
    top.appendChild(node('span', 'meter-row__label', label));
    top.appendChild(node('span', 'meter-row__val', total ? done + ' / ' + total : '\u2013'));
    row.appendChild(top);
    var bar = node('div', 'meter-row__bar');
    bar.setAttribute('role', 'progressbar');
    bar.setAttribute('aria-label', label);
    bar.setAttribute('aria-valuemin', '0');
    bar.setAttribute('aria-valuemax', String(total || 0));
    bar.setAttribute('aria-valuenow', String(done));
    var fill = node('span', 'meter-row__fill');
    fill.style.width = (total ? Math.round((done / total) * 100) : 0) + '%';
    bar.appendChild(fill);
    row.appendChild(bar);
    if (note) row.appendChild(node('p', 'meter-row__note', note));
    return row;
  }

  function cellState(kind, st) {
    var map = {
      learn: { true: ['done', '\u2713', 'Studied'], false: ['todo', '\u25cb', 'Not yet'] },
      lab: { done: ['done', '\u2713', 'Complete'], todo: ['todo', '\u25cb', 'Not yet'], na: ['na', '\u2013', 'No lab'] },
      check: {
        checked: ['done', '\u2713', 'Checked'], review: ['review', '!', 'Review'], partial: ['todo', '\u25d0', 'In progress'],
        none: ['todo', '\u25cb', 'Not yet'], noq: ['na', '\u2013', 'No questions']
      }
    };
    var v = map[kind][String(st)];
    var s = node('span', 'cell-state');
    s.dataset.state = v[0];
    s.appendChild(node('span', 'cell-state__mark', v[1]));
    s.appendChild(document.createTextNode(' ' + v[2]));
    return s;
  }

  /* The objective-level status table. Used here and on the domain review. */
  function objectiveTable(model, domainId) {
    var dom = model.domainById[domainId];
    var wrap = node('div', 'table-scroll');
    wrap.setAttribute('tabindex', '0'); wrap.setAttribute('role', 'region');   // keyboard-scrollable, as in app.js
    wrap.setAttribute('aria-label', 'Objective status: ' + D().info(domainId).short);
    var t = node('table', 'objtable');
    t.dataset.stack = 'true';
    var thead = node('thead'), hr = node('tr');
    ['Objective', 'Learn', 'Lab', 'Check'].forEach(function (h) { hr.appendChild(node('th', null, h)); });
    hr.firstChild.setAttribute('scope', 'col');
    thead.appendChild(hr);
    t.appendChild(thead);
    var tb = node('tbody');
    dom.objectiveIds.forEach(function (oid) {
      var o = model.objectiveById[oid];
      var gr = node('tr', 'objtable__group');
      var gh = node('th', null, '');
      gh.setAttribute('colspan', '4');
      gh.setAttribute('scope', 'rowgroup');
      gh.appendChild(node('span', 'obj-chip', o.id));
      gh.appendChild(document.createTextNode(' ' + o.text));
      gr.appendChild(gh);
      tb.appendChild(gr);
      o.bulletIds.forEach(function (bid) {
        var b = model.bulletById[bid];
        var st = bulletState(model, b);
        var tr = node('tr');
        var th = node('th');
        th.setAttribute('scope', 'row');
        th.appendChild(node('span', 'obj-chip', b.id));
        var lesson = st.lessons.filter(function (l) { return l.exam; })[0] || st.lessons[0];
        th.appendChild(document.createTextNode(' '));
        if (lesson) th.appendChild(link(b.text, '#/module/' + lesson.id));
        else th.appendChild(document.createTextNode(b.text));
        tr.appendChild(th);
        [['Learn', cellState('learn', st.studied)], ['Lab', cellState('lab', st.lab)], ['Check', cellState('check', st.check)]]
          .forEach(function (c) { var td = node('td'); td.dataset.label = c[0]; td.appendChild(c[1]); tr.appendChild(td); });
        tb.appendChild(tr);
      });
    });
    t.appendChild(tb);
    wrap.appendChild(t);
    return wrap;
  }

  function continueCard(model) {
    var sec = node('section', 'continue');
    sec.setAttribute('aria-labelledby', 'continue-title');
    var r = recommend(model);
    var h = node('h2', null, r && r.kind === 'continue' ? 'Continue learning' : r && r.kind === 'check' ? 'Check what you studied' : 'Start here');
    h.id = 'continue-title';
    sec.appendChild(h);

    if (!r) {
      var done = node('div', 'continue__card');
      done.appendChild(node('p', 'continue__title', 'Every lesson is studied and every knowledge check passed.'));
      done.appendChild(link('Go to Exam prep', '#/prep', 'btn btn--primary'));
      sec.appendChild(done);
      return sec;
    }

    var l = r.lesson;
    var card = node('div', 'continue__card');
    D().paint(card, l.domainId);
    var top = node('div', 'continue__top');
    top.appendChild(D().badge(l.domainId, { weight: l.weight }));
    if (l.objectiveId) top.appendChild(node('span', 'obj-chip', l.objectiveId));
    card.appendChild(top);
    card.appendChild(node('p', 'continue__title', l.title));
    if (l.objectiveText && l.exam) card.appendChild(node('p', 'continue__obj', l.objectiveText));
    else if (!l.exam) card.appendChild(node('p', 'continue__obj', l.id.indexOf('0A-') === 0
      ? 'Module 0A \u00b7 foundation primer. Plain-English background the exam lessons assume; skip it from the card below if you already know it.'
      : 'Module 0B \u00b7 project prerequisite, not exam content. Do it before any billable lab.'));

    if (r.left.length) {
      var ul = node('ul', 'continue__left');
      ul.setAttribute('aria-label', 'Still to do in this lesson');
      r.left.forEach(function (k) { ul.appendChild(node('li', null, LEFT_TEXT[k])); });
      card.appendChild(ul);
    }

    var href = '#/module/' + l.id;
    if (r.via === 'lab' && r.left.indexOf('lab') !== -1) href = '#/lab/' + l.id;
    else if (r.left[0] === 'check' || r.left[0] === 'review') href = '#/module/' + l.id + '/check';
    var go = link(r.kind === 'continue' ? 'Continue' : r.kind === 'check' ? 'Take the knowledge check' : 'Start', href, 'btn btn--primary');
    card.appendChild(go);
    sec.appendChild(card);

    /* Review queue, as counts with a destination. */
    var queue = node('div', 'continue__queue');
    var review = 0;
    model.bullets.forEach(function (b) { if (P().bulletCheck(b.questionIds, b.lessonIds, b.text) === 'review') review++; });
    var later = P().marks().length;
    queue.appendChild(queueItem(review, review === 1 ? 'sub-objective needs review' : 'sub-objectives need review', '#/prep/needs-review'));
    queue.appendChild(queueItem(later, 'in Review later', '#/prep/later'));
    sec.appendChild(queue);
    return sec;
  }

  function queueItem(n, text, href) {
    var a = link('', href, 'queue-item');
    a.dataset.empty = n ? 'false' : 'true';
    a.appendChild(node('span', 'queue-item__n', String(n)));
    a.appendChild(node('span', 'queue-item__t', text));
    return a;
  }

  function domainCard(model, dom) {
    var m = domainMeasures(model, dom);
    var card = node('article', 'dcard');
    D().paint(card, dom.id);
    card.setAttribute('aria-labelledby', 'dcard-' + dom.id);

    var head = node('header', 'dcard__head');
    var h = node('h3', 'dcard__title');
    h.id = 'dcard-' + dom.id;
    h.appendChild(D().icon(dom.id, 18));
    h.appendChild(node('span', null, D().info(dom.id).short));
    head.appendChild(h);
    head.appendChild(node('span', 'dcard__weight', dom.weight.replace('-', '\u2013') + ' of the exam'));
    card.appendChild(head);
    card.appendChild(node('p', 'dcard__official', 'Official: ' + dom.name + ' \u00b7 ' + dom.objectiveIds.length + ' objectives, ' + dom.bulletIds.length + ' sub-objectives'));

    card.appendChild(meter('Studied', m.studied, m.bullets));
    card.appendChild(meter('Practised', m.labsDone, m.labs, m.labs ? null : 'No labs in this domain.'));
    card.appendChild(meter('Validated', m.labsValidated, m.labs, m.labs ? 'Labs whose validation checklist is fully ticked' : null));
    var notes = [];
    if (m.review) notes.push(m.review + ' need review');
    if (m.noQ) notes.push(m.noQ + ' have no questions yet');
    card.appendChild(meter('Knowledge checked', m.checked, m.withQ, notes.join(' \u00b7 ') || null));
    card.appendChild(meter('Retained', m.retained, m.withQ, m.due ? m.due + ' due for a re-test in Exam prep' : 'Answered correctly again ' + P().retainDays + '+ days after first passing'));

    var actions = node('div', 'dcard__actions');
    actions.appendChild(link('Domain review', '#/domain/' + dom.id, 'btn'));
    var nextL = null;
    for (var i = 0; i < dom.lessonIds.length; i++) {
      if (!P().isComplete('module', dom.lessonIds[i])) { nextL = model.lessons[dom.lessonIds[i]]; break; }
    }
    if (nextL) {
      var a = link('Next: ' + nextL.id, '#/module/' + nextL.id, 'btn');
      a.title = nextL.title;
      actions.appendChild(a);
    }
    card.appendChild(actions);

    var det = node('details', 'dcard__detail');
    det.appendChild(node('summary', null, 'Objective status'));
    det.addEventListener('toggle', function once() {
      if (det.open && !det.dataset.built) { det.dataset.built = '1'; det.appendChild(objectiveTable(model, dom.id)); }
    });
    card.appendChild(det);
    return card;
  }

  function moduleZero(model) {
    var ids = model.order.filter(function (id) { return id.indexOf('00-') === 0; });
    if (!ids.length) return null;
    var studied = ids.filter(function (id) { return P().isComplete('module', id); }).length;
    var labs = ids.filter(function (id) { return model.lessons[id].hasLab; });
    var labsDone = labs.filter(function (id) { return P().isComplete('lab', id); }).length;
    var done = studied === ids.length && labsDone === labs.length;

    var box = node('section', 'm0');
    D().paint(box, '00');
    box.dataset.done = done ? 'true' : 'false';
    var h = node('h2', 'm0__title');
    h.appendChild(D().icon('00', 16));
    h.appendChild(node('span', null, 'Module 0B \u00b7 Safe lab foundations'));
    box.appendChild(h);
    box.appendChild(node('p', null, done
      ? 'Budget guardrails, least-privilege access and the teardown template are in place.'
      : 'Not exam content, and not optional: budget alerts, least-privilege lab access and the teardown template come before any billable lab.'));
    box.appendChild(node('p', 'm0__counts', studied + ' / ' + ids.length + ' lessons studied \u00b7 ' + labsDone + ' / ' + labs.length + ' labs complete'));
    if (!done) {
      var first = ids.filter(function (id) { return !P().isComplete('module', id); })[0] || ids[0];
      box.appendChild(link('Open Module 0B', '#/module/' + first, 'btn'));
    }
    return box;
  }

  /* Module 0A: the beginner on-ramp. Recommended first, skippable in one
     click, and never a gate: nothing in the exam domains waits for it. */
  function foundations(model) {
    var ids = model.order.filter(function (id) { return id.indexOf('0A-') === 0; });
    if (!ids.length) return null;
    var studied = ids.filter(function (id) { return P().isComplete('module', id); }).length;
    var skipped = !!P().getPref('skipFoundations');
    var box = node('section', 'm0 m0--foundations');
    D().paint(box, '0A');
    box.dataset.done = (studied === ids.length || skipped) ? 'true' : 'false';
    var h = node('h2', 'm0__title');
    h.appendChild(D().icon('0A', 16));
    h.appendChild(node('span', null, 'Module 0A \u00b7 Understanding Azure'));
    box.appendChild(h);
    box.appendChild(node('p', null, skipped
      ? 'Skipped. The primers stay in the sidebar, and each lesson lists the ones it builds on.'
      : 'New to Azure? Start here. ' + ids.length + ' short primers explain tenants, subscriptions, networks, storage, monitoring and Resource Manager before the exam lessons expect you to administer them.'));
    box.appendChild(node('p', 'm0__counts', studied + ' / ' + ids.length + ' primers studied'));
    var row = node('div', 'dcard__actions');
    if (studied < ids.length && !skipped) {
      var first = ids.filter(function (id) { return !P().isComplete('module', id); })[0];
      row.appendChild(link(studied ? 'Continue the primers' : 'Start the primers', '#/module/' + first, 'btn btn--primary'));
    }
    var skip = node('button', 'btn', skipped ? 'Recommend the primers again' : 'I know the basics: skip the primers');
    skip.type = 'button';
    skip.addEventListener('click', function () {
      P().setPref('skipFoundations', !skipped);
      if (global.AcademyApp) global.AcademyApp.reroute();
    });
    row.appendChild(skip);
    row.appendChild(link('Open the resource map', '#/map', 'btn'));
    box.appendChild(row);
    return box;
  }

  function toolsRow() {
    var nav = node('nav', 'tools-row');
    nav.setAttribute('aria-label', 'Study tools');
    [['Exam prep', '#/prep', 'Review by domain, objective, wrong answers and bookmarks'],
     ['Mock exam', '#/exam', 'Timed, weighted, mixed across every quiz'],
     ['Flashcards', '#/cards', 'Distinctions, spaced repetition'],
     ['Coverage', '#/coverage', 'Every official sub-objective and what teaches it'],
     ['Cost planner', '#/cost', 'Every lab by what it will cost'],
     ['Resource map', '#/map', 'What contains, depends on and protects each resource'],
     ['Compare options', '#/compare', 'Easily confused services, side by side'],
     ['Glossary', '#/glossary', 'Every term the lessons define']
    ].forEach(function (t) {
      var a = link('', t[1], 'tool');
      a.appendChild(node('span', 'tool__name', t[0]));
      a.appendChild(node('span', 'tool__desc', t[2]));
      nav.appendChild(a);
    });
    return nav;
  }

  /* ----------------------------------------------------------------- mount */

  /* "Aligned to <exam> skills measured as of <date>": the outline version is
     exam data (data/exam.js); the badge links to the exam-information page,
     found in the manifest's appendix list by the path data/exam.js names. */
  function outlineBadge(manifest) {
    var E = window.AcademyExam;
    var text = 'Aligned to ' + E.code + ' skills measured as of ' + E.outline.label;
    var idx = -1;
    (manifest.appendix || []).forEach(function (a, i) { if (a.content === E.examInfo) idx = i; });
    var el = idx >= 0 ? node('a', 'outline-badge', text) : node('span', 'outline-badge', text);
    if (idx >= 0) {
      el.href = '#/appendix/' + idx;
      el.title = 'Which outline this Academy follows, and when localized exams change';
    }
    return el;
  }

  function mount(root, manifest) {
    root.textContent = '';
    var head = node('header', 'dash-head');
    head.appendChild(node('h1', null, window.AcademyExam.academy));
    head.appendChild(node('p', 'dash-head__sub',
      'Certification-first study for Exam ' + window.AcademyExam.code + ': ' + window.AcademyExam.title + '. Built from Microsoft Learn documentation, mapped to the official skills outline.'));
    head.appendChild(outlineBadge(manifest));
    root.appendChild(head);

    var loading = node('p', 'loading', 'Loading the curriculum\u2026');
    root.appendChild(loading);

    return global.AcademyCurriculum.load(manifest).then(function (model) {
      loading.remove();
      if (!model.snapshotOk) {
        root.appendChild(node('div', 'empty',
          'docs/SKILLS-MEASURED-SNAPSHOT.md could not be read, so objective-level progress is unavailable. Lessons still work from the sidebar.'));
      }
      root.appendChild(continueCard(model));
      var m0 = moduleZero(model);
      var f0 = foundations(model);

      var ds = node('section', 'domains');
      ds.setAttribute('aria-labelledby', 'domains-title');
      var h2 = node('h2', null, window.AcademyExam.code + ' domains');
      h2.id = 'domains-title';
      ds.appendChild(h2);
      ds.appendChild(node('p', 'lede',
        'Counts are observable: a sub-objective is studied when its lesson is marked studied and checked when every question on it was answered correctly on the latest attempt; a lab is validated when its validation checklist is ticked and practised when its teardown is ticked too; retained means answered correctly again at least ' + P().retainDays + ' days later. There is no pass prediction.'));
      var grid = node('div', 'dgrid');
      model.domains.forEach(function (d) { grid.appendChild(domainCard(model, d)); });
      ds.appendChild(grid);

      /* Module 0 sits above the domains until it is done - unless the
         Continue card is already pointing into it, which says the same. */
      var r = recommend(model);
      var zeroFirst = m0 && m0.dataset.done !== 'true' && !(r && !r.lesson.exam);
      if (f0) root.appendChild(f0);
      if (zeroFirst) root.appendChild(m0);
      root.appendChild(ds);
      if (m0 && !zeroFirst) root.appendChild(m0);
      root.appendChild(toolsRow());
      root.appendChild(P().controls(manifest));
    }).catch(function (e) {
      loading.textContent = 'The dashboard could not load: ' + (e && e.message || e);
    });
  }

  global.AcademyDashboard = {
    mount: mount,
    objectiveTable: objectiveTable,
    bulletState: bulletState,
    domainMeasures: domainMeasures
  };
})(window);
