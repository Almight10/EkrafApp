<template>
  <MainLayout>
    <!-- HERO SECTION -->
    <section class="hero">
      <div class="container">
        <div class="hero__inner">
          <!-- Left: Headlines & CTAs -->
          <div class="animate-in">
            <h1 class="display-xl" style="margin:0 0 1.25rem;">
              Rayakan <span class="serif-italic">Kreativitas</span><br>Anak Bangsa
            </h1>
            <p class="hero__desc">
              Platform digital premium untuk mengeksplorasi, mengoleksi, dan merayakan karya terbaik dari 17 sub-sektor ekonomi kreatif Indonesia berbasis Hak Kekayaan Intelektual.
            </p>
            <div class="hero__actions">
              <a href="/katalog" class="btn btn-primary btn-lg">Mulai Eksplorasi</a>
              <a href="https://github.com/Gerryrag/ekrafApp/raw/main/app-release.apk" target="_blank" download class="btn btn-outline btn-lg">📱 Daftar Kreator</a>
            </div>
          </div>

          <!-- Right: Gallery Polaroid Photo Stack -->
          <div class="hero__photo-stack animate-in delay-200">
            <div
              v-for="(card, idx) in heroCards"
              :key="card.id || idx"
              :class="['hero__photo-card', `hero__photo-card--${idx + 1}`]"
              @click="openCardDetail(card)"
              :title="`Lihat detail ${card.title}`"
            >
              <div v-if="card.haki" class="hero__photo-badge">✓ HAKI</div>
              <img
                :src="card.image"
                :alt="card.title"
                @error="onHeroImgError($event, idx)"
              />
              <div class="hero__photo-caption">
                <span class="hero__photo-title">{{ card.title }}</span>
                <span class="hero__photo-sub">{{ card.subSektor }} • 2026</span>
              </div>
            </div>
          </div>
        </div>

        <!-- HERO STATS BANNER -->
        <div class="hero__stats-banner animate-in delay-300">
          <div>
            <div class="hero__stat-value">{{ stats.total }}</div>
            <div class="hero__stat-label">Pelaku Ekraf</div>
          </div>
          <div>
            <div class="hero__stat-value">17</div>
            <div class="hero__stat-label">Sub-Sektor</div>
          </div>
          <div>
            <div class="hero__stat-value">{{ stats.haki }}</div>
            <div class="hero__stat-label">Karya Terkurasi</div>
          </div>
        </div>
      </div>
    </section>

    <!-- SUB-SEKTOR BENTO GRID -->
    <section class="section">
      <div class="container">
        <div class="section-header">
          <div>
            <h2 class="display-lg">Jelajahi <span class="serif-italic">Sub-Sektor</span></h2>
          </div>
          <div style="max-width:380px;font-size:0.875rem;color:var(--clr-muted);">
            Keberagaman karya anak bangsa yang mewakili identitas budaya dan inovasi modern.
          </div>
        </div>

        <div class="bento-grid">
          <!-- Kuliner Card (Big Terracotta) -->
          <div class="bento-card bento-card--kuliner" @click="goToKatalog('kuliner')">
            <div class="bento-card__icon">🍴</div>
            <div>
              <h3 class="bento-card__title">Kuliner</h3>
              <p class="bento-card__desc">Cita rasa nusantara dengan sentuhan inovasi & sertifikasi legalitas.</p>
            </div>
          </div>

          <!-- Fesyen Card (Yellow) -->
          <div class="bento-card bento-card--fesyen" @click="goToKatalog('fesyen')">
            <div class="bento-card__icon">👕</div>
            <div>
              <h3 class="bento-card__title">Fesyen</h3>
              <p class="bento-card__desc" style="color:var(--clr-charcoal);">Batik, tenun & rancangan busana modern.</p>
            </div>
          </div>

          <!-- Kriya Card (White) -->
          <div class="bento-card bento-card--kriya" @click="goToKatalog('kriya')">
            <div class="bento-card__icon">🪡</div>
            <div>
              <h3 class="bento-card__title">Kriya</h3>
              <p class="bento-card__desc">Kerajinan tangan berkualitas tinggi.</p>
            </div>
          </div>

          <!-- Seni Rupa Card (Blush Pink) -->
          <div class="bento-card bento-card--seni-rupa" @click="goToKatalog('seni-rupa')">
            <div class="bento-card__icon">🎨</div>
            <div>
              <h3 class="bento-card__title">Seni Rupa</h3>
              <p class="bento-card__desc">Eksplorasi visual tanpa batas dari seniman lokal terkurasi.</p>
            </div>
          </div>

          <!-- Film & Animasi Card (White) -->
          <div class="bento-card bento-card--film" @click="goToKatalog('film')">
            <div class="bento-card__icon">🎬</div>
            <div>
              <h3 class="bento-card__title">Film & Animasi</h3>
              <p class="bento-card__desc">Karya audio visual bereputasi.</p>
            </div>
          </div>

          <!-- +12 Lainnya (Dark Teal) -->
          <div class="bento-card bento-card--more" @click="goToKatalog('')">
            +12 Sektor Lainnya →
          </div>
        </div>
      </div>
    </section>

    <!-- KARYA PILIHAN (NEW ARRIVALS) -->
    <section class="section section-alt">
      <div class="container">
        <div class="section-header">
          <div>
            <h2 class="display-lg">Karya <span class="serif-italic">Pilihan</span></h2>
          </div>
          <a href="/katalog" class="btn btn-outline btn-sm">Lihat Semua Karya →</a>
        </div>

        <div v-if="loading" class="spinner"></div>
        <div v-else class="grid-catalog">
          <ProductCard v-for="produk in newArrivals" :key="produk.id" :produk="produk" :is-new="true" />
        </div>
      </div>
    </section>

    <!-- TILTED CTA BANNER SECTION -->
    <section class="cta-section" id="tentang">
      <div class="container">
        <div class="cta-banner">
          <h2 class="display-lg" style="margin-bottom:1rem;">
            Jadilah Bagian dari<br><span class="serif-italic">Pergerakan</span>
          </h2>
          <p style="color:var(--clr-muted);line-height:1.7;margin-bottom:2rem;font-size:0.95rem;">
            Daftarkan portofolio Anda, verifikasi Hak Kekayaan Intelektual (HAKI), dan temukan audiens global untuk karya terbaik Anda.
          </p>
          <a href="/katalog" class="btn btn-primary btn-lg">Gabung ke Galeri →</a>
        </div>
      </div>
    </section>
  </MainLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { router } from '@inertiajs/vue3';
