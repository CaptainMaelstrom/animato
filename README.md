animato
=======

![animato](http://i57.tinypic.com/sy4e9g.jpg)

animato is a program made with love2d that let's anyone create animations based on in-betweening ('tweening') between various keyframes. Each keyframe has rotation, scale, and position information about each image. The workflow is roughly this:

1. Replace the images in the images folder with those of your own
2. Open animato and duplicate/remove images until you have the ones you need for your animation
3. Click and drag images and make the next keyframe (by pressing 'k')
4. Press play to watch your images transform from one keyframe to another (press 'p' to play)

![sample idle animation](http://i59.tinypic.com/25up544.gif)

Save your animation to a file by pressing Ctrl+S and entering a name

For a comprehensive list of keyboard shortcuts and mouse controls, hold the space bar down in animato.

Installation
------------
You must first install or have unzipped love2d (www.love2d.org). To see how to run animato with love2d refer to http://www.love2d.org/wiki/Getting_Started .

Changing the draw order
-----------------------

By default, animato will draw each image in the order it was loaded. This may not be satisfactory--to change the order, start by pressing the 'n' key. This will clear the current draw order and you will see all of your images greyed out.
![change draw order](http://i60.tinypic.com/33cx2l4.png)
Now click on each image in the order you'd like animato to draw them. They will turn white as you click them. When you're happy and have clicked all the images, press 'm' to set the draw order.

Changing keyframe easing function and timing
--------------------------------------------

By default, images will transform to the next keyframe in 400 milliseconds linearly. To change the time it takes to tween from one keyframe to another, first click on the keyframe to make it the active keyframe. Now enter the time in milliseconds you want the tween to last (using the number line, not keypad numbers) and press enter.

To change the easing function, select a keyframe and press the arrow keys. To quickly return to the linear function press '0' on the keypad.

Output
------

Each animation is saved to a file that has the name you give it after pressing Ctrl+S. The output is saved to whichever directory you run the program from. To see the animation in another program (perhaps a game you're making), copy the load and draw functions from animato's main.lua into your program.

Bugs/Gotchas
------------

animato doesn't support changing images between keyframes. Please do not add or remove images between keyframes.




