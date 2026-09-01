use crate::colorimetry::{
    mix_spectra_ks, reflectance_to_ks, ks_to_reflectance, spectrum_to_lab, spectrum_to_srgb,
    SPECTRUM_SAMPLES,
};
use crate::pigment::{PigmentDatabase, PigmentError};
use thiserror::Error;

#[derive(Debug, Clone)]
pub struct MixComponent {
    pub pigment_id: String,
    pub weight: f64,
}

#[derive(Debug, Clone)]
pub struct MixedColor {
    pub reflectance: [f64; SPECTRUM_SAMPLES],
    pub lab: (f64, f64, f64),
    pub srgb: (f64, f64, f64),
    pub mass_tone: (f64, f64, f64),
    pub undertone: (f64, f64, f64),
}

#[derive(Error, Debug)]
pub enum MixError {
    #[error("No components in mix")]
    EmptyMix,
    #[error("Component weights must be finite and non-negative")]
    InvalidWeight,
    #[error("Pigment error: {0}")]
    Pigment(#[from] PigmentError),
}

pub struct Mixer {
    db: PigmentDatabase,
}

impl Mixer {
    pub fn new(db: PigmentDatabase) -> Self {
        Self { db }
    }

    pub fn database(&self) -> &PigmentDatabase {
        &self.db
    }

    pub fn mix_weighted(&self, components: &[MixComponent]) -> Result<MixedColor, MixError> {
        if components.is_empty() {
            return Err(MixError::EmptyMix);
        }

        // NaN would poison the K/S sums and silently render as white, and
        // negative weights are physically meaningless — reject both.
        if components
            .iter()
            .any(|c| !c.weight.is_finite() || c.weight < 0.0)
        {
            return Err(MixError::InvalidWeight);
        }

        let total_weight: f64 = components.iter().map(|c| c.weight).sum();
        if total_weight <= 0.0 {
            return Err(MixError::EmptyMix);
        }

        let mut ks_mixed = [0.0; SPECTRUM_SAMPLES];

        for component in components {
            let pigment = self.db.get(&component.pigment_id)?;
            let normalized = component.weight / total_weight;
            let strength = pigment.tinting_strength;
            let effective_weight = normalized * strength;

            for i in 0..SPECTRUM_SAMPLES {
                let ks = reflectance_to_ks(pigment.reflectance[i]);
                ks_mixed[i] += ks * effective_weight;
            }
        }

        let mut reflectance = [0.0; SPECTRUM_SAMPLES];
        for i in 0..SPECTRUM_SAMPLES {
            reflectance[i] = ks_to_reflectance(ks_mixed[i]);
        }

        let lab = spectrum_to_lab(&reflectance);
        let srgb = spectrum_to_srgb(&reflectance);

        let mass_tone = srgb;

        let undertone = self.compute_undertone(&reflectance);

        Ok(MixedColor {
            reflectance,
            lab,
            srgb,
            mass_tone,
            undertone,
        })
    }

    /// Undertone: thin glaze of mix over white (10% concentration).
    /// Falls back to a synthetic flat-white spectrum if the dataset has no
    /// `titanium_white`, so mixing never hard-depends on one pigment id.
    fn compute_undertone(
        &self,
        mass_reflectance: &[f64; SPECTRUM_SAMPLES],
    ) -> (f64, f64, f64) {
        let white_reflectance: [f64; SPECTRUM_SAMPLES] = self
            .db
            .get("titanium_white")
            .map(|w| w.reflectance)
            .unwrap_or([0.95; SPECTRUM_SAMPLES]);
        let glaze_t = 0.1;
        let mut undertone_spec = [0.0; SPECTRUM_SAMPLES];
        for i in 0..SPECTRUM_SAMPLES {
            undertone_spec[i] =
                mix_spectra_ks(&white_reflectance, mass_reflectance, glaze_t)[i];
        }
        spectrum_to_srgb(&undertone_spec)
    }

    pub fn mix_two(
        &self,
        id_a: &str,
        id_b: &str,
        ratio_b: f64,
    ) -> Result<MixedColor, MixError> {
        self.mix_weighted(&[
            MixComponent {
                pigment_id: id_a.to_string(),
                weight: 1.0 - ratio_b,
            },
            MixComponent {
                pigment_id: id_b.to_string(),
                weight: ratio_b,
            },
        ])
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn test_db() -> PigmentDatabase {
        let json = include_str!("../../../data/pigments/all_pigments.json");
        PigmentDatabase::load_from_json(json).expect("test pigments")
    }

    #[test]
    fn blue_yellow_makes_green_not_gray() {
        let mixer = Mixer::new(test_db());
        let result = mixer
            .mix_two("ultramarine_blue", "hansa_yellow", 0.5)
            .unwrap();
        let (r, g, b) = result.srgb;
        assert!(g > r && g > b, "Expected green dominant, got ({r},{g},{b})");
        assert!(result.lab.1 < 0.0, "Green should have negative a*");
    }

    #[test]
    fn white_tints_color() {
        let mixer = Mixer::new(test_db());
        let pure = mixer.mix_weighted(&[MixComponent {
            pigment_id: "cadmium_red_light".into(),
            weight: 1.0,
        }]).unwrap();
        let tinted = mixer
            .mix_two("cadmium_red_light", "titanium_white", 0.5)
            .unwrap();
        assert!(tinted.lab.0 > pure.lab.0);
    }
}
