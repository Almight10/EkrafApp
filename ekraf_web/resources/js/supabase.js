import { createClient } from '@supabase/supabase-js';

// --- Supabase Client Setup ---
// Supports both:
// - Old format: VITE_SUPABASE_ANON_KEY (JWT eyJ...)
// - New format: VITE_SUPABASE_PUBLISHABLE_KEY (sb_publishable_...)
const supabaseUrl =
    import.meta.env.VITE_SUPABASE_URL ||
    window.supabaseConfig?.url ||
    'https://fuiruqmhcbyajuovkxci.supabase.co';

const supabaseKey =
    import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY ||
    import.meta.env.VITE_SUPABASE_ANON_KEY ||
    window.supabaseConfig?.key ||
    '';

export const isSupabaseConfigured = Boolean(
    supabaseUrl &&
    supabaseKey &&
    supabaseKey.length > 20 &&
    !supabaseKey.includes('YOUR_') &&
    !supabaseKey.includes('placeholder')
);

export const supabase = createClient(
    supabaseUrl,
    supabaseKey || 'placeholder_key_not_configured'
);

/**
 * Helper to check if a row is approved/verified by Admin.
 * Only verified/ACC items should appear in public catalogs.
 */
export function isApprovedEkrafData(row) {
    if (!row) return false;

    // 1. If row is demo/dummy item (id starts with 'demo-')
    if (typeof row.id === 'string' && row.id.startsWith('demo-')) {
        return true;
    }

    // 2. Check verified_at timestamp column (from Supabase DB row or _raw)
    const verifiedAt = row.verified_at ?? row._raw?.verified_at;
    if (verifiedAt !== null && verifiedAt !== undefined && String(verifiedAt).trim() !== '' && String(verifiedAt) !== 'null') {
        return true;
    }

    // 3. Check status string values (must be explicitly verified/approved)
    const st = String(row.status || row.status_verifikasi || row._raw?.status || row._raw?.status_verifikasi || '').toLowerCase().trim();
    if (st === 'verified' || st === 'disetujui' || st === 'approved' || st === 'acc') {
        return true;
    }

    // 4. Otherwise, item is unverified / pending -> return false
    return false;
}

/**
 * Normalize data from Supabase — handles both:
 * 1. Android-submitted flat format: { nama_usaha, sub_sektor, nomor_haki, ... }
 * 2. Web nested format: { usaha: {...}, legalitas: {...}, ... }
 */

