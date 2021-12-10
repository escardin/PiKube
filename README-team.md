If you're starting from an sd card in your macbook:
- use raspi imager to load raspberrypi os.
  - before imaging hit cmd + shift + x to bring up the secret menu to configure wifi, hostname (if needed), ssh + password
- after imaging, you could add the cgroup lines at /Volumes/boot/cmdline.txt
  - you may need to re-mount or plug/unplug the card to get it to show up
  - If you do this, you can maybe skip a restart. You won't pickup kernel updates, but if you started with a new image you shouldn't be far enough behind for it to matter
- Ssh in and run script1.sh
- ssh in again and run script2.sh after the restart.
- you may want to copy paste individual lines of python_interactive.sh.txt as it's not intended to be run in a block
