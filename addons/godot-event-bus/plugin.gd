tool
extends EditorPlugin

const EVENT_BUS = "EventBus"

func _enter_tree():
	add_custom_type(EVENT_BUS, "Node", preload("event_bus.gd"), preload("icon.png"))

func _exit_tree():
	remove_custom_type(EVENT_BUS)
