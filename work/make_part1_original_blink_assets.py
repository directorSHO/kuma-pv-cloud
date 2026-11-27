from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(r"C:\Users\自分\Documents\Codex\2026-07-31\new-chat\work")
normal = Image.open(ROOT / "gothic_girl_indigo_skin.png").convert("RGBA")
closed = Image.open(ROOT / "gothic_girl_eyes_closed_skin.png").convert("RGBA")
half = Image.blend(normal, closed, 0.52)

mask = Image.new("L", normal.size, 0)
ImageDraw.Draw(mask).ellipse((545, 235, 955, 470), fill=255)
mask = mask.filter(ImageFilter.GaussianBlur(18))


def save_patch(source: Image.Image, name: str):
    layer = source.copy()
    alpha = np.minimum(
        np.asarray(layer.getchannel("A"), dtype=np.uint8),
        np.asarray(mask, dtype=np.uint8),
    )
    layer.putalpha(Image.fromarray(alpha, "L"))
    layer.save(ROOT / name)
    print(ROOT / name)


save_patch(half, "part1_original_patch_eyes_half.png")
save_patch(closed, "part1_original_patch_eyes_closed.png")
