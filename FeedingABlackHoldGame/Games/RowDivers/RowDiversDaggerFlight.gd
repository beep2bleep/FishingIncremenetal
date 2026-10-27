extends Node3D
## Presentation only. Battle advances this in simulation time, including speed boosts.
var origin: Vector3
var strike: Vector3
var side: Vector3
var duration: float = 0.5
var age: float = 0.0

func setup(from: Vector3, target: Vector3, seconds: float, handedness: float) -> void:
	origin = from
	strike = target
	duration = seconds
	var direction := (strike - origin).normalized()
	side = direction.cross(Vector3.UP).normalized() * handedness
	position = origin

func advance(delta: float, hand: Vector3, view_basis: Basis) -> bool:
	age = minf(age + delta, duration)
	var phase := age / duration
	# Freeze the outbound destination at launch. Return on the opposite side to the
	# current hand, so strafing never leaves the dagger behind or steers its strike.
	var returning := phase >= 0.5
	var t := (phase - 0.5) * 2.0 if returning else phase * 2.0
	var start := strike if returning else origin
	var finish := hand if returning else strike
	var arc := sin(t * PI)
	position = start.lerp(finish, t) + side * arc * (-0.22 if returning else 0.28) + Vector3.UP * arc * 0.12
	# All existing dagger artwork points up. Keep its face readable while tumbling,
	# using camera orientation only; neither the reticle nor bow aim steers it.
	basis = view_basis * Basis(Vector3.FORWARD, phase * TAU * 2.0)
	return age >= duration
