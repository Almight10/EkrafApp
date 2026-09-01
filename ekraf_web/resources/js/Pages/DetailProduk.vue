<template>
  <MainLayout>
    <!-- LOADING SKELETON -->
    <div v-if="loading" class="container detail-container">
      <div style="margin-bottom:1.5rem;">
        <div class="skeleton" style="height:2.5rem;width:55%;margin-bottom:0.75rem;border-radius:4px;"></div>
        <div class="skeleton" style="height:1.25rem;width:20%;border-radius:4px;"></div>
      </div>
      <div class="detail-layout">
        <div>
          <div style="background:#fff;padding:12px;border:1px solid var(--clr-border);box-shadow:4px 4px 0px rgba(28,25,23,0.1);border-radius:2px;">
            <div class="skeleton" style="width:100%;aspect-ratio:1;border-radius:2px;"></div>
          </div>
          <div style="margin-top:2.5rem;background:#ffffff;border:1px solid var(--clr-border);box-shadow:4px 4px 0px rgba(192,72,40,0.15);padding:2rem;border-radius:2px;">
            <div class="skeleton" style="height:1.5rem;width:45%;margin-bottom:1rem;"></div>
            <div class="skeleton" style="height:1rem;width:100%;margin-bottom:0.5rem;"></div>
            <div class="skeleton" style="height:1rem;width:92%;margin-bottom:0.5rem;"></div>
            <div class="skeleton" style="height:1rem;width:70%;"></div>
          </div>
        </div>
        <div style="display:flex;flex-direction:column;gap:1.5rem;">
          <div class="skeleton" style="height:130px;width:100%;border-radius:4px;"></div>
          <div class="skeleton" style="height:55px;width:100%;border-radius:4px;"></div>
          <div class="skeleton" style="height:170px;width:100%;border-radius:4px;"></div>
          <div class="skeleton" style="height:190px;width:100%;border-radius:4px;"></div>
        </div>
      </div>
    </div>

    <!-- NOT FOUND -->
    <div v-else-if="!loading && !produk" class="detail-notfound-wrap">
      <div class="detail-notfound-card">
        <!-- Decorative corner marks -->
        <div class="detail-notfound-corner detail-notfound-corner--tl">✦</div>
        <div class="detail-notfound-corner detail-notfound-corner--tr">✦</div>
        <div class="detail-notfound-corner detail-notfound-corner--bl">✦</div>
        <div class="detail-notfound-corner detail-notfound-corner--br">✦</div>

        <!-- SVG Illustration -->
        <div class="detail-notfound-icon-wrap">
          <svg width="72" height="72" viewBox="0 0 72 72" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
            <!-- Outer dashed ring -->
            <circle cx="36" cy="36" r="34" stroke="var(--clr-border)" stroke-width="1.5" stroke-dasharray="6 4"/>
            <!-- Inner filled circle -->
            <circle cx="36" cy="36" r="26" fill="var(--clr-blush)" stroke="var(--clr-blush-dark)" stroke-width="1.5"/>
            <!-- Search glass body — centered at (33,33) -->
            <circle cx="33" cy="33" r="10" stroke="var(--clr-terracotta)" stroke-width="2.5"/>
            <!-- Search handle — extends bottom-right -->
            <line x1="40.5" y1="40.5" x2="47.5" y2="47.5" stroke="var(--clr-terracotta)" stroke-width="2.5" stroke-linecap="round"/>
            <!-- X inside glass — centered at (33,33) -->
            <line x1="29" y1="29" x2="37" y2="37" stroke="var(--clr-terracotta)" stroke-width="2" stroke-linecap="round"/>
            <line x1="37" y1="29" x2="29" y2="37" stroke="var(--clr-terracotta)" stroke-width="2" stroke-linecap="round"/>
          </svg>
        </div>

        <!-- Label chip -->
        <div class="detail-notfound-chip">
          <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
          INFORMASI
        </div>

        <!-- Heading -->
        <h2 class="detail-notfound-title">
          Karya Tidak<br/>
          <span class="serif-italic" style="color:var(--clr-terracotta);">Ditemukan</span>
        </h2>

        <!-- Sub text -->
        <p class="detail-notfound-desc">
          Karya yang Anda cari tidak tersedia atau alamat URL tidak sesuai.
        </p>

        <!-- Actions -->
        <div class="detail-notfound-actions">
          <a href="/katalog" class="btn btn-primary" style="display:inline-flex;align-items:center;gap:8px;">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
            Jelajahi Katalog
          </a>
          <a href="/" class="btn btn-outline" style="display:inline-flex;align-items:center;gap:8px;">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
            Ke Beranda
          </a>
        </div>
      </div>
    </div>

    <!-- DETAIL PRODUK CONTENT -->
    <div v-else>
      <div class="container detail-container">
        <!-- HEADER TITLE -->
        <div class="detail-header">
          <div>
            <h1 class="display-xl" style="margin:0 0 0.5rem; overflow-wrap: anywhere; word-break: break-word;">
              {{ titleFirst }} <span class="serif-italic">{{ titleRest }}</span>
            </h1>
            <div style="display:flex;align-items:center;gap:0.75rem;margin-top:0.5rem;flex-wrap:wrap;">
              <span class="badge badge-accent">{{ sektorName }}</span>
            </div>
          </div>
        </div>

        <div class="detail-layout">

          <!-- LEFT: GALLERY STACK -->
          <div class="animate-in">
            <div style="background:#fff;padding:12px;border:1px solid var(--clr-border);box-shadow:4px 4px 0px rgba(28,25,23,0.1);border-radius:2px;">
              <img
                v-if="activeImage && !hasDetailImgError"
                :src="getOptimizedImg(activeImage, 600)"
                :alt="produk.usaha?.nama_usaha"
                class="product-gallery__main"
                fetchpriority="high"
                decoding="async"
                width="600"
                height="600"
                @error="onDetailImgError"
              />
              <div v-else style="height:320px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:0.75rem;background:var(--clr-bg-alt);border-radius:2px;color:var(--clr-terracotta);">
                <span style="font-size:0.875rem;font-family:var(--font-mono);color:var(--clr-muted);font-weight:600;">Karya {{ sektorName }}</span>
              </div>
            </div>

            <!-- Thumbs -->
            <div v-if="images.length > 1" class="product-gallery__thumbs">
              <img
                v-for="(img, idx) in images"
                :key="idx"
                :src="getOptimizedImg(img, 200)"
                :alt="`Foto ${idx+1}`"
                class="product-gallery__thumb"
                :class="{ active: activeImage === img }"
                loading="lazy"
                decoding="async"
                width="76"
                height="76"
                @click="selectImage(img)"
              />
            </div>

            <!-- DESKRIPSI USAHA BOX (DI BAWAH GAMBAR) -->
            <div class="detail-desc-box">
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
                    :src="getOptimizedImg(ownerPhoto, 120)"
                    :alt="ownerName"
                    class="product-detail__owner-avatar"
                    width="44"
                    height="44"
                    loading="lazy"
                    decoding="async"
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
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                      <line x1="16" y1="2" x2="16" y2="6"></line>
                      <line x1="8" y1="2" x2="8" y2="6"></line>
                      <line x1="3" y1="10" x2="21" y2="10"></line>
                    </svg>
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
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                    <circle cx="12" cy="10" r="3"></circle>
                  </svg>
                </div>
                <div>
                  <div class="product-detail__owner-label">Lokasi Usaha</div>
                  <div class="product-detail__owner-address">{{ ownerAddress }}</div>
                </div>
              </div>
            </div>

            <!-- Status HAKI Chip Card -->
            <div v-if="hasHaki" class="info-item" style="background:#fceae6;border-color:var(--clr-blush-dark);display:flex;align-items:center;justify-content:space-between;">
              <div>
                <div class="info-item__label" style="color:var(--clr-terracotta);">Status Legalitas</div>
                <div class="info-item__value" style="color:var(--clr-terracotta-dark);font-size:1.1rem;display:flex;align-items:center;gap:6px;">
                  <span>HAKI Terverifikasi</span>
                </div>
              </div>
              <div style="display:flex;align-items:center;color:var(--clr-terracotta);">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                  <path d="m9 12 2 2 4-4"></path>
                </svg>
              </div>
            </div>
            <div v-else class="info-item" style="background:#f3f4f6;border-color:#d1d5db;display:flex;align-items:center;justify-content:space-between;">
              <div>
                <div class="info-item__label" style="color:#6b7280;">Status Legalitas</div>
                <div class="info-item__value" style="color:#374151;font-size:1.1rem;display:flex;align-items:center;gap:6px;">
                  <span>Belum HAKI</span>
                </div>
              </div>
              <div style="display:flex;align-items:center;color:#6b7280;">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <circle cx="12" cy="12" r="10"></circle>
                  <line x1="12" y1="8" x2="12" y2="12"></line>
                  <line x1="12" y1="16" x2="12.01" y2="16"></line>
                </svg>
              </div>
            </div>

            <!-- PRICE & WHATSAPP ORDER BOX (Screenshot 3) -->
            <div style="background:#ffffff;border:1px solid var(--clr-border);box-shadow:3px 3px 0px rgba(28,25,23,0.1);padding:1.5rem;border-radius:2px;">
              <div class="info-item__label">Nilai Karya</div>
              <div style="font-family:var(--font-serif);font-size:2rem;font-weight:800;color:var(--clr-charcoal);margin-bottom:1rem;">
                {{ formattedPrice }}
              </div>
              <button
                type="button"
                class="btn btn-wa btn-lg"
                style="width:100%;font-size:1rem;display:inline-flex;align-items:center;justify-content:center;gap:8px;"
                @click="openOrderModal"
              >
                <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" style="display:block;">
                  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.521.151-.172.2-.296.3-.495.099-.198.05-.372-.025-.521-.075-.148-.669-1.611-.916-2.206-.242-.579-.487-.501-.669-.51l-.57-.01c-.197 0-.52.074-.792.372s-1.04 1.016-1.04 2.479 1.065 2.876 1.213 3.074c.149.198 2.095 3.2 5.076 4.487.709.306 1.263.489 1.694.626.712.226 1.36.194 1.872.118.572-.085 1.758-.719 2.006-1.413.248-.695.248-1.29.173-1.414-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.99c-.002 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413Z"/>
                </svg>
                <span>Pesan via WhatsApp</span>
              </button>
              <a
                v-if="produk.produk?.link_marketplace"
                :href="produk.produk.link_marketplace"
                target="_blank"
                rel="noopener noreferrer"
                class="btn btn-outline btn-lg"
                style="width:100%;font-size:1rem;margin-top:0.75rem;display:inline-flex;align-items:center;justify-content:center;gap:8px;"
              >
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path>
                  <line x1="3" y1="6" x2="21" y2="6"></line>
                  <path d="M16 10a4 4 0 0 1-8 0"></path>
                </svg>
                <span>Beli via Marketplace</span>
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
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                    <path d="m9 12 2 2 4-4"></path>
                  </svg>
                  <div style="text-align:left;">
                    <div style="font-family:var(--font-mono);font-size:0.7rem;font-weight:700;text-transform:uppercase;">OTENTIKASI DIGITAL EKRAF</div>
                    <div style="font-size:0.65rem;opacity:0.7;">Terverifikasi Resmi Kota Probolinggo</div>
                  </div>
                </div>
              </div>

              <!-- IF NO HAKI: SHOW UNVERIFIED / IN-PROGRESS NOTICE BOX -->
              <div v-else style="background:#fafafa;border:2px dashed #cbd5e1;padding:2rem 1.5rem;text-align:center;position:relative;">
                <div style="display:flex;align-items:center;justify-content:center;margin-bottom:0.75rem;">
                  <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#64748b" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"></circle>
                    <line x1="12" y1="8" x2="12" y2="12"></line>
                    <line x1="12" y1="16" x2="12.01" y2="16"></line>
                  </svg>
                </div>
                <div style="font-family:var(--font-serif);font-size:1.1rem;font-weight:700;color:#334155;margin-bottom:0.5rem;">
                  Belum Bersertifikat HAKI
                </div>
                <p style="font-size:0.825rem;color:#64748b;line-height:1.6;margin-bottom:1.25rem;">
                  Karya <strong>"{{ produk.usaha?.nama_usaha }}"</strong> belum terdaftar dalam database Hak Kekayaan Intelektual (HAKI) atau sedang dalam proses pengajuan legalitas.
                </p>
                <div style="display:inline-flex;align-items:center;gap:0.5rem;background:#f1f5f9;color:#475569;border:1px solid #cbd5e1;padding:6px 14px;border-radius:2px;font-size:0.75rem;font-weight:600;font-family:var(--font-mono);">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"></circle>
                    <line x1="12" y1="16" x2="12" y2="12"></line>
                    <line x1="12" y1="8" x2="12.01" y2="8"></line>
                  </svg>
                  <span>Fasilitas Pendampingan HAKI Disediakan Dinas Ekraf</span>
                </div>
              </div>
            </div>

          </div>
        </div>
      </div>
    </div>

    <!-- ORDER & ADDRESS SELECTION MODAL -->
    <transition name="order-modal-fade">
      <div v-if="showOrderModal" class="order-modal-overlay" @click.self="closeOrderModal">
        <div class="order-modal-card animate-in">
          <!-- Header -->
          <div class="order-modal-header">
            <div>
              <div class="order-modal-badge">Pemesanan Direct</div>
              <h3 class="order-modal-title">Form Pemesanan Karya</h3>
            </div>
            <button class="order-modal-close-btn" @click="closeOrderModal" aria-label="Tutup">&times;</button>
          </div>

          <!-- Body -->
          <div class="order-modal-body">
            <!-- Product Brief -->
            <div class="order-product-brief">
              <img
                v-if="activeImage"
                :src="getOptimizedImg(activeImage, 120)"
                :alt="produk?.usaha?.nama_usaha"
                class="order-product-thumb"
              />
              <div class="order-product-meta">
                <div class="order-product-title">{{ produk?.usaha?.nama_usaha }}</div>
                <div class="order-product-price">{{ formattedPrice }}</div>
                <div class="order-product-owner">Penjual: {{ ownerName }}</div>
              </div>
            </div>

            <!-- Form: Nama Pemesan -->
            <div class="order-form-group">
              <label class="order-form-label">Nama Pemesan</label>
              <input
                v-model="orderForm.buyerName"
                type="text"
                class="order-form-input"
                placeholder="Masukkan nama lengkap Anda"
              />
            </div>

            <!-- Form: 2 Cara Input Alamat -->
            <div class="order-form-group">
              <div class="order-form-label-row">
                <label class="order-form-label">Alamat Pengiriman</label>
                <span class="order-form-subhint">Pilih salah satu dari 2 cara</span>
              </div>

              <!-- Address Mode Selection Grid -->
              <div class="address-mode-grid">
                <!-- CARA 1: ALAMAT PROFIL -->
                <div
                  class="address-mode-card"
                  :class="{ active: orderForm.addressMode === 'profile' }"
                  @click="orderForm.addressMode = 'profile'"
                >
                  <div class="address-mode-card__top">
                    <div class="address-mode-card__radio">
                      <span v-if="orderForm.addressMode === 'profile'" class="radio-dot"></span>
                    </div>
                    <div class="address-mode-card__title">Pakai Alamat Profil</div>
                  </div>
                  <div class="address-mode-card__desc">
                    Menggunakan alamat resmi yang terdaftar di profil.
                  </div>
                  <div class="address-mode-card__preview">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                      <circle cx="12" cy="10" r="3"></circle>
                    </svg>
                    <span>{{ profileAddressText }}</span>
                  </div>
                </div>

                <!-- CARA 2: MENGISI ALAMAT BERBEDA -->
                <div
                  class="address-mode-card"
                  :class="{ active: orderForm.addressMode === 'custom' }"
                  @click="orderForm.addressMode = 'custom'"
                >
                  <div class="address-mode-card__top">
                    <div class="address-mode-card__radio">
                      <span v-if="orderForm.addressMode === 'custom'" class="radio-dot"></span>
                    </div>
                    <div class="address-mode-card__title">Mengisi Alamat Berbeda</div>
                  </div>
                  <div class="address-mode-card__desc">
                    Ketik manual alamat pengiriman alternatif/baru.
                  </div>
                  <div class="address-mode-card__preview">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                      <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                    </svg>
                    <span>Input alamat custom</span>
                  </div>
                </div>
              </div>

              <!-- OPTIONAL EDIT PROFILE ADDRESS (If Profile mode selected) -->
              <div v-if="orderForm.addressMode === 'profile'" class="address-profile-edit-box">
                <button
                  type="button"
                  class="btn-text-link"
                  @click="orderForm.isEditingProfileAddress = !orderForm.isEditingProfileAddress"
                >
                  {{ orderForm.isEditingProfileAddress ? '✕ Batal Edit Alamat Profil' : '✏ Ubah / Update Alamat Profil Simpanan' }}
                </button>
                <div v-if="orderForm.isEditingProfileAddress" style="margin-top:0.5rem;display:flex;gap:8px;">
                  <input
                    v-model="orderForm.savedProfileAddressInput"
                    type="text"
                    class="order-form-input"
                    placeholder="Masukkan alamat profil baru Anda..."
                  />
                  <button type="button" class="btn btn-primary btn-sm" @click="saveEditedProfileAddress">
                    Simpan
                  </button>
                </div>
              </div>

              <!-- INPUT CUSTOM ADDRESS TEXTAREA (If Custom mode selected) -->
              <div v-if="orderForm.addressMode === 'custom'" class="address-custom-input-box">
                <textarea
                  v-model="orderForm.customAddress"
                  class="order-form-textarea"
                  rows="3"
                  placeholder="Masukkan alamat pengiriman baru secara lengkap (Jalan, RT/RW, Kelurahan, Kecamatan, Kota, Kode Pos)..."
                ></textarea>
              </div>
            </div>

            <!-- Form: Catatan -->
            <div class="order-form-group" style="margin-bottom:0;">
              <label class="order-form-label">Catatan Pesanan (Opsional)</label>
              <input
                v-model="orderForm.notes"
                type="text"
                class="order-form-input"
                placeholder="Jumlah item, pilihan warna/ukuran, atau pesan khusus"
              />
            </div>
          </div>

          <!-- Footer -->
          <div class="order-modal-footer">
            <button type="button" class="btn btn-outline" @click="closeOrderModal">
              Batal
            </button>
            <button type="button" class="btn btn-wa" @click="submitOrderToWa">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
                <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.521.151-.172.2-.296.3-.495.099-.198.05-.372-.025-.521-.075-.148-.669-1.611-.916-2.206-.242-.579-.487-.501-.669-.51l-.57-.01c-.197 0-.52.074-.792.372s-1.04 1.016-1.04 2.479 1.065 2.876 1.213 3.074c.149.198 2.095 3.2 5.076 4.487.709.306 1.263.489 1.694.626.712.226 1.36.194 1.872.118.572-.085 1.758-.719 2.006-1.413.248-.695.248-1.29.173-1.414-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.99c-.002 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413Z"/>
              </svg>
              <span>Lanjutkan ke WhatsApp</span>
            </button>
          </div>
        </div>
      </div>
    </transition>
  </MainLayout>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue';
