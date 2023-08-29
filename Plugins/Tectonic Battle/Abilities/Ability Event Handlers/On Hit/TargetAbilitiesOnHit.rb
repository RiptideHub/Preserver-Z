#########################################
# Weather Abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:SANDBURST,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next pbBattleWeatherAbility(ability, :Sandstorm, target, battle, false, true, aiChecking)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:INNERLIGHT,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next pbBattleWeatherAbility(ability, :Sun, target, battle, false, true, aiChecking)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:STORMBRINGER,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next pbBattleWeatherAbility(ability, :Rain, target, battle, false, true, aiChecking)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:FROSTSCATTER,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next pbBattleWeatherAbility(ability, :Hail, target, battle, false, true, aiChecking)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:SUNEATER,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next pbBattleWeatherAbility(ability, :Eclipse, target, battle, false, true, aiChecking)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:LUNARLOYALTY,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next pbBattleWeatherAbility(ability, :Moonglow, target, battle, false, true, aiChecking)
    }
)

#########################################
# Stat change abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:GOOEY,
  proc { |ability, user, target, move, _battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatDownEffectScore([:ATTACK,1,:SPEED,1], target, user, i)
            end
            next ret
        end
        user.pbLowerMultipleStatSteps([:ATTACK,1,:SPEED,1], target, ability: ability)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:SICKENING,
  proc { |ability, user, target, move, _battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatDownEffectScore([:SPECIAL_ATTACK,1,:SPEED,1], target, user, i)
            end
            next ret
        end
        user.pbLowerMultipleStatSteps([:SPECIAL_ATTACK,1,:SPEED,1], target, ability: ability)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:TANGLINGHAIR,
    proc { |ability, user, target, move, _battle, aiChecking, aiNumHits|
          next unless move.physicalMove?
          if aiChecking
              ret = 0
              aiNumHits.times do |i|
                  ret -= getMultiStatDownEffectScore([:SPEED,3], target, user, i)
              end
              next ret
          end
          user.tryLowerStat(:SPEED, target, ability: ability, increment: 3)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:COTTONDOWN,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatDownEffectScore([:SPEED,2], target, user, i)
            end
            next ret
        else
            battle.pbShowAbilitySplash(target, ability)
            target.eachOpposing do |b|
                b.tryLowerStat(:SPEED, target, increment: 2)
            end
            target.eachAlly do |b|
                b.tryLowerStat(:SPEED, target, increment: 2)
            end
            battle.pbHideAbilitySplash(target)
        end
    }
)

BattleHandlers::TargetAbilityOnHit.add(:STAMINA,
  proc { |ability, user, target, move, _battle, aiChecking, aiNumHits|
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatUpEffectScore([:DEFENSE,2], user, target, i)
            end
            next ret
        end
        target.tryRaiseStat(:DEFENSE, target, ability: ability, increment: 2)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:GRIT,
    proc { |ability, user, target, move, _battle, aiChecking, aiNumHits|
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatUpEffectScore([:SPECIAL_DEFENSE,2], user, target, i)
            end
            next ret
        end
        target.tryRaiseStat(:SPECIAL_DEFENSE, target, ability: ability, increment: 2)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:ADAPTIVESKIN,
    proc { |ability, user, target, move, _battle, aiChecking, aiNumHits|
        statToRaise = nil
        if move.physicalMove?
            statToRaise = :DEFENSE
        else
            statToRaise = :SPECIAL_DEFENSE
        end
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatUpEffectScore([statToRaise,1], user, target, i)
            end
            next ret
        end
        target.tryRaiseStat(statToRaise, target, ability: ability, increment: 2)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:WEAKARMOR,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        if aiChecking
            ret = getMultiStatDownEffectScore([:DEFENSE, 1], target, target)
            ret -= getMultiStatUpEffectScore([:SPEED, 2], target, target)
            next ret
        else
            battle.pbShowAbilitySplash(target, ability)
            target.tryLowerStat(:DEFENSE, target)
            target.tryRaiseStat(:SPEED, target, increment: 2)
            battle.pbHideAbilitySplash(target)
        end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WEAKSPIRIT,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        if aiChecking
            ret = getMultiStatDownEffectScore([:SPECIAL_DEFENSE, 1], target, target)
            ret -= getMultiStatUpEffectScore([:SPEED, 2], target, target)
            next ret
        else
            battle.pbShowAbilitySplash(target, ability)
            target.tryLowerStat(:SPECIAL_DEFENSE, target)
            target.tryRaiseStat(:SPEED, target, increment: 2)
            battle.pbHideAbilitySplash(target)
        end
    }
)

BattleHandlers::TargetAbilityOnHit.add(:STEAMPOWER,
    proc { |ability, user, target, move, _battle, aiChecking, aiNumHits|
        next unless move.calcType == :WATER
        if aiChecking
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatUpEffectScore([:SPEED,4], user, target, i*4)
            end
            next ret
        end
        target.tryRaiseStat(:SPEED, target, increment: 4, ability: ability)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:FORCEREVERSAL,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        if aiChecking
            expectedTypeMod = battle.battleAI.pbCalcTypeModAI(move.calcType, user, target, move)
            next 0 unless Effectiveness.resistant?(target.damageState.typeMod)
            ret = 0
            aiNumHits.times do |i|
                ret -= getMultiStatUpEffectScore(ATTACKING_STATS_2, user, target, i)
            end
            next ret
        else
            next unless Effectiveness.resistant?(target.damageState.typeMod)
            target.pbRaiseMultipleStatSteps(ATTACKING_STATS_2, target, ability: ability)
        end
    }
)

#########################################
# Damaging abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:IRONBARBS,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        if aiChecking
            next -10 * aiNumHits if user.takesIndirectDamage?
            next 0
        end
        battle.pbShowAbilitySplash(target, ability)
        if user.takesIndirectDamage?(true)
            battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
            user.applyFractionalDamage(1.0 / 8.0)
        end
        battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.copy(:IRONBARBS, :ROUGHSKIN)

BattleHandlers::TargetAbilityOnHit.add(:FEEDBACK,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?(user)
        if aiChecking
            next -10 * aiNumHits if user.takesIndirectDamage?
            next 0
        end
        battle.pbShowAbilitySplash(target, ability)
        if user.takesIndirectDamage?(true)
            battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
            user.applyFractionalDamage(1.0 / 8.0)
        end
        battle.pbHideAbilitySplash(target)
    }
)
  
BattleHandlers::TargetAbilityOnHit.add(:ARCCONDUCTOR,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless battle.rainy?
        if aiChecking
            next -10 * aiNumHits if user.takesIndirectDamage?
            next 0
        end
        battle.pbShowAbilitySplash(target, ability)
        if user.takesIndirectDamage?(true)
            battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
            user.applyFractionalDamage(1.0 / 6.0)
        end
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:SPINTENSITY,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless target.steps[:SPEED] > 0
        if aiChecking
            next -5 * target.steps[:SPEED] if user.takesIndirectDamage?
            next 0
        end
        battle.pbShowAbilitySplash(target, ability)
        battle.pbDisplay(_INTL("#{user.pbThis} catches the full force of #{target.pbThis(true)}'s Speed!"))
        oldStep = target.steps[:SPEED]
        user.applyFractionalDamage(oldStep / 8.0)
        battle.pbCommonAnimation("StatDown", target)
        target.steps[:SPEED] = 0
        battle.pbHideAbilitySplash(target)
    }
)

#########################################
# Move usage abilities
#########################################

# TODO: Make the checks here more detailed

BattleHandlers::TargetAbilityOnHit.add(:RELUCTANTBLADE,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if target.fainted?
        next -30 * aiNumHits if aiChecking
        battle.forceUseMove(target, :LEAFAGE, user.index, ability: ability)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:COUNTERFLOW,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        next if target.fainted?
        next -30 * aiNumHits if aiChecking
        battle.forceUseMove(target, :WIPEOUT, user.index, ability: ability)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WIBBLEWOBBLE,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next if target.fainted?
        next -40 if aiChecking
        battle.forceUseMove(target, :POWERSPLIT, user.index, ability: ability)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CONSTRICTOR,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if target.fainted?
        next -(10 + 20 * aiNumHits) if aiChecking
        battle.forceUseMove(target, :BIND, user.index, ability: ability)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:TOTALMIRROR,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        next if target.fainted?
        next -60 if aiChecking
        battle.forceUseMove(target, move.id, user.index, ability: ability)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:ABOVEITALL,
  proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next if target.fainted?
        next -40 if aiChecking
        battle.forceUseMove(target, :PARTINGSHOT, user.index, ability: ability)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:SHOCKRESPONSE,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
          next if target.fainted?
          next unless move.baseDamage >= 100
          if aiChecking
            score = -5
            score -= getNumbEffectScore(target, user)
            next score
          end
          battle.forceUseMove(target, :NUZZLE, target.index, ability: ability)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:SNORING,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
          next if target.fainted?
          next unless target.asleep?
          next -30 * aiNumHits if aiChecking
          battle.forceUseMove(target, :SNORE, user.index, ability: ability)
    }
)

