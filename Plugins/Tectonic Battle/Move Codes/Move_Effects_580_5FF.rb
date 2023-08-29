#===============================================================================
# Transfers the user's status to the target (Vicious Cleaning)
#===============================================================================
class PokeBattle_Move_580 < PokeBattle_Move
    def pbEffectAgainstTarget(user, target)
        user.getStatuses.each do |status|
            next if status == :NONE
            if target.pbCanInflictStatus?(status, user, false, self)
                case status
                when :SLEEP
                    target.applySleep
                when :POISON
                    target.applyPoison(user, nil, user.statusCount != 0)
                when :BURN
                    target.applyBurn(user)
                when :NUMB
                    target.applyNumb(user)
                when :FROSTBITE
                    target.applyFrostbite(user)
                when :DIZZY
                    target.applyDizzy(user)
                when :LEECHED
                    target.applyLeeched(user)
                end
            else
                statusData = GameData::Status.get(status)
                @battle.pbDisplay(_INTL("{1} tries to transfer its {2} to {3}, but...", user.pbThis, statusData.real_name,
target.pbThis(true)))
                target.pbCanInflictStatus?(status, user, true, self)
            end
            user.pbCureStatus(status)
        end
    end

    def shouldHighlight?(user, _target)
        return user.pbHasAnyStatus?
    end
end

#===============================================================================
# Puts the target to sleep if they are slower, then minimizes the user's speed. (Sedating Dust)
#===============================================================================
class PokeBattle_Move_581 < PokeBattle_SleepMove
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.pbSpeed > user.pbSpeed
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is slower than #{target.pbThis(true)}!"))
            end
            return true
        end
        return !target.canSleep?(user, show_message, self)
    end

    def pbEffectAgainstTarget(user, target)
        target.applySleep
        user.pbMinimizeStatStep(:SPEED, user, self)
    end

    def getEffectScore(user, target)
        score = -30
        score -= user.steps[:SPEED] * 5
        return score
    end
end

#===============================================================================
# For 5 rounds, swaps all battlers' offensive and defensive stats (Sp. Def <-> Sp. Atk and Def <-> Atk).
# (Odd Room)
#===============================================================================
class PokeBattle_Move_582 < PokeBattle_RoomMove
    def initialize(battle, move)
        super
        @roomEffect = :OddRoom
    end
end

#===============================================================================
# Restores health by 50% and raises Speed by one step. (Mulch Meal)
#===============================================================================
class PokeBattle_Move_583 < PokeBattle_HalfHealingMove
    def pbMoveFailed?(user, _targets, show_message)
        if !user.canHeal? && !user.pbCanRaiseStatStep?(:SPEED, user, self, true)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} can't heal or raise its Speed!")) if show_message
            return true
        end
    end

    def pbEffectGeneral(user)
        super
        user.tryRaiseStat(:SPEED, user, move: self)
    end

    def getEffectScore(user, target)
        score = super
        score += 20
        score -= user.steps[:SPEED] * 20
        return score
    end
end

#===============================================================================
# Raises the target's worst three stats by one step each. (Guiding Aroma)
#===============================================================================
class PokeBattle_Move_584 < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if statUp(user, target).length == 0
            @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!", target.pbThis)) if show_message
            return true
        end
        return false
    end

    def statUp(user, target)
        statsTargetCanRaise = target.finalStats.select do |stat, _finalValue|
            next target.pbCanRaiseStatStep?(stat, user, self)
        end
        statsRanked = statsTargetCanRaise.sort_by { |_s, v| v }.to_h.keys
        statUp = []
        statsRanked.each_with_index do |stat, index|
            break if index > 2
            statUp.push(stat)
            statUp.push(1)
        end
        return statUp
    end

    def pbEffectAgainstTarget(user, target)
        target.pbRaiseMultipleStatSteps(statUp(user, target), user, move: self)
    end

    def getEffectScore(user, target)
        return 0 if statUp(user, target).length == 0
        return getMultiStatUpEffectScore(statUp(user, target), user, target)
    end
end

#===============================================================================
# Raises the user's Sp. Atk by 2 steps, and the user's attacks become spread. (Flare Witch)
#===============================================================================
class PokeBattle_Move_585 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.effectActive?(:FlareWitch) && !user.pbCanRaiseStatStep?(:SPECIAL_ATTACK, user, self, true)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} can't raise its Sp. Atk and already activated its witch powers!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.tryRaiseStat(:SPECIAL_ATTACK, user, move: self, increment: 3)
        user.applyEffect(:FlareWitch)
    end

    def getEffectScore(user, target)
        score = getMultiStatUpEffectScore([:SPECIAL_ATTACK,2], user, target)
        score += 30 unless user.effectActive?(:FlareWitch)
        return score
    end
end

#===============================================================================
# Effectiveness against Fighting-type is 2x. (Honorless Sting)
#===============================================================================
class PokeBattle_Move_586 < PokeBattle_Move
    def pbCalcTypeModSingle(moveType, defType, user, target)
        return Effectiveness::SUPER_EFFECTIVE_ONE if defType == :FIGHTING
        return super
    end
end

#===============================================================================
# Resets all stat steps at end of turn and at the end of the next four turns. (Grey Mist)
#===============================================================================
class PokeBattle_Move_587 < PokeBattle_Move
    def pbEffectGeneral(_user)
        @battle.field.applyEffect(:GreyMist, 5)
    end

    def pbMoveFailed?(_user, _targets, show_message)
        if @battle.field.effectActive?(:GreyMist)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since the field is already shrouded in Grey Mist!"))
            end
            return true
        end
        return false
    end

    def getEffectScore(user, _target)
        score = 20
        @battle.eachBattler do |b|
            totalSteps = 0
            GameData::Stat.each_battle { |s| totalSteps += b.steps[s.id] }
            if b.opposes?(user)
                score += totalSteps * 20
                score += getSetupLikelihoodScore(user)
            else
                score -= totalSteps * 20
                score -= getSetupLikelihoodScore(user)
            end
        end
        return score
    end
end

#===============================================================================
# If it faints the target, you gain lots of money after the battle. (Plunder)
#===============================================================================
class PokeBattle_Move_588 < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        return unless target.damageState.fainted
        @battle.field.incrementEffect(:PayDay, 10 * user.level) if user.pbOwnedByPlayer?
    end
end

#===============================================================================
# Attacks two to five times. Gains money for each hit. (Sacred Lots)
#===============================================================================
class PokeBattle_Move_589 < PokeBattle_Move_0C0
    def pbEffectOnNumHits(user, _target, numHits)
        coinsGenerated = 2 * user.level * numHits
        @battle.field.incrementEffect(:PayDay, coinsGenerated) if user.pbOwnedByPlayer?
        if numHits == 10
            @battle.pbDisplay(_INTL("How fortunate!"))
        elsif numHits == 0
            @battle.pbDisplay(_INTL("How unfortunate! Better luck next time."))
        end
    end
end

#===============================================================================
# Power is tripled if the target is poisoned. (Vipershock)
#===============================================================================
class PokeBattle_Move_58A < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 3 if target.poisoned?
        return baseDmg
    end
end

#===============================================================================
# Counts as a use of Rock Roll, Snowball, or Furycutter. (On A Roll)
#===============================================================================
class PokeBattle_Move_58B < PokeBattle_Move
    def pbChangeUsageCounters(user, specialUsage)
        oldEffectValues = {}
        user.eachEffect(true) do |effect, value, data|
            oldEffectValues[effect] = value if data.snowballing_move_counter?
        end
        super
        oldEffectValues.each do |effect, oldValue|
            data = GameData::BattleEffect.get(effect)
            user.effects[effect] = [oldValue + 1, data.maximum].min
        end
    end
end

#===============================================================================
# The user's Speed raises 4 steps, and it gains the Flying-type. (Mach Flight)
#===============================================================================
class PokeBattle_Move_58C < PokeBattle_Move_030
    def pbMoveFailed?(user, targets, show_message)
        return false if GameData::Type.exists?(:FLYING) && !user.pbHasType?(:FLYING) && user.canChangeType?
        super
    end

    def pbEffectGeneral(user)
        super
        user.applyEffect(:Type3, :FLYING)
    end
end

#===============================================================================
# Guaranteed to crit, but lowers the user's speed. (Incision)
#===============================================================================
class PokeBattle_Move_58D < PokeBattle_Move_03E
    def pbCriticalOverride(_user, _target); return 1; end
