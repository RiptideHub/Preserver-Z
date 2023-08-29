#===============================================================================
#  Randomizer Functionality for vanilla Essentials
#-------------------------------------------------------------------------------
#  Randomizes compiled data instead of generating random battlers on the fly
#===============================================================================
module Randomizer
  @@randomizer = false
  @@rules = []
  #-----------------------------------------------------------------------------
  #  check if randomizer is on
  #-----------------------------------------------------------------------------
  def self.running?
    return $PokemonGlobal && $PokemonGlobal.isRandomizer
  end
  def self.on?
    return self.running? && @@randomizer
  end
  #-----------------------------------------------------------------------------
  #  get nuzlocke rules
  #-----------------------------------------------------------------------------
  def self.rules; return @@rules; end
  def self.set_rules(rules); @@rules = rules; end
  #-----------------------------------------------------------------------------
  #  toggle randomizer state
  #-----------------------------------------------------------------------------
  def self.toggle(force = nil)
    @@randomizer = force.nil? ? !@@randomizer : force
    # refresh encounter tables
    $PokemonEncounters.setup($game_map.map_id) if $PokemonEncounters
  end
  
  @@allSpeciesArray = nil
  #-----------------------------------------------------------------------------
  # get all species keys
  #-----------------------------------------------------------------------------
  def self.all_species
	if @@allSpeciesArray == nil
		echoln("Generating the species array for the randomizer!\n")
		@@allSpeciesArray = []
		GameData::Species.each { |species| @@allSpeciesArray.push(species.id) if species.form == 0 }
	end
    return @@allSpeciesArray
  end
  #-----------------------------------------------------------------------------
  # get all item keys
  #-----------------------------------------------------------------------------
  def self.all_items
    keys = []
    GameData::Item.each { |itemData|
      next unless itemData.legal?
      keys.push(itemData.id)
    }
    return keys
  end
  #-----------------------------------------------------------------------------
  #  command selection
  #-----------------------------------------------------------------------------
  def self.commandWindow(commands, index = 0, msgwindow = nil)
    ret = -1
    # creates command window
    cmdwindow = Window_CommandPokemonColor.new(commands)
    cmdwindow.index = index
    cmdwindow.x = Graphics.width - cmdwindow.width
    cmdwindow.z = 99999
    # main loop
    loop do
      # updates graphics, input and OW
      Graphics.update
      Input.update
      pbUpdateSceneMap
      # updates the two windows
      cmdwindow.update
      msgwindow.update if !msgwindow.nil?
      # updates command output
      if Input.trigger?(Input::B)
        pbPlayCancelSE
        ret = -1
        break
      elsif Input.trigger?(Input::C)
        pbPlayDecisionSE
        ret = cmdwindow.index
        break
      end
    end
    # returns command output
    cmdwindow.dispose
    return ret
  end
  
  def self.getNewSpecies(oldSpecies)
    newSpecies = nil
    attempts = 0
    while newSpecies == nil
      possibleSpecies = self.all_species.sample
      bstDiff = (effectiveBST(possibleSpecies) - effectiveBST(oldSpecies)).abs
      acceptableDiff = [10+attempts * 5,60].min
      acceptableDiff = 99999 if attempts > 1000 # Failsafe
      if !@@rules.include?(:SIMILAR_BST)
        newSpecies = possibleSpecies
      elsif bstDiff < acceptableDiff
        echoln("Acceptable BST difference between #{oldSpecies} and #{possibleSpecies}: #{bstDiff} (#{acceptableDiff})\n")
        newSpecies = possibleSpecies
      end
      attempts += 1
    end
    return newSpecies
  end
  
  #-----------------------------------------------------------------------------
  #  randomizes compiled trainer data
  #-----------------------------------------------------------------------------
  def self.randomizeTrainers
    # loads compiled data and creates new array
    data = load_data("Data/trainers.dat")
    return if !data.is_a?(Hash) # failsafe
    # iterate through each trainer
    for key in data.keys
      trainerData = data[key]
      # skip numeric trainers
      next if trainerExcluded?(trainerData.id)
      randomizeTrainer(trainerData)
    end
    return data
  end

  def self.randomizeTrainer(trainerData)
    species_exclusions = Randomizer::EXCLUSIONS_SPECIES
    # iterate through party
    for i in 0...trainerData.pokemon.length
      # don't change this species if it's an excluded one
      currentSpecies = trainerData.pokemon[i][:species]
      next if !species_exclusions.nil? && species_exclusions.include?(currentSpecies)
      trainerData.pokemon[i][:species] = self.getNewSpecies(currentSpecies)
    end
  end

  def self.trainerExcluded?(trainerID)
      return false if Randomizer::EXCLUSIONS_TRAINERS.nil?
      return Randomizer::EXCLUSIONS_TRAINERS.include?(trainerID)
  end

  #-----------------------------------------------------------------------------
  #  randomizes map encounters
  #-----------------------------------------------------------------------------
  def self.randomizeEncounters
    # loads map encounters
    data = load_data("Data/encounters.dat")
    return if !data.is_a?(Hash) # failsafe
    # iterates through each map point
    for key in data.keys
      # go through each encounter type
      for type in data[key].types.keys
        # cycle each definition
        for i in 0...data[key].types[type].length
		      # don't change this species if it's an excluded one
          currentSpecies = data[key].types[type][i][1]
          next if speciesExcluded?(currentSpecies)
		      data[key].types[type][i][1] = self.getNewSpecies(currentSpecies)
        end
      end
    end
    return data
  end

  def self.speciesExcluded?(speciesID)
    return false if Randomizer::EXCLUSIONS_SPECIES.nil?
    return Randomizer::EXCLUSIONS_SPECIES.include?(speciesID)
  end

  #-----------------------------------------------------------------------------
  #  randomizes static battles called through events
  #-----------------------------------------------------------------------------
  def self.randomizeStatic
    new = {}
    array = self.all_species.dup
    # shuffles up species indexes to load a different one
    for org in self.all_species
      newIndex = -1
      new[org] = array[i]
      array.delete_at(i)
    end
    return new
  end

  #-----------------------------------------------------------------------------
  #  randomizes items received through events
  #-----------------------------------------------------------------------------
  def self.randomizeItems
    new = {}
    item = :POTION
    # shuffles up item indexes to load a different one
    for org in self.all_items
      loop do
        item = self.all_items.sample
        break if !GameData::Item.get(item).is_key_item?
      end
      new[org] = item
    end
    return new
  end

  #-----------------------------------------------------------------------------
  #  begins the process of randomizing all data
  #-----------------------------------------------------------------------------
  def self.randomizeData
    data = {}
    # compiles hashtable with randomized values
    randomized = {
      :TRAINERS => proc{ next Randomizer.randomizeTrainers },
      :ENCOUNTERS => proc{ next Randomizer.randomizeEncounters },
      #:STATIC => proc{ next Randomizer.randomizeStatic },
      #:GIFTS => proc{ next Randomizer.randomizeStatic },
      #:ITEMS => proc{ next Randomizer.randomizeItems }
    }
    # applies randomized data for specified rule sets
    for key in @@rules
      data[key] = randomized[key].call if randomized.has_key?(key)
    end
    # return randomized data
    return data
  end
  #-----------------------------------------------------------------------------
  #  returns randomized data for specific entry
  #-----------------------------------------------------------------------------
  def self.getRandomizedData(data, symbol, index = nil)
    return data if !self.on?
    if $PokemonGlobal && $PokemonGlobal.randomizedData && $PokemonGlobal.randomizedData.has_key?(symbol)
      return $PokemonGlobal.randomizedData[symbol][index] if !index.nil?
      return $PokemonGlobal.randomizedData[symbol]
    end
    return data
  end
  #-----------------------------------------------------------------------------
  # randomizes all data and toggles on randomizer
  #-----------------------------------------------------------------------------
  def self.start(skip = false)
    ret = $PokemonGlobal && $PokemonGlobal.isRandomizer
    ret, cmd = self.randomizerSelection unless skip
    @@randomizer = true
	  pbMessage("Attempting to apply your Randomizer rules...") unless skip || cmd < 0
    # randomize data and cache it
    $PokemonGlobal.randomizedData = self.randomizeData if $PokemonGlobal.randomizedData.nil?
    $PokemonGlobal.isRandomizer = ret
    # refresh encounter tables
    $PokemonEncounters.setup($game_map.map_id) if $PokemonEncounters
    # display confirmation message
    return if skip
    msg = _INTL("Your selected Randomizer rules have been applied.")
    msg = _INTL("No Randomizer rules have been applied.") if @@rules.length < 1
    msg = _INTL("Your selection has been cancelled.") if cmd < 0
    pbMessage(msg)
  end
  #-----------------------------------------------------------------------------
  #  creates an UI to select the randomizer options
  #-----------------------------------------------------------------------------
  def self.randomizerSelection
    # list of all possible rules
    modifiers = [:TRAINERS, :ENCOUNTERS, :ITEMS, :SIMILAR_BST]
    # list of rule descriptions
    desc = [
      _INTL("Randomize Trainer Parties"),
      _INTL("Randomize Wild Encounters"),
      _INTL("Randomize Items"),
	  _INTL("Keep Similar Stat Totals")
    ]
    # default
    added = []; cmd = 0
    # creates help text message window
    msgwindow = pbCreateMessageWindow(nil, "choice 1")
    msgwindow.text = _INTL("Select the Randomizer Modes you wish to apply.")
    # main loop
    loop do
      # generates all commands
      commands = []
      for i in 0...modifiers.length
        commands.push(_INTL("{1} {2}", (added.include?(modifiers[i])) ? "[X]" : "[  ]", desc[i]))
      end
      commands.push(_INTL("Done"))
      # goes to command window
      cmd = self.commandWindow(commands, cmd, msgwindow)
	  break if cmd == commands.length - 1
      # processes return
      if cmd < 0
        if pbConfirmMessage("Do you wish to cancel the Randomizer selection?")
			added.clear
			break
		end
      end
      if cmd >= 0 && cmd < (commands.length - 1)
        if added.include?(modifiers[cmd])
          added.delete(modifiers[cmd])
        else
          added.push(modifiers[cmd])
        end
      end
    end
    # disposes of message window
    pbDisposeMessageWindow(msgwindow)
    # adds randomizer rules
    $PokemonGlobal.randomizerRules = added
    @@rules = added
    Input.update
    return (added.length > 0), cmd
  end
  #-----------------------------------------------------------------------------
  #  clear the randomizer content
  #-----------------------------------------------------------------------------
  def self.reset
    @@randomizer = false
    if $PokemonGlobal
      $PokemonGlobal.randomizedData = nil
      $PokemonGlobal.isRandomizer = nil
      $PokemonGlobal.randomizerRules = nil
    end
    $PokemonEncounters.setup($game_map.map_id) if $PokemonEncounters
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  helper functions to return randomized battlers and items
#===============================================================================
def randomizeSpecies(species, static = false, gift = false)
  return species if !Randomizer.on?
  pokemon = nil
  if species.is_a?(Pokemon)
    pokemon = species.clone
    species = pokemon.species
  end
  # if defined as an exclusion rule, species will not be randomized
  excl = Randomizer::EXCLUSIONS_SPECIES
  if !excl.nil? && excl.is_a?(Array)
    for ent in excl
      return (pokemon.nil? ? species : pokemon) if species == ent
    end
  end
  # randomizes static encounters
  species = Randomizer.getRandomizedData(species, :STATIC, species) if static
  species = Randomizer.getRandomizedData(species, :GIFTS, species) if gift
  if !pokemon.nil?
    pokemon.species = species
    pokemon.calc_stats
    pokemon.reset_moves
  end
  return pokemon.nil? ? species : pokemon
