<template>
  <MainLayout>
    <!-- PAGE HEADER & FILTER BAR -->
    <div class="katalog-header-wrap">
      <div class="container">
        <div class="katalog-header__top">
          <div>
            <h1 class="display-xl" style="margin:0 0 0.5rem;">Explore the <span class="serif-italic">Collection</span></h1>
            <p style="color:var(--clr-muted);font-size:0.95rem;margin:0;">Jelajahi dan apresiasi portofolio karya kreatif terverifikasi HAKI seluruh daerah.</p>
          </div>
          <div class="search-wrap">
            <span class="search-icon">🔍</span>
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Cari karya, sektor, kreator..."
              class="search-input"
              id="search-katalog"
            />
          </div>
        </div>

        <!-- CATEGORY CHIPS SCROLLBAR (MOBILE & DESKTOP QUICK SELECT) -->
        <div class="category-chips-scroll">
          <button
            class="chip-item"
            :class="{ active: filterSektor === '' }"
            @click="filterSektor = ''"
          >
            ✨ Semua (17)
          </button>
          <button
            v-for="s in subSektors"
            :key="s.id"
            class="chip-item"
            :class="{ active: filterSektor === s.id }"
            @click="filterSektor = s.id"
          >
            <span>{{ s.icon }}</span> <span>{{ s.nama.split(' ')[0] }}</span>
          </button>
        </div>

        <!-- COMPACT FILTER BAR CONTAINING SELECTS -->
        <div class="filter-bar">
          <div class="filter-bar-group">
            <label for="select-sektor" class="filter-label">
              Sub-Sektor:
            </label>
            <select
              id="select-sektor"
              v-model="filterSektor"
              class="filter-select"
            >
              <option value="">Semua Sub-Sektor (17 Sektor)</option>
              <option v-for="s in subSektors" :key="s.id" :value="s.id">
                {{ s.icon }} {{ s.nama }}
              </option>
            </select>
          </div>

          <div class="filter-bar-group">
            <label for="select-haki" class="filter-label">
              Status HAKI:
            </label>
            <select
              id="select-haki"
              v-model="filterHaki"
              class="filter-select"
            >
              <option value="">Semua Status</option>
              <option value="haki">Terverifikasi HAKI</option>
              <option value="non-haki">Belum HAKI</option>
            </select>
          </div>

          <!-- Reset Filter Button -->
          <button
            v-if="filterSektor || filterHaki || searchQuery"
            @click="resetFilter"
            class="btn btn-sm btn-outline filter-reset-btn"
          >
            ✕ Reset
          </button>
        </div>
      </div>
    </div>

    <!-- KATALOG GRID CONTENT -->
    <div class="container katalog-grid-container">
      <div v-if="loading" class="grid-catalog">
        <SkeletonCard v-for="i in 6" :key="i" />
      </div>

      <div v-else-if="filteredProduk.length === 0" class="empty-state">
        <div class="empty-state__icon">🔍</div>
        <h3 style="color:var(--clr-charcoal);margin:0 0 0.5rem;font-family:var(--font-serif);">Tidak ada karya ditemukan</h3>
        <p style="margin-bottom:1.5rem;">Coba sesuaikan kata kunci atau filter sub-sektor Anda.</p>
        <div style="display:flex;gap:0.75rem;justify-content:center;flex-wrap:wrap;">
          <button v-if="filterSektor || filterHaki || searchQuery" @click="resetFilter" class="btn btn-outline">Reset Filter</button>
        </div>
      </div>

      <div v-else class="grid-catalog">
        <ProductCard v-for="produk in filteredProduk" :key="produk.id" :produk="produk" />
      </div>
    </div>
  </MainLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { supabase, isSupabaseConfigured, normalizeEkrafData, isApprovedEkrafData } from '../supabase.js';
import { dummyProducts } from '../dummyData.js';
import MainLayout from '../Layouts/MainLayout.vue';
import ProductCard from '../Components/ProductCard.vue';
import SkeletonCard from '../Components/SkeletonCard.vue';

const searchQuery = ref('');
const filterSektor = ref('');
const filterHaki = ref('');
const loading = ref(true);
const produkList = ref([]);

