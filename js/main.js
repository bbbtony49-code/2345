// ===== 舒苑飲食文化 - 主要 JavaScript =====

// ===== Navigation Scroll Effect =====
window.addEventListener('scroll', () => {
    const nav = document.querySelector('nav');
    if (nav) {
        if (window.scrollY > 50) {
            nav.classList.add('scrolled');
        } else {
            nav.classList.remove('scrolled');
        }
    }
});

// ===== Smooth Scroll for Anchor Links =====
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        const href = this.getAttribute('href');
        
        // Skip if it's just "#" or empty
        if (href === '#' || href === '') return;
        
        const target = document.querySelector(href);
        if (target) {
            e.preventDefault();
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// ===== Mobile Navigation Toggle =====
const navToggle = document.querySelector('.nav-toggle');
const navLinks = document.querySelector('.nav-links');

if (navToggle && navLinks) {
    navToggle.addEventListener('click', () => {
        const expanded = navToggle.getAttribute('aria-expanded') === 'true';
        navToggle.setAttribute('aria-expanded', String(!expanded));
        navToggle.classList.toggle('active');
        navLinks.classList.toggle('active');
    });

    navLinks.querySelectorAll('a').forEach(link => {
        link.addEventListener('click', () => {
            if (navLinks.classList.contains('active')) {
                navLinks.classList.remove('active');
                navToggle.classList.remove('active');
                navToggle.setAttribute('aria-expanded', 'false');
            }
        });
    });
}

// ===== FAQ Accordion Enhancement =====
const faqItems = document.querySelectorAll('.faq-item');

faqItems.forEach(item => {
    item.addEventListener('toggle', function() {
        if (this.open) {
            // Optional: Close other open items (single-open behavior)
            // Uncomment the following lines if you want only one FAQ open at a time
            /*
            faqItems.forEach(otherItem => {
                if (otherItem !== this && otherItem.open) {
                    otherItem.open = false;
                }
            });
            */
        }
    });
});

// ===== Image Lazy Loading =====
if ('loading' in HTMLImageElement.prototype) {
    // Browser supports native lazy loading
    const images = document.querySelectorAll('img[loading="lazy"]');
    images.forEach(img => {
        if (img.dataset.src) {
            img.src = img.dataset.src;
        }
    });
} else {
    // Fallback for browsers that don't support native lazy loading
    const script = document.createElement('script');
    script.src = 'https://cdnjs.cloudflare.com/ajax/libs/lazysizes/5.3.2/lazysizes.min.js';
    document.body.appendChild(script);
}

// ===== Reveal Animations on Scroll =====
const revealElements = document.querySelectorAll('.reveal');

if (revealElements.length > 0) {
    const revealObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('active');
                revealObserver.unobserve(entry.target);
            }
        });
    }, {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    });

    revealElements.forEach(el => revealObserver.observe(el));
}

// ===== Console Message =====
console.log('%c舒苑飲食文化 | Luxury Private Chef', 'color: #C9A227; font-size: 20px; font-weight: bold;');
console.log('%cWebsite by Professional Development Team', 'color: #888; font-size: 12px;');

// ===== Performance Optimization =====
// Debounce function for scroll events
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Apply debounce to scroll events
window.addEventListener('scroll', debounce(() => {
    // Add any scroll-dependent logic here
}, 100));

// ===== External Links Security =====
// Add target="_blank" and rel="noopener" to all external links
document.querySelectorAll('a[href^="http"]').forEach(link => {
    if (!link.href.includes(window.location.hostname)) {
        link.setAttribute('target', '_blank');
        link.setAttribute('rel', 'noopener noreferrer');
    }
});

// ===== Accessibility Enhancement =====
// Add aria-label to floating buttons
const floatingBtns = document.querySelectorAll('.floating-btn');
floatingBtns.forEach(btn => {
    if (btn.getAttribute('href').includes('tel:')) {
        btn.setAttribute('aria-label', '致電預約');
    } else if (btn.getAttribute('href').includes('line.me')) {
        btn.setAttribute('aria-label', 'LINE 諮詢');
    }
});

