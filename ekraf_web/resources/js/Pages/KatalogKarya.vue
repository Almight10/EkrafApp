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
                {{ s.nama }}
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
        <h3 style="color:var(--clr-charcoal);margin:0 0 0.5rem;font-family:var(--font-serif);">Tidak ada karya ditemukan</h3>
        <p style="margin-bottom:1.5rem;">Coba sesuaikan kata kunci atau filter sub-sektor Anda.</p>
        <div style="display:flex;gap:0.75rem;justify-content:center;flex-wrap:wrap;">
          <button v-if="filterSektor || filterHaki || searchQuery" @click="resetFilter" class="btn btn-outline">Reset Filter</button>
        </div>
      </div>

      <div v-else>
        <div class="grid-catalog">
          <ProductCard v-for="(produk, idx) in paginatedProduk" :key="produk.id" :produk="produk" :is-priority="idx < 2" />
        </div>

        <!-- PAGINATION CONTROLS BANNER -->
        <div v-if="totalPages > 1" class="pagination-wrap">
          <div class="pagination-info">
            Menampilkan {{ startItemIndex }}–{{ endItemIndex }} dari {{ filteredProduk.length }} karya
          </div>

          <div class="pagination-controls">
            <button
              class="page-num-btn"
              :disabled="currentPage === 1"
              @click="goToPage(currentPage - 1)"
              title="Halaman Sebelumnya"
            >
              ← Prev
            </button>

            <button
              v-for="p in totalPages"
              :key="p"
              class="page-num-btn"
              :class="{ active: currentPage === p }"
              @click="goToPage(p)"
            >
              {{ p }}
            </button>

            <button
              class="page-num-btn"
              :disabled="currentPage === totalPages"
              @click="goToPage(currentPage + 1)"
              title="Halaman Selanjutnya"
            >
              Next →
            </button>
          </div>
        </div>
      </div>
    </div>
  </MainLayout>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue';
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

const currentPage = ref(1);
const itemsPerPage = ref(6);

const subSektors = [
  { id: 'aplikasi-game', nama: 'Aplikasi & Game Developer' },
  { id: 'arsitektur', nama: 'Arsitektur' },
  { id: 'desain-interior', nama: 'Desain Interior' },
  { id: 'dkv', nama: 'Desain Komunikasi Visual' },
  { id: 'desain-produk', nama: 'Desain Produk' },
  { id: 'fesyen', nama: 'Fashion' },
  { id: 'film', nama: 'Film, Animasi & Video' },
  { id: 'fotografi', nama: 'Fotografi' },
  { id: 'kriya', nama: 'Kriya' },
  { id: 'kuliner', nama: 'Kuliner' },
  { id: 'musik', nama: 'Musik' },
  { id: 'penerbitan', nama: 'Penerbitan' },
  { id: 'periklanan', nama: 'Periklanan' },
  { id: 'seni-pertunjukan', nama: 'Seni Pertunjukan' },
  { id: 'seni-rupa', nama: 'Seni Rupa' },
  { id: 'tv-radio', nama: 'Televisi & Radio' },
  { id: 'lainnya', nama: 'Lainnya' },
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

const totalPages = computed(() => {
  return Math.ceil(filteredProduk.value.length / itemsPerPage.value) || 1;
});

const startItemIndex = computed(() => {
  if (filteredProduk.value.length === 0) return 0;
  return (currentPage.value - 1) * itemsPerPage.value + 1;
});

const endItemIndex = computed(() => {
  return Math.min(currentPage.value * itemsPerPage.value, filteredProduk.value.length);
});

const paginatedProduk = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value;
  return filteredProduk.value.slice(start, start + itemsPerPage.value);
});

function goToPage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page;
    updateUrlParams();
    if (typeof window !== 'undefined') {
      const container = document.querySelector('.katalog-grid-container');
      if (container) {
        container.scrollIntoView({ behavior: 'smooth' });
      }
    }
  }
}

function updateUrlParams() {
  if (typeof window === 'undefined') return;

  const params = new URLSearchParams();

  if (filterSektor.value) {
    params.set('sektor', filterSektor.value);
  }
  if (filterHaki.value) {
    params.set('haki', filterHaki.value);
  }
  if (searchQuery.value) {
    params.set('q', searchQuery.value);
  }
  if (currentPage.value > 1) {
    params.set('page', currentPage.value.toString());
  }

  const queryString = params.toString();
  const newPath = window.location.pathname + (queryString ? `?${queryString}` : '');
  
  window.history.replaceState({}, '', newPath);
}

watch([searchQuery, filterSektor, filterHaki], () => {
  currentPage.value = 1;
  updateUrlParams();
});

watch(currentPage, () => {
  updateUrlParams();
});

function resetFilter() {
  filterSektor.value = '';
  filterHaki.value = '';
  searchQuery.value = '';
  currentPage.value = 1;
  updateUrlParams();
}

async function loadProduk() {
  if (typeof window !== 'undefined') {
    const params = new URLSearchParams(window.location.search);
    const sektorParam = params.get('sektor');
    const hakiParam = params.get('haki');
    const qParam = params.get('q');
    const pageParam = params.get('page');

    if (sektorParam) filterSektor.value = sektorParam;
    if (hakiParam) filterHaki.value = hakiParam;
    if (qParam) searchQuery.value = qParam;
    if (pageParam && !isNaN(parseInt(pageParam))) {
      currentPage.value = Math.max(1, parseInt(pageParam));
    }
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
      .select('*, users:user_id(nama_lengkap, no_hp, alamat, kecamatan, kelurahan, foto_url)')
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
