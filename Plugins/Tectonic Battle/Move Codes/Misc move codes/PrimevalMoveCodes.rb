module EmpoweredMove
    def pbMoveFailed?(_user, _targets, _show_message); return false; end
    def pbFailsAgainstTarget?(_user, _target, _show_message); return false; end

    # There must be 2 turns without using a primeval attack to then be able to use it again
    def turnsBetweenUses(); return 2; end

    def transformType(user, type)
        user.pbChangeTypes(type)
        typeName = GameData::Type.get(type).name
        @battle.pbAnimation(:CONVERSION, user, [user])
        if user.boss?
            user.pokemon.bossType = type
            @battle.scene.pbChangePokemon(user.index, user.pokemon)
        end
        @battle.pbDisplay(_INTL("{1} transformed into the {2} type!", user.pbThis, typeName))
    end

    def summonAvatar(user,species,summonMessage = nil)
        if @battle.autoTesting
            echoln("Skipping an Avatar summon")
            return
        end
        if @battle.pbSideSize(user.index) < 3
            summonMessage ||= _INTL("#{user.pbThis} summons another Avatar!")
            @battle.pbDisplay(summonMessage)
            @battle.summonAvatarBattler(species, user.level, user.index % 2)
        end
    end
end

# Empowered Sunshine
class PokeBattle_Move_601 < PokeBattle_Move_0FF
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.pbRaiseMultipleStatSteps(ATTACKING_STATS_1, user, move: self)
        transformType(user, :FIRE)
    end
end

# Empowered Rain
class PokeBattle_Move_602 < PokeBattle_Move_100
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.pbAnimation(:AQUARING, user, [user])
        user.applyEffect(:AquaRing)
        transformType(user, :WATER)
    end
end

# Empowered Leech Seed
class PokeBattle_Move_603 < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.eachOtherSideBattler(user) do |b|
            b.applyLeeched(user) if b.canLeech?(user, true, self)
        end
        transformType(user, :GRASS)
    end
end

# Empowered Lightning Dance
class PokeBattle_Move_604 < PokeBattle_MultiStatUpMove
    include EmpoweredMove

    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2, :SPEED, 2]
    end

    def pbEffectGeneral(user)
        super
        transformType(user, :ELECTRIC)
    end
end

# Empowered Hail
class PokeBattle_Move_605 < PokeBattle_Move_102
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.eachOtherSideBattler(user) do |b|
            b.tryLowerStat(:SPEED, user, increment: 2, move: self)
        end
        transformType(user, :ICE)
    end
end

# Empowered Bulk Up
class PokeBattle_Move_606 < PokeBattle_Move_024
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.pbDisplay(_INTL("{1} gained a massive amount of mass!", user.pbThis))
        user.incrementEffect(:WeightChange, 1000)
        transformType(user, :FIGHTING)
    end
end

# Empowered Spikes
class PokeBattle_Move_607 < PokeBattle_Move_103
    include EmpoweredMove

    def pbEffectGeneral(user)
        # Apply up to the maximum number of layers
        increment = GameData::BattleEffect.get(:Spikes).maximum - user.pbOpposingSide.countEffect(:Spikes)
        user.pbOpposingSide.incrementEffect(:Spikes, increment) if increment > 0
        transformType(user, :GROUND)
    end
end

# Empowered Tailwind
class PokeBattle_Move_608 < PokeBattle_Move_05B
    include EmpoweredMove

    def pbEffectGeneral(user)
        user.pbOwnSide.applyEffect(:Tailwind, 4)
        @battle.eachSameSideBattler(user) do |b|
            b.applyEffect(:ExtraTurns, 1)
        end
        transformType(user, :FLYING)
    end
end

# Empowered Calm Mind
class PokeBattle_Move_609 < PokeBattle_Move_02C
    include EmpoweredMove

    def pbEffectGeneral(user)
        user.pbMaximizeStatStep(:ACCURACY, user, self)
        super
        transformType(user, :PSYCHIC)
    end
end

# Empowered String Shot
class PokeBattle_Move_60A < PokeBattle_TargetMultiStatDownMove
    include EmpoweredMove

    def initialize(battle, move)
        super
        @statDown = [:SPEED, 2, :ATTACK, 2, :SPECIAL_ATTACK, 2]
    end

    def pbEffectGeneral(user)
        transformType(user, :BUG)
    end
