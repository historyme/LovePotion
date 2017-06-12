#include "common/runtime.h"
#include "audio.h"
#include "wrap_source.h"
#include "source.h"

using love::Audio;

int Audio::Stop(lua_State * L) { // love.audio.stop()

	for (int i = 0; i <= 23; i++)
		ndspChnWaveBufClear(i);

	return 0;

}

int audioInit(lua_State * L)
{
	luaL_Reg reg[] = 
	{
		{ "newSource",	sourceNew			},
		{ "stop",		love::Audio::Stop	},
		{ 0, 0 },
	};

	luaL_newlib(L, reg);
	
	return 1;
}