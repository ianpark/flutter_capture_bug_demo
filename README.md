### Flutter capture bug demo

This test app demonstrates the `toImage()` failure that appeared after `v1.7.8+hotfix.4`. 

- The problem is, `toImage()` occasionally fails to return the fully captured image but partially or completely empty image.

- When there are multiple images in `Stack()` widget, `toImage()` could only capture one or two images and return the incomplete result. This is very difficult to reproduce, however definitely happens. I suspect the root cause is some sort of memory constraints. 

Please check the following thread for further detail.

https://github.com/flutter/flutter/issues/17687
https://github.com/flutter/flutter/issues/43085

### Steps to reproduce
1. make sure you are on stage channel and version `1.9.1+hotfix.2` or other higher versions.

2. flutter run

3. load a large image. 2MB should be probably enough but it all depends on the performance

4. Press the blue save button or the grey save button multiple time until you see the fail% increase.

Note that "Start Test" and "Stop Test" are added to prove that this problem is not reproducible by calling `toImage()` multiple times in a loop without UI interaction.

The blue save button and the gery one calls the same function. 