end

#===============================================================================
# Returns user to party for swap and lays a layer of spikes. (Caltrop Style)
#===============================================================================
class PokeBattle_Move_58E < PokeBattle_Move_0EE
    def pbMoveFailed?(user, _targets, show_message)
        return false if damagingMove?
        if user.pbOpposingSide.effectAtMax?(:Spikes)
            @battle.pbDisplay(_INTL("But it failed, since there is no room for more Spikes!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        return if damagingMove?
        user.pbOpposingSide.incrementEffect(:Spikes)
    end

    def pbAdditionalEffect(user, _target)
        return unless damagingMove?
        return if user.pbOpposingSide.effectAtMax?(:Spikes)
        user.pbOpposingSide.incrementEffect(:Spikes)
    end

    def getTargetAffectingEffectScore(user, target)
        return getHazardSettingEffectScore(user, target) unless user.pbOpposingSide.effectAtMax?(:Spikes)
    end
end

#===============================================================================
# Faints the opponant if they are below 1/4 HP, after dealing damage. (Cull)
#===============================================================================
class PokeBattle_Move_58F < PokeBattle_Move
    def canCull?(target)
        return target.hp < (target.totalhp / 4)
    end

    def pbEffectAgainstTarget(user, target)
        if canCull?(target)
            @battle.pbDisplay(_INTL("#{user.pbThis} culls #{target.pbThis(true)}!"))
            target.pbReduceHP(target.hp, false)
            target.pbItemHPHealCheck
        end
    end

    def shouldHighlight?(_user, target)
        return canCull?(target)
    end
end

#===============================================================================
# The user, if a Deerling or Sawsbuck, changes their form in season order. (Season's End)
#===============================================================================
class PokeBattle_Move_590 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.countsAs?(:DEERLING) || user.countsAs?(:SAWSBUCK)
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis)) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        if user.countsAs?(:DEERLING) || user.countsAs?(:SAWSBUCK)
            newForm = (user.form + 1) % 4
            formChangeMessage = _INTL("The season shifts!")
            user.pbChangeForm(newForm, formChangeMessage)
        end
    end
end

#===============================================================================
# Power increases the taller the user is than the target. (Cocodrop)
#===============================================================================
class PokeBattle_Move_591 < PokeBattle_Move
    def pbBaseDamage(_baseDmg, user, target)
        ret = 40
        ratio = user.pbHeight.to_f / target.pbHeight.to_f
        ratio = 10 if ratio > 10
        ret += ((16 * (ratio**0.75)) / 5).floor * 5
        return ret
    end
end

#===============================================================================
# Does Dragon-Darts style hit redirection, plus
# each target hit loses 1 step of Speed. (Tar Volley)
#===============================================================================
class PokeBattle_Move_592 < PokeBattle_Move_17C
    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.tryLowerStat(:SPEED, user, move: self)
    end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# attacks with the user with a special attack while this effect applies, that Pokémon
# takes 1/8th chip damage. (Mirror Shield)
#===============================================================================
class PokeBattle_Move_593 < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :MirrorShield
    end

    def getEffectScore(user, target)
        score = super
        # Check only special attackers
        user.eachPredictedProtectHitter(1) do |_b|
            score += 20
        end
        return score
    end
end

#===============================================================================
# Power doubles if has the Defense Curl effect, which it consumes. (Unfurl)
#===============================================================================
class PokeBattle_Move_594 < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, _target)
        baseDmg *= 2 if user.effectActive?(:DefenseCurl)
        return baseDmg
    end

    def pbEffectAfterAllHits(user, _target)
        user.disableEffect(:DefenseCurl)
    end
end

#===============================================================================
# User's Attack and Defense are raised by one step each, and changes user's type to Rock. (Built Different)
#===============================================================================
class PokeBattle_Move_595 < PokeBattle_Move_024
    def pbMoveFailed?(user, targets, show_message)
        return false if GameData::Type.exists?(:ROCK) && !user.pbHasType?(:ROCK) && user.canChangeType?
        super
    end

    def pbEffectGeneral(user)
        super
        user.applyEffect(:Type3, :ROCK)
    end
end

#===============================================================================
# The target cannot escape and takes 50% more damage from all attacks. (Death Mark)
#===============================================================================
class PokeBattle_Move_596 < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effectActive?(:DeathMark)
            @battle.pbDisplay(_INTL("But it failed, since the target is already marked for death!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.pointAt(:DeathMark, user) unless target.effectActive?(:DeathMark)
    end
end

#===============================================================================
# User's side takes 50% less attack damage this turn. (Bulwark)
#===============================================================================
class PokeBattle_Move_597 < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect      = :Bulwark
        @sidedEffect = true
    end

    def pbProtectMessage(user)
        @battle.pbDisplay(_INTL("{1} spread its arms to guard {2}!", @name, user.pbTeam(true)))
    end
end

#===============================================================================
# The user picks between moves to use, those being the 3 last moves used by any foe. (Cross Examine)
#===============================================================================
class PokeBattle_Move_598 < PokeBattle_Move
    def resolutionChoice(user)
        @chosenMoveID = :STRUGGLE
        validMoves = validMoveArray(user)
        moveChoices = []
        validMoves.reverse.each do |moveID|
            next if moveChoices.include?(moveID)
            moveChoices.push(moveID)
            break if moveChoices.length == 3
        end

        moveNames = []
        moveChoices.each do |moveID|
            moveNames.push(GameData::Move.get(moveID).real_name)
        end
        if moveChoices.length == 1
            @chosenMoveID = moveChoices[0]
        elsif moveChoices.length > 1
            if @battle.autoTesting
                @chosenMoveID = moveChoices.sample
            elsif !user.pbOwnedByPlayer? # Trainer AI
                @chosenMoveID = moveChoices[0]
            else
                chosenIndex = @battle.scene.pbShowCommands(_INTL("Which move should #{user.pbThis(true)} use?"),moveNames,0)
                @chosenMoveID = moveChoices[chosenIndex]
            end
        end
    end

    def validMoveArray(user)
        if user.opposes?
            return @battle.allMovesUsedSide0
        else
            return @battle.allMovesUsedSide1
        end
    end

    def pbMoveFailed?(user, targets, show_message)
        if validMoveArray(user).empty?
            @battle.pbDisplay(_INTL("But it failed, since no foe has yet used a move!")) if show_message
            return true
        end
        super
    end

    def pbEffectGeneral(user)
        user.pbUseMoveSimple( @chosenMoveID)
    end

    def resetMoveUsageState
        @chosenMoveID = nil
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Cross-Examine.")
        return 0
    end
end

#===============================================================================
# User takes recoil damage equal to 1/5 of the damage this move dealt.
#===============================================================================
class PokeBattle_Move_599 < PokeBattle_RecoilMove
    def recoilFactor; return 0.2; end
end

#===============================================================================
# Burns the target and sets Sun
#===============================================================================
class PokeBattle_Move_59A < PokeBattle_InvokeMove
    def initialize(battle, move)
        super
        @weatherType = :Sun
        @durationSet = 4
        @statusToApply = :BURN
    end
end

#===============================================================================
# Numbs the target and sets Rain
#===============================================================================
class PokeBattle_Move_59B < PokeBattle_InvokeMove
    def initialize(battle, move)
        super
        @weatherType = :Rain
        @durationSet = 4
        @statusToApply = :NUMB
    end
end

#===============================================================================
# Frostbites the target and sets Hail
#===============================================================================
class PokeBattle_Move_59C < PokeBattle_InvokeMove
    def initialize(battle, move)
        super
        @weatherType = :Hail
        @durationSet = 4
        @statusToApply = :FROSTBITE
    end
end

#===============================================================================
# Dizzies the target and sets Sandstorm
#===============================================================================
class PokeBattle_Move_59D < PokeBattle_InvokeMove
    def initialize(battle, move)
        super
        @weatherType = :Sandstorm
        @durationSet = 4
        @statusToApply = :DIZZY
    end
end

#===============================================================================
# Revives a fainted party member back to 1 HP. (Defibrillate)
#===============================================================================
class PokeBattle_Move_59E < PokeBattle_PartyMemberEffectMove
    def legalChoice(pokemon)
        return false unless super
        return false unless pokemon.fainted?
        return true
    end

    def effectOnPartyMember(pokemon)
        pokemon.heal
        pokemon.hp = 1
        @battle.pbDisplay(_INTL("{1} recovered to 1 HP!", pokemon.name))
    end
end

#===============================================================================
# Decreases the target's Attack and Special Attack by 1 step each. (Singing Stone)
#===============================================================================
class PokeBattle_Move_59F < PokeBattle_TargetMultiStatDownMove
    def initialize(battle, move)
        super
        @statDown = ATTACKING_STATS_1
    end
end

#===============================================================================
# Type effectiveness is multiplied by the Ice-type's effectiveness against
# the target. (Feverish Gas)
#===============================================================================
class PokeBattle_Move_5A0 < PokeBattle_Move
    def pbCalcTypeModSingle(moveType, defType, user, target)
        ret = super
        if GameData::Type.exists?(:ICE)
            iceEffectiveness = Effectiveness.calculate_one(:ICE, defType)
            ret *= iceEffectiveness.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
        end
        return ret
    end
end

#===============================================================================
# Entry hazard. Lays Feather Ward on the opposing side. (Feather Ward)
#===============================================================================
class PokeBattle_Move_5A1 < PokeBattle_Move
    def hazardMove?; return true; end
    def aiAutoKnows?(pokemon); return true; end

    def pbMoveFailed?(user, _targets, show_message)
        if user.pbOpposingSide.effectActive?(:FeatherWard)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since sharp feathers already float around the opponent!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.pbOpposingSide.applyEffect(:FeatherWard)
    end

    def getEffectScore(user, target)
        return getHazardSettingEffectScore(user, target)
    end
end

#===============================================================================
# Decreases the user's Sp. Def.
# Increases the user's Sp. Atk by 1 step, and Speed by 2 steps.
# (Shed Coat)
#===============================================================================
class PokeBattle_Move_5A2 < PokeBattle_StatUpDownMove
    def initialize(battle, move)
        super
        @statUp   = [:SPEED, 3, :SPECIAL_ATTACK, 3]
        @statDown = [:SPECIAL_DEFENSE, 2]
    end
end

#===============================================================================
# Decreases the user's Speed by 3 steps. (Razor Plunge)
#===============================================================================
class PokeBattle_Move_5A3 < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 3]
    end
end

#===============================================================================
# The next ground type move to hit the target deals double damage. (Volatile Toxin)
#===============================================================================
class PokeBattle_Move_5A4 < PokeBattle_Move
    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:VolatileToxin)
    end
