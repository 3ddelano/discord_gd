# Represents an extended Discord User
class_name ExtendedUser extends User

var email: String # The email of the user
var mfa_enabled: bool # Whether the user has enabled two-factor authentication
var premium_type: int # The type of Nitro subscription on the user's account
var verified: bool # Whether the account email has been verified

# @hidden
func _init(p_dict, p_client).(p_dict, p_client, "ExtendedUser"):
	update(p_dict)
	return self


func update(p_dict):
	.update(p_dict)

	if "email" in p_dict:
		email = p_dict.email
	if "verified" in p_dict:
		verified = p_dict.verified
	if "mfa_enabled" in p_dict:
		mfa_enabled = p_dict.mfa_enabled
	if "premium_type" in p_dict:
		premium_type = p_dict.premium_type


# @hidden
func to_dict(p_props = []) -> Dictionary:
	p_props.append_array(["email", "mfa_enabled", "premium", "verified"])
	return .to_dict(p_props)
