--[[
################################################################################
# 
# Copyright (c) 2014-2017 Ultraschall (http://ultraschall.fm)
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# 
################################################################################
]] 

-- Ultraschall Functions-API
-- include the following lines (without the -- comment-characters of course ;) )
-- to get access to the Ultraschall functions API within your script:
--
-- local info = debug.getinfo(1,'S');
-- script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
-- US_API = dofile(script_path .. "ultraschall_functions_api.lua")

-------------------------------------
--- ULTRASCHALL - API - FUNCTIONS ---
-------------------------------------

---------------------------
---- US Little Helpers ----
---------------------------

ultraschall.Msg=function(val)
-- prints a message to the Reaper Console
-- val - your message as a string

  reaper.ShowConsoleMsg(tostring(val).."\n")
end


ultraschall.RoundNumber=function(num)
    if tonumber(num)==nil then return nil end
    num=tonumber(num)
    return num % 1 >= 0.5 and math.ceil(num) or math.floor(num)
end


ultraschall.ApiFunctionTest=function()
  reaper.MB("Ultraschall Functions API works","Ultraschall-API",0)
end


ultraschall.GetPath=function(str,sep)
-- return the path of a filename-string
-- -1 if it doesn't work
local  result=str:match("(.*"..sep..")")
  if result==nil then result="-1" end
  return result
end


ultraschall.GetPartialString=function(str,sep1,sep2)
-- returns the part of a string between sep1 and sep2
--
-- str-string to be processed
-- sep1 - seperator on the "left" side of the string
-- sep2 - seperator on the "right" side of the string
-- returns -1 if it doesn't work, no sep1 or sep2 exist

  if str==nil or sep1==nil or sep2==nil then return -1 end
    local start=sep1:len()
    local stop=sep2:len()
  if sep1=="%" then sep1="%%" end
  if sep2=="%" then sep2="%%" end
  if sep1=="." then sep1="%." end
  if sep2=="." then sep2="%." end
    
   local result=str:match("("..sep1..".*"..sep2..")")
  if result==nil then result="" end

   local endresult=result:sub(1+start,-1-stop)
    
  if endresult==nil then endresult="-1" end
      return endresult
  end
  

ultraschall.SecondsToTime=function(pos)
-- converts timeposition in seconds(pos) to a timestring (h)hh:mm:ss.ms
  local hours=0
  local minutes=0
  local seconds=0
  local milliseconds=0
  local temp=0
  local tempo=0
  local tempo2=0
  local trailinghour=""
  local trailingminute=""
  local trailingsecond="" 
  local trailingmilli=""
  
      if pos>=3600 then temp=tostring(pos/3600) hours=tonumber(temp:match("%d*")) pos=pos-(3600*hours) end
        if pos>=60 then temp=tostring(pos/60) minutes=tonumber(temp:match("(%d*)")) pos=pos-(60*minutes) end
        temp=tostring(pos)
        seconds=pos
        tempo=tostring(seconds)
        tempo2=tempo:match("%.%d*")
        if tempo2==nil then tempo2=".0" end
        milliseconds=tempo2:sub(2,4)
        if milliseconds:len()==2 then milliseconds=milliseconds.."0" end
        if milliseconds:len()==1 then milliseconds=milliseconds.."00" end
        if seconds==nil then seconds=0.0 end        
        if hours<10 then trailinghour="0" else trailinghour="" end
        if minutes<10 then trailingminute="0" else trailingminute="" end
        if seconds<10 then trailingsecond="0" else trailingsecond="" end
        seconds=tostring(seconds)
        seconds=seconds:match("%d*.")
        if seconds:sub(-1,-1)=="." then seconds=seconds:sub(1,-2) end
    return trailinghour..hours..":"..trailingminute..minutes..":"..trailingsecond..seconds.."."..milliseconds
end


ultraschall.TimeToSeconds=function(timestring)
-- converts a timestring (h)hh:mm:ss.ms to timeposition in seconds
local hour=""
local milliseconds=""
local minute=""
local seconds=""
local time=""

if timestring==nil then return -1 end
if tonumber(timestring)~=nil then return -1 end
    hour=timestring:match("%d*:")
    if hour==nil then return -1 end
    hour=hour:sub(1,-2)
    if hour=="" then return -1 end
  
    minute=timestring:match(":%d*:")
    if minute==nil then return -1 end
    minute=minute:sub(2,-2)
    if minute=="" then return -1 end
  
    seconds=timestring:match(":%d*%.")
    if seconds==nil then return -1 end
    seconds=seconds:sub(2,-2)
    if seconds=="" then return -1 end

    milliseconds=timestring:match("%.%d*")
    if milliseconds==nil then milliseconds=0 end
    if milliseconds=="" then milliseconds=".0 " end
    if milliseconds=="0" then milliseconds=".0 " end
    if milliseconds==0 then milliseconds=".0 " end
    if milliseconds=="." then milliseconds=0 end
    
    time=(hour*3600)+(minute*60)+seconds+milliseconds
    if time<0 then return -1 end
    return time
end


ultraschall.RunCommand=function(actioncommand_id)  
-- runs a command by its ActionCommandID(instead of the CommandID-number)

  local command_id = reaper.NamedCommandLookup(actioncommand_id)
  reaper.Main_OnCommand(command_id,0) 

end


ultraschall.Notes2CSV=function()
-- returns the project's notes as a CSV(retval)
  local csv = ""
  local linenumber=1
  local notes = reaper.GetSetProjectNotes(0, false, "")
    for line in notes:gmatch"[^\n]*" do
      csv = csv .. "," .. line --escapeCSV(line)
    end
    
    local retval= string.sub(csv, 2) -- remove first ","
  return retval
end


ultraschall.CSV2Line=function(csv_line)
-- converts a csv to a "clean" line without the ,-seperators
  if csv_line==nil then return -1 end
  if tonumber(csv_line)~=nil then return -1 end
  local clean=""
  local result=csv_line
  local countcomma=0

  for i=1, result:len() do
    if result:sub(i,i)~="," then clean=clean..result:sub(i,i) 
    else countcomma=countcomma+1 
    end
  end

  return clean
end


ultraschall.RGB2Num=function(red, green, blue)
-- converts individual rgb values to an integer
-- negative values are allowed, so you can use this function to subtract colorvalues
-- MAC OR WINDOWS?  
if tonumber(red)==nil then return -1 end
if tonumber(green)==nil then return -1 end
if tonumber(blue)==nil then return -1 end
  
  green = green * 256
  blue = blue * 256 * 256
  
  return red + green + blue

end


ultraschall.CSV2IndividualLines=function(csv_line)
-- converts a csv to an array with all individual values without the ,-seperators
  if csv_line==nil then return -1 end

  local result=csv_line
  local temp=""
  local count=1
  local comma_pos=0
  local line_array={}
  local pos_array={}

for i=1, result:len() do
  if result:sub(i,i)~="," then 
    if result:sub(i,i)~=nil then temp=temp..result:sub(i,i) 
    else line_array[count]=""
    end
  else line_array[count]=temp count=count+1 comma_pos=i temp=""
  end
end
line_array[count]=result:sub(comma_pos+1,-1)

  return line_array
end



ultraschall.RGB2Grayscale=function(red,green,blue)
--converts rgb to a grayscale value
-- Parameters: 
-- red - red-color-value 0-255
-- green - green-color-value 0-255
-- blue - blue-color-value 0-255

  if tonumber(red)==nil or tonumber(red)<0 or tonumber(red)>255 then return -1 end
  if tonumber(green)==nil or tonumber(green)<0 or tonumber(green)>255 then return -1 end
  if tonumber(blue)==nil or tonumber(blue)<0 or tonumber(blue)>255 then return -1 end

  local gray=red+green+blue
  gray=ultraschall.RoundNumber(gray/3)
  local gray_color=reaper.ColorToNative(gray,gray,gray)
return ultraschall.RoundNumber(gray_color)
end


ultraschall.IsItemInTrack=function(tracknumber, itemIDX)
--returns true, if the itemIDX is part of track tracknumber, false if not, -1 if no such itemIDX or Tracknumber available
-- itemIDX - the number of the Item to check of
-- integer tracknumber - the number of the track to check in

if tonumber(itemIDX)==nil then return -1 end
if tonumber(tracknumber)==nil then return -1 end

--reaper.MB(tracknumber,itemIDX,0)

local itemIDX=tonumber(itemIDX)
local tracknumber=tonumber(tracknumber)

if tracknumber>reaper.CountTracks(0) or tracknumber<0 then return -1 end
if itemIDX>reaper.CountMediaItems(0)-1 or itemIDX<0 then return -1 end

local MediaTrack=reaper.GetTrack(0, tracknumber)

local MediaItem=reaper.GetMediaItem(0, itemIDX)
local MediaTrack2=reaper.GetMediaItem_Track(MediaItem)

if MediaTrack==MediaTrack2 then return true end
if MediaTrack~=MediaTrack2 then return false end


end

--AA=ultraschall.IsItemInTrack(0, 1)

ultraschall.WriteValueToFile=function(filename_with_path, value)
  -- Writes value to filename_with_path
  -- Keep in mind, that you need to escape \ by writing \\, or it will not work
  if filename_with_path == nil then return -1 end
  if value==nil then return -1 end
  local file=io.open(filename_with_path,"w")
  if file==nil then return -1 end
  file:write(tostring(value))
  file:close()
  return 1
end

--A=ultraschall.WriteValueToFile("c:\\hui.txt","Oh")

ultraschall.WinColorToMacColor=function()
end

ultraschall.MacColorToWinColor=function()
end

ultraschall.CreateShownoteArray=function()
--creates and returns a shownotearray with no entry set
  return ShownoteArray
end

ultraschall.NumberRangeAsCsvOfNumbers=function(firstnumber, lastnumber, step)
-- returns a string with the all numbers from firstnumber to lastnumber, seperated by a ,
-- e.g. firstnumber=4, lastnumber=8 -> 4,5,6,7,8
-- firstnumber - the number, with which the string starts
-- lastnumber - the number, with which the string ends
-- step - how many numbers shall be skipped inbetween. Can lead to a different lastnumber, if not 1 ! nil=1
  if tonumber(firstnumber)==nil then return nil end
  if tonumber(lastnumber)==nil then return nil end
  if tonumber(step)==nil then step=1 end
    
  firstnumber=tonumber(firstnumber)
  lastnumber=tonumber(lastnumber)
  step=tonumber(step)
  
  local trackstring=""
  for i=firstnumber, lastnumber, step do
    trackstring=trackstring..","..tostring(i)
  end
  return trackstring:sub(2,-1)
end



------------------------------------
---- Ultraschall.ini Management ----
------------------------------------

ultraschall.SetUSExternalState=function(section, key, value)
-- stores value into ultraschall.ini
-- returns true if sucessful, false if unsucessful
  if section==nil then return -1 end
  if key==nil then return -1 end
  if value==nil then return -1 end

  if section:match(".*%=.*") then return -1 end

  return reaper.BR_Win32_WritePrivateProfileString(section, key, value, reaper.GetResourcePath().."\\ultraschall.ini")
end

--A=ultraschall.SetUSExternal("te=s10to","cowb[sfijdfd]oy bebop2","Howde[]eho")
--AA=ultraschall.SetUSExternalState("tes89to","cafdfaaowbsfijdfdoy bebop2","Howdeeho")

ultraschall.GetUSExternalState=function(section, key)
-- gets a value from ultraschall.ini
-- returns length of entry(integer) and the entry itself(string)
  if section==nil then return -1 end
  if key==nil then return -1 end
  
  return reaper.BR_Win32_GetPrivateProfileString(section, key, -1, reaper.GetResourcePath().."\\ultraschall.ini")
end

--A,AA=ultraschall.GetUSExternalState("tes89to","cafdfaaowbsfijdfdoy bebop2")

ultraschall.CountUSExternalState_sec=function()
--count number of sections in the ultraschall.ini
  local count=0
  
  for line in io.lines(reaper.GetResourcePath().."\\ultraschall.ini") do
    local check=line:match(".*=.*")
    if check==nil then check="" count=count+1 end
  end
  return count
end

--A=ultraschall.CountUSExternalState_sec()

ultraschall.CountUSExternalState_key=function(section)
--count number of keys in the section in ultraschall.ini
  local count=0
  local startcount=0
  
  for line in io.lines(reaper.GetResourcePath().."\\ultraschall.ini") do
   local check=line:match("%[.*.%]")
    if startcount==1 and line:match(".*=.*") then
      count=count+1
    else
      startcount=0
    if "["..section.."]" == check then startcount=1 end
    if check==nil then check="" end
    end

  end
  return count
end

--A=ultraschall.CountUSExternalState_key("tes89to")

ultraschall.EnumerateUSExternalState_sec=function(number)
-- returns name of the numberth section in ultraschall.ini or nil, if invalid
  if tonumber(number)==nil then return nil end
  local number=tonumber(number)
  if number<=0 then return -1 end
  if number>ultraschall.CountUSExternalState_sec() then return nil end
  
  local count=0
    for line in io.lines(reaper.GetResourcePath().."\\ultraschall.ini") do
      local check=line:match(".*=.*")
      if check==nil then count=count+1 end
      if count==number then return line end
    end
end

--A=ultraschall.EnumerateUSExternalState_sec(1)

ultraschall.EnumerateUSExternalState_key=function(section, number)
-- returns name of a numberth key within a section in ultraschall.ini or nil if invalid or not existing

  if section==nil then return nil end
  local count=0
  local startcount=0
  
    for line in io.lines(reaper.GetResourcePath().."\\ultraschall.ini") do
     local check=line:match("%[.*.%]")
        if startcount==1 and line:match(".*=.*") then
        count=count+1
        if count==number then local temp=line:match(".*=") return temp:sub(1,-2) end
     else
        startcount=0
        if "["..section.."]" == check then startcount=1 end
        if check==nil then check="" end
    end

  end
  return nil
end


--ALAMO=ultraschall.EnumerateUSExternalState_key("tes89to",1)


--ALABAMSA=ultraschall.CountUSExternalState_key("tes6to")


ultraschall.CountSectionsByPattern=function(pattern)
--uses "pattern"-string to determine, hof often a section with a certain pattern exists. Good for sections, that have a number in them, like
--[section1], [section2], [section3]
--returns the number of sections, that include that pattern
--refer pattern-matching for lua for more details
--pattern - the pattern to look for
end

ultraschall.CountKeysByPattern=function(pattern)
--uses "pattern"-string to determine, hof often a key with a certain pattern exists. Good for keys, that have a number in them, like
--key1, key2, key3
--returns the number of sections, that include that pattern
--refer pattern-matching for lua for more details
--pattern - the pattern to look for
end

ultraschall.CountValuesByPattern=function(pattern)
--uses "pattern"-string to determine, hof often a value with a certain pattern exists. Good for values, that have a number in them, like
--value1, value2, value3
--returns the number of sections, that include that pattern
--refer pattern-matching for lua for more details
--pattern - the pattern to look for
end


ultraschall.EnumerateSectionsByPattern=function(pattern,id)
--uses "pattern"-string to determine, hof often a section with a certain pattern exists. Good for sections, that have a number in them, like
--[section1], [section2], [section3]
--returns the full section-name of the "id"-th section, that fits the pattern description
--refer pattern-matching for lua for more details
--pattern - the pattern to look for
--id - the number of the section, that fits that pattern scheme
end

ultraschall.EnumerateKeysByPattern=function(pattern,id)
--uses "pattern"-string to determine, hof often a key with a certain pattern exists. Good for keys, that have a number in them, like
--key1, key2, key3
--returns the full key-name of the "id"-th key, that fits the pattern description
--refer pattern-matching for lua for more details
--pattern - the pattern to look for
--id - the number of the key, that fits that pattern scheme
end

ultraschall.EnumerateValuesByPattern=function(pattern,id)
--uses "pattern"-string to determine, hof often a value with a certain pattern exists. Good for values, that have a number in them, like
--values1, value2, value3
--returns the full value of the "id"-th value, that fits the pattern description
--refer pattern-matching for lua for more details
--pattern - the pattern to look for
--id - the number of the value, that fits that pattern scheme
end


--------------------------
---- Get Track States ----
--------------------------

-- TODO:
--<FXCHAIN
--<FXCHAIN_REC
--HWOUT a b c d e f g h:U i - HW-destination, as set in the routing-matrix, as well as in the Destination "Controls for Track"-dialogue. There are as many HWOuts as outputchannels.
--                            a - outputchannel, with 1024+x the individual hw-outputchannels, 0,2,4,etc stereo output channels
--                            b - 0-post-fader(post pan), 1-preFX, 3-pre-fader(Post-FX), as set in the Destination "Controls for Track"-dialogue
--                            c - volume, as set in the Destination "Controls for Track"-dialogue
--                            d - pan, as set in the Destination "Controls for Track"-dialogue
--                            e - mute, 1-on, 0-off, as set in the Destination "Controls for Track"-dialogue
--                            f - Phase, 1-on, 0-off, as set in the Destination "Controls for Track"-dialogue
--                            g - source, as set in the Destination "Controls for Track"-dialogue
--                                    -1 - None
--                                     0 - Stereo Source 1/2
--                                     4 - Stereo Source 5/6
--                                    12 - New Channels On Sending Track Stereo Source Channel 13/14
--                                    1024 - Mono Source 1
--                                    1029 - Mono Source 6
--                                    1030 - New Channels On Sending Track Mono Source Channel 7
--                                    1032 - New Channels On Sending Track Mono Source Channel 9
--                                    2048 - MultiChannel 4 Channels 1-4
--                                    2050 - Multichannel 4 Channels 3-6
--                                    3072 - Multichannel 6 Channels 1-6
--                            h - unknown, standard set to -1:U
--                            i - automation mode, as set in the Destination "Controls for Track"-dialogue
--                                    -1 - Track Automation Mode
--                                     0 - Trim/Read
--                                     1 - Read
--                                     2 - Touch
--                                     3 - Write
--                                     4 - Latch
--                                     5 - Latch Preview
--
--AUXRECV a b c d e f g h i j:U k l m - Auxreceive as set in the routing-matrix as well as in the "Routing for Track x"-dialogue(Receives). 
--                                      Can be more than one. Works also for Send to Track...
--                                      Must be defined in the track that receives, NOT the track that sends!
--                                    a - Tracknumber, from where to receive the audio from
--                                    b - 0-PostFader, 1-PreFX, 3-Pre-Fader
--                                    c - Volume
--                                    d - pan; -=left, +=right, 0=center
--                                    e - Mute this send(1) or not(0)
--                                    f - Mono(1), Stereo(0)
--                                    g - Phase of this send on(1) or off(0)
--                                    h - Audio-Channel Source
--                                        -1 - None
--                                        0 - Stereo Source 1/2
--                                        1 - Stereo Source 2/3
--                                        2 - Stereo Source 3/4
--                                        1024 - Mono Source 1
--                                        1025 - Mono Source 2
--                                        2048 - Multichannel Source 4 Channels 1-4
--                                    i - send to channel
--                                        0 - Stereo 1/2
--                                        1 - Stereo 2/3
--                                        2 - Stereo 3/4
--
--                                        1024 - Mono Channel 1
--                                        1025 - Mono Channel 2
--                                    j - unknown, default is -1:U
--                                    k - MIDI-Channel-Management, Bitfield
--                                        0 - All Midi Tracks
--                                        1 to 16 - Midi Channel 1 to 16
--                                        32 - send to Midi Channel 1
--                                        64 - send to MIDI Channel 2
--                                        96 - send to MIDI Channel 3
--                                        512 - send to MIDI Channel 16
--                                        4194304 - send to MIDI-Bus B1
--                                        send to MIDI-Bus B1 + send to MIDI Channel nr = MIDIBus B1 1/nr
--                                        16384 - BusB1
--                                        BusB1+1 to 16 - BusB1-Channel 1 to 16
--                                        32768 - BusB2
--                                        BusB2+1 to 16 - BusB2-Channel 1 to 16
--                                        49152 - BusB3
--                                        BusB3+1 to 16 - BusB3-Channel 1 to 16
--                                        262144 - BusB16
--                                        BusB16+1 to 16 - BusB16-Channel 1 to 16
--
--                                        1024 - Add that value to switch MIDI On
--                                        4177951 - MIDI - None
--                                         
--                                    l - Automation Mode
--                                       -1 - Track Automation Mode
--                                        0 - Trim/Read
--                                        1 - Read
--                                        2 - Touch
--                                        3 - Write
--                                        4 - Latch
--                                        5 - Latch Preview
--                                     

--MediaTrack=reaper.GetTrack(0, 0)
--retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)
-- RECCFGNR_test=str:match("<RECCFG ("..nummer..")%c")
--reaper.ShowConsoleMsg(str)

--MediaTrack=reaper.GetTrack(0, 0)
--retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)
--ALABAMA=ultraschall.WriteValueToFile("c:\\testomat2.txt",str)

ultraschall.GetTrackName=function(tracknumber)
-- returns the trackname as a string
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)
  
--  Track_PeakCol=str:match("PEAKCOL.-%a") Track_PeakCol=Track_PeakCol:sub(9,-2)
  local Track_Name=str:match("NAME.-%c") Track_Name=Track_Name:sub(6,-2)
  return Track_Name
end

--A=ultraschall.GetTrackName(0)

ultraschall.GetTrackPeakColorState=function(tracknumber)
-- returns a color-number as a string
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)
  
--  Track_PeakCol=str:match("PEAKCOL.-%a") Track_PeakCol=Track_PeakCol:sub(9,-2)
  local Track_PeakCol=str:match("PEAKCOL.-%c") Track_PeakCol=Track_PeakCol:sub(9,-2)
  return Track_PeakCol
end

--A=ultraschall.GetTrackPeakColorState(0)

ultraschall.GetTrackBeatState=function(tracknumber)
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)
  
  local Track_Beat=str:match("BEAT.-%c") Track_Beat=Track_Beat:sub(6,-2)
  return tonumber(Track_Beat)
end

--A=ultraschall.GetTrackBeatState(0)

ultraschall.GetTrackAutoRecArmState=function(tracknumber)
-- returns nil, if it's unset
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)

  local Track_AutoRecarm=str:match("AUTO_RECARM.-%c") 
  if Track_AutoRecarm==nil then return nil end 
  Track_AutoRecarm=Track_AutoRecarm:sub(13,-2)
  return tonumber(Track_AutoRecarm)
end

--A=ultraschall.GetTrackAutoRecArmState(0)
  
ultraschall.GetTrackMuteSoloState=function(tracknumber)
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)

  local Track_Mutesolo=str:match("MUTESOLO.-%c") Track_Mutesolo=Track_Mutesolo:sub(9,-2)
  local Track_Mutesolo1=Track_Mutesolo:match("%b  ") Track_Mutesolo=Track_Mutesolo:match(".(%s.*)")
  local Track_Mutesolo2=Track_Mutesolo:match("%b  ") Track_Mutesolo=Track_Mutesolo:match(".(%s.*)")
  local Track_Mutesolo3=Track_Mutesolo
  return tonumber(Track_Mutesolo1), tonumber(Track_Mutesolo2), tonumber(Track_Mutesolo3)
end

--A1,A2,A3 = ultraschall.GetTrackMuteSoloState(0)
  
ultraschall.GetTrackIPhaseState=function(tracknumber)
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)

  local Track_Iphase=str:match("%IPHASE.-%c") Track_Iphase=Track_Iphase:sub(7,-2)
  return tonumber(Track_Iphase)
end

--A=ultraschall.GetTrackIPhaseState(0)

