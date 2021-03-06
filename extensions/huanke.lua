module("extensions.huanke", package.seeall)
extension = sgs.Package("huanke")
EnableLog = true
-----------------------------------
zhouyongliang=sgs.General(extension, "zhouyongliang", "qun", "3")
dingjinjian=sgs.General(extension, "dingjinjian", "qun", "4")
wangkewei=sgs.General(extension, "wangkewei", "qun", "3")
shengjianfeng=sgs.General(extension, "shengjianfeng", "qun", "3")
taoqiuping=sgs.General(extension, "taoqiuping", "qun", "3", false)
sunchanchan=sgs.General(extension, "sunchanchan", "qun", "3", false)
tangqiaozhi=sgs.General(extension, "tangqiaozhi", "qun", "3")
xiezhe=sgs.General(extension, "xiezhe$", "qun", "3")
laiwenfeng=sgs.General(extension, "laiwenfeng$", "qun", "4")
konghaidong=sgs.General(extension, "konghaidong", "qun", "3")
chenxusheng=sgs.General(extension, "chenxusheng", "qun", "3")
------------------------------------
function newMessage(logtype,from,to,arg)
	local log = sgs.LogMessage()
	log.type = logtype
	log.from = from
	log.to:append(to)
	log.arg = arg
	return log
end
--[[
name名加#开头使技能名不显示，但依然运行
name名加$结尾表示主公时显示，非主公不显示，但是依然是运行的

]]


--写
local f=io.open("debug.log","w")
f:close()
function writeLog(str)
	if EnableLog then
		local f=io.open("debug.log","a+")
		f:write(str .. "\n")
		f:flush()
		f:close()
	end
