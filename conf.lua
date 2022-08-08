if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end
io.stdout:setvbuf("no")
if arg[#arg] == "-debug" then require("mobdebug").start() end -- debug pas à pas

function love.conf(t)
  t.console = false

  t.window.title = "Curse of Paradise Islands - Weekly GameJam Week 264"
  t.window.icon = "datas/images/logo/icon.png"
  t.window.width = 1024
  t.window.height = 768
  t.window.resizable = false
  t.window.fullscreen = false
  t.window.fullscreentype = "desktop"
end