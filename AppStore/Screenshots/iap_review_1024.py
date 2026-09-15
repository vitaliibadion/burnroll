#!/usr/bin/env python3
"""Render a 1024×1024 App Review screenshot of the native plan picker."""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "iap-review-1024.png"
OUT_REVIEW = ROOT / "iap-review-screenshot.png"
SIZE = 1024

CREAM = (250, 245, 232)
PAPER = (255, 252, 245)
INK = (31, 27, 23)
MUTED = (99, 89, 79)
BURN = (245, 69, 20)
KEEP = (41, 168, 92)
EMBER = (255, 133, 20)
WHITE = (255, 255, 255)


def font(size: int, weight: str = "bold") -> ImageFont.FreeTypeFont:
    paths = {
        "heavy": "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "bold": "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "regular": "/System/Library/Fonts/Supplemental/Arial.ttf",
    }
    sf = {
        "heavy": "/System/Library/Fonts/SFNS.ttf",
        "bold": "/System/Library/Fonts/SFNS.ttf",
        "regular": "/System/Library/Fonts/SFNS.ttf",
    }
    for candidate in (sf.get(weight), paths[weight]):
        try:
            return ImageFont.truetype(candidate, size)
        except OSError:
            continue
    return ImageFont.load_default()


def rounded_rect(draw: ImageDraw.ImageDraw, box, fill, outline=None, width=1, radius=28):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def main() -> None:
    img = Image.new("RGB", (SIZE, SIZE), CREAM)
    draw = ImageDraw.Draw(img)

    title = "Choose your plan."
    title_font = font(42, "heavy")
    tw = draw.textlength(title, font=title_font)
    draw.text(((SIZE - tw) / 2, 36), title, font=title_font, fill=INK)

    banner = (48, 100, 976, 232)
    rounded_rect(draw, banner, (232, 246, 232), outline=(KEEP[0], KEEP[1], KEEP[2],), width=3, radius=32)
    check_font = font(28, "bold")
    draw.text((80, 122), "✓  Free trial selected", font=check_font, fill=KEEP)
    draw.text((80, 168), "3 days only. Cancel anytime.", font=font(22, "regular"), fill=MUTED)
    trial_font = font(44, "heavy")
    draw.text((820, 138), "$0.00", font=trial_font, fill=KEEP)

    plans = [
        ("Weekly", "3 days free, then $6.99 per week", "$6.99", True),
        ("Monthly", "Pay now · per month", "$14.99", False),
        ("Annually", "Pay now · per year", "$69.99", False),
    ]
    y = 256
    for name, subtitle, price, selected in plans:
        box = (48, y, 976, y + 132)
        fill = (255, 236, 228) if selected else PAPER
        outline = BURN if selected else (230, 222, 210)
        rounded_rect(draw, box, fill, outline=outline, width=3 if selected else 2, radius=28)
        draw.text((80, y + 28), name, font=font(28, "bold"), fill=INK)
        if name == "Annually":
            nw = draw.textlength(name, font=font(28, "bold"))
            badge = (80 + nw + 16, y + 30, 80 + nw + 16 + 118, y + 62)
            draw.rounded_rectangle(badge, radius=14, fill=EMBER)
            draw.text((badge[0] + 10, y + 36), "Best value", font=font(14, "bold"), fill=WHITE)
        draw.text((80, y + 78), subtitle, font=font(18, "regular"), fill=MUTED)
        pw = draw.textlength(price, font=font(28, "heavy"))
        draw.text((936 - pw, y + 48), price, font=font(28, "heavy"), fill=INK)
        y += 148

    cta = (48, y + 8, 976, y + 88)
    rounded_rect(draw, cta, BURN, radius=28)
    cta_label = "Start 3-day free trial"
    cw = draw.textlength(cta_label, font=font(26, "bold"))
    draw.text(((SIZE - cw) / 2, y + 32), cta_label, font=font(26, "bold"), fill=WHITE)

    restore = "Restore purchases"
    rw = draw.textlength(restore, font=font(18, "regular"))
    draw.text(((SIZE - rw) / 2, y + 108), restore, font=font(18, "regular"), fill=MUTED)

    img.save(OUT, "PNG")
    print(OUT)

    # App Review wants an iPhone screenshot size, not 1024×1024.
    review = Image.new("RGB", (1320, 2868), CREAM)
    scaled = img.resize((1180, 1180), Image.Resampling.LANCZOS)
    review.paste(scaled, (70, 420))
    rdraw = ImageDraw.Draw(review)
    legal = (
        "Payment is charged to your Apple Account after the 3-day trial. "
        "The plan renews automatically unless you cancel at least 24 hours "
        "before the period ends."
    )
    rdraw.text((120, 1680), "Privacy policy     Terms of Use", font=font(28, "bold"), fill=EMBER)
    # wrap legal
    words = legal.split()
    line = ""
    y_text = 1760
    body = font(24, "regular")
    for word in words:
        trial = f"{line} {word}".strip()
        if rdraw.textlength(trial, font=body) > 1080:
            rdraw.text((120, y_text), line, font=body, fill=MUTED)
            y_text += 36
            line = word
        else:
            line = trial
    if line:
        rdraw.text((120, y_text), line, font=body, fill=MUTED)
    review.save(OUT_REVIEW, "PNG")
    print(OUT_REVIEW)


if __name__ == "__main__":
    main()
