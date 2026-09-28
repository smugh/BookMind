/**
 * BookMind - Ultra-Minimalist Interactivity
 */

document.addEventListener('DOMContentLoaded', () => {
  // Mobile Nav Toggle
  const navToggle = document.getElementById('navToggle');
  const navLinks = document.getElementById('navLinks');

  if (navToggle && navLinks) {
    navToggle.addEventListener('click', () => {
      navLinks.classList.toggle('mobile-open');
      navToggle.textContent = navLinks.classList.contains('mobile-open') ? '✕' : '☰';
    });

    navLinks.querySelectorAll('.nav-link').forEach(link => {
      link.addEventListener('click', () => {
        navLinks.classList.remove('mobile-open');
        navToggle.textContent = '☰';
      });
    });
  }

  // User Guideline Step Switcher
  const stepCards = document.querySelectorAll('.step-card');
  const stepContents = document.querySelectorAll('.guide-step-content');
  const guidePreviewImg = document.getElementById('guidePreviewImg');

  const stepImages = {
    '1': 'assets/home_library.png',
    '2': 'assets/reader_highlight.png',
    '3': 'assets/notes_modal.png',
    '4': 'assets/knowledge_hub.png'
  };

  stepCards.forEach(card => {
    card.addEventListener('click', () => {
      stepCards.forEach(c => c.classList.remove('active'));
      card.classList.add('active');

      const step = card.getAttribute('data-step');
      stepContents.forEach(content => {
        content.classList.toggle('active', content.getAttribute('id') === `guide-step-${step}`);
      });

      if (guidePreviewImg && stepImages[step]) {
        guidePreviewImg.src = stepImages[step];
      }
    });
  });

  // UI Modal Preview
  const modal = document.getElementById('uiModal');
  const modalImg = document.getElementById('modalImg');
  const modalTitle = document.getElementById('modalTitle');
  const closeModal = document.getElementById('closeModal');

  document.querySelectorAll('.ui-card').forEach(card => {
    card.addEventListener('click', () => {
      const img = card.querySelector('img');
      const label = card.querySelector('.ui-label')?.textContent || '';
      if (modal && modalImg) {
        modalImg.src = img.src;
        modalTitle.textContent = label;
        modal.classList.add('open');
      }
    });
  });

  const hideModal = () => {
    modal?.classList.remove('open');
  };

  closeModal?.addEventListener('click', hideModal);
  modal?.addEventListener('click', e => { if (e.target === modal) hideModal(); });
  document.addEventListener('keydown', e => { if (e.key === 'Escape') hideModal(); });

  // Smooth Scroll
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
      const target = document.querySelector(this.getAttribute('href'));
      if (target) {
        e.preventDefault();
        window.scrollTo({
          top: target.offsetTop - 60,
          behavior: 'smooth'
        });
      }
    });
  });
});
