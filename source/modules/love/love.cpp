#include "love.h"
#include "common/version.h"
#include "common/runtime.h"

extern int graphicsInit(lua_State * L);
extern int filesystemInit(lua_State * L);
extern int systemInit(lua_State * L);
extern int timerInit(lua_State * L);
extern int audioInit(lua_State * L);
extern int keyboardInit(lua_State * L);

extern int initSourceClass(lua_State * L);
extern int initFileClass(lua_State * L);
extern int initImageClass(lua_State * L);

struct { char *name; int (*fn)(lua_State *L); } modules[] = 
{
	{"graphics",	graphicsInit	},
	{"filesystem",	filesystemInit	},
	{"system",		systemInit		},
	{"timer",		timerInit		},
	{"audio",		audioInit		},
	{"keyboard",	keyboardInit	},
	{0}
};

int loveGetVersion(lua_State * L)
{
	lua_pushinteger(L, love::VERSION_MAJOR);
	lua_pushinteger(L, love::VERSION_MINOR);
	lua_pushinteger(L, love::VERSION_REVISION);
	lua_pushstring(L, love::CODENAME);

	return 4;
}

int lastTouch[2];
int loveScan(lua_State * L)
{
	hidScanInput();

	u32 circleHeld;

	touchPosition touch;
	
	u32 keyDown = hidKeysDown();
	u32 keyHeld = hidKeysHeld();
	u32 keyUp = hidKeysUp();

	hidTouchRead(&touch);

	for (int i = 0; i < 32; i++)
	{
		if (keyDown & BIT(i))
		{	
			if (strcmp(BUTTONS[i], "touch") != 0)
			{
				lua_getfield(L, LUA_GLOBALSINDEX, "love");
				lua_getfield(L, -1, "keypressed");
				lua_remove(L, -2);

				if (!lua_isnil(L, -1))
				{
					lua_pushstring(L, BUTTONS[i]);
					lua_call(L, 1, 0);
				}
			}
		}
	}

	for (int i = 0; i < 32; i++)
	{
		if (keyUp & BIT(i))
		{	
			if (strcmp(BUTTONS[i], "touch") != 0)
			{
				lua_getfield(L, LUA_GLOBALSINDEX, "love");
				lua_getfield(L, -1, "keyreleased");
				lua_remove(L, -2);

				if (!lua_isnil(L, -1))
				{
					lua_pushstring(L, BUTTONS[i]);
					lua_call(L, 1, 0);
				}
			}
		}
	}

	for (int i = 0; i < 32; i++)
	{
		if (keyDown & BIT(20))
		{	
			lua_getfield(L, LUA_GLOBALSINDEX, "love");
			lua_getfield(L, -1, "mousepressed");
			lua_remove(L, -2);

			lastTouch[0] = touch.px;
			lastTouch[1] = touch.px;

			if (!lua_isnil(L, -1))
			{
				lua_pushinteger(L, lastTouch[0]);
				lua_pushinteger(L, lastTouch[1]);
				lua_pushinteger(L, 1);

				lua_call(L, 3, 0);
			}
		}
	}

	for (int i = 0; i < 32; i++)
	{
		if (keyUp & BIT(20))
		{	
			lua_getfield(L, LUA_GLOBALSINDEX, "love");
			lua_getfield(L, -1, "mousereleased");
			lua_remove(L, -2);

			lastTouch[0] = touch.px;
			lastTouch[1] = touch.px;

			if (!lua_isnil(L, -1))
			{
				lua_pushinteger(L, lastTouch[0]);
				lua_pushinteger(L, lastTouch[1]);
				lua_pushinteger(L, 1);

				lua_call(L, 3, 0);
			}
		}
	}

	return 0;
}

int loveInit(lua_State * L)
{
	int (*classes[])(lua_State *L) = {
		initSourceClass,
		initFileClass,
		initImageClass,
		NULL,
	};

	for (int i = 0; classes[i]; i++) {
		classes[i](L);
		lua_pop(L, 1);
	}

	luaL_Reg reg[] = 
	{
		{ "getVersion",	loveGetVersion },
		{ 0, 0 },
	};

	luaL_newlib(L, reg);

	for (int i = 0; modules[i].name; i++)
	{
		modules[i].fn(L);
		lua_setfield(L, -2, modules[i].name);
	}

	return 1;
}