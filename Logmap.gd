extends Node

########################
# Logistic Map v1.0
# written by meloonicscorp
# Oct2020
#
########################
#
# THE FORMULA:
#
# x[n+1] = lambda * x[n] * (1 - x[n])
#
# with x[0] = 0.5
# n is the number of the current generation
# lambda (growth rate) is a float between 1 and 4
#
# plot lambda on x-axis and value of f(x[n+1]) on y-axis
#
# what is the logistic map and the bifurcation diagram all about?
# it's hard to explain. check out Veritasium's video on the topic if you want to learn more:
# https://www.youtube.com/watch?v=ovJcsL7vyrk

onready var trect = $Screen/Plot
onready var lamlabel = $Screen/Label
signal unlock_save
signal lock_save

var image : Image
var texture : ImageTexture

var lambdas_per_tick := 100
var N = 500

var min_lambda := 1.0
var max_lambda := 4.0
var lambda : float

#only the last 2% of all calculated values for x[n] are actually used for plotting
# so a large N-value as well as a large lambda_steps gives a more detailed result.
var slice_amt : int
var slice_percent := 2.0

var lambda_steps := 10000.0
var vertical_res := 10000.0
var lstep : float

#array of x[n+1] values calculated
var x : Array = []
#array of lambda-values with their x-Arrays
var l : Array = []

#This dictionary has each lambda-value as key and their x[n+1]-Array as value. 
#You can save this as a file and use it in your project, since calcing it all over again is somewhat expensive.
var json_dic = {}

#arbitrary initial value.
var x_zero = 0.5

var lcount := 0

var coloring := true

func _ready():
	set_up_plot()
	slice_amt = int((N / 100) * slice_percent) + 1
	lstep = (max_lambda - min_lambda)/lambda_steps
	lambda = min_lambda
	set_process(false)

func _process(_delta):
	for _i in range(lambdas_per_tick):
		if lambda <= max_lambda:
			calc_x()
		else:
			emit_signal("unlock_save")
			set_process(false)
	
	texture.create_from_image(image)
	trect.set_texture(texture)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		redraw()


func calc_x():
	
	#first, the initial value is set.
	x = [x_zero]
	
	for n in range(N - 1):
		#calculate x[n+1] from last value, using the formula
		var new_x = lambda * x[n] * (1.0 - x[n])
		
		#set the decimal place accuracy, to make results less random and easier to use
		new_x = stepify(new_x, 1.0/vertical_res)
		
		#the new x[n+1] is added to the array
		x.append(new_x)
	
	#finally, only the last 2% of values get picked, and duplicates are filtered out.
	x = x.slice(x.size()-slice_amt, x.size()-1)
	x = uniques(x)
	
	lamlabel.set_text("Lambda: " + str(lambda) + "\nBranches: " + str(x.size()))
	
	l.append(x)
	json_dic[lambda] = x
	plot(x)
	
	lambda += lstep
	lcount += 1

func uniques(a: Array) -> Array:
	var uni_array = [a[0]]
	for i in a:
		if uni_array.has(i):
			continue
		else:
			uni_array.append(i)
	return uni_array


func set_up_plot():
	image = Image.new()
	texture = ImageTexture.new()
	
	image.create(trect.rect_size.x, trect.rect_size.y, false, Image.FORMAT_RGBAH)
	image.fill(Color(0.0, 0.0, 0.0, 1.0))
	
	texture.create_from_image(image)
	trect.set_texture(texture)

func reset_plot():
	set_process(false)
	lstep = (max_lambda - min_lambda)/lambda_steps
	lambda = min_lambda
	lcount = 0
	l = []
	x = []
	json_dic.clear()
	set_up_plot()

func redraw():
	reset_plot()
	emit_signal("lock_save")
	set_process(true)

func plot(a: Array):
	
	image.lock()
	var wpix = int( (image.get_width() / lambda_steps * lcount ) )
	
	for i in a:
		
		
		var hpix = int( image.get_height() - image.get_height() * i )
		
		if hpix >= image.get_height() or wpix >= image.get_width():
			continue
		
		var col = branchcolor(a)
		image.set_pixel(wpix, hpix, col)
	
	image.unlock()

func branchcolor(a: Array) -> Color:
	if !coloring:
		return Color.white
	
	match a.size():
		1: return Color.white
		2: return Color.yellow
		4: return Color.orange
		8: return Color.red
		_: return Color(randf(), randf(), randf(), 1.0)

func save_json(path: String):
	var f = File.new()
	print(path)
	f.open(path, File.WRITE)
	
	f.store_string(to_json(json_dic))
	f.close()
	set_process_input(true)
