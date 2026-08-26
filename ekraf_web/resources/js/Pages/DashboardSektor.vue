<template>
  <MainLayout>
    <div class="dashboard-page">
      <!-- COMPACT EDITORIAL HEADER -->
      <section class="dashboard-hero">
        <div class="container">
          <div class="dashboard-hero__inner">
            <div>
              <h1 class="dashboard-hero__title">
                Dashboard Visualisasi EKRAF Kota Probolinggo
              </h1>
              <p class="dashboard-hero__desc">
                Ringkasan statistik, sebaran 17 sub-sektor, dan pemetaan wilayah pelaku ekonomi kreatif terdaftar.
              </p>
            </div>
          </div>
        </div>
      </section>

      <!-- METRICS STRIP (4 Mini KPI Cards Matching Main Cards Design) -->
      <section class="metrics-strip">
        <div class="container">
          <div class="metrics-grid">
            <div class="card-box metric-card" :class="{ 'skeleton-pulse': loading }">
              <div>
                <span class="metric-card__val">{{ loading ? '...' : `${totalRegisteredItems} Usaha` }}</span>
                <span class="metric-card__lbl">Total Pelaku Terdata</span>
              </div>
            </div>

            <div class="card-box metric-card" :class="{ 'skeleton-pulse': loading }">
              <div>
                <span class="metric-card__val">{{ loading ? '...' : `${activeSectorsCount} / 17 Sektor` }}</span>
                <span class="metric-card__lbl">Sub-Sektor Terisi ({{ loading ? '0' : totalCoveragePercent }}%)</span>
              </div>
            </div>

            <div class="card-box metric-card" :class="{ 'skeleton-pulse': loading }">
              <div>
                <span class="metric-card__val">{{ loading ? '...' : topSector.name }}</span>
                <span class="metric-card__lbl">Sektor Terbanyak ({{ loading ? '0' : topSector.percentage }}%)</span>
              </div>
            </div>

            <div class="card-box metric-card" :class="{ 'skeleton-pulse': loading }">
              <div>
                <span class="metric-card__val">5 Kecamatan</span>
                <span class="metric-card__lbl">Dominan: {{ loading ? '...' : topKecamatan.name }}</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- MAIN VISUAL DASHBOARD LAYOUT (2 Columns) -->
      <section class="dashboard-main">
        <div class="container">
          <div class="visual-layout">

            <!-- LEFT COLUMN: Sub-Sektor Distribution (Clean Header, 2-Column Compact Grid) -->
            <div class="card-box card-box--left" :class="{ 'skeleton-pulse-light': loading }">
              <div class="card-box__header">
                <div>
                  <h3 class="card-box__title">Sebaran Usaha per Sub-Sektor</h3>
                  <p class="card-box__subtitle">17 Sub-sektor Ekonomi Kreatif Probolinggo</p>
                </div>
              </div>

              <!-- 2-Column Compact Grid -->
              <div class="sector-grid-2col">
                <div
                  v-for="sec in subSektorDistribution"
                  :key="sec.id"
                  class="sector-tile"
                  :class="{ 'sector-tile--empty': sec.count === 0 }"
                  @click="goToKatalog(sec.id)"
                >
                  <div class="sector-tile__top">
                    <div class="sector-tile__name">
                      <span class="sector-tile__dot" :style="{ backgroundColor: sec.color }"></span>
                      <span>{{ sec.name }}</span>
                    </div>
                    <span class="sector-tile__count">
                      {{ loading ? '...' : (sec.count > 0 ? `${sec.count} Usaha` : 'Kosong') }}
                    </span>
                  </div>

                  <div class="sector-tile__track">
                    <div
                      class="sector-tile__fill"
                      :style="{ width: (loading ? 0 : sec.barWidth) + '%', backgroundColor: sec.color }"
                    ></div>
                  </div>
                </div>
              </div>
            </div>

            <!-- RIGHT COLUMN: Regional Breakdown & Top Sector Proportions -->
            <div class="visual-layout__right">

              <!-- Region Breakdown -->
              <div class="card-box" :class="{ 'skeleton-pulse-light': loading }">
                <div class="card-box__header">
                  <div>
                    <h3 class="card-box__title">Sebaran per Kecamatan</h3>
                    <p class="card-box__subtitle">Sebaran pelaku di Kota Probolinggo</p>
                  </div>
                </div>

                <div class="region-compact-list">
                  <div
                    v-for="kec in kecamatanDistribution"
                    :key="kec.name"
                    class="region-compact-item"
                  >
                    <div class="region-compact-item__top">
                      <span>📍 {{ kec.name }}</span>
                      <span class="region-compact-item__val">
                        {{ loading ? '...' : `${kec.count} Usaha (${kec.percentage}%)` }}
                      </span>
                    </div>
                    <div class="sector-tile__track">
                      <div class="sector-tile__fill" :style="{ width: (loading ? 0 : kec.barWidth) + '%', backgroundColor: '#e05638' }"></div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Top Proportions -->
              <div class="card-box" :class="{ 'skeleton-pulse-light': loading }">
                <div class="card-box__header">
                  <div>
                    <h3 class="card-box__title">Proporsi Sektor Utama</h3>
                    <p class="card-box__subtitle">Sub-sektor paling aktif saat ini</p>
                  </div>
                </div>

                <div class="prop-compact-grid">
                  <div
                    v-for="sec in topActiveSectors"
                    :key="sec.id"
                    class="prop-compact-card"
                    @click="goToKatalog(sec.id)"
                  >
                    <div
                      class="prop-compact-card__circle"
                      :style="{ borderColor: sec.color, backgroundColor: `${sec.color}10` }"
                    >
                      <span>{{ loading ? '...' : `${sec.percentage}%` }}</span>
                    </div>
                    <div>
                      <div class="prop-compact-card__title">{{ sec.name }}</div>
                      <div class="prop-compact-card__sub">{{ loading ? '...' : `${sec.count} Usaha` }}</div>
                    </div>
                  </div>
                </div>
              </div>

            </div>

          </div>
        </div>
      </section>
    </div>
  </MainLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { router } from '@inertiajs/vue3';