ultraschall.GetTrackIsBusState=function(tracknumber)
-- for folder-management
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)
  
  local Track_Isbus=str:match("ISBUS.-%c") Track_Isbus=Track_Isbus:sub(6,-2)
  local Track_Isbus1=Track_Isbus:match("%b  ") Track_Isbus=Track_Isbus:match(".(%s.*)")
  local Track_Isbus2=Track_Isbus
  return tonumber(Track_Isbus1), tonumber(Track_Isbus2)
end

--A1,A2=ultraschall.GetTrackIsBusState(1)

ultraschall.GetTrackBusCompState=function(tracknumber)
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)

  local Track_Buscomp=str:match("BUSCOMP%s.-%c") Track_Buscomp=Track_Buscomp:sub(8,-2)
  local Track_Buscomp1=Track_Buscomp:match("%b  ") Track_Buscomp=Track_Buscomp:match(".(%s.*)")
  local Track_Buscomp2=Track_Buscomp
  return tonumber(Track_Buscomp1), tonumber(Track_Buscomp)
end

--A,A2=ultraschall.GetTrackBusCompState(0)

ultraschall.GetTrackShowInMixState=function(tracknumber)
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)

  local Track_ShowinMix=str:match("SHOWINMIX.-%c") Track_ShowinMix=Track_ShowinMix:sub(10,-2)
  local Track_ShowinMix1=Track_ShowinMix:match("%b  ") Track_ShowinMix=Track_ShowinMix:match(".(%s.*)")
  local Track_ShowinMix2=Track_ShowinMix:match("%b  ") Track_ShowinMix=Track_ShowinMix:match(".(%s.*)")
  local Track_ShowinMix3=Track_ShowinMix:match("%b  ") Track_ShowinMix=Track_ShowinMix:match(".(%s.*)")
  local Track_ShowinMix4=Track_ShowinMix:match("%b  ") Track_ShowinMix=Track_ShowinMix:match(".(%s.*)")
  local Track_ShowinMix5=Track_ShowinMix:match("%b  ") Track_ShowinMix=Track_ShowinMix:match(".(%s.*)")
  local Track_ShowinMix6=Track_ShowinMix:match("%b  ") Track_ShowinMix=Track_ShowinMix:match(".(%s.*)")
  local Track_ShowinMix7=Track_ShowinMix:match("%b  ") Track_ShowinMix=Track_ShowinMix:match(".(%s.*)")
  local Track_ShowinMix8=Track_ShowinMix
  return tonumber(Track_ShowinMix1),tonumber(Track_ShowinMix2),tonumber(Track_ShowinMix3),tonumber(Track_ShowinMix4),tonumber(Track_ShowinMix5),tonumber(Track_ShowinMix6),tonumber(Track_ShowinMix7),tonumber(Track_ShowinMix8)
end  

--A1,A2,A3,A4,A5,A6,A7,A8=ultraschall.GetTrackShowInMixState(0)

ultraschall.GetTrackFreeModeState=function(tracknumber)
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)

  local Track_FreeMode=str:match("FREEMODE.-%c") Track_FreeMode=Track_FreeMode:sub(10,-2)
  return tonumber(Track_FreeMode)
end

--A=ultraschall.GetTrackFreeModeState(0)

ultraschall.GetTrackRecState=function(tracknumber)
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)

  local Track_Rec=str:match("REC.-%c") Track_Rec=Track_Rec:sub(4,-2)
  local Track_Rec1=Track_Rec:match("(%b  )") Track_Rec=Track_Rec:match(".(%s.*)")
  local Track_Rec2=Track_Rec:match("(%b  )") Track_Rec=Track_Rec:match(".(%s.*)")
  local Track_Rec3=Track_Rec:match("(%b  )") Track_Rec=Track_Rec:match(".(%s.*)")
  local Track_Rec4=Track_Rec:match("(%b  )") Track_Rec=Track_Rec:match(".(%s.*)")
  local Track_Rec5=Track_Rec:match("(%b  )") Track_Rec=Track_Rec:match(".(%s.*)")
  local Track_Rec6=Track_Rec:match("(%b  )") Track_Rec=Track_Rec:match(".(%s.*)")
  local Track_Rec7=Track_Rec
  return tonumber(Track_Rec1), tonumber(Track_Rec2), tonumber(Track_Rec3), tonumber(Track_Rec4), tonumber(Track_Rec5), tonumber(Track_Rec6), tonumber(Track_Rec7)
end

--A1,A2,A3,A4,A5,A6,A7=ultraschall.GetTrackRecState(0)

ultraschall.GetTrackVUState=function(tracknumber)
-- returns 0 if MultiChannelMetering is off
-- returns 2 if MultichannelMetering is on
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
   retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)
--ultraschall.ExportOutputTo("c:\\testomat",str)
  Track_Vu=str:match("VU.-%c") 
  if Track_Vu~=nil then  Track_Vu=Track_Vu:sub(4,-2) end
  if Track_VU==nil then Track_Vu=0 end
  return tonumber(Track_Vu)
end

--A=ultraschall.GetTrackVUState(0)

ultraschall.GetTrackHeightState=function(tracknumber)
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)

  local Track_Trackheight=str:match("TRACKHEIGHT.-%c") Track_Trackheight=Track_Trackheight:sub(12,-2)
  local Track_Trackheight1=Track_Trackheight:match("%b  ")
  local Track_Trackheight2=Track_Trackheight:match(".(%s.*)")
  return tonumber(Track_Trackheight1), tonumber(Track_Trackheight2)
end
  
--A1,A2=ultraschall.GetTrackHeightState(0)
  
ultraschall.GetTrackINQState=function(tracknumber)
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)

  local Track_INQ=str:match("INQ.-%c") Track_INQ=Track_INQ:sub(4,-2)
  local Track_INQ1=Track_INQ:match("(%b  )") Track_INQ=Track_INQ:match(".(%s.*)")
  local Track_INQ2=Track_INQ:match("(%b  )") Track_INQ=Track_INQ:match(".(%s.*)")
  local Track_INQ3=Track_INQ:match("(%b  )") Track_INQ=Track_INQ:match(".(%s.*)")
  local Track_INQ4=Track_INQ:match("(%b  )") Track_INQ=Track_INQ:match(".(%s.*)")
  local Track_INQ5=Track_INQ:match("(%b  )") Track_INQ=Track_INQ:match(".(%s.*)")
  local Track_INQ6=Track_INQ:match("(%b  )") Track_INQ=Track_INQ:match(".(%s.*)")
  local Track_INQ7=Track_INQ:match("(%b  )") Track_INQ=Track_INQ:match(".(%s.*)")
  local Track_INQ8=Track_INQ
  
  return tonumber(Track_INQ1),tonumber(Track_INQ2),tonumber(Track_INQ3),tonumber(Track_INQ4),tonumber(Track_INQ5),tonumber(Track_INQ6),tonumber(Track_INQ7),tonumber(Track_INQ8)
end
--]]
--A1,A2,A3,A4,A5,A6,A7,A8=ultraschall.GetTrackINQState(0)

ultraschall.GetTrackNChansState=function(tracknumber)
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)
  local Track_Nchan=str:match("NCHAN.-%c") Track_Nchan=Track_Nchan:sub(7,-2)
  return tonumber(Track_Nchan)
end

--A=ultraschall.GetTrackNChansState(1)

ultraschall.GetTrackBypFXState=function(tracknumber)
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)
  local Track_FX=str:match("FX.-%c") Track_FX=Track_FX:sub(4,-2)
  return tonumber(Track_FX)
end

--A=ultraschall.GetTrackBypFXState(1)

ultraschall.GetTrackPerfState=function(tracknumber)
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)
  local Track_Perf=str:match("PERF.-%c") Track_Perf=Track_Perf:sub(6,-2)
  return tonumber(Track_Perf)
end

--A=ultraschall.GetTrackPerfState(0)

ultraschall.GetTrackMIDIOutState=function(tracknumber)
-- -1 no output
-- 416 - microsoft GS wavetable synth - send to original channels
-- 417-432 - microsoft GS wavetable synth - send to channel state-416
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  MediaTrack=reaper.GetTrack(0, tracknumber)
  retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)

  Track_MIDIOut=str:match("MIDIOUT.-%a") Track_MIDIOut=Track_MIDIOut:sub(8,-2)
  return Track_MIDIOut
end

--A=ultraschall.GetTrackMIDIOutState(0)

ultraschall.GetTrackMainSendState=function(tracknumber)
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)

  local Track_TrackMainSend=str:match("MAINSEND.-%c") Track_TrackMainSend=Track_TrackMainSend:sub(9,-2)
  local Track_TrackMainSend1=Track_TrackMainSend:match("%b  ")
  local Track_TrackMainSend2=Track_TrackMainSend:match(".(%s.*)")
  return tonumber(Track_TrackMainSend1), tonumber(Track_TrackMainSend2)
end

-- A,AA= ultraschall.GetTrackMainSendState(0)

ultraschall.GetTrackGroupFlagsState=function(tracknumber)
--[[returns a 23bit flagvalue as well as an array with 32 individual 23bit-flagvalues. You must use bitoperations to get the individual values.
GroupState_as_Flags - returns a flagvalue with 23 bits, that tells you, which grouping-flag is set in at least one of the 32 groups available.
returns -1 in case of failure

the following flags are available:
2^0 - Volume Master
2^1 - Volume Slave
2^2 - Pan Master
2^3 - Pan Slave
2^4 - Mute Master
2^5 - Mute Slave
2^6 - Solo Master
2^7 - Solo Slave
2^8 - Record Arm Master
2^9 - Record Arm Slave
2^10 - Polarity/Phase Master
2^11 - Polarity/Phase Slave
2^12 - Automation Mode Master
2^13 - Automation Mode Slave
2^14 - Reverse Volume
2^15 - Reverse Pan
2^16 - Do not master when slaving
2^17 - Reverse Width
2^18 - Width Master
2^19 - Width Slave
2^20 - VCA Master
2^21 - VCA Slave
2^22 - VCA pre-FX slave

IndividualGroupState_Flags - returns an array with 23 entries. Every entry represents one of the GroupState_as_Flags, but it's value is a flag, that describes, in which of the 32 Groups a certain flag is set.
e.g. If Volume Master is set only in Group 1, entry 1 in the array will be set to 1. If Volume Master is set on Group 2 and Group 4, the first entry in the array will be set to 10.
refer to the upper GroupState_as_Flags list to see, which entry in the array is for which set flag, e.g. array[22] is VCA pre-F slave, array[16] is Do not master when slaving, etc
As said before, the values in each entry is a flag, that tells you, which of the groups is set with a certain flag. The following flags determine, in which group a certain flag is set:
2^0 - Group 1
2^1 - Group 2
2^2 - Group 3
2^3 - Group 4
...
2^30 - Group 31
2^31 - Group 32

parameter:
tracknumber - number of the track, beginning with 0
--]]
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local tempretval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)
  local retval=0
  local Tracktable={}
  local Track_TrackGroupFlags1=0
  local Track_TrackGroupFlags2=0
   local Track_TrackGroupFlags3=0
   local Track_TrackGroupFlags4=0
   local Track_TrackGroupFlags5=0
   local Track_TrackGroupFlags6=0
   local Track_TrackGroupFlags7=0
   local Track_TrackGroupFlags8=0
   local Track_TrackGroupFlags9=0
   local Track_TrackGroupFlags10=0
   local Track_TrackGroupFlags11=0
   local Track_TrackGroupFlags12=0
   local Track_TrackGroupFlags13=0
   local Track_TrackGroupFlags14=0
   local Track_TrackGroupFlags15=0
   local Track_TrackGroupFlags16=0
   local Track_TrackGroupFlags17=0
   local Track_TrackGroupFlags18=0
   local Track_TrackGroupFlags19=0
   local Track_TrackGroupFlags20=0
   local Track_TrackGroupFlags21=0
   local Track_TrackGroupFlags22=0
   local Track_TrackGroupFlags23=0

local Track_TrackGroupFlags=str:match("GROUP_FLAGS.-%c") 
  if Track_TrackGroupFlags==nil then return -1 end
  Track_TrackGroupFlags=Track_TrackGroupFlags:sub(13,-1)
--  reaper.MB(Track_TrackGroupFlags,"",0)
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags1=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags2=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags3=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags4=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags5=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags6=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags7=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags8=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags9=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags10=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags11=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags12=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags13=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags14=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags15=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags16=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags17=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags18=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags19=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags20=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags21=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags22=Track_TrackGroupFlags:match("%d*") Track_TrackGroupFlags=Track_TrackGroupFlags:match(".(%s.*)") if Track_TrackGroupFlags:len()-1>0 then Track_TrackGroupFlags=Track_TrackGroupFlags:sub(2,-1) else Track_TrackGroupFlags=nil end end
  if Track_TrackGroupFlags~=nil then  Track_TrackGroupFlags23=Track_TrackGroupFlags end
  if tonumber(Track_TrackGroupFlags1)>=1 then retval=retval+2^0 Tracktable[0]=tonumber(Track_TrackGroupFlags1) else Tracktable[0]=0 end
  if tonumber(Track_TrackGroupFlags2)>=1 then retval=retval+2^1 Tracktable[1]=tonumber(Track_TrackGroupFlags2) else Tracktable[1]=0 end
  if tonumber(Track_TrackGroupFlags3)>=1 then retval=retval+2^2 Tracktable[2]=tonumber(Track_TrackGroupFlags3) else Tracktable[2]=0 end
  if tonumber(Track_TrackGroupFlags4)>=1 then retval=retval+2^3 Tracktable[3]=tonumber(Track_TrackGroupFlags4) else Tracktable[3]=0 end
  if tonumber(Track_TrackGroupFlags5)>=1 then retval=retval+2^4 Tracktable[4]=tonumber(Track_TrackGroupFlags5) else Tracktable[4]=0 end
  if tonumber(Track_TrackGroupFlags6)>=1 then retval=retval+2^5 Tracktable[5]=tonumber(Track_TrackGroupFlags6) else Tracktable[5]=0 end
  if tonumber(Track_TrackGroupFlags7)>=1 then retval=retval+2^6 Tracktable[6]=tonumber(Track_TrackGroupFlags7) else Tracktable[6]=0 end
  if tonumber(Track_TrackGroupFlags8)>=1 then retval=retval+2^7 Tracktable[7]=tonumber(Track_TrackGroupFlags8) else Tracktable[7]=0 end
  if tonumber(Track_TrackGroupFlags9)>=1 then retval=retval+2^8 Tracktable[8]=tonumber(Track_TrackGroupFlags9) else Tracktable[8]=0 end
  if tonumber(Track_TrackGroupFlags10)>=1 then retval=retval+2^9 Tracktable[9]=tonumber(Track_TrackGroupFlags10) else Tracktable[9]=0 end
  if tonumber(Track_TrackGroupFlags11)>=1 then retval=retval+2^10 Tracktable[10]=tonumber(Track_TrackGroupFlags11) else Tracktable[10]=0 end
  if tonumber(Track_TrackGroupFlags12)>=1 then retval=retval+2^11 Tracktable[11]=tonumber(Track_TrackGroupFlags12) else Tracktable[11]=0 end
  if tonumber(Track_TrackGroupFlags13)>=1 then retval=retval+2^12 Tracktable[12]=tonumber(Track_TrackGroupFlags13) else Tracktable[12]=0 end
  if tonumber(Track_TrackGroupFlags14)>=1 then retval=retval+2^13 Tracktable[13]=tonumber(Track_TrackGroupFlags14) else Tracktable[13]=0 end
  if tonumber(Track_TrackGroupFlags15)>=1 then retval=retval+2^14 Tracktable[14]=tonumber(Track_TrackGroupFlags15) else Tracktable[14]=0 end
  if tonumber(Track_TrackGroupFlags16)>=1 then retval=retval+2^15 Tracktable[15]=tonumber(Track_TrackGroupFlags16) else Tracktable[15]=0 end
  if tonumber(Track_TrackGroupFlags17)>=1 then retval=retval+2^16 Tracktable[16]=tonumber(Track_TrackGroupFlags17) else Tracktable[16]=0 end
  if tonumber(Track_TrackGroupFlags18)>=1 then retval=retval+2^17 Tracktable[17]=tonumber(Track_TrackGroupFlags18) else Tracktable[17]=0 end
  if tonumber(Track_TrackGroupFlags19)>=1 then retval=retval+2^18 Tracktable[18]=tonumber(Track_TrackGroupFlags19) else Tracktable[18]=0 end
  if tonumber(Track_TrackGroupFlags20)>=1 then retval=retval+2^19 Tracktable[19]=tonumber(Track_TrackGroupFlags20) else Tracktable[19]=0 end
  if tonumber(Track_TrackGroupFlags21)>=1 then retval=retval+2^20 Tracktable[20]=tonumber(Track_TrackGroupFlags21) else Tracktable[20]=0 end
  if tonumber(Track_TrackGroupFlags22)>=1 then retval=retval+2^21 Tracktable[21]=tonumber(Track_TrackGroupFlags22) else Tracktable[21]=0 end
  if tonumber(Track_TrackGroupFlags23)>=1 then retval=retval+2^22 Tracktable[22]=tonumber(Track_TrackGroupFlags23) else Tracktable[22]=0 end
  --reaper.MB(retval,"",0)
--  ultraschall.ExportValueToFile("c:\\testomat2",str)
  return retval, Tracktable
end

--B=2^22
--A,A1=ultraschall.GetTrackGroupFlagsState(0)
--A=2^2

-- GROUP_FLAGS 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1

ultraschall.GetTrackLockState=function(tracknumber)
-- Get the state of, if the track has locked controls(1) or not(0)
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)
  
--  Track_PeakCol=str:match("PEAKCOL.-%a") Track_PeakCol=Track_PeakCol:sub(9,-2)
    local Track_Name=str:match("LOCK.-%c.*TRACKHEIGHT")
    if Track_Name~=nil then Track_Name=Track_Name:sub(6,-1)
    Track_Name=Track_Name:match("%d") 
    else Track_Name=0 
    end
   --ultraschall.ExportOutputTo("c:\\testomat2",str)
  return tonumber(Track_Name)
end

--A=ultraschall.GetTrackLockState(0)

ultraschall.GetTrackLayoutNames=function(tracknumber)
-- Get the state of the current TrackLayout-names. Returns the name of the current 
-- TCP and the current MCP-layout or nil if default is selected.
  if tonumber(tracknumber)==nil then return nil end
  local tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)
  local Track_LayoutTCP=nil
  local Track_LayoutMCP=nil
  
--  Track_PeakCol=str:match("PEAKCOL.-%a") Track_PeakCol=Track_PeakCol:sub(9,-2)
    local Track_Layout=str:match("LAYOUTS.-%c")
    if Track_Layout~=nil then Track_Layout=Track_Layout:sub(9,-2)
      if Track_Layout:sub(1,1)=="\"" then 
        Track_LayoutTCP=Track_Layout:match("\".-\"")
        Track_LayoutTCP=Track_LayoutTCP:sub(2,-2)
      end
      if Track_Layout:sub(-1,-1)=="\"" then 
        Track_LayoutMCP=Track_Layout:match(".*(\".-\")")
        Track_LayoutMCP=Track_LayoutMCP:sub(2,-2)
      end
      if Track_LayoutTCP==nil then Track_LayoutTCP=Track_Layout:match(".-%s") Track_LayoutTCP=Track_LayoutTCP:sub(1,-2)end
      if Track_LayoutMCP==nil then Track_LayoutMCP=Track_Layout:match(".*(%s.*)") Track_LayoutMCP=Track_LayoutMCP:sub(2,-1)end
            

    end
  -- ultraschall.ExportOutputTo("c:\\testomat2",str)
  return Track_LayoutTCP, Track_LayoutMCP
end

--A,AA=ultraschall.GetTrackLayoutsState(0)

ultraschall.GetTrackAutomodeState=function(tracknumber)
-- returns current state of Automation-Mode
-- 0 - trim/read, 1 - read, 2 - touch, 3 - write, 4 - latch

  if tonumber(tracknumber)==nil then return nil end
  local tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)
  
   local Track_Automode=str:match("AUTOMODE.-%c") Track_Automode=Track_Automode:sub(9,-2)
  return tonumber(Track_Automode)
end

--A=ultraschall.GetTrackAutomodeState(0)

ultraschall.GetTrackIcon_Filename=function(tracknumber)
-- Get the path and filename of the current track-icon
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)
  
--  Track_PeakCol=str:match("PEAKCOL.-%a") Track_PeakCol=Track_PeakCol:sub(9,-2)
    local Track_Image=str:match("TRACKIMGFN.-%c")
    if Track_Image~=nil then Track_Image=Track_Image:sub(13,-3)
    end
   --ultraschall.ExportOutputTo("c:\\testomat2",str)
  return Track_Image
end

--A,A2=ultraschall.GetTrackIcon_Filename(0)

ultraschall.GetTrackRecCFG=function(tracknumber,cfg_nr)
  --returns the Rec-configuration-string, with which recordings are made
  --
  --tracknumber - the number of the track
  --cfg_nr - the number of the reccfg, beginning with 0(there can be more than one)
  if tonumber(tracknumber)==nil then return nil end
  local tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)
  local RECCFGNR=str:match("<RECCFG ("..cfg_nr..")%c")
  if RECCFGNR==nil then return -1 end
  local RECCFG=str:match("<RECCFG.-%c(.-)%c")
  
  return RECCFG
end

--A=ultraschall.GetTrackRecCFG(0,0)

ultraschall.GetTrackMidiInputChanMap=function(tracknumber)
--returns the Midi Input Channel Map-state or nil, if not existing
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)
  
--  Track_PeakCol=str:match("PEAKCOL.-%a") Track_PeakCol=Track_PeakCol:sub(9,-2)
  local Track_MidiChanMap=str:match("MIDI_INPUT_CHANMAP (.-)%c")
  return tonumber(Track_MidiChanMap)
end

--A=ultraschall.GetTrackMidiInputChanMap(0)

ultraschall.GetTrackMidiCTL=function(tracknumber)
--returns the Midi CTL-state, or nil if not existing
-- returns LinkedToMidiChannel, unknown value
  if tonumber(tracknumber)==nil then return nil end
  tracknumber=tonumber(tracknumber)
  if tracknumber<0 then return nil end
  if tracknumber>reaper.CountTracks()-1 then return nil end
  local MediaTrack=reaper.GetTrack(0, tracknumber)
  local retval, str = reaper.GetTrackStateChunk(MediaTrack, "test", false)
  
--  Track_PeakCol=str:match("PEAKCOL.-%a") Track_PeakCol=Track_PeakCol:sub(9,-2)
  local Track_LinkedToMidiChannel=str:match("MIDICTL (.-)%s.-%c")
  local Track_unknown=str:match("MIDICTL .-%s(.-)%c")
  return tonumber(Track_LinkedToMidiChannel), tonumber(Track_unknown)
end

--A,A2=ultraschall.GetTrackMidiCTL(0)

--------------------------
---- Set Track States ----
--------------------------

ultraschall.SetTrackName=function(tracknumber, name)
--Sets Name of the Track
-- tracknumber - counted from 0
-- name - new name of the track
  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  local str="NAME \""..name.."\""
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)NAME")
  local B3=AA:match("NAME.-%c(.*)")

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
--  reaper.ShowConsoleMsg(AA)
  return B
end

--ATA=ultraschall.SetTrackName(0,"testofon66")

