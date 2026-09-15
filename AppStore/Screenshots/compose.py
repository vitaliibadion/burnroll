#!/usr/bin/env python3
"""Compose 1320×2868 App Store marketing frames from Simulator captures."""

from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

from locale_copy import EMPHASIS, FRAMES, OUTPUT_NAMES, STORE_LOCALES

ROOT = Path(__file__).resolve().parent
CAPTURES = ROOT / "captures"
OUTPUT = ROOT
WIDTH, HEIGHT = 1320, 2868

CREAM = (250, 245, 232)
INK = (28, 24, 20)
BURN = (245, 69, 20)
BURN_DARK = (22, 8, 5)
KEEP = (41, 168, 92)
KEEP_DARK = (6, 36, 20)
EMBER = (255, 133, 20)
DARK = (12, 11, 10)
PAPER = (255, 252, 245)
MUTED_LIGHT = (92, 84, 76)
MUTED_DARK = (210, 198, 184)
FRAME_PATH = ROOT / "frames" / "iphone-16-pro-black.png"
# Key the 720px chassis at 3× so the final LANCZOS downscale anti-aliases curves.
FRAME_UPSCALE = 3
_frame_assets: tuple[Image.Image, Image.Image, tuple[int, int, int, int]] | None = None


def font(size: int, weight: str = "bold", locale: str = "en") -> ImageFont.FreeTypeFont:
    cjk = {
        "ja": {
            "black": ["/System/Library/Fonts/ヒラギノ角ゴシック W8.ttc", "/System/Library/Fonts/Hiragino Sans GB.ttc"],
            "bold": ["/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc", "/System/Library/Fonts/Hiragino Sans GB.ttc"],
            "regular": ["/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc", "/System/Library/Fonts/Hiragino Sans GB.ttc"],
        },
        "zh-Hans": {
            "black": ["/System/Library/Fonts/PingFang.ttc", "/System/Library/Fonts/STHeiti Medium.ttc"],
            "bold": ["/System/Library/Fonts/PingFang.ttc", "/System/Library/Fonts/STHeiti Medium.ttc"],
            "regular": ["/System/Library/Fonts/PingFang.ttc", "/System/Library/Fonts/STHeiti Light.ttc"],
        },
        "ko": {
            "black": ["/System/Library/Fonts/AppleSDGothicNeo.ttc"],
            "bold": ["/System/Library/Fonts/AppleSDGothicNeo.ttc"],
            "regular": ["/System/Library/Fonts/AppleSDGothicNeo.ttc"],
        },
    }
    latin = {
        "black": [
            "/System/Library/Fonts/Supplemental/Arial Black.ttf",
            "/System/Library/Fonts/Supplemental/Impact.ttf",
        ],
        "bold": [
            "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
            "/Library/Fonts/Arial Bold.ttf",
        ],
        "regular": [
            "/System/Library/Fonts/Supplemental/Arial.ttf",
            "/Library/Fonts/Arial.ttf",
        ],
    }
    extra = []
    if locale in {"uk", "pl"}:
        extra = [
            "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
            "/Library/Fonts/Arial Unicode.ttf",
        ]
    candidates = cjk.get(locale, {}).get(weight, []) + extra + latin[weight]
    for path in candidates:
        if Path(path).exists():
            try:
                return ImageFont.truetype(path, size, index=0)
            except OSError:
                continue
    return ImageFont.load_default()


def _is_chroma_green(red: int, green: int, blue: int) -> bool:
    return green >= 70 and green > red + 18 and green > blue + 18


def _is_studio_backdrop(red: int, green: int, blue: int) -> bool:
    luma = 0.299 * red + 0.587 * green + 0.114 * blue
    sat = max(red, green, blue) - min(red, green, blue)
    return luma >= 165 and sat <= 48


def _flood_mask(
    src_px,
    width: int,
    height: int,
    starts: list[tuple[int, int]],
    keep,
) -> Image.Image:
    mask = Image.new("L", (width, height), 0)
    mask_px = mask.load()
    seen = bytearray(width * height)
    queue: deque[tuple[int, int]] = deque()

    def try_enqueue(x: int, y: int) -> None:
        index = y * width + x
        if seen[index]:
            return
        red, green, blue, _alpha = src_px[x, y]
        if not keep(red, green, blue):
            return
        seen[index] = 1
        queue.append((x, y))

    for x, y in starts:
        try_enqueue(x, y)
    while queue:
        x, y = queue.popleft()
        mask_px[x, y] = 255
        if x > 0:
            try_enqueue(x - 1, y)
        if x + 1 < width:
            try_enqueue(x + 1, y)
        if y > 0:
            try_enqueue(x, y - 1)
        if y + 1 < height:
            try_enqueue(x, y + 1)
    return mask


