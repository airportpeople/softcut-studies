-- softcut study 3: cut
-- 
-- E2 fade time
-- E3 metro time (random cut)
-- K* start/stop

file = _path.dust.."/code/softcut-studies/lib/whirl1.aif"

ch_, samples_, samplerate_ = audio.file_info(file)
duration = samples_ / samplerate_

fade_time = 0.01
metro_time = 1.0 

positions = {0,0,0,0}

m = metro.init()
m.time = metro_time

m.event = function()
  for i=1,4 do
    softcut.position(i,1+math.random()*(duration - 1))
  end
end

function update_positions(i,pos)
  positions[i] = pos - 1
  redraw()
end

function startstop()
  playing = not playing
  for i = 1,4 do
    softcut.play(i, playing and 1 or 0)
  end
end

function init()
  softcut.buffer_clear()
  softcut.buffer_read_mono(file,0,1,-1,1,1)

  for i=1,4 do
    softcut.enable(i,1)
    softcut.buffer(i,1)
    softcut.level(i,1.0)
    softcut.pan(i,(i-2.5)*0.5)
    softcut.rate(i,i*0.25)
    softcut.loop(i,1)
    softcut.loop_start(i,1)
    softcut.loop_end(i,duration)
    softcut.position(i,1)
    softcut.play(i,1)
    softcut.fade_time(i,fade_time)
    softcut.phase_quant(i,0.125)
  end

  softcut.event_phase(update_positions)
  softcut.poll_start_phase()

  m:start()
  playing = true
end

function enc(n,d)
  if n==2 then
    fade_time = util.clamp(fade_time+d/100,0,1)
    for i=1,4 do
      softcut.fade_time(i,fade_time)
    end
  elseif n==3 then
    metro_time = util.clamp(metro_time+d/8,0.125,4)
    m.time = metro_time
  end
  redraw()
end

function key(n,z)
  if z == 1 then startstop() end
end

function position_to_line(p)
  -- line is 100 pixels long
  return (p / duration) * 100
end

function redraw()
  screen.clear()
  screen.move(10, 10)
  screen.line(118, 10)
  screen.move(10 + position_to_line(positions[1]), 8)
  screen.line_rel(0, 4)
  screen.move(10 + position_to_line(positions[2]), 8)
  screen.line_rel(0, 4)
  screen.move(10 + position_to_line(positions[3]), 8)
  screen.line_rel(0, 4)
  screen.move(10 + position_to_line(positions[4]), 8)
  screen.line_rel(0, 4)

  screen.move(10,20)
  screen.line_rel(positions[1]*5,0)
  screen.move(40,20)
  screen.line_rel(positions[2]*5,0)
  screen.move(70,20)
  screen.line_rel(positions[3]*5,0)
  screen.move(100,20)
  screen.line_rel(positions[4]*5,0)

  screen.stroke()

  screen.move(10,40)
  screen.text("fade time:")
  screen.move(118,40)
  screen.text_right(string.format("%.2f",fade_time))
  screen.move(10,50)
  screen.text("metro time:")
  screen.move(118,50)
  screen.text_right(string.format("%.2f",metro_time))
  screen.update()
end