import { supabase, isSupabaseConfigured, normalizeEkrafData, enrichOwnerProfilePhoto } from '../supabase.js';
import { slugify } from '../dummyData.js';
import MainLayout from '../Layouts/MainLayout.vue';

const loading = ref(true);
const produk = ref(null);
const activeImage = ref(null);
const hasDetailImgError = ref(false);
const hasOwnerPhotoError = ref(false);

function onDetailImgError() {
  hasDetailImgError.value = true;
}

function selectImage(img) {
  activeImage.value = img;
  hasDetailImgError.value = false;
}

watch(activeImage, () => {
  hasDetailImgError.value = false;
});

function getOptimizedImg(url, width = 600) {
  if (!url) return '';
  if (url.includes('images.unsplash.com')) {
    let clean = url.replace(/w=\d+/, `w=${width}`).replace(/q=\d+/, 'q=75');
    if (!clean.includes('fm=webp')) {
      clean += '&fm=webp';
    }
    return clean;
  }
  return url;
}

const subSektorNames = {
  'aplikasi-game': 'Aplikasi & Game Developer',
  'aplikasi': 'Aplikasi & Game Developer',
  'game': 'Aplikasi & Game Developer',
  'arsitektur': 'Arsitektur',
  'desain-interior': 'Desain Interior',
  'dkv': 'Desain Komunikasi Visual',
  'desain-produk': 'Desain Produk',
  'fesyen': 'Fashion',
  'fashion': 'Fashion',
  'film': 'Film, Animasi & Video',
  'fotografi': 'Fotografi',
  'kriya': 'Kriya',
  'kuliner': 'Kuliner',
  'musik': 'Musik',
  'penerbitan': 'Penerbitan',
  'periklanan': 'Periklanan',
  'iklan': 'Periklanan',
  'seni-pertunjukan': 'Seni Pertunjukan',
  'seni-rupa': 'Seni Rupa',
  'tv-radio': 'Televisi & Radio',
  'lainnya': 'Lainnya',
};

