use crate::colorimetry::{spectrum_to_lab, spectrum_to_srgb, SPECTRUM_SAMPLES};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use thiserror::Error;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PigmentData {
    pub id: String,
    pub name: String,
    pub pigment_codes: Vec<String>,
    pub reflectance: Vec<f64>,
    pub opacity: f64,
    pub tinting_strength: f64,
    pub toxicity: String,
    pub binder: String,
}

#[derive(Debug, Clone)]
pub struct Pigment {
    pub id: String,
    pub name: String,
    pub pigment_codes: Vec<String>,
    pub reflectance: [f64; SPECTRUM_SAMPLES],
    pub opacity: f64,
    pub tinting_strength: f64,
    pub toxicity: String,
    pub binder: String,
    pub lab: (f64, f64, f64),
    pub srgb: (f64, f64, f64),
}

#[derive(Error, Debug)]
pub enum PigmentError {
    #[error("Invalid reflectance length: expected {SPECTRUM_SAMPLES}, got {0}")]
    InvalidReflectanceLength(usize),
    #[error("Pigment not found: {0}")]
    NotFound(String),
    #[error("JSON parse error: {0}")]
    Json(#[from] serde_json::Error),
}

impl TryFrom<PigmentData> for Pigment {
    type Error = PigmentError;

    fn try_from(data: PigmentData) -> Result<Self, Self::Error> {
        if data.reflectance.len() != SPECTRUM_SAMPLES {
            return Err(PigmentError::InvalidReflectanceLength(
                data.reflectance.len(),
            ));
        }
        let mut reflectance = [0.0; SPECTRUM_SAMPLES];
        reflectance.copy_from_slice(&data.reflectance);
        let lab = spectrum_to_lab(&reflectance);
        let srgb = spectrum_to_srgb(&reflectance);
        Ok(Pigment {
            id: data.id,
            name: data.name,
            pigment_codes: data.pigment_codes,
            reflectance,
            opacity: data.opacity,
            tinting_strength: data.tinting_strength,
            toxicity: data.toxicity,
            binder: data.binder,
            lab,
            srgb,
        })
    }
}

pub struct PigmentDatabase {
    pigments: HashMap<String, Pigment>,
}

impl PigmentDatabase {
    pub fn new() -> Self {
        Self {
            pigments: HashMap::new(),
        }
    }

    pub fn load_from_json(json: &str) -> Result<Self, PigmentError> {
        let data: Vec<PigmentData> = serde_json::from_str(json)?;
        let mut db = Self::new();
        for item in data {
            let pigment = Pigment::try_from(item)?;
            db.pigments.insert(pigment.id.clone(), pigment);
        }
        Ok(db)
    }

    pub fn insert(&mut self, pigment: Pigment) {
        self.pigments.insert(pigment.id.clone(), pigment);
    }

    pub fn get(&self, id: &str) -> Result<&Pigment, PigmentError> {
        self.pigments
            .get(id)
            .ok_or_else(|| PigmentError::NotFound(id.to_string()))
    }

    pub fn all(&self) -> Vec<&Pigment> {
        let mut list: Vec<_> = self.pigments.values().collect();
        list.sort_by(|a, b| a.name.cmp(&b.name));
        list
    }

    pub fn count(&self) -> usize {
        self.pigments.len()
    }
}

impl Default for PigmentDatabase {
    fn default() -> Self {
        Self::new()
    }
}
