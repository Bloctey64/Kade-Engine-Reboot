package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.sound.FlxSound;
import flixel.addons.effects.chainable.FlxWaveEffect;

class Stage
{
	public var curStage:String = '';
	public var halloweenLevel:Bool = false;
	public var camZoom:Float;
	public var hideLastBG:Bool = false; // True = hide last BG and show ones from slowBacks on certain step, False = Toggle Visibility of BGs from SlowBacks on certain step
	public var tweenDuration:Float = 2; // How long will it tween hiding/showing BGs, variable above must be set to True for tween to activate
	public var toAdd:Array<Dynamic> = []; // Add BGs on stage startup, load BG in by using "toAdd.push(bgVar);"
	// Layering algorithm for noobs: Everything loads by the method of "On Top", example: You load wall first(Every other added BG layers on it), then you load road(comes on top of wall and doesn't clip through it), then loading street lights(comes on top of wall and road)
	public var swagBacks:Map<String, Dynamic> = []; // Store BGs here to use them later in PlayState or when slowBacks activate
	public var swagGroup:Map<String, FlxTypedGroup<Dynamic>> = []; // Store Groups
	public var animatedBacks:Array<FlxSprite> = []; // Store animated backgrounds and make them play animation(Animation must be named Idle!! Else use swagGroup)
	public var layInFront:Array<Array<FlxSprite>> = [[], [], []]; // BG layering, format: first [0] - in front of GF, second [1] - in front of opponent, third [2] - in front of boyfriend(and techincally also opponent since Haxe layering moment)
	public var slowBacks:Map<Int,
		Array<FlxSprite>> = []; // Change/add/remove backgrounds mid song! Format: "slowBacks[StepToBeActivated] = [Sprites,To,Be,Changed,Or,Added];"

