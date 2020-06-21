if not plist then print("Please install playerlist.")return end local e=loadstring([[local a={}local function b(c)if type(c)~='table'then return type(c)end;local d=1;for e in pairs(c)do if c[d]~=nil then d=d+1 else return'table'end end;if d==1 then return'table'else return'array'end end;local function f(g)local h={'\\','"','/','\b','\f','\n','\r','\t'}local i={'\\','"','/','b','f','n','r','t'}for d,j in ipairs(h)do g=g:gsub(j,'\\'..i[d])end;return g end;local function k(l,m,n,o)m=m+#l:match('^%s*',m)if l:sub(m,m)~=n then if o then error('Expected '..n..' near position '..m)end;return m,false end;return m+1,true end;local function p(l,m,q)q=q or''local r='End of input found while parsing string.'if m>#l then error(r)end;local j=l:sub(m,m)if j=='"'then return q,m+1 end;if j~='\\'then return p(l,m+1,q..j)end;local s={b='\b',f='\f',n='\n',r='\r',t='\t'}local t=l:sub(m+1,m+1)if not t then error(r)end;return p(l,m+2,q..(s[t]or t))end;local function u(l,m)local v=l:match('^-?%d+%.?%d*[eE]?[+-]?%d*',m)local q=tonumber(v)if not q then error('Error parsing number at position '..m..'.')end;return q,m+#v end;function a.stringify(c,w)local g={}local x=b(c)if x=='array'then if w then error('Can\'t encode array as key.')end;g[#g+1]='['for d,q in ipairs(c)do if d>1 then g[#g+1]=', 'end;g[#g+1]=a.stringify(q)end;g[#g+1]=']'elseif x=='table'then if w then error('Can\'t encode table as key.')end;g[#g+1]='{'for y,z in pairs(c)do if#g>1 then g[#g+1]=', 'end;g[#g+1]=a.stringify(y,true)g[#g+1]=':'g[#g+1]=a.stringify(z)end;g[#g+1]='}'elseif x=='string'then return'"'..f(c)..'"'elseif x=='number'then if w then return'"'..tostring(c)..'"'end;return tostring(c)elseif x=='boolean'then return tostring(c)elseif x=='nil'then return'null'else error('Unjsonifiable type: '..x..'.')end;return table.concat(g)end;a.null={}function a.parse(l,m,A)m=m or 1;if m>#l then error('Reached unexpected end of input.')end;local m=m+#l:match('^%s*',m)local B=l:sub(m,m)if B=='{'then local c,C,D={},true,true;m=m+1;while true do C,m=a.parse(l,m,'}')if C==nil then return c,m end;if not D then error('Comma missing between object items.')end;m=k(l,m,':',true)c[C],m=a.parse(l,m)m,D=k(l,m,',')end elseif B=='['then local E,q,D={},true,true;m=m+1;while true do q,m=a.parse(l,m,']')if q==nil then return E,m end;if not D then error('Comma missing between array items.')end;E[#E+1]=q;m,D=k(l,m,',')end elseif B=='"'then return p(l,m+1)elseif B=='-'or B:match('%d')then return u(l,m)elseif B==A then return nil,m+1 else local F={['true']=true,['false']=false,['null']=a.null}for G,H in pairs(F)do local I=m+#G-1;if l:sub(m,I)==G then return H,I+1 end end;local J='position '..m..': '..l:sub(m,m+10)error('Invalid json syntax starting at '..J)end end;return a]])()local t={}local a={}local o o=function()local u=file.Open("player_profiles_save.dat","r")if u then local c do c=u:Read()u:Close()end t=e.parse(c)do local m={}for f=1,#t do local w=t[f]m[w.steam3_32bit]=w.username end a=m end end end local i i=function()do local u=file.Open("player_profiles_save.dat","w")u:Write(e.stringify(t))u:Close()return u end end o()local n=gui.Tab(gui.Reference("Misc"),"playerprofiles","Player Profiles")local s=gui.Groupbox(n,"Player Profiles",4,4,622,0)local h=gui.Listbox(s,"players",440,unpack((function()local u={}local c=1 for m,f in pairs(a)do u[c]=f c=c+1 end return u end)()))local r r=function(u,c)return function(...)local m={pcall(c,...)}if m[1]then return unpack(m,2)end print(tostring(u or'?').."("..tostring(c)..") errored!")return print(m[2])end end local d=r("fetcher",function(u)local c=0x110000100000000+u http.Get("https://steamcommunity.com/profiles/"..c,function(m)if m:find("1 VAC ban on record")or m:find("Multiple VAC bans on record")then a[u]="[VAC] "..a[u]elseif m:find("1 VAC ban on record")or m:find("Multiple VAC bans on record")then a[u]="[OVERWATCH] "..a[u]else a[u]="[CLEAN] "..a[u]end h:SetOptions(unpack((function()local f={}local w=1 for y,p in pairs(a)do f[w]=p w=w+1 end return f end)()))end)end)for u=1,#t do local c=t[u]d(c.steam3_32bit)end local l=plist.gui.Button("Save Profile",r("button",function(u)local c=client.GetPlayerInfo(client.GetPlayerIndexByUserID(u))["SteamID"]table.insert(t,{username=client.GetPlayerNameByUserID(u),steam3_32bit=c})i()a[c]=client.GetPlayerNameByUserID(u)h:SetOptions(unpack((function()local m={}local f=1 for w,y in pairs(a)do m[f]=y f=f+1 end return m end)()))d(c)end))callbacks.Register("Unload",function()return plist.gui.Remove(l)end)