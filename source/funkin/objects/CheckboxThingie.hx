package funkin.objects;

class CheckboxThingie extends FlxText
{
	public var sprTracker:FlxSprite;
	public var daValue(default, set):Bool;
	public var copyAlpha:Bool = true;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public function new(offsetX:Float = 0, offsetY:Float = 0, ?checked = false) {
		super(x, y, 0, '');

		this.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.LIME, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		daValue = checked;

		this.offsetX = offsetX;
		this.offsetY = offsetY;
	}

	override function update(elapsed:Float) {
		if (sprTracker != null) {
			setPosition(sprTracker.x + offsetX, sprTracker.y + offsetY);
			if(copyAlpha) {
				alpha = sprTracker.alpha;
			}
		}
		super.update(elapsed);
	}

	private function set_daValue(check:Bool):Bool {
		if(check) {
			text = 'true';
		} else {
			text = 'false';
		}
		return check;
	}
}