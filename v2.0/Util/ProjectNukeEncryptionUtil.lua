--[[

================================================================================

  ProjectNukeEncryptionUtil
    Provides SHA256 Encryption abilities.

================================================================================

  Author: Unknown

--]]
local MOD = 2^32
local MODM = MOD-1

local function memoize(f)
	local mt = {}
	local t = setmetatable({}, mt)
	function mt:__index(k)
		local v = f(k)
		t[k] = v
		return v
	end
	return t
end

local function make_bitop_uncached(t, m)
	local function bitop(a, b)
		local res,p = 0,1
		while a ~= 0 and b ~= 0 do
			local am, bm = a % m, b % m
			res = res + t[am][bm] * p
			a = (a - am) / m
			b = (b - bm) / m
			p = p*m
		end
		res = res + (a + b) * p
		return res
	end
	return bitop
end

local function make_bitop(t)
	local op1 = make_bitop_uncached(t,2^1)
	local op2 = memoize(function(a) return memoize(function(b) return op1(a, b) end) end)
	return make_bitop_uncached(op2, 2 ^ (t.n or 1))
end

local bxor1 = make_bitop({[0] = {[0] = 0,[1] = 1}, [1] = {[0] = 1, [1] = 0}, n = 4})

local function bxor(a, b, c, ...)
	local z = nil
	if b then
		a = a % MOD
		b = b % MOD
		z = bxor1(a, b)
		if c then z = bxor(z, c, ...) end
		return z
	elseif a then return a % MOD
	else return 0 end
end

local function band(a, b, c, ...)
	local z
	if b then
		a = a % MOD
		b = b % MOD
		z = ((a + b) - bxor1(a,b)) / 2
		if c then z = bit32_band(z, c, ...) end
		return z
	elseif a then return a % MOD
	else return MODM end
end

local function bnot(x) return (-1 - x) % MOD end

local function rshift1(a, disp)
	if disp < 0 then return lshift(a,-disp) end
	return math.floor(a % 2 ^ 32 / 2 ^ disp)
end

local function rshift(x, disp)
	if disp > 31 or disp < -31 then return 0 end
	return rshift1(x % MOD, disp)
end

local function lshift(a, disp)
	if disp < 0 then return rshift(a,-disp) end 
	return (a * 2 ^ disp) % 2 ^ 32
end

local function rrotate(x, disp)
    x = x % MOD
    disp = disp % 32
    local low = band(x, 2 ^ disp - 1)
    return rshift(x, disp) + lshift(low, 32 - disp)
end

local k = {
	0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
	0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
	0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
	0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
	0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
	0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
	0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
	0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
	0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
	0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
	0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
	0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
	0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
	0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
	0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
	0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
}

local function str2hexa(s)
	return (string.gsub(s, ".", function(c) return string.format("%02x", string.byte(c)) end))
end

local function num2s(l, n)
	local s = ""
	for i = 1, n do
		local rem = l % 256
		s = string.char(rem) .. s
		l = (l - rem) / 256
	end
	return s
end

local function s232num(s, i)
	local n = 0
	for i = i, i + 3 do n = n*256 + string.byte(s, i) end
	return n
end

local function preproc(msg, len)
	local extra = 64 - ((len + 9) % 64)
	len = num2s(8 * len, 8)
	msg = msg .. "\128" .. string.rep("\0", extra) .. len
	assert(#msg % 64 == 0)
	return msg
end

local function initH256(H)
	H[1] = 0x6a09e667
	H[2] = 0xbb67ae85
	H[3] = 0x3c6ef372
	H[4] = 0xa54ff53a
	H[5] = 0x510e527f
	H[6] = 0x9b05688c
	H[7] = 0x1f83d9ab
	H[8] = 0x5be0cd19
	return H
end

local function digestblock(msg, i, H)
	local w = {}
	for j = 1, 16 do w[j] = s232num(msg, i + (j - 1)*4) end
	for j = 17, 64 do
		local v = w[j - 15]
		local s0 = bxor(rrotate(v, 7), rrotate(v, 18), rshift(v, 3))
		v = w[j - 2]
		w[j] = w[j - 16] + s0 + w[j - 7] + bxor(rrotate(v, 17), rrotate(v, 19), rshift(v, 10))
	end

	local a, b, c, d, e, f, g, h = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
	for i = 1, 64 do
		local s0 = bxor(rrotate(a, 2), rrotate(a, 13), rrotate(a, 22))
		local maj = bxor(band(a, b), band(a, c), band(b, c))
		local t2 = s0 + maj
		local s1 = bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25))
		local ch = bxor (band(e, f), band(bnot(e), g))
		local t1 = h + s1 + ch + k[i] + w[i]
		h, g, f, e, d, c, b, a = g, f, e, d + t1, c, b, a, t1 + t2
	end

	H[1] = band(H[1] + a)
	H[2] = band(H[2] + b)
	H[3] = band(H[3] + c)
	H[4] = band(H[4] + d)
	H[5] = band(H[5] + e)
	H[6] = band(H[6] + f)
	H[7] = band(H[7] + g)
	H[8] = band(H[8] + h)
