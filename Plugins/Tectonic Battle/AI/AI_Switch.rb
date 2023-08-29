class Integer
    def to_change
        if self > 0
            return "+" + to_s
        else
            return "-" + to_s
        end
    end
end

class PokeBattle_AI
    def pbEnemyShouldWithdraw?(idxBattler,choices=[])
        chosenPartyIndex = pbDetermineSwitch(idxBattler,choices)
        if chosenPartyIndex >= 0
            @battle.pbRegisterSwitch(idxBattler,chosenPartyIndex)
            return true
        end
        return false
    end

    def pbDetermineSwitch(idxBattler, choices = [])
        battler = @battle.battlers[idxBattler]
        owner = @battle.pbGetOwnerFromBattlerIndex(idxBattler)
        policies = owner.policies || []

        switchingBias = 0
        PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) is determining whether it should switch out")

        # Reactive matchup considerations
        # Ignore these protocols if this is an AI trainer helping you in a boss battle
        unless @battle.bossBattle? && !policies.include?(:PROACTIVE_MATCHUP_SWAPPER)
            # Figure out the effectiveness of the last move that hit it
            typeMod = battler.lastRoundHighestTypeModFromFoe
            if typeMod >= 0
                effectivenessSwitchBiasMod = 0
                if Effectiveness.hyper_effective?(typeMod)
                    effectivenessSwitchBiasMod += 20
                elsif Effectiveness.super_effective?(typeMod)
                    effectivenessSwitchBiasMod += 10
                elsif Effectiveness.not_very_effective?(typeMod)
                    effectivenessSwitchBiasMod -= 10
                elsif Effectiveness.ineffective?(typeMod)
                    effectivenessSwitchBiasMod -= 20
                end
                switchingBias += effectivenessSwitchBiasMod
                PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) takes into account the effectiveness of its last hit taken (#{effectivenessSwitchBiasMod.to_change})")
            end

            # More or less likely to switch based on if you have a good move to use
            maxScore = 0
            choices.each do |c|
                maxScore = c[1] if c[1] > maxScore
            end
            maxMoveScoreBiasChange = 40
            maxMoveScoreBiasChange -= (maxScore / 2.5).round
            switchingBias += maxMoveScoreBiasChange
            PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) max score among its #{choices.length} choices is #{maxScore} (#{maxMoveScoreBiasChange.to_change})")

            # If there is a single foe and it is resting after Hyper Beam or is
            # Truanting (i.e. free turn)
            if @battle.pbSideSize(battler.index + 1) == 1 && !battler.pbDirectOpposing.fainted?
                opposingBattler = battler.pbDirectOpposing
                unless opposingBattler.canActThisTurn?
                    switchingBias -= 20
                    PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) thinks the opposing battler can't act this turn (-20)")
                end
            end
        end

        # "Sacrificed Not Swaps" policy
        sacrificing = false
        if policies.include?(:SACS_NOT_SWAPS) && battler.hp <= battler.totalhp / 4
            switchingBias -= 10
            sacrificing = true
            PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) at or below 25% HP, so values saccing itself for tempo (-10)")
            PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) will ignore switch evaluation checks about avoiding death")
        else # Check effects that put the pokemon in danger

            # Pokémon is about to faint because of Perish Song
            if battler.effects[:PerishSong] == 1
                switchingBias += 20
                switchingBias += 20 if user.aboveHalfHealth?
                PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) is to die to perish song (+20)")
            end

            # More likely to switch when poison has worsened
            if battler.poisoned?
                poisonBias = 5 + battler.getPoisonDoublings * 20
                switchingBias += poisonBias
                PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) is poisoned at count (#{battler.getStatusCount(:POISON)}) (+#{poisonBias})")
            end

            # More likely to switch when cursed
            if battler.effectActive?(:Curse)
                switchingBias += 15
                PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) is cursed (+15)")
            end
        end

        # More likely to switch when drowsy
        if battler.effectActive?(:Yawn)
            switchingBias += 25
            PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) is drowsy (+25)")
        end
        
        # Less likely to switch when any opponent has a force switch out move
        # Even less likely if the opponent just used such a mvoe
        battler.eachOpposing do |b|
            if b.hasForceSwitchMove?
                switchingBias -= 10
                PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) has an opponent that can force swaps (-10)")
            end
        end

        # Tries to determine if its in a good or bad type matchup
        # Used for Cool Trainers
        if policies.include?(:PROACTIVE_MATCHUP_SWAPPER)
            unless sacrificing
                currentMatchupRating = rateMatchupAgainstFoes(battler, battler.pokemon, battler.pokemonIndex)
                switchingBias -= currentMatchupRating
                PBDebug.log("[AI] #{battler.pbThis} (#{battler.index}) evaluates its current matchup (#{-currentMatchupRating.to_change})")
            end
        elsif switchingBias <= 0
            PBDebug.log("[AI SWITCH] #{battler.pbThis} decides it doesn't have any reason to switch (final switching bias: #{switchingBias})")
            return -1
        end

        # Determine who to swap into if at all
        PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) is trying to find a teammate to swap into. Its switching bias is #{switchingBias}.")
        list = pbGetPartyWithSwapRatings(idxBattler)
        listSwapOutCandidates(battler, list)

        # Only considers swapping into pokemon whose rating would be at least a +25 upgrade
        upgradeThreshold = 25
        upgradeThreshold -= 10 if owner.tribalBonus.hasTribeBonus?(:CHARMER)
        list.delete_if { |val| !@battle.pbCanSwitch?(idxBattler, val[0]) || (switchingBias + val[1] < upgradeThreshold) }

        if list.length > 0
            partySlotNumber = list[0][0]
            if @battle.pbCanSwitch?(idxBattler, partySlotNumber)
                PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{idxBattler}) will switch with #{@battle.pbParty(idxBattler)[partySlotNumber].name}")
                return partySlotNumber
            end
        else
            PBDebug.log("[AI SWITCH] #{battler.pbThis} (#{battler.index}) fails to find any swap candidates.")
        end
        return -1
    rescue StandardError => exception
        echoln("FAILURE ENCOUNTERED IN pbDetermineSwitch FOR BATTLER INDEX #{idxBattler}")
        return -1
    end

    def pbDefaultChooseNewEnemy(idxBattler, _party)
        list = pbGetPartyWithSwapRatings(idxBattler)
        list.delete_if { |val| !@battle.pbCanSwitchLax?(idxBattler, val[0]) }
        if list.length != 0
            listSwapOutCandidates(@battle.battlers[idxBattler], list)
            return list[0][0]
        end
        return -1
    end

    def getRoughAttackingTypes(battler)
        return nil if battler.fainted?
        attackingTypes = [battler.pokemon.type1, battler.pokemon.type2]
        unless battler.lastMoveUsed.nil?
            moveData = GameData::Move.get(battler.lastMoveUsed)
            attackingTypes.push(moveData.type)
        end
        attackingTypes.uniq!
        attackingTypes.compact!
        return attackingTypes
    end

    def getPartyMemberAttackingTypes(pokemon)
        attackingTypes = []

        pokemon.moves.each do |move|
            next if move.category == 2 # Status
            attackingTypes.push(move.type)
        end

        attackingTypes.uniq!
        attackingTypes.compact!
        return attackingTypes
    end

    def listSwapOutCandidates(battler, list)
        PBDebug.log("[AI] #{battler.pbThis} (#{battler.index}) swap out candidates are:")
        list.each do |listEntry|
            enemyTrainer = @battle.pbGetOwnerFromBattlerIndex(battler.index)
            allyPokemon = enemyTrainer.party[listEntry[0]]
            next if allyPokemon.nil?
            PBDebug.log("#{allyPokemon.name || "Party member #{listEntry[0]}"}: #{listEntry[1]}")
        end
    end

    # Rates every other Pokemon in the trainer's party and returns a sorted list of the indices and swap in rating
    def pbGetPartyWithSwapRatings(idxBattler)
        list = []
        battlerSlot = @battle.battlers[idxBattler]

        policies = battlerSlot.ownersPolicies

        @battle.pbParty(idxBattler).each_with_index do |pkmn, partyIndex|
            next unless pkmn.able?
            next if battlerSlot.pokemonIndex == partyIndex

            switchScore = 0

            # Account for hazards
            unless GameData::Ability::HAZARD_IMMUNITY_ABILITIES.include?(pkmn.ability) && !@battle.abilitiesNeutralized?
                # Determine if the pokemon will be airborne
                airborne = pkmn.hasType?(:FLYING) || pkmn.hasAbility?(:LEVITATE) || pkmn.hasItem?(LEVITATION_ITEMS)
                airborne = false if @battle.field.effectActive?(:Gravity)
                airborne = false if pkmn.hasItem?(:IRONBALL)

                willAbsorbSpikes = false

                # Calculate how much damage the pokemon is likely to take from entry hazards
                entryDamage = 0
                if !airborne && pkmn.ability != :MAGICGUARD && pkmn.hasItem?(:HEAVYDUTYBOOTS)
                    # Spikes
                    spikesCount = battlerSlot.pbOwnSide.countEffect(:Spikes)
                    if spikesCount > 0
                        spikesDenom = [8, 6, 4][spikesCount - 1]
                        entryDamage += pkmn.totalhp / spikesDenom
                    end

                    # Stealth Rock
                    if battlerSlot.pbOwnSide.effectActive?(:StealthRock)
                        types = pkmn.types
                        stealthRockHPRatio = @battle.getTypedHazardHPRatio(:ROCK, types[0], types[1] || nil)
                        entryDamage += pkmn.totalhp * stealthRockHPRatio
                    end

                    # Feather Ward
                    if battlerSlot.pbOwnSide.effectActive?(:FeatherWard)
                        types = pkmn.types
                        featherWardHPRatio = @battle.getTypedHazardHPRatio(:STEEL, types[0], types[1] || nil)
                        entryDamage += pkmn.totalhp * featherWardHPRatio
                    end

                    # Each of the status setting spikes
                    battlerSlot.pbOwnSide.eachEffect(true) do |_effect, value, data|
                        next unless data.is_status_hazard?
                        hazardInfo = data.status_applying_hazard

                        if hazardInfo[:absorb_proc].call(pkmn)
                            willAbsorbSpikes = true
                        else
                            statusSpikesDenom = [16, 4][value - 1]
                            entryDamage += pkmn.totalhp / statusSpikesDenom
                        end
                    end
                end

                # Try not to swap in pokemon who will die to entry hazard damage
                if pkmn.hp <= entryDamage
                    switchScore -= 80
                    dieingOnEntry = true
                elsif willAbsorbSpikes
                    switchScore += 30
                else
                    switchScore -= ((entryDamage / pkmn.totalhp.to_f) * 80).floor
                end
            end

            # Analyze the player's active battlers to their susceptibility to being debuffed
            attackDebuffers = 0
            specialDebuffers = 0
            speedDebuffers = 0
            battlerSlot.eachOpposing do |opposingBattler|
                next if opposingBattler.hasActiveAbilityAI?(%i[INNERFOCUS HEARTENINGAROMA])
                if opposingBattler.hasActiveAbilityAI?(%i[CONTRARY ECCENTRIC])
                    attackDebuffers -= 1
                    specialDebuffers -= 1
                    speedDebuffers -= 1
                else
                    if opposingBattler.hasPhysicalAttack? && opposingBattler.steps[:ATTACK] > -2 && opposingBattler.pbCanLowerStatStep?(:ATTACK)
                        attackDebuffers += 1
                    end
                    if opposingBattler.hasSpecialAttack? && opposingBattler.steps[:SPECIAL_ATTACK] > -2 && opposingBattler.pbCanLowerStatStep?(:SPECIAL_ATTACK)
                        specialDebuffers += 1
                    end
                    if opposingBattler.pbSpeed > pkmn.speed && opposingBattler.pbCanLowerStatStep?(:SPEED)
                        speedDebuffers += 1
                    end
                end
            end

            # More want to swap if has a entry ability that matters
            # Intentionally checked even if the pokemon will die on entry
            settingSun = @battle.pbWeather != :Sun && policies.include?(:SUN_TEAM)
            settingRain = @battle.pbWeather != :Rain && policies.include?(:RAIN_TEAM)
            settingHail = @battle.pbWeather != :Hail && policies.include?(:HAIL_TEAM)
            settingSand = @battle.pbWeather != :Sandstorm && policies.include?(:SAND_TEAM)
            settingEclipse = @battle.pbWeather != :Eclipse && policies.include?(:ECLIPSE_TEAM)
            settingMoonglow = @battle.pbWeather != :Moonglow && policies.include?(:MOONGLOW_TEAM)
            alliesInReserve = battlerSlot.alliesInReserveCount

            case pkmn.ability
            when :INTIMIDATE
                switchScore += attackDebuffers * 10
            when :FASCINATE
                switchScore += specialDebuffers * 10
            when :FRUSTRATE
                switchScore += speedDebuffers * 10
            when :DROUGHT, :INNERLIGHT
                switchScore += alliesInReserve * 8 if settingSun
            when :DRIZZLE, :STORMBRINGER
                switchScore += alliesInReserve * 8 if settingRain
            when :SNOWWARNING, :FROSTSCATTER
                switchScore += alliesInReserve * 8 if settingHail
            when :SANDSTREAM, :SANDBURST
                switchScore += alliesInReserve * 8 if settingSand
            when :MOONGAZE, :LUNARLOYALTY
                switchScore += alliesInReserve * 8 if settingMoonglow
            when :HARBINGER, :SUNEATER
                switchScore += alliesInReserve * 8 if settingEclipse
            end

            # Only matters if the pokemon will live
            unless dieingOnEntry
                # Find the worst type matchup against the current player battlers
                switchScore += rateMatchupAgainstFoes(battlerSlot, pkmn, partyIndex)
            end

            # For preserving the pokemon placed in the last slot
            if policies.include?(:PRESERVE_LAST_POKEMON) && partyIndex == @battle.pbParty(idxBattler).length - 1
                switchScore = -1000
            end

            list.push([partyIndex, switchScore])
        end
        list.sort_by! { |entry| entry[1].nil? ? 99999 : -entry[1] }
        return list
    end

    # The pokemon passed in could be be the pokemon in the given battler slot, or somewhere in the party
    def rateMatchupAgainstFoes(battlerSlot, pokemon, partyIndex)
        matchups = []
        battlerSlot.eachOpposing do |opposingBattler|
            matchup = rateMatchup(battlerSlot, pokemon, partyIndex, getRoughAttackingTypes(opposingBattler))
            matchups.push(matchup)
        end
        if matchups.empty?
            return 0
        else
            return matchups.min
        end
    end

    # The pokemon passed in could be be the pokemon in the given battler slot, or somewhere in the party
    def rateMatchup(battlerSlot, pokemon, partyIndex, attackingtypes = nil)
        typeModDefensive = Effectiveness::NORMAL_EFFECTIVE

        # Get the worse defensive type mod among any of the given types
        typeModDefensive = pbCalcMaxOffensiveTypeMod(attackingtypes, pokemon) unless attackingtypes.nil?

        matchupScore = 0
        # Modify the type matchup score based on the defensive matchup
        if Effectiveness.ineffective?(typeModDefensive)
            matchupScore += 40
        elsif Effectiveness.not_very_effective?(typeModDefensive)
            matchupScore += 20
        elsif Effectiveness.hyper_effective?(typeModDefensive)
            matchupScore -= 40
        elsif Effectiveness.super_effective?(typeModDefensive)
            matchupScore -= 20
        end

        maxScore = highestMoveScoreForHypotheticalBattle(battlerSlot,pokemon,partyIndex)
        maxMoveScoreBiasChange = -40
        maxMoveScoreBiasChange += (maxScore / 2.5).round
        matchupScore += maxMoveScoreBiasChange

        return matchupScore
    end

    def pbCalcMaxOffensiveTypeMod(attackingTypes, victimPokemon)
        victimPokemon = victimPokemon.disguisedAs if victimPokemon.is_a?(PokeBattle_Battler) && victimPokemon.illusion?
        maxTypeMod = 0
        attackingTypes.each do |attackingType|
            mod = Effectiveness.calculate(attackingType, victimPokemon.type1, victimPokemon.type2)
            maxTypeMod = mod if mod > maxTypeMod
        end
        return maxTypeMod
    end

    def highestMoveScoreForHypotheticalBattle(battlerSlot,pokemon,partyIndex)
        fakeBattler = battlerSlot.clone
        fakeBattler.pbInitPokemon(pokemon,partyIndex)
        choices = pbGetBestTrainerMoveChoices(fakeBattler, fakeBattler.ownersPolicies)

        maxScore = 0
        choices.each do |c|
            maxScore = c[1] if c[1] > maxScore
        end
        return maxScore
    end
end
