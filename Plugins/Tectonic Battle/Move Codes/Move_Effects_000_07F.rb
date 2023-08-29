#===============================================================================
# No additional effect.
#===============================================================================
class PokeBattle_Move_000 < PokeBattle_Move
end

#===============================================================================
# Does absolutely nothing. (Splash)
#===============================================================================
class PokeBattle_Move_001 < PokeBattle_Move
    def unusableInGravity?; return true; end

    def pbEffectGeneral(_user)
        @battle.pbDisplay(_INTL("But nothing happened!"))
    end
end

#===============================================================================
# Struggle, if defined as a move in moves.txt. Typically it won't be.
#===============================================================================
class PokeBattle_Move_002 < PokeBattle_Struggle
end

#===============================================================================
# Puts the target to sleep.
#===============================================================================
class PokeBattle_Move_003 < PokeBattle_SleepMove
end

#===============================================================================
# Makes the target drowsy; it falls asleep at the end of the next turn. (Yawn)
#===============================================================================
class PokeBattle_Move_004 < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.effectActive?(:Yawn)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already drowsy!")) if show_message
            return true
        end
        return true unless target.canSleep?(user, show_message, self)
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:Yawn, 2)
    end

    def getEffectScore(user, target)
        score = getSleepEffectScore(user, target)
        score -= 60
        return score
    end
end

#===============================================================================
# Poisons the target.
#===============================================================================
class PokeBattle_Move_005 < PokeBattle_PoisonMove
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_006 < PokeBattle_Move
end

#===============================================================================
# Numbs the target.
#===============================================================================
class PokeBattle_Move_007 < PokeBattle_NumbMove
end

#===============================================================================
# Numbs the target. Accuracy perfect in rain. Hits some
# semi-invulnerable targets. (Thunder)
#===============================================================================
class PokeBattle_Move_008 < PokeBattle_NumbMove
    def hitsFlyingTargets?; return true; end

    def immuneToRainDebuff?; return false; end

    def pbBaseAccuracy(user, target)
        return 0 if @battle.rainy?
        return super
    end

    def shouldHighlight?(_user, _target)
        return @battle.rainy?
    end
end

#===============================================================================
# Numbs the target. May cause the target to flinch. (Thunder Fang)
#===============================================================================
class PokeBattle_Move_009 < PokeBattle_Move
    def flinchingMove?; return true; end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        chance = pbAdditionalEffectChance(user, target, @calcType, 10)
        return if chance == 0
        if @battle.pbRandom(100) < chance && target.canNumb?(user, false, self) && canApplyRandomAddedEffects?(user,target,true)
            target.applyNumb(user)
        end 
        if @battle.pbRandom(100) < chance && canApplyRandomAddedEffects?(user,target,true)
            target.pbFlinch
        end
    end

    def getTargetAffectingEffectScore(user, target)
        score = 0
        score += 0.1 * getNumbEffectScore(user, target)
        score += 0.1 * getFlinchingEffectScore(60, user, target, self)
        return score
    end
end

#===============================================================================
# Burns the target.
#===============================================================================
class PokeBattle_Move_00A < PokeBattle_BurnMove
end

#===============================================================================
# Burns the target. May cause the target to flinch. (Fire Fang)
#===============================================================================
class PokeBattle_Move_00B < PokeBattle_Move
    def flinchingMove?; return true; end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        chance = pbAdditionalEffectChance(user, target, @calcType, 10)
        return if chance == 0
        if @battle.pbRandom(100) < chance && target.canBurn?(user, false, self) && canApplyRandomAddedEffects?(user,target,true)
            target.applyBurn(user)
        end 
        if @battle.pbRandom(100) < chance && canApplyRandomAddedEffects?(user,target,true)
            target.pbFlinch
        end
    end

    def getTargetAffectingEffectScore(user, target)
        score = 0
        score += 0.1 * getBurnEffectScore(user, target)
        score += 0.1 * getFlinchingEffectScore(60, user, target, self)
        return score
    end
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_00C < PokeBattle_Move
end

#===============================================================================
# Frostbites the target. Accuracy perfect in hail. (Blizzard)
#===============================================================================
class PokeBattle_Move_00D < PokeBattle_FrostbiteMove
    def pbBaseAccuracy(user, target)
        return 0 if @battle.icy?
        return super
    end
end

#===============================================================================
# Frostbites the target. May cause the target to flinch. (Ice Fang)
#===============================================================================
class PokeBattle_Move_00E < PokeBattle_Move
    def flinchingMove?; return true; end

    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        chance = pbAdditionalEffectChance(user, target, @calcType, 10)
        return if chance == 0
        if @battle.pbRandom(100) < chance && target.canFrostbite?(user, false, self) && canApplyRandomAddedEffects?(user,target,true)
            target.applyFrostbite(user)
        end 
        if @battle.pbRandom(100) < chance && canApplyRandomAddedEffects?(user,target,true)
            target.pbFlinch
        end
    end

    def getTargetAffectingEffectScore(user, target)
        score = 0
        score += 0.1 * getFrostbiteEffectScore(user, target)
        score += 0.1 * getFlinchingEffectScore(60, user, target, self)
        return score
    end
end

#===============================================================================
# Causes the target to flinch.
#===============================================================================
class PokeBattle_Move_00F < PokeBattle_FlinchMove
end

#===============================================================================
# Causes the target to flinch. (Dragon Rush, Steamroller, Stomp)
#===============================================================================
class PokeBattle_Move_010 < PokeBattle_FlinchMove
end

#===============================================================================
# Causes the target to flinch. Fails if the user is not asleep. (Snore)
#===============================================================================
class PokeBattle_Move_011 < PokeBattle_FlinchMove
    def usableWhenAsleep?; return true; end

    def pbMoveFailed?(user, _targets, show_message)
        unless user.asleep?
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} isn't asleep!")) if show_message
            return true
        end
        return false
    end
end

#===============================================================================
# Causes the target to flinch. Fails if this isn't the user's first turn.
# (Fake Out)
#===============================================================================
class PokeBattle_Move_012 < PokeBattle_FlinchMove
    def pbMoveFailed?(user, _targets, show_message)
        unless user.firstTurn?
            @battle.pbDisplay(_INTL("But it failed, since it isn't #{user.pbThis(true)}'s first turn!")) if show_message
            return true
        end
        return false
    end

    def getTargetAffectingEffectScore(user, target)
        score = getFlinchingEffectScore(150, user, target, self)
        return score
    end
end

#===============================================================================
# Deals double damage on the first turn out. (Play Bite)
#===============================================================================
class PokeBattle_Move_013 < PokeBattle_FlinchMove
    def pbBaseDamage(baseDmg, user, target)
        baseDmg *= 2 if user.firstTurn?
        return baseDmg
    end
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_014 < PokeBattle_Move
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_015 < PokeBattle_Move
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_016 < PokeBattle_Move
end

#===============================================================================
# Burns, frostbites, or numbs the target. (Tri Attack)
#===============================================================================
class PokeBattle_Move_017 < PokeBattle_Move
    def pbAdditionalEffect(user, target)
        return if target.damageState.substitute
        case @battle.pbRandom(3)
        when 0 then target.applyBurn(user)      if target.canBurn?(user, false, self)
        when 1 then target.applyFrostbite(user) if target.canFrostbite?(user, false, self)
        when 2 then target.applyNumb(user)      if target.canNumb?(user, false, self)
        end
    end

    def getTargetAffectingEffectScore(user, target)
        burnScore = getBurnEffectScore(user, target)
        frostBiteScore = getFrostbiteEffectScore(user, target)
        numbScore = getNumbEffectScore(user, target)
        return (burnScore + frostBiteScore + numbScore) / 3
    end
end

#===============================================================================
# Cures user of any status condition. (Refresh)
#===============================================================================
class PokeBattle_Move_018 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.pbHasAnyStatus?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} has no status condition!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.pbCureStatus
    end

    def getEffectScore(_user, _target)
        return 75
    end
end

