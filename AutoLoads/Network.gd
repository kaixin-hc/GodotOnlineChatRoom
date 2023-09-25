extends Node

signal update_user_list

var user_name : String = "Default"
var user_color : String = "red"

var user_list : Dictionary

func _ready() -> void:
	multiplayer.connected_to_server.connect(connected)
	multiplayer.server_disconnected.connect(server_disconnected)
#	get_tree().connect("connected_to_server",self,"connected")
#	get_tree().connect("server_disconnected",self,"server_disconnected")

#If we successful connect to the server, go into the chatroom
func connected():
	print("connected to server")
	var compile_data : Array = [str(multiplayer.get_unique_id()),user_name]
	rpc_id(1,"update_user",compile_data)
	enter_chat_room()
	
#Only run on the server
@rpc("any_peer", "unreliable")
func update_user(user):
	user_list[str(user[0])] = user[1]
	emit_signal("update_user_list")
	rpc("client_update",user_list)
	pass

@rpc("any_peer", "unreliable")	
func client_update(updatedlist):
	user_list = updatedlist
	emit_signal("update_user_list")

#Server just closed
func server_disconnected():
	print("server_disconnected")
	OS.alert('Server closed', 'Status')
	get_tree().change_scene_to_file("res://Lobby/Lobby.tscn")
	

func create_server():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(9999, 4)
	multiplayer.multiplayer_peer = peer
#	var server : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
#	server.create_server(9999,32)
#	get_tree().set_network_peer(server)
#	enter_chat_room()
	
func enter_chat_room():
	get_tree().change_scene_to_file("res://ChatRoom/Chatroom.tscn")
#	get_tree().change_scene("res://ChatRoom/Chatroom.tscn")
