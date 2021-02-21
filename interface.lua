local function SecondsToClock(seconds)
	local seconds = tonumber(seconds)   
    local hours = string.format("%02.f", math.floor(seconds/3600));
    local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
end

local function TenthsSecondsToClock(tenths)
	local tenths = tonumber(tenths)
	local hours = math.floor(tenths / 36000); tenths = tenths - hours * 36000
	local minutes = math.floor(tenths / 600); tenths = tenths - minutes * 600
	local seconds = math.floor(tenths / 10); tenths = tenths - seconds * 10
	return string.format("%02.f:%02.f:%02.f.%d", hours, minutes, seconds, math.floor(tenths))
end

local _Intf = {}
	_Intf.form = DrivingAssist
	_Intf.elements = {
		toggleLogging = DrivingAssist.ToggleLogging,
		toggleTiming = DrivingAssist.ToggleTiming,
		
		pos = DrivingAssist.Pos,
		distanceKm = DrivingAssist.DistanceKm,
		distanceMi = DrivingAssist.DistanceMi,
		time = DrivingAssist.Time,
		speedKph = DrivingAssist.SpeedKph,
		speedMph = DrivingAssist.SpeedMph,
		fileSize = DrivingAssist.FileSize,

		buttonDirectory = DrivingAssist.ButtonDirectory,
		buttonReset = DrivingAssist.ButtonReset
	}

	_Intf.periods = {}
	_Intf.periods[0] = 50
	_Intf.periods[1] = 100
	_Intf.periods[2] = 250
	_Intf.periods[3] = 500
	_Intf.periods[4] = 1000
	
	_Intf.frequencies = {}
	_Intf.frequencies[0] = 5
	_Intf.frequencies[1] = 10
	_Intf.frequencies[2] = 20
	_Intf.frequencies[3] = 50
	_Intf.frequencies[4] = 100

	function _Intf:update(dataPack, isLogging, isTiming, fileSize, logFolder)
		if isLogging then
			DrivingAssist.ToggleLogging.State = cbChecked
		else
			DrivingAssist.ToggleLogging.State = cbUnchecked
		end
		if isTiming then
			DrivingAssist.ToggleTiming.State = cbChecked
		else
			DrivingAssist.ToggleTiming.State = cbUnchecked
		end
		DrivingAssist.FileSize.Caption = string.format("%.2f kB", fileSize / 1024)
		DrivingAssist.Pos.Caption = string.format("%.0f, %.0f, %.0f", dataPack.posX, dataPack.posY, dataPack.posZ)
		DrivingAssist.DistanceKm.Caption = string.format("%0.2f km", dataPack.totalDistanceKm)
		DrivingAssist.DistanceMi.Caption = string.format("%0.2f mi", dataPack.totalDistanceMi)
		DrivingAssist.Time.Caption = SecondsToClock(dataPack.totalTime / 1000)
		DrivingAssist.SpeedKph.Caption = string.format("%0.2f kph", dataPack.avgSpeedKph)
		DrivingAssist.SpeedMph.Caption = string.format("%0.2f mph", dataPack.avgSpeedMph)


		DrivingAssist.LabelFileSize.Hint = logFolder
		DrivingAssist.FileSize.Hint = logFolder

	end

	function _Intf:registerEvents(pipes, int)
		DrivingAssist.ToggleLogging.OnClick = function() pipes.toggleLogging(int); if int.islogging then playSound(findTableFile("asdasd.wav")) else playSound(findTableFile("asd.wav")) end end
		DrivingAssist.ToggleTiming.OnClick = function() pipes.toggleTiming(int) ; if int.istiming then playSound(findTableFile("asdasd.wav")) else playSound(findTableFile("asd.wav")) end end
		DrivingAssist.ButtonDirectory.OnClick = function() pipes.selectDirectory(int) end
		DrivingAssist.ButtonReset.OnClick = function() pipes.resetTiming(int) end
		DrivingAssist.Still.OnClick = function() int.ignoreStanding = not int.ignoreStanding; if int.ignoreStanding then DrivingAssist.Still.State = cbUnchecked else DrivingAssist.Still.State = cbChecked end end
		DrivingAssist.OnClose = function() pipes.closeForm(int) end
		DrivingAssist.Period.OnSelect = function() 
			int.distanceFrequency = self.frequencies[DrivingAssist.Period.ItemIndex]; 
			--int:updateLogTimerInterval() 
		end

		self.timingHotkey = createHotkey(function() 
			pipes.toggleTiming(int)
 			if int.istiming then playSound(findTableFile("asdasd.wav")) else playSound(findTableFile("asd.wav")) end 
		end, VK_CONTROL, VK_T)
		self.loggingHotkey = createHotkey(function() 
			pipes.toggleLogging(int) 
			if int.islogging then playSound(findTableFile("asdasd.wav")) else playSound(findTableFile("asd.wav")) end 
		end, VK_CONTROL, VK_E)

	end
	

Interface = {}
	function Interface.new()
		int = {}
		setmetatable(int, {__index = _Intf})
		return int
	end

return Interface
