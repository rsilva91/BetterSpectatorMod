------------------------------------------------------------------------------
--	FILE:	 Spectator_UI.lua
--	AUTHOR:  D. / Jack The Narrator, Firaxis
--	PURPOSE: Add an Observer
-------------------------------------------------------------------------------


UIEvents = ExposedMembers.LuaEvents;
local bFirst = true
local g_version = "v1.24"
local b_congress = false
local b_IsSpec = false
local WORLD_CONGRESS_STAGE_1:number = DB.MakeHash("TURNSEG_WORLDCONGRESS_1");
local WORLD_CONGRESS_STAGE_2:number = DB.MakeHash("TURNSEG_WORLDCONGRESS_2");
print("-- Init D. Better Spectator Mod",g_version," UI --");


-- ===========================================================================
--	OnLoadScreenClose() - initialize
-- ===========================================================================

function OnLoadScreenClose()

	if (Game:GetProperty("SPEC_INIT") ~= nil) then
		if (Game:GetProperty("SPEC_INIT") == true) then
			if ( Game:GetProperty("SPEC_NUM") ~= nil) then
				local bspec = false
				for k =1, Game:GetProperty("SPEC_NUM") do
					if ( Game.GetLocalPlayer() == Game:GetProperty("SPEC_ID_"..k)) then
						local tmp_string = "Better Spectator Mod "..g_version..": Welcome Home, Observer! #"..k
						UserConfiguration.SetValue("QuickMovement", 1)
						UserConfiguration.SetValue("QuickCombat", 1)
						UI.RequestPlayerOperation(1000, PlayerOperations.START_OBSERVER_MODE, nil)
						bspec = true
					end
				end
				if bspec == false then
					local tmp_string = "Better Spectator Mod"..g_version..": This game is being observed by "..Game:GetProperty("SPEC_NUM").." Observer(s)"
				end
				--UIEvents.UICleanBoost()
				else
				local tmp_string = "Better Spectator Mod "..g_version..": No Observer in this game!"
				
			end
		end
	end
	
	
end


Events.LoadScreenClose.Add( OnLoadScreenClose );

-- ===========================================================================
--	Call to Script Observer Switch
-- ===========================================================================

function OnLocalPlayerTurnBegin()
	if UI.IsInGame() == false then
		return;
	end	
	local turnSegment = Game.GetCurrentTurnSegment();
	if b_IsSpec == true then
		UI.DeselectAllUnits();
	end
	if turnSegment == WORLD_CONGRESS_STAGE_1 then
		b_congress = true	
	elseif turnSegment == WORLD_CONGRESS_STAGE_2 then
		b_congress = true
	else
		b_congress = false
	end

	if (Game:GetProperty("SPEC_INIT") ~= nil) then
		if (Game:GetProperty("SPEC_INIT") == true) then
			if (Game:GetProperty("SPEC_NUM") ~= nil) then
				local specid = 1000;
				for k = 1, Game:GetProperty("SPEC_NUM") do
					if ( Game:GetProperty("SPEC_ID_"..k)~= nil) then
						if ( Game.GetLocalPlayer() == Game:GetProperty("SPEC_ID_"..k)) then
							b_IsSpec = true
							if (GameConfiguration.GetValue("BSM_SP") == nil) then
								if b_congress == false then
									UI.RequestAction(ActionTypes.ACTION_ENDTURN, { REASON = "UserForced" } );
								end
								else
								if (GameConfiguration.GetValue("BSM_SP") == true) then
									if b_congress == false then
										UI.RequestAction(ActionTypes.ACTION_ENDTURN, { REASON = "UserForced" } );
									end
								end
							end
							specid = Game:GetProperty("SPEC_ID")
							if ( Game:GetProperty("SPEC_LAST_ID") ~= nil) then
								specid = Game:GetProperty("SPEC_LAST_ID")
							end
							if GameConfiguration.GetValue("OBSERVER_ID_"..k) ~= nil then
								specid = GameConfiguration.GetValue("OBSERVER_ID_"..k)
							end
							if Game.GetCurrentGameTurn() > 50 and GameConfiguration.GetValue("GAME_NO_BARBARIANS") == true then
								UI.RequestPlayerOperation(Game.GetLocalPlayer(), PlayerOperations.START_OBSERVER_MODE, nil)
								else
								UIEvents.UIDoObserverPlayer(specid)
							end
						end
					end
				end
			end
		end
	end


end

Events.LocalPlayerTurnBegin.Add(		OnLocalPlayerTurnBegin );


