from __future__ import annotations

import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "scripts/app_icon_source.png"
APP_MEDIA = ROOT / "ohos/AppScope/resources/base/media"
ENTRY_MEDIA = ROOT / "ohos/entry/src/main/resources/base/media"
SIZE = 1024


def fill_transparent_corners(image: Image.Image) -> Image.Image:
    image = image.convert("RGBA")
    pixels = image.load()
    width, height = image.size

    def is_opaque(x: int, y: int) -> bool:
        return pixels[x, y][3] >= 128

    changed = True
    neighbors = (
        (-1, 0),
        (1, 0),
        (0, -1),
        (0, 1),
        (-1, -1),
        (1, -1),
        (-1, 1),
        (1, 1),
    )
    while changed:
        changed = False
        updates: list[tuple[int, int, tuple[int, int, int, int]]] = []
        for y in range(height):
            for x in range(width):
                if is_opaque(x, y):
                    continue
                acc = [0, 0, 0]
                count = 0
                for dx, dy in neighbors:
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < width and 0 <= ny < height and is_opaque(nx, ny):
                        color = pixels[nx, ny]
                        acc[0] += color[0]
                        acc[1] += color[1]
                        acc[2] += color[2]
                        count += 1
                if count:
                    updates.append(
                        (
                            x,
                            y,
                            (acc[0] // count, acc[1] // count, acc[2] // count, 255),
                        )
                    )
        for x, y, color in updates:
            pixels[x, y] = color
            changed = True
    return image.convert("RGB")


def lerp(start: int, end: int, t: float) -> int:
    return int(start + (end - start) * t)


def make_background(filled: Image.Image) -> Image.Image:
    width, height = filled.size
    c00 = filled.getpixel((0, 0))
    c10 = filled.getpixel((width - 1, 0))
    c01 = filled.getpixel((0, height - 1))
    c11 = filled.getpixel((width - 1, height - 1))
    background = Image.new("RGB", (width, height))
    pixels = background.load()
    den = max(width - 1, 1)
    for y in range(height):
        ty = y / den
        for x in range(width):
            tx = x / den
            top = tuple(lerp(c00[i], c10[i], tx) for i in range(3))
            bottom = tuple(lerp(c01[i], c11[i], tx) for i in range(3))
            pixels[x, y] = tuple(lerp(top[i], bottom[i], ty) for i in range(3))
    return background


def write_layered_json(directory: Path) -> None:
    payload = {
        "layered-image": {
            "background": "$media:background",
            "foreground": "$media:foreground",
        }
    }
    (directory / "layered_image.json").write_text(
        json.dumps(payload, indent=2) + "\n",
        encoding="utf-8",
    )


def main() -> None:
    source = Image.open(SRC).convert("RGBA").resize(
        (SIZE, SIZE),
        Image.Resampling.LANCZOS,
    )
    filled = fill_transparent_corners(source)
    background = make_background(filled)
    foreground = filled

    for directory in (APP_MEDIA, ENTRY_MEDIA):
        directory.mkdir(parents=True, exist_ok=True)
        background.save(directory / "background.png", format="PNG")
        foreground.save(directory / "foreground.png", format="PNG")
        write_layered_json(directory)

    filled.save(ENTRY_MEDIA / "icon.png", format="PNG")
    if (APP_MEDIA / "app_icon.png").exists():
        (APP_MEDIA / "app_icon.png").unlink()

    for path in (
        APP_MEDIA / "background.png",
        APP_MEDIA / "foreground.png",
        ENTRY_MEDIA / "background.png",
        ENTRY_MEDIA / "foreground.png",
        ENTRY_MEDIA / "icon.png",
    ):
        image = Image.open(path)
        print(path.relative_to(ROOT), image.size, image.mode)


if __name__ == "__main__":
    main()
