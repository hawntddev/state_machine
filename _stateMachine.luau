--!strict
--!optimize 2

--// Types
export type StateMachine = {
	-- instance fields go here
	state: string,
	previousState: string,
	transitionTime: number,
	
	ChangeState: (self: StateMachine, state: string) -> (),
	GetState: (self: StateMachine) -> string,
	IsInState: (self: StateMachine, state: string) -> boolean,
	Remove: (self: StateMachine) -> (),
	
	_onStateChanged: (...any) -> (...any)?,
	_onStateRemoved: (...any) -> (...any)?,
}

--// Module
local StateMachine = {}
StateMachine.__index = StateMachine

StateMachine.States = {}:: {[string]: boolean}

--// Private functions
local function _privateHelper()

end


--// Constructor
function StateMachine.new(state: string): StateMachine
	local self = setmetatable({
		state = state,
		previousState = state,
		transitionTime = 0,
	}, StateMachine):: StateMachine
	
	StateMachine.States[state] = true
	return self
end


--// Methods

function StateMachine:ChangeState(to: string): ()
	local self = self:: StateMachine
	
	if not self then
		return
	end
	
	if self.state == to then
		return
	end
	
	task.delay(self.transitionTime, function()
		self.previousState = self.state
		self.state = to
		
		if self._onStateChanged then
			self._onStateChanged()
		end
	end)
end


function StateMachine:GetState(): string
	local self = self:: StateMachine
	
	return self.state
end


function StateMachine:IsInState(state: string): boolean
	local self = self:: StateMachine
	
	return self.state == state
end

function StateMachine:Remove(): ()
	local self = self:: StateMachine
	
	if not self then
		return
	end
	
	self.state = ""
	self.previousState = ""
	self.transitionTime = 0
	
	if self._onStateRemoved then
		self._onStateRemoved()
	end
	
	self._onStateChanged = nil
	self._onStateRemoved = nil
	
	StateMachine.States[self.state] = nil
	StateMachine.States[self.previousState] = nil
end

--// Return
return StateMachine