BattleHandlers::FieldEffectStatLossItem.add(:ROOMSERVICE,
    proc { |item, battler, battle|
        next false unless battle.field.effectActive?(:TrickRoom)
        next battler.tryLowerStat(:SPEED, battler, increment: 4, item: item)
    }
)
