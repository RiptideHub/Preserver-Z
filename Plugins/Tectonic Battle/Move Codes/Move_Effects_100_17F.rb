#===============================================================================
# Starts rainy weather. (Rain)
#===============================================================================
class PokeBattle_Move_100 < PokeBattle_WeatherMove
    def initialize(battle, move)
        super
        @weatherType = :Rain
    end
end

#===============================================================================
# Starts sandstorm weather. (Sandstorm)
#===============================================================================
class PokeBattle_Move_101 < PokeBattle_WeatherMove
    def initialize(battle, move)
        super
        @weatherType = :Sandstorm
    end
end

#===============================================================================
# Starts hail weather. (Hail)
#===============================================================================
class PokeBattle_Move_102 < PokeBattle_WeatherMove
    def initialize(battle, move)
        super
        @weatherType = :Hail
    end
end

#===============================================================================
# Entry hazard. Lays spikes on the opposing side. (Spikes)
#===============================================================================
class PokeBattle_Move_103 < PokeBattle_Move
    def hazardMove?; return true; end
    def aiAutoKnows?(pokemon); return true; end

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

    def pbEffectAgainstTarget(_user, target)
        return unless damagingMove?
        return if target.pbOwnSide.effectAtMax?(:Spikes)
        target.pbOwnSide.incrementEffect(:Spikes)
    end

    def getEffectScore(user, target)
        return 0 if damagingMove? && target.pbOwnSide.effectAtMax?(:Spikes)
        return getHazardSettingEffectScore(user, target)
    end
end

#===============================================================================
# Entry hazard. Lays poison spikes on the opposing side (max. 2 layers).
# (Poison Spikes)
#===============================================================================
class PokeBattle_Move_104 < PokeBattle_StatusSpikeMove
    def initialize(battle, move)
        @spikeEffect = :PoisonSpikes
        super
    end
end

#===============================================================================
# Entry hazard. Lays stealth rocks on the opposing side. (Stealth Rock)
#===============================================================================
class PokeBattle_Move_105 < PokeBattle_Move
    def hazardMove?; return true; end
    def aiAutoKnows?(pokemon); return true; end

    def pbMoveFailed?(user, _targets, show_message)
        return false if damagingMove?
        if user.pbOpposingSide.effectActive?(:StealthRock)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since pointed stones already float around the opponent!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        return if damagingMove?
        user.pbOpposingSide.applyEffect(:StealthRock)
    end

    def pbEffectAgainstTarget(_user, target)
        return unless damagingMove?
        return if target.pbOwnSide.effectActive?(:StealthRock)
        target.pbOwnSide.applyEffect(:StealthRock)
    end

    def getEffectScore(user, target)
        return 0 if damagingMove? && target.pbOwnSide.effectActive?(:StealthRock)
        return getHazardSettingEffectScore(user, target)
    end
end

#===============================================================================
# Combos with another Pledge move used by the ally. (Grass Pledge)
# If the move is a combo, power is doubled and causes either a sea of fire or a
# swamp on the opposing side.
#===============================================================================
class PokeBattle_Move_106 < PokeBattle_PledgeMove
    def initialize(battle, move)
        super
        # [Function code to combo with, effect, override type, override animation]
        @combos = [["107", :SeaOfFire, :FIRE, :FIREPLEDGE],
                   ["108", :Swamp,     nil,   nil],]
    end
end

#===============================================================================
# Combos with another Pledge move used by the ally. (Fire Pledge)
# If the move is a combo, power is doubled and causes either a rainbow on the
# user's side or a sea of fire on the opposing side.
#===============================================================================
class PokeBattle_Move_107 < PokeBattle_PledgeMove
    def initialize(battle, move)
        super
        # [Function code to combo with, effect, override type, override animation]
        @combos = [["108", :Rainbow,   :WATER, :WATERPLEDGE],
                   ["106", :SeaOfFire, nil,    nil],]
    end
end

#===============================================================================
# Combos with another Pledge move used by the ally. (Water Pledge)
# If the move is a combo, power is doubled and causes either a swamp on the
# opposing side or a rainbow on the user's side.
#===============================================================================
class PokeBattle_Move_108 < PokeBattle_PledgeMove
    def initialize(battle, move)
        super
        # [Function code to combo with, effect, override type, override animation]
        @combos = [["106", :Swamp,   :GRASS, :GRASSPLEDGE],
                   ["107", :Rainbow, nil,    nil],]
    end
end

#===============================================================================
# Scatters coins that the player picks up after winning the battle. (Pay Day)
#===============================================================================
class PokeBattle_Move_109 < PokeBattle_Move
    def pbEffectGeneral(user)
        @battle.field.incrementEffect(:PayDay, 5 * user.level) if user.pbOwnedByPlayer?
    end
end

#===============================================================================
# Ends the opposing side's screen effects. (Brick Break, Psychic Fangs)
#===============================================================================
class PokeBattle_Move_10A < PokeBattle_Move
    def ignoresReflect?; return true; end

    def pbEffectWhenDealingDamage(_user, target)
        side = target.pbOwnSide
        side.eachEffect(true) do |effect, _value, data|
            side.disableEffect(effect) if data.is_screen?
        end
    end

    def sideHasScreens?(side)
        side.eachEffect(true) do |_effect, _value, data|
            return true if data.is_screen?
        end
        return false
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        targets.each do |b|
            next unless sideHasScreens?(b.pbOwnSide)
            hitNum = 1 # Wall-breaking anim
            break
        end
        super
    end

    def getEffectScore(_user, target)
        side = target.pbOwnSide
        score = 0
        side.eachEffect(true) do |_effect, _value, data|
            score += 10 if data.is_screen?
        end
        return score
    end

    def shouldHighlight?(_user, target)
        return sideHasScreens?(target.pbOwnSide)
    end
end

#===============================================================================
# If attack misses, user takes crash damage of 1/2 of max HP.
# (High Jump Kick, Jump Kick)
#===============================================================================
class PokeBattle_Move_10B < PokeBattle_Move
    def recoilMove?;        return true; end
    def unusableInGravity?; return true; end

    def pbCrashDamage(user)
        recoilDamage = user.totalhp / 2.0
        recoilMessage = _INTL("{1} kept going and crashed!", user.pbThis)
        user.applyRecoilDamage(recoilDamage, true, true, recoilMessage)
    end

    def getEffectScore(_user, _target)
        return (@accuracy - 100) * 2
    end
end

#===============================================================================
# User turns 1/4 of max HP into a substitute. (Substitute)
#===============================================================================
class PokeBattle_Move_10C < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.substituted?
            @battle.pbDisplay(_INTL("{1} already has a substitute!", user.pbThis)) if show_message
            return true
        end

        if user.hp <= user.getSubLife
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} does not have enough HP left to make a substitute!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.createSubstitute
    end

    def getEffectScore(user, _target)
        score = 80
        score += 20 if user.firstTurn?
        user.eachOpposing(true) do |b|
            if !b.canActThisTurn?
                score += 50
            elsif b.hasSoundMove?
                score -= 50
            end
        end
        return score
    end
end

#===============================================================================
# User curses the target.
#===============================================================================
class PokeBattle_Move_10D < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effectActive?(:Curse)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already cursed!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.applyEffect(:Curse)
    end

    def getEffectScore(user, target)
        score = getCurseEffectScore(user, target)
        return score
    end
end

#===============================================================================
# Burns target if target is a foe, or raises target's Speed by 4 steps an ally. (Mount's Judgement)
#===============================================================================
class PokeBattle_Move_10E < PokeBattle_Move
    def pbOnStartUse(user, targets)
        @buffing = false
        @buffing = !user.opposes?(targets[0]) if targets.length > 0
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        if @buffing
            if target.substituted? && !ignoresSubstitute?(user)
                @battle.pbDisplay(_INTL("#{target.pbThis} is protected behind its substitute!")) if show_message
                return true
            end
        else
            return true unless target.canBurn?(user, show_message, self)
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        if @buffing
            target.tryRaiseStat(:SPEED, user, move: self)
        else
            target.applyBurn(user)
        end
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        if @buffing
            id = :AGILITY
        end
        super
    end

    def getTargetAffectingEffectScore(user, target)
        if user.opposes?(target)
            return getBurnEffectScore(user, target)
        else
            return getMultiStatUpEffectScore([:SPEED,4])
        end
    end
end

#===============================================================================
# Target will lose 1/4 of max HP at end of each round, while asleep. (Nightmare)
#===============================================================================
class PokeBattle_Move_10F < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        unless target.asleep?
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} isn't asleep!")) if show_message
            return true
        end
        if target.effectActive?(:Nightmare)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already afflicted by a Nightmare!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Nightmare)
    end

    def getTargetAffectingEffectScore(_user, target)
        score = 100
        score += 50 if target.aboveHalfHealth?
        return score
    end
end

#===============================================================================
# Currently unused. # TODO
#===============================================================================
class PokeBattle_Move_110 < PokeBattle_Move
end

