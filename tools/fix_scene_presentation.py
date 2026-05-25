from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCENES = ROOT / "scenes"

FONT_SIZE = 8
TITLE_SIZE = 12
BUTTON_SIZE = 9
RICH_TEXT_SIZE = 9


NODE_RE = re.compile(r'^\[node name="(?P<name>[^"]+)" type="(?P<type>[^"]+)"(?: parent="(?P<parent>[^"]*)")?.*\]$')
SCALE_RE = re.compile(r"scale = Vector2\((?P<x>[-0-9.]+), (?P<y>[-0-9.]+)\)")


def strip_props(lines: list[str], prefixes: tuple[str, ...]) -> list[str]:
    return [line for line in lines if not line.startswith(prefixes)]


def insert_after_header(block: list[str], props: list[str]) -> list[str]:
    return [block[0], *props, *block[1:]]


def is_world_label(name: str, parent: str) -> bool:
    if parent.startswith("HintHUD") or parent.startswith("Panel") or parent.startswith("VBoxContainer"):
        return False
    if name in {"Prompt", "NameLabel", "HintLabel"}:
        return True
    if name == "Label" and parent not in {"", "."}:
        return True
    return False


def sprite_scale(name: str, parent: str, x: float, y: float) -> tuple[float, float] | None:
    if name in {"Floor", "Path"}:
        return None
    if name.startswith("Wall"):
        return None
    if parent == "Decorations" and name.startswith("Tree"):
        return (0.55, 0.55)
    if parent == "Decorations" and name.startswith("House"):
        return (0.55, 0.55)
    if name in {"GlowVisual"}:
        return (0.7, 0.7)
    if max(abs(x), abs(y)) <= 1.2:
        return None
    if name in {"Flower"}:
        return (1.2, 1.2)
    return (0.85, 0.85)


def fix_block(block: list[str]) -> list[str]:
    if not block:
        return block

    match = NODE_RE.match(block[0])
    if not match:
        return block

    name = match.group("name")
    node_type = match.group("type")
    parent = match.group("parent") or ""

    if node_type == "Label":
        block = strip_props(
            block,
            (
                "theme_override_font_sizes/font_size",
                "theme_override_colors/font_color",
                "theme_override_colors/font_outline_color",
                "theme_override_constants/outline_size",
                "clip_text",
                "autowrap_mode",
                "visible",
            ),
        )
        size = TITLE_SIZE if name in {"Title"} else FONT_SIZE
        props = [
            f"theme_override_font_sizes/font_size = {size}",
            "theme_override_colors/font_color = Color(1, 0.96, 0.86, 1)",
            "theme_override_colors/font_outline_color = Color(0.06, 0.04, 0.08, 1)",
            "theme_override_constants/outline_size = 2",
            "clip_text = true",
        ]
        if is_world_label(name, parent) and name != "Prompt":
            props.append("visible = false")
        if name == "Prompt":
            props.append("autowrap_mode = 2")
        return insert_after_header(block, props)

    if node_type == "RichTextLabel":
        block = strip_props(
            block,
            (
                "fit_content",
                "theme_override_font_sizes/normal_font_size",
                "theme_override_font_sizes/bold_font_size",
                "theme_override_colors/default_color",
                "theme_override_colors/font_outline_color",
                "theme_override_constants/outline_size",
                "scroll_active",
            ),
        )
        props = [
            f"theme_override_font_sizes/normal_font_size = {RICH_TEXT_SIZE}",
            f"theme_override_font_sizes/bold_font_size = {RICH_TEXT_SIZE}",
            "theme_override_colors/default_color = Color(1, 0.96, 0.86, 1)",
            "theme_override_colors/font_outline_color = Color(0.06, 0.04, 0.08, 1)",
            "theme_override_constants/outline_size = 2",
            "scroll_active = false",
        ]
        return insert_after_header(block, props)

    if node_type == "Button":
        block = strip_props(
            block,
            (
                "theme_override_font_sizes/font_size",
                "theme_override_colors/font_color",
                "custom_minimum_size",
            ),
        )
        props = [
            f"theme_override_font_sizes/font_size = {BUTTON_SIZE}",
            "theme_override_colors/font_color = Color(1, 0.96, 0.86, 1)",
            "custom_minimum_size = Vector2(120, 24)",
        ]
        return insert_after_header(block, props)

    if node_type == "TextureRect":
        block = strip_props(block, ("stretch_mode", "expand_mode"))
        props = [
            "expand_mode = 1",
            "stretch_mode = 5",
        ]
        return insert_after_header(block, props)

    if node_type == "Sprite2D":
        out: list[str] = []
        changed = False
        for line in block:
            scale_match = SCALE_RE.match(line)
            if scale_match:
                x = float(scale_match.group("x"))
                y = float(scale_match.group("y"))
                new_scale = sprite_scale(name, parent, x, y)
                if new_scale:
                    out.append(f"scale = Vector2({new_scale[0]}, {new_scale[1]})")
                    changed = True
                    continue
            out.append(line)
        return out if changed else block

    return block


def fix_scene(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    fixed: list[str] = []
    block: list[str] = []

    for line in lines:
        if line.startswith("[") and block:
            fixed.extend(fix_block(block))
            block = [line]
        else:
            block.append(line)
    if block:
        fixed.extend(fix_block(block))

    new_text = "\n".join(fixed) + "\n"
    if new_text != text:
        path.write_text(new_text, encoding="utf-8")
        print(path.relative_to(ROOT))


def main() -> None:
    for path in sorted(SCENES.rglob("*.tscn")):
        fix_scene(path)


if __name__ == "__main__":
    main()
