SaveData.register(:waypoints_tracker) do
	ensure_class :WaypointsTracker
	save_value { $waypoints_tracker }
	load_value { |value| $waypoints_tracker = value }
	new_game_value { WaypointsTracker.new }
end

class WaypointsTracker
	attr_reader :activeWayPoints
	attr_reader :legendsMaterialized
	
	def initialize()
		@activeWayPoints = {}
		@legendsMaterialized = []
	end

	def overwriteWaypoint(waypointName,mapID,wayPointInfo)
		if @activeWayPoints.has_key?(waypointName)
			@activeWayPoints[waypointName] = [mapID,wayPointInfo]
		elsif debugControl
			setWaypoint(waypointName,mapID,wayPointInfo)
		end
	end

	def setWaypoint(waypointName,mapID,wayPointInfo)
		@activeWayPoints[waypointName] = [mapID,wayPointInfo]
	end

	def deleteWaypoint(waypointName)
		@activeWayPoints.delete(waypointName)
	end

	def mapPositionHash
		return generateMapPositionHash
	end

	def generateMapPositionHash
		mapPositionHash = {}
		activeWayPoints.each do |waypointName,waypointInfo|
			mapID = waypointInfo[0]
			displayedPosition = getDisplayedPositionOfGameMap(mapID)
			mapPositionHash[waypointName] = displayedPosition 
		end
		return mapPositionHash
	end
	
	def getWaypointAtMapPosition(x,y)
		mapPositionHash.each do |waypointName,displayedPosition|
			if displayedPosition[1] == x && displayedPosition[2] == y
				return waypointName
			end
		end
		return nil
	end

	def addWaypoint(waypointName,event,message = true)
		if event.is_a?(Array)
			@activeWayPoints[waypointName] = event
		else
			@activeWayPoints[waypointName] = [event.map_id,event.id]
		end
	end

	def summonPokemonFromWaypoint(avatarSpecies,waypointEvent)
		$PokemonGlobal.respawnPoint = waypointEvent.id
		speciesDisplayName = GameData::Species.get(avatarSpecies).name
		pbMessage(_INTL("By the power of Regigigas, a #{speciesDisplayName} was created!"))
		level = [50,getLevelCap].min
		if pbWildBattleCore(avatarSpecies, level) == 4 # Caught
			$PokemonGlobal.respawnPoint = nil
			return true
		end
		return false
	end
	
	def accessWaypoint(waypointName,waypointEvent,alternateMessage=false)
		@activeWayPoints = {} if @activeWayPoints.nil?
		
		if alternateMessage
			pbMessage(_INTL("#{WAYPOINT_ACCESS_MESSAGE_ALTERNATE}"))
		else
			pbMessage(_INTL("#{WAYPOINT_ACCESS_MESSAGE}"))
		end
		
		unless @activeWayPoints.has_key?(waypointName)
			pbMessage(_INTL("#{WAYPOINT_REGISTER_MESSAGE}"))
			addWaypoint(waypointName,waypointEvent)
		end
		
		if @activeWayPoints.length <= 1
			pbMessage(_INTL("#{WAYPOINT_UNABLE_MESSAGE}"))
		else
			warpByWaypoints
		end
	end

	def warpByWaypoints(skipMessage = false)
		if @activeWayPoints.empty?
			pbMessage(_INTL("#{NO_WAYPOINTS_MESSAGE}"))
			return
		end

		chosenLocation = nil
		chosenKey = nil
		if CHOOSE_BY_LIST
			commands = [_INTL("Cancel")]
			names = @activeWayPoints.sort_by {|key,value| value[0]}.map {|value| value[0]}
			names.delete_if{|name| name == waypointName}
			names.each do |name|
				commands.push(_INTL(name))
			end
			chosen = pbMessage(_INTL("#{WAYPOINT_CHOOSE_MESSAGE}"),commands,0)
			if chosen != 0
				chosenKey = names[chosen-1]
				chosenLocation = @activeWayPoints[chosenKey]
			end
		else
			pbMessage(_INTL("#{WAYPOINT_CHOOSE_MESSAGE}")) unless skipMessage
			chosenKey = nil
			pbFadeOutIn {
				scene = PokemonRegionMap_Scene.new(-1,false)
				screen = PokemonRegionMapScreen.new(scene)
				chosenKey = screen.pbStartWaypointScreen
			}
			chosenLocation = @activeWayPoints[chosenKey] if !chosenKey.nil?
		end

		unless chosenLocation.nil?
			mapID = chosenLocation[0]
			waypointInfo = chosenLocation[1]

			# Old system of storing the specific location
			if waypointInfo.is_a?(Array)
				$game_temp.player_new_map_id = mapID
				$game_temp.player_new_x = waypointInfo[0]
				$game_temp.player_new_y = waypointInfo[1]
				$game_temp.player_new_direction = 2
				$game_temp.transition_processing = true
				$game_temp.transition_name       = ""
			else
				unless transferPlayerToEvent(waypointInfo,Up,mapID,[0,1])
					pbMessage(_INTL("The chosen waypoint is somehow invalid."))
					pbMessage(_INTL("Removing access."))
					@activeWayPoints.delete(chosenKey)
					return
				end
			end
			$scene.transfer_player
			$game_map.autoplay
			$game_map.refresh
		end
	end
end

# Should only be called by the waypoint events themselves
def accessWaypoint(waypointName,avatarSpecies=nil)
	waypointEvent = get_self

	alternate = false

	if avatarSpecies
		alternate = true
		if pbHasItem?(:PRIMALCLAY)
			avatarSpeciesName = GameData::Species.get(avatarSpecies).name

			if pbConfirmMessageSerious(_INTL("The totem pulses with the frequency of #{avatarSpeciesName}. Summon it?"))
				# No longer allow summoning the pokemon once its been caught once
				if $waypoints_tracker.summonPokemonFromWaypoint(avatarSpecies,waypointEvent)
					pbMessage(_INTL("The totem returns to its original state."))
					pbSetSelfSwitch(waypointEvent.id,'A',false)
					return true
				end
				return false
			end
		end
	end
	
	$waypoints_tracker.accessWaypoint(waypointName,waypointEvent,alternate)
end

def setWaypointSummonable(waypointEventID)
	pbSetSelfSwitch(waypointEventID,'A',true)
end