	public function new(daStage:String)
	{
		this.curStage = daStage;
		camZoom = 1.05; // Don't change zoom here, unless you want to change zoom of every stage that doesn't have custom one
		halloweenLevel = false;

		switch (daStage)
		{
			case 'halloween':
				{
					halloweenLevel = true;

					var hallowTex = Paths.getSparrowAtlas('halloween_bg', 'week2');

					var halloweenBG = new FlxSprite(-200, -100);
					halloweenBG.frames = hallowTex;
					halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
					halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
					halloweenBG.animation.play('idle');
					halloweenBG.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['halloweenBG'] = halloweenBG;
					toAdd.push(halloweenBG);
				}
			case 'philly':
				{
					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city', 'week3'));
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					swagBacks['city'] = city;
					toAdd.push(city);

					var phillyCityLights = new FlxTypedGroup<FlxSprite>();
					if (FlxG.save.data.distractions)
					{
						swagGroup['phillyCityLights'] = phillyCityLights;
						toAdd.push(phillyCityLights);
					}

					for (i in 0...5)
					{
						var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i, 'week3'));
						light.scrollFactor.set(0.3, 0.3);
						light.visible = false;
						light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						light.antialiasing = FlxG.save.data.antialiasing;
						phillyCityLights.add(light);
					}

					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain', 'week3'));
					swagBacks['streetBehind'] = streetBehind;
					toAdd.push(streetBehind);

					var phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train', 'week3'));
					if (FlxG.save.data.distractions)
					{
						swagBacks['phillyTrain'] = phillyTrain;
						toAdd.push(phillyTrain);
					}

					PlayState.trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes', 'week3'));
					FlxG.sound.list.add(PlayState.trainSound);

					// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

					var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street', 'week3'));
					swagBacks['street'] = street;
					toAdd.push(street);
				}
			case 'limo':
				{
					camZoom = 0.90;

					var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset', 'week4'));
					skyBG.scrollFactor.set(0.1, 0.1);
					skyBG.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['skyBG'] = skyBG;
					toAdd.push(skyBG);

					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo', 'week4');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					bgLimo.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['bgLimo'] = bgLimo;
					toAdd.push(bgLimo);

					var fastCar:FlxSprite;
					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol', 'week4'));
					fastCar.antialiasing = FlxG.save.data.antialiasing;

					if (FlxG.save.data.distractions)
					{
						var grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
						swagGroup['grpLimoDancers'] = grpLimoDancers;
						toAdd.push(grpLimoDancers);

						for (i in 0...5)
						{
							var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
							dancer.scrollFactor.set(0.4, 0.4);
							grpLimoDancers.add(dancer);
						}

						swagBacks['fastCar'] = fastCar;
						layInFront[2].push(fastCar);
					}

					var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay', 'week4'));
					overlayShit.alpha = 0.5;
					// add(overlayShit);

					// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

					// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

					// overlayShit.shader = shaderBullshit;

					var limoTex = Paths.getSparrowAtlas('limo/limoDrive', 'week4');

					var limo = new FlxSprite(-120, 550);
					limo.frames = limoTex;
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					limo.antialiasing = FlxG.save.data.antialiasing;
					layInFront[0].push(limo);
					swagBacks['limo'] = limo;

					// Testing
					//
					// hideLastBG = true;
					// slowBacks[40] = [limo];
					// slowBacks[120] = [limo, bgLimo, skyBG, fastCar];
				}
			case 'mall':
				{
					camZoom = 0.80;

					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls', 'week5'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop', 'week5');
					upperBoppers.animation.addByPrefix('idle', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = FlxG.save.data.antialiasing;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					if (FlxG.save.data.distractions)
					{
						swagBacks['upperBoppers'] = upperBoppers;
						toAdd.push(upperBoppers);
						animatedBacks.push(upperBoppers);
					}

					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator', 'week5'));
					bgEscalator.antialiasing = FlxG.save.data.antialiasing;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					swagBacks['bgEscalator'] = bgEscalator;
					toAdd.push(bgEscalator);

					var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree', 'week5'));
					tree.antialiasing = FlxG.save.data.antialiasing;
					tree.scrollFactor.set(0.40, 0.40);
					swagBacks['tree'] = tree;
					toAdd.push(tree);

					var bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop', 'week5');
					bottomBoppers.animation.addByPrefix('idle', 'Bottom Level Boppers', 24, false);
					bottomBoppers.antialiasing = FlxG.save.data.antialiasing;
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					if (FlxG.save.data.distractions)
					{
						swagBacks['bottomBoppers'] = bottomBoppers;
						toAdd.push(bottomBoppers);
						animatedBacks.push(bottomBoppers);
					}

					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow', 'week5'));
					fgSnow.active = false;
					fgSnow.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['fgSnow'] = fgSnow;
					toAdd.push(fgSnow);

					var santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa', 'week5');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = FlxG.save.data.antialiasing;
					if (FlxG.save.data.distractions)
					{
						swagBacks['santa'] = santa;
						toAdd.push(santa);
						animatedBacks.push(santa);
					}
				}
			case 'mallEvil':
				{
					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG', 'week5'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree', 'week5'));
					evilTree.antialiasing = FlxG.save.data.antialiasing;
					evilTree.scrollFactor.set(0.2, 0.2);
					swagBacks['evilTree'] = evilTree;
					toAdd.push(evilTree);

					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow", 'week5'));
					evilSnow.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['evilSnow'] = evilSnow;
					toAdd.push(evilSnow);
				}
			case 'school':
				{
					// defaultCamZoom = 0.9;

					var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky', 'week6'));
					bgSky.scrollFactor.set(0.1, 0.1);
					swagBacks['bgSky'] = bgSky;
					toAdd.push(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool', 'week6'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					swagBacks['bgSchool'] = bgSchool;
					toAdd.push(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					swagBacks['bgStreet'] = bgStreet;
					toAdd.push(bgStreet);

					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack', 'week6'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					swagBacks['fgTrees'] = fgTrees;
					toAdd.push(fgTrees);

					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					swagBacks['bgTrees'] = bgTrees;
					toAdd.push(bgTrees);

					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals', 'week6');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					swagBacks['treeLeaves'] = treeLeaves;
					toAdd.push(treeLeaves);

					var widShit = Std.int(bgSky.width * 6);

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					treeLeaves.setGraphicSize(widShit);

					fgTrees.updateHitbox();
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();
					treeLeaves.updateHitbox();

					var bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					if (PlayState.SONG.song.toLowerCase() == 'roses')
					{
						if (FlxG.save.data.distractions)
						{
							bgGirls.getScared();
						}
					}

					bgGirls.setGraphicSize(Std.int(bgGirls.width * PlayState.daPixelZoom));
					bgGirls.updateHitbox();
					if (FlxG.save.data.distractions)
					{
						swagBacks['bgGirls'] = bgGirls;
						toAdd.push(bgGirls);
					}
				}
			case 'schoolEvil':
				{
					if (!PlayStateChangeables.Optimize)
					{
						var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
						var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
					}

					var posX = 400;
					var posY = 200;

					var bg:FlxSprite = new FlxSprite(posX, posY);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					/* 
						var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
						bg.scale.set(6, 6);
						// bg.setGraphicSize(Std.int(bg.width * 6));
						// bg.updateHitbox();
						add(bg);
						var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
						fg.scale.set(6, 6);
						// fg.setGraphicSize(Std.int(fg.width * 6));
						// fg.updateHitbox();
						add(fg);
						wiggleShit.effectType = WiggleEffectType.DREAMY;
						wiggleShit.waveAmplitude = 0.01;
						wiggleShit.waveFrequency = 60;
						wiggleShit.waveSpeed = 0.8;
					 */

					// bg.shader = wiggleShit.shader;
					// fg.shader = wiggleShit.shader;

					/* 
						var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
						var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);
						// Using scale since setGraphicSize() doesnt work???
						waveSprite.scale.set(6, 6);
						waveSpriteFG.scale.set(6, 6);
						waveSprite.setPosition(posX, posY);
						waveSpriteFG.setPosition(posX, posY);
						waveSprite.scrollFactor.set(0.7, 0.8);
						waveSpriteFG.scrollFactor.set(0.9, 0.8);
						// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
						// waveSprite.updateHitbox();
						// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
						// waveSpriteFG.updateHitbox();
						add(waveSprite);
						add(waveSpriteFG);
					 */
				}
			default:
				{
					camZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = FlxG.save.data.antialiasing;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					swagBacks['stageFront'] = stageFront;
					toAdd.push(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = FlxG.save.data.antialiasing;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					swagBacks['stageCurtains'] = stageCurtains;
					toAdd.push(stageCurtains);
				}
			case 'tank':
				{
					camZoom = 0.9;
					curStage = 'tank';

					// var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet', 'week6'));
					// bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');

					var tankSky:FlxSprite = new FlxSprite(-400, -400).loadGraphic(Paths.image('tankSky', 'week7'));
					tankSky.antialiasing = FlxG.save.data.antialiasing;
					tankSky.scrollFactor.set(0, 0);
					swagBacks['tankSky'] = tankSky;
					toAdd.push(tankSky);
					if (FlxG.save.data.quality)
					{
						var tankClouds:FlxSprite = new FlxSprite(FlxG.random.int(-700, -100),
							FlxG.random.int(-20, 20)).loadGraphic(Paths.image('tankClouds', 'week7'));
						tankClouds.velocity.x = FlxG.random.float(5, 15);
						tankClouds.moves = true;
						tankClouds.antialiasing = FlxG.save.data.antialiasing;
						tankClouds.scrollFactor.set(0.1, 0.1);

						swagBacks['tankClouds'] = tankClouds;
						toAdd.push(tankClouds);

						var tankMountains:FlxSprite = new FlxSprite(-300, -20).loadGraphic(Paths.image('tankMountains', 'week7'));
						tankMountains.antialiasing = FlxG.save.data.antialiasing;
						tankMountains.setGraphicSize(Std.int(tankMountains.width * 1.2));
						tankMountains.updateHitbox();
						tankMountains.scrollFactor.set(0.2, 0.2);
						swagBacks['tankMountains'] = tankMountains;
						toAdd.push(tankMountains);

						var tankBuildings:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.image('tankBuildings', 'week7'));
						tankBuildings.setGraphicSize(Std.int(tankBuildings.width * 1.1));
						tankBuildings.updateHitbox();
						tankBuildings.scrollFactor.set(0.30, 0.30);
						tankBuildings.antialiasing = FlxG.save.data.antialiasing;
						swagBacks['tankBuildings'] = tankBuildings;
						toAdd.push(tankBuildings);
					}

					var tankRuins:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.image('tankRuins', 'week7'));
					tankRuins.setGraphicSize(Std.int(1.1 * tankRuins.width));
					tankRuins.updateHitbox();
					tankRuins.antialiasing = FlxG.save.data.antialiasing;
					tankRuins.scrollFactor.set(0.35, 0.35);
					swagBacks['tankRuins'] = tankRuins;
					toAdd.push(tankRuins);

					if (FlxG.save.data.quality)
					{
						var smokeLeft:FlxSprite = new FlxSprite(-200, -100);
						smokeLeft.antialiasing = FlxG.save.data.antialiasing;
						smokeLeft.scrollFactor.set(0.4, 0.4);
						smokeLeft.frames = Paths.getSparrowAtlas('smokeLeft', 'week7');
						smokeLeft.animation.addByPrefix('idle', 'SmokeBlurLeft', 24, true);
						smokeLeft.animation.play('idle');
						swagBacks['smokeLeft'] = smokeLeft;
						toAdd.push(smokeLeft);

						var smokeRight:FlxSprite = new FlxSprite(1100, -100);
						smokeRight.antialiasing = FlxG.save.data.antialiasing;
						smokeRight.scrollFactor.set(0.4, 0.4);
						smokeRight.frames = Paths.getSparrowAtlas('smokeRight', 'week7');
						smokeRight.animation.addByPrefix('idle', 'SmokeRight', 24, true);
						smokeRight.animation.play('idle');
						swagBacks['smokeRight'] = smokeRight;
						toAdd.push(smokeRight);

						var tankWatchTower:FlxSprite = new FlxSprite(100, 50);
						tankWatchTower.antialiasing = FlxG.save.data.antialiasing;
						tankWatchTower.frames = Paths.getSparrowAtlas('tankWatchtower', 'week7');
						tankWatchTower.animation.addByPrefix('idle', 'watchtower gradient color', 24);
						tankWatchTower.animation.play('idle');
						tankWatchTower.scrollFactor.set(0.5, 0.5);
						tankWatchTower.active = true;
						swagBacks['tankWatchTower'] = tankWatchTower;
						toAdd.push(tankWatchTower);
					}
					var tankGround:FlxSprite = new FlxSprite(300, 300);
					tankGround.scrollFactor.set(0.5, 0.5);
					tankGround.antialiasing = FlxG.save.data.antialiasing;
					tankGround.frames = Paths.getSparrowAtlas('tankRolling', 'week7');
					tankGround.animation.addByPrefix('idle', 'BG tank w lighting', 24, true);
					tankGround.animation.play('idle');
					swagBacks['tankGround'] = tankGround;
					toAdd.push(tankGround);

					var tankmanRun = new FlxTypedGroup<TankmenBG>();
					swagBacks['tankmanRun'] = tankmanRun;
					toAdd.push(tankmanRun);

					var tankField:FlxSprite = new FlxSprite(-420, -150).loadGraphic(Paths.image('tankGround', 'week7'));
					tankField.antialiasing = FlxG.save.data.antialiasing;
					tankField.setGraphicSize(Std.int(1.15 * tankField.width));
					tankField.updateHitbox();
					swagBacks['tankField'] = tankField;
					toAdd.push(tankField);

					var foreGround0 = new FlxSprite(-500, 600);
					foreGround0.scrollFactor.set(1.7, 1.5);
					foreGround0.antialiasing = FlxG.save.data.antialiasing;
					foreGround0.frames = Paths.getSparrowAtlas('tank0', 'week7');
					foreGround0.animation.addByPrefix('idle', 'fg tankhead far right', 24);
					foreGround0.animation.play('idle');
					swagBacks['foreGround0'] = foreGround0;
					layInFront[2].push(foreGround0);

					if (FlxG.save.data.quality)
					{
						var foreGround1 = new FlxSprite(-300, 750);
						foreGround1.scrollFactor.set(2, 0.2);
						foreGround1.antialiasing = FlxG.save.data.antialiasing;
						foreGround1.frames = Paths.getSparrowAtlas('tank1', 'week7');
						foreGround1.animation.addByPrefix('idle', 'fg tankhead', 24);
						foreGround1.animation.play('idle');
						swagBacks['foreGround1'] = foreGround1;
						layInFront[2].push(foreGround1);
					}

					var foreGround2 = new FlxSprite(450, 940);
					foreGround2.scrollFactor.set(1.5, 1.5);
					foreGround2.antialiasing = FlxG.save.data.antialiasing;
					foreGround2.frames = Paths.getSparrowAtlas('tank2', 'week7');
					foreGround2.animation.addByPrefix('idle', 'foreground man', 24);
					foreGround2.animation.play('idle');
					swagBacks['foreGround2'] = foreGround2;
					layInFront[2].push(foreGround2);

					if (FlxG.save.data.quality)
					{
						var foreGround3 = new FlxSprite(1300, 900);
						foreGround3.scrollFactor.set(1.5, 1.5);
						foreGround3.antialiasing = FlxG.save.data.antialiasing;
						foreGround3.frames = Paths.getSparrowAtlas('tank4', 'week7');
						foreGround3.animation.addByPrefix('idle', 'fg tankman', 24);
						foreGround3.animation.play('idle');
						swagBacks['foreGround3'] = foreGround3;
						layInFront[2].push(foreGround3);
					}

					var foreGround4 = new FlxSprite(1620, 710);
					foreGround4.scrollFactor.set(1.5, 1.5);
					foreGround4.antialiasing = FlxG.save.data.antialiasing;
					foreGround4.frames = Paths.getSparrowAtlas('tank5', 'week7');
					foreGround4.animation.addByPrefix('idle', 'fg tankhead far right', 24);
					foreGround4.animation.play('idle');
					swagBacks['foreGround4'] = foreGround4;
					layInFront[2].push(foreGround4);

					if (FlxG.save.data.quality)
					{
						var foreGround5 = new FlxSprite(1400, 1290);
						foreGround5.scrollFactor.set(1.5, 1.5);
						foreGround5.antialiasing = FlxG.save.data.antialiasing;
						foreGround5.frames = Paths.getSparrowAtlas('tank3', 'week7');
						foreGround5.animation.addByPrefix('idle', 'fg tankhead', 24);
						foreGround5.animation.play('idle');
						swagBacks['foreGround5'] = foreGround5;
						layInFront[2].push(foreGround5);
					}
				}
		}
	}
}
