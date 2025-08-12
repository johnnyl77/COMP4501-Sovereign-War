Jacob Duncan, Johnny Ling
COMP 4501 
FINAL S-1
2025-03-12

1. 3D rendering based on an isometric view (main level)

2. Many 3d models for the scene done, ie trees rocks etc, dynamic units when spawned in such as buildings or units

3. Collison detection between objects, both custom implementation and in engine, ie buildings use custom collison tracking to make sure
they are not colliding with each other when trying to place, however units use in engine collison to init events based on what they are 
colliding with

4. Doesnt fully make sence due to the nature of the game being a blank slate, you can click the UI to spawn instances

5. Multiple implementations of player actions and unit actions, most important being clicking to build, deploy units, or delete a buildings
also rough pause menu etc, pathfinding is essentially done and nav mesh generates dynamically when new buildings are placed that have
collison (walls). Units either farm wood, attack other units, farm plants, or farm ores, all with animations and actually moving and dropping
off the resources.

6. Full camera movement, mouse wheel in and out to change zoom and then you can drag (if in spawn unit view) to move around the board
you can also always use WASD to move around the board (usefull for when in other action views)

Due to this being a protopye the game is of course not done and the game loop is not fully complete, however to test the game and actions
you can use the UI, i will describe what buttons do below

ACTION BUTTON (BOTTOM LEFT CORNER) - toggles what state you are in either unit spawn, build, or destroy
when in unit spawn mode you can click in the bottom right corner to spawn a friendly unit, the farmers are unique as you must place a plot of land for them to harvest resources, also the last queen symbol spawns a enemey knight for testing attacking other not friendly units (it will spawn a mage in the real game)
the build and destroy mode are self explanatory, click on the building you want to place, then left click if its free and it will spawn it on your plot of land, this multiple building sizes (1x1, 3x3, 1x3) and the ability to rotate (R KEY)
destroy mode is also easy, just left click on one of your buildings to remove it.

your resources will be updated by the UI when units collect them, but at the moment the economy has not been done so nothing actually costs any resources to make