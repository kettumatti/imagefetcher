# ImageFetcher

A **KDE Plasma 6 applet** that fetches and displays an image from a URL or local file.
The image is automatically refreshed at a configurable interval.
Supports both **singe** and **multiple** image sources.

## Features
- Display remote images (https://) or local images (file://)
- The image can be zoomed if it is larger than the applet window
- Automatic periodic refresh
- Multiple sources (switch image per refresh)
- Works on Plasma 6 (includes correct metadata)
- Simple configuration UI

## Requirements
- KDE Plasma 6+
- Qt 6
- kpackagetool6 (for installation)

## Installation
1. Clone this repository:
```bash
git clone https://github.com/kettumatti/imagefetcher.git
```
2. Install applet
```bash
cd imagefetcher
kpackagetool6 --type Plasma/Applet --install ./
```
3. Add the applet to your Plasma desktop via the widget menu.

## Usage
- Right-click the applet to open Settings
- Configure:
    - Add/remove image sources (URL or local file path)
    - Set refresh interval (in minutes or seconds)
- Left-click to view the image at original size. Drag to move the zoomed image. 

The applet will automatically reload the image(s) at the chosen interval.

## License
This project is licensed under the GNU General Public License v3.0.

