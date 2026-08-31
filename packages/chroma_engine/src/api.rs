use crate::colorimetry::ciede2000;
use crate::mix::{MixComponent, MixedColor, Mixer};
use crate::pigment::{Pigment, PigmentDatabase};
use crate::units::{format_ratios, QuantityUnit};
use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::slice;

static mut ENGINE: Option<EngineState> = None;

struct EngineState {
    mixer: Mixer,
}

fn engine() -> &'static mut EngineState {
    unsafe {
        if ENGINE.is_none() {
            let json = include_str!("../../../data/pigments/all_pigments.json");
            let db = PigmentDatabase::load_from_json(json).expect("Failed to load pigments");
            ENGINE = Some(EngineState {
                mixer: Mixer::new(db),
            });
        }
        ENGINE.as_mut().unwrap()
    }
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
}

fn to_c_string(s: &str) -> *mut c_char {
    CString::new(s).unwrap().into_raw()
}

#[no_mangle]
pub extern "C" fn chroma_init() -> u32 {
    engine().mixer.database().count() as u32
}

#[no_mangle]
pub extern "C" fn chroma_pigment_count() -> u32 {
    engine().mixer.database().count() as u32
}

#[no_mangle]
pub extern "C" fn chroma_get_pigment(index: u32, out: *mut CPigmentInfo) -> i32 {
    if out.is_null() {
        return -1;
    }
    let pigments = engine().mixer.database().all();
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
    if pigment_ids.is_null() || weights.is_null() || out.is_null() || count == 0 {
        return -1;
    }

    let mut components = Vec::with_capacity(count as usize);
    unsafe {
        let ids = slice::from_raw_parts(pigment_ids, count as usize);
        let wts = slice::from_raw_parts(weights, count as usize);
        for i in 0..count as usize {
            let id = CStr::from_ptr(ids[i]).to_string_lossy().into_owned();
            components.push(MixComponent {
                pigment_id: id,
                weight: wts[i],
            });
        }
    }

    match engine().mixer.mix_weighted(&components) {
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
    engine()
        .mixer
        .database()
        .all()
        .into_iter()
        .map(PigmentInfo::from)
        .collect()
}

pub fn mix_paints(components: Vec<MixComponent>) -> Result<MixedColor, String> {
    engine()
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
