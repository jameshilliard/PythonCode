# -*- coding: utf-8 -*-

"""
Script to turn image into css
"""

import image
import sys

__author__ = "Reverland (lhtlyy@gmail.com)"


def getcss(im):
    """docstring for get"""
    css = """position: absolute;
    top: 30px;
    left: 30px;
    width: 0;
    height: 0;
    box-shadow:
        """
    string = '%dpx %dpx 0px 1px rgb%s,\n'
    for y in range(0, im.size[1], 1):
        for x in range(0, im.size[0], 1):
            if im.size[1] - y <= 1 and im.size[0] - x <= 1:
                string = '%dpx %dpx 0px 1px rgb%s;\n'
            color = im.getpixel((x, y))
            css += string % (x, y, color)
    return css


def gethtml(css):
    """docstring for gethtml"""
    html = """
    <div style="
    %s"></div>
    """ % css
    return html


if __name__ == '__main__':
    filename = sys.argv[1]
    #outfile = sys.argv[2]
    im = image.open(filename)
    ratio = 0.5
    size = (int(ratio * im.size[0]), int(ratio * im.size[1]))
    im.thumbnail(size)
    html = gethtml(getcss(im))
    print html
    # with open(outfile, 'wb') as f:
    #     f.write(html)__author__ = 'royxu'
