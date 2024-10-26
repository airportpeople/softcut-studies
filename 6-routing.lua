-- softcut study 6
-- routing
--
-- K2 clear buffer
-- K3 reload audio file
--
-- accepts audio input

file = _path.dust.."code/softcut-studies/lib/whirl1.aif"

feed = 1.0
preserve = 0.25
mix = 0
level_1 = 1
level_2 = 1

positions = {0,0}

m = metro.init()
m.time = 0.5
m.event = function()
  m.time = 0.1+math.random()
  softcut.position(2,1+math.random()*4)
end

function update_positions(i,pos)
  positions[i] = pos - 1
  redraw()
end

function init()
  softcut.buffer_clear()
  softcut.buffer_read_mono(file,0,1,-1,1,1)

	audio.level_adc_cut(1)
	-- audio.level_adc_cut(2)
  softcut.level_input_cut(1,2,1)
  softcut.level_cut_cut(1,2,1)

  -- sample player
  softcut.enable(1,1)
  softcut.buffer(1,1)
  softcut.loop_start(1,1)
  softcut.loop_end(1,5)
  softcut.loop(1,1)
  softcut.position(1,1)
  softcut.rate(1,1)
  softcut.play(1,1)
  softcut.level(1,1)
 
  -- record head
  softcut.enable(2,1)
  softcut.buffer(2,2)  -- record on buffer 2
  softcut.rate(2,1)
  softcut.loop(2,1)
  softcut.loop_start(2,1)
  softcut.loop_end(2,5)
  softcut.position(2,2)
  softcut.play(2,1)
  softcut.rec(2,1)
  softcut.rec_level(2,0.75)
  softcut.pre_level(2,0.25)
  softcut.level(2,1)
  softcut.fade_time(2,0.02)

  softcut.phase_quant(1,0.025)
  softcut.phase_quant(2,0.025)
  softcut.event_phase(update_positions)
  softcut.poll_start_phase()

  m:start()
end

function enc(n,d)
  if n==1 then
    feed = util.clamp(feed+d/20,0,1)
    softcut.level_cut_cut(1,2,feed)
  elseif n==2 then
    preserve = util.clamp(preserve+d/100,0,0.25)
    softcut.pre_level(2,preserve)
  else
    -- mix between buffers
    mix = util.clamp(mix + d/10, -1, 1)
    level_1 = mix > 0 and 1 - mix or 1
    level_2 = mix < 0 and 1 + mix or 1

    softcut.level(1, level_1)
    softcut.level(2, level_2)
  end
  redraw()
end

function key(n,z)
  if n==2 and z==1 then
    softcut.buffer_clear()
  elseif n==3 and z==1 then
    softcut.buffer_read_mono(file,0,1,-1,1,1)
  end
end


function redraw()
  screen.clear()
  screen.move(10,20)
  screen.line_rel(positions[1]*28,0)
  screen.move(10,24)
  screen.line_rel(positions[2]*28,0)
  screen.stroke()
  screen.move(10,40)
  screen.text("feed: ")
  screen.move(118,40)
  screen.text_right(string.format("%.2f",feed))
  screen.move(10,50)
  screen.text("preserve: ")
  screen.move(118,50)
  screen.text_right(string.format("%.2f",preserve))
  screen.move(10,60)
  screen.text("mix: ")
  screen.move(118,60)
  screen.text_right(
    string.format("%.2f", level_1) .. " | " ..
    string.format("%.2f", level_2))
  screen.update()
end