import MainLayout from '@/Layouts/MainLayout.vue';
import { supabase, isSupabaseConfigured, normalizeEkrafData, isApprovedEkrafData } from '@/supabase';

const allEkrafItems = ref([]); // Strictly 100% database items, zero dummy fallbacks!
const loading = ref(true);
const isLiveDb = ref(false);

const ALL_SUB_SEKTORS = [
  { id: 'kuliner', name: 'Kuliner', color: '#e05638' },
  { id: 'fesyen', name: 'Fashion & Busana', color: '#f59e0b' },
  { id: 'kriya', name: 'Kriya & Kerajinan', color: '#3b82f6' },
  { id: 'seni-rupa', name: 'Seni Rupa', color: '#ec4899' },
  { id: 'film', name: 'Film, Animasi & Video', color: '#8b5cf6' },
  { id: 'dkv', name: 'Desain Komunikasi Visual', color: '#06b6d4' },
  { id: 'desain-produk', name: 'Desain Produk', color: '#10b981' },
  { id: 'musik', name: 'Musik', color: '#6366f1' },
  { id: 'seni-pertunjukan', name: 'Seni Pertunjukan', color: '#f43f5e' },
  { id: 'fotografi', name: 'Fotografi', color: '#14b8a6' },
  { id: 'arsitektur', name: 'Arsitektur', color: '#64748b' },
  { id: 'desain-interior', name: 'Desain Interior', color: '#84cc16' },
  { id: 'penerbitan', name: 'Penerbitan', color: '#a855f7' },
  { id: 'periklanan', name: 'Periklanan', color: '#f97316' },
  { id: 'tv-radio', name: 'Televisi & Radio', color: '#0284c7' },
  { id: 'aplikasi-game', name: 'Aplikasi & Game', color: '#d97706' },
  { id: 'lainnya', name: 'Lainnya', color: '#94a3b8' }
];

