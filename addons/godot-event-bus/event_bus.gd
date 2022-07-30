extends Node

@export var events_at_once: int = 1

enum PROCESSING_MODE {IDLE, PHYSICS}

@export var processing_mode:PROCESSING_MODE = PROCESSING_MODE.IDLE

var events_lock = Mutex.new()
var receivers_lock = Mutex.new()
const receivers = {}
const events = []

class Event:
	var receiver = null
	var method = null
	var value = null

func _ready():
	set_process(false)
	set_physics_process(false)
	if (processing_mode == PROCESSING_MODE.IDLE):
		set_process(true)
	elif(processing_mode == PROCESSING_MODE.PHYSICS):
		set_physics_process(true)

func _process(delta):
	_process_events();

func _physics_process(delta):
	_process_events()

func _process_events():
	if events.size() == 0:
		return

	var num = min(events_at_once, events.size())
	for i in range(0, num):
		false # events_lock.lock() # TODOConverter40, image no longer require locking, `false` helps to not broke one line if/else, so can be freely removed
		var event = events.pop_front()
		false # events_lock.unlock() # TODOConverter40, image no longer require locking, `false` helps to not broke one line if/else, so can be freely removed

		event.receiver.call(event.method, event.value)

func publish(event_name, value = null):
	var event_receivers = receivers[event_name]
	for receiver in event_receivers.keys():
		var event = Event.new()
		event.receiver = receiver
		event.method = event_receivers[receiver]
		event.value = value

		false # events_lock.lock() # TODOConverter40, image no longer require locking, `false` helps to not broke one line if/else, so can be freely removed
		events.push_back(event)
		false # events_lock.unlock() # TODOConverter40, image no longer require locking, `false` helps to not broke one line if/else, so can be freely removed

func subscribe(event_name, receiver, method):
	if !receiver.has_method(method):
		printerr(receiver, " doesn't have method ", method)
		return

	false # receivers_lock.lock() # TODOConverter40, image no longer require locking, `false` helps to not broke one line if/else, so can be freely removed
	if !receivers.has(event_name):
		receivers[event_name] = {}
	false # receivers_lock.unlock() # TODOConverter40, image no longer require locking, `false` helps to not broke one line if/else, so can be freely removed
	receivers[event_name][receiver] = method;


func unsubscribe(event_name, receiver):
	receivers[event_name].erase(receiver)

func queue_size():
	return events.size()