def _feather(mask: Image.Image, radius: float) -> Image.Image:
    return mask.filter(ImageFilter.GaussianBlur(radius))


def _smooth_screen_hole(mask: Image.Image, inset: int = 2) -> Image.Image:
    """Replace the keyed hole with a high-res rounded rect so inner corners stay smooth."""
    box = mask.getbbox()
    if box is None:
        return mask
    x0, y0, x1, y1 = box
    width = max(1, x1 - x0)
    radius = max(24, round(width * 0.135))
    hole = Image.new("L", mask.size, 0)
    ImageDraw.Draw(hole).rounded_rectangle(
        (x0 + inset, y0 + inset, x1 - 1 - inset, y1 - 1 - inset),
        radius=radius,
        fill=255,
    )
    return _feather(hole, 1.4)


def load_device_frame() -> tuple[Image.Image, Image.Image, tuple[int, int, int, int]]:
    """Photorealistic iPhone: metal overlay, no studio shadow, screen tucked under the bezel."""
    global _frame_assets
    if _frame_assets is not None:
        return _frame_assets

    src = Image.open(FRAME_PATH).convert("RGBA")
    src = src.resize(
        (src.width * FRAME_UPSCALE, src.height * FRAME_UPSCALE),
        Image.Resampling.LANCZOS,
    )
    width, height = src.size
    src_px = src.load()

    green_starts: list[tuple[int, int]] = []
    for y in (height // 2, height // 3, (height * 2) // 3):
        for x in (width // 2, width // 3, (width * 2) // 3):
            red, green, blue, _alpha = src_px[x, y]
            if _is_chroma_green(red, green, blue):
                green_starts.append((x, y))
    screen_mask = _flood_mask(src_px, width, height, green_starts, _is_chroma_green)
    # Pull the capture under the inner bezel so leftover green/white fringe cannot cut the UI.
    screen_mask = screen_mask.filter(ImageFilter.MaxFilter(1 + 4 * FRAME_UPSCALE))

    border: list[tuple[int, int]] = []
    border.extend((x, 0) for x in range(width))
    border.extend((x, height - 1) for x in range(width))
    border.extend((0, y) for y in range(height))
    border.extend((width - 1, y) for y in range(height))
    backdrop = _flood_mask(src_px, width, height, border, _is_studio_backdrop)

    overlay = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    over_px = overlay.load()
    screen_px = screen_mask.load()
    back_px = backdrop.load()
    for y in range(height):
        for x in range(width):
            if screen_px[x, y] or back_px[x, y]:
                continue
            red, green, blue, _alpha = src_px[x, y]
            if _is_studio_backdrop(red, green, blue):
                continue
            over_px[x, y] = (red, green, blue, 255)

    # White/gray anti-aliasing between glass and metal becomes screen, not a cut over the UI.
    for y in range(height):
        for x in range(width):
            red, green, blue, alpha = over_px[x, y]
            if alpha == 0:
                continue
            luma = 0.299 * red + 0.587 * green + 0.114 * blue
            if luma < 88:
                continue
            adjacent_screen = False
            if x > 0 and screen_px[x - 1, y]:
                adjacent_screen = True
            elif x + 1 < width and screen_px[x + 1, y]:
                adjacent_screen = True
            elif y > 0 and screen_px[x, y - 1]:
                adjacent_screen = True
            elif y + 1 < height and screen_px[x, y + 1]:
                adjacent_screen = True
            if adjacent_screen:
                over_px[x, y] = (0, 0, 0, 0)
                screen_px[x, y] = 255

    hole = screen_mask.getbbox()
    if hole is None:
        raise RuntimeError(f"Could not find the screen hole in {FRAME_PATH}")
    chin_pad = 7 * FRAME_UPSCALE
    for y in range(height):
        for x in range(width):
            red, green, blue, alpha = over_px[x, y]
            if alpha == 0:
                continue
            luma = 0.299 * red + 0.587 * green + 0.114 * blue
            sat = max(red, green, blue) - min(red, green, blue)
            studio_fringe = luma >= 90 and sat <= 55
            below_chin = y > hole[3] + chin_pad
            if (y >= hole[3] - 6 * FRAME_UPSCALE and studio_fringe) or below_chin:
                over_px[x, y] = (0, 0, 0, 0)

    chassis_bottom = 0
    for y in range(height):
        for x in range(width):
            if over_px[x, y][3]:
                chassis_bottom = y
    for y in range(max(0, chassis_bottom - 8 * FRAME_UPSCALE), height):
        for x in range(width):
            screen_px[x, y] = 0

    content = ImageChops.lighter(overlay.split()[-1], screen_mask)
    crop_box = content.getbbox()
    if crop_box is None:
        raise RuntimeError(f"Could not isolate the iPhone chassis in {FRAME_PATH}")
    overlay = overlay.crop(crop_box)
    screen_mask = screen_mask.crop(crop_box)
    screen_mask = _smooth_screen_hole(screen_mask)
    red, green, blue, alpha = overlay.split()
    overlay = Image.merge("RGBA", (red, green, blue, _feather(alpha, 1.15)))
    hole = screen_mask.getbbox()
    if hole is None:
        raise RuntimeError(f"Could not find the screen hole in {FRAME_PATH}")

    _frame_assets = (overlay, screen_mask, hole)
    return _frame_assets


def framed_iphone(capture: Path, device_height: int, metal: str = "black") -> Image.Image:
    """Sit a Simulator screenshot inside the photorealistic iPhone chassis."""
    del metal  # One photographed black-titanium frame; lighting matches the example.
    overlay, screen_mask, bbox = load_device_frame()
    # Composite at the 3× chassis, then downscale so curves stay anti-aliased.
    work_h = max(device_height * 2, overlay.height)
    work_scale = work_h / overlay.height
    work_size = (max(1, round(overlay.width * work_scale)), max(1, round(overlay.height * work_scale)))
    overlay_s = overlay.resize(work_size, Image.Resampling.LANCZOS)
    mask_s = screen_mask.resize(work_size, Image.Resampling.LANCZOS)
    x0, y0, x1, y1 = (round(v * work_scale) for v in bbox)
    screen_w = max(1, x1 - x0)
    screen_h = max(1, y1 - y0)

    shot = Image.open(capture).convert("RGB").resize((screen_w, screen_h), Image.Resampling.LANCZOS)
    base = Image.new("RGBA", work_size, (0, 0, 0, 0))
    base.paste(shot, (x0, y0))
    red, green, blue, alpha = base.split()
    base = Image.merge("RGBA", (red, green, blue, ImageChops.multiply(alpha, mask_s)))
    phone = Image.alpha_composite(base, overlay_s)
    final = (
        max(1, round(phone.width * device_height / phone.height)),
        device_height,
    )
    return phone.resize(final, Image.Resampling.LANCZOS)


def drop_shadow(
    image: Image.Image,
    offset: tuple[int, int] = (0, 18),
    blur: int = 22,
    opacity: float = 0.22,
) -> Image.Image:
    pad = blur * 2 + max(abs(offset[0]), abs(offset[1]))
    canvas = Image.new("RGBA", (image.width + pad * 2, image.height + pad * 2), (0, 0, 0, 0))
    alpha = image.split()[-1]
    shadow = Image.new("RGBA", image.size, (0, 0, 0, 0))
    shadow.putalpha(alpha.point(lambda p: int(p * opacity)))
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur))
    canvas.alpha_composite(shadow, (pad + offset[0], pad + offset[1] + 6))
    canvas.alpha_composite(image, (pad, pad))
    return canvas


