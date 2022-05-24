## How to test the microphone

List the available microphone devices on your system:
```
:~# arecord -l
**** List of CAPTURE Hardware Devices ****
card 0: PCH [HDA Intel PCH], device 0: ALC255 Analog [ALC255 Analog]
  Subdevices: 1/1
  Subdevice #0: subdevice #0
```

Select one of the audio-input devices from the list and use it to record a 10-second audio clip to see if it’s working:
```
:~# arecord -f cd -d 10 --device="hw:0,0" /tmp/test-mic.wav
```

`hw:0,0` is used to specify which microphone device to use: the first digit specifies the **card**, while the second digit specifies the **device**.

Play what you have just recorded:
```
:~# aplay /tmp/test-mic.wav
Playing WAVE '/tmp/test-mic.wav' : Signed 16 bit Little Endian, Rate 44100 Hz, Stereo
```
