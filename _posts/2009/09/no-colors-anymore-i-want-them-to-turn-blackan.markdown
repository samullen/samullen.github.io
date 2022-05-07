---
title: '"No Colors Anymore I Want Them To Turn Black"...and White'
description: "Old Ruby way of dtermining if an image is black and white or not"
published: true
date: 2009-09-29
post: true
categories: [ruby, imagemagic]
---

I'm currently implementing a Digital Asset Management (DAM) system for [Universal Uclick](http://uclick.com), the company I work for. One of the requirements is to keep both color and black and white versions of our creators's works. This hasn't been a problem with our previous system because we've used naming conventions to&nbsp;distinguish&nbsp;between the two versions. In this newer version, I've decided to use the same name, regardless of color or grayscale, and just store said parameter in the database. The problem I ran into, however, is determining whether an image is color or grayscale.&nbsp;

I discovered that the answer is to create a black and white version (in memory) of every image and compare the two versions using ImageMagick's "[difference](http://studio.imagemagick.org/RMagick/doc/image1.html#differenc)" method. But before I get into to that, we first have to deal with one little problem...

I'm using Ruby's implementation of [ImageMagick](http://www.imagemagick.org/script/index.php) ([RMagick](http://studio.imagemagick.org/RMagick/doc/)). [According to the docs](http://studio.imagemagick.org/RMagick/doc/comtasks.html#gray), I'm supposed to use the "[quantize]("http://studio.imagemagick.org/RMagick/doc/image3.html#quantize)" method for converting color to black and white. The only problem is, it doesn't work with images like this [Non Sequitur](http://www.gocomics.com/nonsequitur) strip:

<img src="//samuelmullen.com/images/nq_c090909.gif" class="img-thumbnail img-left">

The solution, I found, is to use the "[modulate](http://studio.imagemagick.org/RMagick/doc/image2.html#modulate)" method, setting brightness to 1.0, saturation to 0.0, and hue to 0.5. Just for giggles I benchmarked the two methods and found modulate to be significantly faster. Here are the results from that:

``` bash
           user     system      total        real
quantize  4.620000   6.820000  11.440000 ( 11.831151)
modulate  1.270000   0.060000   1.330000 (  1.125789)
```

Which one would you use? Yeah, I thought so. (Note: I did not run the benchmark against the above image, but rather, on a [Garfield strip](http://www.gocomics.com/garfield)).

So now the image is being changed to black and white correctly. The next step is to compare the original to the new B&W version. To do that, use ImageMagick's "difference" method and look at the resulting "normalized_mean_error". If it's 0.0, the image is already black and white, if not, it's color. Here's a snippet of code to do this:

``` ruby
require 'rubygems'
require 'RMagick'

class Chromatic
  attr_reader :image
  
  def initialize(img)
    @image = img
  end
  
  def chromatic?
    grayscale_img = self.image.modulate(1,0,0.5)
    self.image.difference(grayscale_img)
    
    self.image.normalized_mean_error > 0
  end
end

img = Magick::Image::read(ARGV.shift).first
img2 = Chromatic.new(img)
puts img2.chromatic?
```

Two birds; one rolling stone. You can now make B&amp;W images faster and determine if an image is color or black and white. Outstanding.
