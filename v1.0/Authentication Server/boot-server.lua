-- Begin
os.loadAPI("/script/util/common")
os.loadAPI("/script/util/fileutil")

-- Setup our variables
local monitor = common.monitor
local modem = common.modem
local writeLine = common.writeLine

-- Begin Server Startup
rednet.open("back")
rednet.host("AUTH", "AUTH-SERVER")

runScript = os.run({}, "/script/run-server")

if runScript == false then
  writeLine("UNABLE TO LOAD RUN-SERVER API")
end