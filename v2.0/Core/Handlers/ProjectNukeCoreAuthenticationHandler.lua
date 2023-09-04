--[[

================================================================================

  ProjectNukeCoreAuthenticationHandler
    Provides services to allow users to be authenticated

================================================================================

  Author: stuntguy3000

--]]

local authenticatedUser = nil

function requestAuthentication(force)
    -- Force reauthentication if a user is logged in
    if (force) then
        authenticatedUser = nil
    end

    -- Is a user logged in?
    if (authenticatedUser) then
        return true
    end

    -- Request Authentication
    authenticationWindow = ProjectNukeCoreGUIHandler.getAuthenticationWindow()
    authenticationWindow.clear()
    authenticationWindow.write("Abc")
    
    ProjectNukeCoreGUIHandler.DrawBaseGUI("Authentication Request", "Please enter your username and password.", authenticationWindow)

    

    -- Bring it together
    authenticationWindow.setVisible(true)
    ProjectNukeCoreGUIHandler.StartEventListener()
end