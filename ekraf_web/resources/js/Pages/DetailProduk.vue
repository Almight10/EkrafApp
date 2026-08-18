<template>
  <MainLayout>
    <!-- LOADING -->
    <div v-if="loading" style="padding:4rem 0;">
      <div class="spinner"></div>
    </div>

    <!-- NOT FOUND -->
    <div v-else-if="!produk" class="empty-state" style="padding:5rem 1rem;">
      <div class="empty-state__icon">😕</div>
      <h2 style="color:var(--clr-charcoal);font-family:var(--font-serif);">Produk tidak ditemukan</h2>
      <a href="/katalog" class="btn btn-primary" style="margin-top:1rem;">Kembali ke Katalog</a>
    </div>

    <!-- DETAIL PRODUK CONTENT -->
    <div v-else>
      <div class="container" style="padding:3rem 1.5rem 5rem;">
        <!-- HEADER TITLE -->
        <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:1.5rem;margin-bottom:1.5rem;flex-wrap:wrap;">
          <div>
            <h1 class="display-xl" style="margin:0 0 0.5rem;">
              {{ titleFirst }} <span class="serif-italic">{{ titleRest }}</span>
            </h1>
            <div style="display:flex;align-items:center;gap:0.75rem;margin-top:0.5rem;flex-wrap:wrap;">
              <span class="badge badge-accent">{{ produk.usaha?.sub_sektor_id || 'Ekraf' }}</span>
              <!-- <span style="color:var(--clr-muted);font-size:0.95rem;">📍 {{ produk.usaha?.alamat || 'Kota Probolinggo' }}</span> -->
            </div>
          </div>
        </div>

        <div style="display:grid;grid-template-columns:1.1fr 0.9fr;gap:3.5rem;align-items:start;" class="detail-layout">

          <!-- LEFT: GALLERY STACK -->
          <div class="animate-in">
            <div style="background:#fff;padding:12px;border:1px solid var(--clr-border);box-shadow:4px 4px 0px rgba(28,25,23,0.1);border-radius:2px;">
              <img
                v-if="activeImage && !hasDetailImgError"
                :src="activeImage"
                :alt="produk.usaha?.nama_usaha"
                class="product-gallery__main"
                @error="onDetailImgError"
              />
              <div v-else style="height:320px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:0.75rem;background:var(--clr-bg-alt);border-radius:2px;color:var(--clr-terracotta);">
                <span style="font-size:0.875rem;font-family:var(--font-mono);color:var(--clr-muted);font-weight:600;">Karya {{ produk.usaha?.sub_sektor_id || 'Ekraf' }}</span>
              </div>
            </div>

            <!-- Thumbs -->
            <div v-if="images.length > 1" class="product-gallery__thumbs">
              <img
                v-for="(img, idx) in images"
                :key="idx"
                :src="img"
                :alt="`Foto ${idx+1}`"
                class="product-gallery__thumb"
                :class="{ active: activeImage === img }"
                @click="activeImage = img"
              />
            </div>

            <!-- DESKRIPSI USAHA BOX (DI BAWAH GAMBAR) -->
            <div style="margin-top:2.5rem;background:#ffffff;border:1px solid var(--clr-border);box-shadow:4px 4px 0px rgba(192,72,40,0.15);padding:2rem;border-radius:2px;">
              <div style="font-family:var(--font-serif);font-size:1.35rem;font-weight:800;color:var(--clr-charcoal);margin-bottom:1rem;">
                Deskripsi Usaha & Karya
              </div>
              <div style="font-size:1rem;line-height:1.7;color:var(--clr-charcoal);white-space:pre-line;">
                {{ produk.produk?.deskripsi_produk || 'Deskripsi belum tersedia.' }}
              </div>
            </div>
          </div>

          <!-- RIGHT: ARTISAN INFO & HAKI CERTIFICATE -->
          <div class="animate-in delay-100" style="display:flex;flex-direction:column;gap:1.5rem;">

            <!-- COMBINED ARTISAN INFO CARD (PELAKU USAHA + TAHUN BERDIRI + LOKASI) -->
            <div class="product-detail__owner-combined">
              <!-- Top Row: Pelaku Usaha & Tahun Berdiri -->
              <div class="owner-card__top">
                <!-- Item 1: Pelaku Usaha -->
                <div class="owner-info-item">
                  <img
                    v-if="ownerPhoto && !hasOwnerPhotoError"
                    :src="ownerPhoto"
                    :alt="ownerName"
                    class="product-detail__owner-avatar"
                    @error="hasOwnerPhotoError = true"
                  />
                  <div
                    v-else
                    class="product-detail__owner-avatar product-detail__owner-avatar--placeholder"
                    aria-hidden="true"
                  >
                    {{ ownerInitial }}
                  </div>
                  <div>
                    <div class="product-detail__owner-label">Pelaku Usaha</div>
                    <div class="product-detail__owner-name">{{ ownerName }}</div>
                  </div>
                </div>

                <!-- Item 2: Tahun Berdiri -->
                <div class="owner-info-item owner-info-item--since">
                  <div class="product-detail__owner-avatar product-detail__owner-avatar--since" aria-hidden="true">
                    📅
                  </div>
                  <div>
                    <div class="product-detail__owner-label">Tahun Berdiri</div>
                    <div class="product-detail__owner-name">{{ produk.meta?.member_since || '2020' }}</div>
                  </div>
                </div>
              </div>

              <!-- Bottom Row: Lokasi -->
              <div class="owner-card__bottom" style="background:#ffffff;">
                <div class="product-detail__owner-avatar product-detail__owner-avatar--location" aria-hidden="true">
                  📍
                </div>
                <div>
                  <div class="product-detail__owner-label">Lokasi Usaha</div>
                  <div class="product-detail__owner-address">{{ produk.usaha?.alamat || 'Kota Probolinggo' }}</div>
                </div>
              </div>
            </div>

            <!-- Status HAKI Chip Card -->
            <div v-if="hasHaki" class="info-item" style="background:#fceae6;border-color:var(--clr-blush-dark);display:flex;align-items:center;justify-content:space-between;">
              <div>
                <div class="info-item__label" style="color:var(--clr-terracotta);">Status Legalitas</div>
                <div class="info-item__value" style="color:var(--clr-terracotta-dark);font-size:1.1rem;">✔ HAKI Terverifikasi</div>
              </div>
              <div style="font-size:1.5rem;">🏅</div>
            </div>
            <div v-else class="info-item" style="background:#f3f4f6;border-color:#d1d5db;display:flex;align-items:center;justify-content:space-between;">
              <div>
                <div class="info-item__label" style="color:#6b7280;">Status Legalitas</div>
                <div class="info-item__value" style="color:#374151;font-size:1.1rem;">⏳ Belum HAKI</div>
              </div>
              <div style="font-size:1.5rem;">📋</div>
            </div>

            <!-- PRICE & WHATSAPP ORDER BOX (Screenshot 3) -->
            <div style="background:#ffffff;border:1px solid var(--clr-border);box-shadow:3px 3px 0px rgba(28,25,23,0.1);padding:1.5rem;border-radius:2px;">
              <div class="info-item__label">Nilai Karya</div>
              <div style="font-family:var(--font-serif);font-size:2rem;font-weight:800;color:var(--clr-charcoal);margin-bottom:1rem;">
                {{ formattedPrice }}
              </div>
              <a
                :href="waLink"
                target="_blank"
                rel="noopener noreferrer"
                class="btn btn-wa btn-lg"
                style="width:100%;font-size:1rem;"
              >
                💬 Pesan via WhatsApp
              </a>
              <a
                v-if="produk.produk?.link_marketplace"
                :href="produk.produk.link_marketplace"
                target="_blank"
                rel="noopener noreferrer"
                class="btn btn-outline btn-lg"
                style="width:100%;font-size:1rem;margin-top:0.75rem;"
              >
                🛒 Beli via Marketplace
              </a>
              <div style="font-size:0.75rem;color:var(--clr-muted);text-align:center;margin-top:0.5rem;">Tersedia dalam jumlah terbatas</div>
            </div>

            <!-- HAKI CERTIFICATE OR NON-HAKI STATUS CARD -->
            <div style="margin-top:1rem;">
              <div style="font-family:var(--font-serif);font-size:1.35rem;font-weight:800;margin-bottom:1rem;text-align:center;">
                Sertifikasi Karya
              </div>

              <!-- IF HAS HAKI: SHOW OFFICIAL HAKI CERTIFICATE BOX -->
              <div v-if="hasHaki" style="background:#ffffff;border:2px solid var(--clr-border);padding:2rem 1.5rem;text-align:center;position:relative;box-shadow:0 8px 24px rgba(0,0,0,0.06);">
                <!-- Corner Ornaments -->
                <div style="position:absolute;top:8px;left:8px;font-size:0.8rem;color:var(--clr-muted);">✧</div>
                <div style="position:absolute;top:8px;right:8px;font-size:0.8rem;color:var(--clr-muted);">✧</div>
                <div style="position:absolute;bottom:8px;left:8px;font-size:0.8rem;color:var(--clr-muted);">✧</div>
                <div style="position:absolute;bottom:8px;right:8px;font-size:0.8rem;color:var(--clr-muted);">✧</div>

                <div style="font-family:var(--font-serif);font-size:1.15rem;font-weight:800;letter-spacing:0.05em;text-transform:uppercase;color:var(--clr-charcoal);margin-bottom:0.25rem;">
                  SERTIFIKAT KEKAYAAN INTELEKTUAL
                </div>
                <div style="font-family:var(--font-mono);font-size:0.85rem;color:var(--clr-terracotta);font-weight:700;margin-bottom:1rem;">
                  No. Registrasi: {{ produk.legalitas?.no_sertifikat_haki }}
                </div>

                <p style="font-size:0.8rem;color:var(--clr-muted);line-height:1.6;margin-bottom:1.25rem;">
                  Dengan ini menyatakan bahwa karya cipta <strong>"{{ produk.usaha?.nama_usaha }}"</strong> telah terdaftar dan dilindungi secara sah di bawah hukum Hak Kekayaan Intelektual Republik Indonesia.
                </p>

                <div style="display:inline-flex;align-items:center;gap:0.75rem;background:var(--clr-charcoal);color:#fff;padding:8px 16px;border-radius:2px;">
                  <span style="font-size:1.25rem;">⚙️</span>
                  <div style="text-align:left;">
                    <div style="font-family:var(--font-mono);font-size:0.7rem;font-weight:700;text-transform:uppercase;">OTENTIKASI DIGITAL EKRAF</div>
                    <div style="font-size:0.65rem;opacity:0.7;">Terverifikasi Resmi Kota Probolinggo</div>
                  </div>
                </div>
              </div>

              <!-- IF NO HAKI: SHOW UNVERIFIED / IN-PROGRESS NOTICE BOX -->
              <div v-else style="background:#fafafa;border:2px dashed #cbd5e1;padding:2rem 1.5rem;text-align:center;position:relative;">
                <div style="font-size:2rem;margin-bottom:0.5rem;">📋</div>
                <div style="font-family:var(--font-serif);font-size:1.1rem;font-weight:700;color:#334155;margin-bottom:0.5rem;">
                  Belum Bersertifikat HAKI
                </div>
                <p style="font-size:0.825rem;color:#64748b;line-height:1.6;margin-bottom:1.25rem;">
                  Karya <strong>"{{ produk.usaha?.nama_usaha }}"</strong> belum terdaftar dalam database Hak Kekayaan Intelektual (HAKI) atau sedang dalam proses pengajuan legalitas.
                </p>
                <div style="display:inline-flex;align-items:center;gap:0.5rem;background:#f1f5f9;color:#475569;border:1px solid #cbd5e1;padding:6px 14px;border-radius:2px;font-size:0.75rem;font-weight:600;font-family:var(--font-mono);">
                  ℹ️ Fasilitas Pendampingan HAKI Disediakan Dinas Ekraf
                </div>
              </div>
            </div>

          </div>
        </div>
      </div>
    </div>
  </MainLayout>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { supabase, isSupabaseConfigured, normalizeEkrafData, enrichOwnerProfilePhoto } from '../supabase.js';
