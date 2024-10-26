-- softcut study 7: files
--
-- K1 load backing track
-- K3 save clip
-- works for mono or stereo

-- TODO: figure out the R channel issue

fileselect = require 'fileselect'

saved = "..."
level = 1.0
rec = 1.0
pre = 1.0
length = 1
position = 1
selecting = false

function load_file(file)
  selecting = false
  if file ~= "cancel" then
    ch_, samples_, sample_rate_ = audio.file_info(file)
    print(ch_ .. " " .. samples_ .. " " .. sample_rate_)
    length = samples_/sample_rate_
    if ch_ == 2 then
      softcut.buffer_read_stereo(file, 0, 1, -1, 1, 1)
    else
      softcut.buffer_read_mono(file, 0, 1, -1, 1, 1)
    end
    reset()
  end
end

function update_positions(i,pos)
  position = (pos - 1) / length
  if selecting == false then redraw() end
end

function reset()
  for i=1,4 do
    softcut.enable(i,1)
    softcut.buffer(i,i)
    softcut.level(i,1.0)
    softcut.loop(i,1)
    softcut.loop_start(i,1)
    softcut.loop_end(i,1+length)
    softcut.position(i,1)
    softcut.rate(i,1.0)
    softcut.play(i,1)

    pan = i % 2 == 0 and 1 or -1
    softcut.pan(i, pan)
  end

  for i=3,4 do
    softcut.rec_level(i,rec)
    softcut.pre_level(i,pre)
    softcut.rec(i,1)
  end
end

function init()
  softcut.buffer_clear()

	audio.level_adc_cut(1)
  softcut.level_input_cut(1,3,1.0)
  softcut.level_input_cut(2,4,1.0)

  softcut.phase_quant(1,0.025)
  softcut.event_phase(update_positions)
  softcut.poll_start_phase()

  reset()
end

function key(n,z)
  if n==1 and z==1 then
    selecting = true
    fileselect.enter(_path.dust,load_file)
  elseif n==2 and z==1 then
  elseif n==3 and z==1 then
    saved = "ss7-"..string.format("%04.0f",10000*math.random())..".wav"
    if ch_ == 1 then
      softcut.buffer_write_mono(_path.dust.."/audio/"..saved,1,length,1)
    else
      softcut.buffer_write_stereo(_path.dust.."/audio/"..saved,1,length)
    end
  end
end

function enc(n,d)
  if n==1 then
    level = util.clamp(level+d/100,0,1)
    softcut.level(1,level)
    softcut.level(2,level)
  elseif n==2 then
    rec = util.clamp(rec+d/100,0,1)
    softcut.rec_level(3,rec)
    softcut.rec_level(4,rec)
  elseif n==3 then
    pre = util.clamp(pre+d/100,0,1)
    softcut.pre_level(3,pre)
    softcut.pre_level(4,pre)
  end
  redraw()
end

function redraw()
  screen.clear()
  screen.move(10,10)
  screen.text(saved)
  screen.move(10,20)
  screen.line_rel(position*108,0)
  screen.stroke()
  screen.move(10,30)
  screen.text("1. level: ")
  screen.move(118,30)
  screen.text_right(string.format("%.2f",level))
  screen.move(10,40)
  screen.text("2. rec: ")
  screen.move(118,40)
  screen.text_right(string.format("%.2f",rec))
  screen.move(10,50)
  screen.text("2. pre: ")
  screen.move(118,50)
  screen.text_right(string.format("%.2f",pre))
  screen.update()
end
