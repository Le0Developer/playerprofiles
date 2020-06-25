if not plist then
  print("Please install playerlist.")
  return 
end
local json = loadstring([[local a={}local function b(c)if type(c)~='table'then return type(c)end;local d=1;for e in pairs(c)do if c[d]~=nil then d=d+1 else return'table'end end;if d==1 then return'table'else return'array'end end;local function f(g)local h={'\\','"','/','\b','\f','\n','\r','\t'}local i={'\\','"','/','b','f','n','r','t'}for d,j in ipairs(h)do g=g:gsub(j,'\\'..i[d])end;return g end;local function k(l,m,n,o)m=m+#l:match('^%s*',m)if l:sub(m,m)~=n then if o then error('Expected '..n..' near position '..m)end;return m,false end;return m+1,true end;local function p(l,m,q)q=q or''local r='End of input found while parsing string.'if m>#l then error(r)end;local j=l:sub(m,m)if j=='"'then return q,m+1 end;if j~='\\'then return p(l,m+1,q..j)end;local s={b='\b',f='\f',n='\n',r='\r',t='\t'}local t=l:sub(m+1,m+1)if not t then error(r)end;return p(l,m+2,q..(s[t]or t))end;local function u(l,m)local v=l:match('^-?%d+%.?%d*[eE]?[+-]?%d*',m)local q=tonumber(v)if not q then error('Error parsing number at position '..m..'.')end;return q,m+#v end;function a.stringify(c,w)local g={}local x=b(c)if x=='array'then if w then error('Can\'t encode array as key.')end;g[#g+1]='['for d,q in ipairs(c)do if d>1 then g[#g+1]=', 'end;g[#g+1]=a.stringify(q)end;g[#g+1]=']'elseif x=='table'then if w then error('Can\'t encode table as key.')end;g[#g+1]='{'for y,z in pairs(c)do if#g>1 then g[#g+1]=', 'end;g[#g+1]=a.stringify(y,true)g[#g+1]=':'g[#g+1]=a.stringify(z)end;g[#g+1]='}'elseif x=='string'then return'"'..f(c)..'"'elseif x=='number'then if w then return'"'..tostring(c)..'"'end;return tostring(c)elseif x=='boolean'then return tostring(c)elseif x=='nil'then return'null'else error('Unjsonifiable type: '..x..'.')end;return table.concat(g)end;a.null={}function a.parse(l,m,A)m=m or 1;if m>#l then error('Reached unexpected end of input.')end;local m=m+#l:match('^%s*',m)local B=l:sub(m,m)if B=='{'then local c,C,D={},true,true;m=m+1;while true do C,m=a.parse(l,m,'}')if C==nil then return c,m end;if not D then error('Comma missing between object items.')end;m=k(l,m,':',true)c[C],m=a.parse(l,m)m,D=k(l,m,',')end elseif B=='['then local E,q,D={},true,true;m=m+1;while true do q,m=a.parse(l,m,']')if q==nil then return E,m end;if not D then error('Comma missing between array items.')end;E[#E+1]=q;m,D=k(l,m,',')end elseif B=='"'then return p(l,m+1)elseif B=='-'or B:match('%d')then return u(l,m)elseif B==A then return nil,m+1 else local F={['true']=true,['false']=false,['null']=a.null}for G,H in pairs(F)do local I=m+#G-1;if l:sub(m,I)==G then return H,I+1 end end;local J='position '..m..': '..l:sub(m,m+10)error('Invalid json syntax starting at '..J)end end;return a]])()
local players = { }
local player_names = { }
local player_vis = { }
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
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #players do
        local v = players[_index_0]
        _accum_0[_len_0] = v.steam3_32bit
        _len_0 = _len_0 + 1
      end
      player_vis = _accum_0
    end
    do
      local _tbl_0 = { }
      for _index_0 = 1, #players do
        local v = players[_index_0]
        _tbl_0[v.steam3_32bit] = {
          v.username,
          v.username
        }
      end
      player_names = _tbl_0
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
local GUI_LIST = gui.Groupbox(GUI_TAB, "Player Profiles", 4, 4, 300, 0)
local GUI_LISTL = gui.Listbox(GUI_LIST, "players", 440, unpack((function()
  local _accum_0 = { }
  local _len_0 = 1
  for _index_0 = 1, #player_vis do
    local steam3_32bit = player_vis[_index_0]
    _accum_0[_len_0] = player_names[steam3_32bit][2]
    _len_0 = _len_0 + 1
  end
  return _accum_0
end)()))
local GUI_OPT = gui.Groupbox(GUI_TAB, "Options", 308, 4, 314, 0)
local GUI_OPT_OPEN, GUI_OPT_REMOVE
do
  local _with_0 = gui.Button(GUI_OPT, "Open Community Profile", function()
    local steam3_32bit = player_vis[GUI_LISTL:GetValue() + 1]
    local steam3_64bit = "7656" .. (0x116ebff0000 + steam3_32bit)
    print("[PLAYERPROFILES] Link to the profile: https://steamcommunity.com/profiles/" .. steam3_64bit)
    return panorama.RunScript("SteamOverlayAPI.OpenExternalBrowserURL( 'https://steamcommunity.com/profiles/" .. tostring(steam3_64bit) .. "' )")
  end)
  _with_0:SetWidth(280)
  GUI_OPT_OPEN = _with_0
end
do
  local _with_0 = gui.Button(GUI_OPT, "Remove", function()
    local steam3_32bit = player_vis[GUI_LISTL:GetValue() + 1]
    player_names[steam3_32bit] = nil
    table.remove(player_vis, GUI_LISTL:GetValue() + 1)
    for i, player in ipairs(players) do
      if player.steam3_32bit == steam3_32bit then
        table.remove(players, i)
        break
      end
    end
    save()
    GUI_LISTL:SetOptions(unpack((function()
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #player_vis do
        local steam3_32bit = player_vis[_index_0]
        _accum_0[_len_0] = player_names[steam3_32bit][2]
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)()))
    if #player_vis == 0 then
      GUI_OPT_OPEN:SetDisabled(true)
      return GUI_OPT_REMOVE:SetDisabled(true)
    end
  end)
  _with_0:SetWidth(280)
  GUI_OPT_REMOVE = _with_0
end
if #player_vis == 0 then
  GUI_OPT_OPEN:SetDisabled(true)
  GUI_OPT_REMOVE:SetDisabled(true)
end
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
  local steam3_64bit = "7656" .. (0x116ebff0000 + steam3_32bit)
  http.Get("https://steamcommunity.com/profiles/" .. steam3_64bit, function(resp)
    if resp:find("1 VAC ban on record") or resp:find("Multiple VAC bans on record") then
      player_names[steam3_32bit][2] = "[VAC] " .. player_names[steam3_32bit][1]
    elseif resp:find("1 game ban on record") or resp:find("Multiple game bans on record") then
      player_names[steam3_32bit][2] = "[OVERWATCH] " .. player_names[steam3_32bit][1]
    else
      player_names[steam3_32bit][2] = "[CLEAN] " .. player_names[steam3_32bit][1]
    end
    GUI_LISTL:SetOptions(unpack((function()
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #player_vis do
        local steam3_32bit = player_vis[_index_0]
        _accum_0[_len_0] = player_names[steam3_32bit][2]
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
  table.insert(player_vis, steam3_32bit)
  player_names[steam3_32bit] = {
    client.GetPlayerNameByUserID(userid),
    client.GetPlayerNameByUserID(userid)
  }
  UI_LISTL:SetOptions(unpack((function()
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #player_vis do
      local steam3_32bit = player_vis[_index_0]
      _accum_0[_len_0] = player_names[steam3_32bit][2]
      _len_0 = _len_0 + 1
    end
    return _accum_0
  end)()))
  fetch(steam3_32bit)
  if #player_vis == 1 then
    GUI_OPT_OPEN:SetDisabled(false)
    GUI_OPT_REMOVE:SetDisabled(false)
  end
  
end))
callbacks.Register("Unload", function()
  return plist.gui.Remove(btn)
end)

