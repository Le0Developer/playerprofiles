if not plist then
  print("Please install playerlist.")
  return 
end
local json = loadstring([[local a={}local function b(c)if type(c)~='table'then return type(c)end;local d=1;for e in pairs(c)do if c[d]~=nil then d=d+1 else return'table'end end;if d==1 then return'table'else return'array'end end;local function f(g)local h={'\\','"','/','\b','\f','\n','\r','\t'}local i={'\\','"','/','b','f','n','r','t'}for d,j in ipairs(h)do g=g:gsub(j,'\\'..i[d])end;return g end;local function k(l,m,n,o)m=m+#l:match('^%s*',m)if l:sub(m,m)~=n then if o then error('Expected '..n..' near position '..m)end;return m,false end;return m+1,true end;local function p(l,m,q)q=q or''local r='End of input found while parsing string.'if m>#l then error(r)end;local j=l:sub(m,m)if j=='"'then return q,m+1 end;if j~='\\'then return p(l,m+1,q..j)end;local s={b='\b',f='\f',n='\n',r='\r',t='\t'}local t=l:sub(m+1,m+1)if not t then error(r)end;return p(l,m+2,q..(s[t]or t))end;local function u(l,m)local v=l:match('^-?%d+%.?%d*[eE]?[+-]?%d*',m)local q=tonumber(v)if not q then error('Error parsing number at position '..m..'.')end;return q,m+#v end;function a.stringify(c,w)local g={}local x=b(c)if x=='array'then if w then error('Can\'t encode array as key.')end;g[#g+1]='['for d,q in ipairs(c)do if d>1 then g[#g+1]=', 'end;g[#g+1]=a.stringify(q)end;g[#g+1]=']'elseif x=='table'then if w then error('Can\'t encode table as key.')end;g[#g+1]='{'for y,z in pairs(c)do if#g>1 then g[#g+1]=', 'end;g[#g+1]=a.stringify(y,true)g[#g+1]=':'g[#g+1]=a.stringify(z)end;g[#g+1]='}'elseif x=='string'then return'"'..f(c)..'"'elseif x=='number'then if w then return'"'..tostring(c)..'"'end;return tostring(c)elseif x=='boolean'then return tostring(c)elseif x=='nil'then return'null'else error('Unjsonifiable type: '..x..'.')end;return table.concat(g)end;a.null={}function a.parse(l,m,A)m=m or 1;if m>#l then error('Reached unexpected end of input.')end;local m=m+#l:match('^%s*',m)local B=l:sub(m,m)if B=='{'then local c,C,D={},true,true;m=m+1;while true do C,m=a.parse(l,m,'}')if C==nil then return c,m end;if not D then error('Comma missing between object items.')end;m=k(l,m,':',true)c[C],m=a.parse(l,m)m,D=k(l,m,',')end elseif B=='['then local E,q,D={},true,true;m=m+1;while true do q,m=a.parse(l,m,']')if q==nil then return E,m end;if not D then error('Comma missing between array items.')end;E[#E+1]=q;m,D=k(l,m,',')end elseif B=='"'then return p(l,m+1)elseif B=='-'or B:match('%d')then return u(l,m)elseif B==A then return nil,m+1 else local F={['true']=true,['false']=false,['null']=a.null}for G,H in pairs(F)do local I=m+#G-1;if l:sub(m,I)==G then return H,I+1 end end;local J='position '..m..': '..l:sub(m,m+10)error('Invalid json syntax starting at '..J)end end;return a]])()
local players = { }
local players_vis = { }
local load
load = function()
  local o = file.Open("player_profiles_save.dat", "r")
  if o then
    local r
    do
      r = o:Read()
      o:Close()
    end
    players = json.parse(r)
    do
      local _tbl_0 = { }
      for _index_0 = 1, #players do
        local k = players[_index_0]
        _tbl_0[k.steam3_32bit] = k.username
      end
      players_vis = _tbl_0
    end
  end
end
local save
save = function()
  do
    local _with_0 = file.Open("player_profiles_save.dat", "w")
    _with_0:Write(json.stringify(players))
    _with_0:Close()
    return _with_0
  end
end
load()
local GUI_TAB = gui.Tab(gui.Reference("Misc"), "playerprofiles", "Player Profiles")
local GUI_GP = gui.Groupbox(GUI_TAB, "Player Profiles", 4, 4, 622, 0)
local GUI_LIST = gui.Listbox(GUI_GP, "players", 440, unpack((function()
  local _accum_0 = { }
  local _len_0 = 1
  for _, v in pairs(players_vis) do
    _accum_0[_len_0] = v
    _len_0 = _len_0 + 1
  end
  return _accum_0
end)()))
local error_wrapper
error_wrapper = function(name, callback)
  return function(...)
    local ok = {
      pcall(callback, ...)
    }
    if ok[1] then
      return unpack(ok, 2)
    end
    print(tostring(name or '?') .. "(" .. tostring(callback) .. ") errored!")
    return print(ok[2])
  end
end
local fetch = error_wrapper("fetcher", function(steam3_32bit)
  local steam3_64bit = 0x110000100000000 + steam3_32bit
  http.Get("https://steamcommunity.com/profiles/" .. steam3_64bit, function(resp)
    if resp:find("1 VAC ban on record") or resp:find("Multiple VAC bans on record") then
      players_vis[steam3_32bit] = "[VAC] " .. players_vis[steam3_32bit]
    elseif resp:find("1 VAC ban on record") or resp:find("Multiple VAC bans on record") then
      players_vis[steam3_32bit] = "[OVERWATCH] " .. players_vis[steam3_32bit]
    else
      players_vis[steam3_32bit] = "[CLEAN] " .. players_vis[steam3_32bit]
    end
    GUI_LIST:SetOptions(unpack((function()
      local _accum_0 = { }
      local _len_0 = 1
      for _, v in pairs(players_vis) do
        _accum_0[_len_0] = v
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()))
    
  end)
  
end)
for _index_0 = 1, #players do
  local player = players[_index_0]
  fetch(player.steam3_32bit)
end
local btn = plist.gui.Button("Save Profile", error_wrapper("button", function(userid)
  local steam3_32bit = client.GetPlayerInfo(client.GetPlayerIndexByUserID(userid))["SteamID"]
  table.insert(players, {
    username = client.GetPlayerNameByUserID(userid),
    steam3_32bit = steam3_32bit
  })
  save()
  players_vis[steam3_32bit] = client.GetPlayerNameByUserID(userid)
  GUI_LIST:SetOptions(unpack((function()
    local _accum_0 = { }
    local _len_0 = 1
    for _, v in pairs(players_vis) do
      _accum_0[_len_0] = v
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end)()))
  fetch(steam3_32bit)
  
end))
callbacks.Register("Unload", function()
  return plist.gui.Remove(btn)
end)

