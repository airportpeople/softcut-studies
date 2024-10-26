-- softcut study 1: basics
--
-- E1 rate
-- E2 loop start
-- E3 loop length
-- K2 start
-- K3 stop

 -- note: audio files must be 48kHz for accurate playback and looping
file = _path.dust.."audio/ap/f9m/1_pad_1.wav"
rate = 1.0
loop_start = 1.0
loop_len = 1.0
loop_end = loop_start + loop_len

function init()
  -- print file information (see function at the bottom)
  print_info(file)

  -- clear buffer
  softcut.buffer_clear()
  -- read file into buffer
  -- buffer_read_mono (file, start_src, start_dst, dur, ch_src, ch_dst)
  softcut.buffer_read_mono(file,0,1,-1,1,1)
  
  -- enable voice 1
  softcut.enable(1,1)
  -- set voice 1 to buffer 1
  softcut.buffer(1,1)
  -- set voice 1 level to 1.0
  softcut.level(1,1.0)
  -- voice 1 enable loop
  softcut.loop(1,1)
  -- set voice 1 loop start to 1
  softcut.loop_start(1,1)
  -- set voice 1 loop end to 2
  softcut.loop_end(1,2)
  -- set voice 1 position to 1
  softcut.position(1,1)
  -- set voice 1 rate to 1.0
  softcut.rate(1,1.0)
  -- enable voice 1 play
  softcut.play(1,1)
end

function enc(n,d)
  if n==1 then
    rate = util.clamp(rate+d/2,-4,4)
    softcut.rate(1,rate)
  elseif n==2 then
    loop_start = util.clamp(loop_start+d/10,1,duration)
    softcut.loop_start(1,loop_start)
  elseif n==3 then
    loop_len = util.clamp(loop_len+d/10,1,duration - loop_start)
  end

  loop_end = loop_start + loop_len
  softcut.loop_end(1,loop_end)

  redraw()
end

function key(n,z)
  -- start
  if n == 2 and z == 1 then
    softcut.play(1, 1)
  -- stop
  elseif n == 3 and z == 1 then
    softcut.play(1, 0)
  end
end

function redraw()
  screen.clear()
  screen.move(10,20)
  screen.text("rate: ")
  screen.move(118,20)
  screen.text_right(string.format("%.2f",rate))
  screen.move(10,30)
  screen.text("loop_start: ")
  screen.move(118,30)
  screen.text_right(string.format("%.2f",loop_start))
  screen.move(10,40)
  screen.text("loop_len: ")
  screen.move(118,40)
  screen.text_right(string.format("%.2f",loop_len))
  screen.move(10,60)
  screen.text("loop_end: ")
  screen.move(118,60)
  screen.text_right(string.format("%.2f",loop_end))
  screen.update()
end


function print_info(file)
  if util.file_exists(file) == true then
    local ch, samples, samplerate = audio.file_info(file)
    duration = samples/samplerate
    print("loading file: "..file)
    print("  channels:\t"..ch)
    print("  samples:\t"..samples)
    print("  sample rate:\t"..samplerate.."hz")
    print("  duration:\t"..duration.." sec")
  else print "read_wav(): file not found" end
end
