from pathlib import Path
import numpy as np
from PIL import Image, ImageFilter

ROOT = Path(r"C:\Users\自分\Documents\Codex\2026-07-31\new-chat\work")
PAIRS = [
    ("gothic_girl_eyes_closed.png", "gothic_girl_eyes_closed_warm.png"),
    ("gothic_girl_indigo.png", "gothic_girl_indigo_warm.png"),
]

for source_name, output_name in PAIRS:
    image = Image.open(ROOT / source_name).convert("RGBA")
    rgba = np.asarray(image).astype(np.float32)
    rgb = rgba[..., :3]
    alpha = rgba[..., 3] / 255.0
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]

    # Select pale, warm-neutral pixels: face, neck, shoulders and hands.
    luminance = 0.299 * r + 0.587 * g + 0.114 * b
    spread = np.maximum.reduce([r, g, b]) - np.minimum.reduce([r, g, b])
    skin = (
        (alpha > 0.08)
        & (luminance > 82)
        & (r > g * 0.98)
        & (r > b * 0.91)
        & (spread < 92)
    )

    mask = Image.fromarray((skin.astype(np.uint8) * 255), "L").filter(ImageFilter.GaussianBlur(5.0))
    weight = (np.asarray(mask).astype(np.float32) / 255.0 * 0.88)[..., None]

    # Pre-compensate the later blue moonlight grade on skin only.
    hsv = np.asarray(image.convert("HSV")).astype(np.float32)
    hsv[..., 0] = np.mod(hsv[..., 0] + 41.0, 256.0)  # +58 degrees
    hsv[..., 1] = np.clip(hsv[..., 1] * 1.20 + 4, 0, 255)
    hsv[..., 2] = np.clip(hsv[..., 2] * 1.075 + 5, 0, 255)
    compensated = Image.fromarray(hsv.astype(np.uint8), "HSV").convert("RGB")
    warmed = np.asarray(compensated).astype(np.float32)

    rgba[..., :3] = rgb * (1.0 - weight) + warmed * weight
    out = Image.fromarray(np.clip(rgba, 0, 255).astype(np.uint8), "RGBA")
    out.save(ROOT / output_name)
    print(ROOT / output_name)