#########################################
# Status inducing abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:STATIC,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        randomStatusProcTargetAbility(ability, :NUMB, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)
  
BattleHandlers::TargetAbilityOnHit.add(:PETRIFYING,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        randomStatusProcTargetAbility(ability, :NUMB, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:POISONPOINT,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        randomStatusProcTargetAbility(ability, :POISON, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
  )

BattleHandlers::TargetAbilityOnHit.add(:POISONPUNISH,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        randomStatusProcTargetAbility(ability, :POISON, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:SUDDENCHILL,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        randomStatusProcTargetAbility(ability, :FROSTBITE, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:CHILLEDBODY,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        randomStatusProcTargetAbility(ability, :FROSTBITE, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:BEGUILING,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        randomStatusProcTargetAbility(ability, :DIZZY, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:DISORIENT,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        randomStatusProcTargetAbility(ability, :DIZZY, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:KELPLINK,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        randomStatusProcTargetAbility(ability, :LEECHED, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:PLAYVICTIM,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        randomStatusProcTargetAbility(ability, :LEECHED, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:FLAMEBODY,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        randomStatusProcTargetAbility(ability, :BURN, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:FIERYSPIRIT,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.specialMove?
        randomStatusProcTargetAbility(ability, :BURN, 30, user, target, move, battle, aiChecking, aiNumHits)
    }
)

#########################################
# Other punishment random triggers
#########################################

BattleHandlers::TargetAbilityOnHit.add(:CURSEDTAIL,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if user.effectActive?(:Curse)
        if aiChecking
            if user.effectActive?(:Warned) || aiNumHits > 1
                next -30
            else
                next -10
            end
        end
        battle.pbShowAbilitySplash(target, ability)
        if user.effectActive?(:Warned)
            user.applyEffect(:Curse)
        else
            user.applyEffect(:Warned)
        end
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:SEALINGBODY,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next if user.fainted?
        next if user.effectActive?(:Disable)
        next -15 if aiChecking
        battle.pbShowAbilitySplash(target, ability)
        user.applyEffect(:Disable, 3) if user.canBeDisabled?(true)
        battle.pbHideAbilitySplash(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:PERISHBODY,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next if target.boss?
        next if user.effectActive?(:PerishSong)
        next if target.effectActive?(:PerishSong)
        next -5 if aiChecking
        battle.pbShowAbilitySplash(target, ability)
        if target.boss?
            target.applyEffect(:PerishSong, 12)
        else
            target.applyEffect(:PerishSong, 3)
        end
        if user.boss?
            user.applyEffect(:PerishSong, 12)
        else
            user.applyEffect(:PerishSong, 3)
        end
        battle.pbHideAbilitySplash(target)
    }
)

#########################################
# Other abilities
#########################################

BattleHandlers::TargetAbilityOnHit.add(:INNARDSOUT,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next if user.dummy
        if aiChecking
            if user.takesIndirectDamage?
                next -50 / aiNumHits
            else
                next 0
            end
        end
        next unless target.fainted?
        battle.pbShowAbilitySplash(target, ability)
        if user.takesIndirectDamage?(true)
            battle.pbDisplay(_INTL("{1} is hurt!", user.pbThis))
            oldHP = user.hp
            damageTaken = target.damageState.hpLost
            damageTaken /= 4 if target.boss?
            user.damageState.displayedDamage = damageTaken
            battle.scene.pbDamageAnimation(user)
            user.pbReduceHP(damageTaken, false)
            user.pbHealthLossChecks(oldHP)
        end
        battle.pbHideAbilitySplash(target)
    }
)
  
BattleHandlers::TargetAbilityOnHit.add(:MUMMY,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if user.fainted?
        next if user.unstoppableAbility?
        next if user.hasAbility?(ability)
        next -10 if aiChecking
        user.replaceAbility(ability, user.opposes?(target))
    }
)
  
BattleHandlers::TargetAbilityOnHit.add(:INFECTED,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if user.fainted?
        next if user.unstoppableAbility?
        next if user.hasAbility?(ability)
        next unless user.canChangeType?
        next -15 if aiChecking
        user.replaceAbility(ability, user.opposes?(target), target)
        user.applyEffect(:Type3,:GRASS) unless user.pbHasType?(:GRASS)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:WANDERINGSPIRIT,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if user.fainted?
        next if user.unstoppableAbility?
        next if user.hasAbility?(ability)
        oldAbil = user.firstAbility
        next unless oldAbil
        next -5 if aiChecking
        target.replaceAbility(oldAbil, user.opposes?(target))
        user.replaceAbility(ability, user.opposes?(target))
    }
)

BattleHandlers::TargetAbilityOnHit.add(:THUNDERSTRUCK,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        if aiChecking
            next target.pbHasAttackingType?(:ELECTRIC) ? -40 : 0
        else
            target.applyEffect(:Charge)
        end
    }
)

BattleHandlers::TargetAbilityOnHit.add(:GULPMISSILE,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next if target.form == 0
        next unless target.species == :CRAMORANT
        gulpform = target.form
        if aiChecking
            score = 0
            score -= 20 if user.takesIndirectDamage?
            if gulpform == 1
                score -= getMultiStatDownEffectScore(DEFENDING_STATS_1, target, user)
            elsif gulpform == 2
                score -= getNumbEffectScore(target, user)
            end
            next score
        else
            battle.pbShowAbilitySplash(target, ability)
            target.form = 0
            battle.scene.pbChangePokemon(target, target.pokemon)
            battle.scene.pbDamageAnimation(user)
            user.applyFractionalDamage(1.0 / 4.0) if user.takesIndirectDamage?(true)
            if gulpform == 1
                user.pbLowerMultipleStatSteps(DEFENDING_STATS_1, target, ability: ability)
            elsif gulpform == 2
                msg = nil
                user.applyNumb(target, msg)
            end
            battle.pbHideAbilitySplash(target)
        end
    }
)
  
BattleHandlers::TargetAbilityOnHit.add(:ILLUSION,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next 10 if aiChecking
        # NOTE: This intentionally doesn't show the ability splash.
        next unless target.illusion?
        target.disableEffect(:Illusion)
        battle.scene.pbChangePokemon(target, target.pokemon)
        battle.pbSetSeen(target)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:EROSIONCYCLE,
    proc { |ability, target, battler, move, battle, aiChecking, aiNumHits|
        next unless move.physicalMove?
        next if target.pbOpposingSide.effectAtMax?(:ErodedRock)
        if aiChecking
            next (target.aboveHalfHealth? ? -10 : 0) * aiNumHits
        end
        target.pbOwnSide.incrementEffect(:ErodedRock)
    }
)

BattleHandlers::TargetAbilityOnHit.add(:QUILLERINSTINCT,
    proc { |ability, user, target, move, battle, aiChecking, aiNumHits|
        next if target.pbOpposingSide.effectAtMax?(:Spikes)
        if aiChecking
            layerSlots = GameData::BattleEffect.get(:Spikes).maximum - target.pbOpposingSide.countEffect(:Spikes)
            aiNumHits = [aiNumHits,layerSlots].min
            next -getHazardSettingEffectScore(target, user) * aiNumHits
        end
        battle.pbShowAbilitySplash(target, ability)
        target.pbOpposingSide.incrementEffect(:Spikes)
        battle.pbHideAbilitySplash(target)
    }
)

# Only does stuff for the AI
BattleHandlers::TargetAbilityOnHit.add(:MULTISCALE,
    proc { |ability, user, target, move, _battle, aiChecking, aiNumHits|
        next unless target.hp == target.totalhp
        if aiChecking
            next 20
        else
            target.aiLearnsAbility(ability)
        end
    }
)

# Only does stuff for the AI
BattleHandlers::TargetAbilityOnHit.copy(:MULTISCALE,:ALOOF)