#===============================================================================
# Cures all party Pokémon of permanent status problems. (Aromatherapy, Heal Bell)
#===============================================================================
# NOTE: In Gen 5, this move should have a target of UserSide, while in Gen 6+ it
#       should have a target of UserAndAllies. This is because, in Gen 5, this
#       move shouldn't call def pbSuccessCheckAgainstTarget for each Pokémon
#       currently in battle that will be affected by this move (i.e. allies
#       aren't protected by their substitute/ability/etc., but they are in Gen
#       6+). We achieve this by not targeting any battlers in Gen 5, since
#       pbSuccessCheckAgainstTarget is only called for targeted battlers.
class PokeBattle_Move_019 < PokeBattle_Move
    def worksWithNoTargets?; return true; end

    def pbMoveFailed?(user, _targets, show_message)
        @battle.pbParty(user.index).each do |pkmn|
            return false if validPokemon(pkmn)
        end
        @battle.pbDisplay(_INTL("But it failed, since there are no status conditions in the party!")) if show_message
        return true
    end

    def validPokemon(pkmn)
        return pkmn&.able? && pkmn.status != :NONE
    end

    def pbEffectGeneral(user)
        # Cure all Pokémon in the user's and partner trainer's party.
        # NOTE: This intentionally affects the partner trainer's inactive Pokémon
        #       too.
        @battle.pbParty(user.index).each_with_index do |pkmn, i|
            battler = @battle.pbFindBattler(i, user)
            if battler
                healStatus(battler)
            else
                healStatus(pkmn)
            end
        end
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        super
        if @id == :AROMATHERAPY
            @battle.pbDisplay(_INTL("A soothing aroma wafted through the area!"))
        elsif @id == :HEALBELL
            @battle.pbDisplay(_INTL("A bell chimed!"))
        end
    end

    def getEffectScore(user, _target)
        score = 0
        @battle.pbParty(user.index).each do |pkmn|
            score += 40 if validPokemon(pkmn)
        end
        return score
    end
end

#===============================================================================
# Safeguards the user's side from being inflicted with status problems.
# (Safeguard)
#===============================================================================
class PokeBattle_Move_01A < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.pbOwnSide.effectActive?(:Safeguard)
            @battle.pbDisplay(_INTL("But it failed, since a Safeguard is already present!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.pbOwnSide.applyEffect(:Safeguard, 10)
    end

    def getEffectScore(user, _target)
        score = 20
        @battle.eachSameSideBattler(user.index) do |b|
            score += 30 if b.hasSpotsForStatus?
        end
        return score
    end
end

#===============================================================================
# User passes its first status problem to the target. (Psycho Shift)
#===============================================================================
class PokeBattle_Move_01B < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.pbHasAnyStatus?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} doesn't have any status conditions!"))
            end
            return true
        end
        return false
    end

    def statusBeingMoved(user)
        return user.getStatuses[0]
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        return !target.pbCanInflictStatus?(statusBeingMoved(user), user, show_message, self)
    end

    def pbEffectAgainstTarget(user, target)
        target.pbInflictStatus(statusBeingMoved(user), 0, nil, user)
        user.pbCureStatus(true, statusBeingMoved(user))
    end

    def getEffectScore(user, target)
        status = statusBeingMoved(user)
        score = 0
        score += getStatusSettingEffectScore(status, user, target, ignoreCheck: true)
        score += getStatusSettingEffectScore(status, target, user, ignoreCheck: true)
        return score
    end
end

#===============================================================================
# Increases the user's Attack by 2 step.
#===============================================================================
class PokeBattle_Move_01C < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2]
    end
end

#===============================================================================
# Increases the user's Defense by 2 steps.
#===============================================================================
class PokeBattle_Move_01D < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:DEFENSE, 2]
    end
end

#===============================================================================
# Increases the user's Defense and Sp. Def by 2 steps. User curls up. (Defense Curl)
#===============================================================================
class PokeBattle_Move_01E < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = DEFENDING_STATS_2
    end

    def pbEffectGeneral(user)
        user.applyEffect(:DefenseCurl)
        super
    end
end

#===============================================================================
# Increases the user's Speed by 2 steps.
#===============================================================================
class PokeBattle_Move_01F < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPEED, 2]
    end
end

#===============================================================================
# Increases the user's Special Attack by 2 step.
#===============================================================================
class PokeBattle_Move_020 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2]
    end
end

#===============================================================================
# Increases the user's defensive stats by 2 steps each.
# Charges up user's next attack if it is Electric-type. (Charge)
#===============================================================================
class PokeBattle_Move_021 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = DEFENDING_STATS_2
    end

    def pbEffectGeneral(user)
        user.applyEffect(:Charge)
        super
    end

    def getEffectScore(user, target)
        foundMove = false
        user.eachMove do |m|
            next if m.type != :ELECTRIC || !m.damagingMove?
            foundMove = true
            break
        end
        score = super
        if foundMove
            score += 20
        else
            score -= 20
        end
        return score
    end
end

#===============================================================================
# Protects the user's side from critical hits and random added effects.
# (Diamond Field)
#===============================================================================
class PokeBattle_Move_022 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.pbOwnSide.effectActive?(:DiamondField)
            @battle.pbDisplay(_INTL("But it failed, since a Diamond Field is already present!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.pbOwnSide.applyEffect(:DiamondField, 10)
    end

    def getEffectScore(user, _target)
        score = 20
        @battle.eachSameSideBattler(user.index) do |b|
            score += 30 if b.aboveHalfHealth?
        end
        return score
    end
end

#===============================================================================
# Increases the user's critical hit rate. (Focus Energy)
#===============================================================================
class PokeBattle_Move_023 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.effectAtMax?(:FocusEnergy)
            @battle.pbDisplay(_INTL("But it failed, since it cannot get any more pumped!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.incrementEffect(:FocusEnergy, 2)
    end

    def getEffectScore(user, _target)
        return getCriticalRateBuffEffectScore(user, 2)
    end
end

#===============================================================================
# Increases the user's Attack and Defense by 1 step each. (Bulk Up)
#===============================================================================
class PokeBattle_Move_024 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2, :DEFENSE, 2]
    end
end

#===============================================================================
# Increases the user's Attack, Defense and accuracy by 2 steps each. (Coil)
#===============================================================================
class PokeBattle_Move_025 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2, :DEFENSE, 2, :ACCURACY, 2]
    end
end

#===============================================================================
# Increases the user's Attack by 2 steps, and Speed by 1. (Dragon Dance)
#===============================================================================
class PokeBattle_Move_026 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2, :SPEED, 1]
    end
end

#===============================================================================
# Increases the user's Attack and Special Attack by 2 steps each. (Work Up)
#===============================================================================
class PokeBattle_Move_027 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = ATTACKING_STATS_2
    end
end

#===============================================================================
# Increases the user's Attack and Sp. Attack by 2 step eachs.
# In sunny weather, increases are 4 steps each instead. (Growth)
#===============================================================================
class PokeBattle_Move_028 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = ATTACKING_STATS_2
    end

    def pbOnStartUse(_user, _targets)
        if @battle.sunny?
            @statUp = [:ATTACK, 4, :SPECIAL_ATTACK, 4]
        else
            @statUp = ATTACKING_STATS_2
        end
    end

    def shouldHighlight?(_user, _target)
        return @battle.sunny?
    end
end

#===============================================================================
# Increases the user's Attack and accuracy by 3 steps each. (Hone Claws)
#===============================================================================
class PokeBattle_Move_029 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 3, :ACCURACY, 3]
    end
end

#===============================================================================
# Increases the user's Defense and Special Defense by 2 steps each.
# (Cosmic Power, Defend Order)
#===============================================================================
class PokeBattle_Move_02A < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = DEFENDING_STATS_2
    end
end

#===============================================================================
# Raises the user's Sp. Attack and Sp. Defense by 2 steps each, and Speed by 1.
# (Quiver Dance)
#===============================================================================
class PokeBattle_Move_02B < PokeBattle_MultiStatUpMove
    def aiAutoKnows?(pokemon); return true; end

    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2, :SPEED, 1]
    end