end

def randomizeItem(item)
  return item if !Randomizer.on?
  return item if GameData::Item.get(item).is_key_item?
  # if defined as an exclusion rule, species will not be randomized
  excl = Randomizer::EXCLUSIONS_ITEMS
  if !excl.nil? && excl.is_a?(Array)
    for ent in excl
      return item if item == ent
    end
  end
  return Randomizer.getRandomizedData(item, :ITEMS, item)
end
#===============================================================================
#  aliasing to return randomized battlers
#===============================================================================
alias pbBattleOnStepTaken_randomizer_x pbBattleOnStepTaken unless defined?(pbBattleOnStepTaken_randomizer_x)
def pbBattleOnStepTaken(*args)
  $rndx_non_static = true
  pbBattleOnStepTaken_randomizer_x(*args)
  $rndx_non_static = false
end
#===============================================================================
#  aliasing to randomize static battles
#===============================================================================
alias pbWildBattle_randomizer_x pbWildBattle unless defined?(pbWildBattle_randomizer_x)
def pbWildBattle(*args)
  # randomizer
  for i in [0]
    args[i] = randomizeSpecies(args[i], !$rndx_non_static)
  end
  # starts battle processing
  return pbWildBattle_randomizer_x(*args)
end

alias pbDoubleWildBattle_randomizer_x pbDoubleWildBattle unless defined?(pbDoubleWildBattle_randomizer_x)
def pbDoubleWildBattle(*args)
  # randomizer
  for i in [0, 2]
    args[i] = randomizeSpecies(args[i], !$rndx_non_static)
  end
  # starts battle processing
  return pbDoubleWildBattle_randomizer_x(*args)
