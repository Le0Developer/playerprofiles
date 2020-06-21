
if not plist
    print "Please install playerlist."
    return

-- json lib
-- full code at https://gist.github.com/tylerneylon/59f4bcf316be525b30ab
json = loadstring[[local a={}local function b(c)if type(c)~='table'then return type(c)end;local d=1;for e in pairs(c)do if c[d]~=nil then d=d+1 else return'table'end end;if d==1 then return'table'else return'array'end end;local function f(g)local h={'\\','"','/','\b','\f','\n','\r','\t'}local i={'\\','"','/','b','f','n','r','t'}for d,j in ipairs(h)do g=g:gsub(j,'\\'..i[d])end;return g end;local function k(l,m,n,o)m=m+#l:match('^%s*',m)if l:sub(m,m)~=n then if o then error('Expected '..n..' near position '..m)end;return m,false end;return m+1,true end;local function p(l,m,q)q=q or''local r='End of input found while parsing string.'if m>#l then error(r)end;local j=l:sub(m,m)if j=='"'then return q,m+1 end;if j~='\\'then return p(l,m+1,q..j)end;local s={b='\b',f='\f',n='\n',r='\r',t='\t'}local t=l:sub(m+1,m+1)if not t then error(r)end;return p(l,m+2,q..(s[t]or t))end;local function u(l,m)local v=l:match('^-?%d+%.?%d*[eE]?[+-]?%d*',m)local q=tonumber(v)if not q then error('Error parsing number at position '..m..'.')end;return q,m+#v end;function a.stringify(c,w)local g={}local x=b(c)if x=='array'then if w then error('Can\'t encode array as key.')end;g[#g+1]='['for d,q in ipairs(c)do if d>1 then g[#g+1]=', 'end;g[#g+1]=a.stringify(q)end;g[#g+1]=']'elseif x=='table'then if w then error('Can\'t encode table as key.')end;g[#g+1]='{'for y,z in pairs(c)do if#g>1 then g[#g+1]=', 'end;g[#g+1]=a.stringify(y,true)g[#g+1]=':'g[#g+1]=a.stringify(z)end;g[#g+1]='}'elseif x=='string'then return'"'..f(c)..'"'elseif x=='number'then if w then return'"'..tostring(c)..'"'end;return tostring(c)elseif x=='boolean'then return tostring(c)elseif x=='nil'then return'null'else error('Unjsonifiable type: '..x..'.')end;return table.concat(g)end;a.null={}function a.parse(l,m,A)m=m or 1;if m>#l then error('Reached unexpected end of input.')end;local m=m+#l:match('^%s*',m)local B=l:sub(m,m)if B=='{'then local c,C,D={},true,true;m=m+1;while true do C,m=a.parse(l,m,'}')if C==nil then return c,m end;if not D then error('Comma missing between object items.')end;m=k(l,m,':',true)c[C],m=a.parse(l,m)m,D=k(l,m,',')end elseif B=='['then local E,q,D={},true,true;m=m+1;while true do q,m=a.parse(l,m,']')if q==nil then return E,m end;if not D then error('Comma missing between array items.')end;E[#E+1]=q;m,D=k(l,m,',')end elseif B=='"'then return p(l,m+1)elseif B=='-'or B:match('%d')then return u(l,m)elseif B==A then return nil,m+1 else local F={['true']=true,['false']=false,['null']=a.null}for G,H in pairs(F)do local I=m+#G-1;if l:sub(m,I)==G then return H,I+1 end end;local J='position '..m..': '..l:sub(m,m+10)error('Invalid json syntax starting at '..J)end end;return a]] !

players = {}
players_vis = {}
load = ->
    o = file.Open "player_profiles_save.dat", "r"
    if o
        local r
        with o
            r = \Read!
            \Close! 
        players = json.parse r
        players_vis = {k.steam3_32bit, k.username for k in *players}

save = ->
    with file.Open "player_profiles_save.dat", "w"
        \Write json.stringify players
        \Close!

load!

GUI_TAB = gui.Tab gui.Reference"Misc", "playerprofiles", "Player Profiles"
GUI_GP = gui.Groupbox GUI_TAB, "Player Profiles", 4, 4, 622, 0
GUI_LIST = gui.Listbox GUI_GP, "players", 440, unpack [v for _, v in pairs players_vis]

error_wrapper = (name, callback) ->
    ( ... ) ->
        ok = { pcall callback, ...  }
        if ok[ 1 ]
            return unpack( ok, 2 )
        print "#{name or '?'}(#{callback}) errored!"
        print ok[ 2 ]
fetch = error_wrapper "fetcher", (steam3_32bit) ->
    steam3_64bit = 0x110000100000000 + steam3_32bit
    http.Get "https://steamcommunity.com/profiles/" .. steam3_64bit, (resp) ->
        if resp\find"1 VAC ban on record" or resp\find"Multiple VAC bans on record"
            players_vis[ steam3_32bit ] = "[VAC] " .. players_vis[ steam3_32bit ]
        elseif resp\find"1 VAC ban on record" or resp\find"Multiple VAC bans on record"
            players_vis[ steam3_32bit ] = "[OVERWATCH] " .. players_vis[ steam3_32bit ]
        else
            players_vis[ steam3_32bit ] = "[CLEAN] " .. players_vis[ steam3_32bit ]
    
        GUI_LIST\SetOptions unpack [v for _, v in pairs players_vis]
        return "__REMOVE_ME__"
    return "__REMOVE_ME__"
    
for player in *players
    fetch player.steam3_32bit

btn = plist.gui.Button "Save Profile", error_wrapper "button", (userid) ->
    steam3_32bit = client.GetPlayerInfo( client.GetPlayerIndexByUserID userid )[ "SteamID" ]
    table.insert players, {
        username: client.GetPlayerNameByUserID userid,
        steam3_32bit: steam3_32bit
    }
    save!
    players_vis[ steam3_32bit ] = client.GetPlayerNameByUserID userid
    GUI_LIST\SetOptions unpack [v for _, v in pairs players_vis]
    fetch steam3_32bit
    return "__REMOVE_ME__"

callbacks.Register "Unload", ->
    plist.gui.Remove btn

return "__REMOVE_ME__"