ultraschall.SetTrackPeakColorState=function(tracknumber, colorvalue)
--Sets Color of the Track
-- tracknumber - counted from 0
-- colorvalue - a colorvalue that colors this track
  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(colorvalue)==nil then return false end
  local str="PEAKCOL "..colorvalue
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)PEAKCOL")
  local B3=AA:match("PEAKCOL.-%c(.*)")

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
--  reaper.ShowConsoleMsg(AA)
  return B
end

--ATA=ultraschall.SetTrackPeakColorState(0,"9999999")

ultraschall.SetTrackBeatState=function(tracknumber, beatstate)
--Sets BEAT of a track.
-- tracknumber - counted from 0
-- beatstate - tracktimebase for this track; -1 - Project time base, 0 - Time, 1 - Beats position, length, rate, 2 - Beats position only
  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(beatstate)==nil then return false end
  local str="BEAT "..beatstate
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)BEAT")
  local B3=AA:match("BEAT.-%c(.*)")

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
--  reaper.ShowConsoleMsg(AA)
  return B
end

--ATA=ultraschall.SetTrackBeatState(0,-1)

ultraschall.SetTrackAutoRecArmState=function(tracknumber, autorecarmstate)
--Sets Autorecarmstate of the Track
-- tracknumber - counted from 0
-- autorecarmstate - 1 - autorecarm on, <> than 1 - off
  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(autorecarmstate)==nil then return false end
  local str=""
  if tonumber(autorecarmstate)==1 then str="AUTO_RECARM "..autorecarmstate end
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)AUTO_RECARM")
  local B3=AA:match("AUTO_RECARM.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  -- reaper.ShowConsoleMsg(AA)
  return B
end

--ATA=ultraschall.SetTrackAutoRecArmState(0,0)

ultraschall.SetTrackMuteSoloState=function(tracknumber, Mute, Solo, SoloDefeat)
--Sets Mute, Solo and SoloDefeat of the Track
-- tracknumber - counted from 0
-- Mute - 0 - Mute off, <> than 0 - on
-- Solo - 0 - off, <> than 0 - on
-- Solo Defeat - 0 - off, <> than 0 - on
  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(Mute)==nil then return false end
  if tonumber(Solo)==nil then return false end
  if tonumber(SoloDefeat)==nil then return false end
  local str="MUTESOLO "..Mute.." "..Solo.." "..SoloDefeat
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)MUTESOLO")
  local B3=AA:match("MUTESOLO.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  --reaper.ShowConsoleMsg(AA)
  return B
end

--ATA=ultraschall.SetTrackMuteSoloState(0,0,0,0)

ultraschall.SetTrackIPhaseState=function(tracknumber, iphasestate)
--Sets IPhase, the Phase-Buttonstate of the Track
-- tracknumber - counted from 0
-- iphasestate - 0 - off, <> than 0 - on
  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(iphasestate)==nil then return false end
  local str="IPHASE "..iphasestate
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)IPHASE")
  local B3=AA:match("IPHASE.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
--  reaper.ClearConsole()
--  reaper.ShowConsoleMsg(AA)
  return B
end

--ATA=ultraschall.SetTrackIPhaseState(0,0)

ultraschall.SetTrackIsBusState=function(tracknumber, busstate1, busstate2)
--Sets ISBUS-state of the Track, if it's a folder track
-- tracknumber - counted from 0
-- track is no folder: busstate1=0, busstate2=0
-- track is a folder: busstate1=1, busstate2=1
-- track is a folder but view of all subtracks not compactible: busstate1=1, busstate2=2
-- track is last track in folder(no tracks of subfolders follow): busstate1=2, busstate2=-1  
  
  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(busstate1)==nil then return false end
  if tonumber(busstate2)==nil then return false end
  local str="ISBUS "..busstate1.." "..busstate2
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)ISBUS")
  local B3=AA:match("ISBUS.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  --reaper.ShowConsoleMsg(AA)
  return B
end

--ATA=ultraschall.SetTrackIsBusState(0,0,0)

ultraschall.SetTrackBusCompState=function(tracknumber, buscompstate1, buscompstate2)
--Sets BUSCOMP-state of the Track, if tracks in a folder are compacted or not
-- tracknumber - counted from 0
-- BusCompState1:
-- 0 - no compacting
-- 1 - compacted tracks
-- 2 - minimized tracks

-- BusCompState2:
-- 0 - unknown
-- 1 - unknown  
  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(buscompstate1)==nil then return false end
  if tonumber(buscompstate2)==nil then return false end
  local str="BUSCOMP "..buscompstate1.." "..buscompstate2
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)BUSCOMP")
  local B3=AA:match("BUSCOMP.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  --reaper.ShowConsoleMsg(AA)
  return B
end

--ATA=ultraschall.SetTrackBusCompState(0,0,0)

ultraschall.SetTrackShowInMixState=function(tracknumber, MCPvisible, MCP_FX_visible, MCP_TrackSendsVisible, TCPvisible, ShowInMix5, ShowInMix6, ShowInMix7, ShowInMix8)
-- Sets SHOWINMIX, that sets visibility of track in MCP and TCP
-- MCPvisible - 0 invisible, 1 visible
-- MCP_FX_visible - 0 visible, 1 FX-Parameters visible, 2 invisible
-- MCPTrackSendsVisible - 0 & 1.1 and higher TrackSends in MCP visible, every other number makes them invisible
-- TCPvisible - 0 track is invisible in TCP, 1 track is visible in TCP
-- ShowInMix5 - unknown
-- ShowInMix6 - unknown
-- ShowInMix7 - unknown
-- ShowInMix8 - unknown

  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(MCPvisible)==nil then return false end
  if tonumber(MCP_FX_visible)==nil then return false end
  if tonumber(MCP_TrackSendsVisible)==nil then return false end
  if tonumber(TCPvisible)==nil then return false end
  if tonumber(ShowInMix5)==nil then return false end
  if tonumber(ShowInMix6)==nil then return false end
  if tonumber(ShowInMix7)==nil then return false end
  if tonumber(ShowInMix8)==nil then return false end
  local str="SHOWINMIX "..MCP_FX_visible.." "..MCP_FX_visible.." "..MCP_TrackSendsVisible.." "..TCPvisible.." "..ShowInMix5.." "..ShowInMix6.." "..ShowInMix7.." "..ShowInMix8
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)SHOWINMIX")
  local B3=AA:match("SHOWINMIX.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  --reaper.ShowConsoleMsg(AA)
  return B
end


--ATA=ultraschall.SetTrackShowInMixState(0,1,1,1,1,1,1,1,1)

ultraschall.SetTrackFreeModeState=function(tracknumber, freemodestate)
--Sets FREEMODE-State of the track
-- tracknumber - counted from 0
-- freemodestate- 0 - off, 1 - on
  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(freemodestate)==nil then return false end
  local str="FREEMODE "..freemodestate
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)FREEMODE")
  local B3=AA:match("FREEMODE.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
--  reaper.ClearConsole()
  --reaper.ShowConsoleMsg(AA)
  return B
end

--ATA=ultraschall.SetTrackFreeModeState(0,1)

ultraschall.SetTrackRecState=function(tracknumber, ArmState, InputChannel, MonitorInput, RecInput, MonitorWhileRec, presPDCdelay, RecordingPath)
-- sets REC-State
-- tracknumber - counted from 0
--[[
ArmState - returns 1(armed) or 0(unarmed)

InputChannel - returns the InputChannel
-1 - No Input
1-16(more?) - Mono Input Channel
1024 - Stereo Channel 1 and 2
1026 - Stereo Channel 3 and 4
1028 - Stereo Channel 5 and 6
...
5056 - Virtual MIDI Keyboard all Channels
5057 - Virtual MIDI Keyboard Channel 1
...
5072 - Virtual MIDI Keyboard Channel 16
5088 - All MIDI Inputs - All Channels
5089 - All MIDI Inputs - Channel 1
...
5104 - All MIDI Inputs - Channel 16

Monitor Input - 0 monitor off, 1 monitor on, 2 monitor on tape audio style

RecInput - returns rec-input type
0 input(Audio or Midi), 
1 Record Output Stereo
2 Disabled, Input Monitoring Only
3 Record Output Stereo, Latency Compensated
4 Record Output MIDI
5 Record Output Mono
6 Record Output Mono, Latency Compensated
7 MIDI overdub, 
8 MIDI replace, 
9 MIDI touch replace, 
10 Record Output Multichannel
11 Record Output Multichannel, Latency Compensated 
12 Record Input Force Mono
13 Record Input Force Stereo
14 Record Input Force Multichannel
15 Record Input Force MIDI
16 MIDI latch replace

MonitorWhileRec - Monitor Trackmedie when recording, 0 is off, 1 is on

presPDCdelay - preserve PDC delayed monitoring in media items

RecordingPath - 0 Primary Recording-Path only, 1 Secondary Recording-Path only, 2 Primary Recording Path and Secondary Recording Path(for invisible backup)]]--

  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(ArmState)==nil then return false end
  if tonumber(InputChannel)==nil then return false end
  if tonumber(MonitorInput)==nil then return false end
  if tonumber(RecInput)==nil then return false end
  if tonumber(MonitorWhileRec)==nil then return false end
  if tonumber(presPDCdelay)==nil then return false end
  if tonumber(RecordingPath)==nil then return false end
  local str="REC "..ArmState.." "..InputChannel.." "..MonitorInput.." "..RecInput.." "..MonitorWhileRec.." "..presPDCdelay.." "..RecordingPath
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)REC")
  local B3=AA:match("REC.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
--  reaper.ShowConsoleMsg(AA)
  return B
end


--ATA=ultraschall.SetTrackRecState(0,0,1,1,1,1,1,1)


ultraschall.SetTrackVUState=function(tracknumber, VUState)
--Sets VU-State
-- tracknumber - counted from 0
-- VUState - 0 if MultiChannelMetering is off, 2 if MultichannelMetering is on, 3 Metering is off
  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(VUState)==nil then return false end
  local str="VU "..VUState
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)VU")
  local B3=AA:match("VU.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
--  reaper.ClearConsole()
  --reaper.ShowConsoleMsg(AA)
  return B
end

--ATA=ultraschall.SetTrackVUState(0,0)

ultraschall.SetTrackHeightState=function(tracknumber, heightstate1, heightstate2)
-- sets TRACKHEIGHT
-- tracknumber - number of the track, starting by 0
-- heightstate1 - 24 up to 443
-- heightstate2 - 0 - use height, 1 - compact the track and ignore the height
  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(heightstate1)==nil then return false end
  if tonumber(heightstate2)==nil then return false end
  local str="TRACKHEIGHT "..heightstate1.." "..heightstate2
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)TRACKHEIGHT")
  local B3=AA:match("TRACKHEIGHT.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
--  reaper.ShowConsoleMsg(AA)
  return B
end

--ultraschall.SetTrackHeightState(0, 120, 0)

ultraschall.SetTrackINQState=function(tracknumber, INQ1, INQ2, INQ3, INQ4, INQ5, INQ6, INQ7, INQ8)
-- sets INQ
-- tracknumber - number of the track, starting by 0
-- INQ1 - unknown
-- INQ2 - unknown
-- INQ3 - unknown
-- INQ4 - unknown
-- INQ5 - unknown
-- INQ6 - unknown
-- INQ7 - unknown
-- INQ8 - unknown
  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(INQ1)==nil then return false end
  if tonumber(INQ2)==nil then return false end
  if tonumber(INQ3)==nil then return false end
  if tonumber(INQ4)==nil then return false end
  if tonumber(INQ5)==nil then return false end
  if tonumber(INQ6)==nil then return false end
  if tonumber(INQ7)==nil then return false end
  if tonumber(INQ8)==nil then return false end
  local str="INQ "..INQ1.." "..INQ2.." "..INQ3.." "..INQ4.." "..INQ5.." "..INQ6.." "..INQ7.." "..INQ8
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)INQ")
  local B3=AA:match("INQ.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  --reaper.ShowConsoleMsg(AA)
  return B
end

--ATA=ultraschall.SetTrackINQState(0, 1000,1000,1000,100,2000,2000,2000,200)


ultraschall.SetTrackNChansState=function(tracknumber, NChans)
--Sets NCHANS, the number of channels for this track, as set in the routing
-- tracknumber - counted from 0
-- NChans - 2 to 64, counted every second channel (2,4,6,8,etc) with stereo-tracks. Unknown, if Multichannel and Mono-tracks count differently
  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(NChans)==nil then return false end
  local str="NCHAN "..NChans
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)NCHAN")
  local B3=AA:match("NCHAN.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
--  reaper.ClearConsole()
  --reaper.ShowConsoleMsg(AA)
  return B
end

--ATA=ultraschall.SetTrackNChansState(0,9)



ultraschall.SetTrackBypFXState=function(tracknumber, FXBypassState)
--Sets FX, FX-Bypass-state
-- tracknumber - counted from 0
-- FXBypassState - 0 bypass, 1 activate fx; has only effect, if FX or instruments are added to this track
  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(FXBypassState)==nil then return false end
  local str="FX "..FXBypassState
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)FX")
  local B3=AA:match("FX.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
--  reaper.ClearConsole()
  --reaper.ShowConsoleMsg(AA)
  return B
end

--ATA=ultraschall.SetTrackBypFXState(0,0)

ultraschall.SetTrackPerfState=function(tracknumber, Perf)
--Sets PERF, TrackPerformance-State
-- tracknumber - counted from 0
-- Perf - 0 - allow anticipative FX + allow media buffering<br>
-- 1 - allow anticipative FX + prevent media buffering <br>
-- 2 - prevent anticipative FX + allow media buffering<br>
-- 3 - prevent anticipative FX + prevent media buffering<br>
--settings seem to repeat with higher numbers (e.g. 4(like 0) - allow anticipative FX + allow media buffering), but to be safe keep it between 0 and 3

  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(Perf)==nil then return false end
  local str="PERF "..Perf
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)PERF")
  local B3=AA:match("PERF.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
--  reaper.ClearConsole()
--  reaper.ShowConsoleMsg(AA)
  return B
end

--ATA=ultraschall.SetTrackPerfState(0,0)

ultraschall.SetTrackMIDIOutState=function(tracknumber, MIDIOutState)
--Sets MIDIOut-State
-- tracknumber - counted from 0
-- MIDIOutState - 
--  -1 no output
-- 416 - microsoft GS wavetable synth - send to original channels
-- 417-432 - microsoft GS wavetable synth - send to channel state minus 416
-- -31 - no Output, send to original channel 1
-- -16 - no Output, send to original channel 16

  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(MIDIOutState)==nil then return false end
  local str="MIDIOUT "..MIDIOutState
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)MIDIOUT")
  local B3=AA:match("MIDIOUT.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
--  reaper.ClearConsole()
  --reaper.ShowConsoleMsg(AA)
  return B
end

--ATA=ultraschall.SetTrackMIDIOutState(0,-1)


ultraschall.SetTrackMainSendState=function(tracknumber, MainSendOn, ParentChannels)
-- sets MAINSEND-state
-- tracknumber - number of the track, starting by 0
-- MainSendOn - on(1) or off(0)
-- ParentChannels - the ParentChannels(0-64), interpreted as beginning with ParentChannels to ParentChannels+NCHAN
  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(MainSendOn)==nil then return false end
  if tonumber(ParentChannels)==nil then return false end
  local str="MAINSEND "..MainSendOn.." "..ParentChannels
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)MAINSEND")
  local B3=AA:match("MAINSEND.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  --reaper.ShowConsoleMsg(AA)
  return B
end

--A=ultraschall.SetTrackMainSendState(0, 1, 2)

ultraschall.SetTrackLockState=function(tracknumber, LockedState)
--Sets LOCK-State, as set by the menu entry Lock Track Controls
-- tracknumber - counted from 0
-- LockedState - 1 - locked, 0 - unlocked

  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(LockedState)==nil then return false end
  local str="LOCK "..LockedState
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)LOCK")
  local B3=AA:match("LOCK.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
--  reaper.ClearConsole()
--  reaper.ShowConsoleMsg(AA)
  return B
end

--ATA=ultraschall.SetTrackLockedState(0,0)

ultraschall.SetTrackLayoutNames=function(tracknumber, TCP_Layoutname, MCP_Layoutname)
--Sets LAYOUTS, the MCP and TCP-layout by name of the layout as defined in the theme.
-- tracknumber - counted from 0
-- TCP_Layoutname - name of the TrackControlPanel-Layout from the theme to use
-- MCP_Layoutname - name of the MixerControlPanel-Layout from the theme to use
  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if TCP_Layoutname==nil then TCP_Layoutname="" end
  if MCP_Layoutname==nil then MCP_Layoutname="" end
  local str="LAYOUTS \""..TCP_Layoutname.."\" \""..MCP_Layoutname.."\""
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)LAYOUTS")
  local B3=AA:match("LAYOUTS.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
  --reaper.ShowConsoleMsg(AA)
  return B
end

--A=ultraschall.SetTrackLayoutName(0,"Ultraschall 2",nil)


ultraschall.SetTrackAutomodeState=function(tracknumber, automodestate)
--Sets Automode-State, as set by the menu entry Set Track Automation Mode
-- tracknumber - counted from 0
-- automodestate - 0 - trim/read, 1 - read, 2 - touch, 3 - write, 4 - latch.

  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(automodestate)==nil then return false end
  local str="AUTOMODE "..automodestate
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)AUTOMODE")
  local B3=AA:match("AUTOMODE.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
--  reaper.ClearConsole()
--  reaper.ShowConsoleMsg(AA)
  return B
end

--ATA=ultraschall.SetTrackAutomodeState(0,0)

ultraschall.SetTrackIcon_Filename=function(tracknumber, Iconfilename_with_path)
--Sets TRACKIMGFN, the trackicon-filename
-- tracknumber - counted from 0
-- Iconfilename_with_path - filename with path

  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if Iconfilename_with_path==nil then Iconfilename_with_path="" end
  local str="TRACKIMGFN \""..Iconfilename_with_path.."\""
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)TRACKIMGFN")
  local B3=AA:match("TRACKIMGFN.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
--  reaper.ClearConsole()
--  reaper.ShowConsoleMsg(AA)
  return B
end


--A=ultraschall.SetTrackIcon_Filename(0,"c:\\us.png")


ultraschall.SetTrackMidiInputChanMap=function(tracknumber, InputChanMap)
--Sets MIDI_INPUT_CHANMAP, as set in the Input-MIDI->Map Input to Channel menu.
-- tracknumber - counted from 0
-- InputChanMap - 0 for channel 1, 2 for channel 2, etc. -1 if not existing.

  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(InputChanMap)==nil then return false end
  local str="MIDI_INPUT_CHANMAP "..InputChanMap
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)MIDI_INPUT_CHANMAP")
  local B3=AA:match("MIDI_INPUT_CHANMAP.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
--  reaper.ClearConsole()
  --reaper.ShowConsoleMsg(AA)
  return B
end

--ATA=ultraschall.SetTrackMidiInputChanMap(0,-1)


ultraschall.SetTrackMidiCTL=function(tracknumber, LinkedToMidiChannel, unknown)
-- sets MIDICTL-state
-- tracknumber - number of the track, starting by 0
-- Parameters:
-- LinkedToMidiChannel
-- unknown - ?
  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if tonumber(LinkedToMidiChannel)==nil then return false end
  if tonumber(unknown)==nil then return false end
  local str="MIDICTL "..LinkedToMidiChannel.." "..unknown
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)MIDICTL")
  local B3=AA:match("MIDICTL.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
--  reaper.ShowConsoleMsg(AA)
  return B
end

--A=ultraschall.SetTrackMidiCTL(0, -1, -1)


ultraschall.SetTrackMIDIColorMapFn=function(tracknumber, Colormapfilename_with_path)
--TODO - GetTrackMIDICOlorMapFn() and ... what the heck does this function?
--Sets MIDICOLORMAPFN
-- tracknumber - counted from 0
-- Colormapfilename_with_path - filename with path

  if tonumber(tracknumber)==nil then return false end
  if tonumber(tracknumber)<0 then return false end
  tracknumber=tonumber(tracknumber)
  if Colormapfilename_with_path==nil then Colormapfilename_with_path="" end
  local str="MIDICOLORMAPFN \""..Colormapfilename_with_path.."\""
  local Mediatrack=reaper.GetTrack(0,tracknumber)
  local A,AA=reaper.GetTrackStateChunk(Mediatrack,str,false)

  local B1=AA:match("(.-)MIDICOLORMAPFN")
  local B3=AA:match("MIDICOLORMAPFN.-%c(.*)")
  if B1==nil then B1=AA:match("(.-TRACK)") B3=AA:match(".-TRACK(.*)") end

  local B=reaper.SetTrackStateChunk(Mediatrack,B1.."\n"..str.."\n"..B3,false)
--  reaper.ClearConsole()
  --reaper.ShowConsoleMsg(AA)
  return B
end

--A=ultraschall.SetTrackMIDIColorMapFn(0, "us.png")


------------------------------
---- Meta Data Management ----
------------------------------

ultraschall.SetID3TagsForCurrentProject=function(title, artist, album, track, year, genre, comment, date, involved_people, language, coverfilename_and_path, coverfilename_and_path2, coverfilename_and_path3)
-- sets project-states with the ID3-Tags. Use nil, if you don't want to change an already set ID3-Tag
-- sets the following tags:
-- Title, Artist, Album, Track, Years, Genre, Comment, Date, Involved_People, Language, Coverfilename_And_Path, Cover2filename_And_Path, Cover3filename_And_Path

    if title~=nil then reaper.SetProjExtState(0, "US_ID3_Tags", "Title", title) end
    if artist~=nil then reaper.SetProjExtState(0, "US_ID3_Tags", "Artist", artist) end
    if album~=nil then reaper.SetProjExtState(0, "US_ID3_Tags", "Album", album) end
    if track~=nil then reaper.SetProjExtState(0, "US_ID3_Tags", "Track", track) end
    if year~=nil then reaper.SetProjExtState(0, "US_ID3_Tags", "Year", year) end
    if genre~=nil then reaper.SetProjExtState(0, "US_ID3_Tags", "Genre", genre) end
    if comment~=nil then reaper.SetProjExtState(0, "US_ID3_Tags", "Comment", comment) end
    if date~=nil then reaper.SetProjExtState(0, "US_ID3_Tags", "Date", date) end
    if involved_people~=nil then reaper.SetProjExtState(0, "US_ID3_Tags", "Involved_People", involved_people) end
    if language~=nil then reaper.SetProjExtState(0, "US_ID3_Tags", "Language", language) end
    if coverfilename_and_path~=nil then reaper.SetProjExtState(0, "US_ID3_Tags", "Coverfilename_And_Path", coverfilename_and_path) end        
    if coverfilename_and_path2~=nil then reaper.SetProjExtState(0, "US_ID3_Tags", "Coverfilename_And_Path2", coverfilename_and_path2) end        
    if coverfilename_and_path3~=nil then reaper.SetProjExtState(0, "US_ID3_Tags", "Coverfilename_And_Path3", coverfilename_and_path3) end        
end

--ultraschall.SetID3TagsForCurrentProject("tit","art","alb","tr","yr","gen","com","dat","inv","lang","coverf1","coverf2","coverf3")

ultraschall.SetID3TagsForCurrentProject_PodcastTags=function(podcast, podcast_category, podcast_description, podcast_id, podcast_keywords, podcast_url)
-- sets project-states with the ID3-Tags specifically for Podcasts. Use nil, if you don't want to change an already set ID3-Tag
-- sets the following tags:
--Podcasttags for Podcast, Category, Description, ID, Keywords, URL
    if podcast~=nil then reaper.SetProjExtState(0, "US_ID3_Tags", "Podcast", podcast) end
    if podcast_category~=nil then reaper.SetProjExtState(0, "US_ID3_Tags", "Podcast_Category", podcast_category) end
    if podcast_description~=nil then reaper.SetProjExtState(0, "US_ID3_Tags", "Podcast_Description", podcast_description) end
    if podcast_id~=nil then reaper.SetProjExtState(0, "US_ID3_Tags", "Podcast_ID", podcast_id) end
    if podcast_keywords~=nil then reaper.SetProjExtState(0, "US_ID3_Tags", "Podcast_Keywords", podcast_keywords) end
    if podcast_url~=nil then reaper.SetProjExtState(0, "US_ID3_Tags", "Podcast_Url", podcast_url) end
end

--ultraschall.SetID3TagsForCurrentProject_PodcastTags("A","A","A","A","A","A","A","A","A","A","A","A","A")

ultraschall.GetID3TagsFromCurrentProject=function()
   --returns project-states with the ID3-Tags for
   -- Title, Artist, Album, Track, Years, Genre, Comment, Date, Involved_People, Language, Coverfilename_And_Path, Cover2filename_And_Path, Cover3filename_And_Path
   --
   -- returns empty string(s) for each ID3-Tag that's unset
    local retval, title=reaper.GetProjExtState(0, "US_ID3_Tags", "Title")
    local retval, artist=reaper.GetProjExtState(0, "US_ID3_Tags", "Artist")
    local retval, album=reaper.GetProjExtState(0, "US_ID3_Tags", "Album")
    local retval, track=reaper.GetProjExtState(0, "US_ID3_Tags", "Track")
    local retval, year=reaper.GetProjExtState(0, "US_ID3_Tags", "Year")
    local retval, genre=reaper.GetProjExtState(0, "US_ID3_Tags", "Genre")
    local retval, comment=reaper.GetProjExtState(0, "US_ID3_Tags", "Comment")
    local retval, date=reaper.GetProjExtState(0, "US_ID3_Tags", "Date")
    local retval, involved_people=reaper.GetProjExtState(0, "US_ID3_Tags", "Involved_People")
    local retval, language=reaper.GetProjExtState(0, "US_ID3_Tags", "Language")
    local retval, coverfilename_and_path=reaper.GetProjExtState(0, "US_ID3_Tags", "Coverfilename_And_Path")
    local retval, coverfilename_and_path2=reaper.GetProjExtState(0, "US_ID3_Tags", "Coverfilename_And_Path2")
    local retval, coverfilename_and_path3=reaper.GetProjExtState(0, "US_ID3_Tags", "Coverfilename_And_Path3")
    return title, artist, album, track, year, genre, comment, date, involved_people, language, coverfilename_and_path, coverfilename_and_path2, coverfilename_and_path3
end

--A,B,C,D,E,F,G,H,I,J,K=ultraschall.GetID3TagsFromCurrentProject()

ultraschall.GetID3TagsFromCurrentProject_PodcastTags=function()
  --returns returns project-states with the ID3-tags specifically for podcasts for 
  -- Podcast, Category, Description, ID, Keywords, URL
  --
  -- returns empty string(s) for each ID3-Tag that's unset

    local retval, podcast=reaper.GetProjExtState(0, "US_ID3_Tags", "Podcast")
    local retval, podcast_category=reaper.GetProjExtState(0, "US_ID3_Tags", "Podcast_Category")
    local retval, podcast_description=reaper.GetProjExtState(0, "US_ID3_Tags", "Podcast_Description")
    local retval, podcast_id=reaper.GetProjExtState(0, "US_ID3_Tags", "Podcast_ID")
    local retval, podcast_keywords=reaper.GetProjExtState(0, "US_ID3_Tags", "Podcast_Keywords")
    local retval, podcast_url=reaper.GetProjExtState(0, "US_ID3_Tags", "Podcast_Url")
    return podcast, podcast_category, podcast_description, podcast_id, podcast_keywords, podcast_url
end

--ultraschall.SetID3TagsForProject("Mach den Affen weg","FreakShow","FreakShowAlbum","76","2011","techtalk","Kommentare","march2011","tim,hukl,dennis,roddi","german","c:\\freakshow.png", "cover2", "cover3")
--ultraschall.SetID3TagsForProject_PodcastTags("podcast", "podcast_category","podcast_description","podcast_id","podcast_keywords","podcast_url")
--ultraschall.SetID3TagsForProject_PodcastTags("a","b","c","d","e","f")
--a,b,c,d,e,f,g,h,i,j,k,l,m=ultraschall.GetID3TagsFromCurrentProject_PodcastTags()
--reaper.ShowConsoleMsg(a.."."..b.."."..c.."."..d.."."..e.."."..f.." end\n")
--if a=="" then reaper.MB("nilalarm","",0) end

----------------------
---- Color Picker ----
----------------------

ultraschall.TracksToGentleSonicRainboom=function(startingcolor, direction)
end

ultraschall.TracksToAdjustedSonicRainboom=function(startingcolor, direction)
end

ultraschall.TracksToGentleGrayScale=function(startingshade, direction)
end

ultraschall.TracksToAdjustedGrayScale=function(startingshade, direction)
end

ultraschall.TracksToColorPattern=function(colorpattern, startingcolor, direction)
end

---------------------------
---- Routing Snapshots ----
---------------------------

ultraschall.SetRoutingSnapshot=function(snapshot_nr)
end

ultraschall.RecallRoutingSnapshot=function(snapshot_nr)
end

ultraschall.ClearRoutingSnapshot=function(snapshot_nr)
end


--------------------
---- Navigation ----
--------------------

ultraschall.ToggleScrollingDuringPlayback=function(scrolling_switch, move_editcursor)
-- integer scrolling_switch - 1-on, 0-off
-- integer move_editcursor - when scrolling stops, shall the editcursor be moved to current position of the playcursor(1) or not(0)
-- changes, if necessary, the state of the actions 41817 and 40036
  local Aretval=reaper.GetToggleCommandState(41817)
  local editcursor=reaper.GetCursorPosition()
  local playcursor=reaper.GetPlayPosition()

  if reaper.GetToggleCommandState(40036)~=scrolling_switch then
    reaper.Main_OnCommand(40036,0)
  end

  if reaper.GetToggleCommandState(41817)~=scrolling_switch then
    reaper.Main_OnCommand(41817,0)
  end

  reaper.SetEditCurPos(playcursor, true, false)

  if move_editcursor==1 then
    reaper.SetEditCurPos(playcursor, true, false)
  else
    reaper.SetEditCurPos(editcursor, false, false)
  end

end

--ultraschall.ToggleScrollingDuringPlayback(0,0)

ultraschall.SetPlayCursor_WhenPlaying=function(position)--, move_view)--, length_of_view)
-- changes position of the play-cursor, when playing
-- changes view to new playposition
-- has no effect during recording, when paused or stop and returns -1 in these cases!
if reaper.GetPlayState()~=1 then return -1 end
  local editcursor=reaper.GetCursorPosition()
  local playcursor=reaper.GetPlayPosition()
  if move_view==true then move_view=false
  elseif move_view==false then move_viev=true end
  reaper.SetEditCurPos(position, true, true) 
   if reaper.GetPlayState()==2 then
     reaper.Main_OnCommand(1007,0)
     reaper.SetEditCurPos(editcursor, false, false)  
     reaper.Main_OnCommand(1008,0)