end

function SHA256(msg)
	msg = preproc(msg, #msg)
	local H = initH256({})
	for i = 1, #msg, 64 do digestblock(msg, i, H) end
	return str2hexa(num2s(H[1], 4) .. num2s(H[2], 4) .. num2s(H[3], 4) .. num2s(H[4], 4) ..
		num2s(H[5], 4) .. num2s(H[6], 4) .. num2s(H[7], 4) .. num2s(H[8], 4))
end


-- 
-- https://gist.githubusercontent.com/SquidDev/86925e07cbabd70773e53d781bd8b2fe/raw/ccea5f652cc33a979de02d6e0fe193db0c5bdfb1/aeslua.min.lua
--

local function e(n)
local s=setmetatable({},{__index=_ENV or getfenv()})if setfenv then setfenv(n,s)end;return n(s)or s end
local t=e(function(n,...)local s=math.floor;local h,r
r=function(d,l)return s(d%4294967296/2^l)end
h=function(d,l)return(d*2^l)%4294967296 end
return{bnot=bit.bnot,band=bit.band,bor=bit.bor,bxor=bit.bxor,rshift=r,lshift=h}end)
local a=e(function(n,...)local s=t.bxor;local h=t.lshift;local r=0x100;local d=0xff;local l=0x11b;local u={}local c={}
local function m(k,q)return s(k,q)end;local function f(k,q)return s(k,q)end
local function w(k)if(k==1)then return 1 end;local q=d-c[k]return u[q]end;local function y(k,q)if(k==0 or q==0)then return 0 end;local j=c[k]+c[q]
if(j>=d)then j=j-d end;return u[j]end
local function p(k,q)
if(k==0)then return 0 end;local j=c[k]-c[q]if(j<0)then j=j+d end;return u[j]end
local function v()for k=1,r do print("log(",k-1,")=",c[k-1])end end
local function b()for k=1,r do print("exp(",k-1,")=",u[k-1])end end;local function g()local k=1
for q=0,d-1 do u[q]=k;c[k]=q;k=s(h(k,1),k)if k>d then k=f(k,l)end end end;g()return
{add=m,sub=f,invert=w,mul=y,div=dib,printLog=v,printExp=b}end)
util=e(function(n,...)local s=t.bxor;local h=t.rshift;local r=t.band;local d=t.lshift;local l;local function u(O)O=s(O,h(O,4))
O=s(O,h(O,2))O=s(O,h(O,1))return r(O,1)end
local function c(O,I)if(I==0)then return
r(O,0xff)else return r(h(O,I*8),0xff)end end;local function m(O,I)
if(I==0)then return r(O,0xff)else return d(r(O,0xff),I*8)end end
local function f(O,I,N)local S={}
for H=0,N-1 do
S[H+1]=
m(O[I+ (H*4)],3)+m(O[I+ (H*4)+1],2)+
m(O[I+ (H*4)+2],1)+m(O[I+ (H*4)+3],0)if N%10000 ==0 then l()end end;return S end;local function w(O,I,N,S)S=S or#O;for H=0,S-1 do
for R=0,3 do I[N+H*4+ (3-R)]=c(O[H+1],R)end;if S%10000 ==0 then l()end end
return I end;local function y(O)local I=""
for N,S in
ipairs(O)do I=I..string.format("%02x ",S)end;return I end
local function p(O)local I={}for N=1,#O,2 do I[#I+1]=tonumber(O:sub(N,
N+1),16)end;return I end
local function v(O)local I=type(O)
if(I=="number")then return string.format("%08x",O)elseif
(I=="table")then return y(O)elseif(I=="string")then local N={string.byte(O,1,#O)}
return y(N)else return O end end
local function b(O)local I=#O;local N=math.random(0,255)local S=math.random(0,255)
local H=string.char(N,S,N,S,c(I,3),c(I,2),c(I,1),c(I,0))O=H..O;local R=math.ceil(#O/16)*16-#O;local D=""for L=1,R do D=D..
string.char(math.random(0,255))end;return O..D end
local function g(O)local I={string.byte(O,1,4)}if
(I[1]==I[3]and I[2]==I[4])then return true end;return false end
local function k(O)if(not g(O))then return nil end
local I=
m(string.byte(O,5),3)+
m(string.byte(O,6),2)+m(string.byte(O,7),1)+m(string.byte(O,8),0)return string.sub(O,9,8+I)end;local function q(O,I)for N=1,16 do O[N]=s(O[N],I[N])end end
local function j(O)
local I=16;while true do local N=O[I]+1
if N>=256 then O[I]=N-256;I=(I-2)%16+1 else O[I]=N;break end end end;local x,z,_=os.queueEvent,coroutine.yield,os.time;local E=_()
local function l()local O=_()if O-E>=0.03 then E=O
x("sleep")z("sleep")end end
local function T(O)local I,N,S,H=string.char,math.random,l,table.insert;local R={}for D=1,O do
H(R,N(0,255))if D%10240 ==0 then S()end end;return R end
local function A(O)local I,N,S,H=string.char,math.random,l,table.insert;local R={}for D=1,O do
H(R,I(N(0,255)))if D%10240 ==0 then S()end end
return table.concat(R)end
return
{byteParity=u,getByte=c,putByte=m,bytesToInts=f,intsToBytes=w,bytesToHex=y,hexToBytes=p,toHexString=v,padByteString=b,properlyDecrypted=g,unpadByteString=k,xorIV=q,increment=j,sleepCheckIn=l,getRandomData=T,getRandomString=A}end)
aes=e(function(n,...)local s=util.putByte;local h=util.getByte;local r='rounds'local d="type"local l=1;local u=2
local c={}local m={}local f={}local w={}local y={}local p={}local v={}local b={}local g={}local k={}
local q={0x01000000,0x02000000,0x04000000,0x08000000,0x10000000,0x20000000,0x40000000,0x80000000,0x1b000000,0x36000000,0x6c000000,0xd8000000,0xab000000,0x4d000000,0x9a000000,0x2f000000}
local function j(M)mask=0xf8;result=0
for F=1,8 do result=t.lshift(result,1)
parity=util.byteParity(t.band(M,mask))result=result+parity;lastbit=t.band(mask,1)
mask=t.band(t.rshift(mask,1),0xff)
if(lastbit~=0)then mask=t.bor(mask,0x80)else mask=t.band(mask,0x7f)end end;return t.bxor(result,0x63)end;local function x()
for M=0,255 do if(M~=0)then inverse=a.invert(M)else inverse=M end
mapped=j(inverse)c[M]=mapped;m[mapped]=M end end
local function z()
for M=0,255 do
byte=c[M]
f[M]=
s(a.mul(0x03,byte),0)+s(byte,1)+s(byte,2)+s(a.mul(0x02,byte),3)w[M]=s(byte,0)+s(byte,1)+s(a.mul(0x02,byte),2)+
s(a.mul(0x03,byte),3)y[M]=

s(byte,0)+s(a.mul(0x02,byte),1)+s(a.mul(0x03,byte),2)+s(byte,3)p[M]=

s(a.mul(0x02,byte),0)+s(a.mul(0x03,byte),1)+s(byte,2)+s(byte,3)end end
local function _()
for M=0,255 do byte=m[M]
v[M]=
s(a.mul(0x0b,byte),0)+s(a.mul(0x0d,byte),1)+s(a.mul(0x09,byte),2)+
s(a.mul(0x0e,byte),3)
b[M]=
s(a.mul(0x0d,byte),0)+s(a.mul(0x09,byte),1)+s(a.mul(0x0e,byte),2)+
s(a.mul(0x0b,byte),3)
g[M]=
s(a.mul(0x09,byte),0)+s(a.mul(0x0e,byte),1)+s(a.mul(0x0b,byte),2)+
s(a.mul(0x0d,byte),3)
k[M]=
s(a.mul(0x0e,byte),0)+s(a.mul(0x0b,byte),1)+s(a.mul(0x0d,byte),2)+
s(a.mul(0x09,byte),3)end end;local function E(M)local F=t.band(M,0xff000000)return
(t.lshift(M,8)+t.rshift(F,24))end
local function T(M)return
s(c[h(M,0)],0)+s(c[h(M,1)],1)+s(c[h(M,2)],2)+
s(c[h(M,3)],3)end
local function A(M)local F={}local W=math.floor(#M/4)if(
(W~=4 and W~=6 and W~=8)or(W*4 ~=#M))then
error("Invalid key size: "..tostring(W))return nil end;F[r]=W+6;F[d]=l;for Y=0,W-1
do
F[Y]=
s(M[Y*4+1],3)+s(M[Y*4+2],2)+s(M[Y*4+3],1)+s(M[Y*4+4],0)end
for Y=W,(F[r]+1)*4-1 do
local P=F[Y-1]
if(Y%W==0)then P=E(P)P=T(P)local V=math.floor(Y/W)P=t.bxor(P,q[V])elseif(
W>6 and Y%W==4)then P=T(P)end;F[Y]=t.bxor(F[(Y-W)],P)end;return F end
local function O(M)local F=h(M,3)local W=h(M,2)local Y=h(M,1)local P=h(M,0)
return



s(a.add(a.add(a.add(a.mul(0x0b,W),a.mul(0x0d,Y)),a.mul(0x09,P)),a.mul(0x0e,F)),3)+
s(a.add(a.add(a.add(a.mul(0x0b,Y),a.mul(0x0d,P)),a.mul(0x09,F)),a.mul(0x0e,W)),2)+
s(a.add(a.add(a.add(a.mul(0x0b,P),a.mul(0x0d,F)),a.mul(0x09,W)),a.mul(0x0e,Y)),1)+
s(a.add(a.add(a.add(a.mul(0x0b,F),a.mul(0x0d,W)),a.mul(0x09,Y)),a.mul(0x0e,P)),0)end
local function I(M)local F=h(M,3)local W=h(M,2)local Y=h(M,1)local P=h(M,0)local V=t.bxor(P,Y)
local B=t.bxor(W,F)local G=t.bxor(V,B)G=t.bxor(G,a.mul(0x08,G))
w=t.bxor(G,a.mul(0x04,t.bxor(Y,F)))G=t.bxor(G,a.mul(0x04,t.bxor(P,W)))
return


s(t.bxor(t.bxor(P,G),a.mul(0x02,t.bxor(F,P))),0)+s(t.bxor(t.bxor(Y,w),a.mul(0x02,V)),1)+
s(t.bxor(t.bxor(W,G),a.mul(0x02,t.bxor(F,P))),2)+
s(t.bxor(t.bxor(F,w),a.mul(0x02,B)),3)end
local function N(M)local F=A(M)if(F==nil)then return nil end;F[d]=u;for W=4,(F[r]+1)*4-5 do
F[W]=O(F[W])end;return F end;local function S(M,F,W)
for Y=0,3 do M[Y+1]=t.bxor(M[Y+1],F[W*4+Y])end end
local function H(M,F)
F[1]=t.bxor(t.bxor(t.bxor(f[h(M[1],3)],w[h(M[2],2)]),y[h(M[3],1)]),p[h(M[4],0)])
F[2]=t.bxor(t.bxor(t.bxor(f[h(M[2],3)],w[h(M[3],2)]),y[h(M[4],1)]),p[h(M[1],0)])
F[3]=t.bxor(t.bxor(t.bxor(f[h(M[3],3)],w[h(M[4],2)]),y[h(M[1],1)]),p[h(M[2],0)])
F[4]=t.bxor(t.bxor(t.bxor(f[h(M[4],3)],w[h(M[1],2)]),y[h(M[2],1)]),p[h(M[3],0)])end
local function R(M,F)
F[1]=s(c[h(M[1],3)],3)+s(c[h(M[2],2)],2)+
s(c[h(M[3],1)],1)+s(c[h(M[4],0)],0)
F[2]=s(c[h(M[2],3)],3)+s(c[h(M[3],2)],2)+
s(c[h(M[4],1)],1)+s(c[h(M[1],0)],0)
F[3]=s(c[h(M[3],3)],3)+s(c[h(M[4],2)],2)+
s(c[h(M[1],1)],1)+s(c[h(M[2],0)],0)
F[4]=s(c[h(M[4],3)],3)+s(c[h(M[1],2)],2)+
s(c[h(M[2],1)],1)+s(c[h(M[3],0)],0)end
local function D(M,F)
F[1]=t.bxor(t.bxor(t.bxor(v[h(M[1],3)],b[h(M[4],2)]),g[h(M[3],1)]),k[h(M[2],0)])
F[2]=t.bxor(t.bxor(t.bxor(v[h(M[2],3)],b[h(M[1],2)]),g[h(M[4],1)]),k[h(M[3],0)])
F[3]=t.bxor(t.bxor(t.bxor(v[h(M[3],3)],b[h(M[2],2)]),g[h(M[1],1)]),k[h(M[4],0)])
F[4]=t.bxor(t.bxor(t.bxor(v[h(M[4],3)],b[h(M[3],2)]),g[h(M[2],1)]),k[h(M[1],0)])end
local function L(M,F)
F[1]=s(m[h(M[1],3)],3)+s(m[h(M[4],2)],2)+
s(m[h(M[3],1)],1)+s(m[h(M[2],0)],0)
F[2]=s(m[h(M[2],3)],3)+s(m[h(M[1],2)],2)+
s(m[h(M[4],1)],1)+s(m[h(M[3],0)],0)
F[3]=s(m[h(M[3],3)],3)+s(m[h(M[2],2)],2)+
s(m[h(M[1],1)],1)+s(m[h(M[4],0)],0)
F[4]=s(m[h(M[4],3)],3)+s(m[h(M[3],2)],2)+
s(m[h(M[2],1)],1)+s(m[h(M[1],0)],0)end
local function U(M,F,W,Y,P)W=W or 1;Y=Y or{}P=P or 1;local V={}local B={}if(M[d]~=l)then
error("No encryption key: "..
tostring(M[d])..", expected "..l)return end
V=util.bytesToInts(F,W,4)S(V,M,0)local G=1;while(G<M[r]-1)do H(V,B)S(B,M,G)G=G+1;H(B,V)S(V,M,G)
G=G+1 end;H(V,B)S(B,M,G)G=G+1;R(B,V)S(V,M,G)
util.sleepCheckIn()return util.intsToBytes(V,Y,P)end
local function C(M,F,W,Y,P)W=W or 1;Y=Y or{}P=P or 1;local V={}local B={}
if(M[d]~=u)then error("No decryption key: "..
tostring(M[d]))return end;V=util.bytesToInts(F,W,4)S(V,M,M[r])local G=M[r]-1;while(G>2)do
D(V,B)S(B,M,G)G=G-1;D(B,V)S(V,M,G)G=G-1 end;D(V,B)
S(B,M,G)G=G-1;L(B,V)S(V,M,G)util.sleepCheckIn()return
util.intsToBytes(V,Y,P)end;x()z()_()
return{ROUNDS=r,KEY_TYPE=d,ENCRYPTION_KEY=l,DECRYPTION_KEY=u,expandEncryptionKey=A,expandDecryptionKey=N,encrypt=U,decrypt=C}end)
local o=e(function(n,...)local function s()return{}end;local function h(d,l)table.insert(d,l)end;local function r(d)return
table.concat(d)end;return{new=s,addString=h,toString=r}end)
ciphermode=e(function(n,...)local s={}local h=math.random
function s.encryptString(r,d,l,u)if u then local f={}for w=1,16 do f[w]=u[w]end;u=f else
u={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}end
local c=aes.expandEncryptionKey(r)local m=o.new()for f=1,#d/16 do local w=(f-1)*16+1
local y={string.byte(d,w,w+15)}u=l(c,y,u)
o.addString(m,string.char(unpack(y)))end
return o.toString(m)end;function s.encryptECB(r,d,l)aes.encrypt(r,d,1,d,1)end;function s.encryptCBC(r,d,l)
util.xorIV(d,l)aes.encrypt(r,d,1,d,1)return d end;function s.encryptOFB(r,d,l)
aes.encrypt(r,l,1,l,1)util.xorIV(d,l)return l end;function s.encryptCFB(r,d,l)
aes.encrypt(r,l,1,l,1)util.xorIV(d,l)return d end
function s.encryptCTR(r,d,l)
local u={}for c=1,16 do u[c]=l[c]end;aes.encrypt(r,l,1,l,1)
util.xorIV(d,l)util.increment(u)return u end
function s.decryptString(r,d,l,u)if u then local f={}for w=1,16 do f[w]=u[w]end;u=f else
u={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}end;local c
if l==s.decryptOFB or
l==s.decryptCFB or l==s.decryptCTR then
c=aes.expandEncryptionKey(r)else c=aes.expandDecryptionKey(r)end;local m=o.new()for f=1,#d/16 do local w=(f-1)*16+1
local y={string.byte(d,w,w+15)}u=l(c,y,u)
o.addString(m,string.char(unpack(y)))end
return o.toString(m)end;function s.decryptECB(r,d,l)aes.decrypt(r,d,1,d,1)return l end;function s.decryptCBC(r,d,l)
local u={}for c=1,16 do u[c]=d[c]end;aes.decrypt(r,d,1,d,1)
util.xorIV(d,l)return u end;function s.decryptOFB(r,d,l)
aes.encrypt(r,l,1,l,1)util.xorIV(d,l)return l end;function s.decryptCFB(r,d,l)
local u={}for c=1,16 do u[c]=d[c]end;aes.encrypt(r,l,1,l,1)
util.xorIV(d,l)return u end
s.decryptCTR=s.encryptCTR;return s end)AES128=16;AES192=24;AES256=32;ECBMODE=1;CBCMODE=2;OFBMODE=3;CFBMODE=4;CTRMODE=4
local function i(n,s,h)local r=s;if(s==
AES192)then r=32 end
if(r>#n)then local l=""for u=1,r-#n do
l=l..string.char(0)end;n=n..l else n=string.sub(n,1,r)end;local d={string.byte(n,1,#n)}
n=ciphermode.encryptString(d,n,ciphermode.encryptCBC,h)n=string.sub(n,1,s)return{string.byte(n,1,#n)}end
function encrypt(n,s,h,r,d)assert(n~=nil,"Empty password.")
assert(n~=nil,"Empty data.")local r=r or CBCMODE;local h=h or AES128;local l=i(n,h,d)
local u=util.padByteString(s)
if r==ECBMODE then
return ciphermode.encryptString(l,u,ciphermode.encryptECB,d)elseif r==CBCMODE then
return ciphermode.encryptString(l,u,ciphermode.encryptCBC,d)elseif r==OFBMODE then
return ciphermode.encryptString(l,u,ciphermode.encryptOFB,d)elseif r==CFBMODE then
return ciphermode.encryptString(l,u,ciphermode.encryptCFB,d)elseif r==CTRMODE then
return ciphermode.encryptString(l,u,ciphermode.encryptCTR,d)else error("Unknown mode",2)end end
function decrypt(n,s,h,r,d)local r=r or CBCMODE;local h=h or AES128;local l=i(n,h,d)local u
if r==ECBMODE then
u=ciphermode.decryptString(l,s,ciphermode.decryptECB,d)elseif r==CBCMODE then
u=ciphermode.decryptString(l,s,ciphermode.decryptCBC,d)elseif r==OFBMODE then
u=ciphermode.decryptString(l,s,ciphermode.decryptOFB,d)elseif r==CFBMODE then
u=ciphermode.decryptString(l,s,ciphermode.decryptCFB,d)elseif r==CTRMODE then
u=ciphermode.decryptString(l,s,ciphermode.decryptCTR,d)else error("Unknown mode",2)end;result=util.unpadByteString(u)
if(result==nil)then return nil end;return result end