const PROBOLINGGO_KECAMATAN = ['Mayangan', 'Kanigaran', 'Wonoasih', 'Kedopok', 'Kademangan'];

const subSektorDistribution = computed(() => {
  const items = allEkrafItems.value;
  const totalCount = items.length || 1;
  const countMap = {};

  items.forEach(item => {
    const rawSektor = item.usaha?.sub_sektor_id || item.sub_sektor || item.subSektor || 'lainnya';
    const sId = String(rawSektor).toLowerCase().trim();
    countMap[sId] = (countMap[sId] || 0) + 1;
  });

  const mapped = ALL_SUB_SEKTORS.map(sec => {
    const count = countMap[sec.id] || 0;
    const percentage = items.length > 0 ? Number(((count / totalCount) * 100).toFixed(1)) : 0;
    return { ...sec, count, percentage };
  });

  mapped.sort((a, b) => b.count - a.count || a.name.localeCompare(b.name));
  const maxCount = Math.max(...mapped.map(m => m.count), 1);

  return mapped.map(item => ({
    ...item,
    barWidth: item.count > 0 ? Math.max(12, Math.round((item.count / maxCount) * 100)) : 0
  }));
});

const kecamatanDistribution = computed(() => {
  const items = allEkrafItems.value;
  const totalCount = items.length || 1;
  const kecMap = { Mayangan: 0, Kanigaran: 0, Wonoasih: 0, Kedopok: 0, Kademangan: 0 };

  items.forEach(item => {
    const alamat = item.usaha?.alamat || item.identitas?.alamat || item.identitas?.kecamatan || '';
    let matched = false;
    PROBOLINGGO_KECAMATAN.forEach(k => {
      if (alamat.toLowerCase().includes(k.toLowerCase())) {
        kecMap[k]++;
        matched = true;
      }
    });
    if (!matched) kecMap['Mayangan']++;
  });

  const list = Object.keys(kecMap).map(k => {
    const count = kecMap[k];
    const percentage = items.length > 0 ? Number(((count / totalCount) * 100).toFixed(1)) : 0;
    return { name: `Kec. ${k}`, count, percentage };
  });

  list.sort((a, b) => b.count - a.count);
  const maxCount = Math.max(...list.map(l => l.count), 1);

  return list.map(item => ({
    ...item,
    barWidth: item.count > 0 ? Math.max(15, Math.round((item.count / maxCount) * 100)) : 0
  }));
});

const activeSectorsCount = computed(() => subSektorDistribution.value.filter(s => s.count > 0).length);
const totalRegisteredItems = computed(() => allEkrafItems.value.length);
const totalCoveragePercent = computed(() => Math.round((activeSectorsCount.value / 17) * 100));
const topSector = computed(() => subSektorDistribution.value[0] || { name: '-', percentage: 0 });
const topKecamatan = computed(() => kecamatanDistribution.value[0] || { name: '-' });
const topActiveSectors = computed(() => subSektorDistribution.value.filter(s => s.count > 0).slice(0, 4));

async function loadDashboardData() {
  loading.value = true;
  allEkrafItems.value = []; // Reset empty

  if (!isSupabaseConfigured) {
    loading.value = false;
    return;
  }

  try {
    const { data, error } = await supabase
      .from('ekraf_data')
      .select('*, users:user_id(nama_lengkap, no_hp, alamat, kecamatan, kelurahan, foto_url)')
      .order('created_at', { ascending: false });

    if (!error && data && data.length > 0) {
      const approved = data.filter(isApprovedEkrafData);
      if (approved.length > 0) {
        allEkrafItems.value = approved.map(normalizeEkrafData);
        isLiveDb.value = true;
      }
    }
  } catch (err) {
    console.warn('[DashboardPage] Supabase fetch error:', err?.message || err);
  } finally {
    loading.value = false;
  }
}

onMounted(() => {
  loadDashboardData();
});

function goToKatalog(sectorId) {
  if (sectorId) router.visit(`/katalog?sektor=${sectorId}`);
  else router.visit('/katalog');
}
</script>

