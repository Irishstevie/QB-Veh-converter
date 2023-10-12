Config = {}

Config.pathToServerData = io.popen("cd"):read('*l') -- Get the path to the directory where server.cfg resides (only for windows)
Config.resourceName = GetCurrentResourceName() -- Get the name of our resource so we can get the full path
Config.fullPathToResource = Config.pathToServerData .. '\\resources\\' .. Config.resourceName
