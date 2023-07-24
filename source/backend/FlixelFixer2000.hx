package backend;

#if windows
import lime.media.AudioManager;
import flixel.system.FlxSound;

@:buildXml('
<target id="haxe">
	<lib name="dwmapi.lib" if="windows" />
	<lib name="shell32.lib" if="windows" />
	<lib name="gdi32.lib" if="windows" />
	<lib name="ole32.lib" if="windows" />
	<lib name="uxtheme.lib" if="windows" />
</target>
')

// majority is taken from microsofts doc 
@:cppFileCode('
#include "mmdeviceapi.h"
#include "combaseapi.h"
#include <iostream>
#include <Windows.h>
#include <cstdio>
#include <tchar.h>
#include <dwmapi.h>
#include <winuser.h>
#include <Shlobj.h>
#include <wingdi.h>
#include <shellapi.h>
#include <uxtheme.h>

#define SAFE_RELEASE(punk)  \\
			  if ((punk) != NULL)  \\
				{ (punk)->Release(); (punk) = NULL; }

static long lastDefId = 0;

class AudioFixClient : public IMMNotificationClient {
	LONG _cRef;
	IMMDeviceEnumerator *_pEnumerator;
	
	public:
	AudioFixClient() :
		_cRef(1),
		_pEnumerator(NULL)
	{
		HRESULT result = CoCreateInstance(__uuidof(MMDeviceEnumerator),
							  NULL, CLSCTX_INPROC_SERVER,
							  __uuidof(IMMDeviceEnumerator),
							  (void**)&_pEnumerator);
		if (result == S_OK) {
			_pEnumerator->RegisterEndpointNotificationCallback(this);
		}
	}

	~AudioFixClient()
	{
		SAFE_RELEASE(_pEnumerator);
	}

	ULONG STDMETHODCALLTYPE AddRef()
	{
		return InterlockedIncrement(&_cRef);
	}

	ULONG STDMETHODCALLTYPE Release()
	{
		ULONG ulRef = InterlockedDecrement(&_cRef);
		if (0 == ulRef)
		{
			delete this;
		}
		return ulRef;
	}

	HRESULT STDMETHODCALLTYPE QueryInterface(
								REFIID riid, VOID **ppvInterface)
	{
		return S_OK;
	}

	HRESULT STDMETHODCALLTYPE OnDeviceAdded(LPCWSTR pwstrDeviceId)
	{
		return S_OK;
	};

	HRESULT STDMETHODCALLTYPE OnDeviceRemoved(LPCWSTR pwstrDeviceId)
	{
		return S_OK;
	}

	HRESULT STDMETHODCALLTYPE OnDeviceStateChanged(
								LPCWSTR pwstrDeviceId,
								DWORD dwNewState)
	{
		return S_OK;
	}

	HRESULT STDMETHODCALLTYPE OnPropertyValueChanged(
								LPCWSTR pwstrDeviceId,
								const PROPERTYKEY key)
	{
		return S_OK;
	}

	HRESULT STDMETHODCALLTYPE OnDefaultDeviceChanged(
		EDataFlow flow, ERole role,
		LPCWSTR pwstrDeviceId)
	{
		::funkin::backend::_hx_system::Main_obj::audioDisconnected = true;
		return S_OK;
	};
};

AudioFixClient *curAudioFix;
')
#end

class FlixelFixer2000 {
    public static var audioDisconnected:Bool = false;
    public static var changeID:Int = 0;

    public static function fix() {
        // DPI blur fix for windows
        #if windows
        untyped __cpp__('
            SetProcessDPIAware();
        ');
        #end

        // Audio fix when switch device for windows as well (only works on state switches)
        #if windows
        untyped __cpp__('
            curAudioFix = new AudioFixClient();
        ');
        FlxG.signals.preStateCreate.add((_) -> fixAudio());
        #end
        
        // "+" key not working fix for macos (by Ne_Eo)
        #if mac
        @:privateAccess FlxG.keys._nativeCorrection.set("0_43", FlxKey.PLUS);
        #end
    }

    #if windows
    public static function fixAudio() {
        if (audioDisconnected) {
            // Restart audio manager
            var playingList:Array<PlayingSound> = [];
            for(e in FlxG.sound.list) {
                if (e.playing) {
                    playingList.push({
                        sound: e,
                        time: e.time
                    });
                    e.stop();
                }
            }
            if (FlxG.sound.music != null)
                FlxG.sound.music.stop();

            AudioManager.shutdown();
            AudioManager.init();
            changeID++;

            for(e in playingList) {
                e.sound.play(e.time);
                e.sound.time = e.time;
            }

            audioDisconnected = false;
        }
    }
    #end
}

typedef PlayingSound = {
	var sound:FlxSound;
	var time:Float;
}