<style scoped>
.dashboard-page {
  padding-bottom: 2.5rem;
  background: transparent;
}

.dashboard-hero {
  background: rgba(245, 237, 226, 0.7);
  backdrop-filter: blur(6px);
  padding: 1.5rem 0 1.25rem;
  border-bottom: 1px solid var(--clr-border);
}

.breadcrumb-compact {
  font-size: 0.775rem;
  color: var(--clr-muted);
  margin-bottom: 4px;
}

.breadcrumb-compact a {
  color: var(--clr-muted);
  text-decoration: none;
}

.dashboard-hero__inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
}

.dashboard-hero__title {
  font-family: var(--font-heading);
  font-size: 1.6rem;
  font-weight: 800;
  color: var(--clr-charcoal);
  margin: 0 0 2px;
  line-height: 1.2;
}

.dashboard-hero__desc {
  font-size: 0.875rem;
  color: var(--clr-muted);
  margin: 0;
}

.status-pill {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: #ffffff;
  border: 1px solid var(--clr-border);
  padding: 5px 12px;
  border-radius: 9999px;
  font-size: 0.775rem;
  font-weight: 600;
  color: var(--clr-charcoal);
}

.status-pill__dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: #10b981;
}

.status-pill__dot--loading {
  background: #f59e0b;
  animation: pulse 1s infinite;
}

@keyframes pulse {
  0% { opacity: 1; }
  50% { opacity: 0.3; }
  100% { opacity: 1; }
}

.skeleton-pulse {
  animation: skeletonPulse 1.2s ease-in-out infinite;
}

@keyframes skeletonPulse {
  0% { opacity: 0.7; }
  50% { opacity: 0.4; }
  100% { opacity: 0.7; }
}

/* Metrics Strip */
.metrics-strip {
  padding: 1.25rem 0;
}

.metrics-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1.25rem;
}

@media (max-width: 860px) {
  .metrics-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 0.85rem;
  }
}

/* Metric Card - Clean Card Box Style (No Icons) */
.metric-card {
  padding: 1.15rem 1.25rem;
  display: flex;
  align-items: center;
  gap: 12px;
}

.metric-card__val {
  display: block;
  font-family: var(--font-heading);
  font-size: 1.15rem;
  font-weight: 800;
  color: var(--clr-charcoal);
  line-height: 1.1;
}

.metric-card__lbl {
  font-size: 0.75rem;
  color: var(--clr-muted);
}

/* Dashboard Main Layout 2-Columns */
.dashboard-main {
  padding: 0.5rem 0 1.5rem;
}

.visual-layout {
  display: grid;
  grid-template-columns: 1.35fr 0.65fr;
  gap: 1.25rem;
}

@media (max-width: 960px) {
  .visual-layout {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
}

.visual-layout__right {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

/* Card Box (Uniform Card Standard) */
.card-box {
  background: #ffffff;
  border: 1px solid var(--clr-border);
  border-radius: 16px;
  padding: 1.25rem;
}

.card-box__header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 1rem;
  margin-bottom: 1rem;
  flex-wrap: wrap;
}

.card-box__title {
  font-family: var(--font-heading);
  font-size: 1.1rem;
  font-weight: 700;
  color: var(--clr-charcoal);
  margin: 0 0 2px;
}

.card-box__subtitle {
  font-size: 0.775rem;
  color: var(--clr-muted);
  margin: 0;
}

/* 2-Column Compact Grid for Sub-Sektor Tiles */
.sector-grid-2col {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.65rem 0.85rem;
}

.sector-tile {
  background: var(--clr-bg-alt);
  border: 1px solid var(--clr-border);
  border-radius: 10px;
  padding: 0.65rem 0.85rem;
  cursor: pointer;
  transition: all 0.15s ease;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.sector-tile:hover {
  background: #ffffff;
  border-color: var(--clr-terracotta);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.04);
}

.sector-tile--empty {
  opacity: 0.55;
}

.sector-tile__top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 6px;
}

