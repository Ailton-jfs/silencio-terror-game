extends Node

var noise = 0.0
var max_noise = 100.0

func add_noise(value):
	noise += value
	noise = clamp(noise, 0, max_noise)

func reduce_noise(value):
	noise -= value
	noise = clamp(noise, 0, max_noise)
