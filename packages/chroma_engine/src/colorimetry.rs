pub const SPECTRUM_SAMPLES: usize = 41;
pub const WAVELENGTH_MIN: f64 = 380.0;
pub const WAVELENGTH_MAX: f64 = 780.0;
pub const WAVELENGTH_STEP: f64 =
    (WAVELENGTH_MAX - WAVELENGTH_MIN) / (SPECTRUM_SAMPLES - 1) as f64;

fn cmf_x(wl: f64) -> f64 {
    match wl as u32 {
        380..=439 => 0.001368 * (wl - 380.0) / 60.0,
        440..=489 => 0.0143 + 0.0956 * (wl - 440.0) / 50.0,
        490..=519 => 0.13438 + 0.2146 * (wl - 490.0) / 30.0,
        520..=559 => 0.34828 + 0.0601 * (wl - 520.0) / 40.0,
        560..=589 => 0.40826 - 0.0401 * (wl - 560.0) / 30.0,
        590..=639 => 0.36826 - 0.2000 * (wl - 590.0) / 50.0,
        640..=780 => 0.16826 - 0.16826 * (wl - 640.0) / 140.0,
        _ => 0.0,
    }
}

fn cmf_y(wl: f64) -> f64 {
    match wl as u32 {
        380..=439 => 0.000039 * (wl - 380.0) / 60.0,
        440..=489 => 0.0040 + 0.3960 * (wl - 440.0) / 50.0,
        490..=519 => 0.4 + 0.4 * (wl - 490.0) / 30.0,
        520..=559 => 0.8 - 0.2 * (wl - 520.0) / 40.0,
        560..=589 => 0.6 - 0.1 * (wl - 560.0) / 30.0,
        590..=639 => 0.5 - 0.3 * (wl - 590.0) / 50.0,
        640..=780 => 0.2 - 0.2 * (wl - 640.0) / 140.0,
        _ => 0.0,
    }
}

fn cmf_z(wl: f64) -> f64 {
    match wl as u32 {
        380..=439 => 0.006450 * (wl - 380.0) / 60.0,
        440..=489 => 0.0645 + 0.3040 * (wl - 440.0) / 50.0,
        490..=519 => 0.3686 + 0.0314 * (wl - 490.0) / 30.0,
        520..=559 => 0.4 - 0.1 * (wl - 520.0) / 40.0,
        560..=589 => 0.3 - 0.15 * (wl - 560.0) / 30.0,
        590..=639 => 0.15 - 0.1 * (wl - 590.0) / 50.0,
        640..=780 => 0.05 - 0.05 * (wl - 640.0) / 140.0,
        _ => 0.0,
    }
}

fn illuminant_d65(wl: f64) -> f64 {
    if wl < 500.0 {
        0.5 + 0.5 * (wl - 380.0) / 120.0
    } else if wl < 600.0 {
        1.0
    } else {
        1.0 - 0.5 * (wl - 600.0) / 180.0
    }
}

pub fn wavelength_at(index: usize) -> f64 {
    WAVELENGTH_MIN + index as f64 * WAVELENGTH_STEP
}

pub fn reflectance_to_ks(r: f64) -> f64 {
    let r = r.clamp(0.001, 0.999);
    let term = 1.0 - r;
    (term * term) / (2.0 * r)
}

pub fn ks_to_reflectance(ks: f64) -> f64 {
    let ks = ks.max(0.0);
    1.0 + ks - ((ks * ks + 2.0 * ks).sqrt())
}

pub fn spectrum_to_xyz(reflectance: &[f64; SPECTRUM_SAMPLES]) -> (f64, f64, f64) {
    let mut x = 0.0;
    let mut y = 0.0;
    let mut z = 0.0;
    let mut y_norm = 0.0;

    for (i, &r) in reflectance.iter().enumerate() {
        let wl = wavelength_at(i);
        let illum = illuminant_d65(wl);
        let r_clamped = r.clamp(0.0, 1.0);
        x += r_clamped * cmf_x(wl) * illum;
        y += r_clamped * cmf_y(wl) * illum;
        z += r_clamped * cmf_z(wl) * illum;
        y_norm += cmf_y(wl) * illum;
    }

    if y_norm > 0.0 {
        (x / y_norm * 100.0, y / y_norm * 100.0, z / y_norm * 100.0)
    } else {
        (0.0, 0.0, 0.0)
    }
}

