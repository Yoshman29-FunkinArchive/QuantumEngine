package backend.plugins;

#if DISCORD_RPC
import lime.app.Application;
import flixel.FlxG;
import discord_rpc.DiscordRpc as Discord;
import discord_rpc.DiscordRpc.DiscordPresenceOptions;

class DiscordPlugin extends FlxBasic {
    var timer:Float = 0;
    var presenceObj:DiscordPresence;

    public function new() {
        super();

        presenceObj = {};

        Application.current.onExit.add(onExit);

        // DiscordRpc
        Discord.onReady = onReady;
        Discord.onError = onError;
        start();
    }

    private function onError(id:Int, err:String) {
        trace('Error #$id: $err');
    }
    private function onDisconnected(_, _) {
        start();
    }
    private function onReady() {
        trace("Discord RPC ready");
        active = true;
    }

    private function start() {
        Discord.start({
            clientID: GameConfig.discordClientID
        });
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        timer += elapsed;
        if (timer > 2.0) {
            timer %= 2.0;
            ping();
        }
    }

    private function ping() {
        presenceObj.state = null;
        presenceObj.details = null;
        presenceObj.startTimestamp = null;
        presenceObj.endTimestamp = null;
        presenceObj.largeImageKey = GameConfig.discordLogoKey;
        presenceObj.largeImageText = 'Running on ${GameConfig.engineName} v${GameConfig.engineVersion.join(".")}';
        presenceObj.smallImageKey = null;
        presenceObj.smallImageText = null;
        presenceObj.partyID = null;
        presenceObj.partySize = null;
        presenceObj.partyMax = null;
        presenceObj.matchSecret = null;
        presenceObj.spectateSecret = null;
        presenceObj.joinSecret = null;
        presenceObj.instance = null;

        if (FlxG.state is MusicBeatState)
            cast(FlxG.state, MusicBeatState).updateDiscordPresence(presenceObj);


        Discord.presence(presenceObj);
        Discord.process();
    }

    private function onExit(code:Int) {
        Discord.shutdown();
    }
}


typedef DiscordPresence = DiscordPresenceOptions;
#else
class DiscordPresence {
    public var state: String;
    public var details: String;
    public var startTimestamp: Null<Int>;
    public var endTimestamp: Null<Int>;
    public var largeImageKey: String;
    public var largeImageText: String;
    public var smallImageKey: String;
    public var smallImageText: String;
    public var partyID: String;
    public var partySize: Null<Int>;
    public var partyMax: Null<Int>;
    public var matchSecret: String;
    public var spectateSecret: String;
    public var joinSecret: String;
    public var instance: Null<Int>;

    public function new() {}
}
#end

class DiscordRpc {
    public static function init() {
        #if DISCORD_RPC
        FlxG.plugins.add(new DiscordPlugin());
        #end
    }
}