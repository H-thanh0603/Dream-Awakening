from __future__ import annotations

import shutil
from pathlib import Path

from PIL import Image, ImageEnhance


ROOT = Path(__file__).resolve().parents[1]
SOURCE = Path(r"D:\PixelGame img")
OUT = ROOT / "assets"


def transparent_crop(src: Path, box: tuple[int, int, int, int], max_size: tuple[int, int] | None = None) -> Image.Image:
    img = Image.open(src).convert("RGBA").crop(box)
    px = img.load()
    w, h = img.size

    # The AI sheets use a warm paper background. Remove only low-saturation,
    # bright pixels so the actual pixel art keeps its cream highlights.
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            mx = max(r, g, b)
            mn = min(r, g, b)
            if r > 218 and g > 205 and b > 185 and (mx - mn) < 42:
                px[x, y] = (r, g, b, 0)

    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)

    if max_size:
        img.thumbnail(max_size, Image.Resampling.LANCZOS)

    return img


def save_asset(src_name: str, box: tuple[int, int, int, int], dest: str, max_size: tuple[int, int] | None = None) -> None:
    target = OUT / dest
    target.parent.mkdir(parents=True, exist_ok=True)
    img = transparent_crop(SOURCE / src_name, box, max_size)
    img.save(target)
    print(f"{dest}: {img.size}")


def save_tile(src_name: str, box: tuple[int, int, int, int], dest: str) -> None:
    target = OUT / dest
    target.parent.mkdir(parents=True, exist_ok=True)
    img = Image.open(SOURCE / src_name).convert("RGBA").crop(box).resize((16, 16), Image.Resampling.LANCZOS)
    img.save(target)
    print(f"{dest}: {img.size}")


def save_sheet(dest: str, frames: list[Image.Image], cell_size: tuple[int, int] = (40, 56)) -> None:
    target = OUT / dest
    target.parent.mkdir(parents=True, exist_ok=True)
    sheet = Image.new("RGBA", (cell_size[0] * len(frames), cell_size[1]), (0, 0, 0, 0))
    for i, frame in enumerate(frames):
        frame = frame.copy()
        frame.thumbnail((cell_size[0], cell_size[1]), Image.Resampling.LANCZOS)
        x = i * cell_size[0] + (cell_size[0] - frame.width) // 2
        y = cell_size[1] - frame.height
        sheet.alpha_composite(frame, (x, y))
    sheet.save(target)
    print(f"{dest}: {sheet.size}")


def save_character_set(
    name: str,
    src_name: str,
    boxes: dict[str, tuple[int, int, int, int]],
    max_size: tuple[int, int],
) -> None:
    frames: dict[str, Image.Image] = {}
    for direction, box in boxes.items():
        frames[direction] = transparent_crop(SOURCE / src_name, box, max_size)

    aliases = {
        "down": f"sprites/characters/{name}.png",
        "left": f"sprites/characters/{name}_left.png",
        "right": f"sprites/characters/{name}_right.png",
        "up": f"sprites/characters/{name}_up.png",
    }
    for direction, dest in aliases.items():
        target = OUT / dest
        target.parent.mkdir(parents=True, exist_ok=True)
        frames[direction].save(target)
        print(f"{dest}: {frames[direction].size}")

    frames["down"].save(OUT / f"sprites/characters/{name}_down.png")
    print(f"sprites/characters/{name}_down.png: {frames['down'].size}")
    save_sheet(
        f"sprites/characters/{name}_sheet.png",
        [frames["down"], frames["left"], frames["right"], frames["up"]],
        (max_size[0] + 10, max_size[1] + 6),
    )


def copy_sources() -> None:
    reference_dir = OUT / "ai_reference" / "pixelgame"
    reference_dir.mkdir(parents=True, exist_ok=True)
    for src in SOURCE.glob("*.png"):
        shutil.copy2(src, reference_dir / src.name)