import { supabase, isSupabaseConfigured, normalizeEkrafData, isApprovedEkrafData } from '../supabase.js';
import { dummyProducts } from '../dummyData.js';
import MainLayout from '../Layouts/MainLayout.vue';
import ProductCard from '../Components/ProductCard.vue';

const loading = ref(true);
const newArrivals = ref([]);
const stats = ref({ total: '15.000+', haki: '5.000+' });

const fallbackArtworks = [
  'data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="400" height="480" viewBox="0 0 400 480"><defs><linearGradient id="g1" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stop-color="%23c04828"/><stop offset="100%" stop-color="%231c1917"/></linearGradient></defs><rect width="100%" height="100%" fill="url(%23g1)"/><circle cx="200" cy="180" r="90" fill="none" stroke="%23f5b72b" stroke-width="6" opacity="0.8"/><text x="50%" y="80%" font-family="serif" font-size="24" font-weight="bold" fill="%23faf6f0" text-anchor="middle">Seni Digital Ekraf</text><text x="50%" y="87%" font-family="sans-serif" font-size="13" fill="%23f5b72b" text-anchor="middle">Galeri Ekraf HAKI</text></svg>',
  'data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="400" height="480" viewBox="0 0 400 480"><defs><linearGradient id="g2" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stop-color="%230d7c66"/><stop offset="100%" stop-color="%23054437"/></linearGradient></defs><rect width="100%" height="100%" fill="url(%23g2)"/><polygon points="200,80 280,240 120,240" fill="%23f5ede2" opacity="0.9"/><text x="50%" y="80%" font-family="serif" font-size="24" font-weight="bold" fill="%23faf6f0" text-anchor="middle">Kerajinan Kriya</text><text x="50%" y="87%" font-family="sans-serif" font-size="13" fill="%23e2f2ef" text-anchor="middle">Hasil Karya Artisanal</text></svg>',
  'data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="400" height="480" viewBox="0 0 400 480"><defs><linearGradient id="g3" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stop-color="%238b5cf6"/><stop offset="100%" stop-color="%234c1d95"/></linearGradient></defs><rect width="100%" height="100%" fill="url(%23g3)"/><rect x="100" y="100" width="200" height="140" fill="none" stroke="%23f5b72b" stroke-width="4"/><text x="50%" y="80%" font-family="serif" font-size="24" font-weight="bold" fill="%23faf6f0" text-anchor="middle">Tenun Nusantara</text><text x="50%" y="87%" font-family="sans-serif" font-size="13" fill="%23f5f3ff" text-anchor="middle">Warisan Budaya</text></svg>',
];

