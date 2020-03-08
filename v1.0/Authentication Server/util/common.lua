-- ================================================
-- common
--
--    Author: stuntguy3000
--    Version: 1.0
--  
-- Responsible for common functions
--
-- ================================================
os.loadAPI("/script/util/fileutil")

-- Setup our global variables
monitor = peripheral.wrap("left")
modem = peripheral.wrap("right")

-- Util Functions
--   Print to the next line
function gotoNextLine()
  _G["display-line"] = _G["display-line"] + 1
  monitor.setCursorPos(1, _G["display-line"])
end

--   Write to the monitor
function writeLine(text)
  monitor.setCursorPos(1, _G["display-line"])
  monitor.write(text)
  gotoNextLine()
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end