function OnTurnEnd()
	if UI.IsInGame() == false then
		return;
	end	
	if GameConfiguration.GetValue("GAME_NO_BARBARIANS") == false then
		UIEvents.UIUndoObserver("OnTurnEnd")
	end
end

Events.TurnEnd.Add(		OnTurnEnd );

-- ===========================================================================
--	Notification
-- ===========================================================================

-- New Cities
function OnCityAddedToMap( playerID: number, cityID : number, cityX : number, cityY : number )
	if playerID == nil or Game.GetLocalPlayer() == nil then
		return
	end
	
	local pPlayer : object = Players[playerID];
	if pPlayer == nil or pPlayer:IsMajor() == false then
		return 
	end

	local cityCount = 0
	for _,pCity : object in pPlayer:GetCities():Members() do
		cityCount = cityCount + 1
	end
	local msgString = "Title"
	local sumString = "Details"
	if cityCount == 1 and GameConfiguration.GetStartTurn() ~=  Game.GetCurrentGameTurn() then
		msgString = Locale.Lookup("LOC_BSM_NOTIFICATION_DELAYED_B1_MESSAGE");
		sumString = Locale.Lookup("LOC_BSM_NOTIFICATION_DELAYED_B1_SUMMARY");
		NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.PLAYER_MET, msgString, sumString, cityX, cityY);
	elseif cityCount == 2 then
		msgString = Locale.Lookup("LOC_BSM_NOTIFICATION_B2_MESSAGE");
		sumString = Locale.Lookup("LOC_BSM_NOTIFICATION_B2_SUMMARY");
		NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.PLAYER_MET, msgString, sumString, cityX, cityY);
	elseif cityCount == 3 then
		msgString = Locale.Lookup("LOC_BSM_NOTIFICATION_B3_MESSAGE");
		sumString = Locale.Lookup("LOC_BSM_NOTIFICATION_B3_SUMMARY");
		NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.PLAYER_MET, msgString, sumString, cityX, cityY);
	elseif cityCount == 10 then
		msgString = Locale.Lookup("LOC_BSM_NOTIFICATION_B10_MESSAGE");
		sumString = Locale.Lookup("LOC_BSM_NOTIFICATION_B10_SUMMARY");
		NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.PLAYER_MET, msgString, sumString, cityX, cityY);
	elseif cityCount == 20 then
		msgString = Locale.Lookup("LOC_BSM_NOTIFICATION_B20_MESSAGE");
		sumString = Locale.Lookup("LOC_BSM_NOTIFICATION_B20_SUMMARY");
		NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.PLAYER_MET, msgString, sumString, cityX, cityY);
	end
end


-- Goody Huts
function OnGoodyHutReward(playerID, unitID, itemID, itemID_2)
	-- Known ItemID list
	-- 301278043 	-1593446804 civic boost
	-- -1068790248	tech boost
	-- 1623514478	-897059678	xp
	-- 1892398955	1038837136 +1 population
	-- 1623514478	-945185595	free scout
	-- 301278043	2109989822 relic
	-- -2010932837	gold
	-- 1892398955	-317814676 free worker
	if playerID == nil or Players[playerID] == nil then
		return
	end
	if ( Players[playerID]:IsMajor() == true) then
			local sumString =""
			local msgString = Locale.Lookup("LOC_BSM_NOTIFICATION_GOODY_MESSAGE" );
			local notificationType = NotificationTypes.DEFAULT
			local pPlayer	:table = Players[playerID];
			local pUnit		:table = pPlayer:GetUnits():FindID(unitID);		
			
			if (itemID == 301278043 and itemID_2 == -1593446804) then
				sumString = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has found a Goody Hut and received a Civic Boost!"
				elseif (itemID == -1068790248) then
				sumString = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has found a Goody Hut and received a Tech Boost!"
				elseif (itemID == 1623514478 and itemID_2 == -897059678) then
				sumString = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has found a Goody Hut and received a XP Boost!"
				elseif (itemID == 1623514478 and itemID_2 == -945185595) then
				sumString = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has found a Goody Hut and received a Free Scout!"
				elseif (itemID == 1892398955 and itemID_2 == 1038837136) then
				sumString = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has found a Goody Hut and received a Population Boost"
				elseif (itemID == 1623514478 and itemID_2 == 1721956964) then
				sumString = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has found a Goody Hut and was healed!"
				elseif (itemID == 1892398955 and itemID_2 == -317814676) then
				sumString = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has found a Goody Hut and received a Free Worker!"
				elseif (itemID == -2010932837) then
				sumString = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has found a Goody Hut and received some Gold!"
				elseif (itemID == 301278043 and itemID_2 == 2109989822) then
				sumString = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has found a Goody Hut and received a Relic!"
				notificationType = NotificationTypes.RELIC_CREATED
				elseif (itemID == 392580697 and itemID_2 == 1171999597) then
				sumString = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has found a Goody Hut and received a Free Envoy!"
				elseif (itemID == 392580697 and itemID_2 == -842336157) then
				sumString = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has found a Goody Hut and received a Diplomatic Boost!"
				else
				sumString = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has found a Goody Hut!"
				print("Goody hut mistery",itemID, itemID_2)
			end
			if sumString ~= "" then
				NotificationManager.SendNotification(Game.GetLocalPlayer(), notificationType, msgString, sumString, pUnit:GetX(), pUnit:GetY());
			end
	end
