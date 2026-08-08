--!strict
--!optimize 2

--// Types
export type StateMachine = {
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

--// Constructor
function StateMachine.new(state: string): StateMachine
	local self = setmetatable({
		state = state,
		previousState = state,
		transitionTime = 0,

		_onStateChanged = nil,
		_onStateRemoved = nil,
	}, StateMachine) :: StateMachine

	return self
end

--// Methods

function StateMachine:ChangeState(to: string): ()
	if self.state == to then
		return
	end

	self.previousState = self.state
	self.state = to

	if self._onStateChanged then
		self._onStateChanged()
	end
end

function StateMachine:GetState(): string
	return self.state
end

function StateMachine:IsInState(state: string): boolean
	return self.state == state
end

function StateMachine:Remove(): ()
	local onStateRemoved = self._onStateRemoved

	if onStateRemoved then
		onStateRemoved()
	end

	self.state = ""
	self.previousState = ""
	self.transitionTime = 0

	self._onStateChanged = nil
	self._onStateRemoved = nil
end

return StateMachine