end

#===============================================================================
# Raises the user's Sp. Attack and Sp. Defense by 2 step eachs. (Calm Mind)
#===============================================================================
class PokeBattle_Move_02C < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2]
    end
end

#===============================================================================
# Raises the user's Attack, Defense, Speed, Special Attack and Special Defense
# by 1 step each. (Ancient Power, Ominous Wind, Silver Wind)
#===============================================================================
class PokeBattle_Move_02D < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = ALL_STATS_1
    end
end

#===============================================================================
# Increases the user's Attack by 4 steps. (Swords Dance)
#===============================================================================
class PokeBattle_Move_02E < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 4]
    end
end

#===============================================================================
# Increases the user's Defense by 4 steps. (Barrier, Iron Defense)
#===============================================================================
class PokeBattle_Move_02F < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:DEFENSE, 4]
    end
end

#===============================================================================
# Increases the user's Speed by 4 steps. (Agility, Rock Polish)
#===============================================================================
class PokeBattle_Move_030 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPEED, 4]
    end

    def getEffectScore(user, target)
        score = super
        score += 40 if user.hasActiveAbilityAI?(:STAMPEDE)
        return score
    end
end

#===============================================================================
# Increases the user's Speed by 4 steps. Lowers user's weight by 100kg.
# (Autotomize)
#===============================================================================
class PokeBattle_Move_031 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPEED, 4]
    end

    def pbEffectGeneral(user)
        if user.pbWeight + user.effects[:WeightChange] > 1
            user.effects[:WeightChange] -= 100
            @battle.pbDisplay(_INTL("{1} became lighter!", user.pbThis))
        end
        super
    end
end

#===============================================================================
# Increases the user's Special Attack by 4 steps. (Dream Dance)
#===============================================================================
class PokeBattle_Move_032 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 4]
    end
end

#===============================================================================
# Increases the user's Special Defense by 4 steps. (Amnesia)
#===============================================================================
class PokeBattle_Move_033 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_DEFENSE, 4]
    end
end

#===============================================================================
# Currently unused.
#===============================================================================
class PokeBattle_Move_034 < PokeBattle_Move
end

#===============================================================================
# Decreases the user's Defense and Special Defense by 2 steps each.
# Increases the user's Attack, Speed and Special Attack by 3 steps each.
# (Shell Smash)
#===============================================================================
class PokeBattle_Move_035 < PokeBattle_StatUpDownMove
    def initialize(battle, move)
        super
        @statUp   = [:ATTACK, 3, :SPECIAL_ATTACK, 3, :SPEED, 3]
        @statDown = DEFENDING_STATS_2
    end
end

#===============================================================================
# Increases the user's Attack and Speed by 2 steps each. (Shift Gear)
#===============================================================================
class PokeBattle_Move_036 < PokeBattle_MultiStatUpMove
    def aiAutoKnows?(pokemon); return true; end

    def initialize(battle, move)
        super
        @statUp = [:SPEED, 2, :ATTACK, 2]
    end
end

#===============================================================================
# (Currently unused)
#===============================================================================
class PokeBattle_Move_037 < PokeBattle_Move
end

#===============================================================================
# Increases the user's Defense by 5 steps. (Cotton Guard)
#===============================================================================
class PokeBattle_Move_038 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:DEFENSE, 5]
    end
end

#===============================================================================
# Increases the user's Special Attack by 5 steps. (Tail Glow)
#===============================================================================
class PokeBattle_Move_039 < PokeBattle_StatUpMove
    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 5]
    end
end

#===============================================================================
# Reduces the user's HP by half of max, and sets its Attack to maximum.
# (Belly Drum)
#===============================================================================
class PokeBattle_Move_03A < PokeBattle_Move
    def statUp; return [:ATTACK,12]; end

    def pbMoveFailed?(user, _targets, show_message)
        hpLoss = [user.totalhp / 2, 1].max
        if user.hp <= hpLoss
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s HP is too low!")) if show_message
            return true
        end
        return true unless user.pbCanRaiseStatStep?(:ATTACK, user, self, show_message)
        return false
    end

    def pbEffectGeneral(user)
        hpLoss = [user.totalhp / 2, 1].max
        user.pbReduceHP(hpLoss, false)
        user.pbMaximizeStatStep(:ATTACK, user, self)
        user.pbItemHPHealCheck
    end

    def getEffectScore(user, target)
        stepsUp = 6 - user.steps[:ATTACK]
        score = getMultiStatUpEffectScore([:ATTACK, stepsUp], user, target)
        score -= 50
        return score
    end
end

#===============================================================================
# Decreases the user's Attack and Defense by 2 steps each. (Superpower)
#===============================================================================
class PokeBattle_Move_03B < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 2, :DEFENSE, 2]
    end
end

#===============================================================================
# Decreases the user's Defense and Special Defense by 2 steps each.
# (Close Combat, Dragon Ascent)
#===============================================================================
class PokeBattle_Move_03C < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = DEFENDING_STATS_2
    end
end

#===============================================================================
# Decreases the user's Defense, Special Defense and Speed by 2 steps each.
# (V-create)
#===============================================================================
class PokeBattle_Move_03D < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 2, :DEFENSE, 2, :SPECIAL_DEFENSE, 2]
    end
end

#===============================================================================
# Decreases the user's Speed by 2 steps. (Hammer Arm, Ice Hammer)
#===============================================================================
class PokeBattle_Move_03E < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 2]
    end
end

#===============================================================================
# Decreases the user's Special Attack by 4 steps.
#===============================================================================
class PokeBattle_Move_03F < PokeBattle_StatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 4]
    end
end

#===============================================================================
# Currently unused.
#===============================================================================
class PokeBattle_Move_040 < PokeBattle_Move
end

#===============================================================================
# Currently unused.
#===============================================================================
class PokeBattle_Move_041 < PokeBattle_Move
end

#===============================================================================
# Decreases the target's Attack by 2 steps.
#===============================================================================
class PokeBattle_Move_042 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 2]
    end
end

#===============================================================================
# Decreases the target's Defense by 2 steps.
#===============================================================================
class PokeBattle_Move_043 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 2]
    end
end

#===============================================================================
# Decreases the target's Speed by 2 steps.
#===============================================================================
class PokeBattle_Move_044 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 2]
    end
end

#===============================================================================
# Decreases the target's Special Attack by 2 steps.
#===============================================================================
class PokeBattle_Move_045 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 2]
    end
end

#===============================================================================
# Decreases the target's Special Defense by 2 steps.
#===============================================================================
class PokeBattle_Move_046 < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_DEFENSE, 2]
    end
end

#===============================================================================
# Lowers the target's Attack, Defense, Speed, Special Attack and Special Defense
# by 1 step each. (Ruin)
#===============================================================================
class PokeBattle_Move_047 < PokeBattle_TargetMultiStatDownMove
    def initialize(battle, move)
        super
        @statDown = ALL_STATS_1
    end
end

#===============================================================================
# Increases the user's Attack and Special Attack by 1 steps each.
#===============================================================================
class PokeBattle_Move_048 < PokeBattle_MultiStatUpMove
    def initialize(battle, move)
        super
        @statUp = ATTACKING_STATS_2
    end
end

