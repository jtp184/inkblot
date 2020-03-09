#!/usr/bin/python
# -*- coding:utf-8 -*-
import sys
import os

# The path to the gem library, passed in from ruby
gpath = sys.argv[1]
# The path to the image to display passed in from ruby
imgpath = sys.argv[2]

# Compose the path to the support library for the eink screen
libdir = gpath + "/waveshare_epd"

# Add it to the path
if os.path.exists(libdir):
    sys.path.append(libdir)

import logging

from waveshare_epd import epd2in7
import time
from PIL import Image,ImageDraw,ImageFont
import traceback

# Initialize the screen
epd = epd2in7.EPD()
epd.init()

# Open the provided image
print imgpath
image = Image.open(imgpath)

# Print it to the display
epd.display(epd.getbuffer(image))

# Power down display
epd.sleep()

exit()