const heroCards = computed(() => {
  if (newArrivals.value && newArrivals.value.length >= 3) {
    return newArrivals.value.slice(0, 3).map((item, idx) => ({
      id: item.id,
      title: item.usaha?.nama_usaha || 'Karya Ekraf',
      subSektor: item.usaha?.sub_sektor_id || 'Ekraf',
      haki: Boolean(item.legalitas?.no_sertifikat_haki),
      image: item.produk?.foto_produk_urls?.[0] || fallbackArtworks[idx % 3],
    }));
  }
  const defaultDummies = dummyProducts.slice(0, 3);
  return defaultDummies.map((item, idx) => ({
    id: item.id,
    title: item.usaha?.nama_usaha || 'Karya Ekraf',
    subSektor: item.usaha?.sub_sektor_id || 'Ekraf',
    haki: Boolean(item.legalitas?.no_sertifikat_haki),
    image: item.produk?.foto_produk_urls?.[0] || fallbackArtworks[idx % 3],
  }));
});

function onHeroImgError(event, idx) {
  event.target.src = fallbackArtworks[idx % 3];
}

function openCardDetail(card) {
  if (card.id) {
    router.visit(`/detail/${card.id}`);
  } else {
    router.visit('/katalog');
  }
}

function goToKatalog(id) {
  if (id) {
    router.visit(`/katalog?sektor=${id}`);
  } else {
    router.visit('/katalog');
  }
}

async function loadData() {
  if (!isSupabaseConfigured) {
    console.warn('[Ekraf] Supabase belum dikonfigurasi — menggunakan data demo.');
    newArrivals.value = dummyProducts.slice(0, 6);
    loading.value = false;
    return;
  }

  try {
    // Fetch latest products with user location via join with public.users
    const { data, error } = await supabase
      .from('ekraf_data')
      .select('*, users!user_id(alamat, kecamatan, kelurahan, no_hp, nama_lengkap)')
      .order('created_at', { ascending: false });

    if (error) throw error;

    if (data && data.length > 0) {
      const approvedData = data.filter(isApprovedEkrafData);
      if (approvedData.length > 0) {
        newArrivals.value = approvedData.slice(0, 6).map(normalizeEkrafData);
      } else {
        newArrivals.value = dummyProducts.slice(0, 6);
      }
    } else {
      newArrivals.value = dummyProducts.slice(0, 6);
    }

    // Fetch total count for stats banner
    const { count } = await supabase
      .from('ekraf_data')
      .select('*', { count: 'exact', head: true });

    const { count: hakiCount } = await supabase
      .from('ekraf_data')
      .select('*', { count: 'exact', head: true })
      .not('nomor_haki', 'is', null)
      .neq('nomor_haki', '');

    if (count) {
      stats.value = {
        total: count.toLocaleString('id-ID') + '+',
        haki: (hakiCount || 0).toLocaleString('id-ID') + '+',
      };
    }
  } catch (err) {
    console.error('[Ekraf] Gagal memuat data Supabase:', err?.message || err);
    newArrivals.value = dummyProducts.slice(0, 6);
  } finally {
    loading.value = false;
  }
}

onMounted(() => {
  loadData();
});
</script>
