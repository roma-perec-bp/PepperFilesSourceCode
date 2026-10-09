package funkin.menus.real_options;

import funkin.menus.mainmenu.MainMenuState;
import funkin.data.StageData;
import funkin.audio.FunkinSound;

import flixel.input.keyboard.FlxKey;

class RealOptionsState extends MusicBeatState
{
	var options:Array<String> = [
		'Note Colors',
		'Controls',
		'Adjust Note Delay Offset',
		'Graphics',
		'Visuals',
		'Gameplay'
	];
	private var grpOptions:FlxTypedGroup<FlxText>;
	private static var curSelected:Int = 0;
	public static var onPlayState:Bool = false;
	var selectedSomethin:Bool = false;

	var lockMovement:Bool = false;
	var mouseMode:Bool = false;

	var staticTransition:FlxSprite;

	var backButt:FlxSprite;

	function openSelectedSubstate(label:String) {
		switch(label)
		{
			case 'Note Colors':
				openSubState(new funkin.menus.real_options.RealNotesColorSubState());
			case 'Controls':
				openSubState(new funkin.menus.real_options.RealControlsSubState());
			case 'Graphics':
				openSubState(new funkin.menus.real_options.RealGraphicsSettingsSubState());
			case 'Visuals':
				openSubState(new funkin.menus.real_options.RealVisualsSettingsSubState());
			case 'Gameplay':
				openSubState(new funkin.menus.real_options.RealGameplaySettingsSubState());
			case 'Adjust Note Delay Offset':
				MusicBeatState.switchState(new funkin.menus.real_options.RealNoteOffsetState());
		}
	}

	var selectorRight:FlxText;

	override function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("options", null);
		#end

		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);

		var curID:Int = -1;
		for (num => option in options)
		{
			var optionText:FlxText = new FlxText(25, 0, 0, Language.getPhrase('options_$option', option));
			optionText.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.LIME, LEFT);
			curID += 1;
			optionText.ID = curID;
			optionText.y += (50 * (num - (options.length / 2))) + 250;
			grpOptions.add(optionText);
		}

		selectorRight = new FlxText(0, 0, 0, '<');
		selectorRight.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.LIME, LEFT);
		add(selectorRight);

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();

		backButt = new FlxSprite(FlxG.width - 100, FlxG.height - 100).loadGraphic(Paths.image('green_x'));
		backButt.scale.set(2,2);
		add(backButt);

		staticTransition = new FlxSprite();
		staticTransition.frames = Paths.getSparrowAtlas('staticTV');
		staticTransition.animation.addByPrefix('idle', "static", 24);
        staticTransition.animation.play('idle');
		staticTransition.updateHitbox();
		staticTransition.screenCenter();
		staticTransition.scale.set(4,4);
		staticTransition.alpha = 0.00001;
		add(staticTransition);
	}

	override function closeSubState()
	{
		super.closeSubState();
		ClientPrefs.saveSettings();
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(selectedSomethin) return;

		if (FlxG.keys.firstJustPressed() != FlxKey.NONE) mouseMode = false;
		if (FlxG.mouse.justMoved) mouseMode = true;

		var dist:Float = -1;
		var distItem:Int = -1;
		if (!selectedSomethin && mouseMode)
		{
			var selectedItem:FlxSprite;
			selectedItem = grpOptions.members[curSelected];

			for (i in 0...options.length)
			{
				var memb:FlxSprite = grpOptions.members[i];
				if (FlxG.mouse.overlaps(memb))
				{
					var distance:Float = Math.sqrt(Math.pow(memb.getGraphicMidpoint().x - FlxG.mouse.screenX, 2) + Math.pow(memb.getGraphicMidpoint().y - FlxG.mouse.screenY, 2));
					if (dist < 0 || distance < dist)
					{
						dist = distance;
						distItem = i;
					}

					if(FlxG.mouse.justPressed && mouseMode)
						openSelectedSubstate(options[curSelected]);
				}
			}

			if(distItem != -1 && selectedItem != grpOptions.members[distItem])
			{
				curSelected = distItem;
				changeSelection();
			}
		}

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);

		if(FlxG.mouse.overlaps(backButt) && FlxG.mouse.justPressed)
		{
			selectedSomethin = true;
			
			FunkinSound.playOnce(Paths.sound('real_menu_sounds/static_sound'));

			staticTransition.alpha = 1;
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				if(onPlayState)
				{
					FlxG.mouse.visible = false;
					FlxTransitionableState.skipNextTransIn = false;
					FlxTransitionableState.skipNextTransOut = false;
					StageData.loadDirectory(PlayState.SONG);
					LoadingState.loadAndSwitchState(new PlayState());
					FlxG.sound.music.volume = 0;
				}
				else MusicBeatState.switchState(new MainMenuState());
			});
		}

		if (controls.BACK)
		{
			selectedSomethin = true;
			
			FunkinSound.playOnce(Paths.sound('real_menu_sounds/static_sound'));

			staticTransition.alpha = 1;
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				if(onPlayState)
				{
					FlxG.mouse.visible = false;
					FlxTransitionableState.skipNextTransIn = false;
					FlxTransitionableState.skipNextTransOut = false;
					StageData.loadDirectory(PlayState.SONG);
					LoadingState.loadAndSwitchState(new PlayState());
					FlxG.sound.music.volume = 0;
				}
				else MusicBeatState.switchState(new MainMenuState());
			});
		}
		else if (controls.ACCEPT) openSelectedSubstate(options[curSelected]);
	}
	
	function changeSelection(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);

		var selectedItem:FlxText;
		selectedItem = grpOptions.members[curSelected];

		selectorRight.x = selectedItem.x + selectedItem.width + 15;
		selectorRight.y = selectedItem.y;

		FunkinSound.playOnce(Paths.sound('real_menu_sounds/blip_select'));
	}

	override function destroy()
	{
		ClientPrefs.loadPrefs();
		super.destroy();
	}
}