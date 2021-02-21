local _Proc = {}
	_Proc.posX, _Proc.posY, _Proc.posZ = 0,0,0
	_Proc.previousDistance = -1
	_Proc.currentDistance = -1

	_Proc.totalTime = 1
	_Proc.totalDistanceKm = 0
	_Proc.totalDistanceMi = 0
	_Proc.avgSpeedKph = 0
	_Proc.avgSpeedMph = 0

	_Proc.standingStill = true
	_Proc.osElapsedTime = 0
	_Proc.lastOsElapsedTime = 0

	function _Proc:reset()
				
		self.posX, self.posY, self.posZ = 0,0,0
		self.previousDistance = -1
		self.currentDistance = -1

		self.totalTime = 1
		self.totalDistanceKm = 0
		self.totalDistanceMi = 0
		self.avgSpeedKph = 0
		self.avgSpeedMph = 0

		self.standingStill = true
		self.wasStandingStill = true
		self.osElapsedTime = 0
		self.lastOsElapsedTime = 0
	
	end

	function _Proc:processData(data, elapsed, isTiming, ignoreStanding)

		if data == nil then return end

		self.posX = math.floor(data.posX)
		self.posY = math.floor(data.posY)
		self.posZ = math.floor(data.posZ)

		if isTiming then
			if self.previousDistance >= 0 then
				-- bodge-check to prevent invalid distances when switching between cars
				if math.abs(data.currentDistance - self.currentDistance) > 0.1 then
					self.previousDistance = -1
					self.currentDistance = -1
					return
				end

				self.previousDistance = self.currentDistance
				self.currentDistance = data.currentDistance
				self.standingStill = (self.previousDistance == self.currentDistance)

				if self.standingStill and not ignoreStanding then 
					self.lastOsElapsedTime = os.clock()
					return 
				else
					self.osElapsedTime = 0
					currentTime = os.clock()
					self.osElapsedTime = currentTime - self.lastOsElapsedTime
					self.lastOsElapsedTime = currentTime
				end

				self.totalDistanceKm = self.totalDistanceKm + (self.currentDistance - self.previousDistance)
				self.totalDistanceMi = self.totalDistanceKm / 1.609344
				self.avgSpeedKph = 3600 * 1000 * self.totalDistanceKm / self.totalTime
				self.avgSpeedMph = 3600 * 1000 * self.totalDistanceMi / self.totalTime
			else
				self.previousDistance = data.currentDistance
				self.currentDistance = data.currentDistance
			end
			self.totalTime = self.totalTime + self.osElapsedTime * 1000
		end
		
	end

Processing = {}
	function Processing.new()
		proc = {}
		setmetatable(proc, {__index = _Proc})
		return proc
	end

return Processing