#===============================================================================
# Ends all barriers and entry hazards for the target's side. (Defog)
# And all entry hazard's for the user's side.
#===============================================================================
class PokeBattle_Move_049 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @miscEffects = %i[Mist Safeguard]
    end

    def eachDefoggable(side, isOurSide)
        side.eachEffect(true) do |effect, _value, data|
            if !isOurSide && (data.is_screen? || @miscEffects.include?(effect))
                yield effect, data
            elsif data.is_hazard?
                yield effect, data
            end
        end
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        targetSide = target.pbOwnSide
        ourSide = user.pbOwnSide
        eachDefoggable(targetSide, false) do |_effect, _data|
            return false
        end
        eachDefoggable(ourSide, true) do |_effect, _data|
            return false
        end
    end

    def blowAwayEffect(user, side, effect, data)
        side.disableEffect(effect)
        if data.is_hazard?
            hazardName = data.real_name
            @battle.pbDisplay(_INTL("{1} blew away {2}!", user.pbThis, hazardName)) unless data.has_expire_proc?
        end
    end

    def pbEffectAgainstTarget(user, target)
        targetSide = target.pbOwnSide
        ourSide = user.pbOwnSide
        eachDefoggable(targetSide, false) do |effect, data|
            blowAwayEffect(user, targetSide, effect, data)
        end
        eachDefoggable(ourSide, true) do |effect, data|
            blowAwayEffect(user, ourSide, effect, data)
        end
    end

    def getEffectScore(user, target)
        score = 0
        # Dislike removing hazards that affect the enemy
        score -= hazardWeightOnSide(target.pbOwnSide)
        # Like removing hazards that affect us
        score += hazardWeightOnSide(target.pbOpposingSide)
        target.pbOwnSide.eachEffect(true) do |effect, _value, data|
            score += 25 if data.is_screen? || @miscEffects.include?(effect)
        end
        return score
    end
end

#===============================================================================
# Decreases the target's Attack and Defense by 2 steps each. (Tickle)
#===============================================================================
class PokeBattle_Move_04A < PokeBattle_TargetMultiStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 2, :DEFENSE, 2]
    end
end

#===============================================================================
# Decreases the target's Attack by 4 steps.
#===============================================================================
class PokeBattle_Move_04B < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:ATTACK, 4]
    end
end

#===============================================================================
# Decreases the target's Defense by 4 steps.
#===============================================================================
class PokeBattle_Move_04C < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 4]
    end
end

#===============================================================================
# Decreases the target's Speed by 4 steps.
#===============================================================================
class PokeBattle_Move_04D < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPEED, 4]
    end
end

#===============================================================================
# (Not currently used.)
#===============================================================================
class PokeBattle_Move_04E < PokeBattle_TargetStatDownMove
end

#===============================================================================
# Decreases the target's Special Defense by 4 steps.
#===============================================================================
class PokeBattle_Move_04F < PokeBattle_TargetStatDownMove
    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_DEFENSE, 4]
    end
end

#===============================================================================
# Resets all target's stat steps to 0. (Clear Smog)
#===============================================================================
class PokeBattle_Move_050 < PokeBattle_Move
    def pbEffectAgainstTarget(_user, target)
        if target.damageState.calcDamage > 0 && !target.damageState.substitute && target.hasAlteredStatSteps?
            target.pbResetStatSteps
            @battle.pbDisplay(_INTL("{1}'s stat changes were removed!", target.pbThis))
        end
    end

    def getTargetAffectingEffectScore(_user, target)
        score = 0
        if !target.substituted? && target.hasAlteredStatSteps?
            GameData::Stat.each_battle do |s|
                score += target.steps[s.id] * 10
            end
        end
        return score
    end
end