end

#===============================================================================
# User is protected against moves with the "B" flag this round. If a Pokémon
# attacks the user while this effect applies, that Pokémon become leeched.
# (Root Haven)
#===============================================================================
class PokeBattle_Move_5A5 < PokeBattle_HalfProtectMove
    def initialize(battle, move)
        super
        @effect = :RootShelter
    end

    def getOnHitEffectScore(user,target)
        return getLeechEffectScore(user, target)
    end
end

#===============================================================================
# User must use this move for 2 more rounds. Raises Speed if KOs. (Tyrant's Fit)
#===============================================================================
class PokeBattle_Move_5A6 < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        user.applyEffect(:Outrage, 3) if !target.damageState.unaffected && !user.effectActive?(:Outrage)
        user.tickDownAndProc(:Outrage)
        return unless target.damageState.fainted
        user.tryRaiseStat(:SPEED, user, increment: 1, move: self)
    end

    def getFaintEffectScore(user, target)
        return getMultiStatUpEffectScore([:SPEED, 1], user, user)
    end
end

#===============================================================================
# Two turn attack. Skips first turn, and transforms the user into their second form
# on the 2nd turn. Only ampharos can use it. (Transcendant Energy)
#===============================================================================
class PokeBattle_Move_5A7 < PokeBattle_TwoTurnMove
    def pbMoveFailed?(user, _targets, show_message)
        if !user.countsAs?(:AMPHAROS)
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        elsif user.form != 0
            @battle.pbDisplay(_INTL("But {1} can't use it the way it is now!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} is radiating energy!", user.pbThis))
    end

    def pbEffectGeneral(user)
        return unless @damagingTurn
        user.pbChangeForm(1, _INTL("{1} transcended its limits and transformed!", user.pbThis))
    end

    def getEffectScore(user, _target)
        score = super
        score += 100
        score += 50 if user.firstTurn?
        return score
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        if @chargingTurn && !@damagingTurn
            @battle.pbCommonAnimation("StatUp", user)
        else
            @battle.pbCommonAnimation("MegaEvolution", user)
            super
        end
    end
end

#===============================================================================
# Target is forced to hold a Black Sludge, dropping its item if neccessary. (Trash Treasure)
# Also lower's the target's Sp. Def.
#===============================================================================
class PokeBattle_Move_5A8 < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if !target.canAddItem?(:BLACKSLUDGE) && !canRemoveItem?(user, target, target.firstItem) && target.pbCanLowerStatStep?(:SPECIAL_DEFENSE,user,self)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis} can't be given a Black Sludge or have its Sp. Def lowered!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        giveSludge = false
        if target.canAddItem?(:BLACKSLUDGE)
            giveSludge = true
        else
            removedAny = false
            target.eachItemWithName do |item, itemName|
                next if item == :BLACKSLUDGE
                next unless canRemoveItem?(user, target, item)
                target.removeItem(item)
                @battle.pbDisplay(_INTL("{1} dropped its {2}!", target.pbThis, itemName))
                removedAny = true
                break
            end

            giveSludge = true if removedAny
        end

        if giveSludge
            @battle.pbDisplay(_INTL("{1} was forced to hold a {2}!", target.pbThis, getItemName(:BLACKSLUDGE)))
            target.giveItem(:BLACKSLUDGE)
        end
        
        target.tryLowerStat(:SPECIAL_DEFENSE, user, move: self)
    end
end

#===============================================================================
# Power increases by 20 for each consecutive use. User heals by 50% of damage dealt. (Hearth Rhythm)
#===============================================================================
class PokeBattle_Move_5A9 < PokeBattle_SnowballingMove
    def initialize(battle, move)
        @usageCountEffect = :HeartRhythm
        super
    end

    def damageAtCount(baseDmg, count)
        return baseDmg + 20 * count
    end

    def healingMove?; return true; end

    def drainFactor(_user, _target); return 0.5; end

    def pbEffectAgainstTarget(user, target)
        return if target.damageState.hpLost <= 0
        hpGain = (target.damageState.hpLost * drainFactor(user, target)).round
        user.pbRecoverHPFromDrain(hpGain, target)
    end
end

#===============================================================================
# Reduce's the target's highest attacking stat. (Scale Glint)
#===============================================================================
class PokeBattle_Move_5AA < PokeBattle_Move
    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        if target.pbAttack > target.pbSpAtk
            target.pbLowerMultipleStatSteps([:ATTACK,1], user, move: self)
        else
            target.pbLowerMultipleStatSteps([:SPECIAL_ATTACK,1], user, move: self)
        end
    end

    def getTargetAffectingEffectScore(user, target)
        if target.pbAttack > target.pbSpAtk
            statDownArray = [:ATTACK,1]
        else
            statDownArray = [:SPECIAL_ATTACK,1]
        end
        return getMultiStatDownEffectScore(statDownArray, user, target)
    end
end

#===============================================================================
# User's Defense and Sp. Def are raised. Then, it heals itself based on (Refurbish)
# current weight. Then, its current weigtht is cut in half.
#===============================================================================
class PokeBattle_Move_5AB < PokeBattle_HealingMove
    def pbMoveFailed?(user, _targets, show_message)
        if !user.canHeal? && !user.pbCanRaiseStatStep?(:DEFENSE, user, self) &&
           !user.pbCanRaiseStatStep?(:SPECIAL_DEFENSE, user, self)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} can't heal or raise either of its defensive stats!}!")) if show_message
            return true
        end
        return false
    end

    def healRatio(user)
        case user.pbWeight
        when 1024..999_999
            return 1.0
        when 512..1023
            return 0.75
        when 256..511
            return 0.5
        when 128..255
            return 0.25
        when 64..127
            return 0.125
        else
            return 0.0625
        end
    end

    def pbEffectGeneral(user)
        user.pbRaiseMultipleStatSteps(DEFENDING_STATS_2, user, move: self)
        super
        user.incrementEffect(:Refurbished)
    end
end