const sektorName = computed(() => {
  const id = produk.value?.usaha?.sub_sektor_id;
  return subSektorNames[id] || id || 'Ekraf';
});

const ownerName = computed(() => {
  return produk.value?.identitas?.nama_lengkap || 'Pelaku Ekraf';
});

const ownerAddress = computed(() => {
  const uAlamat = produk.value?.usaha?.alamat;
  const iAlamat = produk.value?.identitas?.alamat;
  const kec = produk.value?.identitas?.kecamatan;
  const kel = produk.value?.identitas?.kelurahan;
  
  if (uAlamat && uAlamat !== 'Kota Probolinggo') return uAlamat;
  const fullLoc = [iAlamat, kel ? `Kel. ${kel}` : '', kec ? `Kec. ${kec}` : ''].filter(Boolean).join(', ');
  return fullLoc || uAlamat || 'Kota Probolinggo';
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
  const text = encodeURIComponent(`Halo, saya tertarik dengan "${produk.value?.usaha?.nama_usaha || 'Ekraf'}" di Platform Ekraf Kota Probolinggo.`);
  return `https://wa.me/${formattedPhone}?text=${text}`;
});

const showOrderModal = ref(false);
const orderForm = ref({
  buyerName: '',
  addressMode: 'profile', // 'profile' (Cara 1: Profil) or 'custom' (Cara 2: Mengisi Alamat Berbeda)
  customAddress: '',
  notes: '',
  isEditingProfileAddress: false,
  savedProfileAddressInput: '',
});