--    reaper.SetEditCurPos(editcursor, false, false) 
    else
    reaper.SetEditCurPos(editcursor, false, false)  
    end
end

--    reaper.SetEditCurPos(10, false, false)  
--ultraschall.SetPlayCursor_WhenPlaying(10)

ultraschall.SetPlayAndEditCursor_WhenPlaying=function(position)--, move_view)--, length_of_view)
-- changes position of the play-cursor and the edit-cursor, when playing
-- changes view to new playposition
-- has no effect during recording, when paused or stop!
if reaper.GetPlayState()==0 then return -1 end
  local editcursor=reaper.GetCursorPosition()
  local playcursor=reaper.GetPlayPosition()
  if move_view==true then move_view=false
  elseif move_view==false then move_viev=true end
  reaper.SetEditCurPos(position, true, true) 
--  reaper.SetEditCurPos(editcursor, false, false)  
end

--ultraschall.SetPlayAndEditCursor_WhenPlaying(12)

ultraschall.JumpForwardBy=function(seconds)
--jumps forward by seconds
-- returns -1 if seconds is invalid or negative
if tonumber(seconds)==nil then return -1 end
seconds=tonumber(seconds)
if seconds<0 then return -1 end
  local editcursor=reaper.GetCursorPosition()
  local playcursor=reaper.GetPlayPosition()
  
  if reaper.GetPlayState()==0 then 
--  reaper.MB("test","",0)
    reaper.SetEditCurPos(editcursor+seconds, true, true) 
    --ultraschall.SetPlayAndCursor_WhenPlaying(reaper.GetPlayPosition()+10,false)--, 10)
  elseif reaper.GetPlayState()==5 or reaper.GetPlayState()==6 then
    reaper.SetEditCurPos(editcursor+seconds, true, true)
  else
    reaper.SetEditCurPos(playcursor+seconds, true, true)
  end
end

--A=ultraschall.JumpForwardBy(1)

ultraschall.JumpBackwardBy=function(seconds)
--jumps backwards by seconds
-- returns -1 if seconds is invalid or negative
if tonumber(seconds)==nil then return -1 end
seconds=tonumber(seconds)
if seconds<0 then return -1 end
  local editcursor=reaper.GetCursorPosition()
  local playcursor=reaper.GetPlayPosition()
  
  if reaper.GetPlayState()==0 then 
--  reaper.MB("test","",0)
    reaper.SetEditCurPos(editcursor-seconds, true, true) 
    --ultraschall.SetPlayAndCursor_WhenPlaying(reaper.GetPlayPosition()+10,false)--, 10)
  elseif reaper.GetPlayState()==5 or reaper.GetPlayState()==6 then
    reaper.SetEditCurPos(editcursor-seconds, true, true)
  else
    reaper.SetEditCurPos(playcursor-seconds, true, true)
  end
end

--A=ultraschall.JumpBackwardBy(1)

ultraschall.JumpForwardBy_Recording=function(seconds)
--jumps forward by seconds and restarts recording on new position
-- returns -1 if seconds is invalid or negative or if not recording
if tonumber(seconds)==nil then return -1 end
seconds=tonumber(seconds)
if seconds<0 then return -1 end
  local editcursor=reaper.GetCursorPosition()
  local playcursor=reaper.GetPlayPosition()
  
  if reaper.GetPlayState()==5 then 
    reaper.Main_OnCommand(1016,0)
    reaper.SetEditCurPos(playcursor+seconds, true, true) 
    reaper.Main_OnCommand(1013,0)
  elseif reaper.GetPlayState()==6 then
    reaper.Main_OnCommand(1016,0)
    reaper.SetEditCurPos(playcursor+seconds, true, true) 
    reaper.Main_OnCommand(1013,0)
    reaper.Main_OnCommand(1008,0)    
  else
    return -1
  end
end

--A=ultraschall.JumpForwardBy_Recording(5)

ultraschall.JumpBackwardBy_Recording=function(seconds)
--jumps forward by seconds and restarts recording on new position
-- returns -1 if seconds is invalid or negative or if not recording
if tonumber(seconds)==nil then return -1 end
seconds=tonumber(seconds)
if seconds<0 then return -1 end
  local editcursor=reaper.GetCursorPosition()
  local playcursor=reaper.GetPlayPosition()
  
  if reaper.GetPlayState()==5 then 
    reaper.Main_OnCommand(1016,0)
    reaper.SetEditCurPos(playcursor-seconds, true, true) 
    reaper.Main_OnCommand(1013,0)
  elseif reaper.GetPlayState()==6 then
    reaper.Main_OnCommand(1016,0)
    reaper.SetEditCurPos(playcursor-seconds, true, true) 
    reaper.Main_OnCommand(1013,0)
    reaper.Main_OnCommand(1008,0)
  else
    return -1
  end
end

--A=ultraschall.JumpBackwardBy_Recording(10)

ultraschall.GetNextClosestItemEdge=function(tracks, cursor_type, time_position)
-- returns time and item-object of the next closest item-start or item-end within the chosen tracks, as well as "beg" for begin and "end" for end of the returned item
-- can become slow when having thousands of items
-- string tracks - tracknumbers, seperated by a comma. Negative Values will be ignored.
-- integer cursor_type - 0-edit_cursor, 1-play_cursor, 2-mouse-cursor, 3-timeposition
-- number time_position - only when cursor_type=3, else it will be ignored. time_position to check from for the next item.

local cursortime=0
if tonumber(time_position)==nil and reaper.GetPlayState()==0 then
  time_position=reaper.GetCursorPosition()
elseif tonumber(time_position)==nil and reaper.GetPlayState~=0 then
  time_position=reaper.GetPlayPosition()
end
if tonumber(cursor_type)==nil then return -1 end
if tonumber(cursor_type)==0 then cursortime=reaper.GetCursorPosition() end
if tonumber(cursor_type)==1 then cursortime=reaper.GetPlayPosition() end
if tonumber(cursor_type)==2 then 
    reaper.BR_GetMouseCursorContext() 
    cursortime=reaper.BR_GetMouseCursorContext_Position() 
    if cursortime==-1 then return -1 end
end
if tonumber(cursor_type)==3 then
    if tonumber(time_position)==nil then return -1 end
    cursortime=tonumber(time_position)
end
if tonumber(cursor_type)>3 or tonumber(cursor_type)<0 then return -1 end

if tracks==nil then return 0 end
local tracks=tostring(tracks)

local TrackArray = ultraschall.CSV2IndividualLines(tracks)

local TrackArray2={}
--for i=0,reaper.CountTracks() do
  for k=0, reaper.CountTracks() do
    if TrackArray[k]~=nil then TrackArray2[tonumber(TrackArray[k])]=TrackArray[k]
--    reaper.MB(tostring(TrackArray[k]),"",0)
    end
  end
--end
local closest_item=reaper.GetProjectLength(0)
local found_item=nil
local position=""
--reaper.MB("","",0)
for i=0, reaper.CountMediaItems(0)-1 do
  for j=0, reaper.CountTracks(0) do

--  reaper.ShowConsoleMsg(tostring(TrackArray2[j]))
  if TrackArray2[j]~=nil and tonumber(tracks)~=-1 then  
  --reaper.MB("hui","",0)
     if ultraschall.IsItemInTrack(j,i)==true then
    local MediaItem=reaper.GetMediaItem(0, i)
    local ItemStart=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
    local ItemEnd=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")+reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")
    if ItemStart>cursortime and ItemStart<closest_item then
        closest_item=ItemStart
        found_item=MediaItem
        position="beg"
    end
    if ItemEnd>cursortime and ItemEnd<closest_item then
        closest_item=ItemEnd
        position="end"
        found_item=MediaItem
    end
  end
  end
end
end
if found_item~=nil then return closest_item
else return -1
end

end

--A=reaper.CountMediaItems()
--A1,A2,A3=ultraschall.GetNextClosestItemEdge(0,3,222)


ultraschall.GetPreviousClosestItemEdge=function(tracks, cursor_type, time_position)
-- returns time and item-object of the previous closest item-start or item-end within the chosen tracks, as well as "beg" for begin and "end" for end of the returned item
-- can become slow when having thousands of items
-- string tracks - tracknumbers, seperated by a comma. A single -1 means all tracks. Negative Values will be ignored.
-- integer cursor_type - 0-edit_cursor, 1-play_cursor, 2-mouse-cursor, 3-timeposition
-- number time_position - only when cursor_type=3, else it will be ignored. time_position to check from for the previous item.

local cursortime=0
if tonumber(time_position)==nil and reaper.GetPlayState()==0 then
  time_position=reaper.GetCursorPosition()
elseif tonumber(time_position)==nil and reaper.GetPlayState~=0 then
  time_position=reaper.GetPlayPosition()
end

if tonumber(cursor_type)==nil then return -1 end
if tonumber(cursor_type)==0 then cursortime=reaper.GetCursorPosition() end
if tonumber(cursor_type)==1 then cursortime=reaper.GetPlayPosition() end
if tonumber(cursor_type)==2 then 
    reaper.BR_GetMouseCursorContext() 
    cursortime=reaper.BR_GetMouseCursorContext_Position() 
    if cursortime==-1 then return -1 end
end
if tonumber(cursor_type)==3 then
    if tonumber(time_position)==nil then return -1 end
    cursortime=tonumber(time_position)
end
if tonumber(cursor_type)>3 or tonumber(cursor_type)<0 then return -1 end

if tracks==nil then return 0 end
local tracks=tostring(tracks)

local TrackArray = ultraschall.CSV2IndividualLines(tracks)

local TrackArray2={}
--for i=0,reaper.CountTracks() do
  for k=0, reaper.CountTracks() do
    if TrackArray[k]~=nil then TrackArray2[tonumber(TrackArray[k])]=TrackArray[k]
--    reaper.MB(tostring(TrackArray[k]),"",0)
    end
  end
--end

local closest_item=-1
local found_item=nil
local position=""
--reaper.MB("","",0)
for i=0, reaper.CountMediaItems(0)-1 do
  for j=0, reaper.CountTracks(0) do

--  reaper.ShowConsoleMsg(tostring(TrackArray2[j]))
  if TrackArray2[j]~=nil and tonumber(tracks)~=-1 then  
  --reaper.MB("hui","",0)
     if ultraschall.IsItemInTrack(j,i)==true then
    local MediaItem=reaper.GetMediaItem(0, i)
    local Aretval, Astr = reaper.GetItemStateChunk(MediaItem,"<ITEMPOSITION",false)
local ItemStart=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")
local ItemEnd=reaper.GetMediaItemInfo_Value(MediaItem, "D_POSITION")+reaper.GetMediaItemInfo_Value(MediaItem, "D_LENGTH")
--    reaper.MB(ItemEnd.."\n","",0)
    if ItemStart<cursortime and ItemStart>closest_item then
--    reaper.MB("ping","",0)
        closest_item=ItemStart
        found_item=MediaItem
        position="beg"
    end
    if ItemEnd<cursortime and ItemEnd>closest_item then
        closest_item=ItemEnd
        position="end"
        found_item=MediaItem
    end
  end
  end
end
end
if found_item~=nil then return closest_item
else return -1
end

end

--A1,A2,A3=ultraschall.GetPreviousClosestItemEdge("0", 3, 202)

ultraschall.GetClosestNextMarker=function(cursor_type, time_position)
-- returns idx, position(in seconds) and name of the next closest marker

local cursortime=0
local retposition=reaper.GetProjectLength(0)--*200000000 --Working Hack, but isn't elegant....
local retindexnumber=-1
local retmarkername=""

if tonumber(time_position)==nil and reaper.GetPlayState()==0 then
  time_position=reaper.GetCursorPosition()
elseif tonumber(time_position)==nil and reaper.GetPlayState~=0 then
  time_position=reaper.GetPlayPosition()
else
  time_position=tonumber(time_position)
end

if tonumber(cursor_type)==nil then return -1 end
if tonumber(cursor_type)==0 then cursortime=reaper.GetCursorPosition() end
if tonumber(cursor_type)==1 then cursortime=reaper.GetPlayPosition() end
if tonumber(cursor_type)==2 then 
    reaper.BR_GetMouseCursorContext() 
    cursortime=reaper.BR_GetMouseCursorContext_Position() 
    if cursortime==-1 then return -1 end
end
if tonumber(cursor_type)==3 then
    if tonumber(time_position)==nil then return -1 end
    cursortime=tonumber(time_position)
end
if tonumber(cursor_type)>3 or tonumber(cursor_type)<0 then return -1 end

local retval, num_markers, num_regions = reaper.CountProjectMarkers(0)

for i=0,retval do
local  retval2, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)

  if isrgn==false then
    if pos>time_position and pos<retposition then
      retposition=pos
      retindexnumber=markrgnindexnumber
      retmarkername=name
    end
  end
end
  return retindexnumber,retposition, retmarkername
end

--A,AA,AAA=ultraschall.GetClosestNextMarker(3,144)

ultraschall.GetClosestPreviousMarker=function(cursor_type, time_position)
-- returns idx, position(in seconds) and name of the next closest marker
local cursortime=0
local retposition=0
local retindexnumber=-1
local retmarkername=""

if tonumber(time_position)==nil and reaper.GetPlayState()==0 then
  time_position=reaper.GetCursorPosition()
elseif tonumber(time_position)==nil and reaper.GetPlayState~=0 then
  time_position=reaper.GetPlayPosition()
else
  time_position=tonumber(time_position)
end

if tonumber(cursor_type)==nil then return -1 end
if tonumber(cursor_type)==0 then cursortime=reaper.GetCursorPosition() end
if tonumber(cursor_type)==1 then cursortime=reaper.GetPlayPosition() end
if tonumber(cursor_type)==2 then 
    reaper.BR_GetMouseCursorContext() 
    cursortime=reaper.BR_GetMouseCursorContext_Position() 
    if cursortime==-1 then return -1 end
end
if tonumber(cursor_type)==3 then
    if tonumber(time_position)==nil then return -1 end
    cursortime=tonumber(time_position)
end
if tonumber(cursor_type)>3 or tonumber(cursor_type)<0 then return -1 end

local retval, num_markers, num_regions = reaper.CountProjectMarkers(0)

for i=0,retval do
  local retval2, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)

  if isrgn==false then
    if pos<time_position and pos>retposition then
      retposition=pos
      retindexnumber=markrgnindexnumber
      retmarkername=name
    end
  end
end
  return retindexnumber,retposition, retmarkername

end

--A,AA,AAA=ultraschall.GetClosestPreviousMarker(3,143)

ultraschall.GetClosestNextRegion=function(cursor_type, time_position)
-- returns idx, position(in seconds) and name of the next closest marker
local cursortime=0
local retposition=reaper.GetProjectLength()--*200000000 --Working Hack, but isn't elegant....
local retindexnumber=-1
local retmarkername=""

if tonumber(time_position)==nil and reaper.GetPlayState()==0 then
  time_position=reaper.GetCursorPosition()
elseif tonumber(time_position)==nil and reaper.GetPlayState~=0 then
  time_position=reaper.GetPlayPosition()
else
  time_position=tonumber(time_position)
end

if tonumber(cursor_type)==nil then return -1 end
if tonumber(cursor_type)==0 then cursortime=reaper.GetCursorPosition() end
if tonumber(cursor_type)==1 then cursortime=reaper.GetPlayPosition() end
if tonumber(cursor_type)==2 then 
    reaper.BR_GetMouseCursorContext() 
    cursortime=reaper.BR_GetMouseCursorContext_Position() 
    if cursortime==-1 then return -1 end
end
if tonumber(cursor_type)==3 then
    if tonumber(time_position)==nil then return -1 end
    cursortime=tonumber(time_position)
end
if tonumber(cursor_type)>3 or tonumber(cursor_type)<0 then return -1 end

 local retval, num_markers, num_regions = reaper.CountProjectMarkers(0)

for i=0,retval do
   local retval2, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
--reaper.MB(name,tostring(isrgn),0)
  if isrgn==true then
    if pos>time_position and pos<retposition then
      retposition=pos
      retindexnumber=markrgnindexnumber
      retmarkername=name
    end
    if rgnend>time_position and rgnend<retposition then
      retposition=rgnend
      retindexnumber=markrgnindexnumber
      retmarkername=name
    end
  end
