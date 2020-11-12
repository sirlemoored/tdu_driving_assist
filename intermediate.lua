Interface = require("interface")
Memory = require("memory")
Logging = require("logging")
Processing = require("processing")
Settings = require("settings")

local _Int = {}
	_Int.logging = Logging.new()
	_Int.settings = Settings.new()
	_Int.memory = Memory.new()
	_Int.processing = Processing.new()
	_Int.interface = Interface.new()

	_Int.timers = {}
	_Int.islogging = false
	_Int.istiming = false
	_Int.ignoreStanding = false
	_Int.loggingFrequency = 1000

	function _Int:addTimer(interval, label, onTick)
		if onTick == nil then return end
		local timer = createTimer()
		timer.Interval = interval
		timer.OnTimer = onTick
		timer.Enabled = false
		self.timers[label] = timer
	end

	function _Int:toggleTimer(index)
		if index == nil then return end
		self.timers[index].Enabled = not self.timers[index].Enabled

	end

	-- Fetches raw memory contents from memory reading module.
	-- return: table of memory contents { posX, posY, posZ, currentDistance }
	function _Int:getMemory()
		return self.memory:readMemoryContents()
	end

	-- Processes raw memory contents in processing module.
	-- data: table of memory contents { posX, posY, posZ, currentDistance }
	-- timeElapsed: time between ticks
	-- isTiming: self.timing
	-- ignoreStanding: whether we dismiss calculations if standing still
	-- return: processed data { posX, posY, posZ, totalTime, avgSpeedKph, avgSpeedMph, totalDistanceKm, totalDistanceMi, standingStill }
	function _Int:processMemory(data, timeElapsed, isTiming, ignoreStanding)
		return self.processing:processData(data, timeElapsed, isTiming, ignoreStanding)
	end

	-- Saves driving data using logging module.
	-- dataPack: table of driving data { posX, posY, posZ, standingStill }
	-- isLogging: self.logging
	-- ignoreY: is posY ignored in logging
	-- ignoreStanding: dismiss logging if standing still
	function _Int:log(data, isLogging, ignoreY, ignoreStanding)
		self.logging:log(data, isLogging, ignoreY, ignoreStanding)
		return self.logging:getFileSize()
	end
	
	-- Updates interface with processed data.
	-- dataPack: table of driving data { posX, posY, posZ, totalTime, avgSpeedKph, avgSpeedMph, totalDistanceKm, totalDistanceMi }
	-- isLogging: self.logging
	-- isTiming: self.timing
	-- fileSize: log file size
	function _Int:updateInterface(dataPack, isLogging, isTiming, fileSize, folderName)
		self.interface:update(dataPack, isLogging, isTiming, fileSize, folderName)
	end

	function _Int:updateSettings()
		local dialog = createSelectDirectoryDialog(self.interface.mainForm)
		local success = dialog:Execute()
		if success == true then
			self.settings:update(dialog.FileName.."\\")
			self.settings:save()
		end
	end

	function _Int:updateLogTimerInterval()
		self.timers["log"].Enabled = false
		self.timers["log"] = nil
		self:addTimer(self.loggingFrequency, "log", function()
		self:log({ posX = self.processing.posX, posY = self.processing.posY, posZ = self.processing.posZ, standingStill = self.processing.standingStill }, self.islogging, true, self.ignoreStanding)
		end)
		self.timers["log"].Enabled = true
		
	end

	function _Int:toggleLogging()
		if self.memory.injectionDisableInfo == nil then self:inject(); self:uninject(); end
		if not self.islogging then
			self.logging:openFile(self.settings.logs .. os.date(self.settings.logFormat))
		else
			self.logging:closeFile()
		end

		self.islogging = not self.islogging

	end

	function _Int:toggleTiming()
		if self.memory.injectionDisableInfo == nil then self:inject(); self:uninject(); end
		self.istiming = not self.istiming
	end

	function _Int:resetTiming()
		self.processing:reset()
	end
	
	function _Int:inject()
		self.memory:inject()
		self.memory:refresh()
	end

	function _Int:uninject()
		pcall(self.memory:uninject())
	end

	-- This function should be outside, but is here not to overcomplicate things 
	function _Int:addBasicTimers()
		self:addTimer(100, "read", function()
			local mem = self:getMemory()
			self:processMemory(mem, 100, self.istiming, self.ignoreStanding)
		end)

		self:addTimer(self.loggingFrequency, "log", function()
			self:log({ posX = self.processing.posX, posY = self.processing.posY, posZ = self.processing.posZ, standingStill = self.processing.standingStill }, self.islogging, true, self.ignoreStanding)
		end)

		self:addTimer(100, "interface", function()
			self:updateInterface(self.processing, self.islogging, self.istiming, self.logging:getFileSize(), self.settings.logs)
		end)

	end

	function _Int:registerEvents()
		local Pipes = {}
		Pipes.toggleLogging = self.toggleLogging
		Pipes.toggleTiming = self.toggleTiming
		Pipes.selectDirectory = self.updateSettings
		Pipes.resetTiming = self.resetTiming
		Pipes.closeForm = function () self:uninject(); closeCE() end -- ADD closeCE() TOO
		
		self.interface:registerEvents(Pipes, self)
	end

	function _Int:startTimers()
		self:inject()
		self.settings:read()
		self.timers["interface"].Enabled = true
		self.timers["log"].Enabled = true
		self.timers["read"].Enabled = true
	end


Intermediate = {}
	function Intermediate.new()
		int = {}
		setmetatable(int, {__index = _Int})
		return int
	end

return Intermediate
-- 2DFFAC8
