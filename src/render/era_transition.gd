class_name EraTransition
extends Node
## Übergangsanimation zwischen Ären (Stub für Phase 1).
## In Phase 2+ hier echter Tween/Shader-Übergang; Architektur steht bereits:
## Der Renderer besitzt einen EraTransition-Child und kann play_to_era() aufrufen.

signal transition_finished(new_era_id: int)

func play_to_era(new_era_id: int) -> void:
	push_warning("EraTransition: no-op in Phase 1 (Ära %d)" % new_era_id)
	transition_finished.emit.call_deferred(new_era_id)
