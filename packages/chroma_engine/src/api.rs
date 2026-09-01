use crate::colorimetry::{ciede2000, SPECTRUM_SAMPLES};
use crate::mix::{MixComponent, MixedColor, Mixer};
use crate::pigment::{Pigment, PigmentDatabase};
use crate::units::{format_ratios, QuantityUnit};
use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::panic::{catch_unwind, AssertUnwindSafe};
use std::slice;
use std::sync::OnceLock;

/// Maximum number of components accepted by `chroma_mix`; guards against
/// garbage `count` values from a misbehaving caller.
const MAX_MIX_COMPONENTS: u32 = 64;

static ENGINE: OnceLock<Option<EngineState>> = OnceLock::new();

struct EngineState {
    mixer: Mixer,
}

/// Returns `None` if the embedded pigment data failed to parse; FFI entry
/// points then report failure instead of panicking across the C boundary.
fn engine() -> Option<&'static EngineState> {
    ENGINE
        .get_or_init(|| {
            let json = include_str!("../../../data/pigments/all_pigments.json");
            PigmentDatabase::load_from_json(json)
                .ok()
                .map(|db| EngineState {
                    mixer: Mixer::new(db),
                })
        })
        .as_ref()
}

/// Runs `f`, converting any panic into `default` so unwinding never crosses
/// the `extern "C"` boundary (which would abort the host process).
fn ffi_guard<T>(default: T, f: impl FnOnce() -> T) -> T {
    catch_unwind(AssertUnwindSafe(f)).unwrap_or(default)
}

#[repr(C)]
pub struct CPigmentInfo {
    pub id: *mut c_char,
    pub name: *mut c_char,
    pub opacity: f64,
    pub tinting_strength: f64,
    pub lab_l: f64,
    pub lab_a: f64,
    pub lab_b: f64,
    pub srgb_r: f64,
    pub srgb_g: f64,
    pub srgb_b: f64,
}

#[repr(C)]
pub struct CMixResult {
    pub lab_l: f64,
    pub lab_a: f64,
    pub lab_b: f64,
    pub srgb_r: f64,
    pub srgb_g: f64,
    pub srgb_b: f64,
    pub mass_r: f64,
    pub mass_g: f64,
    pub mass_b: f64,
    pub undertone_r: f64,
    pub undertone_g: f64,
    pub undertone_b: f64,
    pub reflectance: [f64; SPECTRUM_SAMPLES],
}

fn to_c_string(s: &str) -> *mut c_char {
    // Interior NUL bytes cannot occur in our data; degrade to an empty string
    // rather than panicking across the FFI boundary if they ever do.
    CString::new(s)
        .unwrap_or_default()
        .into_raw()
}

#[no_mangle]
pub extern "C" fn chroma_init() -> u32 {
    ffi_guard(0, || {
        engine().map_or(0, |e| e.mixer.database().count() as u32)
    })
}

#[no_mangle]
pub extern "C" fn chroma_pigment_count() -> u32 {
    ffi_guard(0, || {
        engine().map_or(0, |e| e.mixer.database().count() as u32)
    })
}

#[no_mangle]
pub extern "C" fn chroma_get_pigment(index: u32, out: *mut CPigmentInfo) -> i32 {
    if out.is_null() {
        return -1;
    }
    ffi_guard(-1, || chroma_get_pigment_impl(index, out))
}

fn chroma_get_pigment_impl(index: u32, out: *mut CPigmentInfo) -> i32 {
    let Some(state) = engine() else { return -1 };
    let pigments = state.mixer.database().all();
    if index as usize >= pigments.len() {
        return -1;
    }
    let p = pigments[index as usize];
    unsafe {
        (*out).id = to_c_string(&p.id);
        (*out).name = to_c_string(&p.name);
        (*out).opacity = p.opacity;
        (*out).tinting_strength = p.tinting_strength;
        (*out).lab_l = p.lab.0;
        (*out).lab_a = p.lab.1;
        (*out).lab_b = p.lab.2;
        (*out).srgb_r = p.srgb.0;
        (*out).srgb_g = p.srgb.1;
        (*out).srgb_b = p.srgb.2;
    }
    0
}

#[no_mangle]
pub extern "C" fn chroma_get_pigment_reflectance(
    index: u32,
    out: *mut f64,
    count: u32,
) -> i32 {
    if out.is_null() || count as usize != SPECTRUM_SAMPLES {
        return -1;
    }
    ffi_guard(-1, || {
        let Some(state) = engine() else { return -1 };
        let pigments = state.mixer.database().all();
        if index as usize >= pigments.len() {
            return -1;
        }
        let p = pigments[index as usize];
        unsafe {
            std::ptr::copy_nonoverlapping(p.reflectance.as_ptr(), out, SPECTRUM_SAMPLES);
        }
        0
    })
}

