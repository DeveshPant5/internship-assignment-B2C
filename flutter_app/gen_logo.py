from PIL import Image, ImageDraw, ImageFont
import os

if not os.path.exists('assets'):
    os.makedirs('assets')

img = Image.new('RGB', (1024, 1024), color=(244, 143, 177))
draw = ImageDraw.Draw(img)

try:
    font = ImageFont.truetype('arial.ttf', 700)
except IOError:
    font = ImageFont.load_default()

text = 'W'
left, top, right, bottom = draw.textbbox((0, 0), text, font=font)
w = right - left
h = bottom - top
draw.text(((1024-w)/2, (1024-h)/2 - 100), text, font=font, fill=(255, 255, 255))
img.save('assets/app_logo.png')
