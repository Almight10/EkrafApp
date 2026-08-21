<template>
  <article class="card" @click="goToDetail" style="cursor: pointer;">
    <div style="position: relative; overflow: hidden;">
      <img
        v-if="optimizedMainImage && !imgError"
        :src="optimizedMainImage"
        :alt="produk.usaha?.nama_usaha"
        class="card__img"
        :loading="isPriority ? 'eager' : 'lazy'"
        :fetchpriority="isPriority ? 'high' : 'low'"
        decoding="async"
        width="400"
        height="300"
        @error="imgError = true"
      />
      <div
        v-else
        class="card__img"
        :style="`background:${sektorData.bg};display:flex;align-items:center;justify-content:center;font-size:3rem;`"
      >
        {{ sektorData.icon }}
      </div>

      <!-- Floating HAKI Stamp (only if has HAKI) -->
      <div v-if="hasHaki" style="position: absolute; top: 0.75rem; right: 0.75rem; z-index: 2;">
        <div class="haki-stamp" title="Bersertifikat HAKI Resmi">✓</div>
      </div>

      <!-- Sektor Tag Badge -->
      <div style="position: absolute; bottom: 0.75rem; left: 0.75rem; z-index: 2; display:flex; gap:4px; flex-wrap:wrap;">
        <span class="badge badge-category">{{ sektorData.label }}</span>
      </div>
    </div>

    <div class="card__body">
      <h3 class="card__title">{{ produk.usaha?.nama_usaha || 'Tanpa Nama Usaha' }}</h3>

      <p v-if="ownerName" class="card__subtitle">
        <span>Oleh {{ ownerName }}</span>
      </p>

      <!-- HAKI Status Indicator Row -->
      <div class="card__haki-row" style="margin-top:0.6rem;">
        <!-- Has HAKI: Green verified chip -->
        <div v-if="hasHaki" class="card__haki-chip card__haki-chip--verified">
          ✔ HAKI Terverifikasi
        </div>
        <!-- No HAKI: Muted gray chip -->
        <div v-else class="card__haki-chip card__haki-chip--pending">
          ⏳ Belum HAKI
        </div>
      </div>

      <div class="card__footer">
        <div class="card__price">
          {{ formattedPrice }}
        </div>
        <div class="card__actions">
          <button class="btn btn-outline btn-sm card__btn-detail" @click.stop="goToDetail">Lihat</button>
          <a
            :href="waLink"
            target="_blank"
            rel="noopener noreferrer"
            class="btn btn-wa btn-sm card__btn-wa"
            @click.stop
            title="Pesan via WhatsApp"
          >
            💬
          </a>
        </div>
      </div>
    </div>
  </article>
</template>

<script setup>
import { ref, computed } from 'vue';
import { router } from '@inertiajs/vue3';
import { slugify } from '../dummyData.js';

const props = defineProps({
  produk: { type: Object, required: true },
  isNew: { type: Boolean, default: false },
  isPriority: { type: Boolean, default: false }
});

const imgError = ref(false);

const subSektorMap = {
  'aplikasi-game': { label: 'Aplikasi & Game Developer', icon: '🎮', bg: '#eef2ff' },
  'aplikasi': { label: 'Aplikasi & Game Developer', icon: '📱', bg: '#ecfeff' },
  'game': { label: 'Aplikasi & Game Developer', icon: '🎮', bg: '#eef2ff' },
  'arsitektur': { label: 'Arsitektur', icon: '🏛️', bg: '#f0f9ff' },
  'desain-interior': { label: 'Desain Interior', icon: '🏠', bg: '#fff7ed' },
  'dkv': { label: 'Desain Komunikasi Visual', icon: '🎨', bg: '#f0fdf4' },
  'desain-produk': { label: 'Desain Produk', icon: '⚙️', bg: '#f4f4f5' },
  'fesyen': { label: 'Fashion', icon: '👗', bg: '#fdf8ea' },
  'fashion': { label: 'Fashion', icon: '👗', bg: '#fdf8ea' },
  'film': { label: 'Film, Animasi & Video', icon: '🎬', bg: '#fff1f2' },
  'fotografi': { label: 'Fotografi', icon: '📷', bg: '#fdf4ff' },
  'kriya': { label: 'Kriya', icon: '🪡', bg: '#fbf7ee' },
  'kuliner': { label: 'Kuliner', icon: '🍽️', bg: '#fdf2f0' },
  'musik': { label: 'Musik', icon: '🎵', bg: '#f0f7ff' },
  'penerbitan': { label: 'Penerbitan', icon: '📚', bg: '#f0fdf4' },
  'periklanan': { label: 'Periklanan', icon: '📢', bg: '#fefce8' },
  'iklan': { label: 'Periklanan', icon: '📢', bg: '#fefce8' },
  'seni-pertunjukan': { label: 'Seni Pertunjukan', icon: '🎭', bg: '#faf0ff' },
  'seni-rupa': { label: 'Seni Rupa', icon: '🖼️', bg: '#fcf0f2' },
  'tv-radio': { label: 'Televisi & Radio', icon: '📺', bg: '#faf5ff' },
  'lainnya': { label: 'Lainnya', icon: '✨', bg: '#faf6f0' },
};

const sektorData = computed(() => {
  const id = props.produk.usaha?.sub_sektor_id || 'kriya';
  return subSektorMap[id] || { label: id, icon: '🎨', bg: '#faf6f0' };
});

const mainImage = computed(() => {
  const urls = props.produk.produk?.foto_produk_urls;
  return Array.isArray(urls) && urls.length > 0 ? urls[0] : null;
});

const optimizedMainImage = computed(() => {
  const raw = mainImage.value;
  if (!raw) return null;
  if (raw.includes('images.unsplash.com')) {
    let clean = raw.replace(/w=\d+/, 'w=360').replace(/q=\d+/, 'q=70');
    if (!clean.includes('fm=webp')) {
      clean += '&fm=webp';
    }
    return clean;
  }
  return raw;
});

const hasHaki = computed(() => {
  return !!(props.produk.legalitas?.no_sertifikat_haki);
});

function onImgError() {
  imgError.value = true;
}

const ownerName = computed(() => {
  const name = props.produk.identitas?.nama_lengkap || props.produk.users?.nama_lengkap || props.produk.nama_lengkap || props.produk.namaLengkap;
  return name && name.trim() ? name.trim() : '';
});

const formattedPrice = computed(() => {
  const h = props.produk.produk?.harga;
  if (!h || isNaN(h)) return 'Hubungi Pemilik';
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(h);
});

const waLink = computed(() => {
  const phone = props.produk.identitas?.no_wa || '6281234567890';
  const cleanPhone = phone.replace(/[^0-9]/g, '');
  const formattedPhone = cleanPhone.startsWith('0') ? '62' + cleanPhone.slice(1) : cleanPhone;
  const text = encodeURIComponent(`Halo, saya tertarik dengan karya "${props.produk.usaha?.nama_usaha || 'Ekraf'}" di Platform Ekraf Kota Probolinggo.`);
  return `https://wa.me/${formattedPhone}?text=${text}`;
});

function goToDetail() {
  const name = props.produk.usaha?.nama_usaha || props.produk.title || props.produk.id || 'karya';
  const slug = slugify(name);
  router.visit(`/detail/${encodeURIComponent(slug)}`);
}
</script>