#===============================================================================
# Attacks 2 rounds in the future. (Future Sight, etc.)
#===============================================================================
class PokeBattle_Move_111 < PokeBattle_Move
    def cannotRedirect?; return true; end

    def damagingMove?(aiChecking = false) # Stops damage being dealt in the setting-up turn
        if aiChecking
            return super
        else
            return false unless @battle.futureSight
            return super
        end
    end

    def pbAccuracyCheck(user, target)
        return true unless @battle.futureSight
        return super
    end

    def pbDisplayUseMessage(user, targets)
        super unless @battle.futureSight
    end

    def displayWeatherDebuffMessages(user, type)
        super unless @battle.futureSight
    end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if !@battle.futureSight && target.position.effectActive?(:FutureSightCounter)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since an attack is already foreseen against #{target.pbThis(true)}!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        return if @battle.futureSight # Attack is hitting
        count = 2
        count -= 1 if user.hasActiveAbility?([:BADOMEN])
        target.position.applyEffect(:FutureSightCounter, count)
        target.position.applyEffect(:FutureSightMove, @id)
        target.position.pointAt(:FutureSightUserIndex, user)
        target.position.applyEffect(:FutureSightUserPartyIndex, user.pokemonIndex)
        if @id == :DOOMDESIRE
            @battle.pbDisplay(_INTL("{1} chose Doom Desire as its destiny!", user.pbThis))
        else
            @battle.pbDisplay(_INTL("{1} foresaw an attack!", user.pbThis))
        end
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        hitNum = 1 unless @battle.futureSight # Charging anim
        super
    end

    def getEffectScore(user, _target)
        score = 0
        score -= 50 unless user.alliesInReserve?
        score -= 20 unless user.firstTurn?
        return score
    end
end

#===============================================================================
# Increases the user's Defense and Special Defense by 1 step each. Ups the
# user's stockpile by 1 (max. 2). (Stockpile)
#===============================================================================
class PokeBattle_Move_112 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = DEFENDING_STATS_1
    end

    def pbMoveFailed?(user, _targets, show_message)
        if user.effectAtMax?(:Stockpile)
            @battle.pbDisplay(_INTL("{1} can't stockpile any more!", user.pbThis)) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.incrementEffect(:Stockpile)
        super
    end

    def getEffectScore(user, target)
        score = super
        score += 20 if user.pbHasMoveFunction?("113")	# Spit Up
        score += 20 if user.pbHasMoveFunction?("114") # Swallow
        return score
    end
end

#===============================================================================
# Power is 150 multiplied by the user's stockpile (X). Resets the stockpile to
# 0. Decreases the user's Defense and Special Defense by X steps each. (Spit Up)
#===============================================================================
class PokeBattle_Move_113 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.effectActive?(:Stockpile)
            @battle.pbDisplay(_INTL("But it failed to spit up a thing!")) if show_message
            return true
        end
        return false
    end

    def pbBaseDamage(_baseDmg, user, _target)
        return 150 * user.countEffect(:Stockpile)
    end

    def pbEffectAfterAllHits(user, target)
        return if user.fainted? || !user.effectActive?(:Stockpile)
        return if target.damageState.unaffected
        @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!", user.pbThis))
        return if @battle.pbAllFainted?(target.idxOwnSide)
        user.disableEffect(:Stockpile)
    end

    def getEffectScore(user, _target)
        return -20 * user.countEffect(:Stockpile)
    end

    def shouldHighlight?(user, _target)
        return user.effectAtMax?(:Stockpile)
    end
end

#===============================================================================
# Heals user depending on the user's stockpile (X). Resets the stockpile to 0.
# Decreases the user's Defense and Special Defense by X steps each. (Swallow)
#===============================================================================
class PokeBattle_Move_114 < PokeBattle_HealingMove
    def healingMove?; return true; end

    def pbMoveFailed?(user, targets, show_message)
        return true if super
        unless user.effectActive?(:Stockpile)
            @battle.pbDisplay(_INTL("But it failed to swallow a thing!")) if show_message
            return true
        end
        return false
    end

    def healRatio(user)
        case [user.countEffect(:Stockpile), 1].max
        when 1
            return 1.0 / 2.0
        when 2
            return 1.0
        end
        return 0.0
    end

    def pbEffectGeneral(user)
        super
        @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!", user.pbThis))
        user.disableEffect(:Stockpile)
    end

    def getEffectScore(user, target)
        score = super
        score -= 20 * user.countEffect(:Stockpile)
        return score
    end

    def shouldHighlight?(user, _target)
        return user.effectAtMax?(:Stockpile)
    end
end

#===============================================================================
# Fails if user was hit by a damaging move this round. (Focus Punch)
#===============================================================================
class PokeBattle_Move_115 < PokeBattle_Move
    def pbDisplayChargeMessage(user)
        user.applyEffect(:FocusPunch)
    end

    def pbDisplayUseMessage(user, targets)
        super unless focusLost?(user)
    end

    def focusLost?(user)
        return user.effectActive?(:FocusPunch) && user.lastHPLost > 0 && !user.damageState.substitute
    end

    def pbMoveFailed?(user, _targets, show_message)
        if focusLost?(user)
            @battle.pbDisplay(_INTL("{1} lost its focus and couldn't move!", user.pbThis)) if show_message
            return true
        end
        return false
    end

    def pbMoveFailedAI?(user, _targets)
        return false if user.substituted?
        if user.ownersPolicies.include?(:PREDICTS_PLAYER)
            user.eachPredictedAttacker do |_b|
                return true
            end
            return false
        end
        return hasBeenUsed?(user)
    end
end

#===============================================================================
# Fails if the target didn't chose a damaging move to use this round, or has
# already moved. (Sucker Punch)
#===============================================================================
class PokeBattle_Move_116 < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        if @battle.choices[target.index][0] != :UseMove
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} didn't choose to attack!")) if show_message
            return true
        end
        oppMove = @battle.choices[target.index][2]
        if !oppMove ||
           (oppMove.function != "0B0" && # Me First
           (target.movedThisRound? || oppMove.statusMove?))
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} already moved this turn!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTargetAI?(user, target)
        if user.ownersPolicies.include?(:PREDICTS_PLAYER)
            return !@battle.aiPredictsAttack?(user,target.index)
        else
            return true unless target.hasDamagingAttack?
            return true if hasBeenUsed?(user)
            return false
        end
    end
end

#===============================================================================
# This round, user becomes the target of attacks that have single targets.
# (Follow Me)
#===============================================================================
class PokeBattle_Move_117 < PokeBattle_Move
    def pbEffectGeneral(user)
        maxFollowMe = 0
        user.eachAlly do |b|
            next if b.effects[:FollowMe] <= maxFollowMe
            maxFollowMe = b.effects[:FollowMe]
        end
        user.applyEffect(:FollowMe, maxFollowMe + 1)
    end

    def getEffectScore(user, _target)
        return 0 unless user.hasAlly?
        score = 50
        score += 25 if user.aboveHalfHealth?
        return score
    end
end

