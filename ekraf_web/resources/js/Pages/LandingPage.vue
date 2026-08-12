<template>
  <MainLayout>
    <!-- HERO SECTION -->
    <section class="hero">
      <div class="container">
        <div class="hero__inner">
          <!-- Left: Headlines, Mobile Showcase & CTAs -->
          <div class="animate-in hero__content">
            <h1 class="display-xl" style="margin:0 0 1.25rem;">
              Rayakan <span class="serif-italic">Kreativitas</span><br>Anak Bangsa
            </h1>
            <p class="hero__desc">
              Platform digital premium untuk mengeksplorasi, mengoleksi, dan merayakan karya terbaik dari 17 sub-sektor ekonomi kreatif Indonesia berbasis Hak Kekayaan Intelektual.
            </p>

            <!-- TIMED ARTWORK SHOWCASE SLIDER (MOBILE VIEW POSITIONED BEFORE CTAS) -->
            <div class="hero__showcase-mobile animate-in delay-100">
              <div v-if="activeCard" class="hero__showcase-card" @click="openCardDetail(activeCard)">
                <div v-if="activeCard.haki" class="hero__photo-badge">✓ HAKI</div>
                <div class="hero__showcase-img-wrap">
                  <transition name="hero-slide" mode="out-in">
                    <img
                      :key="activeCard.id || currentSlide"
                      :src="activeCard.image"
                      :alt="activeCard.title"
                      class="hero__showcase-img"
                      @error="onHeroImgError($event, currentSlide)"
                    />
                  </transition>
                </div>
                <div class="hero__showcase-caption">
                  <div style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:70%;">
                    <div class="hero__photo-title">{{ activeCard.title }}</div>
                    <div class="hero__photo-sub">{{ activeCard.subSektor }} • Karya Pilihan</div>
                  </div>
                  <!-- Slide dots -->
                  <div class="hero__showcase-dots">
                    <span
                      v-for="(c, idx) in heroCards"
                      :key="idx"
                      class="hero__dot"
                      :class="{ active: currentSlide === idx }"
                      @click.stop="currentSlide = idx"
                    ></span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Hero Action Buttons -->
            <div class="hero__actions">
              <a href="/katalog" class="btn btn-primary btn-lg">Mulai Eksplorasi</a>
              <a href="https://github.com/Gerryrag/ekrafApp/releases/latest/download/app-release.apk" target="_blank" rel="noopener noreferrer" class="btn btn-outline btn-lg">Daftar Kreator (Download App)</a>
            </div>
          </div>

          <!-- Right: Desktop Timed Showcase Card -->
          <div class="hero__showcase-desktop animate-in delay-200">
            <div v-if="activeCard" class="hero__showcase-card hero__showcase-card--desktop" @click="openCardDetail(activeCard)">
              <div v-if="activeCard.haki" class="hero__photo-badge">✓ HAKI Terverifikasi</div>
              <div class="hero__showcase-img-wrap">
                <transition name="hero-slide" mode="out-in">
                  <img
                    :key="activeCard.id || currentSlide"
                    :src="activeCard.image"
                    :alt="activeCard.title"
                    class="hero__showcase-img"
                    @error="onHeroImgError($event, currentSlide)"
                  />
                </transition>
              </div>
              <div class="hero__showcase-caption">
                <div style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:70%;">
                  <div class="hero__photo-title">{{ activeCard.title }}</div>
                  <div class="hero__photo-sub">{{ activeCard.subSektor }} • 2026</div>
                </div>
                <!-- Slide dots -->
                <div class="hero__showcase-dots">
                  <span
                    v-for="(c, idx) in heroCards"
                    :key="idx"
                    class="hero__dot"
                    :class="{ active: currentSlide === idx }"
                    @click.stop="currentSlide = idx"
                  ></span>
                </div>
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
          <a href="https://github.com/Gerryrag/ekrafApp/releases/latest/download/app-release.apk" target="_blank" rel="noopener noreferrer" class="btn btn-primary btn-lg">Download Aplikasi Kreator</a>
        </div>
      </div>
    </section>
  </MainLayout>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue';
import { router } from '@inertiajs/vue3';
import { supabase, isSupabaseConfigured, normalizeEkrafData, isApprovedEkrafData } from '../supabase.js';
import { dummyProducts, slugify } from '../dummyData.js';
import MainLayout from '../Layouts/MainLayout.vue';
import ProductCard from '../Components/ProductCard.vue';

const loading = ref(true);
const newArrivals = ref([]);
const stats = ref({ total: '15.000+', haki: '5.000+' });
const currentSlide = ref(0);
let slideTimer = null;

const heroCards = computed(() => {
  const list = newArrivals.value.length > 0 ? newArrivals.value : dummyProducts;
  return list.slice(0, 5).map((item, idx) => ({
    id: item.id,
    title: item.usaha?.nama_usaha || 'Karya Ekraf',
    subSektor: item.usaha?.sub_sektor_id || 'kriya',
    year: item.meta?.member_since || '2026',
    image: item.produk?.foto_produk_urls?.[0] || fallbackArtworks[idx % 3],
    haki: !!(item.legalitas?.no_sertifikat_haki)
  }));
});

const activeCard = computed(() => {
  if (!heroCards.value || heroCards.value.length === 0) return null;
  return heroCards.value[currentSlide.value % heroCards.value.length];
});

function startTimer() {
  stopTimer();
  slideTimer = setInterval(() => {
    if (heroCards.value.length > 0) {
      currentSlide.value = (currentSlide.value + 1) % heroCards.value.length;
    }
  }, 3500);
}

function stopTimer() {
  if (slideTimer) clearInterval(slideTimer);
}

const fallbackArtworks = [
  'https://images.unsplash.com/photo-1606760227091-3dd858d97240?auto=format&fit=crop&w=800&q=80',
  'https://images.unsplash.com/photo-1612196808214-b7e239e5f6b7?auto=format&fit=crop&w=800&q=80',
  'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?auto=format&fit=crop&w=800&q=80'
];

function onHeroImgError(event, idx) {
  event.target.src = fallbackArtworks[idx % 3];
}

function openCardDetail(card) {
  const name = card.title || card.usaha?.nama_usaha || card.id || 'karya';
  if (name) {
    const slug = slugify(name);
    router.visit(`/detail/${encodeURIComponent(slug)}`);
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
  startTimer();
});

onUnmounted(() => {
  stopTimer();
});
</script>