#===============================================================================
# Leeches or numbs the target, depending on how its speed compares to the user.
# (Mystery Seed)
#===============================================================================
class PokeBattle_Move_5AC < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        return false if damagingMove?
        if !target.canLeech?(user, show_message, self) && !target.canNumb?(user, show_message, self)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can neither be leeched or numbed!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        return if damagingMove?
        leechOrNumb(user, target)
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        leechOrNumb(user, target)
    end

    def leechOrNumb(user, target)
        target_speed = target.pbSpeed
        user_speed = user.pbSpeed

        if target.canNumb?(user, false, self) && target_speed >= user_speed
            target.applyNumb(user)
        elsif target.canLeech?(user, false, self) && user_speed >= target_speed
            target.applyLeeched(user)
        end
    end

    def getTargetAffectingEffectScore(user, target)
        target_speed = target.pbSpeed
        user_speed = user.pbSpeed

        if target.canNumb?(user, false, self) && target_speed >= user_speed
            return getNumbEffectScore(user, target)
        elsif target.canLeech?(user, false, self) && user_speed >= target_speed
            return getLeechEffectScore(user, target)
        end
        return 0
    end
end

#===============================================================================
# Raises Attack and Defense by 2 steps, and Crit Chance by 1.
# (Martial Mastery)
#===============================================================================
class PokeBattle_Move_5AD < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2, :DEFENSE, 2]
	end

	def pbMoveFailed?(user, _targets, show_message)
        return super if user.effectAtMax?(:FocusEnergy) 
        return false
    end

	def pbEffectGeneral(user)
		super
		user.incrementEffect(:FocusEnergy, 1) unless user.effectAtMax?(:FocusEnergy)
    end

    def getEffectScore(user, _target)
        score = super
        score += getCriticalRateBuffEffectScore(user, 2)
        return score
    end
end

#===============================================================================
# User is protected against damaging moves this round. Decreases the Sp. Def of
# the user of a stopped special move by 2 steps. (Reverb Ward)
#===============================================================================
class PokeBattle_Move_5AE < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :ReverbWard
    end
end

#===============================================================================
# Target becomes trapped. Summons Eclipse for 6 turns.
# (Captivating Sight)
#===============================================================================
class PokeBattle_Move_5AF < PokeBattle_Move_0EF
    def pbFailsAgainstTarget?(_user, target, show_message)
        return false unless @battle.primevalWeatherPresent?(false)
        super
    end

    def pbEffectGeneral(user)
        @battle.pbStartWeather(user, :Eclipse, 6, false) unless @battle.primevalWeatherPresent?
    end
end

#===============================================================================
# Target becomes trapped. Summons Moonglow for 6 turns.
# (Midnight Hunt)
#===============================================================================
class PokeBattle_Move_5B0 < PokeBattle_Move_0EF
    def pbFailsAgainstTarget?(_user, target, show_message)
        return false unless @battle.primevalWeatherPresent?(false)
        super
    end

    def pbEffectGeneral(user)
        @battle.pbStartWeather(user, :Moonglow, 6, false) unless @battle.primevalWeatherPresent?
    end
end

#===============================================================================
# Target is frostbitten if in moonglow. (Night Chill)
#===============================================================================
class PokeBattle_Move_5B1 < PokeBattle_FrostbiteMove
    def pbAdditionalEffect(user, target)
        return unless @battle.moonGlowing?
        super
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless @battle.moonGlowing?
        super
    end
end

#===============================================================================
# Target is burned if in eclipse. (Calamitous Slash)
#===============================================================================
class PokeBattle_Move_5B2 < PokeBattle_BurnMove
    def pbAdditionalEffect(user, target)
        return unless @battle.eclipsed?
        super
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless @battle.eclipsed?
        super
    end
end

#===============================================================================
# Heals user by 1/2 of their HP.
# In any weather, increases the duration of the weather by 1. (Take Shelter)
#===============================================================================
class PokeBattle_Move_5B3 < PokeBattle_HalfHealingMove
    def pbEffectGeneral(user)
        super
        @battle.extendWeather(1) unless @battle.pbWeather == :None
    end
end

#===============================================================================
# Target falls asleep. Can only be used during the Full Moon. (Bedtime)
#===============================================================================
class PokeBattle_Move_5B4 < PokeBattle_SleepMove
    def pbMoveFailed?(user, _targets, show_message)
        unless @battle.fullMoon?
            @battle.pbDisplay(_INTL("But it failed, since it isn't a Full Moon!")) if show_message
            return true
        end
        return false
    end
end