end
--[[

]]
-------------------------------------
------------------------------------周永亮
--人物卡牌 image\generals\card\zhouyongliang.jpg
--头像 image\generals\avatar\zhouyongliang.jpg
luameinan_card = sgs.CreateSkillCard
{--美男技能卡 
	name = "luameinan", --for translation key
	target_fixed = false,--需要手动选择目标
	will_throw = true,--卡牌会进入弃牌堆
	once = true,--主动发动，每回合一次
	
	filter = function(self, targets, to_select, player)
		if(#targets >= 1) then return false end	--already select 0
		return (not to_select:getGeneral():isMale()) and to_select:isWounded()
	end,
	
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		
		local recov = sgs.RecoverStruct()
		recov.recover = 1
		recov.card = self
		recov.who = effect.from
		
		room:recover(effect.from, recov)
		room:recover(effect.to, recov)
		
		room:broadcastSkillInvoke("luameinan") --play audio
		--setEmotion可动画
		room:setPlayerFlag(effect.from, "luameinan-used")
	end
}

luameinan = sgs.CreateViewAsSkill
{--美男 
	name = "luameinan",
	n = 2,
	
	enabled_at_play = function()
		return not sgs.Self:hasFlag("luameinan-used")
	end,
	
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	
	view_as = function(self, cards)
		if #cards ~= 2 then return nil end
		local new_card = luameinan_card:clone()
		new_card:addSubcard(cards[1])
		new_card:addSubcard(cards[2])
		new_card:setSkillName(self:objectName())
		return new_card
	end
}

luayongliang_card = sgs.CreateSkillCard
{--永亮技能卡 
	name = "luayongliang", --for translation key
	target_fixed = false,
	will_throw = true,
	once = true,
	
	filter = function(self, targets, to_select, player)
		if(#targets >= 1) then return false end
		return (player:distanceTo(to_select) <= 1)
	end,
	
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		
		room:showAllCards(effect.to, effect.from) --展示所有卡牌，第一个参数给第二个参数看
		
		room:broadcastSkillInvoke("luayongliang")
		--room:setPlayerFlag(effect.from, "luayongliang-used")
	end
}

luayongliang = sgs.CreateViewAsSkill
{--永亮
	name = "luayongliang",
	n = 0,
	
	enabled_at_play = function()
		return true
		--return not sgs.Self:hasFlag("luayongliang-used")
	end,
	
	view_filter = function(self, selected, to_select)
		return true
	end,
	
	view_as = function(self, cards)
		if #cards ~= 0 then return nil end
		local new_card = luayongliang_card:clone()
		new_card:setSkillName(self:objectName())
		return new_card
	end
}

zhouyongliang:addSkill(luameinan)
zhouyongliang:addSkill(luayongliang)
--------------------------------------
--丁JJ
luaxuexi_buff = sgs.CreateTriggerSkill
{--学习的生效
	name = "#luaxuexiBuff",
	events = {sgs.Predamage},
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local xuexiStateKey = "xuexistate"
		--room:askForSkillInvoke(player, "luoyi") -- leave for test
		if((player:getMark(xuexiStateKey) == 2) and player:isAlive()) then
			local damage = data:toDamage()
			local room = player:getRoom()
			local reason = damage.card
			if(not reason) then return false end
			if(reason:inherits("Slash") or reason:inherits("Duel")) then
				local log = newMessage("#luaxuexiBuff",player,damage.to,damage.damage +1)
				room:sendLog(log)
				room:broadcastSkillInvoke("luaxuexi")
				damage.damage = damage.damage+1
				data:setValue(damage)
				return false --反回true就不会完成扣血操作
			end
		else
			return false
		end
	end
}

luaxuexi = sgs.CreateTriggerSkill
{--学习
	name = "luaxuexi",	
	events = {sgs.AfterDrawNCards },
	
	on_trigger = function(self, event, player, data)
		local xuexiStateKey = "xuexistate"
		local room = player:getRoom()
		
		if( player:getMark(xuexiStateKey)==1) then
			player:setMark(xuexiStateKey, 2)
		else
			if (room:askForSkillInvoke(player, "luaxuexi")) then	
				room:broadcastSkillInvoke("luaxuexi")
				player:setMark(xuexiStateKey, 1)
			else
				player:setMark(xuexiStateKey, 0)
			end
		end

	end
}

luaxuexiskip = sgs.CreateTriggerSkill
{--学习跳过出牌
	name = "#luaxuexiskip",	
	events = {sgs.EventPhaseChanging },
	
	on_trigger = function(self, event, player, data)
		local xuexiStateKey = "xuexistate"
		local room = player:getRoom()
		local change=data:toPhaseChange()
		if((change.to==sgs.Player_Play) and (player:getMark(xuexiStateKey)==1)) then
			return true --跳过出牌阶段

		end

	end
}


dingjinjian:addSkill(luaxuexi)
dingjinjian:addSkill(luaxuexi_buff)
dingjinjian:addSkill(luaxuexiskip)
-------------------------------------
--王科伟

luaweinan_kill = sgs.CreateTriggerSkill
{--猥男被杀
	name = "#luaweinan_kill",
	events = {sgs.SlashEffected ,sgs.DamageInflicted},
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local weinanStateKey = "weinanstate"
		if((player:getMark(weinanStateKey) == 1) and player:isAlive()) then
			if event == sgs.DamageInflicted then
				--room:askForSkillInvoke(player, "luoyiA") -- leave for test
				local damage=data:toDamage()
				local card = damage.card
				if (card:inherits("Slash")) then
					local log = newMessage("#luaweinan_kill",damage.from,player,damage.damage +1)
					room:sendLog(log)
					room:broadcastSkillInvoke("luaweinan")
					damage.damage = damage.damage+1
					data:setValue(damage)
				end	
			elseif(event == sgs.SlashEffected ) then
				--room:askForSkillInvoke(player, "luoyiB") -- leave for test
				local effect=data:toSlashEffect()
				if not effect.from:getGeneral():isMale() then
					room:slashResult(effect,nil)
					room:broadcastSkillInvoke("luaweinan")
					return true
				end 
		
			end
		
		end		

	end
}

luaweinan_aoe = sgs.CreateTriggerSkill
{--猥男aoe和决斗无效
	name = "#luaweinan_aoe",
	events = {sgs.CardEffected},
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local weinanStateKey = "weinanstate"
		--room:askForSkillInvoke(player, "luoyi") -- leave for test
		if((player:getMark(weinanStateKey) == 1) and player:isAlive()) then
			local effect = data:toCardEffect()
			if (effect.card:inherits("AOE") or effect.card:inherits("Duel")) then
				room:broadcastSkillInvoke("luaweinan")
				return true 
			end

		end
	end
}

luaweinan = sgs.CreateTriggerSkill
{--猥男
	name = "luaweinan",	
	events = {sgs.AfterDrawNCards},
	
	on_trigger = function(self, event, player, data)
		local weinanStateKey = "weinanstate"
		local room = player:getRoom()		

		if (room:askForSkillInvoke(player, "luaweinan")) then
			room:broadcastSkillInvoke("luaweinan")
			player:setMark(weinanStateKey, 1)
		else
			player:setMark(weinanStateKey, 0)
		end

	end
}

luachaiji = sgs.CreateViewAsSkill
{--拆机
	name = "luachaiji",
	n = 1,
	
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	
	view_as = function(self, cards)
		if #cards == 1 then
			local card = cards[1]
			local new_card =sgs.Sanguosha:cloneCard("dismantlement", card:getSuit(), card:getNumber())
			new_card:addSubcard(card:getId())
			new_card:setSkillName(self:objectName())
			return new_card
		end
	end
}


wangkewei:addSkill(luaweinan)
wangkewei:addSkill(luaweinan_aoe)
wangkewei:addSkill(luaweinan_kill)
wangkewei:addSkill(luachaiji)
--------------------------------------

luadengdu_card = sgs.CreateSkillCard
{--邓读
	name = "luadengdu", --for translation key
	target_fixed = false,
	will_throw = true,
	once = true,
	
	filter = function(self, targets, to_select, player)
		if(#targets >= 1) then return false end
		return (player:distanceTo(to_select) <= 1)
	end,
	
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		
		room:showAllCards(effect.to, effect.from) --展示所有卡牌，第一个参数给第二个参数看
		
		room:broadcastSkillInvoke("luadengdu")
		room:setPlayerFlag(effect.from, "luadengdu-used")
	end
}

luadengdu = sgs.CreateViewAsSkill
{--邓读
	name = "luadengdu",
	n = 0,
	
	enabled_at_play = function()
		return not sgs.Self:hasFlag("luadengdu-used")
	end,
	
	view_filter = function(self, selected, to_select)
		return true
	end,
	
	view_as = function(self, cards)
		if #cards ~= 0 then return nil end
		local new_card = luadengdu_card:clone()
		new_card:setSkillName(self:objectName())
		return new_card
	end
}


luaxibu = sgs.CreateTargetModSkill
{--西部
	name = "luaxibu" ,
	pattern = "TrickCard" ,
	distance_limit_func = function(self, player, card)
		if player:hasSkill(self:objectName()) then
			return 1000
		end
	end
}


shengjianfeng:addSkill(luadengdu)
shengjianfeng:addSkill(luaxibu)
--------------------------------------

luaguike = sgs.CreateTriggerSkill
{--龟壳
	name = "luaguike",
	events = {sgs.SlashEffected},
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local effect=data:toSlashEffect()
		room:broadcastSkillInvoke("luaguike")
		local ask_card = room:askForCard(effect.from,"slash", "@luaguikedoublekill")
		if ask_card then
			return false
		else
			return true
		end

	end
}

luaguisu = sgs.CreateDistanceSkill
{--龟速
	name = "luaguisu",
	
	correct_func = function(self, from, to)
		if from:hasSkill(self:objectName()) then
			return -1
		elseif to:hasSkill(self:objectName()) then
			return -1
		else
			return 0
		end

	end
}

taoqiuping:addSkill(luaguike)
taoqiuping:addSkill(luaguisu)
--------------------------------------


newDuel = function()
	return sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
end
luafanjiancard = sgs.CreateSkillCard{
	name = "luafanjiancard" ,
	target_fixed = false ,
	will_throw = true ,
	filter = function(self, targets, to_select)
		if not to_select:isMale() then return false end
		if #targets == 0 then
			return true
		elseif #targets == 1 then
			local duel = newDuel()
			if to_select:isProhibited(targets[1], duel, targets[1]:getSiblings()) then return false end
			if to_select:isCardLimited(duel, sgs.Card_MethodUse) then return false end
			return true
		elseif #targets == 2 then
			return false
		end
	end ,
	feasible = function(self, targets)
		if #targets ~= 2 then return false end
		self:setUserString(targets[2]:objectName())  --标记决斗发起方
		return true
	end ,
	on_use = function(self, room, source, targets)
		local LijianSource
		local LijianTarget
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:hasFlag("LuaLijianServerDuelSource") then
				LijianSource = p
				writeLog("find juedou source")
				p:setFlags("-LuaLijianServerDuelSource")
			elseif p:hasFlag("LuaLijianServerDuelTarget") then
				LijianTarget = p
				writeLog("find juedou target")
				p:setFlags("-LuaLijianServerDuelTarget")
			end
		end
		if (not LijianSource) or (not LijianTarget) then return end
		local duel = newDuel()
		duel:toTrick():setCancelable(false)
		duel:setSkillName(duel:objectName())
		room:broadcastSkillInvoke("luafanjian")
		room:useCard(sgs.CardUseStruct(duel, LijianSource, LijianTarget, false))
	end ,
	on_validate = function(self, cardUse)
		if not self:getUserString() then return nil end
		local room = cardUse.from:getRoom()
		local duelSourceName = self:getUserString()
		local duelSource = nil
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:objectName() == duelSourceName then
				duelSource = p
				break
			end
		end
		if not duelSource then return nil end
		local duelSourceFlag = false
		for _, p in sgs.qlist(cardUse.to) do
			if p:objectName() == duelSource:objectName() then
				p:setFlags("LuaLijianServerDuelSource")
				writeLog("set juedou source")
				duelSourceFlag = true
			else
				writeLog("find juedou target")
				p:setFlags("LuaLijianServerDuelTarget")
			end
		end
		if not duelSourceFlag then
			for _, p in sgs.qlist(cardUse.to) do
				p:setFlags("-LuaLijianServerDuelTarget")
			end
			return nil
		else
			return self
		end
	end
}
luafanjian = sgs.CreateViewAsSkill{
	name = "luafanjian" ,
	n = 0 ,
	view_filter = function(self, cards, to_select)
		return true
	end ,
	view_as = function(self, cards)
		local card = luafanjiancard:clone()
		return card
	end ,
	enabled_at_play = function(self, target)
		return not target:hasUsed("#luafanjiancard")
	end
}
--
luashuqiancard = sgs.CreateSkillCard{
	name = "luashuqiancard" ,
	target_fixed = false ,
	will_throw = true ,
	filter = function(self, targets, to_select, owner)
		local selfCardCount = owner:getCardCount(false,false)
		local toSelectCardCount = to_select:getCardCount(false,false)
		if (#targets == 0) and (selfCardCount < toSelectCardCount) then
			writeLog("luashuqiancard " .. tostring(selfCardCount) .. " < " .. tostring(toSelectCardCount))
			return true
		else
			return false 
		end
	end ,
	on_effect = function(self, effect)
		local from = effect.from
		local to = effect.to
		local room = from:getRoom()
		writeLog("luashuqian " .. self:objectName())
		local selfCardCount = from:getCardCount(false,false)
		local toSelectCardCount = to:getCardCount(false,false)
		room:broadcastSkillInvoke("luashuqian")
		for a=1,(toSelectCardCount - selfCardCount),1 do
			local card_id = room:askForCardChosen(from, to, "h", self:objectName())
			room:throwCard(card_id, to)
			writeLog(card_id)
		end

	end
}

luashuqian = sgs.CreateViewAsSkill{
	name = "luashuqian" ,
	n = 0,
	view_filter = function(self, cards, to_select)
		return true
	end ,
	view_as = function(self, cards)
		local card = luashuqiancard:clone()
		return card
	end ,
	enabled_at_play = function(self, target)
		return not target:hasUsed("#luashuqiancard")
	end
	
}

sunchanchan:addSkill(luafanjian)
sunchanchan:addSkill(luashuqian)
--------------------------------------
luachongqian = sgs.CreateTriggerSkill
{--充钱,另一部分在师兄技能中实现，因为和师兄技能在同一个event中触发
	name = "luachongqian",	
	events = { sgs.AfterDrawInitialCards},
	
	on_trigger = function(self, event, player, data)
		writeLog("luachongqian.sgs.AfterDrawInitialCards.ontrigger")	
		local chongqiankey="chongqianenable"
		player:setMark(chongqiankey,1)
	end
}

luashixiong = sgs.CreateTriggerSkill
{--师兄
	name = "luashixiong",	
	events = {sgs.AfterDrawNCards },
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local chongqiankey="chongqianenable"
		if (1 == player:getMark(chongqiankey)) then
			player:drawCards(1)
			room:broadcastSkillInvoke("luachongqian")
			writeLog("luachongqian.sgs.AfterDrawNCards.ontrigger!")
		end

		if (room:askForSkillInvoke(player, "luashixiong")) then
			room:broadcastSkillInvoke("luashixiong")
			local num = 2
			--[[
			for i=1,num,1 do
				local card2 = room:askForCard(player,".","@luashixiong",data,sgs.Card_MethodNone) 
				if card2 then
					player:obtainCard(card2)
				else
					break
				end
			end
			]]
			for _,ply in sgs.qlist(room:getOtherPlayers(player)) do
				writeLog("shixiong trigger!" .. ply:screenName())

				if(not ply:isMale()) then 
					for i=1,num,1 do
						local card = room:askForCard(ply,".","@luashixiong",data,sgs.Card_MethodNone)
						if card then
							player:obtainCard(card)
						else
							break
						end
					end
				end
			
			end
			
		
		end
	end
}

tangqiaozhi:addSkill(luachongqian)
tangqiaozhi:addSkill(luashixiong)
--------------------------------------

luabuzuiBuff = sgs.CreateTargetModSkill
{--不醉生效
	name = "#luabuzuiBuff",
	pattern = "Slash",
	residue_func = function(self,player)
		local buzuistatekey = "buzuistate"
		if player:hasSkill(self:objectName()) and (1==player:getMark(buzuistatekey)) then
			writeLog("luabuzuiBuff.forever kill")
			return 900
		else
			return 0
		end
	end
}


luabuzui = sgs.CreateTriggerSkill
{--不醉
	name = "luabuzui",	
	events = {sgs.AfterDrawNCards },
	
	on_trigger = function(self, event, player, data)
		writeLog("luabuzui.on_trigger")
		local buzuistatekey = "buzuistate"
		local room = player:getRoom()
		
		if( player:getMark(buzuistatekey)==1) then
			writeLog("luabuzui.shouldSkipPlay")
			room:setPlayerMark(player, buzuistatekey, 2)
		else
			if (room:askForSkillInvoke(player, "luabuzui")) then	
				room:broadcastSkillInvoke("luabuzui")
				writeLog("luabuzui.ok to startluabuzui")
				room:setPlayerMark(player, buzuistatekey, 1)
			else
				writeLog("luabuzui.No to skipluabuzui")
				room:setPlayerMark(player, buzuistatekey, 0)
			end
		end


	end
}

luabuzuiskip = sgs.CreateTriggerSkill
{--不醉跳过出牌
	name = "#luabuzuiskip",	
	events = {sgs.EventPhaseChanging },
	frequency=sgs.Skill_Compulsory,
	priority=0,
	on_trigger = function(self, event, player, data)
		writeLog("#luabuzuiskip.on_trigger")
		local buzuistatekey = "buzuistate"
		local room = player:getRoom()
		local change=data:toPhaseChange()
		if((change.to==sgs.Player_Play) and (player:getMark(buzuistatekey)==2)) then
			room:broadcastSkillInvoke("luabuzui")
			writeLog("#luabuzuiskip.skipPlay")
			return true --跳过出牌阶段
		end				

	end
}


luayuenv = sgs.CreateProhibitSkill
{--阅女
	name = "luayuenv",
	is_prohibited = function(self, from, to, card)
		if( (to:hasSkill("luayuenv")) and  (card:inherits("TrickCard")) and (not from:getGeneral():isMale()) )then
			writeLog("sgs.CreateProhibitSkill.yuenv")
			return true
		end
	end,
}

luazaotacard = sgs.CreateSkillCard
{--糟蹋技能卡 ，与美男技能卡相同，
	name = "luazaotacard", --for translation key
	target_fixed = false,--需要手动选择目标
	will_throw = true,--卡牌会进入弃牌堆
	once = true,--主动发动，每回合一次
	
	filter = function(self, targets, to_select, player)
		if(#targets >= 1) then return false end	--already select 0
		return true --(not to_select:getGeneral():isMale())
	end,
	
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		
		local recov = sgs.RecoverStruct()
		recov.recover = 1
		recov.card = self
		recov.who = effect.from		
		room:recover(effect.from, recov)

		--[[
		这个方法掉血后没学也不会死
		local recovTo = sgs.RecoverStruct()
		recovTo.recover = -2
		recovTo.card = self
		recovTo.who = effect.from		
		room:recover(effect.to, recovTo)		
		]]
		local damage = sgs.DamageStruct()
		damage.from = effect.from
		damage.to = effect.to
		damage.damage = 1
		damage.card = self		
		room:damage(damage)
		
		room:broadcastSkillInvoke("luazaota") --play audio
		--setEmotion可动画
		room:setPlayerFlag(effect.from, "luazaota-used")
	end
}

luazaota = sgs.CreateViewAsSkill
{--糟蹋
	name = "luazaota$",
	--name = "luazaota",
	n = 1,
	
	enabled_at_play = function(self, player)
		local zaotastate = "zaotastate"
		writeLog("luazaotaaction.enabled_at_play,"..tostring(player:getMark(zaotastate)).."   "..tostring(not sgs.Self:hasFlag("luazaota-used")))
		return (player:getMark(zaotastate) == 1) and (not player:hasFlag("luazaota-used"))
	end,
	
	view_filter = function(self, selected, to_select)
		return (#selected == 0 and to_select:isKindOf("EquipCard"))	--装备牌
	end,
	
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local new_card = luazaotacard:clone()
		new_card:addSubcard(cards[1])
		new_card:setSkillName(self:objectName())
		return new_card
	end
}

luazaotaaction = sgs.CreateTriggerSkill
{	
	name = "#luazaotaaction$",	
	--name = "#luazaotaaction$",	
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		writeLog("sgs.CreateTriggerSkill.luazaotaaction")
		local room = player:getRoom()
		if(not player:isLord()) then 
			return false
		end
		local zaotastate = "zaotastate"
		if (room:askForSkillInvoke(player, "luazaota")) then
			local x = data:toInt()
			writeLog("sgs.CreateTriggerSkill.luazaotaaction.invoke,skip card " .. tostring(x))
			data:setValue(0)			
			--player:setMark(zaotastate,1)
			room:setPlayerMark(player, zaotastate, 1)
		else
			--player:setMark(zaotastate,0)
			room:setPlayerMark(player, zaotastate, 0)
		end
	end
}

xiezhe:addSkill(luabuzui)
xiezhe:addSkill(luabuzuiskip)
xiezhe:addSkill(luabuzuiBuff)

xiezhe:addSkill(luayuenv)

xiezhe:addSkill(luazaota)
xiezhe:addSkill(luazaotaaction)
--------------------------------------

luachoujin_card = sgs.CreateSkillCard
{--抽筋技能卡 
	name = "luachoujin", --for translation key
	target_fixed = true,
	will_throw = false,
	
	on_use = function(self, room, source, targets)
		room:loseHp(source)
		room:broadcastSkillInvoke("luachoujin") --play audio
		if(source:isAlive()) then
			room:drawCards(source, 2)
		end
	end,
	
	enabled_at_play = function()
		return true
	end
}

luachoujin = sgs.CreateViewAsSkill
{--抽筋 
	name = "luachoujin",
	n = 0,
	
	enabled_at_play = function()
		local selfHP = sgs.Self:getHp();
		writeLog("luachoujin now HP=" .. tostring(selfHP))
		return selfHP <= 2
	end,
	
	view_as = function(self, cards)
		local card = luachoujin_card:clone()
		card:setSkillName(self:objectName())
		return card
	end
}

luashualai_card = sgs.CreateSkillCard
{--耍赖
	name = "luashualai", --for translation key
	target_fixed = false,--需要手动选择目标
	will_throw = false,--卡牌会进入弃牌堆
	once = true,--主动发动，每回合一次
	
	filter = function(self, targets, to_select, player)
		if(#targets >= 1) then return false end	--already select 0
		return (player:distanceTo(to_select) < 2) and (to_select:hasEquip())
	end,
	
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		local from = effect.from
		local to = effect.to		
		writeLog("luashualai_card.select getCard")
		local card_id = room:askForCardChosen(from, to, "e", "luashualai")
		writeLog("luashualai_card.after select Card")
		room:obtainCard(from, card_id)
		writeLog("luashualai_card.getCard")
		room:broadcastSkillInvoke("luashualai") --play audio
		--setEmotion可动画
		room:setPlayerFlag(effect.from, "luashualai-used")
	end
}

luashualai = sgs.CreateViewAsSkill
{--耍赖
	name = "luashualai$",
	n = 0,
	
	enabled_at_play = function()
		return (not sgs.Self:hasFlag("luashualai-used"))
	end,
	
	view_as = function(self, cards)
		local card = luashualai_card:clone()
		card:setSkillName(self:objectName())
		return card
	end
}



laiwenfeng:addSkill(luachoujin)
laiwenfeng:addSkill(luashualai)
--------------------------------------

luachengguancard = sgs.CreateSkillCard{
	name = "luachengguancard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if (#targets >= 2) or (to_select:objectName() == sgs.Self:objectName()) or (to_select:getCardCount(false,false) <= 0) then
			return false
		end
		return true
	end,
	on_use = function(self, room, source, targets)
		local maxSelectedCard = 3
		room:broadcastSkillInvoke("luachengguan") --play audio
		for i=1,maxSelectedCard,1 do
			local toSel = sgs.SPlayerList()
			toSel:append(source)
			if(targets[2]) and (targets[2]:getCardCount(false,false) > 0) then
				toSel:append(targets[2])
			end
			if(targets[1]) and (targets[1]:getCardCount(false,false) > 0) then
				toSel:append(targets[1])
			end
			--
			writeLog("luachengguancard.select player")
			local playerTo = room:askForPlayerChosen(source, toSel, "luachengguan","@chengguanchosetips")
			if(playerTo:objectName() == source:objectName()) then
				writeLog("luachengguancard.skip select")
				break
			end
			writeLog("luachengguancard.select card")
			local card_id = room:askForCardChosen(source, playerTo, "h", "luachengguan")
			writeLog("luachengguancard.get card")
			room:obtainCard(source, card_id)
			writeLog("luachengguancard.have select around")
		end
		
	end
}
luachengguanvs = sgs.CreateViewAsSkill{
	name = "luachengguan",
	n = 0,
	view_as = function(self, cards)
		return luachengguancard:clone()
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		writeLog("pattern->".. pattern)
		return pattern == "@@luachengguanpattern"
	end
}

luachengguan = sgs.CreateTriggerSkill{
	name = "luachengguan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = luachengguanvs,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Draw then
			local room = player:getRoom()
			local can_invoke = false
			local other_players = room:getOtherPlayers(player)
			for _,target in sgs.qlist(other_players) do
				if target:getCardCount(false,false) > 0 then
					can_invoke = true
					break;
				end
			end
			if can_invoke then
				if room:askForUseCard(player, "@@luachengguanpattern", "@invokeluachengguanask") then
					return true
				end
			end
		end
		return false
	end
}
---

luazhuxicard = sgs.CreateSkillCard{
	name = "luazhuxicard" ,
	filter = function(self, targets, to_select)
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		local plist = sgs.PlayerList()
		for i = 1, #targets, 1 do
			plist:append(targets[i])
		end
		return slash:targetFilter(plist, to_select, sgs.Self)
	end ,
	on_validate = function(self, cardUse) 
		cardUse.m_isOwnerUse = false
		local liubei = cardUse.from
		local targets = cardUse.to
		room = liubei:getRoom()
		local slash = nil
		local others = room:getOtherPlayers(liubei)
		--for _, target in sgs.qlist(targets) do
			--target:setFlags("luazhuxitarget")
		--end
		room:broadcastSkillInvoke("luazhuxi") --play audio
		for _, liege in sgs.qlist(others) do
			slash = room:askForCard(liege, "slash", "@luazhuxi-slash:" .. liubei:objectName(), sgs.QVariant(), sgs.Card_MethodResponse, liubei) --未处理胆守
			if slash then
				--for _, target in sgs.qlist(targets) do
					--target:setFlags("-luazhuxitarget")
				--end
				return slash
			end
		end
		--for _, target in sgs.qlist(targets) do
			--target:setFlags("-luazhuxitarget")
		--end
		room:setPlayerFlag(liubei, "luazhuxi_failed")
		return nil
	end
}

luazhuxivs = sgs.CreateViewAsSkill{
	name = "luazhuxi" ,
	n = 0 ,
	view_as = function()
		return luazhuxicard:clone()
	end ,
	enabled_at_play = function(self, player)
		return player:hasSkill("luazhuxi")
		   and (not player:hasFlag("luazhuxi_failed"))
		   and sgs.Slash_IsAvailable(player)
	end ,
	enabled_at_response = function(self, player, pattern)
		return player:hasSkill("luazhuxi")
		   and ((pattern == "slash") or (pattern == "@luazhuxi"))
		   and (sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE)
		   and (not player:hasFlag("luazhuxi_failed"))
	end
}

luazhuxi = sgs.CreateTriggerSkill{
	name = "luazhuxi" ,
	events = {sgs.CardAsked} ,
	view_as_skill = luazhuxivs ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local pattern = data:toStringList()[1]
		local prompt = data:toStringList()[2]
		if (pattern ~= "slash") then return false end
		local others = room:getOtherPlayers(player)
		if others:isEmpty() then return false end
		room:broadcastSkillInvoke("luazhuxi") --play audio
		if not room:askForSkillInvoke(player, self:objectName(), data) then return false end
		for _, liege in sgs.qlist(others) do
			local slash = room:askForCard(liege, "slash", "@luazhuxi-slash:" .. player:objectName(), sgs.QVariant(), sgs.Card_MethodResponse, player)
			if slash then
				room:provide(slash)
				return true
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target and target:hasSkill("luazhuxi")
	end
}

konghaidong:addSkill(luachengguan)
konghaidong:addSkill(luazhuxi)
--------------------------------------

luashushu = sgs.CreateTriggerSkill
{
	name = "luashushu",
	events = {sgs.CardAsked},
	on_trigger = function(self,event,player,data)
		writeLog("luashushu.card asked")
		local room = player:getRoom()
		local pattern = data:toStringList()[1]
		writeLog("luashushu.card asked pattern " .. pattern)
		if ((pattern == "jink") and
			(room:askForSkillInvoke(player, "luashushu"))) then
			writeLog("luashushu. invoke")
			room:broadcastSkillInvoke("luashushu") --play audio
			
			for _,p in sgs.qlist(room:getOtherPlayers(player)) do
				local data = sgs.QVariant(0)

				data:setValue(player)
				local jink = room:askForCard(p, "jink", "@luashushu-jink:"..player:objectName(), data)
				if (jink) then
					room:provide(jink)
					return true
				end

			end

		end
		writeLog("luashushu. end")
	end
}

luaqiaoke = sgs.CreateTriggerSkill
{--跷课
	name = "luaqiaoke",
	events = {sgs.CardEffected},
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()

		local effect = data:toCardEffect()
		if (effect.card:inherits("AOE")) then
			return true 
		end

	end
}



chenxusheng:addSkill(luashushu)
chenxusheng:addSkill(luaqiaoke)

--------------------------------------
sgs.LoadTranslationTable{
	["huanke"] = "环科包",
	["zhouyongliang"] = "周永亮",
	["$zhouyongliang"] = "周妈妈",
	["#zhouyongliang"] = "周妈妈",
	["designer:zhouyongliang"] = "小明",
	["cv:zhouyongliang"] = "周妈妈配音",
	["illustrator:zhouyongliang"] = "周妈妈画图",
	["luameinan"]="美男",
	["$luameinan"]="他好我也好",
	[":luameinan"]="出牌阶段可以用两张手牌与受伤的女性睡觉，分别加1血",
	["luayongliang"]="永亮",
	["$luayongliang"]="呵呵呵",
	[":luayongliang"]="距离1以内的角色的手牌对你可见",
	
	["dingjinjian"] = "丁锦建",
	["$dingjinjian"] = "丁JJ",
	["#dingjinjian"] = "丁JJ",
	["designer:dingjinjian"] = "小明",
	["cv:dingjinjian"] = "DJJ配音",
	["illustrator:dingjinjian"] = "DJJ画图",
	["luaxuexi"]="学习",
	["$luaxuexi"]="谁来与我大战三百回合",
	[":luaxuexi"]="若本回合闷头学习不出牌，下回合打出的杀和决斗伤害+1",
	
	["wangkewei"] = "王科伟",
	["$wangkewei"] = "convy",
	["#wangkewei"] = "convy",
	["designer:wangkewei"] = "小明",
	["cv:wangkewei"] = "convy配音",
	["illustrator:wangkewei"] = "convy画图",
	["luaweinan"]="猥男",
	["$luaweinan"]="合则两立，斗则两伤",
	[":luaweinan"]="回合开始可选择进入“萎男”状态，本轮不受南蛮和万箭以及决斗影响，但受到杀攻击，伤害+1.女性角色对其出杀，不能躲避",
	["luachaiji"]="拆机",
	["$luachaiji"]="你的牌太多了",
	[":luachaiji"]="任意手牌当过河拆桥",
	
	["shengjianfeng"] = "盛健丰",
	["$shengjianfeng"] = "盛贱贱",
	["#shengjianfeng"] = "盛贱贱",
	["designer:shengjianfeng"] = "小明",
	["cv:shengjianfeng"] = "盛贱贱配音",
	["illustrator:shengjianfeng"] = "盛贱贱画图",
	["luadengdu"]="邓读",
	["$luadengdu"]="邓读术的声音文字描述",
	[":luadengdu"]="邓读术，每回合可以查看一名角色的手牌",
	["luaxibu"]="西部",
	["$luaxibu"]="去西部的声音文字描述",
	[":luaxibu"]="去西部：锦囊无距离限制",
	
	["taoqiuping"] = "陶秋萍",
	["$taoqiuping"] = "秋萍姐",
	["#taoqiuping"] = "秋萍姐",
	["designer:taoqiuping"] = "小明",
	["cv:taoqiuping"] = "秋萍姐配音",
	["illustrator:taoqiuping"] = "秋萍姐画图",
	["luaguike"]="龟壳",
	["$luaguike"]="龟壳的声音文字描述",
	[":luaguike"]="两张杀才有效",
	["@luaguikedoublekill"]="秋萍姐： 你的刀断了没，再来一刀",
	["luaguisu"]="龟速",
	["$luaguisu"]="龟速的声音文字描述",
	[":luaguisu"]="进攻和防御时距离都-1",
	
	["sunchanchan"] = "孙婵婵",
	["$sunchanchan"] = "孙大婵",
	["#sunchanchan"] = "孙大婵",
	["designer:sunchanchan"] = "小明",
	["cv:sunchanchan"] = "孙大婵配音",
	["illustrator:sunchanchan"] = "孙大婵画图",
	["luafanjian"]="反间",
	["$luafanjian"]="反间的声音文字描述",
	[":luafanjian"]="回合内让两男性角色决斗，每回合一次",
	["luashuqian"]="数钱",
	["$luashuqian"]="数钱的声音文字描述",
	[":luashuqian"]="弃掉一个角色比她多的手牌数",
	
	["tangqiaozhi"] = "汤巧智",
	["$tangqiaozhi"] = "汤大师",
	["#tangqiaozhi"] = "汤大师",
	["designer:tangqiaozhi"] = "小明",
	["cv:tangqiaozhi"] = "汤大师配音",
	["illustrator:tangqiaozhi"] = "汤大师画图",
	["luachongqian"]="充钱",
	["$luachongqian"]="充钱的声音文字描述",
	[":luachongqian"]="充话费，每回合多摸一张牌",
	["luashixiong"]="师兄",
	["@luashixiong"]="选牌给师兄",
	["$luashixiong"]="师兄的声音文字描述",
	[":luashixiong"]="所有女性角色都视为小师妹，可以由女性角色在自己回合给1-2张牌",
	
	["xiezhe"] = "谢哲",
	["$xiezhe"] = "小谢",
	["#xiezhe"] = "小谢",
	["designer:xiezhe"] = "小明",
	["cv:xiezhe"] = "小谢配音",
	["illustrator:xiezhe"] = "小谢画图",
	["luabuzui"]="不醉",
	["$luabuzui"]="不醉的声音文字描述",
	[":luabuzui"]="不醉，选择不醉状态后本回合可以无限出杀，但下轮不得出牌",
	["luayuenv"]="阅女",
	["$luayuenv"]="阅女的声音文字描述",
	[":luayuenv"]="阅女，女性角色不能对其使用锦囊",
	["luazaota"]="糟蹋",
	["$luazaota"]="糟蹋的声音文字描述",
	["@luazaotaaskforequipcard"]="选择一张装备牌",
	[":luazaota"]="主公技。每回合可放弃摸牌选择任意一名女性角色口一滴血，并弃一张装备牌",

	["laiwenfeng"] = "赖文峰",
	["$laiwenfeng"] = "老赖",
	["#laiwenfeng"] = "老赖",
	["designer:laiwenfeng"] = "小明",
	["cv:laiwenfeng"] = "老赖配音",
	["illustrator:laiwenfeng"] = "老赖画图",
	["luachoujin"]="抽筋",
	["$luachoujin"]="抽筋的声音文字描述",
	[":luachoujin"]="抽筋，体力值小于等于2时进入抽筋状态，摸两张牌，扣一滴血",
	["luashualai"]="耍赖",
	["$luashualai"]="耍赖的声音文字描述",
	[":luashualai"]="主公技。耍赖，每回合可偷距离内的一名角色一张装备牌",

	["konghaidong"] = "孔海东",
	["$konghaidong"] = "黑洞",
	["#konghaidong"] = "黑洞",
	["designer:konghaidong"] = "小明",
	["cv:konghaidong"] = "黑洞配音",
	["illustrator:konghaidong"] = "黑洞画图",
	["@chengguanchosetips"] = "选择抽牌对象，选择自己表示收队",
	["luachengguan"]="城管",
	["@invokeluachengguanask"]="若发动技能：点击'城管',并选择要抽牌的角色；若不发动，点击取消";
	["$luachengguan"]="城管的声音文字描述",
	[":luachengguan"]="城管出巡：跳过摸排抽取最多3张两名的手牌",
	["luazhuxi"]="主席",
	["$luazhuxi"]="主席的声音文字描述",
	[":luazhuxi"]="社联主席：任意角色替他出杀",
	
	["chenxusheng"] = "陈许胜",
	["$chenxusheng"] = "叔叔",
	["#chenxusheng"] = "叔叔",
	["designer:chenxusheng"] = "小明",
	["cv:chenxusheng"] = "叔叔配音",
	["illustrator:chenxusheng"] = "叔叔画图",
	["luashushu"]="叔叔",
	["$luashushu"]="叔叔的声音文字描述",
	[":luashushu"]="叔叔，男性角色可以给他闪",
	["luaqiaoke"]="跷课",
	["$luaqiaoke"]="跷课的声音文字描述",
	[":luaqiaoke"]="翘课，南蛮万➹无效",
}

