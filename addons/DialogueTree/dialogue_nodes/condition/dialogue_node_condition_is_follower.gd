@tool
extends DialogueNodeCondition
## This is an example, it only works if you implement a follower / companion system with the
## API shown here

func evaluate(p_context: DialogueTree.Context) -> bool:
	return p_context.responder in p_context.initiator.followers


func _get_name() -> String:
	return "Is Follower"
