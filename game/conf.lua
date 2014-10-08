function love.conf(t)
	t.title = "PsyChObALL"
	t.author = "Yan Couto and Ricardo Lira"
	t.url = "http://uspgamedev.org/projetos/psychoball/"
    t.identity = "PsyChObALL"
    t.version = "0.9.1"
    t.console = false
    t.release = true
    t.window.width = 1080
    t.window.height = 720
    t.window.fullscreen = false
    t.window.vsync = true
    t.window.fsaa = 0
    t.modules.joystick = true
    t.modules.audio = true
    t.modules.keyboard = false
    t.modules.event = true
    t.modules.image = true
    t.modules.graphics = true
    t.modules.timer = true
    t.modules.mouse = true
    t.modules.sound = true
    t.modules.physics = false
end