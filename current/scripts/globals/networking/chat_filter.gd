extends Node


func filter(message: Dictionary) -> Dictionary:
	var chat_filter: Dictionary = Saves.get_or_add("networking", "chat_filter", {})
	for word: String in chat_filter:
		if message["payload"]["text"].contains(word):
			message["payload"]["text"] = message["payload"]["text"].replace(word, chat_filter[word]["replacement_word"])
			
			if chat_filter[word]["ban"]:
				SteamLobbies.ban_player_persist(message.identity)
			elif chat_filter[word]["block"]:
				SteamLobbies.block_player(message.identity)
			elif chat_filter[word]["kick"]:
				SteamLobbies.kick(message.identity, "Host chat rules violation")
			
			if chat_filter[word]["delete"]:
				message["payload"]["text"] = "Deleted by filter"
	return message
