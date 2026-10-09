
package funkin.graphics.shaders;

import lime.utils.Assets;
import flixel.addons.display.FlxRuntimeShader;

class BloomedShader extends FlxRuntimeShader
{
  public function new()
  {
    super(Assets.getText(Paths.shaderFragment('bloom')));
  }
}