.sector-tile__name {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.8rem;
  font-weight: 700;
  color: var(--clr-charcoal);
}

.sector-tile__dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  flex-shrink: 0;
}

.sector-tile__count {
  font-family: var(--font-mono);
  font-size: 0.725rem;
  color: var(--clr-muted);
  white-space: nowrap;
}

.sector-tile__track {
  height: 4px;
  background: rgba(0, 0, 0, 0.06);
  border-radius: 2px;
  overflow: hidden;
}

.sector-tile__fill {
  height: 100%;
  border-radius: 2px;
  transition: width 0.4s ease;
}

/* Region compact */
.region-compact-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.region-compact-item__top {
  display: flex;
  justify-content: space-between;
  font-size: 0.8rem;
  font-weight: 600;
  margin-bottom: 3px;
}

.region-compact-item__val {
  font-family: var(--font-mono);
  font-size: 0.75rem;
  color: var(--clr-terracotta);
}

/* Proportion compact */
.prop-compact-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.75rem;
}

.prop-compact-card {
  border: 1px solid var(--clr-border);
  border-radius: 12px;
  padding: 0.75rem 0.85rem;
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  background: var(--clr-bg-alt);
  transition: all 0.15s ease;
}

.prop-compact-card:hover {
  background: #ffffff;
  border-color: var(--clr-terracotta);
}

.prop-compact-card__circle {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  border: 2.5px solid;
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: var(--font-mono);
  font-size: 0.725rem;
  font-weight: 800;
  color: var(--clr-charcoal);
  flex-shrink: 0;
  padding: 4px;
}

.prop-compact-card__title {
  font-size: 0.775rem;
  font-weight: 700;
  color: var(--clr-charcoal);
  line-height: 1.2;
}

.prop-compact-card__sub {
  font-size: 0.7rem;
  color: var(--clr-muted);
}

/* MOBILE ULTRA-COMPACT RESPONSIVE FIX (Prevent Long Vertical Scrolling) */
@media (max-width: 640px) {
  .dashboard-hero {
    padding: 1rem 0 0.85rem;
  }
  .dashboard-hero__title {
    font-size: 1.25rem;
  }
  .dashboard-hero__desc {
    font-size: 0.8rem;
  }
  .metrics-strip {
    padding: 0.75rem 0;
  }
  .metrics-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 0.5rem;
  }
  .metric-card {
    padding: 0.75rem 0.85rem;
    gap: 8px;
    border-radius: 12px;
  }
  .metric-card__icon {
    font-size: 1.1rem;
  }
  .metric-card__val {
    font-size: 0.95rem;
  }
  .metric-card__lbl {
    font-size: 0.675rem;
  }
  .card-box {
    padding: 0.85rem;
    border-radius: 12px;
  }
  .card-box__header {
    margin-bottom: 0.65rem;
  }
  .card-box__title {
    font-size: 0.95rem;
  }
  .card-box__subtitle {
    font-size: 0.7rem;
  }
  .sector-grid-2col {
    grid-template-columns: repeat(2, 1fr);
    gap: 0.45rem 0.55rem;
  }
  .sector-tile {
    padding: 0.45rem 0.6rem;
    border-radius: 8px;
    gap: 4px;
  }
  .sector-tile__name {
    font-size: 0.725rem;
  }
  .sector-tile__count {
    font-size: 0.65rem;
  }
  .region-compact-list {
    gap: 0.5rem;
  }
  .region-compact-item__top {
    font-size: 0.725rem;
  }
  .region-compact-item__val {
    font-size: 0.7rem;
  }
  .prop-compact-grid {
    gap: 0.5rem;
  }
  .prop-compact-card {
    padding: 0.5rem 0.65rem;
    gap: 6px;
    border-radius: 10px;
  }
  .prop-compact-card__circle {
    width: 40px;
    height: 40px;
    font-size: 0.65rem;
    padding: 3px;
  }
  .prop-compact-card__title {
    font-size: 0.725rem;
  }
  .prop-compact-card__sub {
    font-size: 0.65rem;
  }
}
</style>
