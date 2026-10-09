package funkin.menus.real_options;

import funkin.objects.CheckboxThingie;
import funkin.objects.AttachedFlxText;

import funkin.audio.FunkinSound;

import funkin.menus.options.Option;

class RealGameplayChangersSubstate extends MusicBeatSubstate
{
	private var curSelected:Int = 0;
	private var optionsArray:Array<Dynamic> = [];

	private var grpOptions:FlxTypedGroup<FlxText>;
	private var checkboxGroup:FlxTypedGroup<CheckboxThingie>;
	private var grpTexts:FlxTypedGroup<AttachedFlxText>;

	var backButt:FlxSprite;

	private var curOption(get, never):GameplayOption;
	function get_curOption() return optionsArray[curSelected]; //shorter lol

	function getOptions()
	{
		optionsArray.push(new GameplayOption('Opponent Mode', 'opponentplay', BOOL, false));

		var goption:GameplayOption = new GameplayOption('Scroll Type: ', 'scrolltype', STRING, 'multiplicative', ["multiplicative", "constant"]);
		optionsArray.push(goption);

		var option:GameplayOption = new GameplayOption('Scroll Speed:', 'scrollspeed', FLOAT, 1);
		option.scrollSpeed = 2.0;
		option.minValue = 0.35;
		option.changeValue = 0.05;
		option.decimals = 2;
		if (goption.getValue() != "constant")
		{
			option.displayFormat = '%vX';
			option.maxValue = 3;
		}
		else
		{
			option.displayFormat = "%v";
			option.maxValue = 6;
		}
		optionsArray.push(option);

		var option:GameplayOption = new GameplayOption('Health Gain Multiplier: ', 'healthgain', FLOAT, 1);
		option.scrollSpeed = 2.5;
		option.minValue = 0;
		option.maxValue = 5;
		option.changeValue = 0.1;
		option.displayFormat = '%vX';
		optionsArray.push(option);

		var option:GameplayOption = new GameplayOption('Health Loss Multiplier: ', 'healthloss', FLOAT, 1);
		option.scrollSpeed = 2.5;
		option.minValue = 0.5;
		option.maxValue = 5;
		option.changeValue = 0.1;
		option.displayFormat = '%vX';
		optionsArray.push(option);

		optionsArray.push(new GameplayOption('Fade Out Notes', 'fade', BOOL, false));
		optionsArray.push(new GameplayOption('Only Sick Node', 'sickmode', BOOL, false));
	}

	public function getOptionByName(name:String)
	{
		for(i in optionsArray)
		{
			var opt:GameplayOption = i;
			if (opt.name == name)
				return opt;
		}
		return null;
	}

	public function new()
	{
		super();
		
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		add(bg);

		// avoids lagspikes while scrolling through menus!
		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedFlxText>();
		add(grpTexts);

		checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
		add(checkboxGroup);
		
		getOptions();

		var curID:Int = -1;
		for (i in 0...optionsArray.length)
		{
			var optionText:FlxText = new FlxText(220, 260, 0, optionsArray[i].name);
			optionText.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.RED, LEFT);
			curID += 1;
			optionText.ID = curID;
			grpOptions.add(optionText);

			if(optionsArray[i].type == BOOL)
			{
				var checkbox:CheckboxThingie = new CheckboxThingie(optionText.width + 60, 5, Std.string(optionsArray[i].getValue()) == 'true');
				checkbox.color = 0xFFFF0000;
				checkbox.sprTracker = optionText;
				checkbox.ID = i;
				checkboxGroup.add(checkbox);
			}
			else
			{
				var valueText:AttachedFlxText = new AttachedFlxText(''+optionsArray[i].getValue(),optionText.width + 10, 5);
				valueText.sprTracker = optionText;
				valueText.color = 0xFFFF0000;
				valueText.copyAlpha = true;
				valueText.ID = i;
				grpTexts.add(valueText);
				optionsArray[i].child = valueText;
			}
			//optionText.snapToPosition(); //Don't ignore me when i ask for not making a fucking pull request to uncomment this line ok
			updateTextFrom(optionsArray[i]);
		}

		changeSelection();
		reloadCheckboxes();

