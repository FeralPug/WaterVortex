# WaterVortex
Code for a water vortex effect made with Unity BiRP as seen in the picture or on this youtube video https://www.youtube.com/watch?v=aoDp3kHo4TM.

To use import all of the code into a Unity project using the Built in Render pipeline. 
![Cyclone1 - frame at 0m14s](https://github.com/FeralPug/WaterVortex/assets/72169728/4c629bb0-144e-4d40-b13a-4eee4f4f9761)

The effect works by rendering data about the vortexes into a renderbuffer that can then be used in the water shader to displace the water plane. 

To use, create a second camera in your scene that will render the water vortexes. I did this by creating a layer for the vortexes and setting the camera to only render that layer. Also set the camera to orthographic, make its view frustrum large enough to cover the area where vortexes will be, position it above the water, and rotate it so it is looking down at where the water will be. Add the CycloneCameraController to this camera object and assign itself as the camera field. You will need to create the render buffer object and assign it to this script in the inspector as well. The focus field can be left blank. This was there to allow the camera to position itself automatically, but it currently does not do that.

Next create a material with the cycloneFX shader.

Next you will need to create some planes, and assign them the Cyclone controller script and set them to use the cycloneFX shader material. Make sure to put them in the correct layer so that the cyclone camera can see them. 

You will also need to create a water plane that uses the cyclone water shader. This shader is BAD. It uses surfaces shaders to get lighting and finite difference to calculate new normals for vertex displacement. You would be better off to use math to calculate vertex displacement so that you can calculate the new normals exactly or use less lighting and write your own vert/frag shader. The Surface function is really the thing you need here to get the data from the cyclone render buffer object that your cyclone camera renders. 

The Bouyancey Object script and the waterplane controller script are just simple extras that sort of make objects respond to being in the cyclone. I put these two together quickly and would write a more full solution if I really needed this. 
