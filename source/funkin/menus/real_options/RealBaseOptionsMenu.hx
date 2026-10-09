package funkin.menus.real_options;

import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepadManager;

import funkin.audio.FunkinSound;

import funkin.objects.CheckboxThingie;
import funkin.objects.AttachedFlxText;
import funkin.backend.InputFormatter;

class RealBaseOptionsMenu extends MusicBeatSubstate
{
	private var curOption:RealOption = null;
	private var curSelected:Int = 0;
	private var optionsArray:Array<RealOption>;

	private var grpOptions:FlxTypedGroup<FlxText>;
	private var checkboxGroup:FlxTypedGroup<CheckboxThingie>;
	private var grpTexts:FlxTypedGroup<AttachedFlxText>;

	private var descBox:FlxSprite;
	private var descText:FlxText;

	public var rpcTitle:String;
	var backButt:FlxSprite;
	public var bg:FlxSprite;

	public function new()
	{
		super();

		if(rpcTitle == null) rpcTitle = 'Options Menu';
		
		#if DISCORD_ALLOWED
		DiscordClient.changePresence(rpcTitle, null);
		#end

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);

		// avoids lagspikes while scrolling through menus!
		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedFlxText>();
		add(grpTexts);

		checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
		add(checkboxGroup);

		descBox = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(0, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.LIME, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		var curID:Int = -1;
		for (i in 0...optionsArray.length)
		{
			var optionText:FlxText = new FlxText(220, 260, 0, optionsArray[i].name);
			optionText.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.LIME, LEFT);
			curID += 1;
			optionText.ID = curID;
			grpOptions.add(optionText);

			if(optionsArray[i].type == BOOL)
			{
				var checkbox:CheckboxThingie = new CheckboxThingie(optionText.width + 60, 5, Std.string(optionsArray[i].getValue()) == 'true');
				checkbox.sprTracker = optionText;
				checkbox.ID = i;
				checkboxGroup.add(checkbox);
			}
			else
			{
				var valueText:AttachedFlxText = new AttachedFlxText(''+ optionsArray[i].getValue(), optionText.width + 10, 5);
				valueText.sprTracker = optionText;
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

		backButt = new FlxSprite(FlxG.width - 100, FlxG.height - 100).loadGraphic(Paths.image('green_x'));
		backButt.scale.set(2,2);
		add(backButt);
	}

	public function addOption(option:RealOption) {
		if(optionsArray == null || optionsArray.length < 1) optionsArray = [];
		optionsArray.push(option);
		return option;
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;
	var holdValue:Float = 0;

	var bindingKey:Bool = false;
	var holdingEsc:Float = 0;
	var bindingBlack:FlxSprite;
	var bindingText:FlxText;
	var bindingText2:FlxText;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(bindingKey)
		{
			bindingKeyUpdate(elapsed);
			return;
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
			FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'));
		}

		if (controls.BACK) {
			close();
			FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'));
		}

		if(nextAccept <= 0)
		{
			switch(curOption.type)
			{
				case BOOL:
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

				case KEYBIND:
					grpOptions.forEach(function(spr:FlxSprite)
					{
						if(FlxG.mouse.overlaps(spr) && spr.ID == curSelected && FlxG.mouse.justPressed)
						{
							bindingBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
							bindingBlack.scale.set(FlxG.width, FlxG.height);
							bindingBlack.updateHitbox();
							bindingBlack.alpha = 0;
							FlxTween.tween(bindingBlack, {alpha: 0.6}, 0.35, {ease: FlxEase.linear});
							add(bindingBlack);
		
							bindingText = new FlxText(FlxG.width / 2, 160, Language.getPhrase('controls_rebinding', 'Rebinding {1}', [curOption.name]), false);
							bindingText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.LIME, CENTER);
							add(bindingText);
							
							bindingText2 = new FlxText(FlxG.width / 2, 340, Language.getPhrase('controls_rebinding2', 'Hold ESC to Cancel\nHold Backspace to Delete'), true);
							bindingText2.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.LIME, CENTER);
							add(bindingText2);
		
							bindingKey = true;
							holdingEsc = 0;
							ClientPrefs.toggleVolumeKeys(false);
							FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'));
						}
					});
					
					if(controls.ACCEPT)
					{
						bindingBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.WHITE);
						bindingBlack.scale.set(FlxG.width, FlxG.height);
						bindingBlack.updateHitbox();
						bindingBlack.alpha = 0;
						FlxTween.tween(bindingBlack, {alpha: 0.6}, 0.35, {ease: FlxEase.linear});
						add(bindingBlack);
	
						bindingText = new FlxText(FlxG.width / 2, 160, Language.getPhrase('controls_rebinding', 'Rebinding {1}', [curOption.name]), false);
						bindingText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.LIME, CENTER);
						add(bindingText);
						
						bindingText2 = new FlxText(FlxG.width / 2, 340, Language.getPhrase('controls_rebinding2', 'Hold ESC to Cancel\nHold Backspace to Delete'), true);
						bindingText2.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.LIME, CENTER);
						add(bindingText2);
	
