# luatui

## setup

```sh
> hererocks -j 2.1 --luarocks latest luarocks
```

```lua
-- luarocks/luarocks/config-5.1.lua
-- remove user tree and fix cmake_generator
cmake_generator = "Visual Studio 17 2022"
```

```sh
> .\luarocks\bin\activate.ps1
> luarocks install luv
> luarocks install luautf8
> luarocks install wcwidth
```

```sh
# pwsh
> $env:LUA_PATH=$null
> lua main.lua
```

## tests

```sh
> luarocks install busted
> busted -v --helper=./tests/_helper.lua ./tests
```
