use crate::colorimetry::{spectrum_to_lab, spectrum_to_srgb, SPECTRUM_SAMPLES};

#[derive(Debug, Clone, Copy)]
pub enum DryingTime {
    OneDay,
    OneWeek,
    OneMonth,
}

/// Phase 2 stub: simulate drying shift by darkening and slight yellowing.
pub fn apply_drying_shift(
    reflectance: &[f64; SPECTRUM_SAMPLES],
    binder: &str,
    time: DryingTime,
) -> [f64; SPECTRUM_SAMPLES] {
    let factor = match time {
        DryingTime::OneDay => 0.02,
        DryingTime::OneWeek => 0.05,
        DryingTime::OneMonth => 0.08,
    };

    let yellow_shift = if binder == "oil" { factor * 0.5 } else { 0.0 };

    let mut dried = *reflectance;
    for (i, r) in dried.iter_mut().enumerate() {
        let wl = 380.0 + i as f64 * 10.0;
        let darken = 1.0 - factor;
        let yellow_boost = if wl > 550.0 && wl < 650.0 {
            1.0 + yellow_shift
        } else {
            1.0
        };
        *r = (*r * darken * yellow_boost).clamp(0.0, 1.0);
    }
    dried
}

pub fn dried_srgb(
    reflectance: &[f64; SPECTRUM_SAMPLES],
    binder: &str,
    time: DryingTime,
) -> (f64, f64, f64) {
    let dried = apply_drying_shift(reflectance, binder, time);
    spectrum_to_srgb(&dried)
}

pub fn dried_lab(
    reflectance: &[f64; SPECTRUM_SAMPLES],
    binder: &str,
    time: DryingTime,
) -> (f64, f64, f64) {
    let dried = apply_drying_shift(reflectance, binder, time);
    spectrum_to_lab(&dried)
}
