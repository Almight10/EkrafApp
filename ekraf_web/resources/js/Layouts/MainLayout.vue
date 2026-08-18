<template>
  <div>
    <!-- GLOBAL PAGE PRELOADER & INERTIA ROUTE ANIMATION -->
    <PagePreloader />

    <!-- NAVBAR (Editorial Gallery Header) -->
    <nav class="navbar">
      <div class="container navbar__inner">
        <a href="/" class="navbar__brand" @click="closeMobileMenu">
          <span>Kreasi</span>
          <span class="navbar__brand-badge">EKRAF Probolinggo</span>
        </a>

        <!-- Desktop Navigation Links -->
        <ul class="navbar__links navbar__links--desktop">
          <li><a href="/" :class="{ active: currentPath === '/' || currentPath === '' }">Beranda</a></li>
          <li><a href="/katalog" :class="{ active: currentPath.startsWith('/katalog') }">Katalog Karya</a></li>
        </ul>

        <!-- Desktop Actions -->
        <div class="navbar__actions--desktop">
          <!-- <button @click="testLoading" class="btn btn-outline btn-sm" title="Uji Coba Animasi Loading">Preview Loading</button> -->
          <a href="/katalog" class="btn btn-primary btn-sm">Cari Karya</a>
        </div>

        <!-- Mobile Hamburger Toggle Button -->
        <button
          class="navbar__hamburger"
          @click="toggleMobileMenu"
          :aria-expanded="isMobileMenuOpen"
          aria-label="Toggle Navigation Menu"
        >
          <span class="hamburger-icon" :class="{ 'hamburger-icon--open': isMobileMenuOpen }">
            <span></span>
            <span></span>
            <span></span>
          </span>
        </button>
      </div>

      <!-- Mobile Navigation Drawer -->
      <transition name="mobile-menu-slide">
        <div v-if="isMobileMenuOpen" class="mobile-drawer">
          <div class="mobile-drawer__links">
            <a
              href="/"
              :class="{ active: currentPath === '/' || currentPath === '' }"
              @click="closeMobileMenu"
              class="mobile-drawer__link"
            >
              <span>Beranda</span>
            </a>
            <a
              href="/katalog"
              :class="{ active: currentPath.startsWith('/katalog') }"
              @click="closeMobileMenu"
              class="mobile-drawer__link"
            >
              <span>Katalog Karya</span>
            </a>
          </div>

          <div class="mobile-drawer__actions">
            <a href="/katalog" @click="closeMobileMenu" class="btn btn-primary btn-lg" style="width: 100%; text-align: center;">
              Cari Karya
            </a>
          </div>
        </div>
      </transition>
    </nav>

    <!-- Mobile Overlay Backdrop -->
    <div
      v-if="isMobileMenuOpen"
      class="mobile-menu-overlay"
      @click="closeMobileMenu"
    ></div>

    <!-- PAGE CONTENT SLOT -->
    <main>
      <slot />
    </main>

    <!-- FOOTER (Warm Blush Cream Editorial Footer) -->
    <footer class="footer">
      <div class="container footer__inner">
        <div>
          <div class="footer__brand">Ekraf</div>
          <p style="font-size:0.875rem;line-height:1.7;color:var(--clr-muted);max-width:400px;">
            Platform digital premium untuk mengeksplorasi, mengoleksi, dan merayakan karya terbaik dari 17 sub-sektor ekonomi kreatif Indonesia berbasis HAKI.
          </p>
        </div>
        <div>
          <div style="font-family:var(--font-mono);font-weight:700;font-size:0.75rem;text-transform:uppercase;color:var(--clr-charcoal);margin-bottom:0.75rem;">Sub-Sektor Utama</div>
          <ul class="footer__links">
            <li><a href="/katalog?sektor=kuliner">Kuliner</a></li>
            <li><a href="/katalog?sektor=kriya">Kriya</a></li>
            <li><a href="/katalog?sektor=fesyen">Fashion</a></li>
            <li><a href="/katalog?sektor=seni-rupa">Seni Rupa</a></li>
            <li><a href="/katalog?sektor=film">Film, Animasi & Video</a></li>
          </ul>
        </div>
        <div>
          <div style="font-family:var(--font-mono);font-weight:700;font-size:0.75rem;text-transform:uppercase;color:var(--clr-charcoal);margin-bottom:0.75rem;">Pusat Bantuan</div>
          <ul class="footer__links">
            <li><a href="https://github.com/Gerryrag/ekrafApp/releases/latest/download/app-release.apk" target="_blank" rel="noopener noreferrer">Download Aplikasi Kreator</a></li>
            <li><a href="#">Hubungi Dinas Ekraf</a></li>
          </ul>
        </div>
      </div>

      <div class="container footer__copy">
        <div>© 2026 Platform Ekraf HAKI Kota Probolinggo. All Rights Reserved.</div>
        <div class="footer__legal-links">
          <a href="#">Terms of Service</a>
          <a href="#">Privacy Policy</a>
          <a href="#">HAKI Guide</a>
          <a href="#">Support</a>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { Link, usePage } from '@inertiajs/vue3';
import PagePreloader from '@/Components/PagePreloader.vue';

const page = usePage();
const isMobileMenuOpen = ref(false);

const currentPath = computed(() => {
  return page.url || '/';
});

function toggleMobileMenu() {
  isMobileMenuOpen.value = !isMobileMenuOpen.value;
}

function closeMobileMenu() {
  isMobileMenuOpen.value = false;
}

function testLoading() {
  if (typeof window !== 'undefined' && window.triggerEkrafLoader) {
    window.triggerEkrafLoader(1500);
  }
}

function handleTestLoadingMobile() {
  closeMobileMenu();
  testLoading();
}
</script>
