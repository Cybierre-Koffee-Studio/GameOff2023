extends Node
class_name Tile

enum TYPE {CENTER, CORRIDOR, STRAIGHT, CORNER}
#const COLORS = [Color.RED, Color.BLUE, Color.GREEN]

var valeur_cluster_max = 1

const center_texture = preload("res://models/tiles/center/tile_center_texture.png")
const corridor_texture = preload("res://models/tiles/corridor/tile_corridor_texture.png")
const straight_texture = preload("res://models/tiles/straight/tile_straight_texture.png")
const corner_texture = preload("res://models/tiles/corner/tile_corner_texture.png")

const center = preload("res://ProtoCrawler/tuiles_design/tileOuvert.tscn")
const corridor = preload("res://ProtoCrawler/tuiles_design/tileCouloir.tscn")
const straight = preload("res://ProtoCrawler/tuiles_design/tileEnT.tscn")
const corner = preload("res://ProtoCrawler/tuiles_design/tileVirage.tscn")

const reroll_item_scene = preload("res://scenes/items/reroll/reroll.tscn")
const monster_item_scene = preload("res://scenes/items/monstres/monstre.tscn")
const chest_item_scene = preload("res://scenes/items/coffre/coffre.tscn")

const items_list = [reroll_item_scene, monster_item_scene, chest_item_scene]

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
@onready var rota_tuile = $rotile.rotation_degrees.y

signal select_tile
signal rotate_tile

@export var can_rotate : bool = true
@export var can_move : bool = true

var item : Item = null
var poids = 0

# Called when the node enters the scene tree for the first time.
func _ready():
#    poids = randi_range(1,3)
#    $Label3D.text = str(poids)
    pass

func init(type : TYPE, obj : bool):
    poids = randi_range(1,3)
    $Label3D.text = str(poids)
    instance_type = type
    var base_material_copy = $rotile/mesh.get_surface_override_material(0).duplicate()
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
    $rotile/mesh.set_surface_override_material(0, base_material_copy)
    if !obj :
        add_item()
#        var proba_item = randi_range(0,100)
#        if proba_item >= 50:
#            add_item()

func ajout_model_physique(model):
    var le_model = model.instantiate()
    $rotile.add_child(le_model)

# renvoie les données sur les bords de la tuile sous forme d'un tableau de binaires :
#  0 : les ouvertures (haut, droite, bas, gauche), exemple pour un couloir horizontal : 0b0101
#  1 : les murs (haut, droite, bas, gauche), l'inverse des ouvertures en fait, exemple pour un couloir horizontal : 0b1010
func get_tile_data():
#    var rota_degrees : int = self.rotation_degrees.y
    var rota_degrees : int = $rotile.rotation_degrees.y
    var opening_data = opening_data_by_type_and_rotation[instance_type][rota_degrees%360]
    return [opening_data, opening_data^0b1111]

func add_item():
#    var new_item = reroll_item_scene.instantiate()
    var new_item = items_list.pick_random().instantiate()
    new_item.place_on_tile(self)
    item = new_item
    add_child(new_item)

func has_item():
    return item != null

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

func rotate_subtile(degr):
    $rotile.rotation_degrees.y = degr

func get_rota_degrees():
    return $rotile.rotation_degrees.y

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
func check_murs_vides():
    for i in range(1,5) :
        var un_raycast:RayCast3D = find_child("RayCast" + str(i))
        if !un_raycast.is_colliding() :
            var un_mur = find_child("mur" + str(i))
            un_mur.visible = true

