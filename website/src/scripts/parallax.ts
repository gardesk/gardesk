import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export function initParallax() {
  // Check for reduced motion preference
  const prefersReducedMotion = window.matchMedia(
    '(prefers-reduced-motion: reduce)'
  ).matches;

  if (prefersReducedMotion) {
    // Disable snap scroll for reduced motion users
    document.documentElement.style.scrollSnapType = 'none';
    return;
  }

  // Hero parallax background
  const parallaxBg = document.querySelector('[data-parallax="bg"]');
  if (parallaxBg) {
    gsap.to(parallaxBg, {
      yPercent: 30,
      ease: 'none',
      scrollTrigger: {
        trigger: '#hero',
        start: 'top top',
        end: 'bottom top',
        scrub: 1
      }
    });
  }

  // Section entry animations
  const sections = gsap.utils.toArray<HTMLElement>('.snap-section');

  sections.forEach((section, index) => {
    // Skip hero section
    if (index === 0) return;

    const content = section.querySelector('.max-w-6xl, .max-w-4xl');
    if (!content) return;

    gsap.from(content, {
      opacity: 0,
      y: 40,
      duration: 0.8,
      ease: 'power2.out',
      scrollTrigger: {
        trigger: section,
        start: 'top 80%',
        toggleActions: 'play none none reverse'
      }
    });
  });

  // Image placeholder hover effects
  const placeholders = document.querySelectorAll('.image-placeholder');
  placeholders.forEach(placeholder => {
    placeholder.addEventListener('mouseenter', () => {
      gsap.to(placeholder, {
        scale: 1.02,
        duration: 0.3,
        ease: 'power2.out'
      });
    });

    placeholder.addEventListener('mouseleave', () => {
      gsap.to(placeholder, {
        scale: 1,
        duration: 0.3,
        ease: 'power2.out'
      });
    });
  });

  // Feature cards stagger animation
  const featureCards = gsap.utils.toArray<HTMLElement>('.feature-card');
  if (featureCards.length > 0) {
    gsap.from(featureCards, {
      opacity: 0,
      y: 30,
      stagger: 0.1,
      duration: 0.6,
      ease: 'power2.out',
      scrollTrigger: {
        trigger: '#features',
        start: 'top 70%',
        toggleActions: 'play none none reverse'
      }
    });
  }
}

// Initialize on DOM ready
if (typeof window !== 'undefined') {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initParallax);
  } else {
    initParallax();
  }
}
