#===============================================================================
# TargetItemOnHitPositiveBerry handlers
# NOTE: This is for berries that have an effect when Pluck/Bug Bite/Fling
#       forces their use.
#===============================================================================

BattleHandlers::TargetItemOnHitPositiveBerry.add(:KEEBERRY,
    proc { |item, battler, battle, forced|
        next false if !forced && !battler.canConsumeBerry?
        next false unless battler.pbCanRaiseStatStep?(:DEFENSE, battler)
        itemName = GameData::Item.get(item).name
        increment = 4
        increment *= 2 if battler.hasActiveAbility?(:RIPEN)
        unless forced
            battle.pbCommonAnimation("Nom", battler)
            next battler.pbRaiseStatStepByCause(:DEFENSE, increment, battler, itemName)
        end
        next battler.pbRaiseStatStep(:DEFENSE, increment, battler)
    }
)

BattleHandlers::TargetItemOnHitPositiveBerry.add(:MARANGABERRY,
  proc { |item, battler, battle, forced|
      next false if !forced && !battler.canConsumeBerry?
      next false unless battler.pbCanRaiseStatStep?(:SPECIAL_DEFENSE, battler)
      itemName = GameData::Item.get(item).name
      increment = 4
      increment *= 2 if battler.hasActiveAbility?(:RIPEN)
      unless forced
          battle.pbCommonAnimation("Nom", battler)
          next battler.pbRaiseStatStepByCause(:SPECIAL_DEFENSE, increment, battler, itemName)
      end
      next battler.pbRaiseStatStep(:SPECIAL_DEFENSE, increment, battler)
  }
)

BattleHandlers::TargetItemOnHitPositiveBerry.add(:ENIGMABERRY,
  proc { |item, battler, battle, forced|
      next false unless battler.canHeal?
      next false if !forced && !battler.canConsumeBerry?
      battle.pbCommonAnimation("Nom", battler) unless forced
      healFromBerry(battler, 1.0 / 4.0, item, forced = false)
      next true
  }
)
