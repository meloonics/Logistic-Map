extends Control

#Nothing educational to see here. move along!

onready var lm = get_parent().get_parent()

onready var lperticklabel = $ColorRect/VBoxContainer/HBoxContainer3/LperTickvalue
onready var xperlamblabel = $ColorRect/VBoxContainer/HBoxContainer4/XperTickvalue
onready var hreslabel = $ColorRect/VBoxContainer/HBoxContainer/HresValue
onready var vreslabel = $ColorRect/VBoxContainer/HBoxContainer2/VResValue
onready var minlambdalabel = $ColorRect/VBoxContainer/HBoxContainer7/min_lam_value
onready var minlambdaslider = $ColorRect/VBoxContainer/HBoxContainer7/min_lam_slider
onready var maxlambdalabel = $ColorRect/VBoxContainer/HBoxContainer8/max_lam_value
onready var maxlambdaslider = $ColorRect/VBoxContainer/HBoxContainer8/max_lam_slider
onready var colorcheck = $ColorRect/VBoxContainer/HBoxContainer6/CheckButton
onready var redrawbutton = $ColorRect/VBoxContainer/HBoxContainer5/REDRAW
onready var savebutton = $ColorRect/VBoxContainer/HBoxContainer5/SAVE

func _ready():
	lm.connect("unlock_save", self, "unlock_save")
	lm.connect("lock_save", self, "lock_save")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		set_process(true)

func _on_LperTickSlider_value_changed(value):
	lperticklabel.set_text(str(value))
	lm.lambdas_per_tick = int(value)
	redrawsignal()


func _on_XperTickSlider_value_changed(value):
	xperlamblabel.set_text(str(value))
	lm.N = int(value)
	redrawsignal()

func _on_HResSlider_value_changed(value):
	hreslabel.set_text(str(value))
	lm.lambda_steps = int(value)
	redrawsignal()


func _on_VResSlider_value_changed(value):
	vreslabel.set_text(str(value))
	lm.vertical_res = value
	redrawsignal()


func _on_min_lam_slider_value_changed(value):
	minlambdalabel.set_text(str(value))
	lm.min_lambda = value
	if value > lm.max_lambda:
		maxlambdaslider.value = value + maxlambdaslider.step
	redrawsignal()

func _on_max_lam_slider_value_changed(value):
	maxlambdalabel.set_text(str(value))
	lm.max_lambda = value
	if value < lm.min_lambda:
		minlambdaslider.value = value - minlambdaslider.step
	redrawsignal()


func _on_CheckButton_toggled(button_pressed):
	lm.coloring = button_pressed
	redrawsignal()


func _on_REDRAW_pressed():
	redrawbutton.modulate = Color.white
	lm.redraw()


func _on_SAVE_pressed():
	$FileDialog.popup_centered_ratio()
	lm.set_process_input(false)
	set_process_input(false)


func _on_X_pressed():
	$ColorRect.visible = false
	$Button.visible = true


func _on_Button_pressed():
	$ColorRect.visible = true
	$Button.visible = false

func redrawsignal():
	lm.redraw()
	#lock_save()
	#redrawbutton.modulate = Color.green
	#lm.set_process(false)

func unlock_save():
	savebutton.disabled = false

func lock_save():
	savebutton.disabled = true


func _on_FileDialog_file_selected(path):
	lm.save_json(path)
	set_process_input(true)