end

alias pbTripleWildBattle_randomizer_x pbTripleWildBattle unless defined?(pbTripleWildBattle_randomizer_x)
def pbTripleWildBattle(*args)
  # randomizer
  for i in [0, 2, 4]
    args[i] = randomizeSpecies(args[i], !$rndx_non_static)
  end
  # starts battle processing
  return pbTripleWildBattle_randomizer_x(*args)
end
#===============================================================================
#  aliasing to randomize gifted Pokemon
#===============================================================================
alias pbAddPokemon_randomizer_x pbAddPokemon unless defined?(pbAddPokemon_randomizer_x)
def pbAddPokemon(*args)
  # randomizer
  args[0] = randomizeSpecies(args[0], false, true)
  # gives Pokemon
  return pbAddPokemon_randomizer_x(*args)
end

alias pbAddPokemonSilent_randomizer_x pbAddPokemonSilent unless defined?(pbAddPokemonSilent_randomizer_x)
def pbAddPokemonSilent(*args)
  # randomizer
  args[0] = randomizeSpecies(args[0], false, true)
  # gives Pokemon
  return pbAddPokemonSilent_randomizer_x(*args)
end
#===============================================================================
#  snipped of code used to alias the item receiving
#===============================================================================
#-----------------------------------------------------------------------------
#  item find
alias pbItemBall_randomizer_x pbItemBall unless defined?(pbItemBall_randomizer_x)
def pbItemBall(*args)
  args[0] = randomizeItem(args[0])
  return pbItemBall_randomizer_x(*args)
