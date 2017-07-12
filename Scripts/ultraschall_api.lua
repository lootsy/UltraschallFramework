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

ultraschall={}

-- Ultraschall Functions-API
-- include the following lines in your script, up until the "US_API = " - line 
-- (remove the -- comment-characters at the beginning(!) of each line of course ;) )

--US_Functions="ON"                 -- Turn OFF, if you don't want the Functions-API
--                                  -- Turn ON, if you want the Functions-API
--US_DataStructures="ON"            -- Turn OFF, if you don't want the DataStructures-API
--                                  -- Turn ON, if you want the DataStructures-API
--US_GraphicsFunctionsLibrary="ON"  -- Turn OFF, if you don't want the Graphics-Library-API
--                                  -- Turn ON, if you want the Graphics-Library-API
--US_SoundFunctionsLibrary="ON"     -- Turn OFF, if you don't want the Graphics-Library-API
--                                  -- Turn ON, if you want the Graphics-Library-API      
--US_VideoFunctionsLibrary="ON"     -- Turn OFF, if you don't want the Graphics-Library-API
--                                  -- Turn ON, if you want the Graphics-Library-API                              
--US_BetaFunctions="OFF"               -- Only has an effect, if ultraschall_functions_api_Beta.lua exists in Scripts-folder
--                                  -- Turn OFF, if you don't want BETA-Api-Functions
--                                  -- Turn ON, if you want BETA-Api-Functions
-- local info = debug.getinfo(1,'S');
-- script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
-- US_API = dofile(script_path .. "ultraschall_api.lua")


ultraschall.ApiTest=function()
    ultraschall.ApiFunctionTest()
    ultraschall.ApiDataTest()
    ultraschall.ApiGFXTest()
    ultraschall.ApiSoundTest()
    ultraschall.ApiVideoTest()
    
    ultraschall.ApiBetaFunctionsTest()
    ultraschall.ApiBetaDataTest()
    ultraschall.ApiBetaGFXTest()
    ultraschall.ApiBetaSoundTest()
    ultraschall.ApiBetaVideoTest()
end

ultraschall.ApiFunctionTest=function()
  reaper.MB("Ultraschall Functions-API is OFF","Ultraschall-API",0)
end

ultraschall.ApiDataTest=function()
  reaper.MB("Ultraschall DataStructures-API is OFF","Ultraschall-API",0)
end

ultraschall.ApiGFXTest=function()
  reaper.MB("Ultraschall Graphics-API is OFF","Ultraschall-API",0)
end

ultraschall.ApiSoundTest=function()
  reaper.MB("Ultraschall Sound-API is OFF","Ultraschall-API",0)
end

ultraschall.ApiVideoTest=function()
  reaper.MB("Ultraschall Video-API is OFF","Ultraschall-API",0)
end

ultraschall.ApiBetaFunctionsTest=function()
    reaper.MB("Ultraschall BETA-Functions API is OFF","Ultraschall-API (BETA)",0)
end

ultraschall.ApiBetaDataTest=function()
  reaper.MB("Ultraschall BETA-DataStructures-API is OFF","Ultraschall-API (BETA)",0)
end

ultraschall.ApiBetaGFXTest=function()
  reaper.MB("Ultraschall BETA-Graphics-API is OFF","Ultraschall-API (BETA)",0)
end

ultraschall.ApiBetaSoundTest=function()
  reaper.MB("Ultraschall BETA-Sound-API is OFF","Ultraschall-API (BETA)",0)
end

ultraschall.ApiBetaVideoTest=function()
  reaper.MB("Ultraschall BETA-Video-API is OFF","Ultraschall-API (BETA)",0)
end


local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
if US_Functions~="OFF" then US_API_Functions = dofile(script_path .. "ultraschall_functions_api.lua") end
if US_DataStructures~="OFF" then US_API_DataStructures = dofile(script_path .. "ultraschall_datastructures_api.lua") end
if US_GraphicsFunctionsLibrary~="OFF" then US_API_GraphicsLibrary = dofile(script_path .. "ultraschall_gfx_api.lua") end
if US_SoundFunctionsLibrary~="OFF" then US_API_SoundFunctionsLibrary = dofile(script_path .. "ultraschall_sound_api.lua") end
if US_VideoFunctionsLibrary~="OFF" then US_API_VideoFunctionsLibrary = dofile(script_path .. "ultraschall_video_api.lua") end

if US_BetaFunctions~="OFF" then
  if reaper.file_exists(script_path.."\\ultraschall_functions_api_Beta.lua") then BETA=dofile(script_path .. "ultraschall_functions_api_Beta.lua") end
  if reaper.file_exists(script_path.."\\ultraschall_datastructures_api_Beta.lua") then BETA=dofile(script_path .. "ultraschall_datastructures_api_Beta.lua") end
  if reaper.file_exists(script_path.."\\ultraschall_gfx_api_Beta.lua") then BETA=dofile(script_path .. "ultraschall_gfx_api_Beta.lua") end
  if reaper.file_exists(script_path.."\\ultraschall_sound_api_Beta.lua") then BETA=dofile(script_path .. "ultraschall_sound_api_Beta.lua") end
  if reaper.file_exists(script_path.."\\ultraschall_video_api_Beta.lua") then BETA=dofile(script_path .. "ultraschall_video_api_Beta.lua") end
end

--US_ApiTest()
