<template>
  <div>
    <!-- GLOBAL PAGE PRELOADER & INERTIA ROUTE ANIMATION -->
    <PagePreloader />

    <!-- NAVBAR (Editorial Gallery Header) -->
    <nav class="navbar">
      <div class="container navbar__inner">
        <Link href="/" class="navbar__brand" @click="closeMobileMenu">
          <span>Kreasi</span>
          <span class="navbar__brand-badge">EKRAF Probolinggo</span>
        </Link>

        <!-- Desktop Navigation Links -->
        <ul class="navbar__links navbar__links--desktop">
          <li><Link href="/" :class="{ active: currentPath === '/' || currentPath === '' }">Beranda</Link></li>
          <li><Link href="/katalog" :class="{ active: currentPath.startsWith('/katalog') || currentPath.startsWith('/detail') }">Eksplor Ekraf</Link></li>
          <li><Link href="/dashboard" :class="{ active: currentPath.startsWith('/dashboard') }">Dashboard Data</Link></li>
        </ul>

        <!-- Desktop Actions -->
        <div class="navbar__actions--desktop">
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
            <Link
              href="/"
              :class="{ active: currentPath === '/' || currentPath === '' }"
              @click="closeMobileMenu"
              class="mobile-drawer__link"
            >
              <span>Beranda</span>
            </Link>
            <Link
              href="/katalog"
              :class="{ active: currentPath.startsWith('/katalog') || currentPath.startsWith('/detail') }"
              @click="closeMobileMenu"
              class="mobile-drawer__link"
            >
              <span>Eksplor Ekraf</span>
            </Link>
            <Link
              href="/dashboard"
              :class="{ active: currentPath.startsWith('/dashboard') }"
              @click="closeMobileMenu"
              class="mobile-drawer__link"
            >
              <span>Dashboard Data</span>
            </Link>
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
          <div class="footer__brand">Kreasi Ekraf</div>
          <p style="font-size:0.875rem;line-height:1.7;color:var(--clr-muted);max-width:400px;">
            Platform digital premium untuk mengeksplorasi, mengoleksi, dan merayakan karya terbaik dari 17 sub-sektor ekonomi kreatif Indonesia berbasis HAKI.
          </p>
        </div>
        <div>
          <div style="font-family:var(--font-mono);font-weight:700;font-size:0.75rem;text-transform:uppercase;color:var(--clr-charcoal);margin-bottom:0.75rem;">Sub-Sektor Utama</div>
          <ul class="footer__links">
            <li><Link href="/katalog?sektor=kuliner">Kuliner</Link></li>
            <li><Link href="/katalog?sektor=kriya">Kriya</Link></li>
            <li><Link href="/katalog?sektor=fesyen">Fashion</Link></li>
            <li><Link href="/katalog?sektor=seni-rupa">Seni Rupa</Link></li>
            <li><Link href="/katalog?sektor=film">Film, Animasi & Video</Link></li>
          </ul>
        </div>
        <div>
          <div style="font-family:var(--font-mono);font-weight:700;font-size:0.75rem;text-transform:uppercase;color:var(--clr-charcoal);margin-bottom:0.75rem;">Pusat Bantuan</div>
          <ul class="footer__links">
            <li><a href="https://github.com/Gerryrag/ekrafApp/releases/download/ekraf/Kreasi-Ekraf.apk" target="_blank" rel="noopener noreferrer">Download Aplikasi Kreator</a></li>
            <li><a href="#">Hubungi Dinas Kepemudaan Olahraga dan Pariwisata Kota Probolinggo</a></li>
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
</script>

<style scoped>
/* Additional component-specific scopes if needed */
</style>