end
#-----------------------------------------------------------------------------
#  item receive
=begin
alias pbReceiveItem_randomizer_x pbReceiveItem unless defined?(pbReceiveItem_randomizer_x)
def pbReceiveItem(*args)
  args[0] = randomizeItem(args[0])
  return pbReceiveItem_randomizer_x(*args)
end
=end
#===============================================================================
#  additional entry to Global Metadata for randomized data storage
#===============================================================================
class PokemonGlobalMetadata
  attr_accessor :randomizedData
  attr_accessor :isRandomizer
  attr_accessor :randomizerRules
end
#===============================================================================
#  refresh cache on load
#===============================================================================
Events.onMapChange += proc { |_sender,_e|
	# refresh current cache
	if $PokemonGlobal && $PokemonGlobal.isRandomizer
		echoln("Loading randomizer data!")
		Randomizer.start(true)
		Randomizer.set_rules($PokemonGlobal.randomizerRules) if !$PokemonGlobal.randomizerRules.nil?
	end
}
#===============================================================================
#  randomize trainer data if possible
#===============================================================================
def pbLoadTrainer(tr_type, tr_name, tr_version = 0)
  # handle trainer type process
  tr_type_data = GameData::TrainerType.try_get(tr_type)
  raise _INTL("Trainer type {1} does not exist.", tr_type) if !tr_type_data
  tr_type = tr_type_data.id
  # handle actual trainer data
  trainer_data = GameData::Trainer.try_get(tr_type, tr_name, tr_version)

  # Only modify the trainer if the randomizer is on and the trainer is meant to be randomized
  if Randomizer.on? && !Randomizer.trainerExcluded?(trainer_data.id)
    key = [tr_type.to_sym, tr_name, tr_version]
    new_trainer_data = Randomizer.getRandomizedData(trainer_data, :TRAINERS, key)

    if new_trainer_data.nil?
      new_trainer_data = trainer_data.clone
      Randomizer.randomizeTrainer(new_trainer_data)
      $PokemonGlobal.randomizedData[:TRAINERS][key] = new_trainer_data
    end

    trainer_data = new_trainer_data

    # Make sure the trainer's pokemon uses the default moves for their level
    # And have no nickname or item
    trainer_data.pokemon.each do |pkmn|
      pkmn[:moves] = nil
      pkmn[:name] = nil
      pkmn[:item] = nil
    end
  end

  return trainer_data.to_trainer
end

def effectiveBST(species)
  return 500 if [:SHEDINJA,:WISHIWASHI].include?(species)
  ret = pbBaseStatTotal(species)
  ret -= 50 if [:ARCHEN,:ARCHEOPS,:SLAKOTH,:SLAKING,:REGIGIGAS]
  return ret
end

def pbBaseStatTotal(species)
  baseStats = GameData::Species.get(species).base_stats
  ret = 0
  baseStats.each { |k,v| ret += v }
  return ret
end