#===============================================================================
# Removes all Weather. Fails if there is no Weather (Sky Fall)
#===============================================================================
class PokeBattle_Move_5B5 < PokeBattle_Move
    def pbMoveFailed?(_user, _targets, show_message)
        if @battle.pbWeather == :None
            @battle.pbDisplay(_INTL("But it failed, since there is no active weather!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
       @battle.endWeather
    end

    def getEffectScore(_user, _target)
        return 20
    end
end

#===============================================================================
# Move deals double damage but heals the status condition every active Pokémon
# if the target has a status condition (Purifying Flame)
#===============================================================================
class PokeBattle_Move_5B6 < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.pbHasAnyStatus?
        return baseDmg
    end

    def pbEffectWhenDealingDamage(user, target)
        return unless target.pbHasAnyStatus?
        @battle.eachBattler do |b|
            healStatus(b)
        end
    end

    def getEffectScore(_user, _target)
        score = 0
        @battle.eachBattler do |b|
            pkmn = b.pokemon
            next if !pkmn || !pkmn.able? || pkmn.status == :NONE
            score += b.opposes? ? 30 : -30
        end
        return score
    end
end

#===============================================================================
# All stats raised by 1 step. Fails if the attack was not used the turn after a foe fainted.
# (Triumphant Dance)
#===============================================================================
class PokeBattle_Move_5B7 < PokeBattle_MultiStatUpMove
	def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2, :DEFENSE, 2, :SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2, :SPEED, 2]
    end
	
	def pbMoveFailed?(user, targets, show_message)
        unless user.pbOpposingSide.faintLastRound?
            @battle.pbDisplay(_INTL("But it failed, since there was no victory to celebrate!")) if show_message
            return true
        end
        super
    end
end

#===============================================================================
# Removes entry hazards on user's side. 33% Recoil.
# (Icebreaker)
#===============================================================================
class PokeBattle_Move_5B8 < PokeBattle_RecoilMove
    def recoilFactor;  return (1.0 / 3.0); end

    def pbEffectAfterAllHits(user, target)
        return if user.fainted? || target.damageState.unaffected
        user.pbOwnSide.eachEffect(true) do |effect, _value, data|
            next unless data.is_hazard?
            user.pbOwnSide.disableEffect(effect)
        end
    end

    def getEffectScore(user, _target)
        score = super
        score += hazardWeightOnSide(user.pbOwnSide) if user.alliesInReserve?
        return score
    end
end

#===============================================================================
# This round, user becomes the target of attacks that have single targets.
# All enemies attacks this turn become Electric-type.
# (Zap Yapping)
#===============================================================================
class PokeBattle_Move_5B9 < PokeBattle_Move_117
    def pbEffectGeneral(user)
        super
        user.eachOpposing do |b|
            b.applyEffect(:Electrify)
        end
    end
    
    def getEffectScore(_user, _target)
        score = super
        return score + 40
    end
end

#===============================================================================
# Increases the user's Attack and Sp. Attack by 2 step eachs.
# In moonglow, also increases the user's Speed by 2 steps. (Scheme)
#===============================================================================
class PokeBattle_Move_5BA < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = ATTACKING_STATS_2
    end

    def pbOnStartUse(_user, _targets)
        if @battle.moonGlowing?
            @statUp = [:ATTACK, 1, :SPECIAL_ATTACK, 2, :SPEED, 2]
        else
            @statUp = ATTACKING_STATS_2
        end
    end

    def shouldHighlight?(_user, _target)
        return @battle.moonGlowing?
    end
end

#===============================================================================
# User is protected against damaging moves this round. Decreases the Sp. Atk of
# the user of a stopped special move by 1 step. (Shield Shell)
#===============================================================================
class PokeBattle_Move_5BB < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :ShieldShell
    end

    def getEffectScore(user, target)
        score = super
        # Check only special attackers
        user.eachPredictedProtectHitter(1) do |b|
            score += getMultiStatDownEffectScore([:SPECIAL_ATTACK,1],user,b)
        end
        return score
    end
end

#===============================================================================
# User faints, even if the move does nothing else. (Spiky Burst)
# Deals extra damage per "Spike" on the enemy side.
#===============================================================================
class PokeBattle_Move_5BC < PokeBattle_Move_0E0
    def pbBaseDamage(baseDmg, _user, target)
        target.pbOwnSide.eachEffect(true) do |effect, value, effectData|
            next unless effectData.is_spike?
            baseDmg += 50 * value
        end
        return baseDmg
    end
end

#===============================================================================
# Sets stealth rock and sandstorm for 5 turns. (Stone Signal)
#===============================================================================
class PokeBattle_Move_5BD < PokeBattle_Move_105
    def pbMoveFailed?(user, _targets, show_message)
        return false
    end

    def pbEffectGeneral(user)
        super
        @battle.pbStartWeather(user, :Sandstorm, 5, false) unless @battle.primevalWeatherPresent?
    end
end

#===============================================================================
# Halves the target's current HP. (Mouthful)
# User gains half the HP it inflicts as damage.
#===============================================================================
class PokeBattle_Move_5BE < PokeBattle_FixedDamageMove
    def healingMove?; return true; end

    def drainFactor(_user, _target); return 0.5; end

    def shouldDrain?(_user, _target); return true; end

    def pbEffectAgainstTarget(user, target)
        return if target.damageState.hpLost <= 0 || !shouldDrain?(user, target)
        hpGain = (target.damageState.hpLost * drainFactor(user, target)).round
        user.pbRecoverHPFromDrain(hpGain, target)
    end

    def pbFixedDamage(_user, target)
        damage = target.hp / 2.0
        damage /= BOSS_HP_BASED_EFFECT_RESISTANCE if target.boss?
        return damage.round
    end

    def getEffectScore(user, target)
        score = 40 * drainFactor(user, target)
        score *= 1.5 if user.hasActiveAbilityAI?(:ROOTED)
        score *= 2.0 if user.hasActiveAbilityAI?(:GLOWSHROOM) && user.battle.moonGlowing?
        score *= 1.3 if user.hasActiveItem?(:BIGROOT)
        score *= 2 if user.belowHalfHealth?
        score *= -1 if target.hasActiveAbilityAI?(:LIQUIDOOZE) || user.effectActive?(:NerveBreak)
        return score
    end
end

#===============================================================================
# User's side is protected against moves that target multiple battlers this round.
# This round, user becomes the target of attacks that have single targets.
# (Golem Guard)
#===============================================================================
class PokeBattle_Move_5BF < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect      = :WideGuard
        @sidedEffect = true
    end

    def pbEffectGeneral(user)
        super
        maxFollowMe = 0
        user.eachAlly do |b|
            next if b.effects[:FollowMe] <= maxFollowMe
            maxFollowMe = b.effects[:FollowMe]
        end
        user.applyEffect(:FollowMe, maxFollowMe + 1)
    end

    def getEffectScore(user, _target)
        score = 0
        user.eachPredictedProtectHitter do |b|
            score += 50 if user.hasAlly?
            score += 50 if b.poisoned?
            score += 50 if b.leeched?
            score += 30 if b.burned?
            score += 30 if b.frostbitten?
        end
        score /= 2
        if user.hasAlly?
            score += 50
            score += 25 if user.aboveHalfHealth?
        end
        return score
    end
end

#===============================================================================
# Minimizes the target's Speed and Evasiveness. (Freeze Ray)
#===============================================================================
class PokeBattle_Move_5C0 < PokeBattle_Move
    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        target.pbMinimizeStatStep(:SPEED, user, self)
        target.pbMinimizeStatStep(:EVASION, user, self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getMultiStatDownEffectScore([:SPEED,4,:EVASION,4], user, target)
    end
end

#===============================================================================
# Changes Category based on which will deal more damage. (Warped Strike)
# Raises the stat that wasn't selected to be used.
#===============================================================================
class PokeBattle_Move_5C1 < PokeBattle_Move
    def initialize(battle, move)
        super
        @calculated_category = 1
    end

    def calculateCategory(user, targets)
        return selectBestCategory(user, targets[0])
    end

    def pbAdditionalEffect(user, _target)
        if @calculated_category == 0
            return user.tryRaiseStat(:SPECIAL_ATTACK, user, increment: 1, move: self)
        else
            return user.tryRaiseStat(:ATTACK, user, increment: 1, move: self)
        end
    end

    def getEffectScore(user, target)
        expectedCategory = selectBestCategory(user, target)
        if expectedCategory == 0
            return getMultiStatUpEffectScore([:SPECIAL_ATTACK, 1], user, user)
        else
            return getMultiStatUpEffectScore([:ATTACK, 1], user, user)
        end
    end
end

#===============================================================================
# Uses the highest base-power move known by any non-user Pokémon in the user's party. (Optimized Action)
#===============================================================================
class PokeBattle_Move_5C2 < PokeBattle_Move
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            # Struggle, Chatter, Belch
            "002",   # Struggle
            "014",   # Chatter
            "158",   # Belch
            # Moves that affect the moveset
            "05C",   # Mimic
            "05D",   # Sketch
            "069",   # Transform
            # Counter moves
            "071",   # Counter
            "072",   # Mirror Coat
            "073",   # Metal Burst                         # Not listed on Bulbapedia
            # Helping Hand, Feint (always blacklisted together, don't know why)
            "09C",   # Helping Hand
            "08A",   # Lucky Cheer
            "0AD",   # Feint
            # Protection moves
            "0AA",   # Detect, Protect
            "0AB",   # Quick Guard                         # Not listed on Bulbapedia
            "0AC",   # Wide Guard                          # Not listed on Bulbapedia
            "0E8",   # Endure
            "149",   # Mat Block
            "14A",   # Crafty Shield                       # Not listed on Bulbapedia
            "14B",   # King's Shield
            "14C",   # Spiky Shield
            "168",   # Baneful Bunker
            # Moves that call other moves
            "0AE",   # Mirror Move
            "0AF",   # Copycat
            "0B0",   # Me First
            #       "0B3",   # Nature Power                                      # See below
            "0B4",   # Sleep Talk
            "0B5",   # Assist
            "0B6",   # Metronome
            # Move-redirecting and stealing moves
            "0B1",   # Magic Coat                          # Not listed on Bulbapedia
            "0B2",   # Snatch
            "117",   # Follow Me, Rage Powder
            "16A",   # Spotlight
            # Set up effects that trigger upon KO
            "0E6",   # Grudge                              # Not listed on Bulbapedia
            "0E7",   # Destiny Bond
            # Held item-moving moves
            "0F1",   # Covet, Thief
            "0F2",   # Switcheroo, Trick
            "0F3",   # Bestow
            # Moves that start focussing at the start of the round
            "115",   # Focus Punch
            "171",   # Shell Trap
            "172",   # Beak Blast
            # Event moves that do nothing
            "133", # Hold Hands
            "134", # Celebrate
            # Moves that call other moves
            "0B3", # Nature Power
        ]
    end

    def getOptimizedMove(user)
        optimizedMove = nil
        optimizedBP = -1
        @battle.pbParty(user.index).each_with_index do |pkmn, i|
            next if !pkmn || i == user.pokemonIndex
            next unless pkmn.able?
            pkmn.moves.each do |move|
                next if @moveBlacklist.include?(move.function_code)
                next if move.type == :SHADOW
                next if move.category == 2
                next unless move.base_damage > optimizedBP
                battleMove = @battle.getBattleMoveInstanceFromID(move.id)
                next if battleMove.forceSwitchMove?
                next if battleMove.is_a?(PokeBattle_TwoTurnMove)
                optimizedMove = move.id
                optimizedBP = move.base_damage
            end
        end
        return optimizedMove
    end

    def pbMoveFailed?(user, _targets, show_message)
        unless getOptimizedMove(user)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since there are no moves #{user.pbThis(true)} can use!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.pbUseMoveSimple(getOptimizedMove(user))
    end
end

#===============================================================================
# Uses a random special Dragon-themed move, then a random physical Dragon-themed move. (Dragon Invocation)
#===============================================================================
class PokeBattle_Move_5C3 < PokeBattle_Move
    def callsAnotherMove?; return true; end

    def initialize(battle, move)
        super
        @invocationMovesPhysical = [
            :DRAGONCLAW,
            :DRAGONCLAW,
            :CRUNCH,
            :EARTHQUAKE,
            :DUALWINGBEAT,
        ]

        @invocationMovesSpecial = [
            :DRAGONBREATH,
            :DRAGONBREATH,
            :FLAMETHROWER,
            :MIASMA,
            :FROSTBREATH,
        ]
    end

    def pbEffectGeneral(user)
        user.pbUseMoveSimple(@invocationMovesSpecial.sample)
        user.pbUseMoveSimple(@invocationMovesPhysical.sample)
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Dragon Invocation")
        return -1000
    end
end

#===============================================================================
# Two turn attack. Sets sun first turn, attacks second turn.
# (Absolute Radiance)
#===============================================================================
class PokeBattle_Move_5C4 < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} petitions the sun!", user.pbThis))
    end

    def pbChargingTurnEffect(user, _target)
        @battle.pbStartWeather(user, :Sun, 5, false)
    end

    def getEffectScore(user, _target)
        return getWeatherSettingEffectScore(:Sun, user, battle, 5)
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Liftoff)
# (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
#===============================================================================
class PokeBattle_Move_5C5 < PokeBattle_Move_0C9
    include Recoilable

    def recoilFactor; return 0.33; end

    def pbEffectAfterAllHits(user, target)
        return unless @damagingTurn
        super
    end