end
  return retindexnumber,retposition, retmarkername

end

--A,AA,AAA=ultraschall.GetClosestNextRegion(3,188)

ultraschall.GetClosestPreviousRegion=function(cursor_type, time_position)
-- returns idx, position(in seconds) and name of the next closest marker
local cursortime=0
local retposition=0
local retindexnumber=-1
local retmarkername=""

if tonumber(time_position)==nil and reaper.GetPlayState()==0 then
  time_position=reaper.GetCursorPosition()
elseif tonumber(time_position)==nil and reaper.GetPlayState~=0 then
  time_position=reaper.GetPlayPosition()
else
  time_position=tonumber(time_position)
end

if tonumber(cursor_type)==nil then return -1 end
if tonumber(cursor_type)==0 then cursortime=reaper.GetCursorPosition() end
if tonumber(cursor_type)==1 then cursortime=reaper.GetPlayPosition() end
if tonumber(cursor_type)==2 then 
    reaper.BR_GetMouseCursorContext() 
    cursortime=reaper.BR_GetMouseCursorContext_Position() 
    if cursortime==-1 then return -1 end
end
if tonumber(cursor_type)==3 then
    if tonumber(time_position)==nil then return -1 end
    cursortime=tonumber(time_position)
end
if tonumber(cursor_type)>3 or tonumber(cursor_type)<0 then return -1 end

local retval, num_markers, num_regions = reaper.CountProjectMarkers(0)

for i=0,retval do
  local retval2, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)

  if isrgn==true then
    if pos<time_position and pos>retposition then
      retposition=pos
      retindexnumber=markrgnindexnumber
      retmarkername=name
    end
    if rgnend<time_position and rgnend>retposition then
      retposition=rgnend
    end
  end
end
  return retindexnumber,retposition, retmarkername

end

--A,AA,AAA=ultraschall.GetClosestPreviousRegion(3,170)

ultraschall.GetClosestGoToPoints=function(tracks, time_position)
-- what are the closest markers/regions/item starts/itemends to position and within the chosen tracks
-- string tracks - tracknumbers, seperated by a comma.
-- position - position in seconds
--
-- returns position of previous element, type of the element, elementnumber, position of next element, type of the element, elementnumber
-- positions - in seconds
-- type - can be "Item", "Marker", "Region", "ProjectStart", "ProjectEnd"
-- elementnumber - is either the number of the item or the number of the region/marker, -1 if it's an Item.

--reaper.MB(time_position,"",0)
if tonumber(time_position)==-1 and reaper.GetPlayState()==0 then
  time_position=reaper.GetCursorPosition()
elseif tonumber(time_position)==nil and reaper.GetPlayState()~=0 then
  time_position=reaper.GetPlayPosition()
else
  time_position=tonumber(time_position)
end
--reaper.MB(time_position,"",0)

local elementposition_prev, elementtype_prev, number_prev, elementposition_next, elementtype_next, number_next=nil

local nextmarkerid,nextmarkerpos,nextmarkername=ultraschall.GetClosestNextMarker(3, time_position)
local prevmarkerid,prevmarkerpos,prevmarkername=ultraschall.GetClosestPreviousMarker(3,time_position)

local nextitempos=ultraschall.GetNextClosestItemEdge(tracks,3,time_position)
local previtempos=ultraschall.GetPreviousClosestItemEdge(tracks,3,time_position)

local nextrgnID, nextregion=ultraschall.GetClosestNextRegion(3,time_position)
local prevrgnID, prevregion=ultraschall.GetClosestPreviousRegion(3,time_position)

if nextmarkerpos<nextitempos then elementposition_next=nextmarkerpos elementtype_next="Marker" number_next=nextmarkerid
elseif nextitempos==-1 then elementposition_next=nextmarkerpos elementtype_next="Marker" number_next=nextmarkerid
else elementposition_next=nextitempos elementtype_next="Item" number_next=-1 end

if prevmarkerpos>previtempos then elementposition_prev=prevmarkerpos elementtype_prev="Marker" number_prev=prevmarkerid
else elementposition_prev=previtempos elementtype_prev="Item" number_prev=-1 end

if prevregion>elementposition_prev then elementposition_prev=prevregion elementtype_prev="Region" number_prev=prevrgnID end
if nextregion<elementposition_next then elementposition_next=nextregion elementtype_next="Region" number_next=nextrgnID end

if elementposition_prev<=0 then elementposition_prev=0 elementtype_prev="ProjectStart" end
if elementposition_next>=reaper.GetProjectLength() then elementtype_next="ProjectEnd" end

return elementposition_prev, elementtype_prev, number_prev, elementposition_next, elementtype_next, number_next
end

--Aprev1,Aprev2,Aprev3,Anext1,Anext2,Anext3 = ultraschall.GetClosestGoToPoints(0,20)

-----------------------------
---- Muting/Cough Button ----
-----------------------------

ultraschall.ToggleMute=function(track, position, state)
-- state 0=mute, 1=unmute
  if tonumber(track)==nil or tonumber(track)<0 or tonumber(track)>reaper.CountTracks(0)-1 then return -1 end  
  if tonumber(position)==nil or tonumber(position)<0 then return -1 end
  if tonumber(state)==nil or tonumber(state)<0 or tonumber(state)>1 then return -1 end
  
  local Track=reaper.GetTrack(0, track)
  local MuteEnvelopeTrack=reaper.GetTrackEnvelopeByName(Track, "Mute")
  local C=reaper.InsertEnvelopePoint(MuteEnvelopeTrack, position, state, 1, 0, 0)
  reaper.UpdateArrange()
  return 0
end

--ultraschall.ToggleMute(0,reaper.GetPlayPosition(),1)

ultraschall.ToggleMute_TrackObject=function(trackobject, position, state)
-- state 0=mute, 1=unmute
-- returns -1 when it didn't work
  if trackobject==nil then return -1 end
  local Aretval=reaper.ValidatePtr2(0, trackobject, "MediaTrack*")
    if Aretval==false then return -1 end
  if tonumber(position)==nil or tonumber(position)<0 then return -1 end
  if tonumber(state)==nil or tonumber(state)<0 or tonumber(state)>1 then return -1 end
  
  local numtracks=reaper.CountTracks(0)-1
  local itworked=-1
  
  for i=0,numtracks do
    if trackobject==reaper.GetTrack(0,i) then 
        local MuteEnvelopeTrack=reaper.GetTrackEnvelopeByName(trackobject, "Mute")
        local C=reaper.InsertEnvelopePoint(MuteEnvelopeTrack, position, state, 1, 0, 0)
        itworked=0
    end
  end
  return itworked
end

--Track=reaper.GetTrack(0, 0)
--A,AA,AAA=ultraschall.ToggleMute_TrackObject(Track,reaper.GetPlayPosition(),0)
--Track="MackieMesser"
--CC=ultraschall.ToggleMute(0,0,1)
--CC=ultraschall.ToggleMute_TrackObject(Track,80,1)

ultraschall.GetNextMuteState=function(track, position)
-- returns the next mute-envelope-point, it's value and it's time, in relation to position
-- Envelope-Points numbering starts with 0!
-- returns -1 if not existing
  local retval, time, value, shape, tension, selected 
  local MediaTrack=reaper.GetTrack(0, track)
  local TrackEnvelope=reaper.GetTrackEnvelopeByName(MediaTrack, "Mute")
  local Ainteger=reaper.GetEnvelopePointByTime(TrackEnvelope, position)
  if Ainteger==-1 then retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint(TrackEnvelope, 0) Ainteger=-1
  else retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint(TrackEnvelope, Ainteger+1) 
  end
  if Ainteger+1>reaper.CountEnvelopePoints(TrackEnvelope)-1 then return -1 end
  return Ainteger+1, value, time
end

--A,AA,AAA,AAAA=ultraschall.GetNextMuteState(0,15)

ultraschall.GetPreviousMuteState=function(track, position)
-- returns the previous mute-envelope-point, it's value and it's time, in relation to position
-- Envelope-Points numbering starts with 0!
-- returns -1 if not existing
  local MediaTrack=reaper.GetTrack(0, track)
  local TrackEnvelope=reaper.GetTrackEnvelopeByName(MediaTrack, "Mute")
  local Ainteger=reaper.GetEnvelopePointByTime(TrackEnvelope, position)
  local retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint(TrackEnvelope, Ainteger)
  return Ainteger, value, time
end

--A,AA,AAA,AAAA=ultraschall.GetPreviousMuteState(0,14)

ultraschall.GetNextMuteState_TrackObject=function(MediaTrack, position)
-- returns the next mute-envelope-point, it's value and it's time, in relation to position
-- Envelope-Points numbering starts with 0!
-- returns -1 if not existing
  local retval, time, value, shape, tension, selected
  if tonumber(position)==nil then return -1 end
  position=tonumber(position)
  if position<0 then return -1 end
  local Aretval=reaper.ValidatePtr2(0, MediaTrack, "MediaTrack*")
  if Aretval==false then return -1 end
  local TrackEnvelope=reaper.GetTrackEnvelopeByName(MediaTrack, "Mute")
  if TrackEnvelope==nil then return -1 end
  local Ainteger=reaper.GetEnvelopePointByTime(TrackEnvelope, position)
  if Ainteger==-1 then retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint(TrackEnvelope, 0) Ainteger=-1
  else retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint(TrackEnvelope, Ainteger+1) 
  end
  if Ainteger+1>reaper.CountEnvelopePoints(TrackEnvelope)-1 then return -1 end
  return Ainteger+1, value, time
end

ultraschall.GetPreviousMuteState_TrackObject=function(MediaTrack, position)
-- returns the previous mute-envelope-point, it's value and it's time, in relation to position
-- Envelope-Points numbering starts with 0!
-- returns -1 if not existing
  if tonumber(position)==nil then return -1 end
  position=tonumber(position)
  if position<0 then return -1 end
  local Aretval=reaper.ValidatePtr2(0, MediaTrack, "MediaTrack*")
  if Aretval==false then return -1 end
  local TrackEnvelope=reaper.GetTrackEnvelopeByName(MediaTrack, "Mute")
  if TrackEnvelope==nil then return -1 end
  local Ainteger=reaper.GetEnvelopePointByTime(TrackEnvelope, position)
  local retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint(TrackEnvelope, Ainteger)
  return Ainteger, value, time
end

--  MediaTrack=reaper.GetTrack(0, 0)
--  A,AA,AAA=ultraschall.GetNextMuteState_TrackObject(MediaTrack,"10")
  
ultraschall.CountMuteEnvelopePoints=function(track)
--returns the number of the envelope-points in the Mute-lane of track "track"
  if tonumber(track)==nil then return -1 end
  track=tonumber(track)
  if track<0 then return -1 end
  local MediaTrack=reaper.GetTrack(0, track)
  local TrackEnvelope=reaper.GetTrackEnvelopeByName(MediaTrack, "Mute")
  if TrackEnvelope==nil then return -1 end
  return reaper.CountEnvelopePoints(TrackEnvelope)
end

--A=ultraschall.CountMuteEnvelopePoints(0)

-------------------------------
---- Toggle States&Buttons ----
-------------------------------

ultraschall.ToggleStateAction=function(section, actioncommand_id, state)
-- Toggles state of an actioncommand_id
-- returns current state of the action after toggling
--
-- section - section (usually 0 for main)
-- actioncommand_id - the ActionCommandID of the Action you'll want to toggle
-- state - 0 for off, 1 for on
--
-- If you have a button associated, you'll need to use RefreshToolbar() later!

  if actioncommand_id==nil then return -1 end
  if tonumber(state)==nil then return -1 end
  if tonumber(section)==nil then return -1 end
  local command_id = reaper.NamedCommandLookup(actioncommand_id)
  reaper.SetToggleCommandState(section, command_id, state)
  return reaper.GetToggleCommandState(command_id)
end



ultraschall.RefreshToolbar_Action=function(section, actioncommand_id)
-- Refreshes a toolbarbutton with an ActionCommandID
--
-- section - section
-- actioncommand_id - ActionCommandID of the action, associated with the toolbarbutton

  if actioncommand_id==nil then return -1 end
  if tonumber(section)==nil then return -1 end
  
  local command_id = reaper.NamedCommandLookup(actioncommand_id)
  reaper.RefreshToolbar2(0, command_id)
  return 0
end


ultraschall.ToggleStateButton=function(section, actioncommand_id, state)
-- Toggles state and refreshes the button of an actioncommand_id
-- section - section (usually 0 for main)
-- actioncommand_id - the ActionCommandID of the Action you'll want to toggle
-- state - 0 for off, 1 for on

  if actioncommand_id==nil then return false end
  if tonumber(state)==nil then return false end
  if tonumber(section)==nil then return false end

  local command_id = reaper.NamedCommandLookup(actioncommand_id)
  local stater=reaper.SetToggleCommandState(section, command_id, state)
  reaper.RefreshToolbar(command_id)
  return stater
end

--ultraschall.ToggleStateButton(0,"_Ultraschall_OnAir" ,0)

---------------------
---- Ripple Edit ----
---------------------

ultraschall.RippleEdit=function(Tracks, Startposition, Endposition)
-- Tracks is a string of tracks(seperated by a ,), where the Ripple shall be applied to.

end

---------------------
---- Add Markers ----
---------------------

ultraschall.AddNormalMarker=function(position, shown_number, markertitle)
-- Adds a normal Marker, not specifically for shownotes or chapter, etc
-- position - position in seconds; must be positive value
-- shown_number - the indexnumber shown in Reaper for this marker
-- markertitle - the title of the marker

  local noteID=0
  if tonumber(position)==nil then return -1 end
  if tonumber(shown_number)==nil then return -1 end
  if markertitle==nil then markertitle="" end

  if position>=0 then noteID=reaper.AddProjectMarker2(0, false, position, 0, markertitle, shown_number, 0)
  else noteID=-1
end
  return noteID
end


ultraschall.AddPodRangeRegion=function(startposition, endposition)
-- creates a region that marks the begin and end of the podcast with a _PodRange:-region.
-- only one _PodRange:-region is allowed, all others will be deleted by this function!
-- helps find the right offsets for correct positioning of the chapters/shownote/markers 
-- in the exportfile
--
-- startposition - starting-position of the range in seconds; must be a positive value
-- endposition - end-position of the range in seconds; must be bigger than endposition
-- returns -1 if it fails

local color=0
local retval=0
local isrgn=true
local pos=0
local rgnend=0
local name=""
local markrgnindexnumber=""
local noteID=0

  local os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0xFFFFFF|0x1000000
    else
      color = 0xFFFFFF|0x1000000
    end

  local a,nummarkers,numregions=reaper.CountProjectMarkers(0)
  local count=0
  startposition=tonumber(startposition)
  endposition=tonumber(endposition)
  if startposition==nil then return -1 end
  if endposition==nil then return -1 end
  if startposition<0 then return -1 end
  if endposition<startposition then return -1 end
  
  for i=nummarkers+numregions, 0, -1 do
    retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name:sub(1,10)=="_PodRange:" and isrgn==true then count=count+1 reaper.DeleteProjectMarkerByIndex(0,i) end 
  end
  
  noteID=reaper.AddProjectMarker2(0, 1, startposition, endposition, "_PodRange:", 0, color)

return noteID
end

--ultraschall.AddPodRangeRegion(20,30)

ultraschall.AddChapterMarker=function(position, shown_number, chaptertitle)
-- Adds a Chaptermarker. 
-- position - is time in seconds, 
-- shown_number - the number shown with the marker in Reaper
-- chaptertitle - a string of the title of this chapter
-- If no chaptertitle is given, it will write "_Chapter:" only
-- returns -1 if position isn't a valid value
  local color=0
  local noteID=0
  local os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0x0000FF|0x1000000
    else
      color = 0xFF0000|0x1000000
    end

  position=tonumber(position)
  shown_number=tonumber(shown_number)
  if position==nil then return -1 end
  if shown_number==nil then return -1 end
  if chaptertitle==nil then chaptertitle="" end

  if position>=0 then noteID=reaper.AddProjectMarker2(0, false, position, 0, "_Chapter:"..chaptertitle, shown_number, color) -- set yellow-chapter-marker
  else noteID=-1
  end
  
  return noteID
end

--ultraschall.AddChapterMarker(1,20,"hui")

ultraschall.AddShownoteMarker=function(position, shownotetitle, URL)
--!! TODO - local machen der Variablen!!

-- Adds a Shownotemarker. 
-- position - is time in seconds, 
-- shown_number - the number shown with the marker in Reaper, 
-- shownotetitle - a string for the title of the shownote, 
-- URL - a string for the URL.
--
-- If no shownotetitle is given, it will write "_Shownote:" only, if no URL is given, it will add --<>--
-- returns -1 if position isn't a valid value
  numShownotes=ultraschall.CountShownoteMarkers()
  shown_number=0
  for i=1,numShownotes+1 do
    A,shown_numbertemp=ultraschall.EnumerateShownoteMarkers(i)
--    reaper.MB(shown_number,shown_numbertemp,0)
    if tonumber(shown_numbertemp)~=nil then
      if shown_number<tonumber(shown_numbertemp) then shown_number=tonumber(shown_numbertemp) end
    end
  end

  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0x00AA00|0x1000000
    else
      color = 0x00AA00|0x1000000
    end

  if position==nil then position=-1 end
  if URL==nil then URL="" end
  if shownotetitle==nil then shownotetitle="" end

  if position>=0 then noteID=reaper.AddProjectMarker2(0, false, position, 0, "_Shownote: "..shownotetitle.." URL:"..URL, shown_number+1, color) -- set green shownote-marker
                      reaper.SetProjExtState(0, "Ultraschall_Shownotes", "TITLE"..shown_number+1, shownotetitle)
                      reaper.SetProjExtState(0, "Ultraschall_Shownotes", "URL"..shown_number+1, URL)
  else noteID=-1
  end

  return noteID
end



ultraschall.test=function()
--C,CC,CCC,CCCC= ultraschall.AddShownoteMarker(19,"Testomat3000","achherrje.de")
--A,AA=reaper.GetProjExtState(0, "Ultraschall_Shownotes", "TITLE".."29")
--B,BB=reaper.GetProjExtState(0, "Ultraschall_Shownotes", "URL".."29")
end


ultraschall.AddEditMarker=function(position, shown_number, edittitle)
-- Adds an Editmarker. 
-- position - is time in seconds, 
-- shown_number - the number shown with the Edit-Marker in Reaper
-- edittitle - a string of a description for this Edit-marker
--
-- If no chaptertitle is given, it will write "_Edit:" only
-- returns -1 if position isn't a valid value

  local color=0
  local noteID=0
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0xFF0000|0x1000000
    else
      color = 0x0000FF|0x1000000
    end

  position=tonumber(position)
  shown_number=tonumber(shown_number)
  if position==nil then return -1 end
  if shown_number==nil then return -1 end
  if edittitle==nil then edittitle="" end

  if position>=0 then noteID=reaper.AddProjectMarker2(0, false, position, 0, "_Edit:"..edittitle, shown_number, color) -- set red edit-marker
  else noteID=-1
  end

  return noteID
end

--ultraschall.AddEditMarker(13,20,"hui")


ultraschall.AddDummyMarker=function(position, shown_number, dummytitle)
-- Adds a Dummymarker. 
-- position - is time in seconds, 
-- shown_number - the number shown with the Dummy-Marker in Reaper
-- edittitle - a string of a description for this Dummy-marker
--
-- If no chaptertitle is given, it will write "_Dummy:" only
-- returns -1 if position isn't a valid value

  local color=0
  local noteID=0
  
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0x999999|0x1000000
    else
      color = 0x999999|0x1000000
    end

  position=tonumber(position)
  shown_number=tonumber(shown_number)
  if position==nil then return -1 end
  if shown_number==nil then return -1 end
  if dummytitle==nil then dummytitle="" end

  if position>=0 then noteID=reaper.AddProjectMarker2(0, false, position, 0, "_Dummy:"..dummytitle, shown_number, color)
  else noteID=-1
  end

  return noteID
end

--ultraschall.AddDummyMarker(9,20,"hui")

-----------------------
---- Count Markers ----
-----------------------

ultraschall.CountNormalMarkers=function()
-- returns number of normal markers in the project
  local nix=""
  local a,nummarkers,b=reaper.CountProjectMarkers(0)
  local count=0
  for i=0, nummarkers-1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name==nil then name="" end
    if name:sub(1,10)=="_Shownote:" or name:sub(1,9)=="_Chapter:" or name:sub(1,6)=="_Edit:" or name:sub(1,7)=="_PodStart:" or name:sub(1,5)=="_End:" or name:sub(1,10)=="_LiveEdit:" or name:sub(1,7)=="_Dummy:" then nix="1"
    else count=count+1 
    end
    end 

  return count
end


ultraschall.CountShownoteMarkers=function()
-- returns number of _Shownote: markers in the project

  local a,nummarkers,b=reaper.CountProjectMarkers(0)
  local count=0
  for i=0, nummarkers-1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name:sub(1,10)=="_Shownote:" then count=count+1 end
  end

  return count
end

--A=ultraschall.CountShownoteMarkers()

ultraschall.CountChapterMarkers=function()
-- returns number of _Chapter: markers in the project

  local a,nummarkers,b=reaper.CountProjectMarkers(0)
  local count=0
  for i=0, nummarkers-1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name:sub(1,9)=="_Chapter:" then count=count+1 end 
  end

  return count
end

--A=ultraschall.CountChapterMarkers()

ultraschall.CountEditMarkers=function()
-- returns number of _Edit: markers in the project

  local a,nummarkers,b=reaper.CountProjectMarkers(0)
  local count=0
  for i=0, nummarkers-1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name:sub(1,6)=="_Edit:" then count=count+1 end 
  end

  return count
end

--A=ultraschall.CountEditMarkers()

ultraschall.CountDummyMarkers=function()
-- returns number of _Edit: markers in the project

  local a,nummarkers,b=reaper.CountProjectMarkers(0)
  local count=0
  for i=0, nummarkers-1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name:sub(1,7)=="_Dummy:" then count=count+1 end 
  end

  return count
end

--A=ultraschall.CountDummyMarkers()

---------------------------
---- Enumerate Markers ----
---------------------------

ultraschall.GetPodRangeRegion=function()
-- returns startposition and endposition of the PodRange-Region.
-- only one _PodRange:-region is allowed, if there are more, it will return -1

  local color=0
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0xFFFFFF|0x1000000
    else
      color = 0xFFFFFF|0x1000000
    end

  local a,nummarkers,numregions=reaper.CountProjectMarkers(0)
  local startposition=0
  local endposition=0
  local count=0
  
  for i=nummarkers+numregions, 0, -1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name:sub(1,10)=="_PodRange:" and isrgn==true then startposition=pos endposition=rgnend count=count+1 end 
  end
  
  if count>1 then return -1, -1
  else return startposition, endposition
  end
end

--A,AA=ultraschall.GetPodRangeRegion()

ultraschall.EnumerateNormalMarkers=function(number)
-- returns number of markers in general(not chaptermarker!), the shown marker-number,chaptername-name of the marker

  number=tonumber(number)
  if number==nil then return -1 end
  local a,nummarkers,b=reaper.CountProjectMarkers(0)
  if tonumber(number)==nil then return -1,-1,-1,-1 end
  local number=number-1
  local wentfine=0
  local count=-1
  local retnumber=0
  local retidxnum=""
  local markername=""
  local position=0
  local smile=""
  for i=0, nummarkers-1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if isrgn==false then
