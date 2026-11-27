from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter


ROOT = Path(r"C:\Users\自分\Documents\Codex\2026-07-31\new-chat\work")


def brighten_skin(source: Path, destination: Path) -> Image.Image:
    image = Image.open(source).convert("RGBA")
    rgba = np.asarray(image).astype(np.float32)
    rgb = rgba[..., :3]
    alpha = rgba[..., 3]
    r, g, b = rgb[..., 0], rgb[..., 1], rgb[..., 2]
    luminance = 0.299 * r + 0.587 * g + 0.114 * b
    spread = np.maximum.reduce([r, g, b]) - np.minimum.reduce([r, g, b])

    # Warm, mid-to-high luminance pixels capture the face, neck, shoulders and hand.
    skin = (
        (alpha > 20)
        & (luminance > 82)
        & (r > g * 0.97)
        & (r > b * 0.90)
        & (spread < 105)
    )
    mask = Image.fromarray((skin.astype(np.uint8) * 255), "L").filter(
        ImageFilter.GaussianBlur(5.5)
    )
    weight = (np.asarray(mask).astype(np.float32) / 255.0 * 0.58)[..., None]

    lifted = rgb * 1.075 + np.array([7.0, 4.0, 2.0], dtype=np.float32)
    lifted[..., 0] *= 1.018
    lifted[..., 2] *= 0.985
    rgba[..., :3] = rgb * (1.0 - weight) + lifted * weight
    result = Image.fromarray(np.clip(rgba, 0, 255).astype(np.uint8), "RGBA")
    result.save(destination)
    return result


def feathered_ellipse_mask(size, bbox, blur):
    mask = Image.new("L", size, 0)
    from PIL import ImageDraw

    ImageDraw.Draw(mask).ellipse(bbox, fill=255)
    return mask.filter(ImageFilter.GaussianBlur(blur))


normal = brighten_skin(
    ROOT / "gothic_girl_indigo_skin.png",
    ROOT / "part1_girl_bright_normal.png",
)
closed = brighten_skin(
    ROOT / "gothic_girl_eyes_closed_skin.png",
    ROOT / "part1_girl_bright_closed.png",
)
mouth_open = brighten_skin(
    ROOT / "gothic_girl_indigo_skin_mouth_open.png",
    ROOT / "part1_girl_bright_mouth_open_full.png",
)

# Intermediate eyelid and lip states make the animation less mechanical.
half_eyes = Image.blend(normal, closed, 0.52)
half_mouth = Image.blend(normal, mouth_open, 0.50)


def make_patch(source: Image.Image, mask: Image.Image, destination: Path):
    layer = source.copy()
    source_alpha = layer.getchannel("A")
    combined = Image.fromarray(
        np.minimum(
            np.asarray(source_alpha, dtype=np.uint8),
            np.asarray(mask, dtype=np.uint8),
        ),
        "L",
    )
    layer.putalpha(combined)
    layer.save(destination)


eye_mask = feathered_ellipse_mask(normal.size, (545, 235, 955, 470), 18)
mouth_mask = feathered_ellipse_mask(normal.size, (700, 420, 905, 565), 16)

make_patch(half_eyes, eye_mask, ROOT / "part1_patch_eyes_half.png")
make_patch(closed, eye_mask, ROOT / "part1_patch_eyes_closed.png")
make_patch(half_mouth, mouth_mask, ROOT / "part1_patch_mouth_half.png")
make_patch(mouth_open, mouth_mask, ROOT / "part1_patch_mouth_open.png")

for name in [
    "part1_girl_bright_normal.png",
    "part1_girl_bright_closed.png",
    "part1_girl_bright_mouth_open_full.png",
    "part1_patch_eyes_half.png",
    "part1_patch_eyes_closed.png",
    "part1_patch_mouth_half.png",
    "part1_patch_mouth_open.png",
]:
    print(ROOT / name)
