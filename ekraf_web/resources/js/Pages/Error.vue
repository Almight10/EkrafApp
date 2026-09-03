<template>
  <MainLayout>
    <div class="error-page">
      <div class="container">
        <div class="error-box">
          <div class="error-code">404</div>
          <h1 class="display-lg error-title">
            Ops! Halaman Ini <span class="serif-italic">Belum Ditemukan</span>
          </h1>
          <p class="error-desc">
            Maaf, halaman yang Anda cari tidak ditemukan atau telah dipindahkan.
          </p>
          <div class="error-action">
            <Link href="/" class="btn btn-primary btn-lg">
              Kembali ke Beranda
            </Link>
          </div>
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
  padding: 6rem 1.5rem;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: calc(100vh - 280px);
}

.error-box {
  background: #ffffff;
  border: 1px solid var(--clr-charcoal);
  box-shadow: 6px 6px 0px rgba(28, 25, 23, 0.85);
  border-radius: 4px;
  padding: 3.5rem 2rem;
  max-width: 560px;
  margin: 0 auto;
  text-align: center;
}

.error-code {
  font-family: var(--font-serif);
  font-weight: 800;
  font-size: clamp(4rem, 10vw, 6.5rem);
  color: var(--clr-terracotta);
  line-height: 1;
  margin-bottom: 0.5rem;
  text-shadow: 4px 4px 0px rgba(28, 25, 23, 0.9);
}

.error-title {
  color: var(--clr-charcoal);
  margin: 0.5rem 0 1rem;
  font-size: clamp(1.5rem, 4vw, 2.25rem);
}

.error-desc {
  color: var(--clr-muted);
  font-size: 1rem;
  margin: 0 0 2rem;
  line-height: 1.6;
}

.error-action {
  display: flex;
  justify-content: center;
}
</style>