--    reaper.MB(name:sub(1,10),tostring(nummarkers),0)
      if name:sub(1,10)=="_Shownote:" or name:sub(1,9)=="_Chapter:" or name:sub(1,6)=="_Edit:" or name:sub(1,10)=="_LiveEdit:" or name:sub(1,7)=="_Dummy:" then smile=""
      else count=count+1  
      end
    end
    if number>=0 and wentfine==0 and count==number then
--    reaper.MB(name:sub(1,10),"",0)
        retnumber=retval 
        markername=name
        retidxnum=markrgnindexnumber
        position=pos
        wentfine=1
    end
  end
  
  if wentfine==1 then return retnumber, retidxnum, position, markername
  else return -1, ""
  end
end


ultraschall.EnumerateChapterMarkers=function(number)
-- Get the data of a _Chapter: marker
-- returns number, ID, position(in seconds) and the chaptername

  number=tonumber(number)
  if number==nil then return -1 end
  local a,nummarkers,b=reaper.CountProjectMarkers(0)
  local number=number-1
  local wentfine=0
  local count=-1
  local retnumber=0
  local retidxnum=""
  local chaptername=""
  local position=0
  for i=0, nummarkers-1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name:sub(1,9)=="_Chapter:" then count=count+1 end 
    if number>=0 and wentfine==0 and count==number then 
        retnumber=retval 
        chaptername=name :sub(10,-1)
        retidxnum=markrgnindexnumber
        position=pos
        wentfine=1
    end
  end
  
  if wentfine==1 then return retnumber, retidxnum, position, chaptername
  else return -1, ""
  end
end

--A=ultraschall.AddChapterMarker(4,4,"DD")
--A,A2,A3,A4=ultraschall.EnumerateChapterMarkers("1")

ultraschall.EnumerateDummyMarkers=function(number)
-- Get the data of a _Dummy: marker
-- returns number, ID, position(in seconds) and the dummyname

  number=tonumber(number)
  if number==nil then return -1 end
  local a,nummarkers,b=reaper.CountProjectMarkers(0)
  local number=number-1
  local wentfine=0
  local count=-1
  local retnumber=0
  local retidxnum=""
  local chaptername=""
  local position=0
  for i=0, nummarkers-1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name:sub(1,7)=="_Dummy:" then count=count+1 end 
    if number>=0 and wentfine==0 and count==number then 
        retnumber=retval 
        chaptername=name :sub(8,-1)
        retidxnum=markrgnindexnumber
        position=pos
        wentfine=1
    end
  end
  
  if wentfine==1 then return retnumber, retidxnum, position, chaptername
  else return -1, ""
  end
end

--A=ultraschall.AddDummyMarker(4,4,"D")
--A,AA,AAA,AAAA=ultraschall.EnumerateDummyMarkers(1)

ultraschall.EnumerateShownoteMarkers=function(number)
-- !TODO : local machen von variablen

-- Get the data of a _Shownote marker
-- returns number, ID, position(in seconds), shownotename and the URL

  if number==nil then return -1 end
  c,nummarkers,b=reaper.CountProjectMarkers(0)
  number=number-1
  wentfine=0
  count=-1
  retnumber=0
  tempo=-4
  retidxnum=""
  shownotename=""
  for i=0, nummarkers-1 do
    retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name:sub(1,10)=="_Shownote:" then count=count+1 end 
    if number>=0 and wentfine==0 and count==number then 
        retnumber=retval
        shownotename=name--:match("(_Shownote:.*--<)")
        if shownotename==nil then shownotename="_Shownote:" tempo=-1 end--shownotename=name:match("(_Shownote:.*)") tempo=-1 end
        shown_number_temp=markrgnindexnumber
        retidxnum=markrgnindexnumber
        position=pos
        URL=name:match("(--<.*>--)")
        if URL==nil then URL="" end
        wentfine=1
    end
  end

  
  if wentfine==1 then 
    A,TITLE_State=reaper.GetProjExtState(0, "Ultraschall_Shownotes", "TITLE"..tostring(shown_number_temp))
    B,URL_State=reaper.GetProjExtState(0, "Ultraschall_Shownotes", "URL"..tostring(shown_number_temp))
    return retnumber, retidxnum, position, shownotename:sub(11,-1), TITLE_State, URL_State
  else return -1, ""
  end
end

--A=ultraschall.AddShownoteMarker(301,"vier","vier.de")
--ret,retid,pos,name,tit,urlst=ultraschall.EnumerateShownoteMarkers(2)

ultraschall.EnumerateShownoteMarkers_ByShownNumber=function(shown_number)
-- !TODO : local machen von variablen

-- Get the data of a _Shownote marker
-- returns number, ID, position(in seconds), shownotename and the URL

  number=tonumber(number)
  if number==nil then return -1 end
  c,nummarkers,b=reaper.CountProjectMarkers(0)
  number=number-1
  wentfine=0
  count=-1
  retnumber=0
  tempo=-4
  retidxnum=""
  shownotename=""
  for i=0, nummarkers-1 do
    retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name:sub(1,10)=="_Shownote:" then count=count+1 end 
    if number>=0 and wentfine==0 and count==number then 
        retnumber=retval
        shownotename=name--:match("(_Shownote:.*--<)")
        if shownotename==nil then shownotename="_Shownote:" tempo=-1 end--shownotename=name:match("(_Shownote:.*)") tempo=-1 end
        shown_number_temp=markrgnindexnumber
        retidxnum=markrgnindexnumber
        position=pos
        URL=name:match("(--<.*>--)")
        if URL==nil then URL="" end
        wentfine=1
    end
  end

  
  if wentfine==1 then 
    A,TITLE_State=reaper.GetProjExtState(0, "Ultraschall_Shownotes", "TITLE"..tostring(shown_number_temp))
    B,URL_State=reaper.GetProjExtState(0, "Ultraschall_Shownotes", "URL"..tostring(shown_number_temp))
    return retnumber, retidxnum, position, shownotename:sub(11,-1), TITLE_State, URL_State
  else return -1, ""
  end
end


ultraschall.EnumerateEditMarkers=function(number)
-- Get the data of an _Edit marker
-- returns number, ID, position(in seconds) and the editmarker-name

  number=tonumber(number)
  if number==nil then return -1 end
  local a,nummarkers,b=reaper.CountProjectMarkers(0)
  local number=number-1
  local wentfine=0
  local count=-1
  local retnumber=0
  local retidxnum=""
  local editname=""
  local position=0
  for i=0, nummarkers-1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name:sub(1,6)=="_Edit:" then count=count+1 end 
    if number>=0 and wentfine==0 and count==number then 
    --  reaper.MB(tostring(count),tostring(number),0)
        retnumber=retval 
        editname=name :sub(7,-1)
        retidxnum=markrgnindexnumber
        position=pos
        wentfine=1
    end
  --reaper.MB(name,tostring(count),0)
  end
  if wentfine==1 then return retnumber, retidxnum, position, editname
  else return -1, ""
  end
end

--A=ultraschall.AddEditMarker(4,4,"titleD")
--A,AA,AAA,AAAA=ultraschall.EnumerateEditMarkers("1")


ultraschall.GetAllChapterMarkers=function()
--returns the number of chapters and an array of each chaptermarker in the format:
-- chaptermarkersarray [index] [0-position;1-chaptername]
  local count=ultraschall.CountChapterMarkers()
  local numnums=count
  
  local chaptermarkersarray = {}
  for i=1, count do
    chaptermarkersarray[i]={}
    local a,b,position,name=ultraschall.EnumerateChapterMarkers(i)
    chaptermarkersarray[i][0]=position
    chaptermarkersarray[i][1]=name
  end

return numnums, chaptermarkersarray
end

--A,AA=ultraschall.GetAllChapterMarkers()

ultraschall.GetAllShownoteMarkers=function()
--TODO: local machen von variablen

--returns the number of shownotes and an array of each shownote in the format:
-- shownotemarkersarray[index] [0-position;1-shownotename]
  local count=ultraschall.CountShownoteMarkers()
  local numnums=count

  local shownotemarkersarray = {}
  for i=1, count do
    shownotemarkersarray[i]={}
    local a,b,position,name=ultraschall.EnumerateShownoteMarkers(i)
    shownotemarkersarray[i][0]=position
    shownotemarkersarray[i][1]=name
  end

return numnums, shownotemarkersarray
end

--A,AA=ultraschall.GetAllShownoteMarkers()


ultraschall.GetAllEditMarkers=function()
--returns the number of edits and an array of each editmarker in the format:
-- editmarkersarray [index] [0-position;1-editname]
  local count=ultraschall.CountEditMarkers()
  local numnums=count

  local editmarkersarray = {}
  for i=1, count do
    editmarkersarray[i]={}
    local a,b,position,name=ultraschall.EnumerateEditMarkers(i)
    editmarkersarray[i][0]=position
    editmarkersarray[i][1]=name
  end

return numnums, editmarkersarray
end

--A,AA=ultraschall.GetAllEditMarkers()

ultraschall.GetAllNormalMarkers=function()
--returns the number of normal markers and an array of each normal marker in the format:
-- normalmarkersarray [index] [0-position;1-normalmarkername]
  local count=ultraschall.CountNormalMarkers()
  local numnums=count
  
  local normalmarkersarray = {}
  for i=1, count do
    normalmarkersarray[i]={}
    local a,b,position,name=ultraschall.EnumerateNormalMarkers(i)
    normalmarkersarray[i][0]=position
    normalmarkersarray[i][1]=name
  end

return numnums, normalmarkersarray
end

--A,AA=ultraschall.GetAllNormalMarkers()

ultraschall.GetAllMarkers=function()
-- count - number of markers
-- markersarray - an array with all names excluding _edit:, _shownote:, _chapter:. Switching between markername, type of marker, markername, type of maker
  local count,aa,bb= reaper.CountProjectMarkers(0)

  local markersarray = {}
  local numnums=count
  for i=1, count do
    markersarray[i]={}
    local a,b,position,name=ultraschall.EnumerateNormalMarkers(i)
    local retval, isrgn, position, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3(0, i)
    markersarray[i][0]=position
    markersarray[i][1]=name
  end

return numnums, markersarray
end

--A,AA=ultraschall.GetAllMarkers()

----------------------
---- Set Markers -----
----------------------