#===============================================================================
# For 5 rounds, increases gravity on the field. Pokémon cannot become airborne.
# (Gravity)
#===============================================================================
class PokeBattle_Move_118 < PokeBattle_Move
    def pbMoveFailed?(_user, _targets, show_message)
        if @battle.field.effectActive?(:Gravity)
            @battle.pbDisplay(_INTL("But it failed, since gravity is already intense!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(_user)
        @battle.field.applyEffect(:Gravity, 5)
    end

    def getEffectScore(user, _target)
        score = 20
        @battle.eachBattler do |b|
            bScore = 0
            bScore -= 20 if b.airborne?(true)
            bScore += 20 if b.hasInaccurateMove?
            bScore += 40 if b.hasLowAccuracyMove?
            bScore *= -1 if b.opposes?(user)

            score += bScore
        end
        return score
    end
end

#===============================================================================
# For 5 rounds, user becomes airborne. (Magnet Rise)
#===============================================================================
class PokeBattle_Move_119 < PokeBattle_Move
    def unusableInGravity?; return true; end

    def pbMoveFailed?(user, _targets, show_message)
        if user.effectActive?(:Ingrain)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s roots keep it stuck in the ground!"))
            end
            return true
        end
        if user.effectActive?(:SmackDown)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} was smacked down to the ground!"))
            end
            return true
        end
        if user.effectActive?(:MagnetRise)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already risen up through magnetism!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.applyEffect(:MagnetRise, 5)
    end

    def getEffectScore(user, _target)
        score = 20
        score += 20 if user.firstTurn?
        user.eachOpposing(true) do |b|
            if b.pbHasAttackingType?(:GROUND)
                score += 50
                score += 25 if b.pbHasType?(:GROUND)
            end
        end
        return score
    end
end

#===============================================================================
# Traps the target and frostbites them. (Icicle Pin)
#===============================================================================
class PokeBattle_Move_11A < PokeBattle_Move_0EF
    def pbFailsAgainstTarget?(_user, target, show_message)
        return false if damagingMove?
        if target.effectActive?(:MeanLook) && !target.canFrostbite?(user, false, self)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already trapped and can't be frostbitten!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        super
        target.applyFrostbite(user) if target.canFrostbite?(user, false)
    end

    def getTargetAffectingEffectScore(user, target)
        score = 0
        score += 50 unless target.effectActive?(:MeanLook)
        score += getFrostbiteEffectScore(user, target)
        return score
    end
end

#===============================================================================
# Hits airborne semi-invulnerable targets. (Sky Uppercut)
#===============================================================================
class PokeBattle_Move_11B < PokeBattle_Move
    def hitsFlyingTargets?; return true; end

    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.inTwoTurnAttack?("0C9", "0CC", "0CE") || # Fly/Bounce/Sky Drop
                        target.effectActive?(:SkyDrop)
        return baseDmg
    end
end

#===============================================================================
# Grounds the target while it remains active. Hits some semi-invulnerable
# targets. (Smack Down, Thousand Arrows)
#===============================================================================
class PokeBattle_Move_11C < PokeBattle_Move
    def hitsFlyingTargets?; return true; end

    def pbCalcTypeModSingle(moveType, defType, user, target)
        return Effectiveness::NORMAL_EFFECTIVE_ONE if moveType == :GROUND && defType == :FLYING
        return super
    end

    def canSmackDown?(target, checkingForAI = false)
        return false if target.fainted?
        if checkingForAI
            return false if target.substituted?
        elsif target.damageState.unaffected || target.damageState.substitute
            return false
        end
        return false if target.inTwoTurnAttack?("0CE") || target.effectActive?(:SkyDrop) # Sky Drop
        return false if !target.airborne? && !target.inTwoTurnAttack?("0C9", "0CC") # Fly/Bounce
        return true
    end

    def pbEffectAfterAllHits(_user, target)
        return unless canSmackDown?(target)
        target.applyEffect(:SmackDown)
    end

    def getTargetAffectingEffectScore(_user, target)
        score = 0
        if canSmackDown?(target)
            score += 20 unless target.effectActive?(:SmackDown)
            score += 20 if target.inTwoTurnAttack?("0C9", "0CC")
        end
        return score
    end

    def shouldHighlight?(_user, target)
        return canSmackDown?(target)
    end
end

#===============================================================================
# Target moves immediately after the user, ignoring priority/speed. (After You)
#===============================================================================
class PokeBattle_Move_11D < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbFailsAgainstTarget?(_user, target, show_message)
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
        target.applyEffect(:MoveNext)
        @battle.pbDisplay(_INTL("{1} took the kind offer!", target.pbThis))
    end

    def pbFailsAgainstTargetAI?(_user, _target); return false; end

    def getEffectScore(user, target)
        return 0 if user.opposes?(target)
        userSpeed = user.pbSpeed(true)
        targetSpeed = target.pbSpeed(true)
        return 0 if targetSpeed > userSpeed
        return 60
    end
end

#===============================================================================
# Target moves last this round, ignoring priority/speed. (Quash)
#===============================================================================
class PokeBattle_Move_11E < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        return true if pbMoveFailedTargetAlreadyMoved?(target, show_message)
        # Target isn't going to use a move
        oppMove = @battle.choices[target.index][2]
        unless oppMove
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} isn't using a move this turn!")) if show_message
            return true
        end
        # Target is already maximally Quashed and will move last anyway
        highestQuash = 0
        @battle.eachBattler do |b|
            next if b.effects[:Quash] <= highestQuash
            highestQuash = b.effects[:Quash]
        end
        if highestQuash > 0 && target.effects[:Quash] == highestQuash
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        # Target was already going to move last
        if highestQuash == 0 && @battle.pbPriority.last.index == target.index
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} was already forced to move last!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        highestQuash = 0
        @battle.eachBattler do |b|
            next if b.effects[:Quash] <= highestQuash
            highestQuash = b.effects[:Quash]
        end
        target.applyEffect(:Quash, highestQuash + 1)
        @battle.pbDisplay(_INTL("{1}'s move was postponed!", target.pbThis))
    end

    def pbFailsAgainstTargetAI?(_user, _target); return false; end

    def getTargetAffectingEffectScore(user, target)
        return 0 unless user.opposes?(target)
        return 0 unless user.hasAlly?
        userSpeed = user.pbSpeed(true)
        targetSpeed = target.pbSpeed(true)
        return 0 if targetSpeed > userSpeed
        return 50
    end
end

#===============================================================================
# For 5 rounds, for each priority bracket, slow Pokémon move before fast ones.
# (Trick Room)
#===============================================================================
class PokeBattle_Move_11F < PokeBattle_RoomMove
    def initialize(battle, move)
        super
        @roomEffect = :TrickRoom
    end
end

#===============================================================================
# User switches places with its ally. (Ally Switch)
#===============================================================================
class PokeBattle_Move_120 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        eachValidSwitch(user) do |_ally|
            return false
        end
        if show_message
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} has no valid allies to switch with!"))
        end
        return true
    end

    def eachValidSwitch(battler)
        idxUserOwner = @battle.pbGetOwnerIndexFromBattlerIndex(battler.index)
        battler.eachAlly do |b|
            next if @battle.pbGetOwnerIndexFromBattlerIndex(b.index) != idxUserOwner
            next unless b.near?(battler)
            yield b
        end
    end

    def pbEffectGeneral(user)
        idxA = user.index
        idxB = -1
        eachValidSwitch(user) do |ally|
            idxB = ally.index
        end
        if @battle.pbSwapBattlers(idxA, idxB)
            @battle.pbDisplay(_INTL("{1} and {2} switched places!",
               @battle.battlers[idxB].pbThis, @battle.battlers[idxA].pbThis(true)))
        end
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Ally Switch.")
        return 0
    end
end

#===============================================================================
# Target's attacking stats are used instead of user's Attack for this move's calculations.
# (Foul Play, Tricky Toxins)
#===============================================================================
class PokeBattle_Move_121 < PokeBattle_Move
    def pbAttackingStat(_user, target)
        return target, :SPECIAL_ATTACK if specialMove?
        return target, :ATTACK
    end
end

#===============================================================================
# Target's Defense is used instead of its Special Defense for this move's
# calculations. (Psyshock, Psystrike, Secret Sword)
#===============================================================================
class PokeBattle_Move_122 < PokeBattle_Move
    def pbDefendingStat(_user, target)
        return target, :DEFENSE
    end
end

#===============================================================================
# Only damages Pokémon that share a type with the user. (Synchronoise)
#===============================================================================
class PokeBattle_Move_123 < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        userTypes = user.pbTypes(true)
        targetTypes = target.pbTypes(true)
        sharesType = false
        userTypes.each do |t|
            next unless targetTypes.include?(t)
            sharesType = true
            break
        end
        unless sharesType
            if show_message
                @battle.pbDisplay(_INTL("{1} is unaffected, since it doesn't share a type with {2}!", target.pbThis,
    user.pbThis(true)))
            end
            return true
        end
        return false
    end
end

#===============================================================================
# For 5 rounds, swaps all battlers' base Defense with base Special Defense.
# (Wonder Room)
#===============================================================================
class PokeBattle_Move_124 < PokeBattle_RoomMove
    def initialize(battle, move)
        super
        @roomEffect = :WonderRoom
    end
end

#===============================================================================
# Fails unless user has already used all other moves it knows. (Last Resort)
#===============================================================================
class PokeBattle_Move_125 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        hasThisMove = false
        hasOtherMoves = false
        hasUnusedMoves = false
        user.eachMove do |m|
            hasThisMove    = true if m.id == @id
            hasOtherMoves  = true if m.id != @id
            hasUnusedMoves = true if m.id != @id && !user.movesUsed.include?(m.id)
        end
        unless hasThisMove
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} doesn't know Last Resort!"))
            end
            return true
        end
        unless hasOtherMoves
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} has no other moves!")) if show_message
            return true
        end
        if hasUnusedMoves
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} hasn't yet used all its other moves!"))
            end
            return true
        end
        return false
    end
end

#===============================================================================
# The user dances to restore an ally by 50% max HP. They're cured of any status conditions. (Healthy Cheer)
#===============================================================================
class PokeBattle_Move_126 < PokeBattle_Move_0DF
    def pbFailsAgainstTarget?(_user, target, show_message)
       if !target.canHeal? && !target.pbHasAnyStatus?
            @battle.pbDisplay(_INTL("{1} can't be healed and it has no status conditions!", target.pbThis)) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        super
        healStatus(target)
    end

    def getEffectScore(user, target)
        score = super
        score += 40 if target.pbHasAnyStatus?
        return score
    end
end

#===============================================================================
# User cuts its own HP by 25% to curse all foes and also to set Ingrain. (Cursed Roots)
#===============================================================================
class PokeBattle_Move_127 < PokeBattle_Move_0DB
    def pbMoveFailed?(user, _targets, show_message)
        if user.hp <= (user.totalhp / 4)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s HP is too low!")) if show_message
            return true
        end
        allCursed = true
        user.eachOpposing do |b|
            next if b.effectActive?(:Curse)
            allCursed = false
            break
        end
        if user.effectActive?(:Ingrain) && allCursed
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s roots are already planted and all foes are already cursed!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        @battle.pbDisplay(_INTL("{1} cut its own HP!", user.pbThis))
        user.applyFractionalDamage(1.0 / 4.0, false)

        user.eachOpposing do |b|
            next if b.effectActive?(:Curse)
            b.applyEffect(:Curse)
        end

        super
    end

    def getEffectScore(user, _target)
        score = super
        score += getHPLossEffectScore(user, 0.25)
        return score
    end
