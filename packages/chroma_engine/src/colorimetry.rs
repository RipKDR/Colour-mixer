pub const SPECTRUM_SAMPLES: usize = 41;
pub const WAVELENGTH_MIN: f64 = 380.0;
pub const WAVELENGTH_MAX: f64 = 780.0;
pub const WAVELENGTH_STEP: f64 =
    (WAVELENGTH_MAX - WAVELENGTH_MIN) / (SPECTRUM_SAMPLES - 1) as f64;

/// CIE 1931 2-degree standard observer x-bar, 380-780 nm at 10 nm.
const CMF_X: [f64; SPECTRUM_SAMPLES] = [
    0.001368, 0.004243, 0.014310, 0.043510, 0.134380, 0.283900, 0.348280,
    0.336200, 0.290800, 0.195360, 0.095640, 0.032010, 0.004900, 0.009300,
    0.063270, 0.165500, 0.290400, 0.433450, 0.594500, 0.762100, 0.916300,
    1.026300, 1.062200, 1.002600, 0.854450, 0.642400, 0.447900, 0.283500,
    0.164900, 0.087400, 0.046770, 0.022700, 0.011359, 0.005790, 0.002899,
    0.001440, 0.000690, 0.000332, 0.000166, 0.000083, 0.000042,
];

/// CIE 1931 2-degree standard observer y-bar.
const CMF_Y: [f64; SPECTRUM_SAMPLES] = [
    0.000039, 0.000120, 0.000396, 0.001210, 0.004000, 0.011600, 0.023000,
    0.038000, 0.060000, 0.090980, 0.139020, 0.208020, 0.323000, 0.503000,
    0.710000, 0.862000, 0.954000, 0.994950, 0.995000, 0.952000, 0.870000,
    0.757000, 0.631000, 0.503000, 0.381000, 0.265000, 0.175000, 0.107000,
    0.061000, 0.032000, 0.017000, 0.008210, 0.004102, 0.002091, 0.001047,
    0.000520, 0.000249, 0.000120, 0.000060, 0.000030, 0.000015,
];

/// CIE 1931 2-degree standard observer z-bar.
const CMF_Z: [f64; SPECTRUM_SAMPLES] = [
    0.006450, 0.020050, 0.067850, 0.207400, 0.645600, 1.385600, 1.747060,
    1.772110, 1.669200, 1.287640, 0.812950, 0.465180, 0.272000, 0.158200,
    0.078250, 0.042160, 0.020300, 0.008750, 0.003900, 0.002100, 0.001650,
    0.001100, 0.000800, 0.000340, 0.000190, 0.000050, 0.000020, 0.000000,
    0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
    0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
];

/// CIE Standard Illuminant D65 relative SPD, same sampling.
const D65_SPD: [f64; SPECTRUM_SAMPLES] = [
    49.9755, 54.6482, 82.7549, 91.4860, 93.4318, 86.6823, 104.8650,
    117.0080, 117.8120, 114.8610, 115.9230, 108.8110, 109.3540, 107.8020,
    104.7900, 107.6890, 104.4050, 104.0460, 100.0000, 96.3342, 95.7880,
    88.6856, 90.0062, 89.5991, 87.6987, 83.2886, 83.6992, 80.0268,
    80.2146, 82.2778, 78.2842, 69.7213, 71.6091, 74.3490, 61.6040,
    69.8856, 75.0870, 63.5927, 46.4182, 66.8054, 63.3828,
];

/// D65 white point computed from the tables above, so a perfect reflector
/// maps exactly to Lab (100, 0, 0). The 10 nm sampling gives values a hair
/// off the 1 nm standard (95.047, 100, 108.883).
fn d65_white() -> (f64, f64, f64) {
    static WHITE: std::sync::OnceLock<(f64, f64, f64)> = std::sync::OnceLock::new();
    *WHITE.get_or_init(|| {
        let ones = [1.0; SPECTRUM_SAMPLES];
        spectrum_to_xyz(&ones)
    })
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
        let illum = D65_SPD[i];
        let r_clamped = r.clamp(0.0, 1.0);
        x += r_clamped * CMF_X[i] * illum;
        y += r_clamped * CMF_Y[i] * illum;
        z += r_clamped * CMF_Z[i] * illum;
        y_norm += CMF_Y[i] * illum;
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

    let (xn, yn, zn) = d65_white();

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

    let (xn, yn, zn) = d65_white();
    xyz_to_srgb(x * xn, y * yn, z * zn)
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
    fn perfect_white_reproduces_d65_white_point() {
        let white = [1.0; SPECTRUM_SAMPLES];
        let (x, y, z) = spectrum_to_xyz(&white);
        // 10 nm sampling leaves small residuals vs the 1 nm standard values.
        assert!((x - 95.047).abs() < 0.3, "X = {x}");
        assert!((y - 100.0).abs() < 0.001, "Y = {y}");
        assert!((z - 108.883).abs() < 0.3, "Z = {z}");
    }

    #[test]
    fn perfect_white_is_neutral_in_lab_and_srgb() {
        let white = [1.0; SPECTRUM_SAMPLES];
        let (l, a, b) = spectrum_to_lab(&white);
        assert!((l - 100.0).abs() < 0.01, "L = {l}");
        assert!(a.abs() < 0.05, "a = {a}");
        assert!(b.abs() < 0.05, "b = {b}");
        let (r, g, bl) = spectrum_to_srgb(&white);
        assert!((r - 1.0).abs() < 0.01 && (g - 1.0).abs() < 0.01 && (bl - 1.0).abs() < 0.01);
    }

    #[test]
    fn flat_gray_is_neutral_in_lab() {
        let gray = [0.2; SPECTRUM_SAMPLES];
        let (_, a, b) = spectrum_to_lab(&gray);
        assert!(a.abs() < 0.1, "a = {a}");
        assert!(b.abs() < 0.1, "b = {b}");
    }

    #[test]
    fn ks_roundtrip() {
        let r = 0.5;
        let ks = reflectance_to_ks(r);
        let r2 = ks_to_reflectance(ks);
        assert!((r - r2).abs() < 0.01);
    }
}