pub fn xyz_to_lab(x: f64, y: f64, z: f64) -> (f64, f64, f64) {
    fn f(t: f64) -> f64 {
        if t > 0.008856 {
            t.powf(1.0 / 3.0)
        } else {
            (903.3 * t + 16.0) / 116.0
        }
    }

    let xn = 95.047;
    let yn = 100.0;
    let zn = 108.883;

    let l = 116.0 * f(y / yn) - 16.0;
    let a = 500.0 * (f(x / xn) - f(y / yn));
    let b = 200.0 * (f(y / yn) - f(z / zn));
    (l, a, b)
}

pub fn spectrum_to_lab(reflectance: &[f64; SPECTRUM_SAMPLES]) -> (f64, f64, f64) {
    let (x, y, z) = spectrum_to_xyz(reflectance);
    xyz_to_lab(x, y, z)
}

pub fn spectrum_to_srgb(reflectance: &[f64; SPECTRUM_SAMPLES]) -> (f64, f64, f64) {
    let (x, y, z) = spectrum_to_xyz(reflectance);
    xyz_to_srgb(x, y, z)
}

pub fn xyz_to_srgb(x: f64, y: f64, z: f64) -> (f64, f64, f64) {
    let x = x / 100.0;
    let y = y / 100.0;
    let z = z / 100.0;

    let r = x * 3.2406 + y * -1.5372 + z * -0.4986;
    let g = x * -0.9689 + y * 1.8758 + z * 0.0415;
    let b = x * 0.0557 + y * -0.2040 + z * 1.0570;

    fn gamma_correct(c: f64) -> f64 {
        if c <= 0.0031308 {
            12.92 * c
        } else {
            1.055 * c.powf(1.0 / 2.4) - 0.055
        }
    }

    (
        gamma_correct(r).clamp(0.0, 1.0),
        gamma_correct(g).clamp(0.0, 1.0),
        gamma_correct(b).clamp(0.0, 1.0),
    )
}

pub fn mix_spectra_ks(
    a: &[f64; SPECTRUM_SAMPLES],
    b: &[f64; SPECTRUM_SAMPLES],
    t: f64,
) -> [f64; SPECTRUM_SAMPLES] {
    let t = t.clamp(0.0, 1.0);
    let mut result = [0.0; SPECTRUM_SAMPLES];
    for i in 0..SPECTRUM_SAMPLES {
        let ks_a = reflectance_to_ks(a[i]);
        let ks_b = reflectance_to_ks(b[i]);
        let ks_mixed = ks_a * (1.0 - t) + ks_b * t;
        result[i] = ks_to_reflectance(ks_mixed);
    }
    result
}