end

#===============================================================================
# The target's healing is cut in half until they switch out (Icy Injection)
#===============================================================================
class PokeBattle_Move_5C6 < PokeBattle_Move
    def pbAdditionalEffect(_user, target)
        return if target.fainted? || target.damageState.substitute
        target.applyEffect(:IcyInjection)
    end

    def getEffectScore(_user, target)
        if target.hasHealingMove?
            if target.belowHalfHealth?
                return 45
            else
                return 30
            end
        end
        return 0
    end
end

#===============================================================================
# Heals user by 1/2, raises Defense, Sp. Defense, Crit Chance. (Divination)
#===============================================================================
class PokeBattle_Move_5C7 < PokeBattle_HalfHealingMove
    def pbMoveFailed?(user, _targets, show_message)
        if user.effectAtMax?(:FocusEnergy) && !user.pbCanRaiseStatStep?(:DEFENSE, user, self) && 
                !user.pbCanRaiseStatStep?(:SPECIAL_DEFENSE, user, self)
            return super
        end
        return false
    end

    def pbEffectGeneral(user)
        super
        user.pbRaiseMultipleStatSteps(DEFENDING_STATS_1, user, move: self)
        user.incrementEffect(:FocusEnergy, 1) unless user.effectAtMax?(:FocusEnergy)
    end

    def getEffectScore(user, target)
        score = super
        score += getMultiStatUpEffectScore(DEFENDING_STATS_1, user, target)
        score += getCriticalRateBuffEffectScore(user, 1)
        return score
    end
end

#===============================================================================
# Damages target if target is a foe, or buff's the target's Speed
# by four steps if it's an ally. (Lightning Spear)
#===============================================================================
class PokeBattle_Move_5C8 < PokeBattle_Move
    def pbOnStartUse(user, targets)
        @buffing = false
        @buffing = !user.opposes?(targets[0]) if targets.length > 0
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        return false unless @buffing
        return !target.pbCanRaiseStatStep?(:SPEED, user, self, true)
    end

    def damagingMove?(aiChecking = false)
        if aiChecking
            return super
        else
            return false if @buffing
            return super
        end
    end

    def pbEffectAgainstTarget(user, target)
        return unless @buffing
        target.pbRaiseMultipleStatSteps([:SPEED, 4], user, move: self)
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        if @buffing
            @battle.pbAnimation(:CHARGE, user, targets, hitNum) if showAnimation
        else
            super
        end
    end
end

#===============================================================================
# The user puts all their effort into attacking their opponent
# causing them to rest on their next turn. (Extreme Effort)
#===============================================================================
class PokeBattle_Move_5C9 < PokeBattle_Move
    def pbEffectGeneral(user)
	    user.applyEffect(:ExtremeEffort, 2)
    end

    def getEffectScore(user, _target)
        return -getSleepEffectScore(nil, user) / 2
    end
end

#===============================================================================
# Increases Sp. Atk and Sp. Def by 2 steps, and Crit Chance by 1 step.
# (Tranquil Prayer)
#===============================================================================
class PokeBattle_Move_5CA < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2]
	end
    
	def pbMoveFailed?(user, _targets, show_message)
        return super if user.effectAtMax?(:FocusEnergy)
        return false
    end
    
	def pbEffectGeneral(user)
		super
		user.incrementEffect(:FocusEnergy, 1) unless user.effectAtMax?(:FocusEnergy)
    end

    def getEffectScore(user, _target)
        score = super
        score += getCriticalRateBuffEffectScore(user, 1)
        return score
    end
end

#===============================================================================
# Type changes depending on rotom's form. (Machinate)
# Additional effect changes depending on rotom's form. Only usable by rotom.
#===============================================================================
class PokeBattle_Move_5CB < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.countsAs?(:ROTOM)
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbBaseType(user)
        ret = :GHOST
        case user.form
        when 1
            ret = :FIRE if GameData::Type.exists?(:FIRE)
        when 2
            ret = :WATER if GameData::Type.exists?(:WATER)
        when 3
            ret = :ICE if GameData::Type.exists?(:ICE)
        when 4
            ret = :FLYING if GameData::Type.exists?(:FLYING)
        when 5
            ret = :GRASS if GameData::Type.exists?(:GRASS)
        end
        return ret
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        case user.form
        when 1
            target.applyBurn(user) if target.canBurn?(user, true, self)
        when 2
            target.applyNumb(user) if target.canNumb?(user, true, self)
        when 3
            target.applyFrostbite(user) if target.canFrostbite?(user, true, self)
        when 4
            target.applyDizzy(user) if target.canDizzy?(user, true, self)
        when 5
            target.applyLeeched(user) if target.canLeech?(user, true, self)
        end
    end

    def getTargetAffectingEffectScore(user, target)
        case user.form
        when 1
            return getBurnEffectScore(user, target)
        when 2
            return getNumnEffectScore(user, target)
        when 3
            return getFrostbiteEffectScore(user, target)
        when 4
            return getDizzyEffectScore(user, target)
        when 5
            return getLeechEffectScore(user, target)
        end
        return 0
    end
end

#===============================================================================
# In wild battles, makes target flee. Fails if target is a higher level than the
# user.
# In trainer battles, target switches out, to be replaced manually. (Dragon's Roar)
#===============================================================================
class PokeBattle_Move_5CC < PokeBattle_Move
    def forceSwitchMove?; return true; end

    def pbEffectAgainstTarget(user, target)
        if @battle.wildBattle? && target.level <= user.level && @battle.canRun &&
           (target.substituted? || ignoresSubstitute?(user)) && !target.boss
            @battle.decision = 3
        end
    end

    def pbSwitchOutTargetsEffect(user, targets, numHits, switchedBattlers)
        return if numHits == 0
        forceOutTargets(user, targets, switchedBattlers, false)
    end

    def getTargetAffectingEffectScore(user, target)
        return getForceOutEffectScore(user, target)
    end
end

#===============================================================================
# Power doubles if the target is the last alive on their team.
# (Checkmate)
#===============================================================================
class PokeBattle_Move_5CD < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.isLastAlive?
        return baseDmg
    end
end

#===============================================================================
# Boosts Targets' Sp. Atk and Sp. Def by 2 steps. (Tutelage)
#===============================================================================
class PokeBattle_Move_5CE < PokeBattle_TargetMultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2]
    end
end

#===============================================================================
# For 5 rounds, disables the last move the target used. Also, remove 4 PP from it. (Gem Seal)
#===============================================================================
class PokeBattle_Move_5CF < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbFailsAgainstTarget?(user, target, show_message)
        unless target.canBeDisabled?(true, self)
            @battle.pbDisplay(_INTL("But it failed, since the target can't be disabled!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Disable, 5)
        target.eachMove do |m|
            next if m.id != target.lastRegularMoveUsed
            reduction = [4, m.pp].min
            target.pbSetPP(m, m.pp - reduction)
            @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",
               target.pbThis(true), m.name, reduction))
            break
        end
    end

    def getEffectScore(_user, target)
        return 0 if target.hasActiveAbilityAI?(:MENTALBLOCK)
        score = 90
        score += 30 if @battle.pbIsTrapped?(target.index)
        return score
    end