end

#===============================================================================
# Not currently used.
#===============================================================================
class PokeBattle_Move_128 < PokeBattle_Move
end

#===============================================================================
# Not currently used.
#===============================================================================
class PokeBattle_Move_129 < PokeBattle_Move
end

#===============================================================================
# Not currently used.
#===============================================================================
class PokeBattle_Move_12A < PokeBattle_Move
end

#===============================================================================
# Not currently used.
#===============================================================================
class PokeBattle_Move_12B < PokeBattle_Move
end

#===============================================================================
# Not currently used.
#===============================================================================
class PokeBattle_Move_12C < PokeBattle_Move
end

#===============================================================================
# Not currently used.
#===============================================================================
class PokeBattle_Move_12D < PokeBattle_Move
end

#===============================================================================
# Not currently used.
#===============================================================================
class PokeBattle_Move_12E < PokeBattle_Move
end

#===============================================================================
# Not currently used.
#===============================================================================
class PokeBattle_Move_12F < PokeBattle_Move
end

#===============================================================================
# Not currently used.
#===============================================================================
class PokeBattle_Move_130 < PokeBattle_Move
end

#===============================================================================
# Not currently used.
#===============================================================================
class PokeBattle_Move_131 < PokeBattle_Move
end

#===============================================================================
# Not currently used.
#===============================================================================
class PokeBattle_Move_132 < PokeBattle_Move
end

#===============================================================================
# (Not currently used.)
#===============================================================================
class PokeBattle_Move_133 < PokeBattle_Move
end

#===============================================================================
# (Not currently used.)
#===============================================================================
class PokeBattle_Move_134 < PokeBattle_Move
end

#===============================================================================
# Freezes the target. Effectiveness against Water-type is 2x. (Freeze-Dry)
#===============================================================================
class PokeBattle_Move_135 < PokeBattle_FrostbiteMove
    def pbCalcTypeModSingle(moveType, defType, user, target)
        return Effectiveness::SUPER_EFFECTIVE_ONE if defType == :WATER
        return super
    end
end

#===============================================================================
# (Not currently used.)
#===============================================================================
class PokeBattle_Move_136 < PokeBattle_Move
end

#===============================================================================
# (Not currently used.)
#===============================================================================
class PokeBattle_Move_137 < PokeBattle_Move
end

#===============================================================================
# Increases target's Defense and Special Defense by 3 steps. (Aromatic Mist)
#===============================================================================
class PokeBattle_Move_138 < PokeBattle_TargetMultiStatUpMove
    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @statUp = [:DEFENSE, 3, :SPECIAL_DEFENSE, 3]
    end
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_139 < PokeBattle_Move
end

#===============================================================================
# Decreases the target's Attack and Special Attack by 2 steps each. Always hits.
# (Noble Roar)
#===============================================================================
class PokeBattle_Move_13A < PokeBattle_TargetMultiStatDownMove
    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @statDown = ATTACKING_STATS_2
    end

    def pbAccuracyCheck(_user, _target); return true; end
end

#===============================================================================
# Decreases the user's Defense by 1 step. Always hits. Ends target's
# protections immediately. (Hyperspace Fury)
#===============================================================================
class PokeBattle_Move_13B < PokeBattle_StatDownMove
    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 2]
    end

    def pbMoveFailed?(user, _targets, show_message)
        if !user.countsAs?(:HOOPA)
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        elsif user.form != 1
            @battle.pbDisplay(_INTL("But {1} can't use it the way it is now!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbAccuracyCheck(_user, _target); return true; end

    def pbEffectAgainstTarget(_user, target)
        removeProtections(target)
    end
end

#===============================================================================
# (Not currently used.)
#===============================================================================
class PokeBattle_Move_13C < PokeBattle_Move
end

#===============================================================================
# Decreases the target's Special Attack by 4 steps. (Eerie Impulse)
#===============================================================================
class PokeBattle_Move_13D < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 4]
    end
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_13E < PokeBattle_Move
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_13F < PokeBattle_Move
end

#===============================================================================
# Decreases the Attack, Special Attack and Speed of all nearby poisoned foes
# by 3 steps each. (Venom Drench)
#===============================================================================
class PokeBattle_Move_140 < PokeBattle_Move
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 3, :SPECIAL_ATTACK, 3, :SPEED, 3]
    end

    def pbMoveFailed?(user, _targets, show_message)
        @battle.eachBattler do |b|
            return false if isValidTarget?(user, b)
        end
        @battle.pbDisplay(_INTL("But it failed, since it has no valid targets!")) if show_message
        return true
    end

    def isValidTarget?(user, target)
        return false if target.fainted?
        return false unless target.poisoned?
        return false if !target.pbCanLowerStatStep?(:ATTACK, user, self) &&
                        !target.pbCanLowerStatStep?(:SPECIAL_ATTACK, user, self) &&
                        !target.pbCanLowerStatStep?(:SPEED, user, self)
        return true
    end

    def pbFailsAgainstTarget?(user, target, _show_message)
        return !isValidTarget?(user, target)
    end

    def pbEffectAgainstTarget(user, target)
        target.pbLowerMultipleStatSteps(@statDown, user, move: self)
    end

    def getTargetAffectingEffectScore(user, target)
        return getMultiStatDownEffectScore(@statDown, user, target) if isValidTarget?(user, target)
        return 0
    end
end

#===============================================================================
# Reverses all stat changes of the target. (Topsy-Turvy)
#===============================================================================
class PokeBattle_Move_141 < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        failed = true
        GameData::Stat.each_battle do |s|
            next if target.steps[s.id] == 0
            failed = false
            break
        end
        if failed
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} has no stat changes!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        GameData::Stat.each_battle { |s| target.steps[s.id] *= -1 }
        @battle.pbDisplay(_INTL("{1}'s stats were reversed!", target.pbThis))
    end

    def getTargetAffectingEffectScore(user, target)
        score = 0
        netSteps = 0
        GameData::Stat.each_battle do |s|
            netSteps += target.steps[s.id]
        end
        if user.opposes?(target)
            score += netSteps * 10
        else
            score -= netSteps * 10
        end
        return score
    end
end

#===============================================================================
# Gives target the Ghost type. (Trick-or-Treat)
#===============================================================================
class PokeBattle_Move_142 < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        unless GameData::Type.exists?(:GHOST)
            @battle.pbDisplay(_INTL("But it failed, since the Ghost-type doesn't exist!")) if show_message
            return true
        end
        if target.pbHasType?(:GHOST)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already Ghost-type!"))
            end
            return true
        end
        unless target.canChangeType?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can't have its type changed!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Type3, :GHOST)
    end

    def getTargetAffectingEffectScore(_user, _target)
        return 60
    end
end

#===============================================================================
# Gives target the Grass type. (Forest's Curse)
#===============================================================================
class PokeBattle_Move_143 < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        unless GameData::Type.exists?(:GRASS)
            @battle.pbDisplay(_INTL("But it failed, since the Grass-type doesn't exist!")) if show_message
            return true
        end
        if target.pbHasType?(:GRASS)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already Grass-type!"))
            end
            return true
        end
        unless target.canChangeType?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can't have its type changed!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Type3, :GRASS)
    end

    def getTargetAffectingEffectScore(_user, _target)
        return 60
    end
end

#===============================================================================
# Type effectiveness is multiplied by the Flying-type's effectiveness against
# the target. (Flying Press)
#===============================================================================
class PokeBattle_Move_144 < PokeBattle_Move
    def pbCalcTypeModSingle(moveType, defType, user, target)
        ret = super
        if GameData::Type.exists?(:FLYING)
            flyingEff = Effectiveness.calculate_one(:FLYING, defType)
            ret *= flyingEff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
        end
        return ret
    end
end

#===============================================================================
# Target's moves become Electric-type for the rest of the round. (Electrify)
#===============================================================================
class PokeBattle_Move_145 < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.effectActive?(:Electrify)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} was already electrified!"))
            end
            return true
        end
        return true if pbMoveFailedTargetAlreadyMoved?(target, show_message)
        return false
    end

    def pbFailsAgainstTargetAI?(_user, _target); return false; end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Electrify)
    end

    def getEffectScore(_user, _target)
        return 40 # Move sucks
    end
end

#===============================================================================
# All Normal-type moves become Electric-type for the rest of the round.
# (Ion Deluge, Plasma Fists)
#===============================================================================
class PokeBattle_Move_146 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        return false if damagingMove?
        if @battle.field.effectActive?(:IonDeluge)
            @battle.pbDisplay(_INTL("But it failed, since ions already shower the field!")) if show_message
            return true
        end
        return true if pbMoveFailedLastInRound?(user, show_message)
        return false
    end

    def pbEffectGeneral(_user)
        @battle.field.applyEffect(:IonDeluge)
    end