def wrap(
    draw: ImageDraw.ImageDraw,
    text: str,
    typeface: ImageFont.FreeTypeFont,
    max_width: int,
    locale: str = "en",
) -> list[str]:
    if locale in {"ja", "zh-Hans", "ko"}:
        lines: list[str] = []
        current = ""
        for char in text:
            trial = current + char
            if draw.textlength(trial, font=typeface) <= max_width:
                current = trial
            else:
                if current:
                    lines.append(current)
                current = char
        if current:
            lines.append(current)
        return lines or [text]
    words = text.split()
    lines: list[str] = []
    current = ""
    for word in words:
        trial = word if not current else f"{current} {word}"
        if draw.textlength(trial, font=typeface) <= max_width:
            current = trial
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines or [text]


def paint_background(
    base: Image.Image,
    color: tuple[int, int, int],
    accent: tuple[int, int, int] | None = None,
    bottom_blob: bool = True,
) -> None:
    ImageDraw.Draw(base).rectangle((0, 0, WIDTH, HEIGHT), fill=color)
    if not accent:
        return
    blob = Image.new("RGBA", (WIDTH, HEIGHT), (0, 0, 0, 0))
    bdraw = ImageDraw.Draw(blob)
    if bottom_blob:
        bdraw.ellipse((-240, HEIGHT - 1100, WIDTH + 220, HEIGHT + 480), fill=accent + (48,))
    bdraw.ellipse((WIDTH - 820, -480, WIDTH + 420, 760), fill=accent + (36,))
    base.alpha_composite(blob)


