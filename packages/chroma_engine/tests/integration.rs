use chroma_engine::api::{list_pigments, mix_paints};
use chroma_engine::mix::MixComponent;

#[test]
fn engine_loads_20_pigments() {
    let count = chroma_engine::api::chroma_init();
    assert_eq!(count, 20);
}

#[test]
fn list_pigments_returns_all() {
    chroma_engine::api::chroma_init();
    let pigments = list_pigments();
    assert_eq!(pigments.len(), 20);
}

#[test]
fn blue_yellow_mix_is_greenish() {
    chroma_engine::api::chroma_init();
    let result = mix_paints(vec![
        MixComponent {
            pigment_id: "ultramarine_blue".into(),
            weight: 1.0,
        },
        MixComponent {
            pigment_id: "hansa_yellow".into(),
            weight: 1.0,
        },
    ])
    .unwrap();
    assert!(result.srgb.1 > result.srgb.0);
    assert!(result.srgb.1 > result.srgb.2);
    assert!(result.lab.1 < 0.0);
}

#[test]
fn ciede2000_identical_is_zero() {
    chroma_engine::api::chroma_init();
    let delta = chroma_engine::api::chroma_color_difference(50.0, 10.0, 20.0, 50.0, 10.0, 20.0);
    assert!(delta < 0.01);
}

#[test]
fn blue_yellow_parity_reflectance_finite() {
    // Parity guard: the same blue+yellow mix that the Dart engine
    // exercises (see rust_parity_test.dart) must produce a finite,
    // non-zero reflectance spectrum in Rust. This keeps the two
    // engines' shared data contract (spectrum_samples, finite values,
    // green-dominant srgb, negative a*) verified on both sides.
    let result = mix_paints(vec![
        MixComponent {
            pigment_id: "ultramarine_blue".into(),
            weight: 1.0,
        },
        MixComponent {
            pigment_id: "hansa_yellow".into(),
            weight: 1.0,
        },
    ])
    .unwrap();

    // Reflectance must be the full 41-sample spectrum.
    assert_eq!(
        result.reflectance.len(),
        chroma_engine::colorimetry::SPECTRUM_SAMPLES
    );
    // Every sample finite and in [0, 1].
    for (i, &r) in result.reflectance.iter().enumerate() {
        assert!(r.is_finite() && r >= 0.0 && r <= 1.0, "sample {i} = {r}");
    }
    // Not all zeros (mixing two pigments should produce something).
    assert!(
        result.reflectance.iter().any(|&r| r > 0.01),
        "reflectance all near-zero"
    );
    // The green channel must dominate (blue+yellow -> green).
    assert!(result.srgb.1 > result.srgb.0);
    assert!(result.srgb.1 > result.srgb.2);
    assert!(result.lab.1 < 0.0);
}

#[test]
fn blue_red_parity_reflectance_finite() {
    let blue = mix_paints(vec![MixComponent {
        pigment_id: "ultramarine_blue".into(),
        weight: 1.0,
    }])
    .unwrap();
    let red = mix_paints(vec![MixComponent {
        pigment_id: "cadmium_red_light".into(),
        weight: 1.0,
    }])
    .unwrap();
    let result = mix_paints(vec![
        MixComponent {
            pigment_id: "ultramarine_blue".into(),
            weight: 1.0,
        },
        MixComponent {
            pigment_id: "cadmium_red_light".into(),
            weight: 1.0,
        },
    ])
    .unwrap();

    assert_eq!(
        result.reflectance.len(),
        chroma_engine::colorimetry::SPECTRUM_SAMPLES
    );
    for (i, &r) in result.reflectance.iter().enumerate() {
        assert!(r.is_finite() && r >= 0.0 && r <= 1.0, "sample {i} = {r}");
    }
    assert!(result.reflectance.iter().any(|&r| r > 0.01));
    assert_ne!(result.srgb, blue.srgb);
    assert_ne!(result.srgb, red.srgb);
    assert_ne!(result.lab, blue.lab);
    assert_ne!(result.lab, red.lab);
}
