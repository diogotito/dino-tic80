-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua


-- Geometry

verts = {{-1, -1, -1},
         { 1, -1, -1},
         {-1,  1, -1},
         { 1,  1, -1},
         {-1, -1,  1},
         { 1, -1,  1},
         {-1,  1,  1},
         { 1,  1,  1}}

UVs = {{ 8,  0},
       {24,  0},
       { 8, 16},
       {24, 16}}

function mktri(i1,j1, i2,j2, i3,j3)
	return {
		verts={verts[i1],verts[i2],verts[i3]},
		uvs={UVs[j1],UVs[j2],UVs[j3]}
	}
end

cube_tris={
	-- front face
	mktri(1,1, 2,2, 3,3),
	mktri(2,2, 4,4, 3,3),
	-- right face
	mktri(2,1, 6,2, 4,3),
	mktri(4,3, 8,4, 6,2),
	-- back face
	mktri(5,2, 6,1, 7,4),
	mktri(6,1, 8,3, 7,4),
	-- left face
	mktri(1,2, 5,1, 3,4),
	mktri(3,4, 7,3, 5,1),
	-- top face
	mktri(5,1, 6,2, 1,3),
	mktri(6,2, 2,4, 1,3),
	--bottom face
	mktri(7,2, 8,1, 3,4),
	mktri(8,1, 4,3, 3,4),
}


-- 3D maths!

pi = math.pi
sin, cos = math.sin, math.cos

function transform(verts,
                   rotX, rotY, rotZ,
                   sX, sY, sZ,
                   tX, tY, tZ)
	-- rotation sines and cosines
	local sinX,cosX = sin(rotX),cos(rotX)
	local sinY,cosY = sin(rotY),cos(rotY)
	local sinZ,cosZ = sin(rotZ),cos(rotZ)

	for _, v in ipairs(verts) do
		-- unpack vertex to nice variables
		local vx,vy,vz = table.unpack(v)
		-- rotate on X
		vy,vz =  vy*cosX - vz*sinX,
		         vy*sinX + vz*cosX
		-- rotate on Y
		vx,vz =  vx*cosY + vz*sinY,
		        -vx*sinY + vz*cosY
		-- rotate on Z
		vx,vy =  vx*cosZ - vy*sinZ,
		         vx*sinZ + vy*cosZ
		-- scale
		vx = sX * vx
		vy = sY * vy
		vz = sZ * vz
		-- perspective!
		vz = vz + tZ
		local persp = vz / 100 -- idk rly
		vx, vy = vx/persp, vy/persp
		-- translate
		vx = vx + tX
		vy = vy + tY
		-- update vertex coordinates
		v[1],v[2],v[3] = vx,vy,vz
	end
end

function render_tri(t)
	ttri(t.verts[1][1], t.verts[1][2],
	     t.verts[2][1], t.verts[2][2],
	     t.verts[3][1], t.verts[3][2],
	     t.uvs[1][1], t.uvs[1][2],
	     t.uvs[2][1], t.uvs[2][2],
	     t.uvs[3][1], t.uvs[3][2],
	     0, -- read from SPRITES RAM
	     {14}, -- chromakey
	     t.verts[1][3], -- z1
	     t.verts[2][3], -- z2
	     t.verts[3][3]) -- z3
end


-- Complement Lua's standard library

function deepcopy(t)
	local new={}
	for k,v in pairs(t) do
		if type(v)=="table" then
			new[k]=deepcopy(v)
		else
			new[k]=v
		end
	end
	return new
end
--[[
function cat_tbls(...)
	local tbls, cat = {...}, {}
	for _, t in ipairs(tbls) do
		table.move(t,1,#t, #cat+1,cat)
	end
	return cat
end
--]]
function dump_tbl(t, i)
	i = i or 0
	local out = {tostring(t)}
	for k,v in pairs(t) do
		out[#out+1] = ("[%s]=%s"):format(
				k,
				(type(v)=="table")
					and dump_tbl(v, i+1)
					or v)
	end
	local indent = string.rep(" ", i)
	return indent ..
			table.concat(out, "\n "..indent)
end


-- Game loop

t=0
x=96
y=60
z=100

function TIC()

	if btn(0) then y=y-1 end
	if btn(1) then y=y+1 end
	if btn(2) then x=x-1 end
	if btn(3) then x=x+1 end
	if btn(4) then z=z+1 end
	if btn(5) then z=z-1 end

	local a = t / 60 * 2*pi
	local rX,rY,rZ = .1*a, .25*a, .35*a

	local scn_tris  = {}
	local scn_verts = {}

	for _, t in ipairs(cube_tris) do
		local tt = deepcopy(t)
		table.insert(scn_tris, tt)
		table.move(tt.verts, 1, 3,
				#scn_verts + 1, scn_verts)
	end

	transform(scn_verts,
	          rX, rY, rZ,
	          20, 20, 20,
	          x, y, z)

	cls(0)
	for _, t in ipairs(scn_tris) do
		render_tri(t)
	end

	t=t+1
end

-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