const profileAddressText = computed(() => {
  const saved = typeof localStorage !== 'undefined' ? localStorage.getItem('ekraf_user_profile_address') : '';
  if (saved && saved.trim()) return saved.trim();

  const pAddr = produk.value?.identitas?.alamat;
  const pKec = produk.value?.identitas?.kecamatan;
  const pKel = produk.value?.identitas?.kelurahan;
  const fullLoc = [pAddr, pKel ? `Kel. ${pKel}` : '', pKec ? `Kec. ${pKec}` : ''].filter(Boolean).join(', ');
  
  return fullLoc || ownerAddress.value || 'Kota Probolinggo';
});

function openOrderModal() {
  const savedName = typeof localStorage !== 'undefined' ? localStorage.getItem('ekraf_buyer_name') : '';
  const savedCustom = typeof localStorage !== 'undefined' ? localStorage.getItem('ekraf_last_custom_address') : '';
  
  orderForm.value.buyerName = savedName || '';
  orderForm.value.customAddress = savedCustom || '';
  orderForm.value.addressMode = 'profile';
  orderForm.value.notes = '';
  orderForm.value.isEditingProfileAddress = false;
  orderForm.value.savedProfileAddressInput = profileAddressText.value;
  
  showOrderModal.value = true;
}

function closeOrderModal() {
  showOrderModal.value = false;
}

