# Camera
Most models of the RPi have a camera port but pay attention as the RPi Zero has a smaller port and needs a smaller ribbon cable.
There are two types of camera modules:
- standard: take pictures in normal light
- NoIR: without infrared filter, you can take pictures in the dark with an infrared light source

## Connect the module
1. look for the camera module port on your RPi
2. pull up the edges of the ports plastic clip
3. insert the camera ribbon cable and make sure the contacts face the ribbon cable connectors
4. push down the plastic clip into place

## Activate your camera
Power up your RPi and start the config tool with `sudo raspi-config`. Scroll down to "enable camera" and set it to "Yes". Now restart your RPi to load all librarys. 

## Taking pictures from cli
Raspbian has it's own librarys to interact with the camera. To take pictures you can use the command `raspistill`. Here is a little list of what is possible:
- Take a jpg picture (standard): `raspistill -o image.jpg`
- Take a png picture (or bmp/gif): `raspistill -o image.png -e png`
- Take a picture without preview: `raspistill -o image.jpg -n`
- Wait 3000ms to take the picture: `raspistill -o image.jpg -t 3000`
- set the width and height of the picture: `raspistill -o image.jpg -w 640 -h 480`
- set the quality of the picture (from 0 to 100%): `raspistill -o image.jpg -q 20`
- take a series of  pictures all 5 seconds for a whole hour (3600000 seconds): `raspistill -o image_%04d.jpg -tl 5000 -t 3600000` (later you can stick it together with ffmpeg to get a movie)

## Taking videos from cli
Next to pictures you can take videos
- take a video for 5 seconds: `raspivid -o video.h264 -t 50000` (to never end set t to 0)
- set width and height: `raspivid -o video.h264 -t 50000 -w 1280 -h 720`
- set the bitrate: `raspivid -o video.h264 -t 50000 -b 3500000`
- set the framerate: `raspivid -o video.h264 -t 50000 -f 10`
- send the video stream to sdtout: `raspivid -t 50000 -o - `

To convert videos from H264 to mp4 you can use gpac:
```bash
sudo apt-get install gpac
MP4Box -fps 30 -add video.h264 video.mp4
```

## Control the camera with python
You can control your camera using python libraries (preinstalled on Raspbian). 

Open an editor and paste the following, save it like `camera.py`.
```python
from picamera import PiCamera
from time import sleep

camera = PiCamera()

camera.start_preview()
sleep(5)
camera.stop_preview()
```
The camera should be shown 5 seconds and then close.

There are several functions/filters you can use:
- Rotate (in degree): `camera.rotation = 180`
- Make the camera preview see-through by setting an alpha level: `camera.start_preview(alpha=200)`
- Take a picture (it’s important to sleep for at least two seconds before capturing an image because this gives the camera’s sensor time to sense the light levels)
    ```python
    camera.start_preview()
    sleep(5)
    camera.capture('/home/pi/Desktop/image.jpg')
    camera.stop_preview()
    ```
- record a video: 
    ```python
    camera.start_recording('/home/pi/Desktop/video.h264')
    sleep(5)
    camera.stop_recording()
    ```
- change the resolution: `camera.resolution = (2592, 1944)` 
  - maximum resolution is 2592x1944 for still photos, 
  - maximum resolution is 1920x1080 for video recording, 
  - minimum resolution is 64x64
- change the framerate: `camera.framerate = 15`
  - 0 is minimum 
  - 15 is maximum
- add text to your image: `camera.annotate_text = "Hello world!"`

# Source and more
[RaspberryPi.com](https://www.raspberrypi.com/documentation/accessories/camera.html)