// ===== Service Cards Hover Effect =====
const serviceCards = document.querySelectorAll('.service-card');
serviceCards.forEach(card => {
    card.addEventListener('mouseenter', function() {
        this.style.zIndex = '10';
    });
    
    card.addEventListener('mouseleave', function() {
        this.style.zIndex = '1';
    });
});

// ===== Counter Animation (Optional) =====
const counters = document.querySelectorAll('.counter');

if (counters.length > 0) {
    const counterObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const counter = entry.target;
                const target = parseInt(counter.getAttribute('data-target'), 10);
                const suffix = counter.getAttribute('data-suffix') || '';
                const duration = 1800;
                const step = target / (duration / 16);
                let current = 0;

                const updateCounter = () => {
                    current += step;
                    if (current < target) {
                        counter.textContent = Math.ceil(current) + suffix;
                        requestAnimationFrame(updateCounter);
                    } else {
                        counter.textContent = target + suffix;
                    }
                };

                updateCounter();
                counterObserver.unobserve(counter);
            }
        });
    }, {
        threshold: 0.5
    });

    counters.forEach(counter => counterObserver.observe(counter));
}

// ===== Back to Top Button (Optional) =====
// You can add a back-to-top button functionality here if needed

// ===== Form Validation (Optional) =====
// You can add form validation functionality here if needed

// ===== Google Analytics Integration (Optional) =====
// Add your Google Analytics tracking code here if needed

// ===== End of File =====


// ===== Sidebar Navigation Toggle =====
document.addEventListener('DOMContentLoaded', () => {
    const sidebarOverlay = document.querySelector('.sidebar-overlay');
    const sidebarNav = document.querySelector('.sidebar-nav');
    const navToggle = document.querySelector('.nav-toggle');

    // 診斷信息
    console.log('🔍 側邊菜單初始化檢查：');
    console.log('✓ navToggle:', navToggle ? '✅ 找到' : '❌ 未找到');
    console.log('✓ sidebarNav:', sidebarNav ? '✅ 找到' : '❌ 未找到');
    console.log('✓ sidebarOverlay:', sidebarOverlay ? '✅ 找到' : '❌ 未找到');

    if (navToggle && sidebarNav && sidebarOverlay) {
        console.log('✅ 所有元素已找到，開始綁定事件...');

        // Toggle 漢堡菜單
        navToggle.addEventListener('click', (e) => {
            e.preventDefault();
            e.stopPropagation();
            
            const isActive = sidebarNav.classList.contains('active');
            console.log('🔄 漢堡菜單點擊 - 當前狀態:', isActive ? 'active' : 'inactive');
            
            sidebarNav.classList.toggle('active');
            sidebarOverlay.classList.toggle('active');
            navToggle.setAttribute('aria-expanded', String(!isActive));
            navToggle.classList.toggle('active');
            
            console.log('✓ 狀態已切換 - 新狀態:', sidebarNav.classList.contains('active') ? 'active' : 'inactive');
        });

        // 點擊蒙層關閉菜單
        sidebarOverlay.addEventListener('click', (e) => {
            e.preventDefault();
            console.log('🖱️  蒙層點擊 - 關閉菜單');
            
            sidebarNav.classList.remove('active');
            sidebarOverlay.classList.remove('active');
            navToggle.classList.remove('active');
            navToggle.setAttribute('aria-expanded', 'false');
        });

        // 點擊菜單項目後關閉
        sidebarNav.querySelectorAll('a').forEach((link, index) => {
            link.addEventListener('click', (e) => {
                console.log(`🔗 菜單項目 #${index + 1} 點擊:`, link.href);
                
                // 延遲關閉菜單，讓導航先執行
                setTimeout(() => {
                    sidebarNav.classList.remove('active');
                    sidebarOverlay.classList.remove('active');
                    navToggle.classList.remove('active');
                    navToggle.setAttribute('aria-expanded', 'false');
                }, 100);
            });
        });

        console.log('✅ 所有事件綁定完成！');
    } else {
        console.error('❌ 側邊菜單初始化失敗 - 缺少必要元素');
        if (!navToggle) console.error('  - navToggle 未找到');
        if (!sidebarNav) console.error('  - sidebarNav 未找到');
        if (!sidebarOverlay) console.error('  - sidebarOverlay 未找到');
    }
});