end

function OnUnitCaptured( currentUnitOwner, unit, owningPlayer, capturingPlayer )
	local pPlayer	:table = Players[currentUnitOwner];
	local pUnit		:table = pPlayer:GetUnits():FindID(unitID);		
	local	msgString = Locale.Lookup("LOC_BSM_NOTIFICATION_SETTLER_MESSAGE");
	local 	sumString = Locale.Lookup("LOC_NOTIFICATION_SETTLER_SUMMARY");
	if pUnit ~= nil and pUnit:GetName() == "LOC_UNIT_SETTLER_NAME" then
		NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.SPY_ENEMY_CAPTURED, msgString, sumString, pUnit:GetX(), pUnit:GetY());
	end	
end

function OnPantheonFounded(player, belief)

	if ( bspec == true and Players[player]:IsMajor() == true) then
		local msg =""
		local msgString = Locale.Lookup("LOC_BSM_NOTIFICATION_PANTHEON_MESSAGE" );
		msg = Locale.Lookup(PlayerConfigurations[player]:GetPlayerName()).." has chosen a pantheon: "..Locale.Lookup(GameInfo.Beliefs[belief].Name)
		local pCapital = Players[player]:GetCities():GetCapitalCity();
		NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.CHOOSE_PANTHEON, msgString, msg, pCapital:GetX(), pCapital:GetY());
	end
end

local bCampus = false
local bHolySite = false
local bCommercial = false
local bEncampment = false
local bTheater = false
local bIndustrial = false

function OnBuildingAddedToMap( plotX:number, plotY:number, buildingType:number, playerType:number, pctComplete:number, bPillaged:number )

	if Players[playerType] == nil or GameInfo.Buildings[buildingType] == nil then
		return
	end
	if ( Players[playerType]:IsMajor() == true and GameInfo.Buildings[buildingType].IsWonder == true) then
		local msgString = Locale.Lookup("LOC_BSM_NOTIFICATION_WONDER_STARTED_MESSAGE" );
		local msg = ""
		msg = Locale.Lookup(PlayerConfigurations[playerType]:GetPlayerName()).." has started to build: "..Locale.Lookup(GameInfo.Buildings[buildingType].Name)
		NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.WONDER_COMPLETED, msgString, msg, plotX, plotY);
	end
end

function OnDistrictAddedToMap( playerID: number, districtID : number, cityID :number, districtX : number, districtY : number, districtType:number, percentComplete:number )

	local locX = districtX;
	local locY = districtY;
	local type = districtType;

	local pPlayer = Players[playerID];
	if (pPlayer ~= nil) and pPlayer:IsMajor() == true then
		local pDistrict = pPlayer:GetDistricts():FindID(districtID);
		if (pDistrict ~= nil) then
		local name = GameInfo.Districts[pDistrict:GetType()].Name

		local msgString = Locale.Lookup("LOC_BSM_NOTIFICATION_FIRST_DISTRICT_MESSAGE" );
		local msg = ""
		msg = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has started to build the world first "..Locale.Lookup(name)
		if bCampus == false and name == "LOC_DISTRICT_CAMPUS_NAME" then
			NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.WONDER_COMPLETED, msgString, msg, plotX, plotY);
			bCampus = true
		end
		if bEncampment == false and name == "LOC_DISTRICT_ENCAMPMENT_NAME" then
			NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.WONDER_COMPLETED, msgString, msg, plotX, plotY);
			bEncampment = true
		end
		if bCommercial == false and name == "LOC_DISTRICT_COMMERCIAL_HUB_NAME" then
			NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.WONDER_COMPLETED, msgString, msg, plotX, plotY);
			bCommercial = true
		end
		if bTheater == false and name == "LOC_DISTRICT_THEATER_NAME" then
			NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.WONDER_COMPLETED, msgString, msg, plotX, plotY);
			bTheater = true
		end
		if bHolySite == false and name == "LOC_DISTRICT_HOLY_SITE_NAME" then
			NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.WONDER_COMPLETED, msgString, msg, plotX, plotY);
			bHolySite = true
		end	
		if bIndustrial == false and name == "LOC_DISTRICT_INDUSTRIAL_ZONE_NAME" then
			NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.WONDER_COMPLETED, msgString, msg, plotX, plotY);
			bIndustrial = true
		end		
		
		end
	end
