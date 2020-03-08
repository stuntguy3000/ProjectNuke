-- ================================================
-- user-tools
--
--    Author: stuntguy3000
--   Version: 1.0
--  
-- Responsible for main server activities.
--    
--    - Various user related tools and functions
--
-- ================================================
os.loadAPI("/script/util/common")
os.loadAPI("/script/util/fileutil")
os.loadAPI("/script/util/sha256")

function doesUserExist(userName, password)
	database = getDatabase()
	
	if database[userName] ~= nil then
		value = database[userName]
		if value == password then
		  return true
		end
	end
	
	return false
end

function setUserPassword(userName, password)
	getDatabase()[userName] = sha256.sha256(password)
	saveDatabase()
end

function removeUser(userName)
	getDatabase()[userName] = nil
	saveDatabase()
end

function getDatabase() 
	if fs.exists("database") == false then
		fileutil.createIfNotExisting("database", "{userOne = \"5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8\",userTwo = \"5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8\",}")
	end
	
	return fileutil.loadTable("database")
end

function saveDatabase()
	fileutil.saveTable("database", getDatabase())
end
