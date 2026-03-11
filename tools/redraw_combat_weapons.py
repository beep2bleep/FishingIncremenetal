from pathlib import Path

import cv2
import numpy as np


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "FeedingABlackHoldGame" / "Art" / "CombatWeapons"
SCALE = 4


def canvas(width: int, height: int) -> np.ndarray:
    return np.zeros((height * SCALE, width * SCALE, 4), dtype=np.uint8)


def pt(x: float, y: float) -> tuple[int, int]:
    return int(round(x * SCALE)), int(round(y * SCALE))


def fill_poly(img: np.ndarray, points: list[tuple[float, float]], color: tuple[int, int, int, int]) -> None:
    arr = np.array([pt(x, y) for x, y in points], dtype=np.int32)
    cv2.fillConvexPoly(img, arr, color, lineType=cv2.LINE_AA)


def fill_rect(img: np.ndarray, x1: float, y1: float, x2: float, y2: float, color: tuple[int, int, int, int]) -> None:
    cv2.rectangle(img, pt(x1, y1), pt(x2, y2), color, thickness=-1, lineType=cv2.LINE_AA)


def draw_line(
    img: np.ndarray,
    start: tuple[float, float],
    end: tuple[float, float],
    color: tuple[int, int, int, int],
    thickness: float,
) -> None:
    cv2.line(img, pt(*start), pt(*end), color, thickness=max(1, int(round(thickness * SCALE))), lineType=cv2.LINE_AA)


def draw_circle(img: np.ndarray, center: tuple[float, float], radius: float, color: tuple[int, int, int, int]) -> None:
    cv2.circle(img, pt(*center), int(round(radius * SCALE)), color, thickness=-1, lineType=cv2.LINE_AA)


def export(img: np.ndarray, name: str, size: tuple[int, int]) -> None:
    width, height = size
    downscaled = cv2.resize(img, (width, height), interpolation=cv2.INTER_AREA)
    cv2.imwrite(str(OUT_DIR / name), downscaled)


def make_arrow() -> None:
    img = canvas(660, 170)
    shaft = (110, 85)

    fill_rect(img, 140, 58, 535, 80, (145, 92, 44, 255))
    fill_rect(img, 140, 80, 535, 98, (167, 113, 63, 255))
    fill_poly(img, [(88, 23), (148, 23), (204, 85), (88, 85)], (61, 72, 156, 255))
    fill_poly(img, [(88, 23), (140, 23), (194, 80), (88, 80)], (73, 82, 176, 255))
    fill_poly(img, [(88, 147), (148, 147), (204, 85), (88, 85)], (43, 59, 138, 255))
    fill_poly(img, [(88, 147), (140, 147), (194, 90), (88, 90)], (56, 69, 155, 255))
    fill_poly(img, [(540, 43), (592, 55), (632, 85), (592, 117), (540, 128), (562, 85)], (211, 216, 226, 255))
    fill_poly(img, [(550, 48), (596, 58), (626, 85), (596, 112), (550, 120), (572, 85)], (235, 239, 245, 255))
    fill_rect(img, 140, 66, 535, 74, (126, 75, 31, 255))
    fill_rect(img, 140, 81, 535, 89, (186, 130, 77, 255))
    export(img, "arrow.png", (660, 170))


def make_bow() -> None:
    img = canvas(630, 210)
    limb_back = (56, 120, 173, 255)
    limb_front = (74, 142, 199, 255)
    grip_dark = (162, 120, 52, 255)
    grip_light = (202, 156, 66, 255)

    draw_line(img, (32, 160), (154, 42), limb_back, 24)
    draw_line(img, (154, 42), (474, 42), limb_back, 24)
    draw_line(img, (474, 42), (596, 160), limb_back, 24)
    draw_line(img, (32, 160), (154, 42), limb_front, 16)
    draw_line(img, (154, 42), (474, 42), limb_front, 16)
    draw_line(img, (474, 42), (596, 160), limb_front, 16)

    draw_line(img, (28, 162), (602, 162), (188, 198, 214, 255), 4)
    draw_line(img, (28, 162), (602, 162), (235, 240, 247, 255), 2)

    fill_rect(img, 220, 28, 254, 83, grip_dark)
    fill_rect(img, 224, 28, 250, 83, grip_light)
    fill_rect(img, 376, 28, 410, 83, grip_dark)
    fill_rect(img, 380, 28, 406, 83, grip_light)
    export(img, "bow.png", (630, 210))