end

function OnGovernmentChanged( player:number )

	if ( Players[player]:IsMajor() == true and GameConfiguration.GetStartTurn() ~=  Game.GetCurrentGameTurn() and PlayerConfigurations[player]:GetLeaderTypeName() ~= "LEADER_SPECTATOR") then
		local govType:string = "";
  		local eSelectePlayerGovernment :number = Players[player]:GetCulture():GetCurrentGovernment();
  		if eSelectePlayerGovernment ~= -1 then
    			govType = Locale.Lookup(GameInfo.Governments[eSelectePlayerGovernment].Name);
 			else
   			govType = Locale.Lookup("LOC_GOVERNMENT_ANARCHY_NAME" );
  		end
		msg = Locale.Lookup(PlayerConfigurations[player]:GetPlayerName()).." is now in: "..govType
		local msgString = Locale.Lookup("LOC_BSM_NOTIFICATION_GOV_CHANGE_MESSAGE" );
		local pCapital = Players[player]:GetCities():GetCapitalCity();
		
		NotificationManager.SendNotification(Game.GetLocalPlayer(),NotificationTypes.CONSIDER_GOVERNMENT_CHANGE, msgString, msg, pCapital:GetX(), pCapital:GetY());
	end
end



local bKnight = false
local bGalley = false
local bSword = false
local bCross = false
local bBombard = false
local bMusket = false
local bField = false
local bTank = false
local bCara = false
local bFrigate = false
local bBattleship = false
-- Great People


function OnUnitAddedToMap(playerID, unitID, x, y)
	if playerID == nil or Players[playerID] == nil then
		return
	end
		if ( Players[playerID]:IsMajor() == true) then
			local pPlayer = Players[playerID];
			local pUnit = pPlayer:GetUnits():FindID(unitID);
			if pUnit == nil then
				return
			end
			local unitTypeName = UnitManager.GetTypeName(pUnit);
			local msg = ""
			local msgString = Locale.Lookup("LOC_BSM_NOTIFICATION_FIRST_UNIT_MESSAGE" );
			if (unitTypeName == "UNIT_GALLEY" and bGalley == false) then
				unitName = Locale.Lookup(GameInfo.Units[unitTypeName].Name)
				msg = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has built the first "..unitName
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.BARBARIANS_SIGHTED, msgString, msg, pUnit:GetX(), pUnit:GetY());
				bGalley = true
			end
			if (unitTypeName == "UNIT_KNIGHT" and bKnight == false) then
				unitName = Locale.Lookup(GameInfo.Units[unitTypeName].Name)
				msg = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has trained the first "..unitName
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.BARBARIANS_SIGHTED, msgString, msg, pUnit:GetX(), pUnit:GetY());	
				bKnight = true
			end
			if (unitTypeName == "UNIT_SWORDSMAN" and bSword == false) then
				unitName = Locale.Lookup(GameInfo.Units[unitTypeName].Name)
				msg = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has trained the first "..unitName
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.BARBARIANS_SIGHTED, msgString, msg, pUnit:GetX(), pUnit:GetY());
				bSword = true
			end
			if (unitTypeName == "UNIT_CROSSBOWMAN" and bCross == false) then
				unitName = Locale.Lookup(GameInfo.Units[unitTypeName].Name)
				msg = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has trained the first "..unitName
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.BARBARIANS_SIGHTED, msgString, msg, pUnit:GetX(), pUnit:GetY());
				bCross = true
			end
			if (unitTypeName == "UNIT_MUSKETMAN" and bMusket == false) then
				unitName = Locale.Lookup(GameInfo.Units[unitTypeName].Name)
				msg = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has trained the first "..unitName
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.BARBARIANS_SIGHTED, msgString, msg, pUnit:GetX(), pUnit:GetY());
				bMusket = true
			end
			if (unitTypeName == "UNIT_BOMBARD" and bBombard == false) then
				unitName = Locale.Lookup(GameInfo.Units[unitTypeName].Name)
				msg = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has built the first "..unitName
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.BARBARIANS_SIGHTED, msgString, msg, pUnit:GetX(), pUnit:GetY());
				bBombard = true
			end
			if (unitTypeName == "UNIT_FIELD_CANNON" and bField == false) then
				unitName = Locale.Lookup(GameInfo.Units[unitTypeName].Name)
				msg = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has built the first "..unitName
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.BARBARIANS_SIGHTED, msgString, msg, pUnit:GetX(), pUnit:GetY());
				bField = true
			end
			if (unitTypeName == "UNIT_TANK" and bTank == false) then
				unitName = Locale.Lookup(GameInfo.Units[unitTypeName].Name)
				msg = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has built the first "..unitName
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.BARBARIANS_SIGHTED, msgString, msg, pUnit:GetX(), pUnit:GetY());
				bTank = true
			end
			if (unitTypeName == "UNIT_CARAVEL" and bCara == false) then
				unitName = Locale.Lookup(GameInfo.Units[unitTypeName].Name)
				msg = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has built the first "..unitName
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.BARBARIANS_SIGHTED, msgString, msg, pUnit:GetX(), pUnit:GetY());
				bCara = true
			end
			if (unitTypeName == "UNIT_FRIGATE" and bFrigate == false) then
				unitName = Locale.Lookup(GameInfo.Units[unitTypeName].Name)
				msg = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has built the first "..unitName
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.BARBARIANS_SIGHTED, msgString, msg, pUnit:GetX(), pUnit:GetY());
				bFrigate = true
			end
			if (unitTypeName == "UNIT_BATTLESHIP" and bBattleship == false) then
				unitName = Locale.Lookup(GameInfo.Units[unitTypeName].Name)
				msg = Locale.Lookup(PlayerConfigurations[playerID]:GetPlayerName()).." has built the first "..unitName
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.BARBARIANS_SIGHTED, msgString, msg, pUnit:GetX(), pUnit:GetY());
				bBattleship = true
			end

		end	


