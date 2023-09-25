extends CanvasLayer

@onready
var message = $vbxChatRoomContainer/HBoxContainer2/txtMessage
@onready
var history = $vbxChatRoomContainer/HBoxContainer/txtChatHistory
@onready
var users : ItemList = $vbxChatRoomContainer/HBoxContainer/itlUsers

func _ready() -> void:
	#Connect to our custom signal in Network
	Network.update_user_list.connect(update_user_list)
#	Network.connect("update_user_list",self,"update_user_list")
	multiplayer.peer_disconnected.connect(user_left, multiplayer.get_unique_id())
#	get_tree().connect("network_peer_disconnected",self,"user_left")
	
	# if we're server just update list
	if(multiplayer.is_server()):
		update_user_list() 
	
#Called when a user enters the chat, clear the list and repopulate withupdated one
func update_user_list():
	users.clear()
	for i in Network.user_list:
		users.add_item(Network.user_list[i])

#Remove user by it's ID and repopulate userlist
func user_left(ID):
	print(ID)
	Network.user_list.erase(str(ID)) # remove from user_list
	update_user_list()

func _physics_process(_delta: float) -> void:
	if(Input.is_action_just_pressed("return_key")):
		print(message.text)
		#Check it's not an empty space, if it isn't, then sendmessage
		if(message.text != "\n"):
			#Create the message and tell everyone else to add it to their history
			rpc("send_chat",create_message())
			history.append_text(create_message())
			message.text = ""
		else:
			message.text = ""

@rpc("any_peer", "unreliable")
func send_chat(txt):
	print("called send_chat")
	history.append_text(txt)

#We're using richtextlabel which allows us to format
func create_message() -> String:
	return "[b][color=" + Network.user_color +"]" + Network.user_name + ": "+"[/color][/b]" + message.text 

func _on_btnLogout_pressed() -> void:
	multiplayer.multiplayer_peer = null
	Network.user_list.clear()
	get_tree().change_scene_to_file("res://Lobby/Lobby.tscn")