end

#===============================================================================
# Always hits. Ends target's protections immediately. (Hyperspace Hole)
#===============================================================================
class PokeBattle_Move_147 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end
    def pbAccuracyCheck(_user, _target); return true; end

    def pbEffectAgainstTarget(_user, target)
        removeProtections(target)
    end
end

#===============================================================================
# Powders the foe. This round, if it uses a Fire move, it loses 1/4 of its max
# HP instead. (Black Powder)
#===============================================================================
class PokeBattle_Move_148 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.effectActive?(:Powder)
            @battle.pbDisplay(_INTL("But it failed, since the target is already covered in powder!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Powder)
    end

    def getEffectScore(user, target)
        return 20 unless target.pbHasMoveType?(:FIRE)
        return 0 if hasBeenUsed?(user)
        return 80
    end
end

#===============================================================================
# This round, the user's side is unaffected by damaging moves. (Mat Block)
#===============================================================================
class PokeBattle_Move_149 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.firstTurn?
            @battle.pbDisplay(_INTL("But it failed, since it isn't #{user.pbThis(true)}'s first turn!")) if show_message
            return true
        end
        if user.pbOwnSide.effectActive?(:MatBlock)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since a Mat was already thrown up on #{user.pbThis(true)}'s side of the field!"))
            end
            return true
        end
        return true if pbMoveFailedLastInRound?(user, show_message)
        return false
    end

    def pbEffectGeneral(user)
        user.pbOwnSide.applyEffect(:MatBlock)
    end

    def getEffectScore(user, _target)
        score = 0
        # Check only status having pokemon
        user.eachOpposing do |b|
            next unless b.hasDamagingAttack?
            score += 40
            score += 40 if user.hasAlly?
        end
        return score
    end
end

#===============================================================================
# User's side is protected against status moves this round. (Crafty Shield)
#===============================================================================
class PokeBattle_Move_14A < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.pbOwnSide.effectActive?(:CraftyShield)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since a crafty shield is already protecting #{user.pbTeam(true)}!"))
            end
            return true
        end
        return true if pbMoveFailedLastInRound?(user, show_message)
        return false
    end

    def pbEffectGeneral(user)
        user.pbOwnSide.applyEffect(:CraftyShield)
    end

    def getEffectScore(user, _target)
        score = 0
        # Check only status having pokemon
        user.eachOpposing do |b|
            next unless b.hasStatusMove?
            score += 40
            score += 40 if user.hasAlly?
        end
        return score
    end
end

#===============================================================================
# User is protected against damaging moves this round. Decreases the Attack of
# the user of a stopped physical move by 1 step. (King's Shield)
#===============================================================================
class PokeBattle_Move_14B < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :KingsShield
    end

    def getEffectScore(user, target)
        score = super
        # Check only physical attackers
        user.eachPredictedProtectHitter(0) do |b|
            score += getMultiStatDownEffectScore([:ATTACK,1],user,b)
        end
        return score
    end
end

#===============================================================================
# User is protected against moves that target it this round. Damages the user of
# a stopped physical move by 1/8 of its max HP. (Spiky Shield)
#===============================================================================
class PokeBattle_Move_14C < PokeBattle_ProtectMove
    def initialize(battle, move)
        super
        @effect = :SpikyShield
    end

    def getEffectScore(user, target)
        score = super
        # Check only physical attackers
        user.eachPredictedProtectHitter(0) do |_b|
            score += 20
        end
        return score
    end
end

#===============================================================================
# Two turn attack. Skips first turn, attacks second turn. (Phantom Force)
# Is invulnerable during use. Ends target's protections upon hit.
#===============================================================================
class PokeBattle_Move_14D < PokeBattle_Move_0CD
    # NOTE: This move is identical to function code 0CD (Shadow Force).
end

#===============================================================================
# Two turn attack. Skips first turn, and increases the user's Special Attack,
# Special Defense and Speed by 2 steps each in the second turn. (Geomancy)
#===============================================================================
class PokeBattle_Move_14E < PokeBattle_TwoTurnMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 4, :SPECIAL_DEFENSE, 4, :SPEED, 4]
    end

    def pbMoveFailed?(user, _targets, show_message)
        return false if user.effectActive?(:TwoTurnAttack) # Charging turn
        if !user.pbCanRaiseStatStep?(:SPECIAL_ATTACK, user, self) &&
           !user.pbCanRaiseStatStep?(:SPECIAL_DEFENSE, user, self) &&
           !user.pbCanRaiseStatStep?(:SPEED, user, self)
            @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!", user.pbThis)) if show_message
            return true
        end
        return false
    end

    def pbChargingTurnMessage(user, _targets)
        @battle.pbDisplay(_INTL("{1} is absorbing power!", user.pbThis))
    end

    def pbEffectGeneral(user)
        return unless @damagingTurn
        user.pbRaiseMultipleStatSteps(@statUp, user, move: self)
    end

    def getEffectScore(user, target)
        score = super
        score += getMultiStatUpEffectScore(@statUp, user, target)
        return score
    end
end

#===============================================================================
# User gains 3/4 the HP it inflicts as damage. (Draining Kiss, Oblivion Wing)
#===============================================================================
class PokeBattle_Move_14F < PokeBattle_DrainMove
    def drainFactor(_user, _target); return 0.75; end
end

#===============================================================================
# If this move KO's the target, increases the user's Attack by 5 steps.
# (Fell Stinger)
#===============================================================================
class PokeBattle_Move_150 < PokeBattle_Move
    def pbEffectAfterAllHits(user, target)
        return unless target.damageState.fainted
        user.tryRaiseStat(:ATTACK, user, increment: 5, move: self)
    end

    def getFaintEffectScore(user, target)
        return getMultiStatUpEffectScore([:ATTACK, 5], user, user)
    end
end

#===============================================================================
# Decreases the target's Attack and Special Attack by 1 step each. Then, user
# switches out. Ignores trapping moves. (Parting Shot)
#===============================================================================
class PokeBattle_Move_151 < PokeBattle_TargetMultiStatDownMove
    def switchOutMove?; return true; end

    def initialize(battle, move)
        super
        @statDown = ATTACKING_STATS_2
    end

    def pbEndOfMoveUsageEffect(user, targets, numHits, switchedBattlers)
        switcher = user
        targets.each do |b|
            next if switchedBattlers.include?(b.index)
            switcher = b if b.effectActive?(:MagicCoat) || b.effectActive?(:MagicBounce)
        end
        return if switcher.fainted? || numHits == 0
        return unless @battle.pbCanChooseNonActive?(switcher.index)
        @battle.pbDisplay(_INTL("{1} went back to {2}!", switcher.pbThis, @battle.pbGetOwnerName(switcher.index)))
        @battle.pbPursuit(switcher.index)
        return if switcher.fainted?
        newPkmn = @battle.pbGetReplacementPokemonIndex(switcher.index) # Owner chooses
        return if newPkmn < 0
        @battle.pbRecallAndReplace(switcher.index, newPkmn)
        @battle.pbClearChoice(switcher.index) # Replacement Pokémon does nothing this round
        @battle.moldBreaker = false if switcher.index == user.index
        switchedBattlers.push(switcher.index)
        switcher.pbEffectsOnSwitchIn(true)
    end

    def getEffectScore(user, target)
        return getSwitchOutEffectScore(user, target)
    end
end

#===============================================================================
# No Pokémon can switch out or flee until the end of the next round. (Fairy Lock)
#===============================================================================
class PokeBattle_Move_152 < PokeBattle_Move
    def pbMoveFailed?(_user, _targets, show_message)
        if @battle.field.effectActive?(:FairyLock)
            @battle.pbDisplay(_INTL("But it failed, since a Fairy Lock is already active!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(_user)
        @battle.field.applyEffect(:FairyLock, 2)
        @battle.pbDisplay(_INTL("No one will be able to run away during the next turn!"))
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Fairy Lock.")
        return 0 # The move is both annoying and very weak
    end
end

#===============================================================================
# Entry hazard. Lays a Speed reducing web on the opposing side. (Sticky Web)
#===============================================================================
class PokeBattle_Move_153 < PokeBattle_Move
    def hazardMove?; return true; end
    def aiAutoKnows?(pokemon); return true; end

    def pbMoveFailed?(user, _targets, show_message)
        if user.pbOpposingSide.effectActive?(:StickyWeb)
            @battle.pbDisplay(_INTL("But it failed, since a Sticky Web is already laid out!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.pbOpposingSide.applyEffect(:StickyWeb)
    end

    def getEffectScore(user, target)
        return getHazardSettingEffectScore(user, target)
    end
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_154 < PokeBattle_Move
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_155 < PokeBattle_Move
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_156 < PokeBattle_Move
end

#===============================================================================
# Doubles the prize money the player gets after winning the battle. (Happy Hour)
#===============================================================================
class PokeBattle_Move_157 < PokeBattle_Move
    def pbEffectGeneral(user)
        @battle.field.applyEffect(:HappyHour) unless user.opposes?
        @battle.pbDisplay(_INTL("Everyone is caught up in the happy atmosphere!"))
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Happy Hour.")
        return 0
    end
end

#===============================================================================
# Fails unless user has consumed a berry at some point. (Belch)
#===============================================================================
class PokeBattle_Move_158 < PokeBattle_Move
    def pbCanChooseMove?(user, commandPhase, showMessages)
        unless user.belched?
            if showMessages
                msg = _INTL("{1} hasn't eaten any held berry, so it can't possibly belch!", user.pbThis)
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            return false
        end
        return true
    end

    def pbMoveFailed?(user, _targets, show_message)
        unless user.belched?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} hasn't eaten a berry yet!"))
            end
            return true
        end
        return false
    end
end

#===============================================================================
# Poisons the target and decreases its Speed by 4 steps. (Toxic Thread)
#===============================================================================
class PokeBattle_Move_159 < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if !target.canPoison?(user, false, self) &&
           !target.pbCanLowerStatStep?(:SPEED, user, self)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can't be poisoned or have its Speed lowered!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.applyPoison(user) if target.canPoison?(user, false, self)
        target.tryLowerStat(:SPEED, user, increment: 4, move: self)
    end

    def getTargetAffectingEffectScore(user, target)
        score = getMultiStatDownEffectScore([:SPEED,4],user,target)
        score += getPoisonEffectScore(user, target)
        return score
    end
end

#===============================================================================
# Cures the target's burn. (Sparkling Aria)
#===============================================================================
class PokeBattle_Move_15A < PokeBattle_Move
    def pbAdditionalEffect(_user, target)
        return if target.fainted? || target.damageState.substitute
        return if target.status != :BURN
        target.pbCureStatus(true, :BURN)
    end

    def getTargetAffectingEffectScore(user, target)
        score = 0
        if !target.substituted? && target.burned?
            if target.opposes?(user)
                score -= 30
            else
                score += 30
            end
        end
        return score
    end
end

#===============================================================================
# Cures the target's permanent status problems. Heals user by 1/2 of its max HP.
# (Purify)
#===============================================================================
class PokeBattle_Move_15B < PokeBattle_HalfHealingMove
    def pbFailsAgainstTarget?(_user, target, show_message)
        unless target.pbHasAnyStatus?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} has no status conditions!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.pbCureStatus
        super
    end

    def getEffectScore(user, _target)
        # The target for this is set as the user since its the user that heals
        score = getHealingEffectScore(user, user, 5)
        score += 30
        return score
    end
end

#===============================================================================
# TODO: Currently unused.
#===============================================================================
class PokeBattle_Move_15C < PokeBattle_Move
end

#===============================================================================
# User gains stat steps equal to each of the target's positive stat steps,
# and target's positive stat steps become 0, before damage calculation.
# (Spectral Thief, Scam)
#===============================================================================
class PokeBattle_Move_15D < PokeBattle_Move
    def statStepStealingMove?; return true; end
    
    def ignoresSubstitute?(_user); return true; end

    def pbCalcDamage(user, target, numTargets = 1)
        if target.hasRaisedStatSteps?
            pbShowAnimation(@id, user, target, 1) # Stat step-draining animation
            @battle.pbDisplay(_INTL("{1} stole the target's boosted stats!", user.pbThis))
            showAnim = true
            GameData::Stat.each_battle do |s|
                next if target.steps[s.id] <= 0
                if user.pbCanRaiseStatStep?(s.id, user,
self) && user.pbRaiseStatStep(s.id, target.steps[s.id], user, showAnim)
                    showAnim = false
                end
                target.steps[s.id] = 0
            end
        end
        super
    end

    def getEffectScore(_user, target)
        score = 0
        GameData::Stat.each_battle do |s|
            next if target.steps[s.id] <= 0
            score += target.steps[s.id] * 20
        end
        return score
    end

    def shouldHighlight?(_user, target)
        return target.hasRaisedStatSteps?
    end
end

#===============================================================================
# Until the end of the next round, the user's moves will always be critical hits.
# (Laser Focus)
#===============================================================================
class PokeBattle_Move_15E < PokeBattle_Move
    def pbEffectGeneral(user)
        user.applyEffect(:LaserFocus, 2)
        @battle.pbDisplay(_INTL("{1} concentrated intensely!", user.pbThis))
    end

    def getEffectScore(user, _target)
        return 0 if user.effectActive?(:LaserFocus)
        return 80
    end
end

#===============================================================================
# Decreases the user's Defense by 3 steps. (Clanging Scales)
#===============================================================================
class PokeBattle_Move_15F < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 3]
    end
end

#===============================================================================
# Decreases the target's Attack by 1 step. Heals user by an amount equal to the
# target's Attack stat. (Strength Sap)
#===============================================================================
class PokeBattle_Move_160 < PokeBattle_Move
    def healingMove?; return true; end

    def pbFailsAgainstTarget?(_user, target, show_message)
        # NOTE: The official games appear to just check whether the target's Attack
        #       stat step is -6 and fail if so, but I've added the "fail if target
        #       has Contrary and is at +6" check too for symmetry. This move still
        #       works even if the stat step cannot be changed due to an ability or
        #       other effect.
        if !@battle.moldBreaker && target.hasActiveAbility?(%i[CONTRARY ECCENTRIC]) &&
           target.statStepAtMax?(:ATTACK)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s Attack can't go any higher!"))
            end
            return true
        elsif target.statStepAtMin?(:ATTACK)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s Attack can't go any lower!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        healAmount = target.pbAttack
        # Reduce target's Attack stat
        target.tryLowerStat(:ATTACK, user, move: self)
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

    def getEffectScore(user, target)
        return getHealingEffectScore(user, user, 2)
    end

    def getTargetAffectingEffectScore(user, target)
        return getMultiStatDownEffectScore([:ATTACK, 1], user, target)
    end
end

#===============================================================================
# User and target swap their Speed stats (not their stat steps). (Speed Swap)
#===============================================================================
class PokeBattle_Move_161 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbEffectAgainstTarget(user, target)
        userSpeed = user.base_speed
        targetSpeed = target.base_speed
        user.applyEffect(:BaseSpeed,targetSpeed)
        target.applyEffect(:BaseSpeed,userSpeed)
        @battle.pbDisplay(_INTL("{1} switched base Speed with its target!", user.pbThis))
    end

    def getEffectScore(user, target)
        score = getWantsToBeSlowerScore(user, target, magnitude = 8)
        return score
    end
end

#===============================================================================
# User loses their Fire type. Fails if user is not Fire-type. (Burn Up)
#===============================================================================
class PokeBattle_Move_162 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.pbHasType?(:FIRE)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} isn't Fire-type!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAfterAllHits(user, _target)
        user.applyEffect(:BurnUp)
    end

    def getEffectScore(_user, _target)
        return -20
    end
end

#===============================================================================
# Ignores all abilities that alter this move's success or damage.
# (Moongeist Beam, Sunsteel Strike)
#===============================================================================
class PokeBattle_Move_163 < PokeBattle_Move
    def pbChangeUsageCounters(user, specialUsage)
        super
        @battle.moldBreaker = true unless specialUsage
    end
end

#===============================================================================
# Ignores all abilities that alter this move's success or damage. This move is
# physical if user's Attack is higher than its Special Attack (after applying
# stat steps), and special otherwise. (Photon Geyser)
#===============================================================================
class PokeBattle_Move_164 < PokeBattle_Move_163
    def initialize(battle, move)
        super
        @calculated_category = 1
    end

    def calculateCategory(user, _targets)
        return selectBestCategory(user)
    end
end

#===============================================================================
# Negates the target's ability while it remains on the field, if it has already
# performed its action this round. (Core Enforcer)
#===============================================================================
class PokeBattle_Move_165 < PokeBattle_Move
    def pbEffectAgainstTarget(_user, target)
        return if target.damageState.substitute || target.effectActive?(:GastroAcid)
        return if target.unstoppableAbility?
        return if @battle.choices[target.index][0] != :UseItem &&
                  !((@battle.choices[target.index][0] == :UseMove ||
                  @battle.choices[target.index][0] == :Shift) && target.movedThisRound?)
        target.applyEffect(:GastroAcid)
    end

    def getEffectScore(user, target)
        score = getWantsToBeSlowerScore(user, target, 3) if !target.substituted? && !target.effectActive?(:GastroAcid)
        return score
    end
end

#===============================================================================
# Power is doubled if the user's last move failed. (Stomping Tantrum)
#===============================================================================
class PokeBattle_Move_166 < PokeBattle_Move
    def pbBaseDamage(baseDmg, user, _target)
        baseDmg *= 2 if user.lastRoundMoveFailed
        return baseDmg
    end
end

#===============================================================================
# For 5 rounds, lowers power of attacks against the user's side. Fails if
# weather is not hail. (Aurora Veil)
#===============================================================================
class PokeBattle_Move_167 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if @battle.pbWeather != :Hail
            @battle.pbDisplay(_INTL("But it failed, since it's not Hailing!")) if show_message
            return true
        end
        if user.pbOwnSide.effectActive?(:AuroraVeil)
            @battle.pbDisplay(_INTL("But it failed, since Aurora Veil is already active!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.pbOwnSide.applyEffect(:AuroraVeil, user.getScreenDuration)
    end

    def getEffectScore(user, _target)
        score = 0
        user.eachOpposing do |b|
            score += 40 if b.hasDamagingAttack?
        end
        score += 15 * user.getScreenDuration
        score = (score * 1.3).ceil if user.fullHealth?
        return score
    end
end

#===============================================================================
# (Not currently used.)
#===============================================================================
class PokeBattle_Move_168 < PokeBattle_Move
end

#===============================================================================
# This move's type is the same as the user's first type. (Revelation Dance)
#===============================================================================
class PokeBattle_Move_169 < PokeBattle_Move
    def pbBaseType(user)
        userTypes = user.pbTypes(true)
        return userTypes[0]
    end
end

#===============================================================================
# This round, target becomes the target of attacks that have single targets.
# (Spotlight)
#===============================================================================
class PokeBattle_Move_16A < PokeBattle_Move
    def pbEffectAgainstTarget(_user, target)
        maxSpotlight = 0
        target.eachAlly do |b|
            next if b.effects[:Spotlight] <= maxSpotlight
            maxSpotlight = b.effects[:Spotlight]
        end
        target.applyEffect(:Spotlight, maxSpotlight + 1)
    end

    def getEffectScore(_user, target)
        return 0 unless target.hasAlly?
        score = 50
        score += 25 if target.aboveHalfHealth?
        return score
    end
end

#===============================================================================
# The target uses its most recent move again. (Instruct)
#===============================================================================
class PokeBattle_Move_16B < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbFailsAgainstTarget?(_user, target, show_message)
        unless target.lastRegularMoveUsed
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} hasn't used a move yet!"))
            end
            return true
        end
        unless target.pbHasMove?(target.lastRegularMoveUsed)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} no longer knows its most recent move!"))
            end
            return true
        end
        if target.usingMultiTurnAttack?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is locked into an attack!"))
            end
            return true
        end
        targetMove = @battle.choices[target.index][2]
        if targetMove && (targetMove.function == "115" ||   # Focus Punch
                          targetMove.function == "171" ||   # Shell Trap
                          targetMove.function == "172")     # Beak Blast
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is focusing!")) if show_message
            return true
        end
        unless GameData::Move.get(target.lastRegularMoveUsed).can_be_forced?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s last used move cant be instructed!"))
            end
            return true
        end
        if @battle.getBattleMoveInstanceFromID(target.lastRegularMoveUsed).is_a?(PokeBattle_TwoTurnMove)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s last used move is a two-turn move!"))
            end
            return true
        end
        idxMove = -1
        target.eachMoveWithIndex do |m, i|
            idxMove = i if m.id == target.lastRegularMoveUsed
        end
        if target.moves[idxMove].pp == 0 && target.moves[idxMove].total_pp > 0
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s last used move it out of PP!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Instruct)
    end

    def getEffectScore(_user, _target)
        return 0 # Much too chaotic of a move to allow the AI to use
    end
