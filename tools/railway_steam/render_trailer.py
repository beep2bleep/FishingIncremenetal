"""Encode the actual Godot movie capture for Steam (1080p, H.264, AAC)."""
import pathlib
import subprocess
import argparse
import imageio_ffmpeg

parser = argparse.ArgumentParser()
parser.add_argument('--demo', action='store_true')
args = parser.parse_args()
ROOT = pathlib.Path(__file__).resolve().parents[2]
source = ROOT / ('Build - RailwayFury/Steam/Trailer/demo-gameplay.avi' if args.demo else 'Build - RailwayFury/Steam/Trailer/gameplay.avi')
output = ROOT / ('FeedingABlackHoldGame/StoreAssets_RailwayFury/steam/trailer/demo-gameplay-trailer.mp4' if args.demo else 'FeedingABlackHoldGame/StoreAssets_RailwayFury/steam/trailer/gameplay-trailer.mp4')
output.parent.mkdir(parents=True, exist_ok=True)
subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(), '-y', '-i', str(source),
                '-c:v', 'libx264', '-preset', 'medium', '-b:v', '12000k',
                '-maxrate', '16000k', '-bufsize', '24000k',
                '-pix_fmt', 'yuv420p', '-c:a', 'aac', '-b:a', '192k',
                '-ac', '2', '-movflags', '+faststart', str(output)], check=True)
print(output)
