<template>
  <MainLayout>
    <div class="error-page">
      <div class="container">
        <div class="error-content">
          <div class="error-code">404</div>
          <h1 class="error-title">Halaman Tidak Ditemukan</h1>
          <p class="error-desc">
            Maaf, halaman yang Anda cari tidak ditemukan atau telah dipindahkan.
          </p>
          <Link href="/" class="btn btn-outline">
            Kembali ke Beranda
          </Link>
        </div>
      </div>
    </div>
  </MainLayout>
</template>

<script setup>
import { Link } from '@inertiajs/vue3';
import MainLayout from '@/Layouts/MainLayout.vue';
</script>

<style scoped>
.error-page {
  padding: 5rem 1.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: calc(100vh - 280px);
  text-align: center;
}

.error-content {
  max-width: 480px;
  margin: 0 auto;
}

.error-code {
  font-family: var(--font-mono);
  font-weight: 700;
  font-size: 2.25rem;
  color: var(--clr-terracotta);
  letter-spacing: 0.05em;
  margin-bottom: 0.5rem;
}

.error-title {
  font-family: var(--font-sans);
  font-weight: 700;
  font-size: 1.5rem;
  color: var(--clr-charcoal);
  margin: 0 0 0.75rem;
}

.error-desc {
  color: var(--clr-muted);
  font-size: 0.95rem;
  margin: 0 0 1.75rem;
  line-height: 1.6;
}
</style>