ROLE_COLORS = {
    "ink": INK,
    "burn": BURN,
    "keep": KEEP,
    "paper": PAPER,
    "ember": EMBER,
}


def draw_title_lines(
    base: Image.Image,
    lines: list[list[tuple[str, tuple[int, int, int]]]],
    subtitle: str,
    muted: tuple[int, int, int],
    top: int = 92,
    locale: str = "en",
) -> int:
    draw = ImageDraw.Draw(base)
    title_font = font(88 if locale not in {"ja", "zh-Hans", "ko"} else 78, "black", locale)
    sub_font = font(56 if locale not in {"ja", "zh-Hans", "ko"} else 48, "regular", locale)
    sub_bold = font(56 if locale not in {"ja", "zh-Hans", "ko"} else 48, "bold", locale)
    y = top
    for line in lines:
        x = 56
        for text, color in line:
            if color not in {INK, PAPER}:
                blob = Image.new("RGBA", (WIDTH, 130), (0, 0, 0, 0))
                ImageDraw.Draw(blob).text((x, 16), text, font=title_font, fill=color + (80,))
                blob = blob.filter(ImageFilter.GaussianBlur(12))
                base.alpha_composite(blob, (0, y - 16))
                draw = ImageDraw.Draw(base)
            draw.text((x, y), text, font=title_font, fill=color)
            x += int(draw.textlength(text, font=title_font))
        y += 96 if locale not in {"ja", "zh-Hans", "ko"} else 102
    y += 18
    for line in wrap(draw, subtitle, sub_font, WIDTH - 72, locale):
        cursor = 56
        parts = split_emphasis(line, locale)
        for part, kind in parts:
            fill = {"keep": KEEP, "burn": BURN, "plain": muted}[kind]
            weight = sub_font if kind == "plain" else sub_bold
            draw.text((cursor, y), part, font=weight, fill=fill)
            cursor += int(draw.textlength(part, font=weight))
        y += 68
    return y


def split_emphasis(line: str, locale: str = "en") -> list[tuple[str, str]]:
    keep_words = EMPHASIS.get(locale, EMPHASIS["en"])["keep"]
    burn_words = EMPHASIS.get(locale, EMPHASIS["en"])["burn"]
    if locale in {"ja", "zh-Hans", "ko"}:
        out: list[tuple[str, str]] = [(line, "plain")]
        for kind, words in (("keep", keep_words), ("burn", burn_words)):
            next_out: list[tuple[str, str]] = []
            for chunk, current in out:
                if current != "plain":
                    next_out.append((chunk, current))
                    continue
                remaining = chunk
                while remaining:
                    hit = next(((w, remaining.find(w)) for w in words if remaining.find(w) >= 0), None)
                    if not hit:
                        next_out.append((remaining, "plain"))
                        break
                    word, index = min(
                        ((w, remaining.find(w)) for w in words if remaining.find(w) >= 0),
                        key=lambda item: item[1],
                    )
                    if index > 0:
                        next_out.append((remaining[:index], "plain"))
                    next_out.append((word, kind))
                    remaining = remaining[index + len(word):]
            out = next_out
        return out or [(line, "plain")]
    words = line.split(" ")
    out = []
    for index, word in enumerate(words):
        bare = word.strip(".,;—-").lower()
        kind = "plain"
        if bare in keep_words:
            kind = "keep"
        elif bare in burn_words:
            kind = "burn"
        prefix = "" if index == 0 else " "
        out.append((prefix + word, kind))
    return out or [(line, "plain")]


def tilt_phone(phone: Image.Image, degrees: float) -> Image.Image:
    if abs(degrees) < 0.05:
        return phone
    return phone.rotate(degrees, resample=Image.Resampling.BICUBIC, expand=True)