end

# Empowered Sandstorm
class PokeBattle_Move_60B < PokeBattle_Move_101
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.pbRaiseMultipleStatSteps(DEFENDING_STATS_1, user, move: self)
        transformType(user, :ROCK)
    end
end

# Empowered Cursed Oath
class PokeBattle_Move_60C < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.eachOtherSideBattler(user) do |b|
            b.applyEffect(:Curse)
        end
        transformType(user, :GHOST)
    end
end

# Empowered Dragon Dance
class PokeBattle_Move_60D < PokeBattle_MultiStatUpMove
    include EmpoweredMove

    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2, :SPEED, 2]
    end

    def pbEffectGeneral(user)
        super
        transformType(user, :DRAGON)
    end
end

# Empowered Torment
class PokeBattle_Move_60E < PokeBattle_Move_0B7
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        transformType(user, :DARK)
    end

    def pbEffectAgainstTarget(user, target)
        target.applyEffect(:Torment)
        target.pbLowerMultipleStatSteps(ATTACKING_STATS_1, user, move: self)
    end
end

# Empowered Laser Focus
class PokeBattle_Move_60F < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        user.applyEffect(:EmpoweredLaserFocus)
        transformType(user, :STEEL)
    end
end

# Empowered Puzzle Room
class PokeBattle_Move_610 < PokeBattle_Move_51A
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.pbRaiseMultipleStatSteps(ATTACKING_STATS_1, user, move: self)
        transformType(user, :FAIRY)
    end
end

# Empowered Poison Gas
class PokeBattle_Move_611 < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.eachOtherSideBattler(user) do |b|
            next unless b.canPoison?(user, true, self)
            b.applyPoison(user)
        end
        transformType(user, :POISON)
    end
end

# Empowered Endure
class PokeBattle_Move_612 < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.applyEffect(:EmpoweredEndure, 3)
    end
end

# Empowered Ignite
class PokeBattle_Move_613 < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.eachOtherSideBattler(user) do |b|
            b.applyBurn(user) if b.canBurn?(user, true, self)
        end
        transformType(user, :FIRE)
    end
end

# Empowered Flow State
class PokeBattle_Move_614 < PokeBattle_MultiStatUpMove
    include EmpoweredMove

    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 1, :SPECIAL_DEFENSE, 1]
    end

    def pbEffectGeneral(user)
        super

        user.applyEffect(:EmpoweredFlowState)

        transformType(user, :WATER)
    end
end

# # Empowered Aromatherapy
# class PokeBattle_Move_615 < PokeBattle_Move_019
#     include EmpoweredMove

#     def pbEffectGeneral(user)
#         # Double supers here is intentional
#         super
#         super
#         user.pbRaiseMultipleStatSteps([:ATTACK, 1, :SPECIAL_ATTACK, 1], user, move: self)
#         transformType(user, :GRASS)
#     end
# end

# Empowered Ingrain
class PokeBattle_Move_615 < PokeBattle_Move
    include EmpoweredMove

    def pbMoveFailed?(user, _targets, show_message)
        if user.effectActive?(:EmpoweredIngrain)
            if show_message
                @battle.pbDisplay(_INTL("But it failed, since #{user.pbThis(true)}'s roots are already planted!"))
            end
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        user.applyEffect(:EmpoweredIngrain,4)
        transformType(user, :GRASS)
    end

    def getEffectScore(user, _target)
        score = 50
        score += 30 if @battle.pbIsTrapped?(user.index)
        score += 20 if user.firstTurn?
        score += 20 if user.aboveHalfHealth?
        score *= 2
        return score
    end
end

# Empowered Numb
class PokeBattle_Move_616 < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.eachOtherSideBattler(user) do |b|
            b.applyNumb(user) if b.canNumb?(user, true, self)
        end
        transformType(user, :ELECTRIC)
    end
end

# Empowered Eclipse
class PokeBattle_Move_617 < PokeBattle_Move_09D
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.pbRaiseMultipleStatSteps([:ATTACK, 1, :SPECIAL_ATTACK, 1], user, move: self)
        transformType(user, :PSYCHIC)
    end
end

# Empowered Moonglow
class PokeBattle_Move_618 < PokeBattle_Move_09E
    include EmpoweredMove

    def pbEffectGeneral(user)
        super

        @battle.eachSameSideBattler(user) do |b|
            b.pbRaiseMultipleStatSteps(DEFENDING_STATS_1, user, move: self)
        end

        transformType(user, :FAIRY)
    end