function saveEditedProfileAddress() {
  if (orderForm.value.savedProfileAddressInput.trim()) {
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem('ekraf_user_profile_address', orderForm.value.savedProfileAddressInput.trim());
    }
  }
  orderForm.value.isEditingProfileAddress = false;
}

function submitOrderToWa() {
  const phone = produk.value?.identitas?.no_wa || produk.value?.users?.no_hp || '6281234567890';
  const cleanPhone = phone.replace(/[^0-9]/g, '');
  const formattedPhone = cleanPhone.startsWith('0') ? '62' + cleanPhone.slice(1) : cleanPhone;

  const buyerName = orderForm.value.buyerName.trim() || 'Pembeli';
  
  let selectedAddress = '';
  let addressLabel = '';
  
  if (orderForm.value.addressMode === 'profile') {
    selectedAddress = profileAddressText.value;
    addressLabel = ' [Alamat dari Profil]';
  } else {
    selectedAddress = orderForm.value.customAddress.trim() || 'Alamat tidak diisi';
    addressLabel = ' [Alamat Berbeda]';
  }

  let text = `Halo, saya ${buyerName} berminat memesan karya "${produk.value?.usaha?.nama_usaha || 'Ekraf'}".\n\n`;
  text += `*Detail Pesanan:*\n`;
  text += `- Karya: ${produk.value?.usaha?.nama_usaha || 'Ekraf'}\n`;
  text += `- Nilai Karya: ${formattedPrice.value}\n`;
  text += `- Alamat Pengiriman: ${selectedAddress}${addressLabel}\n`;

  if (orderForm.value.notes.trim()) {
    text += `- Catatan: ${orderForm.value.notes.trim()}\n`;
  }

  text += `\nMohon informasi ketersediaan & proses pemesanan. Terima kasih!`;

  if (typeof localStorage !== 'undefined') {
    localStorage.setItem('ekraf_buyer_name', buyerName);
    if (orderForm.value.addressMode === 'custom' && orderForm.value.customAddress.trim()) {
      localStorage.setItem('ekraf_last_custom_address', orderForm.value.customAddress.trim());
    }
  }

  const waUrl = `https://wa.me/${formattedPhone}?text=${encodeURIComponent(text)}`;
  window.open(waUrl, '_blank');
  closeOrderModal();
}