def _perspective_coeffs(
    source: list[tuple[float, float]],
    dest: list[tuple[float, float]],
) -> list[float]:
    """8 coefficients mapping dest pixels back to source (PIL PERSPECTIVE)."""
    matrix = []
    vector: list[float] = []
    for (xs, ys), (xd, yd) in zip(source, dest):
        matrix.append([xd, yd, 1, 0, 0, 0, -xs * xd, -xs * yd])
        vector.append(xs)
        matrix.append([0, 0, 0, xd, yd, 1, -ys * xd, -ys * yd])
        vector.append(ys)
    n = 8
    a = [row[:] + [vector[i]] for i, row in enumerate(matrix)]
    for col in range(n):
        pivot = max(range(col, n), key=lambda r: abs(a[r][col]))
        a[col], a[pivot] = a[pivot], a[col]
        div = a[col][col] or 1e-12
        for j in range(col, n + 1):
            a[col][j] /= div
        for row in range(n):
            if row == col:
                continue
            factor = a[row][col]
            for j in range(col, n + 1):
                a[row][j] -= factor * a[col][j]
    return [a[i][n] for i in range(n)]


def pose_phone(phone: Image.Image, pose: str) -> Image.Image:
    """straight = front-on. depth_left / depth_right = slight 3D yaw that shows the side."""
    if pose == "straight":
        return phone
    width, height = phone.size
    pad = int(max(width, height) * 0.10)
    canvas = Image.new("RGBA", (width + pad * 2, height + pad * 2), (0, 0, 0, 0))
    canvas.paste(phone, (pad, pad))
    left, top = pad, pad
    right, bottom = pad + width, pad + height
    source = [(left, top), (right, top), (right, bottom), (left, bottom)]
    inset = int(width * 0.14)
    drop = int(height * 0.08)
    if pose == "depth_right":
        dest = [
            (left + int(width * 0.02), top + drop),
            (right - inset, top + int(drop * 1.55)),
            (right - int(inset * 0.35), bottom - int(drop * 0.22)),
            (left, bottom - int(drop * 0.08)),
        ]
    else:
        dest = [
            (left + inset, top + int(drop * 1.55)),
            (right - int(width * 0.02), top + drop),
            (right, bottom - int(drop * 0.08)),
            (left + int(inset * 0.35), bottom - int(drop * 0.22)),
        ]
    coeffs = _perspective_coeffs(source, dest)
    warped = canvas.transform(
        canvas.size,
        Image.Transform.PERSPECTIVE,
        coeffs,
        Image.Resampling.BICUBIC,
    )
    box = warped.getbbox()
    warped = warped.crop(box) if box else warped
    spin = -6.5 if pose == "depth_right" else 6.5
    return warped.rotate(spin, resample=Image.Resampling.BICUBIC, expand=True)


def place_phone(base: Image.Image, phone: Image.Image, y: int, x: int | None = None) -> None:
    shadowed = drop_shadow(phone, offset=(0, 22), blur=26)
    if x is None:
        x = (WIDTH - shadowed.width) // 2
    base.alpha_composite(shadowed, (x, y))


def colored_title(frame: dict) -> list[list[tuple[str, tuple[int, int, int]]]]:
    return [
        [(text, ROLE_COLORS[role]) for text, role in line]
        for line in frame["title"]
    ]


def compose_single(
    capture: Path,
    output: Path,
    title: list[list[tuple[str, tuple[int, int, int]]]],
    subtitle: str,
    background: tuple[int, int, int],
    accent: tuple[int, int, int] | None,
    muted: tuple[int, int, int],
    metal: str,
    device_height: int = 1980,
    pose: str = "straight",
    locale: str = "en",
) -> None:
    base = Image.new("RGBA", (WIDTH, HEIGHT), background + (255,))
    paint_background(base, background, accent)
    text_bottom = draw_title_lines(base, title, subtitle, muted, locale=locale)
    phone = pose_phone(framed_iphone(capture, device_height, metal=metal), pose)
    shadowed_h = phone.height + 64
    y = min(text_bottom + 36, HEIGHT - shadowed_h - 28)
    y = max(y, text_bottom + 16)
    place_phone(base, phone, y)
    output.parent.mkdir(parents=True, exist_ok=True)
    base.convert("RGB").save(output, "PNG", optimize=True)


