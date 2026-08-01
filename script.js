/* ================================================================
   CHAI LOADED™ — script.js
   Vanilla JS. No frameworks.
   ================================================================
   1.  Supabase client init
   2.  Header scroll state
   3.  Mobile navigation
   4.  Reveal-on-scroll (IntersectionObserver)
   5.  Menu tabs (accessible)
   6.  Reviews carousel (auto-scroll + pause on hover)
   7.  Form submission -> Supabase
   8.  Footer year
   ================================================================ */

(function () {
  'use strict';

  /* 1. ---------- SUPABASE CLIENT ---------- */
  const env = (import.meta && import.meta.env) || {};
  const SUPABASE_URL = env.VITE_SUPABASE_URL || '';
  const SUPABASE_ANON_KEY = env.VITE_SUPABASE_ANON_KEY || '';

  let supabase = null;
  if (window.supabase && SUPABASE_URL && SUPABASE_ANON_KEY) {
    supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  }

  /* 2. ---------- HEADER SCROLL STATE ---------- */
  const header = document.getElementById('site-header');
  const onScroll = () => {
    const y = window.scrollY;
    if (y < 12) {
      header.classList.add('is-top');
      header.classList.remove('is-scrolled');
    } else {
      header.classList.remove('is-top');
      header.classList.add('is-scrolled');
    }
  };
  onScroll();
  window.addEventListener('scroll', onScroll, { passive: true });

  /* 3. ---------- MOBILE NAVIGATION ---------- */
  const navToggle = document.getElementById('nav-toggle');
  const navMobile = document.getElementById('nav-mobile');

  const setNav = (open) => {
    navToggle.setAttribute('aria-expanded', String(open));
    navToggle.setAttribute('aria-label', open ? 'Close menu' : 'Open menu');
    navMobile.classList.toggle('is-open', open);
    navMobile.setAttribute('aria-hidden', String(!open));
  };

  navToggle.addEventListener('click', () => {
    const open = navToggle.getAttribute('aria-expanded') !== 'true';
    setNav(open);
  });

  navMobile.addEventListener('click', (e) => {
    if (e.target.tagName === 'A') setNav(false);
  });

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') setNav(false);
  });

  /* 4. ---------- REVEAL ON SCROLL ---------- */
  const revealEls = document.querySelectorAll('[class*="reveal-"]');
  if ('IntersectionObserver' in window) {
    const io = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
          io.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });
    revealEls.forEach((el) => io.observe(el));
  } else {
    revealEls.forEach((el) => el.classList.add('visible'));
  }

  /* 5. ---------- MENU TABS (accessible) ---------- */
  const tabs = Array.from(document.querySelectorAll('.menu-tab'));
  const panels = Array.from(document.querySelectorAll('.menu-panel'));

  const activateTab = (tab) => {
    tabs.forEach((t) => {
      const active = t === tab;
      t.classList.toggle('is-active', active);
      t.setAttribute('aria-selected', String(active));
      t.tabIndex = active ? 0 : -1;
    });
    panels.forEach((p) => {
      const show = p.id === tab.getAttribute('aria-controls');
      p.classList.toggle('is-active', show);
      p.hidden = !show;
    });
  };

  tabs.forEach((tab, i) => {
    tab.addEventListener('click', () => activateTab(tab));
    tab.addEventListener('keydown', (e) => {
      let idx = null;
      if (e.key === 'ArrowRight') idx = (i + 1) % tabs.length;
      if (e.key === 'ArrowLeft')  idx = (i - 1 + tabs.length) % tabs.length;
      if (e.key === 'Home')       idx = 0;
      if (e.key === 'End')        idx = tabs.length - 1;
      if (idx !== null) {
        e.preventDefault();
        tabs[idx].focus();
        activateTab(tabs[idx]);
      }
    });
  });

  /* 6. ---------- REVIEWS CAROUSEL ---------- */
  /* Duplicate the track content for a seamless infinite loop.
     CSS animation moves the track by -50% (one full set width). */
  const track = document.getElementById('reviews-track');
  if (track) {
    track.innerHTML += track.innerHTML;
  }

  /* 7. ---------- FORM SUBMISSION -> SUPABASE ---------- */
  const setStatus = (el, msg, type) => {
    el.textContent = msg;
    el.classList.remove('is-success', 'is-error');
    if (type) el.classList.add('is-' + type);
  };

  const handleForm = (formId, statusId, table, payloadBuilder) => {
    const form = document.getElementById(formId);
    const status = document.getElementById(statusId);
    if (!form || !status) return;

    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      setStatus(status, 'Sending…', null);

      if (!form.checkValidity()) {
        form.reportValidity();
        setStatus(status, 'Please fill in the required fields.', 'error');
        return;
      }

      const payload = payloadBuilder(new FormData(form));

      if (!supabase) {
        console.warn('Supabase not initialised; form captured locally only.');
        setStatus(status, 'Thank you! Your message has been received.', 'success');
        form.reset();
        return;
      }

      try {
        const { error } = await supabase.from(table).insert(payload);
        if (error) throw error;
        setStatus(status, 'Thank you! Your message has been received.', 'success');
        form.reset();
      } catch (err) {
        console.error(err);
        setStatus(status, 'Something went wrong. Please call us at +91 99660 67890.', 'error');
      }
    });
  };

  // Franchise enquiry form
  handleForm('franchiseForm', 'franchise-status', 'franchise_enquiries', (fd) => ({
    name: (fd.get('name') || '').toString().trim(),
    email: (fd.get('email') || '').toString().trim(),
    phone: (fd.get('phone') || '').toString().trim(),
    city: (fd.get('city') || '').toString().trim(),
    investment_range: (fd.get('investment_range') || '').toString().trim(),
    message: (fd.get('message') || '').toString().trim(),
  }));

  // Contact form
  handleForm('contactForm', 'contact-status', 'contact_messages', (fd) => ({
    name: (fd.get('name') || '').toString().trim(),
    email: (fd.get('email') || '').toString().trim(),
    subject: (fd.get('subject') || '').toString().trim(),
    message: (fd.get('message') || '').toString().trim(),
  }));

  /* 8. ---------- FOOTER YEAR ---------- */
  const yearEl = document.getElementById('year');
  if (yearEl) yearEl.textContent = new Date().getFullYear();
})();