end


local bHypatia = false
local bNewton = false
local bKwolek = false -- Doesn t exist ?
local bSagan = false
local bEinstein = false
local bElCid = false
local bBonaparte = false
local bBreedlove = false
local bDuilius = false
local bCruz = false
local bGoddard = false
local bKorolev = false
local bBraun = false
local bBentz = false


function GPData()

	local pGreatPeople	:table  = Game.GetGreatPeople();
	if pGreatPeople == nil then
		UI.DataError("GreatPeoplePopup received NIL great people object.");
		return;
	end
	local displayPlayerID = Game.GetLocalPlayer()
	local pTimeline:table = nil;

	pTimeline = pGreatPeople:GetTimeline();
	
	for i,entry in ipairs(pTimeline) do
		--print("	GPData() Timeline", entry.Claimant)
		-- don't add unclaimed great people to the previously recruited tab

			local claimantName :string = nil;
			if (entry.Claimant ~= nil) then
				claimantName = Locale.Lookup(PlayerConfigurations[entry.Claimant]:GetCivilizationShortDescription());
			end

			local canRecruit			:boolean = false;
			local canReject				:boolean = false;
			local canPatronizeWithFaith :boolean = false;
			local canPatronizeWithGold	:boolean = false;
			local actionCharges			:number = 0;
			local patronizeWithGoldCost	:number = nil;		
			local patronizeWithFaithCost:number = nil;
			local recruitCost			:number = entry.Cost;
			local rejectCost			:number = nil;
			local earnConditions		:string = nil;
			local msg = ""
			local dur = 5
			if (entry.Individual ~= nil) then
				local individualInfo = GameInfo.GreatPersonIndividuals[entry.Individual];
				actionCharges = individualInfo.ActionCharges;
			end
			local msgString = Locale.Lookup("LOC_BSM_NOTIFICATION_STRONG_GP_MESSAGE" );
			local personName:string = "";
			if  GameInfo.GreatPersonIndividuals[entry.Individual] ~= nil then
				personName = Locale.Lookup(GameInfo.GreatPersonIndividuals[entry.Individual].Name);
			end  


			if (bHypatia == false and entry.Individual == 130 and entry.Claimant == nil) then
				msg = personName.." is now available!"
				dur = 15
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.CHOOSE_RELIGION, msgString, msg);
				bHypatia = true
			end
			if (bNewton == false and entry.Individual == 135 and entry.Claimant == nil) then
				msg = personName.." is now available!"
				dur = 15
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.CHOOSE_RELIGION, msgString, msg);
				bNewton = true
			end
			if (bElCid == false and entry.Individual == 60 and entry.Claimant == nil) then
				msg = personName.." is now available!"
				dur = 15
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.CHOOSE_RELIGION, msgString, msg);
				bElCid = true
			end
			if (bBonaparte == false and entry.Individual == 64 and entry.Claimant == nil) then
				msg = personName.." is now available!"
				dur = 15
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.CHOOSE_RELIGION, msgString, msg);
				bBonaparte = true
			end
			if (bEinstein == false and entry.Individual == 64 and entry.Claimant == nil) then
				msg = personName.." is now available!"
				dur = 15
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.CHOOSE_RELIGION, msgString, msg);
				bEinstein = true
			end
			if (bBreedlove == false and entry.Individual == 89 and entry.Claimant == nil) then
				msg = personName.." is now available!"
				dur = 15
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.CHOOSE_RELIGION, msgString, msg);
				bBreedlove = true
			end
			if (bDuilius == false and entry.Individual == 1 and entry.Claimant == nil) then
				msg = personName.." is now available!"
				dur = 15
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.CHOOSE_RELIGION, msgString, msg);
				bDuilius = true
			end
			if (bCruz == false and entry.Individual == 7 and entry.Claimant == nil) then
				msg = personName.." is now available!"
				dur = 15
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.CHOOSE_RELIGION, msgString, msg);
				bCruz = true
			end
			if (bGoddard == false and entry.Individual == 49 and entry.Claimant == nil) then
				msg = personName.." is now available!"
				dur = 15
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.CHOOSE_RELIGION, msgString, msg);
				bGoddard = true
			end
			--if (bKwolek == false and entry.Individual == 49 and entry.Claimant == nil) then
			--	msg = personName.." is now available!"
			--	dur = 15
			--	StatusMessage( msg, dur, ReportingStatusTypes.DEFAULT )
			--	bKwolek = true
			--end
			if (bKorolev == false and entry.Individual == 52 and entry.Claimant == nil) then
				msg = personName.." is now available!"
				dur = 15
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.CHOOSE_RELIGION, msgString, msg);
				bKorolev  = true
			end
			if (bBraun == false and entry.Individual == 55 and entry.Claimant == nil) then
				msg = personName.." is now available!"
				dur = 15
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.CHOOSE_RELIGION, msgString, msg);
				bBraun  = true
			end
			if (bBentz == false and entry.Individual == 91 and entry.Claimant == nil) then
				msg = personName.." is now available!"
				dur = 15
				NotificationManager.SendNotification(Game.GetLocalPlayer(), NotificationTypes.CHOOSE_RELIGION, msgString, msg);
				bBentz  = true
			end

	end

