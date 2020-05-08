# 3D Models for a Vase and Plate

<img width="474" alt="image" src="https://user-images.githubusercontent.com/350131/81410762-94964800-9141-11ea-91fa-842a238c431b.png">
<img width="765" alt="image" src="https://user-images.githubusercontent.com/350131/81410827-ad066280-9141-11ea-86dd-3b355cea2a8c.png">

Considering you have Ruby/Bundler already installed, just clone the repo, run `bundle` and tweak the `BASE_PARAMS` on the `vase.rb` file.
You can build `.scad` files by running `make` - this will generate both vase and plate.
I recommend installing OpenSCAD, so you can have a live preview.

## Why another vase?

I recently printed a https://www.thingiverse.com/thing:2792926 using the vase mode on my 3d printer. The result came out surprisingly good, but weak.
Since the vase mode available in Cura doesn't allow me to increase the width of the walls, I decided to give a try on a generic print that would not rely on the printer mode.
So basically:

* Also generates a plate
* You can print it with holes
* You can adjust the wall width, allowing space for infill and shell tweaks

# License

This project is released under The MIT License (MIT).