async function loadDetail() {
  loading.value = true;
  produk.value = null;
  const startTime = Date.now();

  const pathParts = window.location.pathname.split('/');
  const rawParam = pathParts[pathParts.length - 1];
  const param = decodeURIComponent(rawParam).trim();
  const targetSlug = slugify(param);

  if (!isSupabaseConfigured) {
    loading.value = false;
    return;
  }

  try {
    const { data: list, error } = await supabase
      .from('ekraf_data')
      .select('*, users:user_id(nama_lengkap, no_hp, alamat, kecamatan, kelurahan, foto_url)');

    if (error) console.warn('[Ekraf] Supabase query notice:', error?.message || error);

    let matchedRow = null;
    if (list && list.length > 0) {
      matchedRow = list.find(row => String(row.id) === param);

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
    }

    if (matchedRow) {
      const normalized = normalizeEkrafData(matchedRow);
      produk.value = normalized;
      hasDetailImgError.value = false;
      hasOwnerPhotoError.value = false;
      if (normalized.produk?.foto_produk_urls?.length > 0) {
        activeImage.value = normalized.produk.foto_produk_urls[0];
      }
      enrichOwnerProfilePhoto(normalized).then(enriched => {
        if (enriched) produk.value = enriched;
      });
    } else {
      produk.value = null;
    }
  } catch (err) {
    console.error('[Ekraf] Gagal memuat detail:', err?.message || err);
    produk.value = null;
  } finally {
    const elapsed = Date.now() - startTime;
    const remaining = Math.max(0, 500 - elapsed);
    if (remaining > 0) await new Promise(r => setTimeout(r, remaining));
    loading.value = false;
  }
}