end

function WritingBoostUIHook(player1ID, player2ID)
	if Game:GetProperty("TO_CHECK")==nil then
		return
	end
	local localPlayerID = Game.GetLocalPlayer()
	local hostID = 0
	if GameConfiguration.IsNetworkMultiplayer() then
		hostID = Network.GetGameHostPlayerID()
	end
	local sPlayer1LeaderName = PlayerConfigurations[player1ID]:GetLeaderTypeName()
	local sPlayer2LeaderName = PlayerConfigurations[player2ID]:GetLeaderTypeName()
	local pPlayer1 = Players[player1ID]
	local pPlayer2 = Players[player2ID]
	local bMajNotSpec1 = false
	local bMajNotSpec2 = false
	local bIsAi1 = true
	local bIsAi2 = true
	local bIsLoc1 = false 
	local bIsLoc2 = false
	local bIsTurnEnd1 = false
	local bIsTurnEnd2 = false
	if pPlayer1 == nil then
		return
	end
	if pPlayer2 == nil then
		return
	end
	if pPlayer1:IsMajor() and sPlayer1LeaderName~="LEADER_SPECTATOR" then
		bMajNotSpec1 = true
		if player1ID == localPlayerID then
			bIsLoc1 = true
		end
		if pPlayer1:IsHuman() then
			bIsAi1 = false
		end
		bIsTurnEnd1 = (not pPlayer1:IsTurnActive())
		print(bIsTurnEnd1)
	end
	if pPlayer2:IsMajor() and sPlayer1LeaderName~="LEADER_SPECTATOR" then
		bMajNotSpec2 = true
		if player2ID == localPlayerID then
			bIsLoc2 = true
		end
		if pPlayer2:IsHuman() then
			bIsAi2 = false
		end
		bIsTurnEnd2 = (not pPlayer2:IsTurnActive())
		print(bIsTurnEnd2)
	end
	if bMajNotSpec1 and bMajNotSpec2 then
		print("Both Players are (Major and not Spec) -> proceed...")
		print("Major "..sPlayer1LeaderName.." Meets Major "..sPlayer2LeaderName.." UI side")
		local kParameters:table = {}
		local values1 = {}
		local values2 = {}
		local iTechWriting = GameInfo.Technologies["TECH_WRITING"].Index
		local p1Techs = pPlayer1:GetTechs()
		local p2Techs = pPlayer2:GetTechs()
		if (p1Techs:HasBoostBeenTriggered(iTechWriting)==false) or (p1Techs:HasTech(iTechWriting)==false) then
			table.insert(values1, player1ID)
		end
		if (p2Techs:HasBoostBeenTriggered(iTechWriting)==false) or (p2Techs:HasTech(iTechWriting)==false) then
			table.insert(values2, player2ID)
		end			
		if #values1>0 and values1~={} then
			local kParameters:table = {}
			kParameters.value = values1
			kParameters.OnStart = "ApplyWritingBoost"
			if (not bIsTurnEnd1) and (not bIsAi1) then
				if bIsLoc1 then
					print("ID's to apply boost are being sent to Spectator.lua Gameplay context via Request")
					UI.RequestPlayerOperation(localPlayerID, PlayerOperations.EXECUTE_SCRIPT, kParameters)
				end
			else
				print("ID's to apply boost are being sent to Spectator.lua Gameplay context via Host")
				UIEvents.HostWritingUpdate(hostID, kParameters)
			end
		end
		if #values2>0 and values2~={} then
			local kParameters:table = {}
			kParameters.value = values2
			kParameters.OnStart = "ApplyWritingBoost"
			if (not bIsTurnEnd2) and (not bIsAi2) then
				if bIsLoc2 then
					print("ID's to apply boost are being sent to Spectator.lua Gameplay context via Request")
					UI.RequestPlayerOperation(localPlayerID, PlayerOperations.EXECUTE_SCRIPT, kParameters)
				end
			else
				print("ID's to apply boost are being sent to Spectator.lua Gameplay context via Host")
				UIEvents.HostWritingUpdate(hostID, kParameters)
			end
		end
	end