end

# Empowered Heal Order
class PokeBattle_Move_619 < PokeBattle_HalfHealingMove
    include EmpoweredMove

    def healingMove?; return true; end

    def pbEffectGeneral(user)
        super

        summonAvatar(user, :COMBEE, _INTL("{1} summons a helper!", user.pbThis))

        transformType(user, :BUG)
    end
end

# Empowered Grey Mist
class PokeBattle_Move_61A < PokeBattle_Move_587
    include EmpoweredMove

    def pbEffectGeneral(user)
        super

        itemName = GameData::Item.get(:BLACKSLUDGE).real_name
        @battle.pbDisplay(_INTL("{1} crafts itself a {2}!", user.pbThis, itemName))
        user.giveItem(:BLACKSLUDGE)

        transformType(user, :POISON)
    end
end

# Empowered Rock Polish
class PokeBattle_Move_61B < PokeBattle_Move_030
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.applyEffect(:ExtraTurns, 2)
        transformType(user, :ROCK)
    end
end

# Empowered Whirlwind
class PokeBattle_Move_61C < PokeBattle_Move_0EB
    include EmpoweredMove

    def pbEffectGeneral(user)
        transformType(user, :FLYING)
    end
end

# Empowered Embargo
class PokeBattle_Move_61D < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        user.pbOpposingSide.applyEffect(:EmpoweredEmbargo) unless user.pbOpposingSide.effectActive?(:EmpoweredEmbargo)
        transformType(user, :DARK)
    end
end

# Empowered Chill
class PokeBattle_Move_61E < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        @battle.eachOtherSideBattler(user) do |b|
            b.applyFrostbite(user) if b.canFrostbite?(user, true, self)
        end
        transformType(user, :ICE)
    end
end

# Empowered Destiny Bond
class PokeBattle_Move_61F < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.applyEffect(:EmpoweredDestinyBond)
        transformType(user, :GHOST)
    end
end

# Empowered Shore Up
class PokeBattle_Move_620 < PokeBattle_HalfHealingMove
    include EmpoweredMove

    def pbEffectGeneral(user)
        super

        user.applyEffect(:EmpoweredShoreUp)

        transformType(user, :GROUND)
    end
end

# Empowered Loom Over
class PokeBattle_Move_621 < PokeBattle_Move_522
    include EmpoweredMove

    def pbEffectGeneral(user)
        super

        transformType(user, :DRAGON)
    end
end

# Empowered Detect
class PokeBattle_Move_622 < PokeBattle_Move
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.applyEffect(:EmpoweredDetect, 3)
        transformType(user, :FIGHTING)
    end
end

# Empowered Quiver Dance
class PokeBattle_Move_623 < PokeBattle_MultiStatUpMove
    include EmpoweredMove

    def initialize(battle, move)
        super
        @statUp = [:SPECIAL_ATTACK, 2, :SPECIAL_DEFENSE, 2, :SPEED, 2]
    end

    def pbEffectGeneral(user)
        super
        transformType(user, :BUG)
    end
end

# Empowered Shiver Dance
class PokeBattle_Move_624 < PokeBattle_MultiStatUpMove
    include EmpoweredMove

    def initialize(battle, move)
        super
        @statUp = [:ATTACK, 2, :DEFENSE, 2, :SPEED, 2]
    end

    def pbEffectGeneral(user)
        super
        transformType(user, :ICE)
    end
end

# Empowered Iron Defense
class PokeBattle_Move_625 < PokeBattle_Move_02F
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.addAbility(:FILTER,true)
        transformType(user, :STEEL)
    end
end

# Empowered Amnesia
class PokeBattle_Move_626 < PokeBattle_Move_033
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.addAbility(:UNAWARE,true)
        transformType(user, :PSYCHIC)
    end
end

# Empowered Howl
class PokeBattle_Move_627 < PokeBattle_Move_530
    include EmpoweredMove

    def pbEffectGeneral(user)
        summonAvatar(user, :POOCHYENA, _INTL("#{user.pbThis} calls out to the pack!"))
        super
        transformType(user, :DARK)
    end
end