end

#===============================================================================
# Target cannot use sound-based moves for 2 more rounds. (Throat Chop)
#===============================================================================
class PokeBattle_Move_16C < PokeBattle_Move
    def pbAdditionalEffect(_user, target)
        return if target.fainted? || target.damageState.substitute
        target.applyEffect(:ThroatChop, 3)
    end

    def getTargetAffectingEffectScore(_user, target)
        return 30 if !target.effectActive?(:ThroatChop) && target.hasSoundMove? && !target.substituted?
        return 0
    end
end

#===============================================================================
# Heals user by 1/2 of its max HP, or 2/3 of its max HP in a sandstorm. (Shore Up)
#===============================================================================
class PokeBattle_Move_16D < PokeBattle_HealingMove
    def healRatio(_user)
        return 2.0 / 3.0 if @battle.sandy?
        return 1.0 / 2.0
    end

    def shouldHighlight?(_user, _target)
        return @battle.sandy?
    end
end

# TODO: create a "targeting healing move" parent class
#===============================================================================
# Heals target by 1/2 of its max HP, or 2/3 of its max HP in moonglow.
# (Floral Healing)
#===============================================================================
class PokeBattle_Move_16E < PokeBattle_Move
    def healingMove?; return true; end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.hp == target.totalhp
            @battle.pbDisplay(_INTL("{1}'s HP is full!", target.pbThis)) if show_message
            return true
        elsif !target.canHeal?
            @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        if @battle.moonGlowing?
            ratio = 2.0 / 3.0
        else
            ratio = 1.0 / 2.0
        end
        target.applyFractionalHealing(ratio)
    end

    def getEffectScore(user, target)
        magnitude = 3
        magnitude = 5 if @battle.moonGlowing?
        return getHealingEffectScore(user, target, magnitude)
    end

    def shouldHighlight?(_user, _target)
        return @battle.moonGlowing?
    end