						bindingKey = true;
						holdingEsc = 0;
						ClientPrefs.toggleVolumeKeys(false);
						FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'));
					}

				default:

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
	
									if(curOption.type == INT)
									{
										holdValue = Math.round(holdValue);
										curOption.setValue(holdValue);
									}
									else
									{
										holdValue = FlxMath.roundDecimal(holdValue, curOption.decimals);
										curOption.setValue(holdValue);
									}
	
								case STRING:
									var num:Int = curOption.curOption; //lol
									num++;
	
									if(num < 0)
										num = curOption.options.length - 1;
									else if(num >= curOption.options.length)
										num = 0;
	
									curOption.curOption = num;
									curOption.setValue(curOption.options[num]);
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
	
									if(curOption.type == INT)
									{
										holdValue = Math.round(holdValue);
										curOption.setValue(holdValue);
									}
									else
									{
										holdValue = FlxMath.roundDecimal(holdValue, curOption.decimals);
										curOption.setValue(holdValue);
									}
	
								case STRING:
									var num:Int = curOption.curOption; //lol
									num--;
	
									if(num < 0)
										num = curOption.options.length - 1;
									else if(num >= curOption.options.length)
										num = 0;
	
									curOption.curOption = num;
									curOption.setValue(curOption.options[num]);
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
		
										if(curOption.type == INT)
										{
											holdValue = Math.round(holdValue);
											curOption.setValue(holdValue);
										}
										else
										{
											holdValue = FlxMath.roundDecimal(holdValue, curOption.decimals);
											curOption.setValue(holdValue);
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
										curOption.setValue(curOption.options[num]);
										//trace(curOption.options[num]);

									default:
								}
								updateTextFrom(curOption);
								curOption.change();
								FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'));
							}
							else if(curOption.type != STRING)
							{
								holdValue += curOption.scrollSpeed * elapsed * (controls.UI_LEFT ? -1 : 1);
								if(holdValue < curOption.minValue) holdValue = curOption.minValue;
								else if (holdValue > curOption.maxValue) holdValue = curOption.maxValue;
		
								switch(curOption.type)
								{
									case INT:
										curOption.setValue(Math.round(holdValue));
									
									case FLOAT, PERCENT:
										curOption.setValue(FlxMath.roundDecimal(holdValue, curOption.decimals));

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
					{
						if(holdTime > 0.5) FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'));
						holdTime = 0;
					}
			}

			if(controls.RESET)
			{
				var leOption:RealOption = optionsArray[curSelected];
				if(leOption.type != KEYBIND)
				{
					leOption.setValue(leOption.defaultValue);
					if(leOption.type != BOOL)
					{
						if(leOption.type == STRING) leOption.curOption = leOption.options.indexOf(leOption.getValue());
						updateTextFrom(leOption);
					}
				}
				else
				{
					leOption.setValue(!Controls.instance.controllerMode ? leOption.defaultKeys.keyboard : leOption.defaultKeys.gamepad);
					updateBind(leOption);
				}
				leOption.change();
				FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'));
				reloadCheckboxes();
			}
		}

		if(nextAccept > 0) {
			nextAccept -= 1;
		}
	}

	function bindingKeyUpdate(elapsed:Float)
	{
		if(FlxG.keys.pressed.ESCAPE || FlxG.gamepads.anyPressed(B))
		{
			holdingEsc += elapsed;
			if(holdingEsc > 0.5)
			{
				FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'));
				closeBinding();
			}
		}
		else if (FlxG.keys.pressed.BACKSPACE || FlxG.gamepads.anyPressed(BACK))
		{
			holdingEsc += elapsed;
			if(holdingEsc > 0.5)
			{
				if (!controls.controllerMode) curOption.keys.keyboard = NONE;
				else curOption.keys.gamepad = NONE;
				updateBind(!controls.controllerMode ? InputFormatter.getKeyName(NONE) : InputFormatter.getGamepadName(NONE));
				FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'));
				closeBinding();
			}
		}
		else
		{
			holdingEsc = 0;
			var changed:Bool = false;
			if(!controls.controllerMode)
			{
				if(FlxG.keys.justPressed.ANY || FlxG.keys.justReleased.ANY)
				{
					var keyPressed:FlxKey = cast (FlxG.keys.firstJustPressed(), FlxKey);
					var keyReleased:FlxKey = cast (FlxG.keys.firstJustReleased(), FlxKey);

					if(keyPressed != NONE && keyPressed != ESCAPE && keyPressed != BACKSPACE)
					{
						changed = true;
						curOption.keys.keyboard = keyPressed;
					}
					else if(keyReleased != NONE && (keyReleased == ESCAPE || keyReleased == BACKSPACE))
					{
						changed = true;
						curOption.keys.keyboard = keyReleased;
					}
				}
			}
			else if(FlxG.gamepads.anyJustPressed(ANY) || FlxG.gamepads.anyJustPressed(LEFT_TRIGGER) || FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER) || FlxG.gamepads.anyJustReleased(ANY))
			{
				var keyPressed:FlxGamepadInputID = NONE;
				var keyReleased:FlxGamepadInputID = NONE;
				if(FlxG.gamepads.anyJustPressed(LEFT_TRIGGER))
					keyPressed = LEFT_TRIGGER; //it wasnt working for some reason
				else if(FlxG.gamepads.anyJustPressed(RIGHT_TRIGGER))
					keyPressed = RIGHT_TRIGGER; //it wasnt working for some reason
				else
				{
					for (i in 0...FlxG.gamepads.numActiveGamepads)
					{
						var gamepad:FlxGamepad = FlxG.gamepads.getByID(i);
						if(gamepad != null)
						{
							keyPressed = gamepad.firstJustPressedID();
							keyReleased = gamepad.firstJustReleasedID();
							if(keyPressed != NONE || keyReleased != NONE) break;
						}
					}
				}

				if(keyPressed != NONE && keyPressed != FlxGamepadInputID.BACK && keyPressed != FlxGamepadInputID.B)
				{
					changed = true;
					curOption.keys.gamepad = keyPressed;
				}
				else if(keyReleased != NONE && (keyReleased == FlxGamepadInputID.BACK || keyReleased == FlxGamepadInputID.B))
				{
					changed = true;
					curOption.keys.gamepad = keyReleased;
				}
			}

			if(changed)
			{
				var key:String = null;
				if(!controls.controllerMode)
				{
					if(curOption.keys.keyboard == null) curOption.keys.keyboard = 'NONE';
					curOption.setValue(curOption.keys.keyboard);
					key = InputFormatter.getKeyName(FlxKey.fromString(curOption.keys.keyboard));
				}
				else
				{
					if(curOption.keys.gamepad == null) curOption.keys.gamepad = 'NONE';
					curOption.setValue(curOption.keys.gamepad);
					key = InputFormatter.getGamepadName(FlxGamepadInputID.fromString(curOption.keys.gamepad));
				}
				updateBind(key);
				FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'));
				closeBinding();
			}
		}
	}

	final MAX_KEYBIND_WIDTH = 320;
	function updateBind(?text:String = null, ?option:RealOption = null)
	{
		if(option == null) option = curOption;
		if(text == null)
		{
			text = option.getValue();
			if(text == null) text = 'NONE';

			if(!controls.controllerMode)
				text = InputFormatter.getKeyName(FlxKey.fromString(text));
			else
				text = InputFormatter.getGamepadName(FlxGamepadInputID.fromString(text));
		}

		var bind:AttachedFlxText = cast option.child;
		var attach:AttachedFlxText = new AttachedFlxText(text, bind.offsetX);
		attach.sprTracker = bind.sprTracker;
		attach.copyAlpha = true;
		attach.ID = bind.ID;
		attach.scale.x = Math.min(1, MAX_KEYBIND_WIDTH / attach.width);
		attach.x = bind.x;
		attach.y = bind.y;

		option.child = attach;
		grpTexts.insert(grpTexts.members.indexOf(bind), attach);
		grpTexts.remove(bind);
		bind.destroy();
	}

	function closeBinding()
	{
		bindingKey = false;
		bindingBlack.destroy();
		remove(bindingBlack);

		bindingText.destroy();
		remove(bindingText);

		bindingText2.destroy();
		remove(bindingText2);
		ClientPrefs.toggleVolumeKeys(true);
	}

	function updateTextFrom(option:RealOption) {
		if(option.type == KEYBIND)
		{
			updateBind(option);
			return;
		}

		var text:String = option.displayFormat;
		var val:Dynamic = option.getValue();
		if(option.type == PERCENT) val *= 100;
		var def:Dynamic = option.defaultValue;
		option.text = text.replace('%v', val).replace('%d', def);
	}
	
	function changeSelection(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, optionsArray.length - 1);

		descText.text = optionsArray[curSelected].description;
		descText.screenCenter(Y);
		descText.y += 270;

		descBox.setPosition(descText.x - 10, descText.y - 10);
		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();

		curOption = optionsArray[curSelected]; //shorter lol
		FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'));
	}

	function reloadCheckboxes()
		for (checkbox in checkboxGroup)
			checkbox.daValue = Std.string(optionsArray[checkbox.ID].getValue()) == 'true'; //Do not take off the Std.string() from this, it will break a thing in Mod Settings Menu
}