#!/usr/bin/python
# md
# ## Download a google drive file
#
# This python script downloads a file from google drive using teh file ID obtained from a shareable link.
#
# ### Usage
#
# 1. Obtain the file ID from the shareable link of the file.
# 2. Run the script with the following command:
#    ```shell
#    python google_drive.py file_id destination_file_path
#    ```
# 3. The file will be saved in the destination path.
#
# ### Notes
# - The script will overwrite existing files with the same name.
# - The script will not work for files that are not shared.
# - To share a file, click on the share button on the top right corner of the file and click on "Get shareable link".
#
# /md

import requests


def download_file_from_google_drive(id, destination):
    def get_confirm_token(response):
        for key, value in response.cookies.items():
            if key.startswith('download_warning'):
                return value

        return None

    def save_response_content(response, destination):
        CHUNK_SIZE = 32768

        with open(destination, "wb") as f:
            for chunk in response.iter_content(CHUNK_SIZE):
                if chunk:  # filter out keep-alive new chunks
                    f.write(chunk)

    URL = "https://docs.google.com/uc?export=download"

    session = requests.Session()

    response = session.get(URL, params={'id': id}, stream=True)
    token = get_confirm_token(response)

    if token:
        params = {'id': id, 'confirm': token}
        response = session.get(URL, params=params, stream=True)

    save_response_content(response, destination)


if __name__ == "__main__":
    import sys
    if len(sys.argv) != 3:
        print("Usage: python google_drive.py drive_file_id destination_file_path")
    else:
        # TAKE ID FROM SHAREABLE LINK
        file_id = sys.argv[1]
        # DESTINATION FILE ON YOUR DISK
        destination = sys.argv[2]
        download_file_from_google_drive(file_id, destination)
