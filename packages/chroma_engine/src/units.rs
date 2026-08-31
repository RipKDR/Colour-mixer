use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum QuantityUnit {
    Parts,
    Percent,
    Grams,
    Milliliters,
    Drops,
    Teaspoons,
    Scoops,
}

impl QuantityUnit {
    pub fn to_grams(self, value: f64, paint_density: f64) -> f64 {
        match self {
            QuantityUnit::Parts | QuantityUnit::Percent => value,
            QuantityUnit::Grams => value,
            QuantityUnit::Milliliters => value * paint_density,
            QuantityUnit::Drops => value * 0.05,
            QuantityUnit::Teaspoons => value * 5.0,
            QuantityUnit::Scoops => value * 2.0,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RatioDisplay {
    pub parts: String,
    pub percent: String,
    pub grams: String,
}

pub fn format_ratios(weights: &[f64], unit: QuantityUnit, density: f64) -> Vec<RatioDisplay> {
    let grams: Vec<f64> = weights
        .iter()
        .map(|&w| unit.to_grams(w, density))
        .collect();
    let total: f64 = grams.iter().sum();
    if total <= 0.0 {
        return weights
            .iter()
            .map(|_| RatioDisplay {
                parts: "0".into(),
                percent: "0%".into(),
                grams: "0g".into(),
            })
            .collect();
    }

    let min_g = grams.iter().cloned().fold(f64::INFINITY, f64::min);
    weights
        .iter()
        .zip(grams.iter())
        .map(|(&w, &g)| {
            let parts_val = if min_g > 0.0 { g / min_g } else { 0.0 };
            let pct = g / total * 100.0;
            RatioDisplay {
                parts: format!("{parts_val:.1}"),
                percent: format!("{pct:.1}%"),
                grams: format!("{w:.2}g"),
            }
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn drops_convert_to_grams() {
        assert!((QuantityUnit::Drops.to_grams(10.0, 1.0) - 0.5).abs() < 0.001);
    }
}
