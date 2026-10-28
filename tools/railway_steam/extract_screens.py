"""Extract unaltered gameplay frames from the reproducible movie captures."""
import pathlib
import struct
import cv2

BASE = pathlib.Path(__file__).resolve().parents[2] / 'FeedingABlackHoldGame/StoreAssets_RailwayFury/steam'
for edition, filename, times in [('full', 'gameplay-trailer.mp4', [2,6,12,16,23,31]),
                                  ('demo', 'demo-gameplay-trailer.mp4', [3,9,15,21,27,33])]:
    video = cv2.VideoCapture(str(BASE/'trailer'/filename))
    target = BASE/'screenshots'/edition
    target.mkdir(parents=True, exist_ok=True)
    for index, seconds in enumerate(times, 1):
        video.set(cv2.CAP_PROP_POS_MSEC, seconds*1000)
        ok, frame = video.read()
        if not ok:
            raise RuntimeError(f'Missing {edition} frame at {seconds}s')
        cv2.imwrite(str(target/f'{index:02d}-gameplay.png'), frame)
    video.release()

# ICO is a container of the existing PNG exports, without modifying their pixels.
layers = [(size, (BASE/'capsules'/f'icon_{size}.png').read_bytes()) for size in [16,32,48,256]]
header = struct.pack('<HHH', 0, 1, len(layers))
offset = 6+16*len(layers)
entries, payload = b'', b''
for size, png in layers:
    entries += struct.pack('<BBBBHHII', size%256, size%256, 0, 0, 1, 32, len(png), offset)
    payload += png
    offset += len(png)
(BASE/'capsules'/'shortcut.ico').write_bytes(header+entries+payload)
print('Extracted 12 untouched gameplay frames and packaged Steam shortcut icon.')