#===============================================================================
# Resets all stat steps for all battlers to 0. (Haze)
#===============================================================================
class PokeBattle_Move_051 < PokeBattle_Move
    def pbMoveFailed?(_user, _targets, show_message)
        failed = true
        @battle.eachBattler do |b|
            failed = false if b.hasAlteredStatSteps?
            break unless failed
        end
        if failed
            @battle.pbDisplay(_INTL("But it failed, since no battlers have any changed stats!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(_user)
        @battle.eachBattler { |b| b.pbResetStatSteps }
        @battle.pbDisplay(_INTL("All stat changes were eliminated!"))
    end

    def getEffectScore(user, _target)
        score = 0
        @battle.eachBattler do |b|
            totalSteps = 0
            GameData::Stat.each_battle { |s| totalSteps += b.steps[s.id] }
            if b.opposes?(user)
                score += totalSteps * 20
            else
                score -= totalSteps * 20
            end
        end
        return score
    end
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_052 < PokeBattle_Move
end

#===============================================================================
# (Not currently used)
#===============================================================================
class PokeBattle_Move_053 < PokeBattle_Move
end

#===============================================================================
# User and target swap all their stat steps. (Heart Swap)
#===============================================================================
class PokeBattle_Move_054 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbEffectAgainstTarget(user, target)
        GameData::Stat.each_battle do |s|
            user.steps[s.id], target.steps[s.id] = target.steps[s.id], user.steps[s.id]
        end
        @battle.pbDisplay(_INTL("{1} switched stat changes with the target!", user.pbThis))
    end

    def getEffectScore(user, target)
        score = 0
        userSteps = 0
        targetSteps = 0
        GameData::Stat.each_battle do |s|
            userSteps += user.steps[s.id]
            targetSteps += target.steps[s.id]
        end
        score += (targetSteps - userSteps) * 10
        return score
    end
end

#===============================================================================
# User copies the target's stat steps. (Psych Up)
#===============================================================================
class PokeBattle_Move_055 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbEffectAgainstTarget(user, target)
        GameData::Stat.each_battle { |s| user.steps[s.id] = target.steps[s.id] }
        # Copy critical hit chance raising effects
        target.eachEffect do |effect, value, data|
            user.effects[effect] = value if data.critical_rate_buff?
        end
        @battle.pbDisplay(_INTL("{1} copied {2}'s stat changes!", user.pbThis, target.pbThis(true)))
    end

    def getEffectScore(user, target)
        score = 0
        GameData::Stat.each_battle do |s|
            stepdiff = target.steps[s.id] - user.steps[s.id]
            score += stepdiff * 10
        end
        return score
    end
end

#===============================================================================
# Swaps the user's Sp Attack and Sp Def stats. (Energy Trick)
#===============================================================================
class PokeBattle_Move_056 < PokeBattle_Move
    def pbEffectGeneral(user)
        baseSpAtk = user.base_special_attack
        baseSpDef = user.base_special_defense
        user.effects[:BaseSpecialAttack] = baseSpDef
        user.effects[:BaseSpecialDefense] = baseSpAtk
        user.effects[:EnergyTrick] = !user.effects[:EnergyTrick]
        @battle.pbDisplay(_INTL("{1} switched its base Sp. Atk and Sp. Def!", user.pbThis))
    end

    def getEffectScore(user, _target)
        return 0 if user.effectActive?(:EnergyTrick) # No flip-flopping
        baseSpAtk = user.base_special_attack
        baseSpDef = user.base_special_defense
        return 100 if baseSpDef > baseSpAtk # Prefer a higher Attack
        return 0
    end
end

#===============================================================================
# Swaps the user's Attack and Defense stats. (Power Trick)
#===============================================================================
class PokeBattle_Move_057 < PokeBattle_Move
    def pbEffectGeneral(user)
        baseAttack = user.base_attack
        baseDefense = user.base_defense
        user.effects[:BaseAttack] = baseDefense
        user.effects[:BaseDefense] = baseAttack
        user.effects[:PowerTrick] = !user.effects[:PowerTrick]
        @battle.pbDisplay(_INTL("{1} switched its base Attack and Defense!", user.pbThis))
    end

    def getEffectScore(user, _target)
        return 0 if user.effectActive?(:PowerTrick) # No flip-flopping
        baseAttack = user.base_attack
        baseDefense = user.base_defense
        return 100 if baseDefense > baseAttack # Prefer a higher Attack
        return 0
    end
end

#===============================================================================
# Averages the user's and target's base Attack.
# Averages the user's and target's base Special Attack. (Power Split)
#===============================================================================
class PokeBattle_Move_058 < PokeBattle_Move
    def pbEffectAgainstTarget(user, target)
        newAtk   = ((user.base_attack + target.base_attack) / 2).floor
        newSpAtk = ((user.base_special_attack + target.base_special_attack) / 2).floor
        user.applyEffect(:BaseAttack,newAtk)
        target.applyEffect(:BaseAttack,newAtk)
        user.applyEffect(:BaseSpecialAttack,newSpAtk)
        target.applyEffect(:BaseSpecialAttack,newSpAtk)
        @battle.pbDisplay(_INTL("{1} averaged its base attacking stats with the target!", user.pbThis))
    end

    def getEffectScore(user, target)
        userAttack = user.base_attack
        userSpAtk = user.base_special_attack
        targetAttack = target.base_attack
        targetSpAtk = target.base_special_attack
        if userAttack < targetAttack && userSpAtk < targetSpAtk
            return 120
        elsif userAttack + userSpAtk < targetAttack + targetSpAtk
            return 80
        else
            return 0
        end
    end
end

#===============================================================================
# Averages the user's and target's base Defense.
# Averages the user's and target's base Special Defense. (Guard Split)
#===============================================================================
class PokeBattle_Move_059 < PokeBattle_Move
    def pbEffectAgainstTarget(user, target)
        newDef   = ((user.base_defense + target.base_defense) / 2).floor
        newSpDef = ((user.base_special_defense + target.base_special_defense) / 2).floor
        user.applyEffect(:BaseDefense,newDef)
        target.applyEffect(:BaseDefense,newDef)
        user.applyEffect(:BaseSpecialDefense,newSpDef)
        target.applyEffect(:BaseSpecialDefense,newSpDef)
        @battle.pbDisplay(_INTL("{1} averaged its base defensive stats with the target!", user.pbThis))
    end

    def getEffectScore(user, target)
        userDefense = user.base_defense
        userSpDef = user.base_special_defense
        targetDefense = target.base_defense
        targetSpDef = target.base_special_defense
        if userDefense < targetDefense && userSpDef < targetSpDef
            return 120
        elsif userDefense + userSpDef < targetDefense + targetSpDef
            return 80
        else
            return 0
        end
    end
end

#===============================================================================
# Averages the user's and target's current HP. (Pain Split)
#===============================================================================
class PokeBattle_Move_05A < PokeBattle_Move
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.boss?
            @battle.pbDisplay(_INTL("But it failed, since the target is an avatar!")) if show_message
            return true
        end
        if user.boss?
            @battle.pbDisplay(_INTL("But it failed, since the user is an avatar!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        newHP = (user.hp + target.hp) / 2
        if user.hp > newHP
            user.pbReduceHP(user.hp - newHP, false, false)
        elsif user.hp < newHP
            user.pbRecoverHP(newHP - user.hp, false, true, false)
        end
        if target.hp > newHP
            target.pbReduceHP(target.hp - newHP, false, false)
        elsif target.hp < newHP
            target.pbRecoverHP(newHP - target.hp, false, true, false)
        end
        @battle.pbDisplay(_INTL("The battlers shared their pain!"))
        user.pbItemHPHealCheck
        target.pbItemHPHealCheck
    end

    def getEffectScore(user, target)
        if user.hp >= (user.hp + target.hp) / 2
            return 0
        else
            return 100
        end
    end
end

#===============================================================================
# For 4 rounds, doubles the Speed of all battlers on the user's side. (Tailwind)
#===============================================================================
class PokeBattle_Move_05B < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.pbOwnSide.effectActive?(:Tailwind)
            @battle.pbDisplay(_INTL("But it failed, since there is already a tailwind blowing!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.pbOwnSide.applyEffect(:Tailwind, 4)
    end

    def getEffectScore(user, _target)
        score = 100
        score += 20 if user.firstTurn?
        score += 50 if @battle.pbSideSize(user.index) > 1
        return score
    end
end

#===============================================================================
# This move turns into the last move used by the target, until user switches
# out. (Mimic)
#===============================================================================
class PokeBattle_Move_05C < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            "014", # Chatter
            "0B6", # Metronome
            # Struggle
            "002", # Struggle
            # Moves that affect the moveset
            "05C",   # Mimic
            "05D",   # Sketch
            "069", # Transform
        ]
    end

    def pbMoveFailed?(user, _targets, show_message)
        if user.transformed?
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is transformed!")) if show_message
            return true
        end
        unless user.pbHasMove?(@id)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} doesn't know Mimic!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        lastMoveData = GameData::Move.try_get(target.lastRegularMoveUsed)
        if !lastMoveData
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} hasn't used a move!")) if show_message
            return true
        end
        if user.pbHasMove?(target.lastRegularMoveUsed)
             @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} already knows #{target.pbThis(true)}'s most recent move!")) if show_message
             return true
        end
        if @moveBlacklist.include?(lastMoveData.function_code)
            @battle.pbDisplay(_INTL("But it failed, #{target.pbThis(true)}'s most recent move can't be Mimicked!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        user.eachMoveWithIndex do |m, i|
            next if m.id != @id
            newMove = Pokemon::Move.new(target.lastRegularMoveUsed)
            user.moves[i] = PokeBattle_Move.from_pokemon_move(@battle, newMove)
            @battle.pbDisplay(_INTL("{1} learned {2}!", user.pbThis, newMove.name))
            user.pbCheckFormOnMovesetChange
            break
        end
    end
end

#===============================================================================
# This move permanently turns into the last move used by the target. (Sketch)
#===============================================================================
class PokeBattle_Move_05D < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def initialize(battle, move)
        super
        @moveBlacklist = [
            "014", # Chatter
            "05D", # Sketch (this move)
            # Struggle
            "002", # Struggle
        ]
    end

    def pbMoveFailed?(user, _targets, show_message)
        if user.transformed?
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is transformed!")) if show_message
            return true
        end
        if !user.pbHasMove?(@id)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} doesn't know Sketch!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        lastMoveData = GameData::Move.try_get(target.lastRegularMoveUsed)
        if !lastMoveData
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} hasn't used a move!")) if show_message
            return true
        end
        if user.pbHasMove?(target.lastRegularMoveUsed)
             @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} already knows #{target.pbThis(true)}'s most recent move!")) if show_message
             return true
        end
        if @moveBlacklist.include?(lastMoveData.function_code)
            @battle.pbDisplay(_INTL("But it failed, #{target.pbThis(true)}'s most recent move can't be Sketched!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        user.eachMoveWithIndex do |m, i|
            next if m.id != @id
            newMove = Pokemon::Move.new(target.lastRegularMoveUsed)
            user.pokemon.moves[i] = newMove
            user.moves[i] = PokeBattle_Move.from_pokemon_move(@battle, newMove)
            @battle.pbDisplay(_INTL("{1} learned {2}!", user.pbThis, newMove.name))
            user.pbCheckFormOnMovesetChange
            user.pokemon.first_moves.push(newMove.id)
            break
        end
    end
end

#===============================================================================
# Changes user's type to that of a random user's move, except a type the user
# already has (even partially), OR changes to the user's first move's type.
# (Conversion)
#===============================================================================
class PokeBattle_Move_05E < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.canChangeType?
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} can't have its type changed!"))
            return true
        end
        userTypes = user.pbTypes(true)
        @newTypes = []
        user.eachMoveWithIndex do |m, i|
            break if i > 0
            next if GameData::Type.get(m.type).pseudo_type
            next if userTypes.include?(m.type)
            @newTypes.push(m.type) unless @newTypes.include?(m.type)
        end
        if @newTypes.length == 0
            @battle.pbDisplay(_INTL("But it failed, since there are no valid types for it to choose!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        newType = @newTypes[@battle.pbRandom(@newTypes.length)]
        user.pbChangeTypes(newType)
        typeName = GameData::Type.get(newType).name
        @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", user.pbThis, typeName))
    end
end

#===============================================================================
# Changes user's type to a random one that resists/is immune to the last move
# used by the target. (Conversion 2)
#===============================================================================
class PokeBattle_Move_05F < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbMoveFailed?(user, _targets, show_message)
        unless user.canChangeType?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} can't have its types changed!"))
            end
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        if !target.lastMoveUsed || !target.lastMoveUsedType ||
           GameData::Type.get(target.lastMoveUsedType).pseudo_type
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        @newTypes = []
        GameData::Type.each do |t|
            next if t.pseudo_type || user.pbHasType?(t.id) ||
                    !Effectiveness.resistant_type?(target.lastMoveUsedType, t.id)
            @newTypes.push(t.id)
        end
        if @newTypes.length == 0
            @battle.pbDisplay(_INTL("But it failed!")) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        newType = @newTypes[@battle.pbRandom(@newTypes.length)]
        user.pbChangeTypes(newType)
        typeName = GameData::Type.get(newType).name
        @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", user.pbThis, typeName))
    end
end

#===============================================================================
# Changes user's type depending on the environment. (Camouflage)
#===============================================================================
class PokeBattle_Move_060 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        unless user.canChangeType?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} can't have its types changed!"))
            end
            return true
        end
        camouflageType = getCamouflageType
        unless GameData::Type.exists?(camouflageType)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since the type #{user.pbThis(true)} is supposed to become doesn't exist!"))
            end
            return true
        end
        if user.pbHasOtherType?(camouflageType)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} is already #{GameData::Type.get(camouflageType).real_name}-type!"))
            end
            return true
        end
        return false
    end

    def getCamouflageType
        newType = :NORMAL
        checkedTerrain = false
        case @battle.field.terrain
        when :Electric
            newType = :ELECTRIC
            checkedTerrain = true
        when :Grassy
            newType = :GRASS
            checkedTerrain = true
        when :Fairy
            newType = :FAIRY
            checkedTerrain = true
        when :Psychic
            newType = :PSYCHIC
            checkedTerrain = true
        end
        unless checkedTerrain
            case @battle.environment
            when :Grass, :TallGrass
                newType = :GRASS
            when :MovingWater, :StillWater, :Puddle, :Underwater
                newType = :WATER
            when :Cave
                newType = :ROCK
            when :Rock, :Sand
                newType = :GROUND
            when :Forest, :ForestGrass
                newType = :BUG
            when :Snow, :Ice
                newType = :ICE
            when :Volcano
                newType = :FIRE
            when :Graveyard
                newType = :GHOST
            when :Sky
                newType = :FLYING
            when :Space
                newType = :DRAGON
            when :UltraSpace
                newType = :PSYCHIC
            end
        end
        newType = :NORMAL unless GameData::Type.exists?(newType)
        return newType
    end

    def pbEffectGeneral(user)
        newType = getCamouflageType
        user.pbChangeTypes(newType)
        typeName = GameData::Type.get(newType).name
        @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", user.pbThis, typeName))
    end
end

#===============================================================================
# Target becomes Water type. (Soak)
#===============================================================================
class PokeBattle_Move_061 < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        unless GameData::Type.exists?(:WATER)
            @battle.pbDisplay(_INTL("But it failed, since the Water-type doesn't exist!")) if show_message
            return true
        end
        unless target.canChangeType?
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can't change their type!")) if show_message
            return true
        end
        unless target.pbHasOtherType?(:WATER)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already only Water-type!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.pbChangeTypes(:WATER)
        typeName = GameData::Type.get(:WATER).name
        @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", target.pbThis, typeName))
    end

    def getEffectScore(_user, _target)
        return 80
    end
end

#===============================================================================
# User copes target's types. (Reflect Type)
#===============================================================================
class PokeBattle_Move_062 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbMoveFailed?(user, _targets, show_message)
        unless user.canChangeType?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} can't have its types changed!"))
            end
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        newTypes = target.pbTypes(true)
        if newTypes.length == 0 # Target has no type to copy
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} has no types!")) if show_message
            return true
        end
        if user.pbTypes == target.pbTypes && user.effects[:Type3] == target.effects[:Type3]
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} && #{target.pbThis(true)} share the exact same types!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        user.pbChangeTypes(target)
        @battle.pbDisplay(_INTL("{1}'s type changed to match {2}'s!",
           user.pbThis, target.pbThis(true)))
    end
