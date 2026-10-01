class_name VehicleFactory
extends RefCounted
## Turbo Rush procedural vehicle factory.
## Extracted out of main.gd so the main game script stays modular and editable.
## All meshes/materials are generated in code, so the project needs no binary art assets.

static func build(car_name:String,_car_id:String,color:Color)->CharacterBody3D:
    var car:=CharacterBody3D.new()
    car.name=car_name
    car.collision_layer=2
    car.collision_mask=0

    var shape:=CollisionShape3D.new()
    var bs:=BoxShape3D.new()
    bs.size=Vector3(2.25,1.0,4.2)
    shape.shape=bs
    shape.position.y=0.58
    car.add_child(shape)

    car.set_meta("car_id",_car_id)
    var body_color:=color
    if car_name=="PLAYER":
        var skin_id:=str(SaveSystem.data["cosmetics"]["equipped"].get("skin","skin_01"))
        var skin:=ContentCatalog.skin(skin_id)
        if not skin.is_empty():
            body_color=Color(str(skin.get("color","#FF6B2C")))

    var lower:=MeshInstance3D.new()
    var lower_mesh:=BoxMesh.new()
    lower_mesh.size=Vector3(2.24,0.46,4.12)
    lower.mesh=lower_mesh
    lower.position.y=0.52
    var lower_mat:=StandardMaterial3D.new()
    lower_mat.albedo_color=body_color.darkened(0.16)
    lower_mat.metallic=0.28
    lower_mat.roughness=0.28
    lower.material_override=lower_mat
    car.add_child(lower)

    var body:=MeshInstance3D.new()
    var bm:=BoxMesh.new()
    bm.size=Vector3(2.08,0.52,3.42)
    body.mesh=bm
    body.position=Vector3(0,0.82,-0.15)
    body.rotation_degrees.x=-2.5
    var mat:=StandardMaterial3D.new()
    mat.albedo_color=body_color
    mat.metallic=0.22
    mat.roughness=0.24
    body.material_override=mat
    car.add_child(body)

    var hood:=MeshInstance3D.new()
    var hm:=BoxMesh.new()
    hm.size=Vector3(1.88,0.20,1.18)
    hood.mesh=hm
    hood.position=Vector3(0,1.03,-1.38)
    hood.rotation_degrees.x=-4.0
    hood.material_override=mat
    car.add_child(hood)

    var cabin:=MeshInstance3D.new()
    var cb:=BoxMesh.new()
    cb.size=Vector3(1.34,0.52,1.70)
    cabin.mesh=cb
    cabin.position=Vector3(0,1.25,0.05)
    cabin.rotation_degrees.x=7.0
    var glass:=StandardMaterial3D.new()
    glass.albedo_color=Color("#12243B")
    glass.metallic=0.75
    glass.roughness=0.12
    cabin.material_override=glass
    car.add_child(cabin)

    var roof:=MeshInstance3D.new()
    var rb:=BoxMesh.new()
    rb.size=Vector3(1.08,0.08,1.15)
    roof.mesh=rb
    roof.position=Vector3(0,1.57,0.05)
    var roof_mat:=StandardMaterial3D.new()
    roof_mat.albedo_color=Color("#0E1420")
    roof_mat.metallic=0.55
    roof_mat.roughness=0.2
    roof.material_override=roof_mat
    car.add_child(roof)

    var splitter:=MeshInstance3D.new()
    var spb:=BoxMesh.new()
    spb.size=Vector3(1.86,0.10,0.32)
    splitter.mesh=spb
    splitter.position=Vector3(0,0.50,-2.02)
    var split_mat:=StandardMaterial3D.new()
    split_mat.albedo_color=Color("#0B0E15")
    split_mat.metallic=0.45
    splitter.material_override=split_mat
    car.add_child(splitter)

    var spoiler:=MeshInstance3D.new()
    var sb:=BoxMesh.new()
    sb.size=Vector3(1.76,0.12,0.36)
    spoiler.mesh=sb
    spoiler.position=Vector3(0,1.23,1.72)
    spoiler.material_override=roof_mat
    car.add_child(spoiler)

    for sx in [-0.82,0.82]:
        for sz in [-1.35,1.35]:
            var wheel:=MeshInstance3D.new()
            var cm:=CylinderMesh.new()
            cm.height=0.34
            cm.top_radius=0.44
            cm.bottom_radius=0.44
            wheel.mesh=cm
            wheel.name="Wheel%s%s" % ["L" if sx<0 else "R","F" if sz<0 else "R"]
            wheel.position=Vector3(sx,0.38,sz)
            wheel.rotation.z=PI/2
            var wm:=StandardMaterial3D.new()
            wm.albedo_color=Color("#0B0E13")
            wm.metallic=0.32
            wm.roughness=0.48
            wheel.material_override=wm
            car.add_child(wheel)
            var hub:=MeshInstance3D.new()
            var hubm:=CylinderMesh.new()
            hubm.height=0.10
            hubm.top_radius=0.18
            hubm.bottom_radius=0.18
            hub.mesh=hubm
            hub.position=Vector3(sx + (0.18 if sx<0 else -0.18),0.38,sz)
            hub.rotation.z=PI/2
            var hub_mat:=StandardMaterial3D.new()
            hub_mat.albedo_color=Color("#C5CEDF")
            hub_mat.metallic=0.75
            hub.material_override=hub_mat
            car.add_child(hub)

    for sx in [-0.62,0.62]:
        var lamp:=MeshInstance3D.new()
        var lm:=BoxMesh.new()
        lm.size=Vector3(0.26,0.14,0.10)
        lamp.mesh=lm
        lamp.position=Vector3(sx,0.88,-2.05)
        var led:=StandardMaterial3D.new()
        led.albedo_color=Color("#E9FCFF")
        led.emission_enabled=true
        led.emission=Color("#83E6FF")
        led.emission_energy_multiplier=3.0
        lamp.material_override=led
        car.add_child(lamp)

        var tail:=MeshInstance3D.new()
        var tm:=BoxMesh.new()
        tm.size=Vector3(0.26,0.12,0.08)
        tail.mesh=tm
        tail.position=Vector3(sx,0.82,2.07)
        var tail_mat:=StandardMaterial3D.new()
        tail_mat.albedo_color=Color("#FF3D52")
        tail_mat.emission_enabled=true
        tail_mat.emission=Color("#FF3147")
        tail_mat.emission_energy_multiplier=1.7
        tail.material_override=tail_mat
        car.add_child(tail)

    var underglow:=MeshInstance3D.new()
    underglow.name="Underglow"
    var ugm:=BoxMesh.new()
    ugm.size=Vector3(1.55,0.03,3.10)
    underglow.mesh=ugm
    underglow.position=Vector3(0,0.26,0)
    var ugmat:=StandardMaterial3D.new()
    ugmat.albedo_color=body_color
    ugmat.emission_enabled=true
    ugmat.emission=body_color
    ugmat.emission_energy_multiplier=0.72
    underglow.material_override=ugmat
    car.add_child(underglow)

    for sx in [-1.0,1.0]:
        var mirror:=MeshInstance3D.new()
        var mm:=BoxMesh.new()
        mm.size=Vector3(0.22,0.16,0.42)
        mirror.mesh=mm
        mirror.position=Vector3(sx*1.10,1.05,-0.05)
        mirror.rotation_degrees.y=12.0*float(sx)
        mirror.material_override=roof_mat
        car.add_child(mirror)

    var flame:=MeshInstance3D.new()
    flame.name="BoostFlame"
    var fm:=BoxMesh.new()
    fm.size=Vector3(0.44,0.22,0.75)
    flame.mesh=fm
    flame.position=Vector3(0,0.72,2.42)
    flame.scale=Vector3(0.85,0.72,0.35)
    var fmat:=StandardMaterial3D.new()
    fmat.albedo_color=Color("#FF9B4A")
    fmat.emission_enabled=true
    fmat.emission=Color("#5DE9FF")
    fmat.emission_energy_multiplier=3.2
    flame.material_override=fmat
    flame.visible=false
    car.add_child(flame)
    car.set_meta("boost_flame",flame)

    var boost_light:=OmniLight3D.new()
    boost_light.name="BoostGlow"
    boost_light.position=Vector3(0,0.75,2.55)
    boost_light.light_energy=6.0
    boost_light.omni_range=5.0
    boost_light.light_color=Color("#32D8FF")
    boost_light.visible=false
    car.add_child(boost_light)
    car.set_meta("boost_glow",boost_light)

    var brake_glow:=MeshInstance3D.new()
    brake_glow.name="BrakeGlow"
    var bgm:=BoxMesh.new()
    bgm.size=Vector3(1.38,0.08,0.12)
    brake_glow.mesh=bgm
    brake_glow.position=Vector3(0,0.88,2.12)
    var bgmat:=StandardMaterial3D.new()
    bgmat.albedo_color=Color("#FF3147")
    bgmat.emission_enabled=true
    bgmat.emission=Color("#FF3147")
    bgmat.emission_energy_multiplier=2.6
    brake_glow.material_override=bgmat
    brake_glow.visible=false
    car.add_child(brake_glow)
    car.set_meta("brake_glow",brake_glow)

    return car

static func animate_wheels(vehicle:Node3D,speed:float,delta:float)->void:
    if not is_instance_valid(vehicle):return
    var spin:=speed*delta*0.95
    for wheel_name in ["WheelLF","WheelRF","WheelLR","WheelRR"]:
        var wheel:=vehicle.get_node_or_null(wheel_name)
        if wheel is Node3D:
            wheel.rotate_x(spin)
