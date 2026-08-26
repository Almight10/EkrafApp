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
        <div v-if="hasHaki" class="card__haki-chip card__haki-chip--verified" style="display:inline-flex;align-items:center;gap:4px;">
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
            <path d="m9 12 2 2 4-4"></path>
          </svg>
          <span>HAKI Terverifikasi</span>
        </div>
        <!-- No HAKI: Muted gray chip -->
        <div v-else class="card__haki-chip card__haki-chip--pending" style="display:inline-flex;align-items:center;gap:4px;">
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"></circle>
            <line x1="12" y1="8" x2="12" y2="12"></line>
            <line x1="12" y1="16" x2="12.01" y2="16"></line>
          </svg>
          <span>Belum HAKI</span>
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
            aria-label="Pesan via WhatsApp"
          >
            <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" style="display:block;">
              <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.521.151-.172.2-.296.3-.495.099-.198.05-.372-.025-.521-.075-.148-.669-1.611-.916-2.206-.242-.579-.487-.501-.669-.51l-.57-.01c-.197 0-.52.074-.792.372s-1.04 1.016-1.04 2.479 1.065 2.876 1.213 3.074c.149.198 2.095 3.2 5.076 4.487.709.306 1.263.489 1.694.626.712.226 1.36.194 1.872.118.572-.085 1.758-.719 2.006-1.413.248-.695.248-1.29.173-1.414-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.99c-.002 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413Z"/>
            </svg>
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
