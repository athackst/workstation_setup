#!/usr/bin/python
# md
# ## Export Google Keep notes to Obsidian
#
# This script converts a Google Keep JSON export file to Markdown files that can be imported into Obsidian.
#
# ### Usage
# 1. Export your Google Keep notes to JSON format. See [Google Takeout](https://takeout.google.com/settings/takeout) for instructions.
# 2. Extract your Google Keep export file to the google_keep folder.
# 3. Open a terminal and run the script with the following command:
#    ```shell
#    python keep_to_obsidian.py --input path/to/google_keep_export -- output path/to/obsidian_export
#    ```
# 4. Markdown files will be saved in the Obsidian export folder.
#
# ### Notes
# - The script will create the Obsidian export folder if it doesn't exist.
# - The script will overwrite existing Markdown files with the same name.
# - The script will decode HTML entities in the note content.
# - The script will use 'Untitled' as the note title if the note doesn't have a title.
# - The script will ignore notes that don't have any content.
# - The script will ignore notes that don't have a `textContent` field.
#
# /md

import json
import os
import html
import click
import re


def sanitize_filename(filename):
    # Replace any characters that are not letters, numbers, or underscores with underscores.
    return re.sub(r'[^\w]+', '_', filename)


@click.command()
@click.option('--input', default='google_keep', help='Path to the folder containing Google Keep JSON files.')
@click.option('--output', default='obsidian', help='Path to the folder to export Markdown files to.')
def convert_google_keep_to_obsidian(input, output):
    google_keep_folder = input
    obsidian_export_folder = output

    # Create the Obsidian export folder if it doesn't exist.
    if not os.path.exists(obsidian_export_folder):
        os.mkdir(obsidian_export_folder)

    # Iterate through the JSON files in the Google Keep export folder.
    for filename in os.listdir(google_keep_folder):
        if filename.endswith(".json"):
            with open(os.path.join(google_keep_folder, filename), 'r', encoding='utf-8') as json_file:
                data = json.load(json_file)

                if 'textContent' in data:
                    title = data['title'].strip(
                    ) if 'title' in data else 'Untitled'
                    title = sanitize_filename(title)  # Sanitize the title
                    content = data['textContent']
                    content = html.unescape(content)  # Decode HTML entities

                    # Create a Markdown file for each note.
                    md_filename = os.path.join(
                        obsidian_export_folder, title + '.md')
                    with open(md_filename, 'w', encoding='utf-8') as md_file:
                        md_file.write(f'# {title}\n\n')
                        md_file.write(content)

    print("Export completed. Markdown files are saved in the Obsidian export folder.")


if __name__ == '__main__':
    convert_google_keep_to_obsidian()