const subSektors = [
  { id: 'kuliner', nama: 'Kuliner', icon: '🍴' },
  { id: 'kriya', nama: 'Kriya', icon: '🪡' },
  { id: 'fesyen', nama: 'Fesyen', icon: '👕' },
  { id: 'musik', nama: 'Musik', icon: '🎵' },
  { id: 'seni-pertunjukan', nama: 'Seni Pertunjukan', icon: '🎭' },
  { id: 'seni-rupa', nama: 'Seni Rupa', icon: '🎨' },
  { id: 'dkv', nama: 'Desain Komunikasi Visual (DKV)', icon: '📐' },
  { id: 'desain-produk', nama: 'Desain Produk', icon: '⚙️' },
  { id: 'desain-interior', nama: 'Desain Interior', icon: '🏠' },
  { id: 'arsitektur', nama: 'Arsitektur', icon: '🏛️' },
  { id: 'fotografi', nama: 'Fotografi', icon: '📷' },
  { id: 'game', nama: 'Pengembangan Game', icon: '🎮' },
  { id: 'aplikasi', nama: 'Pengembang Aplikasi', icon: '📱' },
  { id: 'film', nama: 'Film, Animasi & Video', icon: '🎬' },
  { id: 'iklan', nama: 'Periklanan', icon: '📢' },
  { id: 'penerbitan', nama: 'Penerbitan', icon: '📚' },
  { id: 'tv-radio', nama: 'TV & Radio', icon: '📺' },
];

const filteredProduk = computed(() => {
  return produkList.value.filter(p => {
    if (filterSektor.value && p.usaha?.sub_sektor_id !== filterSektor.value) return false;
    if (filterHaki.value === 'haki' && !p.legalitas?.no_sertifikat_haki) return false;
    if (filterHaki.value === 'non-haki' && p.legalitas?.no_sertifikat_haki) return false;
    if (searchQuery.value) {
      const q = searchQuery.value.toLowerCase();
      const namaUsaha = (p.usaha?.nama_usaha || '').toLowerCase();
      const jenisUsaha = (p.usaha?.jenis_usaha || '').toLowerCase();
      const deskripsi = (p.produk?.deskripsi_produk || '').toLowerCase();
      const namaOwner = (p.identitas?.nama_lengkap || '').toLowerCase();
      return namaUsaha.includes(q) || jenisUsaha.includes(q) || deskripsi.includes(q) || namaOwner.includes(q);
    }
    return true;
  });
});

function resetFilter() {
  filterSektor.value = '';
  filterHaki.value = '';
  searchQuery.value = '';
}

async function loadProduk() {
  if (typeof window !== 'undefined') {
    const params = new URLSearchParams(window.location.search);
    const sektorParam = params.get('sektor');
    if (sektorParam) filterSektor.value = sektorParam;
  }

  if (!isSupabaseConfigured) {
    console.warn('[Ekraf] Supabase belum dikonfigurasi — menggunakan data demo.');
    produkList.value = dummyProducts;
    loading.value = false;
    return;
  }

  try {
    const { data, error } = await supabase
      .from('ekraf_data')
      .select('*, users!user_id(nama_lengkap, no_hp, alamat, kecamatan, kelurahan)')
      .order('created_at', { ascending: false });

    if (error) throw error;

    if (data && data.length > 0) {
      // Filter ONLY approved / ACC entries from admin
      const approvedData = data.filter(isApprovedEkrafData);
      if (approvedData.length > 0) {
        produkList.value = approvedData.map(normalizeEkrafData);
      } else {
        console.info('[Ekraf] Belum ada data terverifikasi — menggunakan data demo.');
        produkList.value = dummyProducts;
      }
      console.info(`[Ekraf] Loaded ${approvedData.length} verified records from Supabase.`);
    } else {
      console.info('[Ekraf] Tabel kosong — menggunakan data demo.');
      produkList.value = dummyProducts;
    }
  } catch (err) {
    console.error('[Ekraf] Gagal memuat data Supabase:', err?.message || err);
    produkList.value = dummyProducts;
  } finally {
    loading.value = false;
  }
}

onMounted(() => {
  loadProduk();
});
</script>
