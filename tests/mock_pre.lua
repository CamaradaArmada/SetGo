strmatch, strsub, strlen, strupper, strlower, strfind, format, gsub, strrep = string.match, string.sub, string.len, string.upper, string.lower, string.find, string.format, string.gsub, string.rep
tinsert, tremove, floor, ceil, max, min, abs = table.insert, table.remove, math.floor, math.ceil, math.max, math.min, math.abs
function strsplit(sep, s) local out = {} for p in (s .. sep):gmatch("(.-)" .. sep:gsub("%p", "%%%0")) do out[#out + 1] = p end return unpack(out) end
securecallfunction = function(f, ...) return f(...) end
geterrorhandler = function() return function(e) print("ERR", e) end end
issecretvalue = function() return false end
date = os.date