end

#===============================================================================
# Damages target if target is a foe, or heals target by 1/2 of its max HP if
# target is an ally. (Pollen Puff)
#===============================================================================
class PokeBattle_Move_16F < PokeBattle_Move
    def pbTarget(user)
        return GameData::Target.get(:NearFoe) if user.effectActive?(:HealBlock)
        return super
    end

    def pbOnStartUse(user, targets)
        @healing = false
        @healing = !user.opposes?(targets[0]) if targets.length > 0
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        return false unless @healing
        if target.substituted? && !ignoresSubstitute?(user)
            @battle.pbDisplay(_INTL("#{target.pbThis} is protected behind its substitute!")) if show_message
            return true
        end
        unless target.canHeal?
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can't be healed!")) if show_message
            return true
        end
        return false
    end

    def damagingMove?(aiChecking = false)
        if aiChecking
            return super
        else
            return false if @healing
            return super
        end
    end

    def pbEffectAgainstTarget(_user, target)
        return unless @healing
        target.applyFractionalHealing(1.0 / 2.0)
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        hitNum = 1 if @healing # Healing anim
        super
    end

    def getEffectScore(user, target)
        return getHealingEffectScore(user, target) unless user.opposes?(target)
        return 0
    end

    def resetMoveUsageState
        @healing = false
    end
end

#===============================================================================
# Damages user by 1/2 of its max HP, even if this move misses. (Mind Blown)
#===============================================================================
class PokeBattle_Move_170 < PokeBattle_Move
    def worksWithNoTargets?; return true; end

    def pbMoveFailed?(user, _targets, show_message)
        unless @battle.moldBreaker
            bearer = @battle.pbCheckGlobalAbility(:DAMP)
            unless bearer.nil?
                if show_message
                    @battle.pbShowAbilitySplash(bearer, :DAMP)
                    @battle.pbDisplay(_INTL("{1} cannot use {2}!", user.pbThis, @name))
                    @battle.pbHideAbilitySplash(bearer)
                end
                return true
            end
        end
        return false
    end

    def shouldShade?(_user, _target)
        return false
    end

    def pbMoveFailedAI?(_user, _targets); return false; end

    def pbSelfKO(user)
        return unless user.takesIndirectDamage?
        user.pbReduceHP((user.totalhp / 2.0).round, false)
        user.pbItemHPHealCheck
    end

    def getEffectScore(user, _target)
        return getHPLossEffectScore(user, 0.5)
    end
end

#===============================================================================
# Fails if user has not been hit by an opponent's physical move this round.
# (Shell Trap)
#===============================================================================
class PokeBattle_Move_171 < PokeBattle_Move
    def pbDisplayChargeMessage(user)
        user.applyEffect(:ShellTrap)
    end

    def pbDisplayUseMessage(user, targets)
        super if user.tookPhysicalHit
    end

    def pbMoveFailed?(user, _targets, show_message)
        unless user.effectActive?(:ShellTrap)
            @battle.pbDisplay(_INTL("But it failed, since the effect wore off somehow!")) if show_message
            return true
        end
        unless user.tookPhysicalHit
            @battle.pbDisplay(_INTL("{1}'s shell trap didn't work!", user.pbThis)) if show_message
            return true
        end
        return false
    end

    def pbMoveFailedAI?(_user, _targets); return false; end

    def getEffectScore(_user, target)
        return -1000 unless target.hasPhysicalAttack?
        return -30
    end
end

#===============================================================================
# If a Pokémon attacks the user with a physical move before it uses this move, the
# attacker is burned. (Beak Blast)
#===============================================================================
class PokeBattle_Move_172 < PokeBattle_Move
    def pbDisplayChargeMessage(user)
        user.applyEffect(:BeakBlast)
    end

    def getTargetAffectingEffectScore(user, target)
        if target.hasPhysicalAttack?
            return getBurnEffectScore(user, target) / 2
        else
            return 0
        end
    end
end