#[no_mangle]
pub extern "C" fn chroma_free_string(s: *mut c_char) {
    if !s.is_null() {
        unsafe {
            let _ = CString::from_raw(s);
        }
    }
}

#[no_mangle]
pub extern "C" fn chroma_mix(
    pigment_ids: *const *const c_char,
    weights: *const f64,
    count: u32,
    out: *mut CMixResult,
) -> i32 {
    if pigment_ids.is_null()
        || weights.is_null()
        || out.is_null()
        || count == 0
        || count > MAX_MIX_COMPONENTS
    {
        return -1;
    }
    ffi_guard(-1, || chroma_mix_impl(pigment_ids, weights, count, out))
}

fn chroma_mix_impl(
    pigment_ids: *const *const c_char,
    weights: *const f64,
    count: u32,
    out: *mut CMixResult,
) -> i32 {
    let Some(state) = engine() else { return -1 };

    let mut components = Vec::with_capacity(count as usize);
    unsafe {
        let ids = slice::from_raw_parts(pigment_ids, count as usize);
        let wts = slice::from_raw_parts(weights, count as usize);
        for i in 0..count as usize {
            if ids[i].is_null() {
                return -1;
            }
            let id = CStr::from_ptr(ids[i]).to_string_lossy().into_owned();
            components.push(MixComponent {
                pigment_id: id,
                weight: wts[i],
            });
        }
    }

    match state.mixer.mix_weighted(&components) {
        Ok(result) => {
            unsafe {
                *out = CMixResult {
                    lab_l: result.lab.0,
                    lab_a: result.lab.1,
                    lab_b: result.lab.2,
                    srgb_r: result.srgb.0,
                    srgb_g: result.srgb.1,
                    srgb_b: result.srgb.2,
                    mass_r: result.mass_tone.0,
                    mass_g: result.mass_tone.1,
                    mass_b: result.mass_tone.2,
                    undertone_r: result.undertone.0,
                    undertone_g: result.undertone.1,
                    undertone_b: result.undertone.2,
                    reflectance: result.reflectance,
                };
            }
            0
        }
        Err(_) => -1,
    }
}

#[no_mangle]
pub extern "C" fn chroma_color_difference(
    l1: f64,
    a1: f64,
    b1: f64,
    l2: f64,
    a2: f64,
    b2: f64,
) -> f64 {
    ciede2000((l1, a1, b1), (l2, a2, b2))
}

// Re-export types for Rust consumers
pub struct PigmentInfo {
    pub id: String,
    pub name: String,
    pub pigment_codes: Vec<String>,
    pub opacity: f64,
    pub tinting_strength: f64,
    pub toxicity: String,
    pub binder: String,
    pub lab_l: f64,
    pub lab_a: f64,
    pub lab_b: f64,
    pub srgb_r: f64,
    pub srgb_g: f64,
    pub srgb_b: f64,
}

impl From<&Pigment> for PigmentInfo {
    fn from(p: &Pigment) -> Self {
        Self {
            id: p.id.clone(),
            name: p.name.clone(),
            pigment_codes: p.pigment_codes.clone(),
            opacity: p.opacity,
            tinting_strength: p.tinting_strength,
            toxicity: p.toxicity.clone(),
            binder: p.binder.clone(),
            lab_l: p.lab.0,
            lab_a: p.lab.1,
            lab_b: p.lab.2,
            srgb_r: p.srgb.0,
            srgb_g: p.srgb.1,
            srgb_b: p.srgb.2,
        }
    }
}

pub fn list_pigments() -> Vec<PigmentInfo> {
    engine().map_or_else(Vec::new, |e| {
        e.mixer
            .database()
            .all()
            .into_iter()
            .map(PigmentInfo::from)
            .collect()
    })
}

pub fn mix_paints(components: Vec<MixComponent>) -> Result<MixedColor, String> {
    let state = engine().ok_or_else(|| "pigment data unavailable".to_string())?;
    state
        .mixer
        .mix_weighted(&components)
        .map_err(|e| e.to_string())
}

pub fn format_mix_ratios(weights: &[f64], unit: QuantityUnit) -> Vec<(String, String, String)> {
    format_ratios(weights, unit, 1.15)
        .into_iter()
        .map(|r| (r.parts, r.percent, r.grams))
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn engine_initializes_once() {
        let a = chroma_init();
        let b = chroma_init();
        assert_eq!(a, b);
        assert!(a > 0, "engine should load at least one pigment");
    }

    #[test]
    fn mix_rejects_oversized_count() {
        let mut out = std::mem::MaybeUninit::<CMixResult>::uninit();
        let rc = chroma_mix(
            std::ptr::NonNull::dangling().as_ptr(),
            std::ptr::NonNull::dangling().as_ptr(),
            MAX_MIX_COMPONENTS + 1,
            out.as_mut_ptr(),
        );
        assert_eq!(rc, -1);
    }
}
