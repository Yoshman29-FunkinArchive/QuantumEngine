# bald engine

![](art/picture.png) holy shit another **CANCELLED** engine

im too lazy to make a proper readme lemme copy the twitter thread i made abt the thought process for this with paths to the files used in the attached images (since my acc is privated)

<details>
    <summary>Twitter thread i made about the engine (from September 2023)</summary>


> so uuh yea i left the baldi funkin team due to me just having freaking enough of fnf but before leaving the fnf community i was cooking up smth real cool for the mod with some pretty neat ideas and i thought id share it with yall
> 
> its all my work and if it contains a single bit of baldi funkin it wont be shown of course but yea i started developing a fnf engine exclusively for the mod and i did take a special route for it
> 
> basically it wasnt going to be a cne or yce but rather smth that would be useful to me, in the way that i wanted to work so yea i got to work and i managed to get smth quite good imo??? it aint done, sadly they scrapped it right away after i left but its worth showing the cool stuff on it and the route i took for it in case it could inspire future engine devs

> first of all i totally gave up on softcoding, fuck it tbh lmao and at the same time i didnt wanted to make hardcoding well hard so i went on a modular route for the engine

> menus are base, playstate is rewritten
> i added characters as an interface (still depends on flxsprite) so that its possible to make both sparrow and animate atlas characters
> 
> -> `source/game/characters/`

> as for character loading, i just did a class checkup (for example if in your chart player1 is "Boyfriend", it'll look up for the class at game.characters.Boyfriend, keep charts in mind ill get back to it later), of course theres safelocks for bf and gf
> 
> -> `source/game/characters/presets/Character.hx -> CharacterUtil class`

> for stages, its pretty similar
> 
> i decided to use flixel's abilities and make stages flxgroups, the code for the stage base class isn't very complex, of course with the default stage example
> 
> -> `source/game/stages/`

> forgot to mention how character code works
>
> offsets are missing for sparrow ones, we'll get to them later
> 
> -> `source/game/characters/`

> as for playstate itself, i decided to move things such as healthbars in seperate classes. Reduced playstate length to around 400 lines, some classes are created using Type.createInstance, i'll also get to that later (might be outdated)
>
> -> `source/game/PlayState.hx`

> For the chart format, there isn't any thats serializable, instead Chart is a class and multiple parsers are used. It allows for stuff such as custom health bars, custom modcharts, rating skins, countdown skins, cutscenes and end cutscenes
>
> -> `source/assets/chart/`

> for custom note types, it works like characters except u directly extend from note which is a sprite and u need to add it manually in the code (idk if theres a class checkup i forgot)
strumlines are also customisable and more than 4k is possible
>
> -> `source/game/StrumLine.hx`,  `source/game/strums/`

> abt modcharts, this is the templates folder
> 
> hscript is here due to one coder needing a way to softcode stuff, but yea its the only softcoded part of the engine
> 
> video cutscenes are also supported
> 
> -> `source/game/modcharts/`

> engine also comes with a GameConfig.hx file which allows you to change global game configuration
> 
> -> `source/GameConfig.hx`

> as for the conductor, it's a flixel plugin now and i expanded it, but i think its better to go through the assets first so that you can understand
> 
> i got rid of base game's assets management and decided to get smth that would be more straightforward than what was originally here
> 
> -> `assets/` tree overview

> songs works that way: they have those following files, if you want to add a difficulty, just add a folder in with the name of your difficulty and put in the files you wanna replace (for example: songs/song/hard/chart.json). The engine will automatically use that file instead
> 
> -> `assets/songs/dadbattle/` tree overview

> BPM files are simple txt files that allows you to set the bpm of the music, but also add bpm changes. It supports comments and is automatically loaded by Conductor, which means bpm changes works everywhere, menus included
> 
> -> `assets/menus/freakyMenu.bpm`

> the offset system is also generalized. All spritesheets comes with an additional json file which defines its animations. They're automatically loaded by the engine once you use this line of code and offsets works everywhere without additional setup.
> 
> -> `assets/game/character/bf-dead*`, along with this snippet:
>
> `this.loadFrames('game/characters/bf');` where `this` is an FlxSprite

> Also if you're wondering, character offsets are flipped correctly when switching from player to opponents, like in Codename Engine.

> also this is what the assets/game folder looks like
>
> -> overview of assets folder

> i think this is all i have to say abt this, was def fun to develop
additional mentions: cleaned up paths, FlixelFixer2000 (high dpi doesnt make the game blurry anymore)
> 
> its mainly an engine made in the most modular way possible lmao and it works great
> -> `source/assets/Paths.hx`
</details>

## TODO LIST:

- [x] Sorted assets
- [x] Sorted source
- [x] Get rid of base game stuff in source
- [x] Turn Conductor into a flixel plugin (updates independently of MusicBeatState)
- [x] Make source work with new assets
    - [x] Implement FunkinCache
    - [x] Fix BitmapFrontEnd
    - [x] Source assets
    - [x] Implement GPU textures (and maybe reimplement cne's assetslibrarytree???)
- [x] New chart system
    - [x] Create chart system
    - [x] Make it read charts from **Psych / Base Game**
        - [x] Parse metadata
        - [x] Parse notes
        - [x] Parse events
    - [x] Make it read charts from **Codename**
- [x] Complete PlayState rewrite
    - [x] Rewrite controls
    - [x] New chart parser
    - [x] New stage system based on FlxGroups
    - [x] Change Character into an interface (and extend it)
        - [x] Sparrow characters support
        - [x] Animate Atlas characters support
    - [x] New Note system
    - [x] Add sustains to the note system
    - [x] Add score, misses & accuracy
    - [x] Add healthbar & icons
    - [x] Add Game Over screen
    - [x] Make the songs actually finishable
    - [x] Pause Menu
    - [x] Scroll speeds
    - [x] Cutscenes
    - [x] End Cutscene
    - [x] Modchart class with callbacks & stuff
    - [x] Beginning countdown (3 2 1 go)
    - [x] Make combo ratings show up
- [x] Save & Options
    - [ ] Remove Highscore, etc... and replace it by FunkinSave (like CNE)
    - [ ] Add Options
        - [x] Add options saving
        - [ ] Add options menu (??? maybe at the end right before release)
- [ ] Discord RPC
- [ ] Baldi Funkin
- [ ] Menus
    - [ ] Update Freeplay to use icons & config.json
    - [ ] Update Story Menu to a better format

## TODONT LIST:

- [x] "mods" folder

## ADDED FEATURE LIST

- **Reorganized assets**: Got rid of data, images, sounds, etc... Redone for ease of use.
- **Reorganized source**: Now disposed into folders.
- **Rewritten Conductor**: now works as a plugin, allows for any game song to use BPM changes via additional .bpm file (including main menu and gameover)
    - `FlxG.sound.playMusic()` now obsolete, use `Conductor.instance.loadAndPlay()`
- **Rewritten Characters**: Characters now have separate classes and can extend anything that extends FlxSprite (FlxSpriteGroup, FlxAnimate...)
- **Rewritten Stages**: Stages are now FlxGroups separated into singular classes. Since theyre groups, they can be easily interchanged midsong with some coding.
- **Rewritten Chart System**: Charts allows now for more than 2 strumlines (no chart format tho, use the Codename Engine one if you want best compatibility)

## CREDITS
- Yoshman29 - programmer
- Ne_Eo - additional help & added some fixes
- Baldi's Basics in Funkin' team - lol theyre the reason this engine exists
- Funkin Crew - The original game
- mystman12 - for making baldis basics