		backButt = new FlxSprite(FlxG.width - 150, FlxG.height - 150).loadGraphic(Paths.image('x'));
		backButt.scale.set(2,2);
		add(backButt);
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;
	var holdValue:Float = 0;
	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P || FlxG.mouse.wheel > 0)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P || FlxG.mouse.wheel < 0)
		{
			changeSelection(1);
		}

		if(FlxG.mouse.overlaps(backButt) && FlxG.mouse.justPressed)
		{
			close();
			ClientPrefs.saveSettings();
			FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'));
		}

		if (controls.BACK) {
			close();
			ClientPrefs.saveSettings();
			FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'));
		}

		grpOptions.forEach(function(spr:FlxText)
        {
			var lerpVal:Float = Math.exp(-elapsed * 12);

            var centY = (FlxG.height/2) - (spr.height /2);

            spr.y = FlxMath.lerp(spr.y, centY - (curSelected-spr.ID) * 100, FlxMath.bound(elapsed * 10, 0, 1));

			spr.alpha = (
                spr.ID == curSelected ?
                    FlxMath.lerp(spr.alpha, 1, FlxMath.bound(elapsed * 24, 0, 1))
                    :
                    FlxMath.lerp(spr.alpha, 0.7, FlxMath.bound(elapsed * 24, 0, 1))
            );
        });

		if(nextAccept <= 0)
		{
			var usesCheckbox:Bool = (curOption.type == BOOL);
			if(usesCheckbox)
			{

				grpOptions.forEach(function(spr:FlxSprite)
				{
					if(FlxG.mouse.overlaps(spr) && spr.ID == curSelected && FlxG.mouse.justPressed)
					{
						FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'));
						curOption.setValue((curOption.getValue() == true) ? false : true);
						curOption.change();
						reloadCheckboxes();
					}
				});

				if(controls.ACCEPT)
				{
					FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'));
					curOption.setValue((curOption.getValue() == true) ? false : true);
					curOption.change();
					reloadCheckboxes();
				}
			}
			else
			{
				grpOptions.forEach(function(spr:FlxSprite)
				{
					if(FlxG.mouse.overlaps(spr) && spr.ID == curSelected && FlxG.mouse.justPressed)
					{
						var add:Dynamic = null;
						if(curOption.type != STRING)
							add = curOption.changeValue;
	
						switch(curOption.type)
						{
							case INT, FLOAT, PERCENT:
								holdValue = curOption.getValue() + add;
								if(holdValue < curOption.minValue) holdValue = curOption.minValue;
								else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;

								switch(curOption.type)
								{
									case INT:
										holdValue = Math.round(holdValue);
										curOption.setValue(holdValue);

									case FLOAT, PERCENT:
										holdValue = FlxMath.roundDecimal(holdValue, curOption.decimals);
										curOption.setValue(holdValue);

									default:
								}

							case STRING:
								var num:Int = curOption.curOption; //lol
								num++;

								if(num < 0)
									num = curOption.options.length - 1;
								else if(num >= curOption.options.length)
									num = 0;

								curOption.curOption = num;
								curOption.setValue(curOption.options[num]); //lol
								
								if (curOption.name == "Scroll Type")
								{
									var oOption:GameplayOption = getOptionByName("Scroll Speed");
									if (oOption != null)
									{
										if (curOption.getValue() == "constant")
										{
											oOption.displayFormat = "%v";
											oOption.maxValue = 6;
										}
										else
										{
											oOption.displayFormat = "%vX";
											oOption.maxValue = 3;
											if(oOption.getValue() > 3) oOption.setValue(3);
										}
										updateTextFrom(oOption);
									}
								}
								//trace(curOption.options[num]);

							default:
						}
						updateTextFrom(curOption);
						curOption.change();
						FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'));
					}

					if(FlxG.mouse.overlaps(spr) && spr.ID == curSelected && FlxG.mouse.justPressedRight)
					{
						var add:Dynamic = null;
						if(curOption.type != STRING)
							add = -curOption.changeValue;

						switch(curOption.type)
						{
							case INT, FLOAT, PERCENT:
								holdValue = curOption.getValue() + add;
								if(holdValue < curOption.minValue) holdValue = curOption.minValue;
								else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;

								switch(curOption.type)
								{
									case INT:
										holdValue = Math.round(holdValue);
										curOption.setValue(holdValue);

									case FLOAT, PERCENT:
										holdValue = FlxMath.roundDecimal(holdValue, curOption.decimals);
										curOption.setValue(holdValue);

									default:
								}

							case STRING:
								var num:Int = curOption.curOption; //lol
								--num;


								if(num < 0)
									num = curOption.options.length - 1;
								else if(num >= curOption.options.length)
									num = 0;

								curOption.curOption = num;
								curOption.setValue(curOption.options[num]); //lol
								
								if (curOption.name == "Scroll Type")
								{
									var oOption:GameplayOption = getOptionByName("Scroll Speed");
									if (oOption != null)
									{
										if (curOption.getValue() == "constant")
										{
											oOption.displayFormat = "%v";
											oOption.maxValue = 6;
										}
										else
										{
											oOption.displayFormat = "%vX";
											oOption.maxValue = 3;
											if(oOption.getValue() > 3) oOption.setValue(3);
										}
										updateTextFrom(oOption);
									}
								}
								//trace(curOption.options[num]);

							default:
						}
						updateTextFrom(curOption);
						curOption.change();
						FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'));
					}
				});

				if(controls.UI_LEFT || controls.UI_RIGHT)
				{
					var pressed = (controls.UI_LEFT_P || controls.UI_RIGHT_P);
					if(holdTime > 0.5 || pressed)
					{
						if(pressed)
						{
							var add:Dynamic = null;
							if(curOption.type != STRING)
								add = controls.UI_LEFT ? -curOption.changeValue : curOption.changeValue;

							switch(curOption.type)
							{
								case INT, FLOAT, PERCENT:
									holdValue = curOption.getValue() + add;
									if(holdValue < curOption.minValue) holdValue = curOption.minValue;
									else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;

									switch(curOption.type)
									{
										case INT:
											holdValue = Math.round(holdValue);
											curOption.setValue(holdValue);

										case FLOAT, PERCENT:
											holdValue = FlxMath.roundDecimal(holdValue, curOption.decimals);
											curOption.setValue(holdValue);

										default:
									}

								case STRING:
									var num:Int = curOption.curOption; //lol
									if(controls.UI_LEFT_P) --num;
									else num++;

									if(num < 0)
										num = curOption.options.length - 1;
									else if(num >= curOption.options.length)
										num = 0;

									curOption.curOption = num;
									curOption.setValue(curOption.options[num]); //lol
									
									if (curOption.name == "Scroll Type")
									{
										var oOption:GameplayOption = getOptionByName("Scroll Speed");
										if (oOption != null)
										{
											if (curOption.getValue() == "constant")
											{
												oOption.displayFormat = "%v";
												oOption.maxValue = 6;
											}
											else
											{
												oOption.displayFormat = "%vX";
												oOption.maxValue = 3;
												if(oOption.getValue() > 3) oOption.setValue(3);
											}
											updateTextFrom(oOption);
										}
									}
									//trace(curOption.options[num]);

								default:
							}
							updateTextFrom(curOption);
							curOption.change();
							FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'));
						}
						else if(curOption.type != STRING)
						{
							holdValue = Math.max(curOption.minValue, Math.min(curOption.maxValue, holdValue + curOption.scrollSpeed * elapsed * (controls.UI_LEFT ? -1 : 1)));

							switch(curOption.type)
							{
								case INT:
									curOption.setValue(Math.round(holdValue));
								
								case FLOAT, PERCENT:
									var blah:Float = Math.max(curOption.minValue, Math.min(curOption.maxValue, holdValue + curOption.changeValue - (holdValue % curOption.changeValue)));
									curOption.setValue(FlxMath.roundDecimal(blah, curOption.decimals));

								default:
							}
							updateTextFrom(curOption);
							curOption.change();
						}
					}

					if(curOption.type != STRING)
						holdTime += elapsed;
				}
				else if(controls.UI_LEFT_R || controls.UI_RIGHT_R)
					clearHold();
			}

			if(controls.RESET)
			{
				for (i in 0...optionsArray.length)
				{
					var leOption:GameplayOption = optionsArray[i];
					leOption.setValue(leOption.defaultValue);
					if(leOption.type != BOOL)
					{
						if(leOption.type == STRING)
							leOption.curOption = leOption.options.indexOf(leOption.getValue());

						updateTextFrom(leOption);
					}

					if(leOption.name == 'Scroll Speed')
					{
						leOption.displayFormat = "%vX";
						leOption.maxValue = 3;
						if(leOption.getValue() > 3)
							leOption.setValue(3);

						updateTextFrom(leOption);
					}
					leOption.change();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				reloadCheckboxes();
			}
		}

		if(nextAccept > 0) {
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function updateTextFrom(option:GameplayOption) {
		var text:String = option.displayFormat;
		var val:Dynamic = option.getValue();
		if(option.type == PERCENT) val *= 100;
		var def:Dynamic = option.defaultValue;
		option.text = text.replace('%v', val).replace('%d', def);
	}

	function clearHold()
	{
		if(holdTime > 0.5)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		holdTime = 0;
	}
	
	function changeSelection(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, optionsArray.length - 1);

		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function reloadCheckboxes() {
		for (checkbox in checkboxGroup) {
			checkbox.daValue = (optionsArray[checkbox.ID].getValue() == true);
		}
	}
}

class GameplayOption
{
	private var child:FlxText;
	public var text(get, set):String;
	public var onChange:Void->Void = null; //Pressed enter (on Bool type options) or pressed/held left/right (on other types)
	public var type:OptionType = BOOL;

	public var showBoyfriend:Bool = false;
	public var scrollSpeed:Float = 50; //Only works on int/float, defines how fast it scrolls per second while holding left/right

	private var variable:String = null; //Variable from ClientPrefs.hx's gameplaySettings
	public var defaultValue:Dynamic = null;

	public var curOption:Int = 0; //Don't change this
	public var options:Array<String> = null; //Only used in string type
	public var changeValue:Dynamic = 1; //Only used in int/float/percent type, how much is changed when you PRESS
	public var minValue:Dynamic = null; //Only used in int/float/percent type
	public var maxValue:Dynamic = null; //Only used in int/float/percent type
	public var decimals:Int = 1; //Only used in float/percent type

	public var displayFormat:String = '%v'; //How String/Float/Percent/Int values are shown, %v = Current value, %d = Default value
	public var name:String = 'Unknown';

	public function new(name:String, variable:String, type:OptionType, defaultValue:Dynamic = 'null variable value', ?options:Array<String> = null)
	{
		_name = name;
		this.name = Language.getPhrase('setting_$name', name);
		this.variable = variable;
		this.type = type;
		this.defaultValue = defaultValue;
		this.options = options;

		if(defaultValue == 'null variable value')
		{
			switch(type)
			{
				case BOOL:
					defaultValue = false;
				case INT, FLOAT:
					defaultValue = 0;
				case PERCENT:
					defaultValue = 1;
				case STRING:
					defaultValue = '';
					if(options.length > 0)
						defaultValue = options[0];

				default:
			}
		}

		if(getValue() == null)
			setValue(defaultValue);

		switch(type)
		{
			case STRING:
				var num:Int = options.indexOf(getValue());
				if(num > -1)
					curOption = num;

			case PERCENT:
				displayFormat = '%v%';
				changeValue = 0.01;
				minValue = 0;
				maxValue = 1;
				scrollSpeed = 0.5;
				decimals = 2;

			default:
		}
	}

	public function change()
	{
		//nothing lol
		if(onChange != null)
			onChange();
	}

	public function getValue():Dynamic
		return ClientPrefs.data.gameplaySettings.get(variable);

	public function setValue(value:Dynamic)
		ClientPrefs.data.gameplaySettings.set(variable, value);

	public function setChild(child:FlxText)
		this.child = child;

	var _name:String = null;
	var _text:String = null;
	private function get_text()
		return _text;

	private function set_text(newValue:String = '')
	{
		if(child != null)
		{
			_text = newValue;
			child.text = Language.getPhrase('setting_$_name-$_text', _text);
			return _text;
		}
		return null;
	}
}