end

#===============================================================================
# Target's ability becomes Simple. (Simple Beam)
#===============================================================================
class PokeBattle_Move_063 < PokeBattle_Move
    def pbMoveFailed?(_user, _targets, show_message)
        unless GameData::Ability.exists?(:SIMPLE)
            @battle.pbDisplay(_INTL("But it failed, since the ability Simple doesn't exist!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.unstoppableAbility?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s ability can't be supressed!"))
            end
            return true
        end
        if target.hasAbility?(:SIMPLE)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} already has the ability #{getAbilityName(:SIMPLE)}!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        target.replaceAbility(:SIMPLE)
    end

    def getEffectScore(user, target)
        score = getSuppressAbilityEffectScore(user, target)
        score += user.opposes?(target) ? -20 : 20
        return score
    end
end

#===============================================================================
# Target's ability becomes Insomnia. (Worry Seed)
#===============================================================================
class PokeBattle_Move_064 < PokeBattle_Move
    def pbMoveFailed?(_user, _targets, show_message)
        unless GameData::Ability.exists?(:INSOMNIA)
            @battle.pbDisplay(_INTL("But it failed, since the ability Insomnia doesn't exist!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.unstoppableAbility?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s ability can't be supressed!"))
            end
            return true
        end
        if target.hasAbility?(:INSOMNIA)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s ability is already #{getAbilityName(:INSOMNIA)}!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.replaceAbility(:INSOMNIA)
    end

    def getEffectScore(user, target)
        return getSuppressAbilityEffectScore(user, target)
    end
end

#===============================================================================
# User copies target's ability. (Role Play)
#===============================================================================
class PokeBattle_Move_065 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbMoveFailed?(user, _targets, show_message)
        if user.unstoppableAbility?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s ability can't be changed!"))
            end
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        unless target.firstAbility
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} doesn't have an ability!"))
            end
            return true
        end
        if user.firstAbility == target.firstAbility
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since the #{target.pbThis(true)} and #{user.pbThis(true)} have the same ability!"))
            end
            return true
        end
        if user.ungainableAbility?(target.firstAbility) || GameData::Ability::UNCOPYABLE_ABILITIES.include?(target.firstAbility) ||
                target.firstAbility == :WONDERGUARD
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s ability can't be copied!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        replacementMsg = _INTL("{1} copied {2}'s {3}!",
            user.pbThis, target.pbThis(true), getAbilityName(target.firstAbility))
        user.replaceAbility(target.firstAbility, replacementMsg: replacementMsg)
    end

    def getEffectScore(user, target)
        return 0 if target.hasActiveAbilityAI?(DOWNSIDE_ABILITIES)
        return 100 if user.hasActiveAbilityAI?(DOWNSIDE_ABILITIES)
        return 50
    end
end

#===============================================================================
# Target copies user's ability. (Entrainment)
#===============================================================================
class PokeBattle_Move_066 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, _show_message)
        unless user.firstAbility
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} doesn't have an ability!"))
            return true
        end
        if user.ungainableAbility?(user.firstAbility) || GameData::Ability::UNCOPYABLE_ABILITIES.include?(user.firstAbility)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s ability cannot be copied!"))
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.unstoppableAbility?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s ability can't be supressed!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        replacementMsg = _INTL("{1} acquired {2}!", target.pbThis, getAbilityName(user.firstAbility))
        target.replaceAbility(user.firstAbility, replacementMsg: replacementMsg)
    end

    def getEffectScore(user, target)
        score = 60
        if user.hasActiveAbilityAI?(DOWNSIDE_ABILITIES)
            if user.opposes?(target)
                score += 60
            else
                return 0
            end
        end
        return score
    end
end