end

Events.DiplomacyMeet.Add(WritingBoostUIHook)

function WritingIsBoostedUIHook(playerID, iTech, iUnknownA, iUnknownB)
	if Game:GetProperty("TO_CHECK")==nil then
		return
	end
	local localPlayerID = Game.GetLocalPlayer()
	local hostID = 0
	if GameConfiguration.IsNetworkMultiplayer() then
		hostID = Network.GetGameHostPlayerID()
	end
	local sPlayerLeaderName = PlayerConfigurations[playerID]:GetLeaderTypeName()
	local pPlayer = Players[playerID]
	local bMajNotSpec = false
	local bIsAi = true
	local bIsLoc = false 
	local bIsTurnEnd = false
	if pPlayer == nil then
		return
	end
	if pPlayer:IsMajor() and sPlayerLeaderName~="LEADER_SPECTATOR" then
		bMajNotSpec = true
		if playerID == localPlayerID then
			bIsLoc = true
		end
		if pPlayer:IsHuman() then
			bIsAi = false
		end
		bIsTurnEnd = (not pPlayer:IsTurnActive())
		print(bIsTurnEnd)
	end
	if bMajNotSpec then
		print("Player is (Major and not Spec) -> proceed...")
		print("Major "..sPlayerLeaderName.." Trigger (Step1) Remove(boosted) UI side")
		local kParameters:table = {}
		local values = {}
		local iTechWriting = GameInfo.Technologies["TECH_WRITING"].Index
		local pTechs = pPlayer:GetTechs()
		if iTechWriting == iTech then
			table.insert(values, playerID)
		end			
		if #values>0 and values~={} then
			local kParameters:table = {}
			kParameters.value = values
			kParameters.OnStart = "PopCheckList"
			if (not bIsTurnEnd) and (not bIsAi) then
				if bIsLoc then
					print("ID's to remove(boost) are being sent to Spectator.lua Gameplay context via Request")
					UI.RequestPlayerOperation(localPlayerID, PlayerOperations.EXECUTE_SCRIPT, kParameters)
					
				end
			else
				print("ID's to remove(boost) are being sent to Spectator.lua Gameplay context via Host")
				UIEvents.HostPopCheckList(hostID, kParameters)
			end
		end
	end
end