import { dummyProducts, getDemoItemById, slugify } from '../dummyData.js';
import MainLayout from '../Layouts/MainLayout.vue';

const loading = ref(true);
const produk = ref(null);
const activeImage = ref(null);
const hasDetailImgError = ref(false);
const hasOwnerPhotoError = ref(false);

function onDetailImgError() {
  hasDetailImgError.value = true;
}

const ownerName = computed(() => {
  return produk.value?.identitas?.nama_lengkap || 'Pelaku Ekraf';
});

const ownerPhoto = computed(() => {
  return produk.value?.identitas?.foto_url || '';
});

const ownerInitial = computed(() => {
  const name = ownerName.value.trim();
  return name ? name.charAt(0).toUpperCase() : '?';
});

const titleFirst = computed(() => {
  const name = produk.value?.usaha?.nama_usaha || 'Karya Ekraf';
  const parts = name.split(' ');
  if (parts.length <= 1) return name;
  return parts.slice(0, Math.ceil(parts.length / 2)).join(' ');
});

const titleRest = computed(() => {
  const name = produk.value?.usaha?.nama_usaha || '';
  const parts = name.split(' ');
  if (parts.length <= 1) return '';
  return parts.slice(Math.ceil(parts.length / 2)).join(' ');
});

const images = computed(() => {
  return produk.value?.produk?.foto_produk_urls || [];
});

