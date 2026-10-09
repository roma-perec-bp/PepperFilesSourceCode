package funkin.graphics.shaders;

import lime.utils.Assets;
import flixel.addons.display.FlxRuntimeShader;

@:nullSafety
class DaveAndBambiGlitchShader extends FlxRuntimeShader
{
  public function new()
  {
    super(Assets.getText(Paths.shaderFragment('dnb')));
    this.setFloat('uTime', 0);
  }
}
