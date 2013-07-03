function love.conf(t)
	t.title = "PsyChObALL"
	t.author = "Yan Couto and Ricardo Lira"
	t.url = "http://uspgamedev.org/projetos/psychoball/"
    t.identity = "PsyChObALL"
    t.version = "0.8.0"
    t.console = false
    t.release = false
    t.screen.width = 1080
    t.screen.height = 720
    t.screen.fullscreen = false
    t.screen.vsync = false
    t.screen.fsaa = 0
    t.modules.joystick = false
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