#===============================================================================
# User and target swap abilities. (Skill Swap)
#===============================================================================
class PokeBattle_Move_067 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbMoveFailed?(user, _targets, _show_message)
        unless user.firstAbility
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)} doesn't have an ability!"))
            return true
        end
        if user.unstoppableAbility?(user.firstAbility)
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s ability cannot be changed!"))
            return true
        end
        if user.ungainableAbility?(user.firstAbility) || user.firstAbility == :WONDERGUARD
            @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s ability cannot be copied!"))
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(user, target, show_message)
        unless target.firstAbility
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} doesn't have an ability!"))
            end
            return true
        end
        if target.unstoppableAbility?(target.firstAbility)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s ability can't be supressed!"))
            end
            return true
        end
        if target.ungainableAbility?(target.firstAbility) || target.firstAbility == :WONDERGUARD
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s ability can't be copied!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        showSplashes = user.opposes?(target)
        oldUserAbil   = user.firstAbility
        oldTargetAbil = target.firstAbility
        replacementMsg = _INTL("{1} swapped Abilities with its target!", user.pbThis)
        target.replaceAbility(oldUserAbil, showSplashes, user, replacementMsg: replacementMsg)
        user.replaceAbility(oldTargetAbil, showSplashes, target, replacementMsg: replacementMsg)
    end

    def getEffectScore(user, target)
        return 0 if target.hasActiveAbilityAI?(DOWNSIDE_ABILITIES)
        score = 60
        score += 100 if user.hasActiveAbilityAI?(DOWNSIDE_ABILITIES)
        return score
    end
end

#===============================================================================
# Target's ability is negated. (Gastro Acid)
#===============================================================================
class PokeBattle_Move_068 < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.unstoppableAbility?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)}'s ability cannot be supressed!"))
            end
            return true
        end
        if target.effectActive?(:GastroAcid)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already affected by Gastro Acid!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.applyEffect(:GastroAcid)
    end

    def getEffectScore(user, target)
        return getSuppressAbilityEffectScore(user, target)
    end
end

#===============================================================================
# User transforms into the target. (Transform)
#===============================================================================
class PokeBattle_Move_069 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if user.transformed?
            @battle.pbDisplay(_INTL("But it failed, since the user is already transformed!")) if show_message
            return true
        end
        return false
    end

    def pbFailsAgainstTarget?(_user, target, show_message)
        if target.transformed?
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is also transformed!")) if show_message
            return true
        end
        if target.illusion?
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is disguised by an Illusion!"))
            end
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(user, target)
        user.pbTransform(target)
    end

    def getEffectScore(_user, _target)
        return 80
    end
end

#===============================================================================
# Inflicts a fixed 20HP damage. (Sonic Boom)
#===============================================================================
class PokeBattle_Move_06A < PokeBattle_FixedDamageMove
    def pbFixedDamage(_user, _target)
        return 20
    end
end

#===============================================================================
# Inflicts a fixed 40HP damage. (Dragon Rage)
#===============================================================================
class PokeBattle_Move_06B < PokeBattle_FixedDamageMove
    def pbFixedDamage(_user, _target)
        return 40
    end
end

#===============================================================================
# Halves the target's current HP. (Nature's Madness, Super Fang)
#===============================================================================
class PokeBattle_Move_06C < PokeBattle_FixedDamageMove
    def pbFixedDamage(_user, target)
        damage = target.hp / 2.0
        damage /= BOSS_HP_BASED_EFFECT_RESISTANCE if target.boss?
        return damage.round
    end
end

#===============================================================================
# Inflicts damage equal to the user's level. (Night Shade, Seismic Toss)
#===============================================================================
class PokeBattle_Move_06D < PokeBattle_FixedDamageMove
    def pbFixedDamage(user, _target)
        return user.level
    end
end

#===============================================================================
# Inflicts damage to bring the target's HP down to equal the user's HP. (Endeavor)
#===============================================================================
class PokeBattle_Move_06E < PokeBattle_FixedDamageMove
    def pbFailsAgainstTarget?(user, target, show_message)
        if user.hp >= target.hp
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s health is greater than #{target.pbThis(true)}'s!"))
            end
            return true
        end
        if target.boss?
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is an Avatar!")) if show_message
            return true
        end
        return false
    end

    def pbNumHits(_user, _targets, _checkingForAI = false); return 1; end

    def pbFixedDamage(user, target)
        return target.hp - user.hp
    end
end

#===============================================================================
# Target becomes Bug type. (Scale Scatter)
#===============================================================================
class PokeBattle_Move_06F < PokeBattle_Move
    def pbFailsAgainstTarget?(_user, target, show_message)
        unless GameData::Type.exists?(:BUG)
            @battle.pbDisplay(_INTL("But it failed, since the Bug-type doesn't exist!")) if show_message
            return true
        end
        unless target.canChangeType?
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} can't change their type!")) if show_message
            return true
        end
        unless target.pbHasOtherType?(:BUG)
            @battle.pbDisplay(_INTL("But it failed, since #{target.pbThis(true)} is already only Bug-type!")) if show_message
            return true
        end
        return false
    end

    def pbEffectAgainstTarget(_user, target)
        target.pbChangeTypes(:BUG)
        typeName = GameData::Type.get(:BUG).name
        @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", target.pbThis, typeName))
    end

    def getEffectScore(_user, _target)
        return 80
    end
end

#===============================================================================
# OHKO. Accuracy increases by difference between levels of user and target.
#===============================================================================
class PokeBattle_Move_070 < PokeBattle_FixedDamageMove
    def pbFailsAgainstTarget?(user, target, show_message)
        if target.level > user.level
            if show_message
                @battle.pbDisplay(_INTL("{1} is unaffected, since its level is greater than {2}'s!", target.pbThis,
    user.pbThis(true)))
            end
            return true
        end
        if target.boss?
            @battle.pbDisplay(_INTL("{1} is unaffected, since it's an Avatar!", target.pbThis)) if show_message
            return true
        end
        unless @battle.moldBreaker
            %i[STURDY DANGERSENSE].each do |ability|
                if target.hasActiveAbility?(ability)
                    if show_message
                        @battle.pbShowAbilitySplash(target, ability)
                        @battle.pbDisplay(_INTL("But it failed to affect {1}!", target.pbThis(true)))
                        @battle.pbHideAbilitySplash(target)
                    end
                    return true
                end
            end
        end
        return false
    end

    def pbAccuracyCheck(user, target)
        return true if user.boss
        acc = @accuracy + user.level - target.level
        return @battle.pbRandom(100) < acc
    end

    def pbFixedDamage(_user, target)
        return target.totalhp
    end

    def pbHitEffectivenessMessages(user, target, numTargets = 1)
        super
        @battle.pbDisplay(_INTL("It's a one-hit KO!")) if target.fainted?
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use a OHKO move.")
        return -1000
    end
end

#===============================================================================
# Counters a physical move used against the user this round, with 2x the power.
# (Counter)
#===============================================================================
class PokeBattle_Move_071 < PokeBattle_FixedDamageMove
    def pbAddTarget(targets, user)
        target = user.getBattlerPointsTo(:CounterTarget)
        return if target.nil? || !user.opposes?(target)
        user.pbAddTarget(targets, user, target, self, false)
    end

    def pbMoveFailed?(_user, targets, show_message)
        if targets.length == 0
            @battle.pbDisplay(_INTL("But there was no target...")) if show_message
            return true
        end
        return false
    end

    def pbMoveFailedAI?(_user, _targets); return false; end

    def pbFixedDamage(user, _target)
        dmg = user.effects[:Counter] * 2
        dmg = 1 if dmg == 0
        return dmg
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Counter.")
        return -1000
    end
end

#===============================================================================
# Counters a specical move used against the user this round, with 2x the power.
# (Mirror Coat)
#===============================================================================
class PokeBattle_Move_072 < PokeBattle_FixedDamageMove
    def pbAddTarget(targets, user)
        target = user.getBattlerPointsTo(:MirrorCoatTarget)
        return if target.nil? || !user.opposes?(target)
        user.pbAddTarget(targets, user, target, self, false)
    end

    def pbMoveFailed?(_user, targets, show_message)
        if targets.length == 0
            @battle.pbDisplay(_INTL("But there was no target...")) if show_message
            return true
        end
        return false
    end

    def pbMoveFailedAI?(_user, _targets); return false; end

    def pbFixedDamage(user, _target)
        dmg = user.effects[:MirrorCoat] * 2
        dmg = 1 if dmg == 0
        return dmg
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Mirror Coat.")
        return -1000
    end
end