onMounted(() => {
  loadDetail();
});
</script>

<style scoped>
/* Order Modal Overlay */
.order-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 999;
  background: rgba(28, 25, 23, 0.65);
  backdrop-filter: blur(6px);
  -webkit-backdrop-filter: blur(6px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1.25rem;
}

/* Modal Card */
.order-modal-card {
  background: #ffffff;
  border: 2px solid var(--clr-charcoal);
  box-shadow: 8px 8px 0px rgba(28, 25, 23, 0.9);
  width: 100%;
  max-width: 540px;
  border-radius: 4px;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.order-modal-header {
  padding: 1.25rem 1.5rem;
  background: var(--clr-bg-alt);
  border-bottom: 1px solid var(--clr-border);
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 1rem;
}

.order-modal-badge {
  font-family: var(--font-mono);
  font-size: 0.68rem;
  font-weight: 700;
  text-transform: uppercase;
  color: var(--clr-terracotta);
  letter-spacing: 0.05em;
  margin-bottom: 0.25rem;
}

.order-modal-title {
  font-family: var(--font-serif);
  font-size: 1.35rem;
  font-weight: 800;
  color: var(--clr-charcoal);
  margin: 0;
}

.order-modal-close-btn {
  background: transparent;
  border: none;
  font-size: 1.75rem;
  line-height: 1;
  color: var(--clr-muted);
  cursor: pointer;
  padding: 0;
  transition: color 200ms ease;
}

.order-modal-close-btn:hover {
  color: var(--clr-terracotta);
}

.order-modal-body {
  padding: 1.5rem;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

/* Item brief box */
.order-product-brief {
  display: flex;
  align-items: center;
  gap: 1rem;
  background: var(--clr-blush);
  border: 1px solid var(--clr-blush-dark);
  padding: 0.85rem 1rem;
  border-radius: 4px;
}

.order-product-thumb {
  width: 56px;
  height: 56px;
  object-fit: cover;
  border-radius: 4px;
  border: 1px solid var(--clr-border);
}

.order-product-meta {
  display: flex;
  flex-direction: column;
}

.order-product-title {
  font-family: var(--font-serif);
  font-weight: 700;
  font-size: 1rem;
  color: var(--clr-charcoal);
}

.order-product-price {
  font-family: var(--font-sans);
  font-weight: 800;
  font-size: 0.95rem;
  color: var(--clr-terracotta);
}

.order-product-owner {
  font-size: 0.775rem;
  color: var(--clr-muted);
}

/* Form controls */
.order-form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.order-form-label-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.order-form-label {
  font-family: var(--font-sans);
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--clr-charcoal);
}

.order-form-subhint {
  font-size: 0.725rem;
  color: var(--clr-muted);
  font-family: var(--font-mono);
}

.order-form-input, .order-form-textarea {
  width: 100%;
  padding: 0.65rem 0.85rem;
  font-family: var(--font-sans);
  font-size: 0.875rem;
  border: 1px solid var(--clr-charcoal);
  border-radius: 2px;
  background: #ffffff;
  color: var(--clr-charcoal);
  transition: box-shadow 200ms ease, border-color 200ms ease;
}

.order-form-input:focus, .order-form-textarea:focus {
  outline: none;
  border-color: var(--clr-terracotta);
  box-shadow: 3px 3px 0px rgba(192, 72, 40, 0.25);
}

/* Address Mode Grid (2 Cara Alamat) */
.address-mode-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.75rem;
}

