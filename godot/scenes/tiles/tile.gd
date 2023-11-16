extends Node
class_name Tile

enum TYPE {CENTER, CORRIDOR, STRAIGHT, CORNER}
#const COLORS = [Color.RED, Color.BLUE, Color.GREEN]

var valeur_cluster_max = 1

const center_texture = preload("res://models/tiles/center/tile_center_texture_center.png")
const corridor_texture = preload("res://models/tiles/corridor/tile_corridor_texture_corridor.png")
const straight_texture = preload("res://models/tiles/straight/tile_straight_texture_t.png")
const corner_texture = preload("res://models/tiles/corner/tile_corner_texture_corner.png")

const center = preload("res://ProtoCrawler/tuiles_design/tileOuvert.tscn")
const corridor = preload("res://ProtoCrawler/tuiles_design/tileCouloir.tscn")
const straight = preload("res://ProtoCrawler/tuiles_design/tileEnT.tscn")
const corner = preload("res://ProtoCrawler/tuiles_design/tileVirage.tscn")

const opening_data_by_type_and_rotation = {
    TYPE.CENTER: {
        0:   0b1111,
        90:  0b1111,
        180: 0b1111,
        270: 0b1111
    },
    TYPE.CORRIDOR: {
        0:   0b1010,
        90:  0b0101,
        180: 0b1010,
        270: 0b0101
    },
    TYPE.STRAIGHT: {
        0:   0b0111,
        90:  0b1110,
        180: 0b1101,
        270: 0b1011,
    },
    TYPE.CORNER: {
        0:   0b0011,
        270: 0b1001,
        180: 0b1100,
        90:  0b0110,
    }
}

var instance_type

signal select_tile
signal rotate_tile

@export var can_rotate : bool = true
@export var can_move : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func init(type : TYPE):
    instance_type = type
    var base_material_copy = $mesh.get_surface_override_material(0).duplicate()
    match type:
        TYPE.CENTER:
            base_material_copy.albedo_texture = center_texture
            ajout_model_physique(center)
        TYPE.CORRIDOR:
            base_material_copy.albedo_texture = corridor_texture
            ajout_model_physique(corridor)
        TYPE.STRAIGHT:
            base_material_copy.albedo_texture = straight_texture
            ajout_model_physique(straight)
        TYPE.CORNER:
            base_material_copy.albedo_texture = corner_texture
            ajout_model_physique(corner)
    #base_material_copy.albedo_color = COLORS.pick_random()
    $mesh.set_surface_override_material(0, base_material_copy)

func ajout_model_physique(model):
    var le_model = model.instantiate()
    add_child(le_model)

# renvoie les données sur les bords de la tuile sous forme d'un tableau de binaires :
#  0 : les ouvertures (haut, droite, bas, gauche), exemple pour un couloir horizontal : 0b0101
#  1 : les murs (haut, droite, bas, gauche), l'inverse des ouvertures en fait, exemple pour un couloir horizontal : 0b1010
func get_tile_data():
    var rotation_degrees : int = floor(rad_to_deg(self.rotation.y))
    var opening_data = opening_data_by_type_and_rotation[instance_type][rotation_degrees%360]
    return [opening_data, opening_data^0b1111]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    pass

func _on_area_3d_mouse_entered():
    pass

func _on_area_3d_mouse_exited():
    pass

func _on_area_3d_input_event(_camera, event, _position, _normal, _shape_idx):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
            select_tile.emit(self)

#func get_neighbour_tile_color():
#    var valeur_tampon = 0
#    for i in range(1,5) :
#        var un_raycast:RayCast3D = find_child("RayCast" + str(i))
#        if un_raycast.is_colliding() :
#            if un_raycast.get_collider().get_parent().get_tile_color() == get_tile_color() :
#                if un_raycast.get_collider().get_parent().valeur_cluster_max < valeur_tampon :
#                    valeur_cluster_max = un_raycast.get_collider().get_parent().valeur_cluster_max
#                print("C LA MEME")

#func get_tile_color():
#    return $mesh.get_surface_override_material(0).albedo_color