const hasHaki = computed(() => {
  return !!(produk.value?.legalitas?.no_sertifikat_haki);
});

const formattedPrice = computed(() => {
  const h = produk.value?.produk?.harga;
  if (!h || isNaN(h)) return 'Hubungi Pemilik';
  return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(h);
});

const waLink = computed(() => {
  const phone = produk.value?.identitas?.no_wa || produk.value?.users?.no_hp || '6281234567890';
  const cleanPhone = phone.replace(/[^0-9]/g, '');
  const formattedPhone = cleanPhone.startsWith('0') ? '62' + cleanPhone.slice(1) : cleanPhone;
  const text = encodeURIComponent(`Halo, saya tertarik dengan karya "${produk.value?.usaha?.nama_usaha || 'Ekraf'}" di Platform Ekraf Kota Probolinggo.`);
  return `https://wa.me/${formattedPhone}?text=${text}`;
});

async function loadDetail() {
  const pathParts = window.location.pathname.split('/');
  const rawParam = pathParts[pathParts.length - 1];
  const param = decodeURIComponent(rawParam).trim();
  const targetSlug = slugify(param);

  if (!isSupabaseConfigured) {
    produk.value = await enrichOwnerProfilePhoto(getDemoItemById(param));
    hasOwnerPhotoError.value = false;
    if (produk.value && images.value.length > 0) {
      activeImage.value = images.value[0];
    }
    loading.value = false;
    return;
  }

  try {
    // 1. Fetch rows from Supabase ekraf_data table to match pure slug or ID
    const { data: list, error } = await supabase
      .from('ekraf_data')
      .select('*, users!user_id(alamat, kecamatan, kelurahan, no_hp, nama_lengkap, foto_url)');

    if (error) console.warn('[Ekraf] Supabase query notice:', error?.message || error);

    let matchedRow = null;
    if (list && list.length > 0) {
      // Step A: Exact ID match
      matchedRow = list.find(row => String(row.id) === param);

      // Step B: Exact slug match on any name field
      if (!matchedRow) {
        matchedRow = list.find(row => {
          const norm = normalizeEkrafData(row);
          const candidates = [
            norm.usaha?.nama_usaha,
            row.nama_brand,
            row.namaBrand,
            row.nama_usaha,
            row.namaUsaha,
            row.nama_produk_unggulan,
            row.namaProdukUnggulan,
            row.id,
          ];
          return candidates.some(c => c && slugify(c) === targetSlug);
        });
      }

      // Step C: Flexible substring match
      if (!matchedRow) {
        matchedRow = list.find(row => {
          const norm = normalizeEkrafData(row);
          const name = (norm.usaha?.nama_usaha || row.nama_brand || row.nama_usaha || '').toLowerCase();
          const cleanParam = param.toLowerCase().replace(/-/g, ' ');
          return name && cleanParam && (name.includes(cleanParam) || cleanParam.includes(name));
        });
      }
    }

    if (matchedRow) {
      produk.value = await enrichOwnerProfilePhoto(normalizeEkrafData(matchedRow));
      hasOwnerPhotoError.value = false;
      if (images.value.length > 0) activeImage.value = images.value[0];
    } else {
      // Search demo items strictly
      const demoMatch = dummyProducts.find(p => {
        const s = slugify(p.usaha?.nama_usaha || p.title || p.id);
        return s === targetSlug || p.id === param;
      });

      if (demoMatch) {
        produk.value = await enrichOwnerProfilePhoto(demoMatch);
        hasOwnerPhotoError.value = false;
        if (images.value.length > 0) activeImage.value = images.value[0];
      } else if (list && list.length > 0) {
        produk.value = await enrichOwnerProfilePhoto(normalizeEkrafData(list[0]));
        hasOwnerPhotoError.value = false;
        if (images.value.length > 0) activeImage.value = images.value[0];
      } else {
        produk.value = await enrichOwnerProfilePhoto(dummyProducts[0]);
        hasOwnerPhotoError.value = false;
      }
    }
  } catch (err) {
    console.error('[Ekraf] Gagal memuat detail:', err?.message || err);
    produk.value = dummyProducts[0];
  } finally {
    loading.value = false;
  }
}

onMounted(() => {
  loadDetail();
});
</script>
