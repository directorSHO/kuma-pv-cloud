import math
import random
import subprocess
from PIL import Image, ImageDraw

W, H, FPS, SECONDS = 960, 540, 30, 30
OUT = r"C:\Users\自分\Documents\Codex\2026-07-31\new-chat\work\gothic_rain_30s.mp4"
FFMPEG = "ffmpeg"

rng = random.Random(116)
palette = [
    (61, 116, 151),
    (76, 104, 157),
    (104, 77, 139),
    (112, 96, 143),
    (139, 123, 83),
]

drops = []
for _ in range(210):
    drops.append({
        "x": rng.uniform(-120, W),
        "y": rng.uniform(-H, H),
        "speed": rng.uniform(420, 980),
        "length": rng.uniform(12, 38),
        "width": rng.choice([1, 1, 1, 2]),
        "color": rng.choice(palette),
        "phase": rng.random() * math.tau,
    })

cmd = [
    FFMPEG, "-y", "-f", "rawvideo", "-pix_fmt", "rgb24",
    "-s", f"{W}x{H}", "-r", str(FPS), "-i", "-",
    "-an", "-c:v", "libx264", "-preset", "fast", "-crf", "18",
    "-pix_fmt", "yuv420p", "-movflags", "+faststart", OUT,
]

proc = subprocess.Popen(cmd, stdin=subprocess.PIPE)
for frame_no in range(FPS * SECONDS):
    t = frame_no / FPS
    image = Image.new("RGB", (W, H), (0, 0, 0))
    draw = ImageDraw.Draw(image)

    spread = max(0.0, min(1.0, (t - 7.5) / 13.0))
    coverage = W * spread
    strength = max(0.0, min(1.0, (t - 7.5) / 9.0))

    for drop in drops:
        drop["y"] += drop["speed"] / FPS
        drop["x"] -= drop["speed"] * 0.10 / FPS
        if drop["y"] > H + 60 or drop["x"] < -160:
            drop["x"] = rng.uniform(0, W + 100)
            drop["y"] = rng.uniform(-220, -20)

        if drop["x"] > coverage + 35:
            continue

        edge = max(0.0, min(1.0, (coverage + 35 - drop["x"]) / 120.0))
        pulse = 0.84 + 0.16 * math.sin(t * 1.7 + drop["phase"])
        gain = strength * edge * pulse
        if gain <= 0.02:
            continue

        color = tuple(int(channel * gain * 0.78) for channel in drop["color"])
        x1, y1 = drop["x"], drop["y"]
        length = drop["length"] * (0.7 + 0.3 * strength)
        draw.line((x1, y1, x1 - length * 0.20, y1 + length), fill=color, width=drop["width"])

    proc.stdin.write(image.tobytes())

proc.stdin.close()
return_code = proc.wait()
if return_code:
    raise SystemExit(return_code)
print(OUT)