# Empowered Mind Link
class PokeBattle_Move_628 < PokeBattle_Move_549
    include EmpoweredMove

    def pbEffectGeneral(user)
        summonAvatar(user, :ABRA, _INTL("#{user.pbThis} gathers an new mind!"))
        super
        transformType(user, :PSYCHIC)
    end
end

# Empowered Growl
class PokeBattle_Move_629 < PokeBattle_Move_042
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.tryRaiseStat(:ATTACK, user, move: self, increment: 2)
    end
end

# Empowered Dazzle
class PokeBattle_Move_630 < PokeBattle_Move_045
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        user.tryRaiseStat(:SPECIAL_ATTACK, user, move: self, increment: 2)
    end
end

# Empowered Yawn
class PokeBattle_Move_631 < PokeBattle_Move_004
    include EmpoweredMove
end

# Empowered Dream Dance
class PokeBattle_Move_632 < PokeBattle_Move_032
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        # TODO
        transformType(user, :FAIRY)
    end
end

# Empowered Swords Dance
class PokeBattle_Move_633 < PokeBattle_Move_02E
    include EmpoweredMove

    def pbEffectGeneral(user)
        super
        # TODO
        transformType(user, :STEEL)
    end
end

# Empowered Stand Together
class PokeBattle_Move_633 < PokeBattle_Move_554
    include EmpoweredMove

    def pbEffectGeneral(user)
        summonAvatar(user, :TYROGUE, _INTL("#{user.pbThis} joins with an ally!"))
        super
        transformType(user, :FIGHTING)
    end
end

# Empowered Harmonize
class PokeBattle_Move_634 < PokeBattle_Move_555
    include EmpoweredMove

    def pbEffectGeneral(user)
        summonAvatar(user, :GOSSIFLEUR, _INTL("#{user.pbThis} connects with their friend!"))
        super
        transformType(user, :GRASS)
    end
end

########################################################
### DAMAGING MOVES
########################################################

# Empowered Meteor Mash
class PokeBattle_Move_636 < PokeBattle_Move_01C
    include EmpoweredMove
end

# Empowered Ice Beam
class PokeBattle_Move_637 < PokeBattle_Move_403
    include EmpoweredMove
end

# Empowered Rock Tomb
class PokeBattle_Move_638 < PokeBattle_Move_04D
    include EmpoweredMove
end

# Empowered Ancient Power
class PokeBattle_Move_639 < PokeBattle_Move_02D
    include EmpoweredMove
end

# Empowered Thunderbolt / Dragon Breath
class PokeBattle_Move_640 < PokeBattle_NumbMove
    include EmpoweredMove
end

# Empowered Flareblitz
class PokeBattle_Move_641 < PokeBattle_Move_0FE
    include EmpoweredMove
end

# Empowered Metal Claw
class PokeBattle_Move_642 < PokeBattle_Move_5D8
    include EmpoweredMove

    def multiHitMove?; return true; end
    def pbNumHits(_user, _targets, _checkingForAI = false); return 2; end
end

# Empowered Slash
class PokeBattle_Move_643 < PokeBattle_Move_0A0
    include EmpoweredMove
end

# Empowered Brick Break
class PokeBattle_Move_644 < PokeBattle_TargetStatDownMove
    include EmpoweredMove

    def ignoresReflect?; return true; end

    def pbEffectGeneral(user)
        user.pbOpposingSide.eachEffect(true) do |effect, _value, data|
            user.pbOpposingSide.disableEffect(effect) if data.is_screen?
        end
    end

    def pbShowAnimation(id, user, targets, hitNum = 0, showAnimation = true)
        user.pbOpposingSide.eachEffect(true) do |_effect, _value, data|
            # Wall-breaking anim
            hitNum = 1 if data.is_screen?
        end
        super
    end

    def initialize(battle, move)
        super
        @statDown = [:DEFENSE, 5]
    end
end

# Empowered Cross Poison
class PokeBattle_Move_645 < PokeBattle_Move
    include EmpoweredMove

    def pbCriticalOverride(_user, target)
        return 1 if target.poisoned?
        return 0
    end
end

# Empowered Solar Beam
class PokeBattle_Move_646 < PokeBattle_Move_0C4
    include EmpoweredMove
end

# Empowered Power Gem
class PokeBattle_Move_647 < PokeBattle_Move_401
    include EmpoweredMove
end

