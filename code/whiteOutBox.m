function [image] = whiteOutBox(image, box)
image(box(2):box(2)+box(4), box(1):box(1)+box(3));