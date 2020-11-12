local _Settings = {}
	_Settings.file = os.getenv("userprofile") .. "\\Documents\\Test Drive Unlimited\\DA\\settings.tdu"
	_Settings.logs = os.getenv("userprofile") .. "\\Documents\\Test Drive Unlimited\\DA\\logs\\"
	_Settings.logFormat = "tdu_%d_%m_%Y.log"

	function _Settings:read()
		local file = io.open(self.file)
		if file ~= nil then
			self.logs = file:read()
			file:close()
		end
	end

	function _Settings:update(logs)
		self.logs = logs
	end

	function _Settings:save()
		local file = io.open(self.file, "w")
		file:write(self.logs)
		file:close()
	end

	function _Settings:toString()
		return self.file .. "\n" .. self.logs .. "\n" .. self.logFormat
	end


Settings = {}

	function Settings.new(logd)
		set = {}
		set.logs = logd
		setmetatable(set, {__index = _Settings})
		return set
	end

return Settings
