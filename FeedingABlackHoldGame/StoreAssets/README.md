Store asset pack for uploading to itch.io and Steam.

What I created:
- SVG logos and banners (editable vector placeholders)
- Screenshot placeholders (SVG)
- Text files: `itch_description.txt`, `steam_description.txt`, `press_release.txt`, `credits.txt`

How to export to PNG (Windows):

Using ImageMagick (magick):
magick convert -background none input.svg -resize WIDTHxHEIGHT output.png

Using Inkscape (new CLI):
inkscape input.svg --export-filename=output.png --export-width=WIDTH --export-height=HEIGHT

Recommended sizes (examples):
- itch header/banner: 1200x540, 960x540
- itch thumbnail: 512x512
- steam header: 616x353
- steam capsule small: 231x87
- steam capsule main: 464x181
- steam hero: 1920x620 (optional)
- screenshots: 1280x720 or 1920x1080

Place exported PNGs into the same folders (`itchio` / `steam`) before uploading.
