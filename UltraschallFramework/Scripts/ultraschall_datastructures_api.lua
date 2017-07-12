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


ultraschall.ApiDataTest=function()
  reaper.MB("Ultraschall Data API works","Ultraschall API",0)
end

------------------------------------------
--- ULTRASCHALL - API - DATASTRUCTURES ---
------------------------------------------

----------------------
--- METADATA-Array ---
----------------------

US_METADATA={}
US_METADATA[0]={}
US_METADATA[1]={}


--------------------
--- ID3TAG-Array ---
--------------------

US_ID3_TAG={}
US_ID3_TAG[0]={}
US_ID3_TAG[1]={}
US_ID3_TAG[0][0]="TITLE"
US_ID3_TAG[0][1]="ARTIST"
US_ID3_TAG[0][2]="ALBUM"
US_ID3_TAG[0][3]="YEAR"
US_ID3_TAG[0][4]="GENRE"
US_ID3_TAG[0][5]="COMMENT"


----------------------
--- Shownote-Array ---
----------------------

US_SHOWNOTE={}
US_SHOWNOTE[0]={}
US_SHOWNOTE[1]={}
US_SHOWNOTE[1][0]={}
US_SHOWNOTE[0][0]="TITLE"
US_SHOWNOTE[0][1]="URL"
US_SHOWNOTE[0][2]="DATE"
US_SHOWNOTE[0][3]="COMMENT"

US_SHOWNOTE[1][1]={} -- number URLs are given US_SHOWNOTE[1][1][number], 
                     -- i.e. US_SHOWNOTE[1][1][0]="URL1.com"
                     --      US_SHOWNOTE[1][1][1]="URL2.com"
                     --      US_SHOWNOTE[1][1][2]="URL3.com"
                     -- etc



