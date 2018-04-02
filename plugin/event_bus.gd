extends Node

export(int) var events_at_once = 1

enum PROCESSING_MODE {IDLE, PHYSICS}
export (int, "Idle", "Physics") var processing_mode = 0

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
        events_lock.lock()
        var event = events.pop_front()
        events_lock.unlock()

        event.receiver.call(event.method, event.value)

func publish(event_name, value = null):
    var event_receivers = receivers[event_name]
    for receiver in event_receivers.keys():
        var event = Event.new()
        event.receiver = receiver
        event.method = event_receivers[receiver]
        event.value = value

        events_lock.lock()
        events.push_back(event)
        events_lock.unlock()

func subscribe(event_name, receiver, method):
    if !receiver.has_method(method):
        printerr(receiver, " doesn't have method ", method)
        return

    receivers_lock.lock()
    if !receivers.has(event_name):
        receivers[event_name] = {}
    receivers_lock.unlock()
    receivers[event_name][receiver] = method;


func unsubscribe(event_name, receiver):
    receivers[event_name].erase(receiver)

func queue_size():
    return events.size()