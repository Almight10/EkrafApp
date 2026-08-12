<template>
  <article class="card" @click="goToDetail" style="cursor: pointer;">
    <div style="position: relative; overflow: hidden;">
      <img
        v-if="mainImage && !imgError"
        :src="mainImage"
        :alt="produk.usaha?.nama_usaha"
        class="card__img"
        loading="lazy"
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
      <div style="margin-top:0.875rem;">
        <!-- Has HAKI: Green verified chip -->
        <div v-if="hasHaki" style="display:inline-flex;align-items:center;gap:6px;background:#d1fae5;color:#065f46;border:1px solid #6ee7b7;padding:3px 10px;border-radius:2px;font-size:0.725rem;font-weight:700;font-family:var(--font-mono);text-transform:uppercase;letter-spacing:0.04em;">
          ✔ HAKI Terverifikasi
        </div>
        <!-- No HAKI: Muted gray chip -->
        <div v-else style="display:inline-flex;align-items:center;gap:6px;background:#f3f4f6;color:#6b7280;border:1px solid #d1d5db;padding:3px 10px;border-radius:2px;font-size:0.725rem;font-weight:600;font-family:var(--font-mono);text-transform:uppercase;letter-spacing:0.04em;">
          ⏳ Belum HAKI
        </div>
      </div>

      <div style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 0.5rem; margin-top: 0.875rem; padding-top: 0.75rem; border-top: 1px solid var(--clr-border);">
        <div style="font-family: var(--font-serif); font-weight: 700; color: var(--clr-terracotta); font-size: 1.05rem;">
          {{ formattedPrice }}
        </div>
        <div style="display: flex; gap: 6px; flex-shrink: 0;">
          <button class="btn btn-outline btn-sm" @click.stop="goToDetail">Lihat Karya</button>
          <a
            :href="waLink"
            target="_blank"
            rel="noopener noreferrer"
            class="btn btn-wa btn-sm"
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
  isNew: { type: Boolean, default: false }
});

const imgError = ref(false);

const subSektorMap = {
  'kuliner': { label: 'Kuliner', icon: '🍽️', bg: '#fdf2f0' },
  'kriya': { label: 'Kriya', icon: '🪡', bg: '#fbf7ee' },
  'fesyen': { label: 'Fesyen', icon: '👗', bg: '#fdf8ea' },
  'musik': { label: 'Musik', icon: '🎵', bg: '#f0f7ff' },
  'seni-pertunjukan': { label: 'Seni Pertunjukan', icon: '🎭', bg: '#faf0ff' },
  'seni-rupa': { label: 'Seni Rupa', icon: '🖼️', bg: '#fcf0f2' },
  'dkv': { label: 'DKV', icon: '🎨', bg: '#f0fdf4' },
  'desain-produk': { label: 'Desain Produk', icon: '⚙️', bg: '#f4f4f5' },
  'desain-interior': { label: 'Desain Interior', icon: '🏠', bg: '#fff7ed' },
  'arsitektur': { label: 'Arsitektur', icon: '🏛️', bg: '#f0f9ff' },
  'fotografi': { label: 'Fotografi', icon: '📷', bg: '#fdf4ff' },
  'game': { label: 'Game', icon: '🎮', bg: '#eef2ff' },
  'aplikasi': { label: 'Aplikasi', icon: '📱', bg: '#ecfeff' },
  'film': { label: 'Film & Video', icon: '🎬', bg: '#fff1f2' },
  'iklan': { label: 'Periklanan', icon: '📢', bg: '#fefce8' },
  'penerbitan': { label: 'Penerbitan', icon: '📚', bg: '#f0fdf4' },
  'tv-radio': { label: 'TV & Radio', icon: '📺', bg: '#faf5ff' },
};

const sektorData = computed(() => {
  const id = props.produk.usaha?.sub_sektor_id || 'kriya';
  return subSektorMap[id] || { label: id, icon: '🎨', bg: '#faf6f0' };
});

const mainImage = computed(() => {
  const urls = props.produk.produk?.foto_produk_urls;
  return Array.isArray(urls) && urls.length > 0 ? urls[0] : null;
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