def main() -> None:
    copy_sources()

    save_asset("pixel 1.png", (0, 0, 1456, 1088), "preview_sheet.png", (728, 544))

    # Character overworld sprites and directional placeholders.
    save_character_set(
        "player",
        "pixel 2.png",
        {
            "down": (80, 65, 225, 300),
            "left": (260, 65, 375, 300),
            "up": (430, 65, 545, 300),
            "right": (590, 65, 705, 300),
        },
        (36, 48),
    )
    save_character_set(
        "mira",
        "pixel 3.png",
        {
            "down": (105, 65, 255, 300),
            "up": (350, 65, 500, 300),
            "left": (555, 65, 690, 300),
            "right": (705, 65, 840, 300),
        },
        (36, 48),
    )
    save_character_set(
        "theo",
        "pixel 4.png",
        {
            "down": (85, 80, 225, 315),
            "left": (215, 365, 360, 585),
            "up": (85, 600, 225, 800),
            "right": (415, 365, 560, 585),
        },
        (36, 48),
    )
    save_character_set(
        "rell",
        "pixel 5.png",
        {
            "down": (75, 95, 230, 340),
            "up": (80, 380, 230, 610),
            "left": (60, 685, 210, 930),
            "right": (355, 685, 500, 930),
        },
        (38, 50),
    )
    save_character_set(
        "lina",
        "pixel 6.png",
        {
            "down": (110, 80, 265, 350),
            "left": (340, 80, 475, 350),
            "up": (500, 80, 650, 350),
            "right": (690, 80, 820, 350),
        },
        (40, 52),
    )

    # Dialogue portraits.
    save_asset("pixel 2.png", (485, 890, 705, 1065), "portraits/player_portrait.png", (96, 96))
    save_asset("pixel 3.png", (790, 610, 1015, 835), "portraits/mira_portrait.png", (96, 96))
    save_asset("pixel 4.png", (780, 565, 1015, 760), "portraits/theo_portrait.png", (96, 96))
    save_asset("pixel 5.png", (870, 680, 1095, 875), "portraits/rell_portrait.png", (96, 96))
    save_asset("pixel 6.png", (350, 750, 575, 965), "portraits/lina_portrait.png", (96, 96))

    # Village and dream repeating tiles.
    save_tile("pixel 7.png", (28, 36, 184, 185), "sprites/tiles/floor_grass.png")
    save_tile("pixel 7.png", (197, 38, 323, 185), "sprites/tiles/floor_path.png")
    save_tile("pixel 8.png", (40, 55, 175, 190), "sprites/tiles/floor_dream.png")
    save_tile("pixel 8.png", (835, 675, 925, 790), "sprites/tiles/wall_dream.png")
    save_tile("pixel 7.png", (420, 50, 575, 245), "sprites/tiles/wall_house.png")

    # Village decorations used directly by Village.tscn.
    save_asset("pixel 7.png", (20, 380, 185, 575), "sprites/tiles/tree_large.png", (72, 72))
    save_asset("pixel 7.png", (545, 45, 740, 280), "sprites/tiles/house_front.png", (80, 96))
    save_asset("pixel 7.png", (1060, 55, 1290, 245), "sprites/tiles/house_roof.png", (96, 64))

    # Tutorial and inventory props.
    save_asset("pixel 7.png", (350, 455, 425, 590), "sprites/items/lamp_off.png", (32, 48))
    lamp_on = transparent_crop(SOURCE / "pixel 7.png", (350, 455, 425, 590), (32, 48))
    lamp_on = ImageEnhance.Brightness(lamp_on).enhance(1.25)
    lamp_on.save(OUT / "sprites/items/lamp_on.png")
    print(f"sprites/items/lamp_on.png: {lamp_on.size}")

    save_asset("pixel 9.png", (970, 275, 1210, 455), "sprites/items/paper_clue.png", (48, 48))
    save_asset("pixel 9.png", (1160, 55, 1360, 290), "sprites/items/mirror_frame_empty.png", (48, 64))
    save_asset("pixel 8.png", (895, 65, 1015, 260), "sprites/items/mirror_filled.png", (48, 64))
    save_asset("pixel 8.png", (850, 690, 1050, 855), "sprites/items/door_closed.png", (54, 64))
    save_asset("pixel 8.png", (540, 675, 735, 860), "sprites/items/door_open.png", (64, 72))
    save_asset("pixel 9.png", (760, 285, 910, 450), "sprites/items/flower.png", (40, 48))
    save_asset("pixel 9.png", (800, 515, 970, 700), "sprites/items/pocket_watch.png", (48, 48))
    save_asset("pixel 9.png", (75, 285, 265, 470), "sprites/items/mask.png", (48, 48))
    save_asset("pixel 9.png", (500, 525, 710, 675), "sprites/items/paper_plane.png", (48, 40))
    save_asset("pixel 9.png", (985, 510, 1145, 675), "sprites/items/clock_hand.png", (48, 48))
    save_asset("pixel 9.png", (575, 725, 760, 875), "sprites/items/music_box.png", (48, 48))
    save_asset("pixel 9.png", (1135, 725, 1265, 880), "sprites/items/key_brass.png", (40, 48))
    save_asset("pixel 9.png", (45, 725, 260, 930), "sprites/items/letter.png", (48, 48))


if __name__ == "__main__":
    main()
