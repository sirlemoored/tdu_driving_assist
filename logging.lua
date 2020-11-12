local _defaultFormat = "tdu_%d_%m_%Y.log"
local _logLineWithYFormat = "%.0f,%.0f,%.0f\n"
local _logLineWithoutYFormat = "%.0f,%.0f\n"

local _Log = {}
	_Log.format = _defaultFormat
	_Log.fileName = os.date(_Log.format)
	_Log.file = nil

	function _Log:openFile(filename)
		self.file = io.open(filename, "a")
	end

	function _Log:closeFile()
		self.file:close()
		self.file = nil
	end

	function _Log:log(data, isLogging, ignoreY, ignoreStanding)
		if not isLogging then return end
		if data.standingStill == true and not ignoreStanding then return end
		if self.file ~= nil then
			if ignoreY then
				self.file:write(string.format(_logLineWithoutYFormat, data.posX, data.posZ))
			else
				self.file:write(string.format(_logLineWithYFormat, data.posX, data.posY, data.posZ))
			end
		end
	end

	function _Log:getFileSize()
		if self.file ~= nil then 
			return self.file:seek("end") 
		else 
			return 0 
		end
	end

Log = {}
	function Log.new(format)
		log = {}
		log.format = format or _defaultFormat
		log.fileName = os.date(log.format)
		setmetatable(log, {__index = _Log})
		return log
	end

return Log