def make_shield() -> None:
    img = canvas(330, 360)
    outer = [(165, 10), (297, 86), (297, 272), (165, 350), (33, 272), (33, 86)]
    inner = [(165, 31), (277, 96), (277, 260), (165, 327), (53, 260), (53, 96)]
    left_face = np.array([pt(x, y) for x, y in [(165, 31), (53, 96), (53, 260), (165, 327)]], dtype=np.int32)
    right_face = np.array([pt(x, y) for x, y in [(165, 31), (277, 96), (277, 260), (165, 327)]], dtype=np.int32)

    fill_poly(img, outer, (134, 62, 28, 255))
    fill_poly(img, inner, (177, 91, 45, 255))
    cv2.fillConvexPoly(img, left_face, (188, 103, 53, 255), lineType=cv2.LINE_AA)
    cv2.fillConvexPoly(img, right_face, (162, 78, 39, 255), lineType=cv2.LINE_AA)

    star = np.array(
        [pt(x, y) for x, y in [(165, 92), (186, 147), (244, 168), (186, 188), (165, 255), (144, 188), (86, 168), (144, 147)]],
        dtype=np.int32,
    )
    cv2.fillConvexPoly(img, star, (72, 184, 230, 255), lineType=cv2.LINE_AA)
    highlight = np.array(
        [pt(x, y) for x, y in [(165, 106), (180, 151), (228, 168), (180, 184), (165, 236), (150, 184), (102, 168), (150, 151)]],
        dtype=np.int32,
    )
    cv2.fillConvexPoly(img, highlight, (102, 218, 255, 255), lineType=cv2.LINE_AA)
    export(img, "shield.png", (330, 360))


def make_sword() -> None:
    img = canvas(620, 190)
    fill_rect(img, 24, 58, 56, 146, (150, 96, 52, 255))
    fill_rect(img, 56, 78, 164, 126, (127, 80, 39, 255))
    fill_rect(img, 56, 84, 164, 120, (160, 104, 57, 255))
    fill_rect(img, 160, 28, 194, 164, (154, 98, 52, 255))
    fill_rect(img, 164, 28, 190, 164, (182, 120, 66, 255))
    fill_poly(img, [(194, 42), (548, 42), (604, 95), (548, 148), (194, 148)], (194, 201, 214, 255))
    fill_poly(img, [(194, 56), (532, 56), (584, 95), (532, 134), (194, 134)], (236, 240, 247, 255))
    draw_line(img, (206, 95), (562, 95), (218, 224, 232, 255), 3)
    export(img, "sword.png", (620, 190))


def make_wand() -> None:
    img = canvas(520, 160)
    fill_rect(img, 26, 62, 388, 88, (126, 76, 40, 255))
    fill_rect(img, 26, 68, 388, 82, (156, 99, 57, 255))
    fill_rect(img, 380, 50, 414, 100, (194, 152, 66, 255))
    fill_rect(img, 384, 50, 410, 100, (228, 185, 82, 255))
    draw_circle(img, (426, 96), 36, (132, 74, 214, 255))
    draw_circle(img, (450, 84), 38, (220, 176, 74, 255))
    draw_circle(img, (458, 68), 42, (54, 150, 228, 255))
    draw_circle(img, (452, 56), 14, (170, 156, 242, 255))
    export(img, "wand.png", (520, 160))


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    make_arrow()
    make_bow()
    make_shield()
    make_sword()
    make_wand()


if __name__ == "__main__":
    main()