#===============================================================================
# Cures the target's frostbite. (Rousing Hula)
#===============================================================================
class PokeBattle_Move_173 < PokeBattle_Move
    def pbAdditionalEffect(_user, target)
        return if target.fainted? || target.damageState.substitute
        return if target.status != :FROSTBITE
        target.pbCureStatus(true, :FROSTBITE)
    end

    def getTargetAffectingEffectScore(user, target)
        score = 0
        if !target.substituted? && target.frostbitten?
            if target.opposes?(user)
                score -= 30
            else
                score += 30
            end
        end
        return score
    end
end

#===============================================================================
# Fails if this isn't the user's first turn. (First Impression, Breach, Ambush)
#===============================================================================
class PokeBattle_Move_174 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.firstTurn?
            @battle.pbDisplay(_INTL("But it failed, since it isn't #{user.pbThis(true)}'s first turn!")) if show_message
            return true
        end
        return false
    end
end

#===============================================================================
# Hits twice. Causes the target to flinch. (Double Iron Bash)
#===============================================================================
class PokeBattle_Move_175 < PokeBattle_FlinchMove
    def multiHitMove?; return true; end
    def pbNumHits(_user, _targets, _checkingForAI = false); return 2; end
end

#===============================================================================
# Chance to paralyze the target. Fail if the user is not a Morpeko.
# If the user is a Morpeko-Hangry, this move will be Dark type. (Aura Wheel)
#===============================================================================
class PokeBattle_Move_176 < PokeBattle_NumbMove
    def pbMoveFailed?(user, _targets, show_message)
        if @id == :AURAWHEEL && !user.countsAs?(:MORPEKO)
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbBaseType(user)
        ret = :NORMAL
        case user.form
        when 0
            ret = :ELECTRIC
        when 1
            ret = :DARK
        end
        return ret
    end
end

#===============================================================================
# User's Defense is used instead of user's Attack for this move's calculations.
# (Body Press)
#===============================================================================
class PokeBattle_Move_177 < PokeBattle_Move
    def pbAttackingStat(user, _target)
        return user, :DEFENSE
    end
end

#===============================================================================
# If the user attacks before the target, or if the target switches in during the
# turn that Fishious Rend is used, its base power doubles. (Fishious Rend, Bolt Beak)
#===============================================================================
class PokeBattle_Move_178 < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 unless target.movedThisRound?
        return baseDmg
    end

    def pbBaseDamageAI(baseDmg, user, target)
        baseDmg *= 2 if user.pbSpeed(true) > target.pbSpeed(true)
        return baseDmg
    end
end

#===============================================================================
# Raises all user's stats by 2 steps in exchange for the user losing 1/3 of its
# maximum HP, rounded down. Fails if the user would faint. (Clangorous Soul)
#===============================================================================
class PokeBattle_Move_179 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2, :DEFENSE, 2, :SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2, :SPEED, 2]
    end

    def pbMoveFailed?(user, targets, show_message)
        if user.hp <= (user.totalhp / 3)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s HP is too low!")) if show_message
            return true
        end
        super
    end

    def pbEffectGeneral(user)
        super
        user.applyFractionalDamage(1.0 / 3.0)
    end

    def getEffectScore(user, target)
        score = super
        score += getHPLossEffectScore(user, 0.33)
        return score
    end
end

#===============================================================================
# Swaps barriers, veils and other effects between each side of the battlefield.
# (Court Change)
#===============================================================================
class PokeBattle_Move_17A < PokeBattle_Move
    def pbMoveFailed?(_user, _targets, show_message)
        playerSide = @battle.sides[0]
        trainerSide = @battle.sides[1]
        GameData::BattleEffect.each_side_effect do |effectData|
            next unless effectData.court_changed?
            id = effectData.id
            return false if playerSide.effectActive?(id) || trainerSide.effectActive?(id)
        end
        @battle.pbDisplay(_INTL("But it failed, since there were no effects to swap!")) if show_message
        return true
    end

    def pbEffectGeneral(user)
        effectsPlayer = @battle.sides[0].effects
        effectsTrainer = @battle.sides[1].effects
        GameData::BattleEffect.each_side_effect do |effectData|
            next unless effectData.court_changed?
            id = effectData.id
            effectsPlayer[id], effectsTrainer[id] = effectsTrainer[id], effectsPlayer[id]
        end
        @battle.pbDisplay(_INTL("{1} swapped the battle effects affecting each side of the field!", user.pbThis))
    end

    def getEffectScore(_user, _target)
        return 0 # TODO
    end
end

#===============================================================================
# The user raises the target's Attack and Sp. Atk by 5 steps by decorating
# the target. (Decorate)
#===============================================================================
class PokeBattle_Move_17B < PokeBattle_TargetMultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 5, :SPECIAL_ATTACK, 5]
    end
end

#===============================================================================
# Hits in 2 volleys. The second volley targets the original target's ally if it
# has one (that can be targeted), or the original target if not. A battler
# cannot be targeted if it is is immune to or protected from this move somehow,
# or if this move will miss it. (Dragon Darts)
# NOTE: This move sometimes shows a different failure message compared to the
#       official games. This is because of the order in which failure checks are
#       done (all checks for each target in turn, versus all targets for each
#       check in turn). This is considered unimportant, and since correcting it
#       would involve extensive code rewrites, it is being ignored.
#===============================================================================
class PokeBattle_Move_17C < PokeBattle_Move_0BD
    def pbNumHits(_user, _targets, checkingForAI = false)
        if checkingForAI
            return 2
        else
            return 1
        end
    end

    # Hit again if only at the 0th hit
    def pbRepeatHit?(hitNum = 0)
        return hitNum < 1
    end

    def pbModifyTargets(targets, user)
        return if targets.length != 1
        choices = []
        targets[0].eachAlly do |b|
            user.pbAddTarget(choices, user, b, self)
        end
        return if choices.empty?
        idxChoice = (choices.length > 1) ? @battle.pbRandom(choices.length) : 0
        user.pbAddTarget(targets, user, choices[idxChoice], self, !pbTarget(user).can_choose_distant_target?)
    end

    def pbShowFailMessages?(targets)
        if targets.length > 1
            valid_targets = targets.select { |b| !b.fainted? && !b.damageState.unaffected }
            return valid_targets.length <= 1
        end
        return super
    end

    def pbDesignateTargetsForHit(targets, hitNum)
        valid_targets = []
        targets.each do |b|
            next if b.damageState.unaffected || b.damageState.fainted
            valid_targets.push(b)
        end
        indexThisHit = hitNum % targets.length
        if indexThisHit == 2
            if valid_targets[2]
                return [valid_targets[2]]
            else
                indexThisHit = 1
            end
        end
        return [valid_targets[1]] if indexThisHit == 1 && valid_targets[1]
        return [valid_targets[0]]
    end
end

#===============================================================================
# Prevents both the user and the target from escaping. (Jaw Lock)
#===============================================================================
class PokeBattle_Move_17D < PokeBattle_Move
    def pbEffectAgainstTarget(user, target)
        return if target.damageState.substitute
        if !user.effectActive?(:JawLock) && !target.effectActive?(:JawLock)
            user.applyEffect(:JawLock)
            target.applyEffect(:JawLock)
            user.pointAt(:JawLockUser, target)
            target.pointAt(:JawLockUser, user)
            @battle.pbDisplay(_INTL("Neither Pokémon can escape!"))
        end
    end

    def getTargetAffectingEffectScore(_user, target)
        return 20 unless target.effectActive?(:JawLock)
        return 0
    end
end

#===============================================================================
# The user restores 1/4 of its maximum HP, rounded half up. If there is and
# adjacent ally, the user restores 1/4 of both its and its ally's maximum HP,
# rounded up. (Life Dew)
#===============================================================================
class PokeBattle_Move_17E < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def healingMove?; return true; end

    def healRatio(_user)
        return 1.0 / 4.0
    end

    def pbMoveFailed?(user, _targets, show_message)
        failed = true
        @battle.eachSameSideBattler(user) do |b|
            next if b.hp == b.totalhp
            failed = false
            break
        end
        if failed
            @battle.pbDisplay(_INTL("But it failed, since there was no one to heal!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.hp == target.totalhp
            @battle.pbDisplay(_INTL("{1}'s HP is full!", target.pbThis)) if show_message
            return true
        elsif !target.canHeal?
            @battle.pbDisplay(_INTL("{1} is unaffected!", target.pbThis)) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        hpGain = (target.totalhp / 4.0).round
        target.pbRecoverHP(hpGain)
    end

    def getEffectScore(_user, target)
        score = 0
        if target.canHeal?
            score += 20
            score += 40 if target.belowHalfHealth?
        end
        return score
    end
end

#===============================================================================
# Increases each stat by 1 step. Prevents user from fleeing. (No Retreat)
#===============================================================================
class PokeBattle_Move_17F < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2, :DEFENSE, 2, :SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2, :SPEED, 2]
    end

    def pbMoveFailed?(user, targets, show_message)
        if user.effectActive?(:NoRetreat)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already committed to the battle!"))
            end
            return true
        end
        super
    end

    def pbEffectGeneral(user)
        super
        user.applyEffect(:NoRetreat)
    end
end
