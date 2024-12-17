extends Node


func filter(message: Dictionary) -> Dictionary:
	var filter: Dictionary = Saves.get_or_add("networking", "chat_filter", {})
	for word in filter:
		if message["payload"]["text"].contains(word):
			message["payload"]["text"] = message["payload"]["text"].replace(word, filter[word]["replacement_word"])
		
			if filter[word]["ban"]:
				SteamLobbies.ban_player_persist(message.identity)
			elif filter[word]["block"]:
				SteamLobbies.block_player(message.identity)
			elif filter[word]["kick"]:
				SteamLobbies.kick(message.identity, "Host chat rules violation")
			
			if filter[word]["delete"]:
				message["payload"]["text"] = "Deleted by filter"
	return message
