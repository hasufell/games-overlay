dofile("build/options.lua")

solution "TEngine"
	configurations { "Debug", "Release" }
	objdir "obj"
	defines {"GLEW_STATIC"}
	if _OPTIONS.force32bits then buildoptions{"-m32"} linkoptions{"-m32"} libdirs{"/usr/lib32"} end
	if _OPTIONS.relpath then linkoptions{"-Wl,-rpath -Wl,\\\$\$ORIGIN/lib "} end

	includedirs {
		"src",
		"src/luasocket",
		"src/fov",
		"src/expat",
		"src/lxp",
		"src/libtcod_import",
		"src/physfs",
		"src/zlib",
		"src/bzip2",
		"/opt/SDL-2.0/include/SDL2",
		"/usr/include/GL",
	}
	if _OPTIONS.lua == "default" then includedirs{"src/lua"}
	elseif _OPTIONS.lua == "jit2" then includedirs{"src/luajit2/src", "src/luajit2/dynasm",}
	end

if _OPTIONS.steam then
	dofile("steamworks/build/steam-def.lua")
end

configuration "bsd"
	libdirs {
		"/usr/local/lib",
	}
	includedirs {
		"/usr/local/include",
	}

configuration "windows"
	libdirs {
		"/c/code/SDL/lib",
	}
	includedirs {
		"/c/code/SDL/include/SDL2",
		"/c/code/SDL/include",
		"/c/mingw2/include/GL",
	}

configuration "macosx"
	buildoptions { "-isysroot /Developer/SDKs/MacOSX10.6.sdk", "-mmacosx-version-min=10.6" }


configuration "Debug"
	defines { }
	flags { "Symbols" }
	buildoptions { "-ggdb" }
	buildoptions { "-O3" }
	targetdir "bin/Debug"
	if _OPTIONS.luaassert then defines {"LUA_USE_APICHECK"} end
	if _OPTIONS.pedantic then buildoptions { "-Wall" } end

configuration "Release"
	defines { "NDEBUG=1" }
	flags { "Optimize", "NoFramePointer" }
	buildoptions { "-O2" }
	targetdir "bin/Release"


--dofile("build/runner.lua")
dofile("build/te4core.lua")
