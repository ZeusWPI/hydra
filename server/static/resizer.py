#!/usr/bin/env python3
"""
Resize images to a specified size.
"""

from PIL import Image
import os
import argparse
import glob


def resize(input_image, output_folder):
    """
    Resize an image.
    """
    image = Image.open(input_image)
    image.thumbnail((300, 300))
    output_name = os.path.basename(input_image)
    output_path = os.path.join(output_folder, output_name)
    image.save(output_path)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Resize images in a folder')
    parser.add_argument('input', help='The folder containing the source images. Must be a valid path.')
    parser.add_argument('output', help='An empty output folder. Must be a valid path.')
    args = parser.parse_args()

    input_folder = os.path.join(args.input, '')
    for image_file in glob.glob(input_folder + '*.png'):
        print(f"Resizing image {image_file}...")
        resize(image_file, args.output)
