extends Node


var encrypted_messages_recieved: Dictionary = {}
var encrypted_messages_sent: Dictionary = {}
var crypto: Crypto = Crypto.new()
var RNG: RandomNumberGenerator = RandomNumberGenerator.new()

func save_message(sender_identity: int, message_id: int, payload: PackedByteArray) -> void:
	if !encrypted_messages_recieved.has(sender_identity):
		encrypted_messages_recieved[sender_identity] = {}
	encrypted_messages_recieved[sender_identity][message_id] = payload

func send_key(ID: int, this_target: int = 0) -> void:
	SteamP2P.send_message_to_user({"type": "encrypted_key", "message_id": ID, "key": encrypted_messages_sent[ID]["key"].save_to_string()}, this_target)

func decode_message(sender_identity: int, message_id: int, key: String) -> void:
	if encrypted_messages_recieved.has(sender_identity) and encrypted_messages_recieved[sender_identity].has(message_id):
		var crypto_key: CryptoKey = CryptoKey.new()
		crypto_key.load_from_string(key)
		var decrypted_byte_array: PackedByteArray = crypto.decrypt(crypto_key, encrypted_messages_recieved[sender_identity][message_id])
		var decrypted_message: Dictionary = {"identity": sender_identity, "payload": decrypted_byte_array}
		SteamP2P.process_message(decrypted_message)

func encode_payload(payload: Dictionary) -> int:
	var key: CryptoKey = crypto.generate_rsa(4096)
	var ID: int = 0
	while ID == 0 or encrypted_messages_sent.has(ID):
		ID = RNG.randi()
	var encrypted: PackedByteArray = crypto.encrypt(key, var_to_bytes(payload).compress(FileAccess.COMPRESSION_GZIP))
	var processed_payload: PackedByteArray = var_to_bytes({"type": "encrypted_message", "message_id": ID, "encrypted_payload": encrypted})
	encrypted_messages_sent[ID] = {"key": key, "payload": processed_payload}
	return ID
