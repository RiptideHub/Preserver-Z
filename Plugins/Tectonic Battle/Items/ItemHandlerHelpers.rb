def healFromBerry(battler, ratio, item, forced = false, filchedFrom = nil, filchingAbility = nil)
    if filchedFrom
        battler.battle.pbShowAbilitySplash(battler, filchingAbility)
        itemName = GameData::Item.get(item).real_name
        battler.battle.pbDisplay(_INTL("#{battler.pbThis} filched #{filchedFrom.pbThis(true)}'s #{itemName}!"))
    end
    battler.battle.pbCommonAnimation("Nom", battler) unless forced
    ratio *= 2.0 if battler.hasActiveAbility?(:RIPEN)
    if battler.hasTribeBonus?(:SCAVENGER)
        ratio *= 1.25
        battler.battle.pbShowTribeSplash(battler,:SCAVENGER)
        battler.battle.pbDisplay(_INTL("#{battler.pbThis} got a bit extra out of their #{getItemName(item)}!"))
        battler.battle.pbHideTribeSplash(battler)
    end
    itemToPass = forced ? nil : item
    battler.applyFractionalHealing(ratio, item: itemToPass)
    battler.battle.pbHideAbilitySplash(battler) if filchedFrom
end

def pbBattleStatIncreasingBerry(battler, battle, item, forced, stat, increment = 1, checkGluttony = true, filchedFrom = nil, filchingAbility = nil)
    return false if !forced && !battler.canConsumePinchBerry?(checkGluttony)
    return false unless battler.pbCanRaiseStatStep?(stat, battler)
    if filchedFrom
        battle.pbShowAbilitySplash(battler, filchingAbility)
        itemName = GameData::Item.get(item).real_name
        battle.pbDisplay(_INTL("#{battler.pbThis} filched #{filchedFrom.pbThis(true)}'s #{itemName}!"))
    end
    itemName = GameData::Item.get(item).name
    increment *= 2 if battler.hasActiveAbility?(:RIPEN)
    if forced
        return battler.pbRaiseStatStep(stat, increment, battler)
    end
    battle.pbCommonAnimation("Nom", battler)
    result = battler.pbRaiseStatStepByCause(stat, increment, battler, itemName)
    battle.pbHideAbilitySplash(battler) if filchedFrom
    return result
end

def pbBattleTypeWeakingBerry(item, type, moveType, target, mults, feast = false, aiChecking = false)
    return if moveType != type
    return if Effectiveness.resistant?(target.damageState.typeMod) && moveType != :NORMAL
    if target.hasActiveAbility?(:RIPEN)
        mults[:final_damage_multiplier] = (mults[:final_damage_multiplier] / 4).round
    else
        mults[:final_damage_multiplier] /= 2
    end
    if feast
        target.damageState.feastWeakened = item
    else
        target.damageState.berryWeakened = item
    end
    target.battle.pbCommonAnimation("Nom", target) unless aiChecking
end

def pbBattleGem(item, user, type, move, mults, moveType, aiChecking = false)
    # Pledge moves never consume Gems
    return if move.is_a?(PokeBattle_PledgeMove)
    return if moveType != type
    return unless user.canConsumeGem?
    user.applyEffect(:GemConsumed, item) unless aiChecking
    mults[:base_damage_multiplier] *= 1.5
end
