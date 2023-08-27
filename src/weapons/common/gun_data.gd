#extends GenericWeaponData
class_name GunData

@export var weapon_name: String = ""
@export var node_path: String = ""
@export var type: String = ""
@export var slot: int = -1
@export var damage: int = -1
@export var fire_rate_rpm: int = -1
@export var semi_auto: bool = false
@export var max_ammo: int = -1
@export var max_ammo_mag: int = -1
@export var reload_time_sec: float = -1
@export var swap_time_sec: float = -1
@export var vertical_recoil_impulse: float = -1
@export var vertical_recoil_drop: float = -1
@export var vertical_recoil_max_degrees: int = -1

# not used yet
@export var horizontal_recoil_impulse: float = -1
@export var horizontal_recoil_drop: float = -1
@export var horizontal_recoil_max_degrees: int = -1
@export var move_speed_mult: int = -1
@export var range_max_damage: float = -1
@export var dmg_dropoff_per_10_range: float = -1
@export var armor_penetration: int = -1
