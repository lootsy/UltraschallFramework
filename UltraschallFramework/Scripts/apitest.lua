-- Ultraschall Functions-API
-- include the following lines

US_Functions="ON"                 -- Turn OFF, if you don't want the Functions-API
                                  -- Turn ON, if you want the Functions-API
US_DataStructures="ON"            -- Turn OFF, if you don't want the DataStructures-API
                                  -- Turn ON, if you want the DataStructures-API
US_GraphicsFunctionsLibrary="ON"  -- Turn OFF, if you don't want the Graphics-Library-API
                                  -- Turn ON, if you want the Graphics-Library-API
US_SoundFunctionsLibrary="ON"     -- Turn OFF, if you don't want the Graphics-Library-API
                                  -- Turn ON, if you want the Graphics-Library-API      
US_VideoFunctionsLibrary="ON"     -- Turn OFF, if you don't want the Graphics-Library-API
                                  -- Turn ON, if you want the Graphics-Library-API                              
US_BetaFunctions="ON"               -- Only has an effect, if ultraschall_functions_api_Beta.lua exists in Scripts-folder
                                  -- Turn OFF, if you don't want BETA-Api-Functions
                                  -- Turn ON, if you want BETA-Api-Functions
local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
US_API = dofile(script_path .. "ultraschall_api.lua")

--ultraschall.ApiTest()