Events.TechBoostTriggered.Add(WritingIsBoostedUIHook)

function WritingIsResearchedUIHook(playerID, iTech)
	if Game:GetProperty("TO_CHECK")==nil then
		return
	end
	local localPlayerID = Game.GetLocalPlayer()
	local hostID = 0
	if GameConfiguration.IsNetworkMultiplayer() then
		hostID = Network.GetGameHostPlayerID()
	end
	local sPlayerLeaderName = PlayerConfigurations[playerID]:GetLeaderTypeName()
	local pPlayer = Players[playerID]
	local bMajNotSpec = false
	local bIsAi = true
	local bIsLoc = false 
	local bIsTurnEnd = false
	if pPlayer == nil then
		return
	end
	if pPlayer:IsMajor() and sPlayerLeaderName~="LEADER_SPECTATOR" then
		bMajNotSpec = true
		if playerID == localPlayerID then
			bIsLoc = true
		end
		if pPlayer:IsHuman() then
			bIsAi = false
		end
		bIsTurnEnd = (not pPlayer:IsTurnActive())
		print(bIsTurnEnd)
	end
	if bMajNotSpec then
		print("Player is (Major and not Spec) -> proceed...")
		print("Major "..sPlayerLeaderName.." Trigger (Step1) Remove(researched) UI side")
		local kParameters:table = {}
		local values = {}
		local iTechWriting = GameInfo.Technologies["TECH_WRITING"].Index
		local pTechs = pPlayer:GetTechs()
		if iTechWriting == iTech then
			table.insert(values, playerID)
		end			
		if #values>0 and values~={} then
			local kParameters:table = {}
			kParameters.value = values
			kParameters.OnStart = "PopCheckList"
			if (not bIsTurnEnd) and (not bIsAi) then
				if bIsLoc then
					UI.RequestPlayerOperation(localPlayerID, PlayerOperations.EXECUTE_SCRIPT, kParameters)
					print("ID's to remove(research) are sent to Spectator.lua Gameplay context via Request")
				end
			else
				UIEvents.HostPopCheckList(hostID, kParameters)
				print("ID's to remove(research) are sent to Spectator.lua Gameplay context via Host")
			end
		end
	end
end
Events.ResearchCompleted.Add(WritingIsResearchedUIHook)

function ExposedMembers.FreeUIHooks()
	print("FreeUIHooks triggered")
	Events.ResearchCompleted.Remove(WritingIsResearchedUIHook)
	Events.TechBoostTriggered.Remove(WritingIsBoostedUIHook)
	Events.DiplomacyMeet.Remove(WritingBoostUIHook)
	print(tostring(Game.GetLocalPlayer()).." Removed all UI Hooks")
	print("Includeing Self")
end

function OnLocalPlayerTurnBeginNotification()
	GPData()	
end

function OnLocalPlayerTurnBeginRecalculateBoost()
	print("Local player raise Game Event begin")
	local currentTurn = Game.GetCurrentGameTurn()
	if currentTurn == GameConfiguration.GetStartTurn() then
		local kParameters:table = {}
		kParameters.OnStart = "FirstHumanTurnRecalculateBoost"
		--UI.RequestPlayerOperation(Game.GetLocalPlayer(), PlayerOperations.EXECUTE_SCRIPT, kParameters)
		print("OnLocalPlayerTurnBeginRecalculateBoost sent request to Gameplay")
	end	
end

function Initialize()

	if Game.GetLocalPlayer() == nil or Players[Game.GetLocalPlayer()] == nil then
		return
	end

	if PlayerConfigurations[Game.GetLocalPlayer()]:GetLeaderTypeName() == "LEADER_SPECTATOR" then
		-- only subscribe for Spectators
		Events.CityAddedToMap.Add( 									OnCityAddedToMap );
		Events.UnitAddedToMap.Add(									OnUnitAddedToMap );
		Events.GovernmentChanged.Add( 								OnGovernmentChanged );
		Events.BuildingAddedToMap.Add( 								OnBuildingAddedToMap );
		Events.PantheonFounded.Add(									OnPantheonFounded)
		Events.GoodyHutReward.Add(									OnGoodyHutReward );
		Events.LocalPlayerTurnBegin.Add(							OnLocalPlayerTurnBeginNotification );
		Events.UnitCaptured.Add(									OnUnitCaptured);
		Events.DistrictAddedToMap.Add (								OnDistrictAddedToMap );
	else
		--Events.LocalPlayerTurnBegin.Add(OnLocalPlayerTurnBeginRecalculateBoost)
	end

end

Initialize()
