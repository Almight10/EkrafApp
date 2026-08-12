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
          <li><Link href="/" :class="{ active: currentPath === '/' }">Beranda</Link></li>
          <li><Link href="/katalog" :class="{ active: currentPath.startsWith('/katalog') }">Katalog Karya</Link></li>
        </ul>

        <!-- Desktop Actions -->
        <div class="navbar__actions--desktop">
          <button @click="testLoading" class="btn btn-outline btn-sm" title="Uji Coba Animasi Loading">⚡ Preview Loading</button>
          <Link href="/katalog" class="btn btn-primary btn-sm">🔍 Cari Karya</Link>
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
              :class="{ active: currentPath === '/' }"
              @click="closeMobileMenu"
              class="mobile-drawer__link"
            >
              <span>🏠 Beranda</span>
              <span>→</span>
            </Link>
            <Link
              href="/katalog"
              :class="{ active: currentPath.startsWith('/katalog') }"
              @click="closeMobileMenu"
              class="mobile-drawer__link"
            >
              <span>🎨 Katalog Karya</span>
              <span>→</span>
            </Link>
            <a
              href="/katalog?sektor=kuliner"
              @click="closeMobileMenu"
              class="mobile-drawer__link mobile-drawer__link--sub"
            >
              <span>🍴 Sub-Sektor Ekraf</span>
              <span>→</span>
            </a>
            <a
              href="#tentang"
              @click="closeMobileMenu"
              class="mobile-drawer__link mobile-drawer__link--sub"
            >
              <span>📜 Daftar & Info HAKI</span>
              <span>→</span>
            </a>
          </div>

          <div class="mobile-drawer__actions">
            <Link href="/katalog" @click="closeMobileMenu" class="btn btn-primary btn-lg" style="width: 100%; text-align: center;">
              🔍 Cari Karya Creative
            </Link>
            <button @click="handleTestLoadingMobile" class="btn btn-outline btn-lg" style="width: 100%; text-align: center;">
              ⚡ Preview Loading Animation
            </button>
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
            <li><Link href="/katalog?sektor=kuliner">Kuliner Nusantara</Link></li>
            <li><Link href="/katalog?sektor=kriya">Kriya & Craft</Link></li>
            <li><Link href="/katalog?sektor=fesyen">Fesyen & Woven</Link></li>
            <li><Link href="/katalog?sektor=seni-rupa">Seni Rupa & Visual</Link></li>
          </ul>
        </div>
        <div>
          <div style="font-family:var(--font-mono);font-weight:700;font-size:0.75rem;text-transform:uppercase;color:var(--clr-charcoal);margin-bottom:0.75rem;">Pusat Bantuan</div>
          <ul class="footer__links">
            <li><a href="#">Daftar Sebagai Pengrajin</a></li>
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
