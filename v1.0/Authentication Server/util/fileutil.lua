-- ================================================
-- fileutil
--
--    Author: stuntguy3000
--    Version: 1.0
--  
-- Responsible for file utilities
--    
--    - Various user related tools and functions
--
-- ================================================
function readFile(fileName)
	createIfNotExisting(fileName)
	local file = fs.open(fileName, "r")
	
	return file.readAll()
end

function deleteFile(fileName)
	if fs.exists(fileName) == true then
		return fs.delete(fileName)
	end
	
	return false
end

function createIfNotExisting(fileName)
	if fs.exists(fileName) == false then
		fs.open(fileName, "w").close()
		return true
	end
	
	return false
end

function createIfNotExisting(fileName, defaultText)
	if fs.exists(fileName) == false then
		file = fs.open(fileName, "w")
		file.writeLine(defaultText)
		file.close()
		return true
	end
	return false
end

function saveTable(table, fileName)
	local file = fs.open(fileName, "w")
	file.write(textutils.serialize(table))
	file.close()
end

function loadTable(fileName)
	local file = fs.open(fileName, "r")
	local data = file.readAll()
	file.close()
	return textutils.unserialize(data)
end