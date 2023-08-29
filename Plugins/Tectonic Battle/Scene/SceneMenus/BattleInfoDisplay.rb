HIGHEST_STAT_BASE = Color.new(139,52,34)
LOWEST_STAT_BASE = Color.new(60,55,112)
TRIBAL_BOOSTED_BASE = Color.new(70, 130, 76)

FADED_EFFECT_BASE = Color.new(120,120,120)

DEBUGGING_EFFECT_DISPLAY = false

class BattleInfoDisplay < SpriteWrapper
	attr_accessor   :battle
	attr_accessor   :selected
	attr_accessor	:individual
	
  def initialize(viewport,z,battle)
	super(viewport)
    self.x = 0
    self.y = 0
	self.battle = battle
	
	@sprites      			= {}
    @spriteX      			= 0
    @spriteY      			= 0
	@selected	  			= 0
	@individual   			= nil
	@field					= false
	@battleInfoMain			= AnimatedBitmap.new("Graphics/Pictures/Battle/battle_info_main")
	@battleInfoIndividual	= AnimatedBitmap.new("Graphics/Pictures/Battle/battle_info_individual")
	@backgroundBitmap  		= @battleInfoMain
	@statusCursorBitmap  	= AnimatedBitmap.new("Graphics/Pictures/Battle/cursor_status")
	
	@contents = BitmapWrapper.new(@backgroundBitmap.width,@backgroundBitmap.height)
    self.bitmap  = @contents
	pbSetNarrowFont(self.bitmap)
	
	@battlerScrollingValue = 0
	@fieldScrollingValue = 0

	@turnOrder = @battle.pbTurnOrderDisplayed
	
	self.z = z
    refresh
  end
  
  def dispose
    pbDisposeSpriteHash(@sprites)
    @battleInfoMain.dispose
	@battleInfoIndividual.dispose
    super
  end
  
  def visible=(value)
    super
    for i in @sprites
      i[1].visible = value if !i[1].disposed?
    end
  end
  
  def refresh
    self.bitmap.clear
	
	if @individual
		@backgroundBitmap  		= @battleInfoIndividual
		self.bitmap.blt(0,0,@backgroundBitmap.bitmap,Rect.new(0,0,@backgroundBitmap.width,@backgroundBitmap.height))
		drawIndividualBattlerInfo(@individual)
	else
		@backgroundBitmap  		= @battleInfoMain
		self.bitmap.blt(0,0,@backgroundBitmap.bitmap,Rect.new(0,0,@backgroundBitmap.width,@backgroundBitmap.height))
		drawWholeBattleInfo()
	end
  end
  
  def drawWholeBattleInfo()
	base   = Color.new(88,88,80)
	shadow = Color.new(168,184,184)
	textToDraw = []
	
	# Draw the
	battlerNameX = 16
	battlerCursorX = 152
	yPos = 8
	battlerIndex = 0

	# Entries for allies
	@battle.eachSameSideBattler do |b|
		next if b.nil?
		textToDraw.push([b.name,battlerNameX,yPos + 4,0,base,shadow])
		cursorX = @selected == battlerIndex ? @statusCursorBitmap.width/2 : 0
		self.bitmap.blt(battlerCursorX,yPos,@statusCursorBitmap.bitmap,Rect.new(cursorX,0,@statusCursorBitmap.width/2,@statusCursorBitmap.height))
		textToDraw.push([@turnOrder[b.index].to_s,battlerCursorX + 140,yPos + 4,0,base,shadow]) if @turnOrder.key?(b.index)
		
		yPos += 52
		battlerIndex += 1
	end

	# Entries for enemies
	yPos = 180
	@battle.eachOtherSideBattler do |b|
		next if b.nil?
		textToDraw.push([b.name,battlerNameX,yPos + 4,0,base,shadow])
		cursorX = @selected == battlerIndex ? @statusCursorBitmap.width/2 : 0
		self.bitmap.blt(battlerCursorX,yPos,@statusCursorBitmap.bitmap,Rect.new(cursorX,0,@statusCursorBitmap.width/2,@statusCursorBitmap.height))
		textToDraw.push([@turnOrder[b.index].to_s,battlerCursorX + 140,yPos + 4,0,base,shadow]) if @turnOrder.key?(b.index)
		
		yPos += 52
		battlerIndex += 1
	end
	
	weatherAndTerrainY = 336
	weatherMessage = "No Weather"
	weatherColor = FADED_EFFECT_BASE
	if @battle.field.weather != :None
		weatherColor = base
		weatherName = GameData::BattleWeather.get(@battle.field.weather).real_name
		weatherDuration = @battle.field.weatherDuration
		weatherDuration = "Infinite" if weatherDuration < 0
		if [:Eclipse,:Moonglow].include?(@battle.field.weather)
			turnsTillActivation = PokeBattle_Battle::SPECIAL_EFFECT_WAIT_TURNS - @battle.field.specialTimer
			weatherMessage = _INTL("{1} ({2},{3})",weatherName,weatherDuration,turnsTillActivation)
		else
			weatherMessage = _INTL("{1} ({2})",weatherName,weatherDuration)
		end
	end
	
	textToDraw.push([weatherMessage,24,weatherAndTerrainY,0,weatherColor,shadow])

	# terrainMessage = "No Terrain"
	# if @battle.field.terrain != :None
	# 	terrainName = GameData::BattleTerrain.get(@battle.field.terrain).real_name
	# 	terrainDuration = @battle.field.terrainDuration
	# 	terrainDuration = "Inf." if terrainDuration < 0
	# 	terrainMessage = _INTL("{1} Terrain ({2})",terrainName, terrainDuration)
	# end
	# textToDraw.push([terrainMessage,256+24,weatherAndTerrainY,0,base,shadow])

	turnCountMessage = "Turn Count: #{(@battle.turnCount + 1).to_s}"
	textToDraw.push([turnCountMessage,256+24,weatherAndTerrainY,0,base,shadow])
	
	# Whole field effects
	wholeFieldX = 324
	textToDraw.push([_INTL("Field Effects"),wholeFieldX+60,0,2,base,shadow])
	
	# Compile array of descriptors of each field effect
	fieldEffects = []
	pushEffectDescriptorsToArray(@battle.field,fieldEffects)
	@battle.sides.each do |side|
		thisSideEffects = []
		pushEffectDescriptorsToArray(side,thisSideEffects)
		if side.index == 1
			thisSideEffects.map { |descriptor|
				"#{descriptor} [O]"
			}
		end
		fieldEffects.concat(thisSideEffects)
	end

	fieldEffects.concat($Trainer.tribalBonus.getActiveBonusesList(true,false))
	@battle.opponent&.each do |opponent|
		fieldEffects.concat(opponent.tribalBonus.getActiveBonusesList(true,true))
	end
	
	# Render out the field effects
	scrollingBoundYMin = 36
	scrollingBoundYMax = 300
	if fieldEffects.length != 0
		scrolling = true if fieldEffects.length > 8
		index = 0
		repeats = scrolling ? 2 : 1
		for repeat in 0...repeats
			fieldEffects.each do |effectName|
				index += 1
				calcedY = 60 + 32 * index
				if scrolling
					calcedY -= @fieldScrollingValue
					calcedY += 8
				end
				next if calcedY < scrollingBoundYMin || calcedY > scrollingBoundYMax
				distanceFromFade = [calcedY - scrollingBoundYMin,scrollingBoundYMax - calcedY].min
				textAlpha = scrolling ? ([distanceFromFade / 20.0,1.0].min * 255).floor : 255
				textBase = Color.new(base.red,base.blue,base.green,textAlpha)
				textShadow = Color.new(shadow.red,shadow.blue,shadow.green,textAlpha)
				textToDraw.push([effectName,wholeFieldX,calcedY,0,textBase,textShadow])
			end
		end
	else
		textToDraw.push(["None",wholeFieldX,44,0,FADED_EFFECT_BASE,shadow])
	end
	
	# Reset the scrolling once its scrolled through the entire list once
	@fieldScrollingValue = 0 if @fieldScrollingValue > fieldEffects.length * 32

	pbDrawTextPositions(self.bitmap,textToDraw)
  end
  
  def drawIndividualBattlerInfo(battler)
	base   = Color.new(88,88,80)
    shadow = Color.new(168,184,184)
	textToDraw = []
	
	battlerName = battler.name
	if battler.pokemon.nicknamed?
		speciesData = GameData::Species.get(battler.species)
		battlerName += " (#{speciesData.real_name})"
		battlerName += " [#{speciesData.form_name}]" if speciesData.form != 0
	end
	textToDraw.push([battlerName,256,0,2,base,shadow])
	
	# Stat Steps
	statStepsSectionTopY = 52
	statLabelX = 20
	statStepX = 116
	statMultX = 172
	statValueX = 232
	battlerEffectsX = 308
	textToDraw.push(["Stat",statLabelX,statStepsSectionTopY,0,base,shadow])
	textToDraw.push(["Step",statStepX-16,statStepsSectionTopY,0,base,shadow])
	textToDraw.push(["Mult",statMultX,statStepsSectionTopY,0,base,shadow])
	textToDraw.push(["Value",statValueX,statStepsSectionTopY,0,base,shadow])
	
	statsToNames = {
		:ATTACK => "Atk",
		:DEFENSE => "Def",
		:SPECIAL_ATTACK => "Sp. Atk",
		:SPECIAL_DEFENSE => "Sp. Def",
		:SPEED => "Speed",
		:ACCURACY => "Acc",
		:EVASION => "Evade"
	}

	# Hash containing info about each stat
	# Each key is a symbol of a stat
	# Each value is an array of [statName, statStep, statMult, statFinalValue]
	calculatedStatInfo = {}
	
	# Display the info about each stat
	statValues = battler.plainStats
	highestStat = nil
	highestStatValue = -65536 # I chose these caps somewhat arbitrarily
	lowestStat = nil
	lowestStatValue = 65536
	statsToNames.each do |stat,name|
		statValuesArray = []
		
		statData = GameData::Stat.get(stat)
		statValuesArray.push(name)
		
		# Stat step
		step = battler.steps[stat]
		if step != 0 && battler.boss? && AVATAR_DILUTED_STAT_STEPS
			step = (step/2.0).round(2)
		end
		statValuesArray.push(step)

		# Multiplier
		statValuesArray.push(battler.statMultiplierAtStep(battler.steps[stat]))

		# Draw the final stat value label
		if stat == :ACCURACY || stat == :EVASION
			value = 100
		else
			value = battler.getFinalStat(stat)
		end
		statValuesArray.push(value)

		# Track the highest and lowest main battle stat (not accuracy or evasion)
		if statData.type == :main_battle
			if value > highestStatValue
				highestStat = stat
				highestStatValue = value
			end

			if value < lowestStatValue
				lowestStat = stat
				lowestStatValue = value
			end
		end
		
		calculatedStatInfo[stat] = statValuesArray
	end

	index = 0
	calculatedStatInfo.each do |stat,calculatedInfo|
		name 		= calculatedInfo[0]
		step 		= calculatedInfo[1]
		statMult 	= calculatedInfo[2]
		statValue 	= calculatedInfo[3]

		# Calculate text display info
		y = statStepsSectionTopY + 40 + 40 * index
		statValueAddendum = ""
		if stat == highestStat
			finalStatColor = HIGHEST_STAT_BASE
			statValueAddendum = " H"
		elsif stat == lowestStat
			finalStatColor = LOWEST_STAT_BASE
			statValueAddendum = " L"
		else
			finalStatColor = base
		end

		# Display the stat's name
		statNameColor = base
		if GameData::Stat.get(stat).type == :main_battle
			tribalBoostSymbol = (stat.to_s + "_TRIBAL").to_sym
			isTribalBoosted = statValues[tribalBoostSymbol] > 0
			statNameColor = TRIBAL_BOOSTED_BASE if isTribalBoosted
		end
		textToDraw.push([name,statLabelX,y,0,statNameColor,shadow])

		# Display the stat step
		x = statStepX
		x -= 12 if step != 0
		stepLabel = step.to_s
		stepLabel = "+" + stepLabel if step > 0
		textToDraw.push([stepLabel,x,y,0,base,shadow])

		# Display the stat multiplier
		multLabel = statMult.round(2).to_s
		textToDraw.push([multLabel,statMultX,y,0,base,shadow])

		# Display the final calculated stat
		textToDraw.push([statValue.to_s + statValueAddendum,statValueX,y,0,finalStatColor,shadow])

		index += 1
	end
	
	# Effects
	textToDraw.push(["Battler Effects",battlerEffectsX,statStepsSectionTopY,0,base,shadow])
	
	# Compile a descriptor for each effect on the battler or its position
	battlerEffects = []
	pushEffectDescriptorsToArray(battler,battlerEffects)
	pushEffectDescriptorsToArray(@battle.positions[battler.index],battlerEffects)

	# List abilities that were added by effects
	battler.addedAbilities.each do |abilityID|
		battlerEffects.push("Ability: #{getAbilityName(abilityID)}")
	end
	
	scrolling = true if battlerEffects.length > 8
	
	# Print all the battler effects to screen
	scrollingBoundYMin = 84
	scrollingBoundYMax = 336
	index = 0
	repeats = scrolling ? 2 : 1
	if battlerEffects.length != 0
		for repeat in 0...repeats
			battlerEffects.each do |effectName|
				index += 1
				calcedY = statStepsSectionTopY + 4 + 32 * index
				calcedY -= @battlerScrollingValue if scrolling
				next if calcedY < scrollingBoundYMin || calcedY > scrollingBoundYMax
				distanceFromFade = [calcedY - scrollingBoundYMin,scrollingBoundYMax - calcedY].min
				textAlpha = scrolling ? ([distanceFromFade / 20.0,1.0].min * 255).floor : 255
				textBase = Color.new(base.red,base.blue,base.green,textAlpha)
				textShadow = Color.new(shadow.red,shadow.blue,shadow.green,textAlpha)
				textToDraw.push([effectName,battlerEffectsX,calcedY,0,textBase,textShadow])
			end
		end
	else
		textToDraw.push(["None",battlerEffectsX,statStepsSectionTopY + 36,0,FADED_EFFECT_BASE,shadow])
	end
	
	# Reset the scrolling once its scrolled through the entire list once
	@battlerScrollingValue = 0 if @battlerScrollingValue > battlerEffects.length * 32
	
	pbDrawTextPositions(self.bitmap,textToDraw)
  end

  def pushEffectDescriptorsToArray(effectHolder,descriptorsArray)
	effectHolder.eachEffect(!DEBUGGING_EFFECT_DISPLAY) do |effect, value, effectData|
		next if !effectData.info_displayed
		effectName = effectData.real_name
		if effectData.type != :Boolean
			effectName = "#{effectName}: #{effectData.value_to_string(value,@battle)}"
		end
		descriptorsArray.push(effectName)
	end
  end
 
  def update(frameCounter=0)
    super()
    pbUpdateSpriteHash(@sprites)
	if @individual.nil?
		@battlerScrollingValue = 0
		@fieldScrollingValue += 1
	else
		@battlerScrollingValue += 1
		@fieldScrollingValue = 0
	end
  end
end