end

#===============================================================================
# Restores health by half and gains an Aqua Ring. (River Rest)
#===============================================================================
class PokeBattle_Move_5D0 < PokeBattle_HalfHealingMove
    def pbMoveFailed?(user, _targets, show_message)
        if super(user, _targets, false) && user.effectActive?(:AquaRing)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis} can't heal and already has a veil of water!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        super
        user.applyEffect(:AquaRing)
    end

    def getEffectScore(user, target)
        score = super
        score += 40 unless user.effectActive?(:AquaRing)
        return score
    end
end

#===============================================================================
# Heals the party of status conditions and gains an Aqua Ring. (Whale Song)
#===============================================================================
class PokeBattle_Move_5D1 < PokeBattle_Move_019
    def worksWithNoTargets?; return true; end

    def pbMoveFailed?(user, _targets, show_message)
        if super(user, _targets, false) && user.effectActive?(:AquaRing)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} already has a veil of water and none of its party members have a status condition!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        super
        user.applyEffect(:AquaRing)
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        super
        @battle.pbDisplay(_INTL("Majestic whale sounds reverberate!"))
    end

    def getEffectScore(user, _target)
        score = super
        score += 40 unless user.effectActive?(:AquaRing)
        return score
    end
end

#===============================================================================
# Increases Speed by 4 steps and Crit Chance by 2 steps. (Deep Breathing)
#===============================================================================
class PokeBattle_Move_5D2 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPEED, 4]
    end

    def pbMoveFailed?(user, _targets, show_message)
        if user.effectAtMax?(:FocusEnergy)
            return super
        end
        return false
    end

    def pbEffectGeneral(user)
        super
        user.incrementEffect(:FocusEnergy, 2)
    end

    def getEffectScore(user, _target)
        score = super
        score += getCriticalRateBuffEffectScore(user, 2)
        return score
    end
end

#===============================================================================
# For 6 rounds, doubles the Speed of all battlers on the user's side. (Sustained Wind)
#===============================================================================
class PokeBattle_Move_5D3 < PokeBattle_Move_05B
    def pbEffectGeneral(user)
        user.pbOwnSide.applyEffect(:Tailwind, 6)
    end

    def getEffectScore(user, _target)
        score = super
        score = (score * 1.5).round
        return score
    end
end

#===============================================================================
# Heals user by 1/2 of their HP.
# Extends the duration of any screens affecting the user's side by 1. (Stabilize)
#===============================================================================
class PokeBattle_Move_5D4 < PokeBattle_HalfHealingMove
    def pbEffectGeneral(user)
        super
        pbOwnSide.eachEffect(true) do |effect, value, data|
            next unless data.is_screen?
            pbOwnSide.effects[effect] += 1
            @battle.pbDisplay(_INTL("{1}'s {2} was extended 1 turn!", pbTeam, data.real_name))
        end
    end

    def getEffectScore(user, target)
        score = super
        pbOwnSide.eachEffect(true) do |effect, value, data|
            next unless data.is_screen?
            score += 30
        end
        return score
    end
end

#===============================================================================
# Target's Herb items are destroyed. (Blight Touch)
#===============================================================================
class PokeBattle_Move_5D5 < PokeBattle_Move
    def canBlightTargetsItem?(target, checkingForAI = false)
        if checkingForAI
            return false if target.substituted?
        elsif target.damageState.substitute
            return false
        end
        return true
    end

    def pbEffectWhenDealingDamage(user, target)
        return unless canBlightTargetsItem?(target)
        target.eachItemWithName do |item, itemName|
            next unless canRemoveItem?(user, target, item)
            next unless HERB_ITEMS.include?(item)
            target.removeItem(item)
            @battle.pbDisplay(_INTL("{1}'s {2} was blighted!", target.pbThis, itemName))
        end
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless canBlightTargetsItem?(target)
        score = 0
        target.eachItemWithName do |item, itemName|
            next unless canRemoveItem?(user, target, item, checkingForAI: true)
            next unless HERB_ITEMS.include?(item)
            score += 30
        end
        return score
    end
end

#===============================================================================
# User heals for 3/5ths of their HP. (Heal Order)
#===============================================================================
class PokeBattle_Move_5D6 < PokeBattle_HealingMove
    def healRatio(_user)
        return 3.0 / 5.0
    end
end

#===============================================================================
# Target becomes your choice of Dragon, Fairy, or Steel type. (Regalia)
#===============================================================================
class PokeBattle_Move_5D7 < PokeBattle_Move
    def resolutionChoice(user)
        validTypes = %i[DRAGON FAIRY STEEL]
        validTypeNames = []
        validTypes.each do |typeID|
            validTypeNames.push(GameData::Type.get(typeID).real_name)
        end
        if validTypes.length == 1
            @chosenType = validTypes[0]
        elsif validTypes.length > 1
            if @battle.autoTesting
                @chosenType = validTypes.sample
            elsif !user.pbOwnedByPlayer? # Trainer AI
                @chosenType = validTypes[0]
            else
                chosenIndex = @battle.scene.pbShowCommands(_INTL("Which type should #{user.pbThis(true)} gift?"),validTypeNames,0)
                @chosenType = validTypes[chosenIndex]
            end
        end
    end

    def pbFailsAgainstTarget?(_user, target, show_message)
        unless GameData::Type.exists?(@chosenType)
            @battle.pbDisplay(_INTL("But it failed, since the chosen type doesn't exist!")) if show_message
            return true
        end
        unless target.canChangeType?
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can't change their type!")) if show_message
            return true
        end
        unless target.pbHasOtherType?(@chosenType)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already only the chosen type!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTargetAI?(_user, target)
        @chosenType = :DRAGON
        return pbFailsAgainstTarget?(_user, target, false)
    end

    def pbEffectAgainstTarget(_user, target)
        target.pbChangeTypes(@chosenType)
        typeName = GameData::Type.get(@chosenType).name
        @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", target.pbThis, typeName))
    end

    def resetMoveUsageState
        @chosenType = nil
    end

    def getEffectScore(_user, _target)
        return 80
    end
end

#===============================================================================
# Increases the user's Attack by 1 step.
#===============================================================================
class PokeBattle_Move_5D8 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 1]
    end
end

#===============================================================================
# Increases the user's Attack by 3 steps.
#===============================================================================
class PokeBattle_Move_5D9 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 3]
    end
end

#===============================================================================
# Increases the user's Defense by 1 step.
#===============================================================================
class PokeBattle_Move_5DA < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:DEFENSE, 1]
    end
end

#===============================================================================
# Increases the user's Defense by 3 steps.
#===============================================================================
class PokeBattle_Move_5DB < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:DEFENSE, 3]
    end
end

#===============================================================================
# Increases the user's Sp. Atk by 1 step.
#===============================================================================
class PokeBattle_Move_5DC < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 1]
    end
end

#===============================================================================
# Increases the user's Sp. Atk by 3 steps.
#===============================================================================
class PokeBattle_Move_5DD < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 3]
    end
end

#===============================================================================
# Increases the user's Sp. Def by 1 step.
#===============================================================================
class PokeBattle_Move_5DE < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_DEFENSE, 1]
    end
end

#===============================================================================
# Increases the user's Sp. Def by 3 steps.
#===============================================================================
class PokeBattle_Move_5DF < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_DEFENSE, 3]
    end
end

#===============================================================================
# Increases the user's Speed by 1 step.
#===============================================================================
class PokeBattle_Move_5E0 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPEED, 1]
    end
end

#===============================================================================
# Increases the user's Speed by 3 steps.
#===============================================================================
class PokeBattle_Move_5E1 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPEED, 3]
    end
end

#===============================================================================
# Increases the user's defensive stats by 2 steps and gives them the Shell Armor ability.
#===============================================================================
class PokeBattle_Move_5E2 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = DEFENDING_STATS_2
    end

    def pbEffectGeneral(user)
        super
        user.addAbility(:SHELLARMOR,true)
    end
end

#===============================================================================
# Increases the user's Speed and Sp. Atk by 2 steps. (Frolic)
#===============================================================================
class PokeBattle_Move_5E3 < PokeBattle_MultiStatUpMove
    def aiAutoKnows?(pokemon); return true; end

    def initialize(battle, move)
        super
        @statUp = [:SPEED, 2, :SPECIAL_ATTACK, 2]
    end
