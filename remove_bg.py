from PIL import Image
import os
import sys

def remove_background(image_path):
    try:
        img = Image.open(image_path)
        img = img.convert("RGBA")
        datas = img.getdata()

        newData = []
        for item in datas:
            # Change all white (also shades of whites) to transparent
            if item[0] > 240 and item[1] > 240 and item[2] > 240:
                newData.append((255, 255, 255, 0))
            else:
                newData.append(item)

        img.putdata(newData)
        img.save(image_path, "PNG")
        print(f"Processed {image_path}")
    except Exception as e:
        print(f"Error processing {image_path}: {e}")

if __name__ == "__main__":
    files = [
        "assets/images/bosses/syntax_sentinel.png",
        "assets/images/bosses/logic_lich.png",
        "assets/images/bosses/bug_bear.png"
    ]
    for f in files:
        remove_background(f)
