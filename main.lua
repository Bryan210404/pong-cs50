Class = require 'class'
push = require 'push'
require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

-- Inicialización de las variables de puntuación
player1Score = 0
player2Score = 0

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    player1 = Paddle(10, VIRTUAL_HEIGHT / 2 - 20, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT / 2 - 20, 5, 20)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    gameState = 'start'
end

function love.update(dt)
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- Simple AI para la paleta del jugador 2
    if ball.y < player2.y + player2.height / 2 then
        player2.dy = -PADDLE_SPEED
    elseif ball.y > player2.y + player2.height / 2 then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    player1:update(dt)
    player2:update(dt)
    ball:update(dt)

    if ball:collides(player1) then
        ball.dx = -ball.dx * 1.03
        ball.x = player1.x + player1.width
        sounds['paddle_hit']:play()
    end
    if ball:collides(player2) then
        ball.dx = -ball.dx * 1.03
        ball.x = player2.x - ball.width
        sounds['paddle_hit']:play()
    end

    if ball.y <= 0 then
        ball.y = 0
        ball.dy = -ball.dy
        sounds['wall_hit']:play()
    end
    if ball.y >= VIRTUAL_HEIGHT - ball.height then
        ball.y = VIRTUAL_HEIGHT - ball.height
        ball.dy = -ball.dy
        sounds['wall_hit']:play()
    end

    if ball.x < 0 then
        servingPlayer = 1
        player2Score = player2Score + 1
        ball:reset()
        gameState = 'start'
        sounds['score']:play()
    end
    if ball.x > VIRTUAL_WIDTH then
        servingPlayer = 2
        player1Score = player1Score + 1
        ball:reset()
        gameState = 'start'
        sounds['score']:play()
    end
end

function love.keypressed(key)
    if key == 'return' then
        if gameState == 'start' then
            gameState = 'play'
        end
    end
    if key == 'escape' then
        love.event.quit()
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    love.graphics.setFont(smallFont)

    if gameState == 'start' then
        love.graphics.printf('Welcome to Pong!', 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Play!', 0, 32, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        love.graphics.setFont(scoreFont)
        love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
        love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

        player1:render()
        player2:render()
        ball:render()
    end

    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

