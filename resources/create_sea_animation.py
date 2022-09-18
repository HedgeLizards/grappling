#!/usr/bin/env python3
n = 48

print("""
[gd_resource type="AnimatedTexture" load_steps=4 format=2]

[ext_resource path="res://assets/sea/Sea00.png" type="Texture" id=1]
{res}

[resource]
flags = 4
frames = 3
fps = 6.0
frame_0/texture = ExtResource( 1 )
{frame}
""".format(
	res="\n".join('[ext_resource path="res://assets/sea/Sea{ind:0>2}.png" type="Texture" id={id}]'.format(ind=i, id=i+1) for i in range(1,n+1)),
	frame="\n".join('frame_{id}/texture = ExtResource( {res} )\nframe_{id}/delay_sec = 0'.format(res = i+1, id=i) for i in range(1,n+1))
))

