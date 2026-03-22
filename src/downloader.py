import yt_dlp
import csv
import os

def download_playlist(url, output_dir, verbose=False):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    csv_path = os.path.join(output_dir, 'playlist_log.csv')
    
    ydl_opts = {
        'format': 'bestaudio/best',
        'writethumbnail': True,  # Required to download the art first
        'postprocessors': [
            {
                'key': 'FFmpegExtractAudio',
                'preferredcodec': 'mp3',
                'preferredquality': '320',
            },
            {
                'key': 'FFmpegMetadata',
                'add_metadata': True,  # Embeds title, artist, etc.
            },
            {
                'key': 'EmbedThumbnail',  # Embeds the downloaded image into the MP3
            }
        ],
        'outtmpl': os.path.join(output_dir, '%(title)s.%(ext)s'),
        'verbose': False,
        'quiet': not verbose,
    }

    downloaded_data = []

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        # download=True will now also trigger the metadata/art embedding
        info = ydl.extract_info(url, download=True)
        
        # Check if it's a playlist or single video to log correctly
        entries = info.get('entries', [info])
        for index, entry in enumerate(entries, start=1):
            if entry:
                file_name = f"{entry['title']}.mp3"
                downloaded_data.append([index, file_name])

    # Generate CSV log
    with open(csv_path, mode='w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['index', 'file_name'])
        writer.writerows(downloaded_data)
    
    print(f"\nSuccess! Files and metadata saved in: {output_dir}")
    return 0