ultraschall.SetNormalMarker=function(number, position, shown_number, markertitle)
-- Sets values of a normal Marker(no _Chapter:, _Shownote:, etc)
-- number - number of the marker, 1 to current number of markers
-- position - position in seconds; -1 - keep the old value
-- shown_number - the number shown with the marker in Reaper; -1 - keep the old value
-- markertitle - title of the marker; nil - keep the old value
--
-- returns true if successful and false if not(i.e. marker doesn't exist)

  local color=0
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0xFF0000|0x1000000
    else
      color = 0x0000FF|0x1000000
    end
  if tonumber(position)==nil then position=-1 end
  if tonumber(position)<0 then position=-1 end
  if tonumber(shown_number)==nil then shown_number=-1 end
  if tonumber(number)==nil then return false end
  
  local nix=""
  local c,nummarkers,b=reaper.CountProjectMarkers(0)
  number=tonumber(number)-1
  local wentfine=0
  local count=-1
  local retnumber=0
  for i=0, nummarkers-1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if isrgn==false then
      if name:sub(1,10)=="_Shownote:" or name:sub(1,9)=="_Chapter:" or name:sub(1,6)=="_Edit:" or name:sub(1,10)=="_LiveEdit:" or name:sub(1,7)=="_Dummy:" then nix="1"
      else count=count+1
      end
    end
    if number>=0 and wentfine==0 and count==number then
        if tonumber(position)==-1 or position==nil then position=pos end
        if tonumber(shown_number)<=-1 or shown_number==nil then shown_number=markrgnindexnumber end
        if markertitle==nil then markertitle=name end
        retnumber=i
        wentfine=1
    end
  end
  
  if markertitle==nil then markertitle="" end
  
  if wentfine==1 then return reaper.SetProjectMarkerByIndex(0, retnumber, 0, position, 0, shown_number, markertitle, 0)
  else return false
  end
end

--A=ultraschall.SetNormalMarker(1,2,33,"hurtz")

ultraschall.SetEditMarker=function(number, position, shown_number, edittitle)
-- Sets values of an Edit-Marker
-- number - number of the _Edit-marker, 1 to current number of _Edit-markers
-- position - position in seconds; -1 - keep the old value
-- shown_number - the number shown with the marker in Reaper; -1 - keep the old value
-- edittitle - title of the editmarker; nil - keep the old value
--
-- returns true if successful and false if not(i.e. marker doesn't exist)

  local color=0
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0xFF0000|0x1000000
    else
      color = 0x0000FF|0x1000000
    end
  if tonumber(position)==nil then position=-1 end
  if tonumber(position)<0 then position=-1 end
  if tonumber(shown_number)==nil then shown_number=-1 end
  if tonumber(number)==nil then return false end
  
  local c,nummarkers,b=reaper.CountProjectMarkers(0)
  number=tonumber(number)-1
  local wentfine=0
  local count=-1
  local retnumber=0
  for i=0, nummarkers-1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name:sub(1,6)=="_Edit:" then count=count+1 end 
    if number>=0 and wentfine==0 and count==number then 
        if tonumber(position)==-1 or position==nil then position=pos end
        if tonumber(shown_number)<=-1 or shown_number==nil then shown_number=markrgnindexnumber end
        if edittitle==nil then edittitle=name:match("(_Edit:.*)") edittitle=edittitle:sub(7,-1) end
        retnumber=i
        wentfine=1
    end
  end
  
  if edittitle==nil then edittitle="" end
  
  if wentfine==1 then return reaper.SetProjectMarkerByIndex(0, retnumber, 0, position, 0, shown_number, "_Edit:" .. edittitle, color)
  else return false
  end
end

--A=ultraschall.SetEditMarker(1,6,10,"Editmarke1")

ultraschall.SetChapterMarker=function(number, position, shown_number, chaptertitle)
-- Sets values of a Chapter-Marker
-- number - number of the _Chapter-marker, 1 to current number of _Chapter-markers
-- position - position in seconds; -1 - keep the old value
-- shown_number - the number shown with the marker in Reaper; -1 - keep the old value
-- chaptertitle - title of the chapter; nil - keep the old value
--
-- returns true if successful and false if not(i.e. marker doesn't exist)

  local color=0
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0x0000FF|0x1000000
    else
      color = 0xFF0000|0x1000000
    end 

  if tonumber(position)==nil then position=-1 end
  if tonumber(position)<0 then position=-1 end
  if tonumber(shown_number)==nil then shown_number=-1 end
  if tonumber(number)==nil then return false end
  
  local c,nummarkers,b=reaper.CountProjectMarkers(0)
  number=tonumber(number)-1
  local wentfine=0
  local count=-1
  local retnumber=0
  for i=0, nummarkers-1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name:sub(1,9)=="_Chapter:" then count=count+1 end 
    if number>=0 and wentfine==0 and count==number then 
        if tonumber(position)==-1 or position==nil then position=pos end
        if tonumber(shown_number)<=-1 or shown_number==nil then shown_number=markrgnindexnumber end
        if chaptertitle==nil then chaptertitle=name:match("(_Chapter:.*)") chaptertitle=chaptertitle:sub(10,-1) end
        retnumber=i
        wentfine=1
    end
  end
  
  if chaptertitle==nil then chaptertitle="" end
  
  if wentfine==1 then return reaper.SetProjectMarkerByIndex(0, retnumber, 0, position, 0, shown_number, "_Chapter:" .. chaptertitle, color)
  else return false
  end
end

--A=ultraschall.AddChapterMarker(1,10,10,"Kapitel")
--A=ultraschall.SetChapterMarker(1,2,11,"Kapitel6")


ultraschall.SetShownoteMarker=function(number, position, shownotetitle, URL)
-- TODO: local machen von variablen

-- Sets values of a Shownote-Marker
-- number - number of the _Shownote-marker, 1 to current number of _Shownote-markers
-- position - position in seconds; -1 - keep the old value
-- shown_number - the number shown with the marker in Reaper; -1 - keep the old value
-- shownotetitle - title of the shownote; nil - keep the old value
-- URL - URL for the title; nil - keep the old value
--
-- returns true if successful and false if not(i.e. marker doesn't exist)

  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0x00AA00|0x1000000
    else
      color = 0x00AA00|0x1000000
    end

  if tonumber(position)==nil then position=-1 end
  if tonumber(position)<0 then position=-1 end
  if tonumber(shown_number)==nil then shown_number=-1 end
  if tonumber(number)==nil then return false end
  
  c,nummarkers,b=reaper.CountProjectMarkers(0)
  number=tonumber(number)-1
  wentfine=0
  count=-1
  retnumber=0
  for i=0, nummarkers-1 do
    retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name:sub(1,10)=="_Shownote:" then count=count+1 end 
    if number>=0 and wentfine==0 and count==number then 
    shown_number_temp=markrgnindexnumber
        if tonumber(position)==-1 or position==nil then position=pos end
        if tonumber(shown_number)<=-1 or shown_number==nil then shown_number=markrgnindexnumber end
        if shownotetitle==nil then shownotetitle=name:match("(_Shownote:.*)") shownotetitle=shownotetitle:sub(11,-1) end
        if URL==nil then 
--        A,TITLE_State=reaper.GetProjExtState(0, "Ultraschall_Shownotes", "TITLE"..tostring(shown_number_temp))
        B,URL=reaper.GetProjExtState(0, "Ultraschall_Shownotes", "URL"..tostring(shown_number_temp))
        end
        retnumber=i
        wentfine=1
    end
  end
  
  if URL==nil then 
  B,URL=reaper.GetProjExtState(0, "Ultraschall_Shownotes", "URL"..tostring(shown_number_temp))
  end
  if shownotetitle==nil then shownotetitle="" end
  
  if wentfine==1 then reaper.SetProjExtState(0, "Ultraschall_Shownotes", "TITLE"..tostring(shown_number_temp), shownotetitle)
                      reaper.SetProjExtState(0, "Ultraschall_Shownotes", "URL"..tostring(shown_number_temp), URL)
                      return reaper.SetProjectMarkerByIndex(0, retnumber, 0, position, 0, shown_number, "_Shownote:" .. shownotetitle, color)
  else return false
  end
end

--ultraschall.AddShownoteMarker(10,"Truddle","fuddle.de")
--ultraschall.SetShownoteMarker(2,nil,nil,nil)
--A,AA,AAA,AAAA,AAAAA,AAAAAA=ultraschall.EnumerateShownoteMarkers(3)

ultraschall.SetPodRangeRegion=function(startposition, endposition)
-- Sets _PodRange:-Marker
-- startposition - startposition in seconds, must be positive value
-- endposition - endposition in seconds, must be bigger than startposition
-- returns -1 if it fails

  return ultraschall.AddPodRangeRegion(startposition, endposition)
end

--A,AA,AAA=ultraschall.SetPodRangeRegion(2,10)

-------------------------
---- Delete Markers -----
-------------------------

ultraschall.DeletePodRangeRegion=function()
-- deletes the PodRange-Region
  local a,nummarkers,numregions=reaper.CountProjectMarkers(0)
  local count=0
  local itworked=-1
  for i=nummarkers+numregions, 0, -1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name:sub(1,10)=="_PodRange:" and isrgn==true then reaper.DeleteProjectMarkerByIndex(0,i) itworked=1 end 
  end
  return itworked
end

--A=ultraschall.AddPodRangeRegion(2,10)
--A2=ultraschall.DeletePodRangeRegion()

ultraschall.DeleteNormalMarker=function(number)
-- Deletes a Normal-Marker
-- number - number of the _Normal-marker, 1 to current number of _Normal-markers
-- returns true if successful and false if not(i.e. marker doesn't exist)

  local c,nummarkers,b=reaper.CountProjectMarkers(0)
  number=tonumber(number)
  if number==nil then return -1 end
  local number=number-1
  local wentfine=0
  local count=-1
  local retnumber=0
  local nix=""
  for i=0, nummarkers-1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if isrgn==false then
      if name:sub(1,10)=="_Shownote:" or name:sub(1,9)=="_Chapter:" or name:sub(1,6)=="_Edit:" or name:sub(1,10)=="_LiveEdit:" or name:sub(1,7)=="_Dummy:" then nix="1"
      else count=count+1
      end
    end
    if number>=0 and wentfine==0 and count==number then
        retnumber=i
        wentfine=1
    end
  end
  
  if wentfine==1 then return reaper.DeleteProjectMarkerByIndex(0, retnumber)
  else return false
  end
end

--A=ultraschall.AddNormalMarker(3,10,"marke")
--A2=ultraschall.DeleteNormalMarker("1")

ultraschall.DeleteShownoteMarker=function(number)
--TODO local machen von Variablen

-- Deletes a Shownote-Marker
-- number - number of the _Shownote-marker, 1 to current number of _Shownote-markers
-- returns true if successful and false if not(i.e. marker doesn't exist)

  c,nummarkers,b=reaper.CountProjectMarkers(0)
  number=tonumber(number)
  if number==nil then return -1 end
  number=number-1
  wentfine=0
  count=-1
  retnumber=0
  for i=0, nummarkers-1 do
    retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name:sub(1,10)=="_Shownote:" then count=count+1 end 
    if number>=0 and wentfine==0 and count==number then 
        shown_number_temp=markrgnindexnumber
        retnumber=i
        wentfine=1
    end
  end
  
  if wentfine==1 then 
    reaper.SetProjExtState(0, "Ultraschall_Shownotes", "TITLE"..tostring(shown_number_temp), "")
    reaper.SetProjExtState(0, "Ultraschall_Shownotes", "URL"..tostring(shown_number_temp), "")
    return reaper.DeleteProjectMarkerByIndex(0, retnumber)
  else return false
  end
end

--A,AA,AAA=ultraschall.AddShownoteMarker(10,"ofseroad2","middle2")
--A,AA=reaper.GetProjExtState(0, "Ultraschall_Shownotes", "TITLE1")
--B,BB=reaper.GetProjExtState(0, "Ultraschall_Shownotes", "URL1")
--ultraschall.DeleteShownoteMarker(1)

ultraschall.DeleteChapterMarker=function(number)
-- Deletes a Chapter-Marker
-- number - number of the _Chapter-marker, 1 to current number of _Chapter-markers
-- returns true if successful and false if not(i.e. marker doesn't exist)

  c,nummarkers,b=reaper.CountProjectMarkers(0)
  number=tonumber(number)
  if number==nil then return -1 end
  number=number-1
  wentfine=0
  count=-1
  retnumber=0
  for i=0, nummarkers-1 do
    retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name:sub(1,9)=="_Chapter:" then count=count+1 end 
    if number>=0 and wentfine==0 and count==number then 
        retnumber=i
        wentfine=1
    end
  end
  
  if wentfine==1 then return reaper.DeleteProjectMarkerByIndex(0, retnumber)
  else return false
  end
end

--A=ultraschall.AddChapterMarker(3,10,"markel")
--A2=ultraschall.DeleteChapterMarker("1")

ultraschall.DeleteEditMarker=function(number)
-- Deletes a Edit-Marker
-- number - number of the _Edit-marker, 1 to current number of _Edit-markers
-- returns true if successful and false if not(i.e. marker doesn't exist)

  local c,nummarkers,b=reaper.CountProjectMarkers(0)
  number=tonumber(number)
  if number==nil then return -1 end
  number=number-1
  local wentfine=0
  local count=-1
  local retnumber=0
  for i=0, nummarkers-1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name:sub(1,6)=="_Edit:" then count=count+1 end 
    if number>=0 and wentfine==0 and count==number then 
        retnumber=i
        wentfine=1
    end
  end
  
  if wentfine==1 then return reaper.DeleteProjectMarkerByIndex(0, retnumber)
  else return false
  end
end

--A=ultraschall.AddEditMarker(3,10,"markel")
--A2=ultraschall.DeleteEditMarker(1)

ultraschall.DeleteDummyMarker=function(number)
-- Deletes a Dummy-Marker
-- number - number of the _Dummy-marker, 1 to current number of _Dummy-markers
-- returns true if successful and false if not(i.e. marker doesn't exist)

  local c,nummarkers,b=reaper.CountProjectMarkers(0)
  number=tonumber(number)
  if number==nil then return -1 end
  number=number-1
  local wentfine=0
  local count=-1
  local retnumber=0
  for i=0, nummarkers-1 do
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
    if name:sub(1,7)=="_Dummy:" then count=count+1 end 
    if number>=0 and wentfine==0 and count==number then 
        retnumber=i
        wentfine=1
    end
  end
  
  if wentfine==1 then return reaper.DeleteProjectMarkerByIndex(0, retnumber)
  else return false
  end
end

--A=ultraschall.AddDummyMarker(1,1,"dummyone")
--A2=ultraschall.DeleteDummyMarker("1")

-------------------------
---- Export Markers -----
-------------------------

ultraschall.ExportShownotesToFile=function(filename_with_path, PodRangeStart,PodRangeEnd)
--ToDo local machen der variables

--Export Shownote-Markers to File
--filename_with_path - filename of the file where the markers shall be exported to
--PodRangeStart - start of the Podcast;markers earlier of that will not be exported;markers exported will be markerposition minus PodRangeStart
--                must be a positive value; nil=0
--PodRangeEnd - end of the Podcast; markers later of that will not be exported; 
--              must be a positive value; nil=end of project  
-- return -1 in case of error

if filename_with_path == nil then return -1 end
PodRangeStart=tonumber(PodRangeStart)
PodRangeEnd=tonumber(PodRangeEnd)
if PodRangeStart==nil then PodRangeStart=0 end
if PodRangeStart<0 then return -1 end
if PodRangeEnd==nil then PodRangeEnd=reaper.GetProjectLength(0) end
if PodRangeEnd<PodRangeStart then return -1 end
  number=ultraschall.CountShownoteMarkers()
  timestring="00:00:00.000"
  
  file=io.open(filename_with_path,"w")
  
  if file==nil then return -1 end
    for i=1,number do
      idx,shown_number,pos,name,URL = ultraschall.EnumerateShownoteMarkers(i)
      if pos>=PodRangeStart and pos<=PodRangeEnd then
        pos=pos-PodRangeStart
        timestring=ultraschall.SecondsToTime(pos)
        tempomat, TITLE=reaper.GetProjExtState(0, "Ultraschall_Shownotes", "TITLE"..shown_number)
        tempomat, URL=reaper.GetProjExtState(0, "Ultraschall_Shownotes", "URL"..shown_number)
        file:write(timestring.." \""..name.."\"-->Title:\""..TITLE.."\"-->URL:\""..URL.."\"-->END\n")
      end
    end
  fileclose=io.close(file)
  return 1
end


--A,AA,AAA=ultraschall.AddShownoteMarker(10,"test1","URL3000.com")
--A,AA,AAA=ultraschall.AddShownoteMarker(20,"test2","URL4000.com")
--A,AA,AAA=ultraschall.AddShownoteMarker(30,"test3","URL5000.com")
--APACHEN=ultraschall.ExportShownotesToFile("c:\\test.txt")

ultraschall.ExportShownotesToFile_Filerequester=function(PodRangeStart,PodRangeEnd)
--ToDo local machen der variables

--Export Shownote-Markers to File(must be an existing file or the requester runs into troubles!)
--PodRangeStart - start of the Podcast;markers earlier of that will not be exported;markers exported will be markerposition minus PodRangeStart
--                must be a positive value; nil=0
--PodRangeEnd - end of the Podcast; markers later of that will not be exported; 
--              must be a positive value; nil=end of project  
-- return -1 in case of error

if PodRangeStart==nil then PodRangeStart=0 end
if PodRangeStart<0 then return -1 end
if PodRangeEnd==nil then PodRangeEnd=reaper.GetProjectLength(0) end
if PodRangeEnd<PodRangeStart then return -1 end
  number=ultraschall.CountShownoteMarkers()
  
  retval, filename_with_path = reaper.GetUserFileNameForRead("ShownoteMarkers.shownotes.txt", "Export Shownote-Markers", "*.shownotes.txt")
  if retval==false then return -1 end

  timestring="00:00:00.000"
  
  file=io.open(filename_with_path,"w")
  
  if file==nil then return -1 end
    for i=1,number do
      idx,shown_number,pos,name,URL = ultraschall.EnumerateShownoteMarkers(i)
      if pos>=PodRangeStart and pos<=PodRangeEnd then
        pos=pos-PodRangeStart
        timestring=ultraschall.SecondsToTime(pos)
        tempomat, TITLE=reaper.GetProjExtState(0, "Ultraschall_Shownotes", "TITLE"..shown_number)
        tempomat, URL=reaper.GetProjExtState(0, "Ultraschall_Shownotes", "URL"..shown_number)
        file:write(timestring.." \""..name.."\"-->Title:\""..TITLE.."\"-->URL:\""..URL.."\"-->END\n")
      end
    end
  fileclose=io.close(file)
  return 1
end

--APACHEN=ultraschall.ExportShownotesToFile_Filerequester()

ultraschall.ExportChapterMarkersToFile=function(filename_with_path,PodRangeStart,PodRangeEnd)
--Export Chapter-Markers to filename_with_path
--filename_with_path - filename of the file where the markers shall be exported to
--PodRangeStart - start of the Podcast;markers earlier of that will not be exported;markers exported will be markerposition minus PodRangeStart
--                must be a positive value; nil=0
--PodRangeEnd - end of the Podcast; markers later of that will not be exported; 
--              must be a positive value; nil=end of project
--
-- returns -1 in case of error

if filename_with_path == nil then return -1 end
if PodRangeStart==nil then PodRangeStart=0 end
if PodRangeStart<0 then return -1 end
if PodRangeEnd==nil then PodRangeEnd=reaper.GetProjectLength(0) end
if PodRangeEnd<PodRangeStart then return -1 end
  local number=ultraschall.CountChapterMarkers()
    
  local timestring="00:00:00.000"
  
  local file=io.open(filename_with_path,"w")
  
  if file==nil then return -1 end
    for i=1,number do
      local idx,shown_number,pos,name, URL=ultraschall.EnumerateChapterMarkers(i)
      if pos>=PodRangeStart and pos<=PodRangeEnd then
        pos=pos-PodRangeStart
        timestring=ultraschall.SecondsToTime(pos)
        file:write(timestring.." "..name.."\n")
      end
    end
  local fileclose=io.close(file)
  return 1
end

--A,AA=ultraschall.AddChapterMarker(10,10,"A")
--A,AA=ultraschall.AddChapterMarker(20,20,"B")
--A,AA=ultraschall.AddChapterMarker(30,30,"C")
--APPALACHEN=ultraschall.ExportChapterMarkersToFile("c:\\test.txt",1,300)


ultraschall.ExportChapterMarkersToFile_Filerequester=function(PodRangeStart, PodRangeEnd)
--Export Chapter-Markers to File(must be an existing file or the requester runs into troubles!)
--PodRangeStart - start of the Podcast;markers earlier of that will not be exported;markers exported will be markerposition minus PodRangeStart
--                must be a positive value; nil=0
--PodRangeEnd - end of the Podcast; markers later of that will not be exported; 
--              must be a positive value; nil=end of project  
-- return -1 in case of error

if PodRangeStart==nil then PodRangeStart=0 end
PodRangeStart=tonumber(PodRangeStart)
PodRangeEnd=tonumber(PodRangeEnd)
if PodRangeStart<0 then return -1 end
if PodRangeEnd==nil then PodRangeEnd=reaper.GetProjectLength(0) end
if PodRangeEnd<PodRangeStart then return -1 end
  local number=ultraschall.CountChapterMarkers()

  local retval, filename_with_path = reaper.GetUserFileNameForRead("ChapterMarkers.chapters.txt", "Export Chapter-Markers", "*.chapters.txt")
  if retval==false then return -1 end

  local timestring="00:00:00.000"
  
  local file=io.open(filename_with_path,"w")
  
  if file==nil then return -1 end
    for i=1,number do
      local idx,shown_number,pos,name, URL=ultraschall.EnumerateChapterMarkers(i)
      if pos>=PodRangeStart and pos<=PodRangeEnd then
        pos=pos-PodRangeStart
        timestring=ultraschall.SecondsToTime(pos)
        file:write(timestring.." "..name.."\n")
      end
    end
  local fileclose=io.close(file)
  return 1
end

--APACHEN=ultraschall.ExportChapterMarkersToFile_Filerequester()

ultraschall.ExportEditMarkersToFile=function(filename_with_path,PodRangeStart, PodRangeEnd)
--Export Edit-Markers to filename_with_path
--filename_with_path - filename of the file where the markers shall be exported to
--PodRangeStart - start of the Podcast;markers earlier of that will not be exported;markers exported will be markerposition minus PodRangeStart
--                must be a positive value; nil=0
--PodRangeEnd - end of the Podcast; markers later of that will not be exported; 
--              must be a positive value; nil=end of project
--
-- returns -1 in case of error

if filename_with_path == nil then return -1 end
PodRangeStart=tonumber(PodRangeStart)
PodRangeEnd=tonumber(PodRangeEnd)
if PodRangeStart==nil then PodRangeStart=0 end
if PodRangeStart<0 then return -1 end
if PodRangeEnd==nil then PodRangeEnd=reaper.GetProjectLength(0) end
if PodRangeEnd<PodRangeStart then return -1 end
  local number=ultraschall.CountEditMarkers()  
  local timestring="00:00:00.000"
  
  local file=io.open(filename_with_path,"w")
  
  if file==nil then return -1 end
    for i=1,number do
      local idx,shown_number,pos,name, URL=ultraschall.EnumerateEditMarkers(i)
      if pos>=PodRangeStart and pos<=PodRangeEnd then
        pos=pos-PodRangeStart
        timestring=ultraschall.SecondsToTime(pos)
        file:write(timestring.." "..name.."\n")
      end
    end
  local fileclose=io.close(file)
  return 1
end

--A,AA=ultraschall.AddEditMarker(10,10,"ed10")
--A,AA=ultraschall.AddEditMarker(20,20,"ed20")
--A,AA=ultraschall.AddEditMarker(30,30,"ed30")
--APACHEN=ultraschall.ExportEditMarkersToFile("c:\\test.txt")
--Mespotine

ultraschall.ExportEditMarkersToFile_Filerequester=function(PodRangeStart, PodRangeEnd)
--Export Markers to File(must be an existing file or the requester runs into troubles!)
--PodRangeStart - start of the Podcast;markers earlier of that will not be exported;markers exported will be markerposition minus PodRangeStart
--                must be a positive value; nil=0
--PodRangeEnd - end of the Podcast; markers later of that will not be exported; 
--              must be a positive value; nil=end of project  
-- return -1 in case of error

if PodRangeStart==nil then PodRangeStart=0 end
PodRangeStart=tonumber(PodRangeStart)
PodRangeEnd=tonumber(PodRangeEnd)
if PodRangeStart<0 then return -1 end
if PodRangeEnd==nil then PodRangeEnd=reaper.GetProjectLength(0) end
if PodRangeEnd<PodRangeStart then return -1 end
  local number=ultraschall.CountEditMarkers()

  local retval, filename_with_path = reaper.GetUserFileNameForRead("EditMarkers.edit.txt", "Export Edit-Markers", "*.edit.txt")
  if retval==false then return -1 end

  local timestring="00:00:00.000"
  
  local file=io.open(filename_with_path,"w")
  
  if file==nil then return -1 end
    for i=1,number do
      local idx,shown_number,pos,name, URL=ultraschall.EnumerateEditMarkers(i)
      if pos>=PodRangeStart and pos<=PodRangeEnd then
        pos=pos-PodRangeStart
        timestring=ultraschall.SecondsToTime(pos)
        file:write(timestring.." "..name.."\n")
      end
    end
  local fileclose=io.close(file)
  return 1
end

--ALASKA=ultraschall.ExportEditMarkersToFile_Filerequester()

ultraschall.ExportNormalMarkersToFile=function(filename_with_path, PodRangeStart, PodRangeEnd)
--Export Markers to filename_with_path
--filename_with_path - filename of the file where the markers shall be exported to
--PodRangeStart - start of the Podcast;markers earlier of that will not be exported;markers exported will be markerposition minus PodRangeStart
--                must be a positive value; nil=0
--PodRangeEnd - end of the Podcast; markers later of that will not be exported; 
--              must be a positive value; nil=end of project  
--
-- return -1 in case of error
  
  if filename_with_path == nil then return -1 end
  PodRangeStart=tonumber(PodRangeStart)
  PodRangeEnd=tonumber(PodRangeEnd)
  if PodRangeStart==nil then PodRangeStart=0 end
  if PodRangeStart<0 then return -1 end
  if PodRangeEnd==nil then PodRangeEnd=reaper.GetProjectLength(0) end
  if PodRangeEnd<PodRangeStart then return -1 end  
  local number=ultraschall.CountNormalMarkers()
    
  local timestring="00:00:00.000"
  
  local file=io.open(filename_with_path,"w")
  
  if file==nil then return -1 end
    for i=1,number do
      local idx,shown_number,pos,name, URL=ultraschall.EnumerateNormalMarkers(i)
      if pos>=PodRangeStart and pos<=PodRangeEnd then
        pos=pos-PodRangeStart
        timestring=ultraschall.SecondsToTime(pos)
        file:write(timestring.." "..name.."\n")
      end
    end
  local fileclose=io.close(file)
  return 1
end 
--A,AA=ultraschall.AddNormalMarker(10,10,"10mark")
--A,AA=ultraschall.AddNormalMarker(30,30,"30mark")
--A,AA=ultraschall.AddNormalMarker(20,20,"20mark")
--APPALACHEN=ultraschall.ExportNormalMarkersToFile("c:\\test.txt")


ultraschall.ExportNormalMarkersToFile_Filerequester=function(PodRangeStart, PodRangeEnd)
--Export Markers to File(must be an existing file or the requester runs into troubles!)
--PodRangeStart - start of the Podcast;markers earlier of that will not be exported;markers exported will be markerposition minus PodRangeStart
--                must be a positive value; nil=0
--PodRangeEnd - end of the Podcast; markers later of that will not be exported; 
--              must be a positive value; nil=end of project  
-- return -1 in case of error
  
  if PodRangeStart==nil then PodRangeStart=0 end
  PodRangeStart=tonumber(PodRangeStart)
  PodRangeEnd=tonumber(PodRangeEnd)
  if PodRangeStart<0 then return -1 end
  if PodRangeEnd==nil then PodRangeEnd=reaper.GetProjectLength(0) end
  if PodRangeEnd<PodRangeStart then return -1 end
  
  local number=ultraschall.CountNormalMarkers()
  local retval, filename_with_path = reaper.GetUserFileNameForRead("Markerfile.markers.txt", "Export Markers", "*.markers.txt")
  if retval==false then return -1 end
  local timestring="00:00:00.000"
  
  local file=io.open(filename_with_path,"w")
  
  if file==nil then return -1 end
    for i=1,number do
      local idx,shown_number,pos,name, URL=ultraschall.EnumerateNormalMarkers(i)
      if pos>=PodRangeStart and pos<=PodRangeEnd then
        pos=pos-PodRangeStart
        timestring=ultraschall.SecondsToTime(pos)
        file:write(timestring.." "..name.."\n")
      end
    end
  local fileclose=io.close(file)
  return 1
end
--ultraschall.ExportMarkersToFile_Filerequester(7,9999999999)

-------------------------
---- Import Markers -----
-------------------------

ultraschall.ImportShownotesFromFile=function(filename_with_path)
--!!NEW FORMAT! NEEDS TO BE IMPLEMENTED FIRST!!!

-- returns an array fo the imported values
-- first entry, time1 in seconds, second entry markername1, third entry time2 in seconds, fourth entry markername2, etc
--
-- filename_with_path - filename with path of the file to import
--[[
  if filename_with_path == nil then return -1 end
  if PodRangeStart==nil then PodRangeStart=0 end
  if PodRangeStart<0 then return -1 end
  if PodRangeEnd==nil then PodRangeEnd=reaper.GetProjectLength(0) end
  if PodRangeEnd<PodRangeStart then return -1 end  number=ultraschall.CountNormalMarkers()
  
  file=io.open(filename_with_path,"r")
  if file==nil then return -1 end
  fileclose=io.close(file) 
    
  markername=""
  entry=0

table = {}
    
  for line in io.lines(filename_with_path) do
    entry=entry+1
    table[entry]={}
    time=ultraschall.TimeToSeconds(line:match("%d*:%d*:%d*.%d*"))
    markername=line:match("%s.*")

    if markername==nil then markername="" end
    if time<0 then return -1 end

    table[entry][0]=time
    table[entry][1]=markername
  end

  return table]]
end

--A=ultraschall.ImportShownotesFromFile("c:\\test.txt")

ultraschall.ImportShownotesFromFile_Filerequester=function()
--!!NEW FORMAT! NEEDS TO BE IMPLEMENTED FIRST!!!

-- returns an array fo the imported values
-- first entry, time1 in seconds, second entry markername1, third entry time2 in seconds, fourth entry markername2, etc
--
-- filename_with_path - filename with path of the file to import
--[[
  if PodRangeStart==nil then PodRangeStart=0 end
  if PodRangeStart<0 then return -1 end
  if PodRangeEnd==nil then PodRangeEnd=reaper.GetProjectLength(0) end
  if PodRangeEnd<PodRangeStart then return -1 end  number=ultraschall.CountNormalMarkers()
  
  retval, filename_with_path = reaper.GetUserFileNameForRead("Shownotemarkers.shownotess.txt", "Import Shownote-Markers", "*.shownotes.txt")
  if retval==false then return -1 end 
  
    file=io.open(filename_with_path,"r")
    if file==nil then return -1 end
    fileclose=io.close(file) 
      
    markername=""
    entry=0
  
  table = {}
      
    for line in io.lines(filename_with_path) do
      entry=entry+1
      table[entry]={}
      time=ultraschall.TimeToSeconds(line:match("%d*:%d*:%d*.%d*"))
      markername=line:match("%s.*")
  
      if markername==nil then markername="" end
      if time<0 then return -1 end
  
      table[entry][0]=time
      table[entry][1]=markername
    end
  
    return table]]
  end
  

--APPACHEN=ultraschall.ImportShownotesFromFile_Filerequester()

ultraschall.ImportChaptersFromFile=function(filename_with_path,PodRangeStart)
-- Imports chapterentries from a file and returns an array of the imported values.
-- array[markernumber1][0] - position of the marker in seconds+PodRangeStart
-- array[markernumber1][1] - name of the marker
-- array[markernumber2][0] - position of the marker in seconds+PodRangeStart
-- array[markernumber2][1] - name of the marker
-- array[markernumberx][0] - position of the marker in seconds+PodRangeStart
-- array[markernumberx][1] - name of the marker

-- Parameters:
-- filename_with_path - filename with path of the file to import
-- Podrangestart - the start of the podcast in seconds. Will be added to the time-positions of each chaptermarker. 
--    Podrangestart=0 gives you the timepositions, as they were stored in the chapter-marker-import-file.

  if filename_with_path == nil then return -1 end
  PodRangeStart=tonumber(PodRangeStart)
  if PodRangeStart==nil then PodRangeStart=0 end
  if PodRangeStart<0 then return -1 end
  local number=ultraschall.CountNormalMarkers()
  
  local file=io.open(filename_with_path,"r")
  if file==nil then return -1 end
  local fileclose=io.close(file) 
    
  local markername=""
  local entry=0

local table = {}
    
  for line in io.lines(filename_with_path) do
    entry=entry+1
    table[entry]={}
    time=ultraschall.TimeToSeconds(line:match("%d*:%d*:%d*.%d*"))+PodRangeStart
    markername=line:match("%s.*")

    if markername==nil then markername="" end
    if time<0 then return -1 end

    table[entry][0]=time
    table[entry][1]=markername
  end

  return table
end

--ALABAMA=ultraschall.ImportChaptersFromFile("c:\\test.txt",10)

--reaper.MB(ALABAMA[1][1],"0",0)

ultraschall.ImportChaptersFromFile_Filerequester=function(PodRangeStart)
-- Opens a filerequester to choose the importfile with. Imports chapterentries from the chosen file and returns 
-- an array of the imported values.
-- array[markernumber1][0] - position of the marker in seconds+PodRangeStart
-- array[markernumber1][1] - name of the marker
-- array[markernumber2][0] - position of the marker in seconds+PodRangeStart
-- array[markernumber2][1] - name of the marker
-- array[markernumberx][0] - position of the marker in seconds+PodRangeStart
-- array[markernumberx][1] - name of the marker

-- Parameters:
-- Podrangestart - the start of the podcast in seconds. Will be added to the time-positions of each chaptermarker. Podrangestart=0 gives you the timepositions, as they were stored in the chapter-marker-import-file.

  local retval, filename_with_path = reaper.GetUserFileNameForRead("Markers.markers.txt", "Import Markers", "*.markers.txt")
  if retval==false then return -1 end 
  PodRangeStart=tonumber(PodRangeStart)
  if PodRangeStart==nil then PodRangeStart=0 end
  if PodRangeStart<0 then return -1 end
  local number=ultraschall.CountNormalMarkers()
  
  local file=io.open(filename_with_path,"r")
  if file==nil then return -1 end
  local fileclose=io.close(file) 
    
  local markername=""
  local entry=0

local table = {}
    
  for line in io.lines(filename_with_path) do
    entry=entry+1
    table[entry]={}
    local time=ultraschall.TimeToSeconds(line:match("%d*:%d*:%d*.%d*"))+PodRangeStart
    markername=line:match("%s.*")

    if markername==nil then markername="" end
    if time<0 then return -1 end

    table[entry][0]=time
    table[entry][1]=markername
  end

  return table
end


--ALPPACHEN=ultraschall.ImportChaptersFromFile_Filerequester()


ultraschall.ImportEditFromFile=function(filename_with_path,PodRangeStart)
-- Imports editentries from a file and returns an array of the imported values.
-- array[markernumber1][0] - position of the marker in seconds+PodRangeStart
-- array[markernumber1][1] - name of the marker
-- array[markernumber2][0] - position of the marker in seconds+PodRangeStart
-- array[markernumber2][1] - name of the marker
-- array[markernumberx][0] - position of the marker in seconds+PodRangeStart
-- array[markernumberx][1] - name of the marker

-- Parameters:
-- filename_with_path - filename with path of the file to import
-- Podrangestart - the start of the podcast in seconds. Will be added to the time-positions of each chaptermarker. 
--    Podrangestart=0 gives you the timepositions, as they were stored in the chapter-marker-import-file.

  if filename_with_path == nil then return -1 end
  PodRangeStart=tonumber(PodRangeStart)
  if PodRangeStart==nil then PodRangeStart=0 end
  if PodRangeStart<0 then return -1 end
  local number=ultraschall.CountNormalMarkers()
  
  local file=io.open(filename_with_path,"r")
  if file==nil then return -1 end
  local fileclose=io.close(file) 
    
  local markername=""
  local entry=0

local table = {}
    
  for line in io.lines(filename_with_path) do
    entry=entry+1
    table[entry]={}
    time=ultraschall.TimeToSeconds(line:match("%d*:%d*:%d*.%d*"))+PodRangeStart
    markername=line:match("%s.*")

    if markername==nil then markername="" end
    if time<0 then return -1 end

    table[entry][0]=time
    table[entry][1]=markername
  end

  return table
end

--ABAMA=ultraschall.ImportEditFromFile("c:\\test.txt",10)

ultraschall.ImportEditFromFile_Filerequester=function(PodRangeStart)
-- Opens a filerequester to choose the importfile with. Imports editentries from the chosen file and returns 
-- an array of the imported values.
-- array[markernumber1][0] - position of the marker in seconds+PodRangeStart
-- array[markernumber1][1] - name of the marker
-- array[markernumber2][0] - position of the marker in seconds+PodRangeStart
-- array[markernumber2][1] - name of the marker
-- array[markernumberx][0] - position of the marker in seconds+PodRangeStart
-- array[markernumberx][1] - name of the marker

-- Parameters:
-- Podrangestart - the start of the podcast in seconds. Will be added to the time-positions of each chaptermarker. Podrangestart=0 gives you the timepositions, as they were stored in the chapter-marker-import-file.

  local retval, filename_with_path = reaper.GetUserFileNameForRead("Markers.markers.txt", "Import Markers", "*.markers.txt")
  if retval==false then return -1 end 
  PodRangeStart=tonumber(PodRangeStart)
  if PodRangeStart==nil then PodRangeStart=0 end
  if PodRangeStart<0 then return -1 end
  local number=ultraschall.CountNormalMarkers()
  
  local file=io.open(filename_with_path,"r")
  if file==nil then return -1 end
  local fileclose=io.close(file) 
    
  local markername=""
  local entry=0

local table = {}
    
  for line in io.lines(filename_with_path) do
    entry=entry+1
    table[entry]={}
    local time=ultraschall.TimeToSeconds(line:match("%d*:%d*:%d*.%d*"))+PodRangeStart
    markername=line:match("%s.*")

    if markername==nil then markername="" end
    if time<0 then return -1 end

    table[entry][0]=time
    table[entry][1]=markername
  end

  return table
end


--APPACHEN=ultraschall.ImportEditFromFile_Filerequester()

ultraschall.ImportMarkersFromFile=function(filename_with_path,PodRangeStart)
-- Imports markerentries from a file and returns an array of the imported values.
-- array[markernumber1][0] - position of the marker in seconds+PodRangeStart
-- array[markernumber1][1] - name of the marker
-- array[markernumber2][0] - position of the marker in seconds+PodRangeStart
-- array[markernumber2][1] - name of the marker
-- array[markernumberx][0] - position of the marker in seconds+PodRangeStart
-- array[markernumberx][1] - name of the marker

-- Parameters:
-- filename_with_path - filename with path of the file to import
-- Podrangestart - the start of the podcast in seconds. Will be added to the time-positions of each chaptermarker. 
--    Podrangestart=0 gives you the timepositions, as they were stored in the chapter-marker-import-file.

  if filename_with_path == nil then return -1 end
  PodRangeStart=tonumber(PodRangeStart)
  if PodRangeStart==nil then PodRangeStart=0 end
  if PodRangeStart<0 then return -1 end
  local number=ultraschall.CountNormalMarkers()
  
  local file=io.open(filename_with_path,"r")
  if file==nil then return -1 end
  local fileclose=io.close(file) 
    
  local markername=""
  local entry=0

local table = {}
    
  for line in io.lines(filename_with_path) do
    entry=entry+1
    table[entry]={}
    time=ultraschall.TimeToSeconds(line:match("%d*:%d*:%d*.%d*"))+PodRangeStart
    markername=line:match("%s.*")

    if markername==nil then markername="" end
    if time<0 then return -1 end

    table[entry][0]=time
    table[entry][1]=markername
  end

  return table
end

--APPALACHEN=ultraschall.ImportMarkersFromFile("c:\\test.txt")

--A,AA,AAA,AAAA=ultraschall.EnumerateNormalMarkers(4)
--APPALACHEN=ultraschall.ExportMarkersToFile("c:\\test.txt",0,99999999)

ultraschall.ImportMarkersFromFile_Filerequester=function(PodRangeStart)
-- Opens a filerequester to choose the importfile with. Imports markerentries from the chosen file and returns 
-- an array of the imported values.
-- array[markernumber1][0] - position of the marker in seconds+PodRangeStart
-- array[markernumber1][1] - name of the marker
-- array[markernumber2][0] - position of the marker in seconds+PodRangeStart
-- array[markernumber2][1] - name of the marker
-- array[markernumberx][0] - position of the marker in seconds+PodRangeStart
-- array[markernumberx][1] - name of the marker

-- Parameters:
-- Podrangestart - the start of the podcast in seconds. Will be added to the time-positions of each chaptermarker. Podrangestart=0 gives you the timepositions, as they were stored in the chapter-marker-import-file.

  local retval, filename_with_path = reaper.GetUserFileNameForRead("Markers.markers.txt", "Import Markers", "*.markers.txt")
  if retval==false then return -1 end 
  PodRangeStart=tonumber(PodRangeStart)
  if PodRangeStart==nil then PodRangeStart=0 end
  if PodRangeStart<0 then return -1 end
  local number=ultraschall.CountNormalMarkers()
  
  local file=io.open(filename_with_path,"r")
  if file==nil then return -1 end
  local fileclose=io.close(file) 
    
  local markername=""
  local entry=0

local table = {}
    
  for line in io.lines(filename_with_path) do
    entry=entry+1
    table[entry]={}
    local time=ultraschall.TimeToSeconds(line:match("%d*:%d*:%d*.%d*"))+PodRangeStart
    markername=line:match("%s.*")

    if markername==nil then markername="" end
    if time<0 then return -1 end

    table[entry][0]=time
    table[entry][1]=markername
  end

  return table
end

--APPACHEN=ultraschall.ImportMarkersFromFile_Filerequester()


-------------------------
---- Convert Markers ----
-------------------------

ultraschall.MarkerToEditMarker=function(number)

number=tonumber(number)
if number==nil then return -1 end
if number<1 then return -1 end
--  retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
--  for i=retval,0,-1 do
local color=0
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0xFF0000|0x1000000
    else
      color = 0x0000FF|0x1000000
    end 

    local idx, shownmarker, position, markername = ultraschall.EnumerateNormalMarkers(number)
    if idx==-1 then return -1 end
    local itworks=reaper.SetProjectMarkerByIndex(0, idx-1, false, position, 0, shownmarker, "_Edit:"..markername, color)
--  end
return idx, shownmarker, position, markername
end

--A,AA,AAA,AAAA=ultraschall.MarkerToEditMarker(1)


ultraschall.MarkerToChapterMarker=function(number)
number=tonumber(number)
if number==nil then return -1 end
if number<1 then return -1 end
--  retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
--  for i=retval,0,-1 do
local color=0
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0x0000FF|0x1000000
    else
      color = 0xFF0000|0x1000000
    end 
    
    local idx, shownmarker, position, markername = ultraschall.EnumerateNormalMarkers(number)
    if idx==-1 then return -1 end
    local itworks=reaper.SetProjectMarkerByIndex(0, idx-1, false, position, 0, shownmarker, "_Chapter:"..markername, color)
--  end
return idx, shownmarker, position, markername
end

--A,AA,AAA,AAAA=ultraschall.MarkerToChapterMarker(1)

ultraschall.MarkerToDummyMarker=function(number)
number=tonumber(number)
local color=0
if number==nil then return -1 end
if number<1 then return -1 end
--  retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
--  for i=retval,0,-1 do
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0x999999|0x1000000
    else
      color = 0x999999|0x1000000
    end 
    
    local idx, shownmarker, position, markername = ultraschall.EnumerateNormalMarkers(number)
    if idx==-1 then return -1 end
    local itworks=reaper.SetProjectMarkerByIndex(0, idx-1, false, position, 0, shownmarker, "_Dummy:"..markername, color)
--  end
return idx, shownmarker, position, markername
end

--A,AA,AAA,AAAA=ultraschall.MarkerToDummyMarker("1")

ultraschall.MarkerToShownoteMarker=function(number)
--TODO: New implementation and localize variables
--reaper.MB("test","test",0)
-- test --<URL>--
if number==nil then return -1 end
if number<1 then return -1 end
--  retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
--  for i=retval,0,-1 do
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0x00AA00|0x1000000
    else
      color = 0x00AA00|0x1000000
    end
        
    idx, shownmarker, position, markername = ultraschall.EnumerateNormalMarkers(number)
--    reaper.MB(tostring(idx),markername,0)
    if idx==-1 then return -1 end
    URL=markername:match("(--<.*>--)")
    if URL==nil then URL="--<>--" end
    Atempname=markername:sub(1,-(URL:len()+1))
    itworks=reaper.SetProjectMarkerByIndex(0, idx-1, false, position, 0, shownmarker, "_Shownote:"..Atempname..URL, color)
--  end
return idx, shownmarker, position, markername
end

--A, AA, AAA, AAAA=ultraschall.EnumerateNormalMarkers(1)
--A,AA,AAA,AAAA=ultraschall.MarkerToShownoteMarker(1)


ultraschall.ShownoteToEditMarker=function(number)
--TODO: New implementation and localize variables
if number==nil then return -1 end
if number<1 then return -1 end
--  retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
--  for i=retval,0,-1 do
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0xFF0000|0x1000000
    else
      color = 0x0000FF|0x1000000
    end 
            
    idx, shownmarker, position, markername,URL = ultraschall.EnumerateShownoteMarkers(number)
    if idx==-1 then return -1 end
    itworks=reaper.SetProjectMarkerByIndex(0, idx-1, false, position, 0, shownmarker, "_Edit:"..markername.."--<"..URL..">--", color)
--  end
return idx, shownmarker, position, markername
end


ultraschall.ShownoteToChapterMarker=function(number)
--TODO: New implementation and localize variables
if number==nil then return -1 end
if number<1 then return -1 end
--  retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
--  for i=retval,0,-1 do
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0x0000FF|0x1000000
    else
      color = 0xFF0000|0x1000000
    end 
                
    idx, shownmarker, position, markername,URL = ultraschall.EnumerateShownoteMarkers(number)
    if idx==-1 then return -1 end
    itworks=reaper.SetProjectMarkerByIndex(0, idx-1, false, position, 0, shownmarker, "_Chapter:"..markername.."--<"..URL..">--", color)
--  end
return idx, shownmarker, position, markername
end


ultraschall.ShownoteToDummyMarker=function(number)
--TODO: New implementation and localize variables
if number==nil then return -1 end
if number<1 then return -1 end
--  retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
--  for i=retval,0,-1 do
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0x999999|0x1000000
    else
      color = 0x999999|0x1000000
    end 
                
    idx, shownmarker, position, markername,URL = ultraschall.EnumerateShownoteMarkers(number)
    if idx==-1 then return -1 end
    itworks=reaper.SetProjectMarkerByIndex(0, idx-1, false, position, 0, shownmarker, "_Dummy:"..markername.."--<"..URL..">--", color)
--  end
return idx, shownmarker, position, markername
end


ultraschall.ShownoteToMarker=function(number)
--TODO: New implementation and localize variables
if number==nil then return -1 end
if number<1 then return -1 end
--  retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
--  for i=retval,0,-1 do
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0x888888|0x0000000
    else
      color = 0x888888|0x0000000
    end 
                
    idx, shownmarker, position, markername,URL = ultraschall.EnumerateShownoteMarkers(number)
    if idx==-1 then return -1 end
--    itworks=ultraschall.DeleteShownoteMarker(number)
--    itworks2=ultraschall.AddNormalMarker(position, shownmarker, markername.."--<"..URL..">--")
    itworks=reaper.SetProjectMarkerByIndex(0, idx-1, false, position, 0, shownmarker, markername.."--<"..URL..">--", color)
--  end
return idx, shownmarker, position, markername
end

--ultraschall.AddShownoteMarker(10,10,"test","URL.com")
--AA,AAA,AAA,AAAA = ultraschall.ShownoteToMarker(1)
--ultraschall.MarkerToShownoteMarker(1)

ultraschall.ChapterToEditMarker=function(number)
number=tonumber(number)
local color=0
if number==nil then return -1 end
if number<1 then return -1 end
--  retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
--  for i=retval,0,-1 do
 os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0xFF0000|0x1000000
    else
      color = 0x0000FF|0x1000000
    end
        
    local idx, shownmarker, position, markername = ultraschall.EnumerateChapterMarkers(number)
    if idx==-1 then return -1 end
    local itworks=reaper.SetProjectMarkerByIndex(0, idx-1, false, position, 0, shownmarker, "_Edit:"..markername, color)
--  end
return idx, shownmarker, position, markername
end

--A,AA,AAA,AAAA=ultraschall.ChapterToEditMarker(1)
--A,AA,AAA,AAAA=ultraschall.EditToChapterMarker(1)

ultraschall.ChapterToShownoteMarker=function(number)
--Needs reimplementation and localizing variables
number=tonumber(number)
local color=0
if number==nil then return -1 end
if number<1 then return -1 end
--  retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
--  for i=retval,0,-1 do
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0x00AA00|0x1000000
    else
      color = 0x00AA00|0x1000000
    end
        
    idx, shownmarker, position, markername = ultraschall.EnumerateChapterMarkers(number)
--    reaper.MB(tostring(idx),markername,0)
    if idx==-1 then return -1 end
    URL=markername:match("(--<.*>--)")
    if URL==nil then URL="--<>--" end
    Atempname=markername:sub(1,-(URL:len()+1))
    itworks=reaper.SetProjectMarkerByIndex(0, idx-1, false, position, 0, shownmarker, "_Shownote:"..Atempname..URL, color)
--  end
return idx, shownmarker, position, markername
end

--A,AA,AAA,AAAA=ultraschall.ChapterToShownoteMarker(1)
--A,AA,AAA,AAAA=ultraschall.ShownoteToChapterMarker(1)

ultraschall.ChapterToDummyMarker=function(number)
number=tonumber(number)
local color=0
if number==nil then return -1 end
if number<1 then return -1 end
--  retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
--  for i=retval,0,-1 do
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0x999999|0x1000000
    else
      color = 0x999999|0x1000000
    end 
    
    local idx, shownmarker, position, markername = ultraschall.EnumerateChapterMarkers(number)
    if idx==-1 then return -1 end
    local itworks=reaper.SetProjectMarkerByIndex(0, idx-1, false, position, 0, shownmarker, "_Dummy:"..markername, color)
--  end
return idx, shownmarker, position, markername
end

--A,AA,AAA,AAAA=ultraschall.ChapterToDummyMarker(1)
--A,AA,AAA,AAAA=ultraschall.DummyToChapterMarker(1)

ultraschall.ChapterToMarker=function(number)
number=tonumber(number)
local color=0
if number==nil then return -1 end
if number<1 then return -1 end
--  retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
--  for i=retval,0,-1 do
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0x888888|0x0000000
    else
      color = 0x888888|0x0000000
    end 
    
    local idx, shownmarker, position, markername = ultraschall.EnumerateChapterMarkers(number)
    if idx==-1 then return -1 end
  if markername=="" then itworks=reaper.SetProjectMarkerByIndex2(0, idx-1, false, position, 0, shownmarker, ""..markername, color,1)
    else local itworks=reaper.SetProjectMarkerByIndex(0, idx-1, false, position, 0, shownmarker, ""..markername, color)
    end
    --  end
return idx, shownmarker, position, markername
end

--ultraschall.AddChapterMarker(12,12,"chapter")
--A,AA,AAA,AAAA=ultraschall.ChapterToMarker(1)
--A,AA,AAA,AAAA=ultraschall.MarkerToChapterMarker(1)

ultraschall.EditToChapterMarker=function(number)
number=tonumber(number)
local color=0
if number==nil then return -1 end
if number<1 then return -1 end
--  retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
--  for i=retval,0,-1 do
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0x0000FF|0x1000000
    else
      color = 0xFF0000|0x1000000
    end 
     
    local idx, shownmarker, position, markername = ultraschall.EnumerateEditMarkers(number)
    if idx==-1 then return -1 end
    local itworks=reaper.SetProjectMarkerByIndex(0, idx-1, false, position, 0, shownmarker, "_Chapter:"..markername, color)
--  end
return idx, shownmarker, position, markername
end

--A,AA,AAA,AAAA=ultraschall.EditToChapterMarker("1")
--A,AA,AAA,AAAA=ultraschall.ChapterToEditMarker(1)

ultraschall.EditToShownoteMarker=function(number)
if number==nil then return -1 end
if number<1 then return -1 end
--  retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
--  for i=retval,0,-1 do
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0x00AA00|0x1000000
    else
      color = 0x00AA00|0x1000000
    end
        
    idx, shownmarker, position, markername = ultraschall.EnumerateEditMarkers(number)
--    reaper.MB(tostring(idx),markername,0)
    if idx==-1 then return -1 end
    URL=markername:match("(--<.*>--)")
    if URL==nil then URL="--<>--" end
    Atempname=markername:sub(1,-(URL:len()+1))
    itworks=reaper.SetProjectMarkerByIndex(0, idx-1, false, position, 0, shownmarker, "_Shownote:"..Atempname..URL, color)
--  end
return idx, shownmarker, position, markername
end

--A,AA,AAA,AAAA=ultraschall.EditToShownoteMarker(1)
--A,AA,AAA,AAAA=ultraschall.ShownoteToEditMarker(1)

ultraschall.EditToDummyMarker=function(number)
number=tonumber(number)
local color=0
if number==nil then return -1 end
if number<1 then return -1 end
--  retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
--  for i=retval,0,-1 do
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0x888888|0x0000000
    else
      color = 0x888888|0x0000000
    end 
     
    local idx, shownmarker, position, markername = ultraschall.EnumerateEditMarkers(number)
    if idx==-1 then return -1 end
    local itworks=reaper.SetProjectMarkerByIndex(0, idx-1, false, position, 0, shownmarker, "_Dummy:"..markername, color)
--  end
return idx, shownmarker, position, markername
end

--A,AA,AAA,AAAA=ultraschall.EditToDummyMarker(1)

ultraschall.EditToMarker=function(number)
number=tonumber(number)
local color=0
if number==nil then return -1 end
if number<1 then return -1 end
--  retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
--  for i=retval,0,-1 do
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0x888888|0x0000000
    else
      color = 0x888888|0x0000000
    end 
    
    local idx, shownmarker, position, markername = ultraschall.EnumerateEditMarkers(number)
    if idx==-1 then return -1 end
    if markername=="" then itworks=reaper.SetProjectMarkerByIndex2(0, idx-1, false, position, 0, shownmarker, ""..markername, color,1)
    else local itworks=reaper.SetProjectMarkerByIndex(0, idx-1, false, position, 0, shownmarker, ""..markername, color)
    end
--  end
return idx, shownmarker, position, markername
end

--A=ultraschall.AddEditMarker(9,7,"edittitle")
--A,AA,AAA,AAAA=ultraschall.EditToMarker(1)
--A,AA,AAA,AAAA=ultraschall.MarkerToEditMarker(1)
--mespotine
ultraschall.DummyToChapterMarker=function(number)
number=tonumber(number)
local color=0
if number==nil then return -1 end
if number<1 then return -1 end
--  retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
--  for i=retval,0,-1 do
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0x0000FF|0x1000000
    else
      color = 0xFF0000|0x1000000
    end
         
    local idx, shownmarker, position, markername = ultraschall.EnumerateDummyMarkers(number)
    if idx==-1 then return -1 end
    local itworks=reaper.SetProjectMarkerByIndex(0, idx-1, false, position, 0, shownmarker, "_Chapter:"..markername, color)
--  end
return idx, shownmarker, position, markername
end

--A,AA,AAA,AAAA=ultraschall.DummyToChapterMarker(1)
--A,AA,AAA,AAAA=ultraschall.ChapterToDummyMarker(1)


ultraschall.DummyToShownoteMarker=function(number)
return idx, shownmarker, position, markername
end

--A,AA,AAA,AAAA=ultraschall.DummyToShownoteMarker(1)
--A,AA,AAA,AAAA=ultraschall.ShownoteToDummyMarker(1)

ultraschall.DummyToEditMarker=function(number)
number=tonumber(number)
local color=0
if number==nil then return -1 end
if number<1 then return -1 end
--  retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
--  for i=retval,0,-1 do
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
     color = 0xFF0000|0x1000000
    else
      color = 0x0000FF|0x1000000
    end
         
    local idx, shownmarker, position, markername = ultraschall.EnumerateDummyMarkers(number)
    if idx==-1 then return -1 end
    local itworks=reaper.SetProjectMarkerByIndex(0, idx-1, false, position, 0, shownmarker, "_Edit:"..markername, color)
--  end
return idx, shownmarker, position, markername
end

--A,AA,AAA,AAAA=ultraschall.DummyToEditMarker(1)
--A,AA,AAA,AAAA=ultraschall.EditToDummyMarker(1)

ultraschall.DummyToMarker=function(number)
number=tonumber(number)
local color=0
if number==nil then return -1 end
if number<1 then return -1 end
--  retval, num_markers, num_regions = reaper.CountProjectMarkers(0)
--  for i=retval,0,-1 do
  os = reaper.GetOS()
    if string.match(os, "OSX") then 
      color = 0x888888|0x0000000
    else
      color = 0x888888|0x0000000
    end 
    
    local idx, shownmarker, position, markername = ultraschall.EnumerateDummyMarkers(number)
    if idx==-1 then return -1 end
    if markername=="" then itworks=reaper.SetProjectMarkerByIndex2(0, idx-1, false, position, 0, shownmarker, ""..markername, color,1)
    else local itworks=reaper.SetProjectMarkerByIndex(0, idx-1, false, position, 0, shownmarker, ""..markername, color)
    end
--  end
return idx, shownmarker, position, markername
end

--A,AA,AAA,AAAA=ultraschall.DummyToMarker(1)
--A,AA,AAA,AAAA=ultraschall.MarkerToDummyMarker(1)

-----------------------
---- Render Export ----
-----------------------

ultraschall.SetGeneralRenderSettings=function()
end

ultraschall.RenderToMP3_CBR=function()
end

ultraschall.RenderToMP3_VBR=function()
end

ultraschall.RenderToMP3_MaxQuality=function()
end

ultraschall.RenderToMP3_ABR=function()
end

ultraschall.RenderToFlac=function()
end

ultraschall.RenderToOpus=function()
end

ultraschall.RenderToMP4Video=function()
end

ultraschall.RenderToWebMVideo=function()
end

ultraschall.RenderToAviVideo=function()
end

ultraschall.RenderToMKVVideo=function()
end

ultraschall.RenderToAIFF=function()
end

ultraschall.RenderSettings=function()
-- set general render settings
return settingsarray
end


------------------------------------
---- Import Reaper Config-Files ----
------------------------------------

ultraschall.ImportIni=function(from_export_filepath, to_export_filepath)
return successful, backup_filepath
end

ultraschall.ImportIniNb=function(from_export_filepath, to_export_filepath)
return successful, backup_filepath
end

ultraschall.ImportIniKb=function(from_export_filepath, to_export_filepath)
return successful, backup_filepath
end


--ultraschall.test=function()
