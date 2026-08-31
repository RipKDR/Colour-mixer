#!/usr/bin/env python3
"""Generate spectral reflectance curves for 20 artist pigments (380-780nm, 41 samples)."""

import json
import math

SAMPLES = 41
WL_MIN = 380
WL_STEP = 10


def wavelength(i):
    return WL_MIN + i * WL_STEP


def gaussian(wl, center, width, amplitude=1.0):
    return amplitude * math.exp(-0.5 * ((wl - center) / width) ** 2)


def sigmoid_reflectance(wl, low, high, center, steepness):
    t = 1.0 / (1.0 + math.exp(-steepness * (wl - center)))
    return low + (high - low) * t


def generate_spectrum(profile_fn):
    return [max(0.001, min(0.999, profile_fn(wavelength(i)))) for i in range(SAMPLES)]


PIGMENTS = [
    {
        "id": "titanium_white",
        "name": "Titanium White",
        "pigment_codes": ["PW6"],
        "opacity": 1.0,
        "tinting_strength": 0.3,
        "toxicity": "low",
        "binder": "acrylic",
        "profile": lambda wl: 0.92 + 0.03 * gaussian(wl, 450, 80),
    },
    {
        "id": "ivory_black",
        "name": "Ivory Black",
        "pigment_codes": ["PBk9"],
        "opacity": 0.95,
        "tinting_strength": 1.2,
        "toxicity": "low",
        "binder": "acrylic",
        "profile": lambda wl: 0.04 + 0.02 * (wl - 380) / 400,
    },
    {
        "id": "cadmium_red_light",
        "name": "Cadmium Red Light",
        "pigment_codes": ["PR108"],
        "opacity": 0.9,
        "tinting_strength": 1.0,
        "toxicity": "high",
        "binder": "acrylic",
        "profile": lambda wl: sigmoid_reflectance(wl, 0.05, 0.75, 600, 0.04)
        + gaussian(wl, 650, 30, 0.15),
    },
    {
        "id": "cadmium_yellow",
        "name": "Cadmium Yellow",
        "pigment_codes": ["PY35"],
        "opacity": 0.9,
        "tinting_strength": 0.9,
        "toxicity": "high",
        "binder": "acrylic",
        "profile": lambda wl: sigmoid_reflectance(wl, 0.08, 0.02, 520, -0.05)
        + gaussian(wl, 580, 40, 0.7),
    },
    {
        "id": "ultramarine_blue",
        "name": "Ultramarine Blue",
        "pigment_codes": ["PB29"],
        "opacity": 0.85,
        "tinting_strength": 1.1,
        "toxicity": "low",
        "binder": "acrylic",
        "profile": lambda wl: sigmoid_reflectance(wl, 0.7, 0.06, 480, -0.03)
        + gaussian(wl, 450, 25, 0.2),
    },
    {
        "id": "phthalo_blue_gs",
        "name": "Phthalo Blue (Green Shade)",
        "pigment_codes": ["PB15:3"],
        "opacity": 0.95,
        "tinting_strength": 2.0,
        "toxicity": "low",
        "binder": "acrylic",
        "profile": lambda wl: sigmoid_reflectance(wl, 0.75, 0.04, 460, -0.04)
        + gaussian(wl, 490, 20, 0.15),
    },
    {
        "id": "phthalo_green",
        "name": "Phthalo Green",
        "pigment_codes": ["PG7"],
        "opacity": 0.95,
        "tinting_strength": 2.0,
        "toxicity": "low",
        "binder": "acrylic",
        "profile": lambda wl: sigmoid_reflectance(wl, 0.7, 0.05, 500, -0.03)
        * sigmoid_reflectance(wl, 0.05, 0.6, 650, 0.05),
    },
    {
        "id": "yellow_ochre",
        "name": "Yellow Ochre",
        "pigment_codes": ["PY43"],
        "opacity": 0.8,
        "tinting_strength": 0.7,
        "toxicity": "low",
        "binder": "acrylic",
        "profile": lambda wl: 0.15 + gaussian(wl, 580, 60, 0.5) + gaussian(wl, 450, 80, 0.1),
    },
    {
        "id": "burnt_sienna",
        "name": "Burnt Sienna",
        "pigment_codes": ["PBr7"],
        "opacity": 0.75,
        "tinting_strength": 0.8,
        "toxicity": "low",
        "binder": "acrylic",
        "profile": lambda wl: 0.1 + gaussian(wl, 600, 70, 0.45) + gaussian(wl, 480, 60, 0.15),
    },
    {
        "id": "raw_umber",
        "name": "Raw Umber",
        "pigment_codes": ["PBr7"],
        "opacity": 0.8,
        "tinting_strength": 1.0,
        "toxicity": "low",
        "binder": "acrylic",
        "profile": lambda wl: 0.08 + gaussian(wl, 550, 80, 0.3) + gaussian(wl, 650, 50, 0.15),
    },
    {
        "id": "alizarin_crimson",
        "name": "Alizarin Crimson",
        "pigment_codes": ["PR83"],
        "opacity": 0.7,
        "tinting_strength": 1.5,
        "toxicity": "medium",
        "binder": "acrylic",
        "profile": lambda wl: sigmoid_reflectance(wl, 0.06, 0.55, 580, 0.035)
        + gaussian(wl, 500, 40, 0.1),
    },
    {
        "id": "quinacridone_magenta",
        "name": "Quinacridone Magenta",
        "pigment_codes": ["PR122"],
        "opacity": 0.75,
        "tinting_strength": 1.8,
        "toxicity": "low",
        "binder": "acrylic",
        "profile": lambda wl: sigmoid_reflectance(wl, 0.05, 0.6, 560, 0.04)
        + gaussian(wl, 520, 30, 0.12),
    },
    {
        "id": "hansa_yellow",
        "name": "Hansa Yellow",
        "pigment_codes": ["PY74"],
        "opacity": 0.85,
        "tinting_strength": 1.0,
        "toxicity": "low",
        "binder": "acrylic",
        "profile": lambda wl: sigmoid_reflectance(wl, 0.06, 0.02, 500, -0.06)
        + gaussian(wl, 570, 35, 0.75),
    },
    {
        "id": "pyrrole_red",
        "name": "Pyrrole Red",
        "pigment_codes": ["PR254"],
        "opacity": 0.9,
        "tinting_strength": 1.2,
        "toxicity": "low",
        "binder": "acrylic",
        "profile": lambda wl: sigmoid_reflectance(wl, 0.05, 0.7, 610, 0.04),
    },
    {
        "id": "dioxazine_purple",
        "name": "Dioxazine Purple",
        "pigment_codes": ["PV23"],
        "opacity": 0.9,
        "tinting_strength": 2.0,
        "toxicity": "low",
        "binder": "acrylic",
        "profile": lambda wl: sigmoid_reflectance(wl, 0.65, 0.08, 520, -0.03)
        * sigmoid_reflectance(wl, 0.08, 0.4, 580, 0.03),
    },
    {
        "id": "cerulean_blue",
        "name": "Cerulean Blue",
        "pigment_codes": ["PB35"],
        "opacity": 0.85,
        "tinting_strength": 0.8,
        "toxicity": "medium",
        "binder": "acrylic",
        "profile": lambda wl: sigmoid_reflectance(wl, 0.55, 0.12, 490, -0.025)
        + gaussian(wl, 480, 30, 0.2),
    },
    {
        "id": "viridian",
        "name": "Viridian",
        "pigment_codes": ["PG18"],
        "opacity": 0.8,
        "tinting_strength": 1.2,
        "toxicity": "medium",
        "binder": "acrylic",
        "profile": lambda wl: sigmoid_reflectance(wl, 0.6, 0.08, 510, -0.025)
        * sigmoid_reflectance(wl, 0.08, 0.45, 620, 0.035),
    },
    {
        "id": "naples_yellow",
        "name": "Naples Yellow",
        "pigment_codes": ["PBr24"],
        "opacity": 0.85,
        "tinting_strength": 0.5,
        "toxicity": "medium",
        "binder": "acrylic",
        "profile": lambda wl: 0.5 + gaussian(wl, 580, 50, 0.3) - gaussian(wl, 450, 60, 0.1),
    },
    {
        "id": "burnt_umber",
        "name": "Burnt Umber",
        "pigment_codes": ["PBr7"],
        "opacity": 0.85,
        "tinting_strength": 1.1,
        "toxicity": "low",
        "binder": "acrylic",
        "profile": lambda wl: 0.06 + gaussian(wl, 580, 70, 0.25) + gaussian(wl, 480, 50, 0.1),
    },
    {
        "id": "paynes_gray",
        "name": "Payne's Gray",
        "pigment_codes": ["PBk7", "PB29"],
        "opacity": 0.8,
        "tinting_strength": 1.3,
        "toxicity": "low",
        "binder": "acrylic",
        "profile": lambda wl: 0.08 + gaussian(wl, 480, 40, 0.15) + gaussian(wl, 600, 60, 0.08),
    },
]


def main():
    output = []
    for p in PIGMENTS:
        profile = p.pop("profile")
        reflectance = generate_spectrum(profile)
        output.append({**p, "reflectance": reflectance})

    with open("/agent/data/pigments/all_pigments.json", "w") as f:
        json.dump(output, f, indent=2)
    print(f"Generated {len(output)} pigments")


if __name__ == "__main__":
    main()
