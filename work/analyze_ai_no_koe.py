import wave
import numpy as np
from PIL import Image, ImageDraw, ImageFont

wav_path = r"C:\Users\自分\Documents\Codex\2026-07-31\new-chat\work\ai_no_koe_20s.wav"
out_path = r"C:\Users\自分\Documents\Codex\2026-07-31\new-chat\work\ai_no_koe_analysis.png"

with wave.open(wav_path, "rb") as wf:
    sr = wf.getframerate()
    samples = np.frombuffer(wf.readframes(wf.getnframes()), dtype=np.int16).astype(np.float32) / 32768

n_fft, hop = 1024, 128
window = np.hanning(n_fft).astype(np.float32)
frames = np.lib.stride_tricks.sliding_window_view(samples, n_fft)[::hop]
spec = np.abs(np.fft.rfft(frames * window, axis=1))
freqs = np.fft.rfftfreq(n_fft, 1 / sr)
times = np.arange(len(spec)) * hop / sr

band = (freqs >= 250) & (freqs <= 3500)
energy = np.sqrt(np.mean(spec[:, band] ** 2, axis=1))
energy /= energy.max() + 1e-9
flux = np.maximum(0, np.diff(spec[:, band], axis=0)).mean(axis=1)
flux = np.pad(flux, (1, 0))
flux /= flux.max() + 1e-9
kernel = np.ones(9) / 9
smooth = np.convolve(energy, kernel, mode="same")

peaks = []
for i in range(2, len(flux) - 2):
    if flux[i] > 0.16 and flux[i] == max(flux[i-2:i+3]):
        t = times[i]
        if not peaks or t - peaks[-1][0] > 0.11:
            peaks.append((t, float(flux[i]), float(smooth[i])))

W, H = 2400, 900
img = Image.new("RGB", (W, H), "#050710")
draw = ImageDraw.Draw(img)
font = ImageFont.truetype(r"C:\Windows\Fonts\meiryo.ttc", 22)
small = ImageFont.truetype(r"C:\Windows\Fonts\meiryo.ttc", 16)

def tx(t): return int(t / 20 * (W - 100)) + 60

for sec in range(21):
    x = tx(sec)
    draw.line((x, 40, x, H - 50), fill="#28304d", width=1)
    draw.text((x + 3, 8), f"{sec}s", font=font, fill="#d9e1ff")

# waveform
bins = W - 100
chunks = np.array_split(samples, bins)
for idx, chunk in enumerate(chunks):
    x = idx + 60
    amp = float(np.max(np.abs(chunk))) if len(chunk) else 0
    y = int(150 * amp)
    draw.line((x, 210-y, x, 210+y), fill="#477dff")
draw.text((10, 190), "波形", font=small, fill="white")

# band energy and flux
for arr, base_y, scale, color, label in [
    (smooth, 520, 180, "#69e0d0", "声帯域"),
    (flux, 800, 180, "#ff6ea8", "発音立上り"),
]:
    pts = [(tx(float(t)), int(base_y - float(v) * scale)) for t, v in zip(times, arr)]
    draw.line(pts, fill=color, width=2)
    draw.text((10, base_y-20), label, font=small, fill=color)

for t, f, e in peaks:
    x = tx(t)
    draw.line((x, 610, x, 820), fill="#ffb3d0", width=1)
    draw.text((x + 2, 820), f"{t:.2f}", font=small, fill="#ffd4e5")

img.save(out_path)
print("PEAKS")
print(" ".join(f"{t:.2f}" for t, f, e in peaks if t <= 16))
print(out_path)