#===============================================================================
# Counters the last damaging move used against the user this round, with 1.5x
# the power. (Metal Burst)
#===============================================================================
class PokeBattle_Move_073 < PokeBattle_FixedDamageMove
    def pbAddTarget(targets, user)
        return if user.lastFoeAttacker.length == 0
        lastAttacker = user.lastFoeAttacker.last
        return if lastAttacker < 0 || !user.opposes?(lastAttacker)
        user.pbAddTarget(targets, user, @battle.battlers[lastAttacker], self, false)
    end

    def pbMoveFailed?(_user, targets, show_message)
        if targets.length == 0
            @battle.pbDisplay(_INTL("But there was no target...")) if show_message
            return true
        end
        return false
    end

    def pbMoveFailedAI?(_user, _targets); return false; end

    def pbFixedDamage(user, _target)
        dmg = (user.lastHPLostFromFoe * 1.5).floor
        dmg = 1 if dmg == 0
        return dmg
    end

    def getEffectScore(_user, _target)
        echoln("The AI will never use Metal Burst.")
        return -1000
    end
end

#===============================================================================
# The target's ally loses 1/16 of its max HP. (Flame Burst)
#===============================================================================
class PokeBattle_Move_074 < PokeBattle_Move
    def pbEffectWhenDealingDamage(_user, target)
        hitAlly = []
        target.eachAlly(true) do |b|
            next unless b.takesIndirectDamage?
            hitAlly.push([b.index, b.hp])
            b.pbReduceHP(b.totalhp / 16, false)
        end
        if hitAlly.length == 2
            @battle.pbDisplay(_INTL("The bursting flame hit {1} and {2}!",
               @battle.battlers[hitAlly[0][0]].pbThis(true),
               @battle.battlers[hitAlly[1][0]].pbThis(true)))
        elsif hitAlly.length > 0
            hitAlly.each do |b|
                @battle.pbDisplay(_INTL("The bursting flame hit {1}!",
                   @battle.battlers[b[0]].pbThis(true)))
            end
        end
        switchedAlly = []
        hitAlly.each do |b|
            @battle.battlers[b[0]].pbItemHPHealCheck
            switchedAlly.push(@battle.battlers[b[0]]) if @battle.battlers[b[0]].pbAbilitiesOnDamageTaken(b[1])
        end
        switchedAlly.each { |b| b.pbEffectsOnSwitchIn(true) }
    end

    def getEffectScore(_user, target)
        score = 0
        target.eachAlly(true) do |_b|
            score += 10
        end
        return score
    end
end

#===============================================================================
# Power is doubled if the target is using Dive. Hits some semi-invulnerable
# targets. (Surf)
#===============================================================================
class PokeBattle_Move_075 < PokeBattle_Move
    def hitsDivingTargets?; return true; end

    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.inTwoTurnAttack?("0CB") # Dive
        return baseDmg
    end

    def pbEffectAfterAllHits(user, target)
        if !target.damageState.unaffected && !target.damageState.protected && !target.damageState.missed && user.canGulpMissile?
            user.form = 2
            user.form = 1 if user.aboveHalfHealth?
            @battle.scene.pbChangePokemon(user, user.pokemon)
        end
    end

    def getEffectScore(user, _target)
        return 50 if user.canGulpMissile?
        return 0
    end
end

#===============================================================================
# Power is doubled if the target is using Dig. Hits digging targets. (Earthquake)
#===============================================================================
class PokeBattle_Move_076 < PokeBattle_Move
    def hitsDiggingTargets?; return true; end

    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.inTwoTurnAttack?("OCA") # Dig
        return baseDmg
    end
end

#===============================================================================
# Puts the target to sleep, but only if the user is Darkrai. (Dark Void)
#===============================================================================
class PokeBattle_Move_077 < PokeBattle_SleepMove
    def pbMoveFailed?(user, _targets, show_message)
        unless user.countsAs?(:DARKRAI)
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis)) if show_message
            return true
        end
        return false
    end
end

#===============================================================================
# Swaps form if the user is Meloetta. (Relic Song)
#===============================================================================
class PokeBattle_Move_078 < PokeBattle_Move
    def pbEndOfMoveUsageEffect(user, _targets, numHits, _switchedBattlers)
        return if numHits == 0
        return if user.fainted? || user.transformed?
        return unless user.isSpecies?(:MELOETTA)
        return if user.hasActiveAbility?(:SHEERFORCE)
        newForm = (user.form + 1) % 2
        user.pbChangeForm(newForm, _INTL("{1} transformed!", user.pbThis))
    end
end

#===============================================================================
# Power is doubled if Fusion Flare has already been used this round. (Fusion Bolt)
#===============================================================================
class PokeBattle_Move_079 < PokeBattle_Move
    def pbChangeUsageCounters(user, specialUsage)
        @doublePower = @battle.field.effectActive?(:FusionFlare)
        super
    end

    def pbBaseDamage(baseDamage, _user, _target)
        baseDamage *= 2 if @doublePower
        return baseDamage
    end

    def pbBaseDamageAI(baseDmg, _user, _target)
        return baseDmg
    end

    def pbEffectGeneral(_user)
        @battle.field.applyEffect(:FusionBolt)
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        hitNum = 1 if (targets.length > 0 && targets[0].damageState.critical) || @doublePower # Charged anim
        super
    end
end

#===============================================================================
# Power is doubled if Fusion Bolt has already been used this round. (Fusion Flare)
#===============================================================================
class PokeBattle_Move_07A < PokeBattle_Move
    def pbChangeUsageCounters(user, specialUsage)
        @doublePower = @battle.field.effectActive?(:FusionBolt)
        super
    end

    def pbBaseDamage(baseDamage, _user, _target)
        baseDamage *= 2 if @doublePower
        return baseDamage
    end

    def pbBaseDamageAI(baseDmg, _user, _target)
        return baseDmg
    end

    def pbEffectGeneral(_user)
        @battle.field.applyEffect(:FusionFlare)
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        hitNum = 1 if (targets.length > 0 && targets[0].damageState.critical) || @doublePower # Charged anim
        super
    end
end

#===============================================================================
# Power is doubled if the target is poisoned. (Venoshock)
#===============================================================================
class PokeBattle_Move_07B < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.poisoned?
        return baseDmg
    end
end

#===============================================================================
# Power is doubled if the target is paralyzed. Cures the target of numb.
# (Smelling Salts)
#===============================================================================
class PokeBattle_Move_07C < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.numbed?
        return baseDmg
    end

    def pbEffectAfterAllHits(_user, target)
        return if target.fainted?
        return if target.damageState.unaffected || target.damageState.substitute
        target.pbCureStatus(true, :NUMB)
    end

    def getTargetAffectingEffectScore(_user, target)
        return -30 if target.numbed?
        return 0
    end
end

#===============================================================================
# Power is doubled if the target is asleep. Wakes the target up. (Wake-Up Slap)
#===============================================================================
class PokeBattle_Move_07D < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.asleep?
        return baseDmg
    end

    def pbEffectAfterAllHits(_user, target)
        return if target.fainted?
        return if target.damageState.unaffected || target.damageState.substitute
        target.pbCureStatus(true, :SLEEP)
    end

    def getTargetAffectingEffectScore(_user, target)
        return -60 if target.asleep?
        return 0
    end
end

#===============================================================================
# Power is doubled if the user is burned, poisoned or paralyzed. (Facade)
# Burn's halving of Attack is negated (new mechanics).
#===============================================================================
class PokeBattle_Move_07E < PokeBattle_Move
    def damageReducedByBurn?; return false; end

    def pbBaseDamage(baseDmg, user, _target)
        baseDmg *= 2 if user.pbHasAnyStatus?
        return baseDmg
    end
end

#===============================================================================
# Power is doubled if the target has a status problem. (Hex, Cruelty)
#===============================================================================
class PokeBattle_Move_07F < PokeBattle_Move
    def pbBaseDamage(baseDmg, _user, target)
        baseDmg *= 2 if target.pbHasAnyStatus?
        return baseDmg
    end
end