@media (max-width: 480px) {
  .address-mode-grid {
    grid-template-columns: 1fr;
  }
}

.address-mode-card {
  border: 2px solid var(--clr-border);
  background: #ffffff;
  padding: 0.85rem;
  border-radius: 4px;
  cursor: pointer;
  transition: all 200ms ease;
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.address-mode-card:hover {
  border-color: var(--clr-charcoal);
  background: var(--clr-bg);
}

.address-mode-card.active {
  border-color: var(--clr-terracotta);
  background: var(--clr-blush);
  box-shadow: 3px 3px 0px rgba(192, 72, 40, 0.2);
}

.address-mode-card__top {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.address-mode-card__radio {
  width: 16px;
  height: 16px;
  border-radius: 50%;
  border: 2px solid var(--clr-charcoal);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.address-mode-card.active .address-mode-card__radio {
  border-color: var(--clr-terracotta);
}

.radio-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--clr-terracotta);
}

.address-mode-card__title {
  font-family: var(--font-sans);
  font-size: 0.825rem;
  font-weight: 700;
  color: var(--clr-charcoal);
}

.address-mode-card__desc {
  font-size: 0.725rem;
  color: var(--clr-muted);
  line-height: 1.3;
}

.address-mode-card__preview {
  display: flex;
  align-items: flex-start;
  gap: 0.35rem;
  font-size: 0.725rem;
  color: var(--clr-terracotta-dark);
  font-weight: 600;
  margin-top: 0.25rem;
  line-height: 1.3;
}

.address-mode-card__preview svg {
  flex-shrink: 0;
  margin-top: 2px;
}

.address-profile-edit-box {
  margin-top: 0.25rem;
  padding: 0.5rem 0.75rem;
  background: var(--clr-bg-alt);
  border-radius: 4px;
}

.btn-text-link {
  background: none;
  border: none;
  padding: 0;
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--clr-terracotta);
  cursor: pointer;
  text-decoration: underline;
}

.address-custom-input-box {
  margin-top: 0.25rem;
}

.order-modal-footer {
  padding: 1.25rem 1.5rem;
  background: var(--clr-bg-alt);
  border-top: 1px solid var(--clr-border);
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 0.75rem;
}

/* Modal Transition */
.order-modal-fade-enter-active, .order-modal-fade-leave-active {
  transition: opacity 250ms ease;
}
.order-modal-fade-enter-from, .order-modal-fade-leave-to {
  opacity: 0;
}
</style>
