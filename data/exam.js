/* data/exam.js - exam identity, as data.

   Everything that makes this Academy AZ-104 rather than another exam lives in
   this file. The engine (assets/js/*, sw.js) reads it and hardcodes none of it,
   so an outline update, or reusing the engine for another certification, means
   editing data, not code.

   It is a script rather than JSON because three readers need it synchronously,
   before anything is fetched: theme.js (to restore the theme without a flash),
   every module that builds a storage key, and the service worker, which loads
   it with importScripts().

   What stays OUT of this file:
     - official domain names and weights    -> content/manifest.json, checked
                                               against the skills snapshot
     - objective bullets and their ids      -> docs/SKILLS-MEASURED-SNAPSHOT.md
                                               and data/objectives/*.json
     - colours                              -> assets/css/tokens.css (--d-NN)

   STORAGE. GitHub Pages project sites share one origin (<user>.github.io), so
   localStorage and Cache Storage are shared by every Academy published under
   the same account. `slug` prefixes every storage key and every cache name.
   Never reuse another Academy's slug. */

(function (g) {
  'use strict';

  g.AcademyExam = {
    code: 'AZ-104',
    slug: 'az104',
    title: 'Microsoft Azure Administrator',
    academy: 'AZ104 Academy',
    repo: 'https://github.com/IronBranded/AZ104-Academy',
    sitePath: '/AZ104-Academy/',
    studyGuide: 'https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/az-104',

    /* The outline version this Academy targets. The study guide can show two
       versions when a change is scheduled; this is the one lessons are written
       against. Shown in the UI as "Aligned to ... skills measured as of". */
    outline: { date: '2026-04-17', label: 'April 17, 2026' },

    /* The exam-information page the outline badge links to (an appendix path
       from content/manifest.json). */
    examInfo: 'content/appendix/a1-exam-information.md',

    /* Short learner-facing labels and icons. Official names and weights are
       NOT here; they come from the manifest. Icons are 16x16 paths stroked with
       currentColor, and differ in silhouette (hexagon, round, cylinder, square,
       triangle of nodes, zig-zag) so domains stay distinguishable without
       colour: Identity blue and Compute purple measure deltaE 4.4 apart under
       simulated protanopia, which is effectively the same colour. */
    domains: {
      '0A': { short: 'Understanding Azure',   abbr: 'FND', exam: false, nav: 'Module 0A \u00b7 Understanding Azure',
              icon: 'M8 1.5a6.5 6.5 0 1 1 0 13a6.5 6.5 0 0 1 0-13zM10.6 5.4 9 9 5.4 10.6 7 7z' },
      '00': { short: 'Safe lab foundations',  abbr: 'LAB', exam: false, nav: 'Module 0B \u00b7 Safe lab foundations',
              icon: 'M8 1.5 14 5v6l-6 3.5L2 11V5z' },
      '01': { short: 'Identity & Governance', abbr: 'IDG', exam: true,
              icon: 'M8 2.2a2.8 2.8 0 1 1 0 5.6a2.8 2.8 0 0 1 0-5.6zM2.6 14c.5-2.9 2.7-4.4 5.4-4.4s4.9 1.5 5.4 4.4' },
      '02': { short: 'Storage',               abbr: 'STO', exam: true,
              icon: 'M3 4c0-1.1 2.2-2 5-2s5 .9 5 2-2.2 2-5 2-5-.9-5-2zM3 4v8c0 1.1 2.2 2 5 2s5-.9 5-2V4M3 8c0 1.1 2.2 2 5 2s5-.9 5-2' },
      '03': { short: 'Compute',               abbr: 'CMP', exam: true,
              icon: 'M4 4h8v8H4zM6.5 6.5h3v3h-3zM6 1.5V4M10 1.5V4M6 12v2.5M10 12v2.5M1.5 6H4M1.5 10H4M12 6h2.5M12 10h2.5' },
      '04': { short: 'Networking',            abbr: 'NET', exam: true,
              icon: 'M8 2a1.6 1.6 0 1 1 0 3.2A1.6 1.6 0 0 1 8 2zM3 10.8a1.6 1.6 0 1 1 0 3.2a1.6 1.6 0 0 1 0-3.2zM13 10.8a1.6 1.6 0 1 1 0 3.2a1.6 1.6 0 0 1 0-3.2zM7.1 5 3.9 10.9M8.9 5l3.2 5.9M4.6 12.4h6.8' },
      '05': { short: 'Monitor & Maintain',    abbr: 'MON', exam: true,
              icon: 'M1.5 8.5h3l1.6-4.5 3.3 9 1.6-4.5h3.5' }
    },

    /* Labs whose resources bill by the hour whether or not you are looking at
       them, keyed by module id, named as the lab names them. The cost planner
       flags these. Add an entry only when the lab itself states the meter. */
    metered: {
      '03-02': 'Virtual machine (B-series) and managed disks',
      '03-03': 'Container Registry (per day) and container groups (per second running)',
      '03-04': 'App Service plan (B1, then S1) per hour',
      '04-01': 'Virtual machine (B-series); a Standard public IP while it exists',
      '04-02': 'Virtual machine (B-series) and a private endpoint (hourly)',
      '04-03': 'Two B-series VMs, a Standard load balancer and public IP (hourly)',
      '05-01': 'Virtual machine (B-series), public IP, and log ingestion',
      '05-02': 'VM for hours, backup storage, Site Recovery replicas and cache storage'
    }
  };
})(typeof self !== 'undefined' ? self : this);