/// CIEDE2000 color difference.
pub fn ciede2000(lab1: (f64, f64, f64), lab2: (f64, f64, f64)) -> f64 {
    let (l1, a1, b1) = lab1;
    let (l2, a2, b2) = lab2;

    let c1 = (a1 * a1 + b1 * b1).sqrt();
    let c2 = (a2 * a2 + b2 * b2).sqrt();
    let c_bar = (c1 + c2) / 2.0;

    let g = 0.5 * (1.0 - (c_bar.powi(7) / (c_bar.powi(7) + 25.0_f64.powi(7))).sqrt());

    let a1p = a1 * (1.0 + g);
    let a2p = a2 * (1.0 + g);
    let c1p = (a1p * a1p + b1 * b1).sqrt();
    let c2p = (a2p * a2p + b2 * b2).sqrt();

    let h1p = b1.atan2(a1p).to_degrees().rem_euclid(360.0);
    let h2p = b2.atan2(a2p).to_degrees().rem_euclid(360.0);

    let dl = l2 - l1;
    let dc = c2p - c1p;

    let dh = if (c1p * c2p).abs() < 1e-10 {
        0.0
    } else if (h2p - h1p).abs() <= 180.0 {
        h2p - h1p
    } else if h2p <= h1p {
        h2p - h1p + 360.0
    } else {
        h2p - h1p - 360.0
    };
    let dh = 2.0 * (c1p * c2p).sqrt() * (dh.to_radians() / 2.0).sin();

    let l_bar = (l1 + l2) / 2.0;
    let c_barp = (c1p + c2p) / 2.0;

    let h_bar = if (c1p * c2p).abs() < 1e-10 {
        h1p + h2p
    } else if (h1p - h2p).abs() <= 180.0 {
        (h1p + h2p) / 2.0
    } else if h1p + h2p < 360.0 {
        (h1p + h2p + 360.0) / 2.0
    } else {
        (h1p + h2p - 360.0) / 2.0
    };

    let t = 1.0
        - 0.17 * ((h_bar - 30.0).to_radians()).cos()
        + 0.24 * ((2.0 * h_bar).to_radians()).cos()
        + 0.32 * ((3.0 * h_bar + 6.0).to_radians()).cos()
        - 0.20 * ((4.0 * h_bar - 63.0).to_radians()).cos();

    let sl = 1.0 + (0.015 * (l_bar - 50.0).powi(2)) / (20.0 + (l_bar - 50.0).powi(2)).sqrt();
    let sc = 1.0 + 0.045 * c_barp;
    let sh = 1.0 + 0.015 * c_barp * t;

    // Rotation term (Sharma 2005): only active for high-chroma blues near 275°.
    let d_theta = 30.0 * (-((h_bar - 275.0) / 25.0).powi(2)).exp();
    let rc = 2.0 * (c_barp.powi(7) / (c_barp.powi(7) + 25.0_f64.powi(7))).sqrt();
    let rt = -rc * (2.0 * d_theta).to_radians().sin();

    let kl = 1.0;
    let kc = 1.0;
    let kh = 1.0;

    let term1 = (dl / (kl * sl)).powi(2);
    let term2 = (dc / (kc * sc)).powi(2);
    let term3 = (dh / (kh * sh)).powi(2);
    let term4 = rt * (dc / (kc * sc)) * (dh / (kh * sh));

    (term1 + term2 + term3 + term4).sqrt()
}

pub fn lab_to_srgb(l: f64, a: f64, b: f64) -> (f64, f64, f64) {
    let y = (l + 16.0) / 116.0;
    let x = a / 500.0 + y;
    let z = y - b / 200.0;

    let x3 = x.powi(3);
    let y3 = y.powi(3);
    let z3 = z.powi(3);

    let x = if x3 > 0.008856 { x3 } else { (x - 16.0 / 116.0) / 7.787 };
    let y = if y3 > 0.008856 { y3 } else { (y - 16.0 / 116.0) / 7.787 };
    let z = if z3 > 0.008856 { z3 } else { (z - 16.0 / 116.0) / 7.787 };

    xyz_to_srgb(x * 95.047, y * 100.0, z * 108.883)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ciede2000_matches_sharma_2005_reference_pairs() {
        // (L1,a1,b1), (L2,a2,b2), expected dE00 — Sharma et al. (2005).
        let cases = [
            ((50.0, 2.6772, -79.7751), (50.0, 0.0, -82.7485), 2.0425),
            ((50.0, 3.1571, -77.2803), (50.0, 0.0, -82.7485), 2.8615),
            ((50.0, 2.8361, -74.0200), (50.0, 0.0, -82.7485), 3.4412),
            ((50.0, -1.3802, -84.2814), (50.0, 0.0, -82.7485), 1.0000),
            ((50.0, -1.1848, -84.8006), (50.0, 0.0, -82.7485), 1.0000),
            ((50.0, -0.9009, -85.5211), (50.0, 0.0, -82.7485), 1.0000),
            ((50.0, 0.0, 0.0), (50.0, -1.0, 2.0), 2.3669),
        ];
        for (lab1, lab2, expected) in cases {
            let de = ciede2000(lab1, lab2);
            assert!(
                (de - expected).abs() < 0.0001,
                "pair {lab1:?} vs {lab2:?}: got {de}, expected {expected}"
            );
        }
    }

    #[test]
    fn white_reflectance_is_high() {
        let white = [0.95; SPECTRUM_SAMPLES];
        let (l, _, _) = spectrum_to_lab(&white);
        assert!(l > 90.0);
    }

    #[test]
    fn ks_roundtrip() {
        let r = 0.5;
        let ks = reflectance_to_ks(r);
        let r2 = ks_to_reflectance(ks);
        assert!((r - r2).abs() < 0.01);
    }
}
