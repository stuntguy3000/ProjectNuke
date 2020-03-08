rednet.open("back")
rednet.host("EMERGENCY", "EMERGENCY-SERVER")

for i=0,1000 do 
  rednet.broadcast("CLEAR", "EMERGENCY")
  sleep(0.01)
end
