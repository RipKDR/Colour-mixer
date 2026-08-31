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