# Empowered Bullet Seed
class PokeBattle_Move_648 < PokeBattle_Move_17C
    include EmpoweredMove

    def pbRepeatHit?(hitNum = 0)
        return hitNum < 5
    end

    def turnsBetweenUses(); return 3; end
end

# Empowered Future Sight
class PokeBattle_Move_649 < PokeBattle_Move_111
    include EmpoweredMove
end

# Empowered Dragon Darts
class PokeBattle_Move_650 < PokeBattle_Move_17C
    include EmpoweredMove
end

# Empowered Giga Drain
class PokeBattle_Move_651 < PokeBattle_DrainMove
    include EmpoweredMove

    def drainFactor(_user, _target); return 1.0; end
end

# Empowered Earthquake
class PokeBattle_Move_652 < PokeBattle_Move_076
    include EmpoweredMove
end

# Empowered Surf
class PokeBattle_Move_653 < PokeBattle_Move_075
    include EmpoweredMove
end

# Empowered Brave Bird
class PokeBattle_Move_654 < PokeBattle_Move_0FB
    include EmpoweredMove
end

# Empowered Sludge Wave
class PokeBattle_Move_655 < PokeBattle_Move_005
    include EmpoweredMove
end

# Empowered Stored Power
class PokeBattle_Move_656 < PokeBattle_Move_08E
    include EmpoweredMove

    def pbBaseDamage(_baseDmg, user, _target)
        mult = 1
        GameData::Stat.each_battle { |s| mult += user.steps[s.id] if user.steps[s.id] > 0 }
        return 30 * mult
    end
end

# Empowered Bullet Punch
class PokeBattle_Move_657 < PokeBattle_Move_500
    include EmpoweredMove
end

# Empowered Mystical Fire
class PokeBattle_Move_658 < PokeBattle_TargetStatDownMove
    include EmpoweredMove

    def initialize(battle, move)
        super
        @statDown = [:SPECIAL_ATTACK, 6]
    end
end

########################################################
### Specific avatar only moves
########################################################

#===============================================================================
# Targets struck lose their flinch immunity. Only usable by the Avatar of Rayquaza (Stratosphere Scream)
#===============================================================================
class PokeBattle_Move_700 < PokeBattle_Move
    def ignoresSubstitute?(_user); return true; end

    def pbMoveFailed?(user, _targets, show_message)
        if !user.countsAs?(:RAYQUAZA) || !user.boss?
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbEffectAfterAllHits(_user, target)
        return if target.fainted?
        return if target.damageState.unaffected
        if target.effectActive?(:FlinchImmunity)
            target.disableEffect(:FlinchImmunity)
            @battle.pbDisplay(_INTL("#{target.pbThis} is newly afraid. It can be flinched again!"))
        end
    end
end

#===============================================================================
# Summons an Avatar of Luvdisc and an Avatar of Remoraid.
# Only usable by the Avatar of Kyogre (Seven Seas Edict)
#===============================================================================
class PokeBattle_Move_701 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if !user.countsAs?(:KYOGRE) || !user.boss?
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        end
        unless @battle.pbSideSize(user.index) == 1
            @battle.pbDisplay(_INTL("But there is no room for fish to join!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        @battle.pbDisplay(_INTL("Fish are drawn to the field!", user.pbThis))
        @battle.summonAvatarBattler(:LUVDISC, user.level, user.index % 2)
        @battle.summonAvatarBattler(:REMORAID, user.level, user.index % 2)
        @battle.pbSwapBattlers(user.index, user.index + 2)
    end
end

#===============================================================================
# Summons Gravity for 10 turn and doubles the weight of Pokemon on the opposing side.
# Only usable by the Avatar of Groudon (Warping Core)
#===============================================================================
class PokeBattle_Move_702 < PokeBattle_Move
    def pbMoveFailed?(user, _targets, show_message)
        if !user.countsAs?(:GROUDON) || !user.boss?
            @battle.pbDisplay(_INTL("But {1} can't use the move!", user.pbThis(true))) if show_message
            return true
        end
        if @battle.field.effectActive?(:Gravity)
            @battle.pbDisplay(_INTL("But gravity is already warped!", user.pbThis(true))) if show_message
            return true
        end
        return false
    end

    def pbEffectGeneral(user)
        @battle.field.applyEffect(:Gravity, 5)
        @battle.eachOtherSideBattler(user) do |b|
            b.applyEffect(:WarpingCore)
        end
    end
end