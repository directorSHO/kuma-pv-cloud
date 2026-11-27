from pathlib import Path
import numpy as np
from PIL import Image, ImageFilter

ROOT = Path(r"C:\Users\自分\Documents\Codex\2026-07-31\new-chat\work")
PAIRS = [
    ("gothic_girl_eyes_closed.png", "gothic_girl_eyes_closed_skin.png"),
    ("gothic_girl_indigo.png", "gothic_girl_indigo_skin.png"),
]

for source_name, output_name in PAIRS:
    image = Image.open(ROOT / source_name).convert("RGBA")
    rgba = np.asarray(image).astype(np.float32)
    rgb = rgba[..., :3]
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    original_alpha = rgba[..., 3] / 255.0
    luminance = 0.299 * r + 0.587 * g + 0.114 * b
    spread = np.maximum.reduce([r, g, b]) - np.minimum.reduce([r, g, b])

    skin = (
        (original_alpha > 0.08)
        & (luminance > 120)
        & (r > g * 0.98)
        & (r > b * 0.90)
        & (spread < 96)
    )
    mask = Image.fromarray((skin.astype(np.uint8) * 255), "L").filter(ImageFilter.GaussianBlur(3.0))
    mask_array = np.asarray(mask).astype(np.float32) / 255.0

    out = rgba.copy()
    out[..., 0] = np.clip(r * 1.12 + 8, 0, 255)
    out[..., 1] = np.clip(g * 1.045 + 3, 0, 255)
    out[..., 2] = np.clip(b * 0.94, 0, 255)
    out[..., 3] = np.clip(original_alpha * mask_array * 232, 0, 255)
    Image.fromarray(out.astype(np.uint8), "RGBA").save(ROOT / output_name)
    print(ROOT / output_name)
