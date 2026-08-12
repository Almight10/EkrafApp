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
    // Determine author name with fallback to joined public.users table
    const ownerName =
        (row.nama_lengkap && String(row.nama_lengkap).trim()) ||
        (row.users?.nama_lengkap && String(row.users.nama_lengkap).trim()) ||
        (row.identitas?.nama_lengkap && String(row.identitas.nama_lengkap).trim()) ||
        row.namaLengkap ||
        '';

    const ownerPhone =
        row.users?.no_hp ||
        row.no_hp ||
        row.noHp ||
        row.no_wa ||
        row.identitas?.no_wa ||
        '';

    const alamatStr = (row.alamat && String(row.alamat).trim()) || (row.users?.alamat && String(row.users.alamat).trim()) || '';
    const kecamatanStr = (row.kecamatan && String(row.kecamatan).trim()) || (row.users?.kecamatan && String(row.users.kecamatan).trim()) || '';
    const kelurahanStr = (row.kelurahan && String(row.kelurahan).trim()) || (row.users?.kelurahan && String(row.users.kelurahan).trim()) || '';

    const lokasiLengkap = [alamatStr, kelurahanStr ? `Kel. ${kelurahanStr}` : '', kecamatanStr ? `Kec. ${kecamatanStr}` : '']
        .filter(Boolean)
        .join(', ') || 'Kota Probolinggo';

    // Already in nested web format
    if (row.usaha && typeof row.usaha === 'object') {
        return {
            ...row,
            usaha: {
                ...row.usaha,
                alamat: row.usaha.alamat || lokasiLengkap,
            },
            identitas: {
                ...row.identitas,
                nama_lengkap: ownerName,
                no_wa: ownerPhone,
                alamat: alamatStr,
                kecamatan: kecamatanStr,
                kelurahan: kelurahanStr,
            }
        };
    }

    // Flat format from Android — map to nested web format
    return {
        id: row.id,
        status_verifikasi: row.status || row.status_verifikasi || 'pending',
        created_at: row.created_at || row.createdAt,
        usaha: {
            nama_usaha: row.nama_usaha || row.namaUsaha || row.nama_brand || row.namaBrand || row.nama_produk_unggulan || 'Karya Ekraf',
            sub_sektor_id: normalizeSubSektor(row.sub_sektor || row.subSektor || ''),
            jenis_usaha: row.deskripsi_usaha || row.deskripsiUsaha || '',
            alamat: lokasiLengkap,
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

// Helper: Normalize sub-sektor string to URL-friendly ID
function normalizeSubSektor(sektor) {
    const map = {
        'kuliner': 'kuliner',
        'kriya': 'kriya',
        'fashion': 'fesyen',
        'fesyen': 'fesyen',
        'musik': 'musik',
        'seni pertunjukan': 'seni-pertunjukan',
        'seni rupa': 'seni-rupa',
        'desain komunikasi visual': 'dkv',
        'dkv': 'dkv',
        'desain produk': 'desain-produk',
        'desain interior': 'desain-interior',
        'arsitektur': 'arsitektur',
        'fotografi': 'fotografi',
        'aplikasi & game developer': 'aplikasi',
        'aplikasi': 'aplikasi',
        'game': 'game',
        'film, animasi & video': 'film',
        'film': 'film',
        'periklanan': 'iklan',
        'penerbitan': 'penerbitan',
        'televisi & radio': 'tv-radio',
    };
    return map[sektor?.toLowerCase()?.trim()] || sektor?.toLowerCase()?.replace(/\s+/g, '-') || 'kriya';
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

export default supabase;

