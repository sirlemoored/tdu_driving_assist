local autoAssemblyScript = [[
         [ENABLE]

         aobscanmodule(INJECT,TestDriveUnlimited.exe,F3 0F 11 48 58 F3 0F 11 87)
         alloc(newmem,$1000)
         globalalloc(odo_copied, 4)

         label(code)
         label(return)

         newmem:

         code:
         mov [odo_copied], eax
         movss [eax+58],xmm1
         jmp return

         INJECT:
         jmp newmem
         return:
         registersymbol(INJECT)

         [DISABLE]

         INJECT:
         db F3 0F 11 48 58

         unregistersymbol(INJECT)
         dealloc(newmem)
]]

local _Mem = {}
	_Mem.processName = "TestDriveUnlimited.exe"
	_Mem.addressX = 0x00fa48c0
	_Mem.addressY = 0x00fa48c4
	_Mem.addressZ = 0x00fa48c8
	_Mem.distanceLabel = "odo_copied"
	_Mem.distanceAddress = 0x0
	_Mem.distanceOffset = 0x58
	_Mem.injectionDisableInfo = nil

	function _Mem:refresh()
		openProcess(self.processName)
		local ptr = getAddress(self.distanceLabel)
		self.distanceAddress = (readInteger(ptr) or 0) + self.distanceOffset
	end

	function _Mem:readMemoryContents()
		pack = {}
		pack.posX = readFloat(self.addressX) or 0
		pack.posY = readFloat(self.addressY) or 0
		pack.posZ = readFloat(self.addressZ) or 0
		pack.currentDistance = readFloat(self.distanceAddress) or 0
		return pack
	end

	function _Mem:inject()
		openProcess(self.processName)

		local enabledOk, disableInfo = autoAssemble(autoAssemblyScript)
		self.injectionDisableInfo = disableInfo
		if not enabledOk then 
			return false
		else
			return true
		end
	end

	function _Mem:uninject()
		if self.injectionDisableInfo == nil then
			return false
		else
			local disabledOk = autoAssemble(autoAssemblyScript, self.injectionDisableInfo)
			self.injectionDisableInfo = nil
			return true
		end	
	end


Memory = {}
	function Memory.new()
		mem = {}
		setmetatable(mem, {__index = _Mem})
		return mem
	end

return Memory
