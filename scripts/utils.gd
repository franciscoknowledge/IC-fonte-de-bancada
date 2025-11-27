extends Node

func get_enum_key(e: Dictionary, v: int) -> String:
	for key in e.keys():
		if e[key] != v: continue
		return key
		
	return "ERRO"
