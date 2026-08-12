<template>
  <Teleport to="body">
    <div :class="['ekraf-preloader', { 'ekraf-preloader--hidden': !isLoading }]">
      <div class="ekraf-loader-card">
        <!-- Logo Wrapper with Orbiting Rings & Upward Liquid Aura -->
        <div class="ekraf-loader-logo-wrapper">
          <!-- Ambient Bottom-to-Top Glow Pulsar -->
          <div class="ekraf-loader-glow"></div>

          <!-- Bottom-to-Top Revealing Ekraf Probolinggo Logo SVG -->
          <div class="ekraf-logo-svg-wrap">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 300" class="ekraf-animated-logo">
              <defs>
                <linearGradient id="loaderOrangeGrad" x1="0%" y1="100%" x2="0%" y2="0%">
                  <stop offset="0%" stop-color="#E03E0B" />
                  <stop offset="100%" stop-color="#F25822" />
                </linearGradient>
                <linearGradient id="loaderPurpleGrad" x1="0%" y1="100%" x2="0%" y2="0%">
                  <stop offset="0%" stop-color="#550070" />
                  <stop offset="100%" stop-color="#7B0099" />
                </linearGradient>
                <linearGradient id="loaderMagentaGrad" x1="0%" y1="100%" x2="0%" y2="0%">
                  <stop offset="0%" stop-color="#8A00AA" />
                  <stop offset="100%" stop-color="#BC22E0" />
                </linearGradient>
                <linearGradient id="loaderLightMagentaGrad" x1="0%" y1="100%" x2="0%" y2="0%">
                  <stop offset="0%" stop-color="#A855F7" />
                  <stop offset="100%" stop-color="#D946EF" />
                </linearGradient>

                <!-- Upward Liquid Clip-Path -->
                <clipPath id="upwardClipPath">
                  <rect x="0" y="0" width="300" height="300" class="upward-clip-rect" />
                </clipPath>
              </defs>

              <g transform="translate(10, 0)" clip-path="url(#upwardClipPath)">
                <!-- Outer Orange Arc (Rises & Unfurls Upward) -->
                <path class="ekraf-svg-orange-arc"
                      d="M 205,75 C 145,55 75,95 72,160 C 69,225 125,255 170,242 C 125,248 90,215 95,160 C 100,105 155,75 205,75 Z"
                      fill="url(#loaderOrangeGrad)" />

                <!-- Inner Purple Ribbon (Unfurls Upward) -->
                <path class="ekraf-svg-purple-arc"
                      d="M 165,108 C 125,120 102,152 107,188 C 112,224 140,240 170,238 C 132,236 122,198 126,165 C 130,135 148,118 165,108 Z"
                      fill="url(#loaderPurpleGrad)" />

                <!-- Grape Cluster Bubbles (Rise Up Sequentially from Bottom) -->
                <g class="ekraf-svg-grapes">
                  <circle class="grape-bubble g1" cx="150" cy="225" r="18" fill="url(#loaderPurpleGrad)" />
                  <circle class="grape-bubble g2" cx="172" cy="232" r="19" fill="url(#loaderMagentaGrad)" />
                  <circle class="grape-bubble g3" cx="162" cy="202" r="23" fill="url(#loaderPurpleGrad)" />
                  <circle class="grape-bubble g4" cx="192" cy="216" r="18" fill="url(#loaderMagentaGrad)" />
                  <circle class="grape-bubble g5" cx="215" cy="206" r="16" fill="url(#loaderLightMagentaGrad)" />
                  <circle class="grape-bubble g6" cx="200" cy="186" r="17" fill="url(#loaderMagentaGrad)" />
                  <circle class="grape-bubble g7" cx="224" cy="184" r="14" fill="url(#loaderLightMagentaGrad)" />
                </g>
              </g>
            </svg>
          </div>
        </div>

        <!-- Typography & Brand Titles -->
        <div class="ekraf-loader-title">Ekraf</div>
        <div class="ekraf-loader-subtitle">Ekonomi Kreatif Kota Probolinggo</div>

        <!-- Upward Flowing Progress Line Bar -->
        <div class="ekraf-loader-progress-track">
          <div class="ekraf-loader-progress-bar"></div>
        </div>

        <!-- Loading Status Indicator -->
        <div class="ekraf-loader-status">
          <span>MEMUAT HALAMAN</span>
          <span class="ekraf-loader-dots">
            <span>.</span><span>.</span><span>.</span>
          </span>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import { router } from '@inertiajs/vue3';

const props = defineProps({
  initialLoadingDuration: {
    type: Number,
    default: 1000
  }
});

const isLoading = ref(true);
let removeStartListener = null;
let removeFinishListener = null;
let timeoutTimer = null;

onMounted(() => {
  // Hide initial page mount loading
  timeoutTimer = setTimeout(() => {
    isLoading.value = false;
  }, props.initialLoadingDuration);

  // Allow manually triggering animation for demo/testing
  if (typeof window !== 'undefined') {
    window.triggerEkrafLoader = (ms = 2200) => {
      isLoading.value = true;
      setTimeout(() => {
        isLoading.value = false;
      }, ms);
    };
    window.addEventListener('ekraf-show-loader', () => {
      window.triggerEkrafLoader(2200);
    });
  }

  // Listen to Inertia page transition events
  removeStartListener = router.on('start', () => {
    isLoading.value = true;
  });

  removeFinishListener = router.on('finish', () => {
    setTimeout(() => {
      isLoading.value = false;
    }, 450);
  });
});

onUnmounted(() => {
  if (timeoutTimer) clearTimeout(timeoutTimer);
  if (removeStartListener) removeStartListener();
  if (removeFinishListener) removeFinishListener();
});
</script>