export function normalizeEkrafData(row) {
    if (!row) return {};

    // Support row.users being an Object OR an Array (PostgREST join variations)
    const userObj = Array.isArray(row.users) ? row.users[0] : row.users;
    const rawData = row._raw || row;
    const userRawObj = Array.isArray(rawData?.users) ? rawData.users[0] : rawData?.users;

    const usersData = userObj || userRawObj || {};

    // Determine author name with fallback to joined public.users table or row fields
    const ownerName =
        (row.nama_lengkap && String(row.nama_lengkap).trim()) ||
        (usersData.nama_lengkap && String(usersData.nama_lengkap).trim()) ||
        (usersData.nama && String(usersData.nama).trim()) ||
        (usersData.full_name && String(usersData.full_name).trim()) ||
        (usersData.name && String(usersData.name).trim()) ||
        (row.identitas?.nama_lengkap && String(row.identitas.nama_lengkap).trim()) ||
        row.namaLengkap ||
        '';

    const ownerPhone =
        usersData.no_hp ||
        usersData.no_wa ||
        usersData.phone ||
        row.no_hp ||
        row.noHp ||
        row.no_wa ||
        row.identitas?.no_wa ||
        '';

    const ownerPhoto =
        (usersData.foto_url && String(usersData.foto_url).trim()) ||
        (row.identitas?.foto_url && String(row.identitas.foto_url).trim()) ||
        '';

    // Alamat Usaha (prioritas) dan Alamat Domisili Pemilik (fallback)
    const alamatUsahaStr = (row.alamat_usaha && String(row.alamat_usaha).trim()) || (row.usaha?.alamat && String(row.usaha.alamat).trim()) || '';
    const kecamatanUsahaStr = (row.kecamatan_usaha && String(row.kecamatan_usaha).trim()) || '';
    const kelurahanUsahaStr = (row.kelurahan_usaha && String(row.kelurahan_usaha).trim()) || '';

    const alamatStr = (row.alamat && String(row.alamat).trim()) || (usersData.alamat && String(usersData.alamat).trim()) || (row.users?.alamat && String(row.users.alamat).trim()) || '';
    const kecamatanStr = (row.kecamatan && String(row.kecamatan).trim()) || (usersData.kecamatan && String(usersData.kecamatan).trim()) || (row.users?.kecamatan && String(row.users.kecamatan).trim()) || '';
    const kelurahanStr = (row.kelurahan && String(row.kelurahan).trim()) || (usersData.kelurahan && String(usersData.kelurahan).trim()) || (row.users?.kelurahan && String(row.users.kelurahan).trim()) || '';

    const effectiveAlamat = alamatUsahaStr || alamatStr;
    const effectiveKelurahan = kelurahanUsahaStr || kelurahanStr;
    const effectiveKecamatan = kecamatanUsahaStr || kecamatanStr;

    const lokasiLengkap = [effectiveAlamat, effectiveKelurahan ? `Kel. ${effectiveKelurahan}` : '', effectiveKecamatan ? `Kec. ${effectiveKecamatan}` : '']
        .filter(Boolean)
        .join(', ') || 'Kota Probolinggo';

    // Already in nested web format
    if (row.usaha && typeof row.usaha === 'object') {
        const currentAlamat = row.usaha.alamat && row.usaha.alamat !== 'Kota Probolinggo' ? row.usaha.alamat : lokasiLengkap;
        return {
            ...row,
            user_id: row.user_id || row.userId || '',
            usaha: {
                ...row.usaha,
                alamat: currentAlamat,
                alamat_usaha: alamatUsahaStr || alamatStr,
                kecamatan_usaha: kecamatanUsahaStr || kecamatanStr,
                kelurahan_usaha: kelurahanUsahaStr || kelurahanStr,
                maps_url: row.maps_url || row.usaha.maps_url || '',
            },
            identitas: {
                ...row.identitas,
                nama_lengkap: ownerName || row.identitas?.nama_lengkap || '',
                no_wa: ownerPhone || row.identitas?.no_wa || '',
                foto_url: ownerPhoto || row.identitas?.foto_url || '',
                alamat: alamatStr || row.identitas?.alamat || '',
                kecamatan: kecamatanStr || row.identitas?.kecamatan || '',
                kelurahan: kelurahanStr || row.identitas?.kelurahan || '',
            }
        };
    }

    // Flat format from Android — map to nested web format
    return {
        id: row.id,
        user_id: row.user_id || row.userId || '',
        status_verifikasi: row.status || row.status_verifikasi || 'pending',
        created_at: row.created_at || row.createdAt,
        usaha: {
            nama_usaha: row.nama_usaha || row.namaUsaha || row.nama_brand || row.namaBrand || row.nama_produk_unggulan || 'Karya Ekraf',
            sub_sektor_id: normalizeSubSektor(row.sub_sektor || row.subSektor || ''),
            jenis_usaha: row.deskripsi_usaha || row.deskripsiUsaha || '',
            alamat: lokasiLengkap,
            alamat_usaha: alamatUsahaStr || alamatStr,
            kecamatan_usaha: kecamatanUsahaStr || kecamatanStr,
            kelurahan_usaha: kelurahanUsahaStr || kelurahanStr,
            maps_url: row.maps_url || '',
        },
        produk: {
            harga: parseHarga(row.harga_produk || row.hargaProduk || '0'),
            deskripsi_produk: row.deskripsi_usaha || row.deskripsiUsaha || '',
            foto_produk_urls: parseFotoUrls(row.product_image_paths || row.productImagePaths || row.foto_urls || []),
            link_marketplace: row.link_marketplace || '',
        },
        legalitas: {
            no_sertifikat_haki: row.nomor_haki || row.nomorHaki || row.no_sertifikat_haki || '',
        },
        identitas: {
            nama_lengkap: ownerName,
            no_wa: ownerPhone,
            foto_url: ownerPhoto,
            alamat: alamatStr,
            kecamatan: kecamatanStr,
            kelurahan: kelurahanStr,
        },
        meta: {
            member_since: row.tahun_berdiri || row.tahunBerdiri || new Date(row.created_at || Date.now()).getFullYear().toString(),
            status: row.status || 'pending',
        },
        // Preserve original raw data for reference
        _raw: row,
    };
}

// Helper: Normalize sub-sektor string to URL-friendly ID matching Android list
function normalizeSubSektor(sektor) {
    if (!sektor) return 'kriya';
    const s = String(sektor).toLowerCase().trim();
    const map = {
        'aplikasi & game developer': 'aplikasi-game',
        'aplikasi game developer': 'aplikasi-game',
        'aplikasi': 'aplikasi-game',
        'game': 'aplikasi-game',
        'arsitektur': 'arsitektur',
        'desain interior': 'desain-interior',
        'desain komunikasi visual': 'dkv',
        'desain komunikasi visual (dkv)': 'dkv',
        'dkv': 'dkv',
        'desain produk': 'desain-produk',
        'fashion': 'fesyen',
        'fesyen': 'fesyen',
        'film, animasi & video': 'film',
        'film animasi & video': 'film',
        'film': 'film',
        'animasi': 'film',
        'video': 'film',
        'fotografi': 'fotografi',
        'kriya': 'kriya',
        'kuliner': 'kuliner',
        'musik': 'musik',
        'penerbitan': 'penerbitan',
        'periklanan': 'periklanan',
        'iklan': 'periklanan',
        'seni pertunjukan': 'seni-pertunjukan',
        'seni rupa': 'seni-rupa',
        'televisi & radio': 'tv-radio',
        'tv & radio': 'tv-radio',
        'tv-radio': 'tv-radio',
        'lainnya': 'lainnya',
    };
    return map[s] || s.replace(/\s+/g, '-') || 'kriya';
}