end

#===============================================================================
# Increases the user's Sp. Atk and accuracy by 3 steps each.
#===============================================================================
class PokeBattle_Move_5E4 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 3, :ACCURACY, 3]
    end
end

#===============================================================================
# Decreases the target's Sp. Atk by 1 step. Heals user by an amount equal to the
# target's Sp. Atk stat. (Mind Sap)
#===============================================================================
class PokeBattle_Move_5E5 < PokeBattle_Move
    def healingMove?; return true; end

    def pbFailsAgainstTarget?(_user, target, show_message)
        # NOTE: The official games appear to just check whether the target's Attack
        #       stat step is -6 and fail if so, but I've added the "fail if target
        #       has Contrary and is at +6" check too for symmetry. This move still
        #       works even if the stat step cannot be changed due to an ability or
        #       other effect.
        if !@battle.moldBreaker && target.hasActiveAbility?(%i[CONTRARY ECCENTRIC]) &&
           target.statStepAtMax?(:SPECIAL_ATTACK)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s Attack can't go any higher!"))
            end
            return true
        elsif target.statStepAtMin?(:SPECIAL_ATTACK)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s Attack can't go any lower!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        healAmount = target.pbSpAtk
        # Reduce target's Attack stat
        target.tryLowerStat(:SPECIAL_ATTACK, user, move: self)
        # Heal user
        if target.hasActiveAbility?(:LIQUIDOOZE)
            @battle.pbShowAbilitySplash(target, :LIQUIDOOZE)
            user.pbReduceHP(healAmount)
            @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!", user.pbThis))
            @battle.pbHideAbilitySplash(target)
            user.pbItemHPHealCheck
        elsif user.canHeal?
            healAmount *= 1.3 if user.hasActiveItem?(:BIGROOT)
            user.pbRecoverHP(healAmount)
        end
    end

    def getEffectScore(user, _target)
        return getHealingEffectScore(user, user, 2)
    end

    def getTargetAffectingEffectScore(user, target)
        return getMultiStatDownEffectScore([:ATTACK, 1], user, target)
    end
end

#===============================================================================
# Decreases the target's Attack by 1 step.
#===============================================================================
class PokeBattle_Move_5E6 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 1]
    end
end

#===============================================================================
# Decreases the target's Attack by 3 steps.
#===============================================================================
class PokeBattle_Move_5E7 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 3]
    end
end

#===============================================================================
# Decreases the target's Defense by 1 step.
#===============================================================================
class PokeBattle_Move_5E8 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 1]
    end
end

#===============================================================================
# Decreases the target's Defense by 3 step.
#===============================================================================
class PokeBattle_Move_5E9 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 3]
    end
end

#===============================================================================
# Decreases the target's Speed by 1 step.
#===============================================================================
class PokeBattle_Move_5EA < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 1]
    end
end

#===============================================================================
# Decreases the target's Speed by 3 step.
#===============================================================================
class PokeBattle_Move_5EB < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 3]
    end
end

#===============================================================================
# Decreases the target's Special Attack by 1 step.
#===============================================================================
class PokeBattle_Move_5EC < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 1]
    end
end

#===============================================================================
# Decreases the target's Special Attack by 3 steps.
#===============================================================================
class PokeBattle_Move_5ED < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 3]
    end
end

#===============================================================================
# Decreases the target's Special Defense by 1 step.
#===============================================================================
class PokeBattle_Move_5EF < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_DEFENSE, 1]
    end
end

#===============================================================================
# Decreases the target's Special Defense by 3 steps.
#===============================================================================
class PokeBattle_Move_5F0 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_DEFENSE, 3]
    end
end

#===============================================================================
# Decreases the target's Attack by 5 steps. (Feather Dance)
#===============================================================================
class PokeBattle_Move_5F1 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 5]
    end
end

#===============================================================================
# Does Double Damage under gravity (Falling Apple)
#===============================================================================
class PokeBattle_Move_5F2 < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, _target)
        baseDmg *= 2.0 if @battle.field.effectActive?(:Gravity)
        return baseDmg
    end
end

#===============================================================================
# Decreases the target's Sp. Atk by 5 steps. (Star Dance)
#===============================================================================
class PokeBattle_Move_5F3 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 5]
    end
end

#===============================================================================
# Target moves immediately after the user and deals 50% more damage. (Amp Up)
#===============================================================================
class PokeBattle_Move_5F4 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.fainted?
            @battle.pbDisplay(_INTL("But it failed, since the receiver is gone!")) if show_message
            return true
        end
        # Target has already moved this round
        return true if pbMoveFailedTargetAlreadyMoved?(target, show_message)
        # Target was going to move next anyway (somehow)
        if target.effectActive?(:MoveNext)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already being forced to move next!")) if show_message
            return true
        end
        # Target didn't choose to use a move this round
        oppMove = @battle.choices[target.index][2]
        unless oppMove
            @battle.pbDisplay(_INTL("But it failed. since #{target.pbThis(true)} isn't using a move this turn!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:HelpingHand)
        @battle.pbDisplay(_INTL("{1} is ready to help {2}!", user.pbThis, target.pbThis(true)))
        target.applyEffect(:MoveNext)
        @battle.pbDisplay(_INTL("{1} is amped up!", target.pbThis))
    end

    def pbFailsAgainstTargetAI?(_user, _target); return false; end

    def getEffectScore(user, target)
        return 0 if user.opposes?(target)
        userSpeed = user.pbSpeed(true)
        targetSpeed = target.pbSpeed(true)
        return 0 if targetSpeed > userSpeed
        return 120
    end
end

#===============================================================================
# Increases the user's Attack and Sp. Attack by 4 step eachs. (True Senses)
#===============================================================================
class PokeBattle_Move_5F5 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 4, :SPECIAL_ATTACK, 4]
    end
end

#===============================================================================
# User takes recoil damage equal to 1/3 of the damage this move dealt. (Undying Rush)
# But can't faint from that recoil damage.
#===============================================================================
class PokeBattle_Move_5F6 < PokeBattle_RecoilMove
    def recoilFactor;  return (1.0 / 3.0); end
    
    def pbRecoilDamage(user, target)
        damage = (target.damageState.totalHPLost * finalRecoilFactor(user)).round
        damage = [damage,(user.hp - 1)].min
        return damage
    end

    def pbEffectAfterAllHits(user, target)
        return if target.damageState.unaffected
        recoilDamage = pbRecoilDamage(user, target)
        return if recoilDamage <= 0
        user.applyRecoilDamage(recoilDamage, false, true)
    end
end

#===============================================================================
# Target can't switch out or flee until they take a hit. (Ice Dungeon)
# Their attacking stats are both lowered by 1 step.
#===============================================================================
class PokeBattle_Move_5F7 < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effectActive?(:IceDungeon) && target.pbCanLowerStatStep?(:ATTACK, user, self) &&
                target.pbCanLowerStatStep?(:SPECIAL_ATTACK, user, self)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already imprisoned and its attacking stats can't be reduced!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.applyEffect(:IceDungeon)
        target.pbLowerMultipleStatSteps(ATTACKING_STATS_1, user, move: self)
    end

    def getTargetAffectingEffectScore(user, target)
        score = 0
        score += 40 unless target.effectActive?(:IceDungeon)
        score += getMultiStatUpEffectScore(ATTACKING_STATS_1, user, target)
        return score
    end
end

#===============================================================================
# Target's Defense is lowered by 3 steps if in sandstorm. (Grindstone)
#===============================================================================
class PokeBattle_Move_5F8 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 3]
    end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        return unless @battle.sandy?
        target.tryLowerStat(@statDown[0], user, increment: @statDown[1], move: self)
    end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless @battle.sandy?
        return getMultiStatDownEffectScore(@statDown, user, target)
    end

    def shouldHighlight?(_user, _target)
        return @battle.sandy?
    end
end

#===============================================================================
# Move has increased Priority in sandstorm (Sand Blasting)
#===============================================================================
class PokeBattle_Move_5F9 < PokeBattle_Move
    def priorityModification(_user, _targets)
        return 1 if @battle.sandy?
        return 0
    end

    def shouldHighlight?(_user, _target)
        return @battle.sandy?
    end
end