def compose_dual(keep: Path, burn: Path, output: Path, locale: str = "en") -> None:
    frame = FRAMES[locale]["01"]
    base = Image.new("RGBA", (WIDTH, HEIGHT), CREAM + (255,))
    paint_background(base, CREAM, BURN, bottom_blob=False)
    text_bottom = draw_title_lines(
        base,
        colored_title(frame),
        frame["subtitle"],
        MUTED_LIGHT,
        top=72,
        locale=locale,
    )
    keep_phone = pose_phone(framed_iphone(keep, 1280, metal="black"), "straight")
    burn_phone = pose_phone(framed_iphone(burn, 1280, metal="black"), "straight")
    keep_s = drop_shadow(keep_phone, offset=(0, 12), blur=16, opacity=0.16)
    burn_s = drop_shadow(burn_phone, offset=(0, 12), blur=16, opacity=0.16)
    stagger = 52
    overlap = int(min(burn_s.width, keep_s.width) * 0.40)
    pair_w = burn_s.width + keep_s.width - overlap
    pair_h = max(burn_s.height, keep_s.height) + stagger
    pair = Image.new("RGBA", (pair_w, pair_h), (0, 0, 0, 0))
    pair.alpha_composite(burn_s, (0, stagger))
    pair.alpha_composite(keep_s, (burn_s.width - overlap, 0))
    margin = 40
    avail_w = WIDTH - margin * 2
    avail_h = HEIGHT - text_bottom - margin
    scale = min(1.0, avail_w / pair.width, avail_h / pair.height)
    if scale < 0.995:
        pair = pair.resize(
            (max(1, round(pair.width * scale)), max(1, round(pair.height * scale))),
            Image.Resampling.LANCZOS,
        )
    x = (WIDTH - pair.width) // 2
    y = text_bottom + (avail_h - pair.height) // 2
    base.alpha_composite(pair, (x, y))
    output.parent.mkdir(parents=True, exist_ok=True)
    base.convert("RGB").save(output, "PNG", optimize=True)


def captures_for(locale: str) -> Path:
    localized = CAPTURES / locale
    if (localized / "03-keep.png").exists():
        return localized
    return CAPTURES


def compose_locale(locale: str) -> None:
    folder = OUTPUT if locale == "en" else OUTPUT / locale
    captures = captures_for(locale)
    frames = FRAMES[locale]
    compose_dual(
        captures / "03-keep.png",
        captures / "02-burn.png",
        folder / OUTPUT_NAMES["01"],
        locale=locale,
    )
    compose_single(
        captures / "02-burn.png",
        folder / OUTPUT_NAMES["02"],
        colored_title(frames["02"]),
        frames["02"]["subtitle"],
        BURN_DARK,
        BURN,
        MUTED_DARK,
        metal="black",
        device_height=1920,
        pose="straight",
        locale=locale,
    )
    compose_single(
        captures / "03-keep.png",
        folder / OUTPUT_NAMES["03"],
        colored_title(frames["03"]),
        frames["03"]["subtitle"],
        KEEP_DARK,
        KEEP,
        (186, 232, 204),
        metal="black",
        device_height=1920,
        pose="straight",
        locale=locale,
    )
    compose_single(
        captures / "04-review.png",
        folder / OUTPUT_NAMES["04"],
        colored_title(frames["04"]),
        frames["04"]["subtitle"],
        CREAM,
        EMBER,
        MUTED_LIGHT,
        metal="black",
        device_height=1800,
        pose="straight",
        locale=locale,
    )
    compose_single(
        captures / "05-privacy.png",
        folder / OUTPUT_NAMES["05"],
        colored_title(frames["05"]),
        frames["05"]["subtitle"],
        DARK,
        KEEP,
        MUTED_DARK,
        metal="black",
        device_height=1800,
        pose="straight",
        locale=locale,
    )
    compose_single(
        captures / "01-cleaner.png",
        folder / OUTPUT_NAMES["06"],
        colored_title(frames["06"]),
        frames["06"]["subtitle"],
        (46, 24, 10),
        EMBER,
        (255, 214, 168),
        metal="black",
        device_height=1920,
        pose="straight",
        locale=locale,
    )


def main() -> None:
    import sys

    locales = STORE_LOCALES
    if len(sys.argv) > 1:
        locales = sys.argv[1:]
        unknown = [locale for locale in locales if locale not in STORE_LOCALES]
        if unknown:
            raise SystemExit(f"Unknown locale(s): {', '.join(unknown)}")
    for locale in locales:
        compose_locale(locale)
        print("Wrote", locale)
    print("Wrote marketing frames to", OUTPUT)


if __name__ == "__main__":
    main()