// Helper: Parse harga string "Rp 250.000" or number → integer
function parseHarga(val) {
    if (typeof val === 'number') return val;
    if (!val) return 0;
    const str = String(val).replace(/[^0-9]/g, '');
    return parseInt(str) || 0;
}

// Helper: Parse foto URLs — could be JSON string, array, or comma-separated
function parseFotoUrls(val) {
    if (Array.isArray(val)) return val.filter(Boolean);
    if (typeof val === 'string') {
        try {
            const parsed = JSON.parse(val);
            if (Array.isArray(parsed)) return parsed.filter(Boolean);
        } catch {
            // comma-separated fallback
            return val.split(',').map(s => s.trim()).filter(Boolean);
        }
    }
    return [];
}

/**
 * Resolve profile photo URL from Supabase Storage.
 * Needed because public web clients cannot read users.foto_url (RLS).
 */
export async function resolveProfilePhotoUrl(userId) {
    if (!userId || !isSupabaseConfigured) return '';

    try {
        const { data, error } = await supabase.storage
            .from('profiles')
            .list('foto_diri', {
                search: String(userId),
                limit: 5,
                sortBy: { column: 'created_at', order: 'desc' },
            });

        if (error || !data?.length) return '';

        const file = data.find((item) => item.name.startsWith(`${userId}_`)) || data[0];
        if (!file?.name) return '';

        const { data: urlData } = supabase.storage
            .from('profiles')
            .getPublicUrl(`foto_diri/${file.name}`);

        return urlData?.publicUrl || '';
    } catch {
        return '';
    }
}

export async function enrichOwnerProfilePhoto(item) {
    if (!item) return item;

    let updatedItem = { ...item };
    const userId = item.user_id || item._raw?.user_id;

    // Check if owner name or address is missing/default
    const nameMissing = !updatedItem.identitas?.nama_lengkap || updatedItem.identitas.nama_lengkap === 'Pelaku Ekraf';
    const addressMissing = !updatedItem.identitas?.alamat || updatedItem.usaha?.alamat === 'Kota Probolinggo';

    if (userId && isSupabaseConfigured && (nameMissing || addressMissing)) {
        try {
            const { data: uData } = await supabase
                .from('users')
                .select('nama_lengkap, no_hp, alamat, kecamatan, kelurahan, foto_url')
                .eq('id', userId)
                .maybeSingle();

            if (uData) {
                const name = uData.nama_lengkap || uData.nama || uData.full_name || '';
                const phone = uData.no_hp || uData.no_wa || '';
                const photo = uData.foto_url || '';
                const alamatStr = uData.alamat || '';
                const kecStr = uData.kecamatan || '';
                const kelStr = uData.kelurahan || '';

                const lokasiLengkap = [alamatStr, kelStr ? `Kel. ${kelStr}` : '', kecStr ? `Kec. ${kecStr}` : '']
                    .filter(Boolean)
                    .join(', ');

                updatedItem = {
                    ...updatedItem,
                    usaha: {
                        ...updatedItem.usaha,
                        alamat: (lokasiLengkap || updatedItem.usaha?.alamat) || 'Kota Probolinggo',
                    },
                    identitas: {
                        ...updatedItem.identitas,
                        nama_lengkap: name || updatedItem.identitas?.nama_lengkap || 'Pelaku Ekraf',
                        no_wa: phone || updatedItem.identitas?.no_wa || '',
                        foto_url: photo || updatedItem.identitas?.foto_url || '',
                        alamat: alamatStr || updatedItem.identitas?.alamat || '',
                        kecamatan: kecStr || updatedItem.identitas?.kecamatan || '',
                        kelurahan: kelStr || updatedItem.identitas?.kelurahan || '',
                    }
                };
            }
        } catch (e) {
            console.warn('[Ekraf] Notice fetching user profile fallback:', e);
        }
    }

    if (!updatedItem.identitas?.foto_url && userId) {
        const fotoUrl = await resolveProfilePhotoUrl(userId);
        if (fotoUrl) {
            updatedItem = {
                ...updatedItem,
                identitas: {
                    ...updatedItem.identitas,
                    foto_url: fotoUrl,
                },
            };
        }
    }

    return updatedItem;
}

export default supabase;

