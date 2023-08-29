BattleHandlers::SpecialDefenseCalcUserAbility.add(:MARVELSKIN,
    proc { |ability, user, _battle, spDefMult|
        spDefMult *= 2 if user.pbHasAnyStatus?
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcUserAbility.add(:SOLARCELL,
    proc { |ability, _user, battle, spDefMult|
        spDefMult *= 1.25 if battle.sunny?
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcUserAbility.add(:FLOWERGIFT,
    proc { |ability, _user, battle, spDefMult|
        spDefMult *= 1.5 if battle.sunny?
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcUserAbility.add(:ICESCALES,
    proc { |ability, _user, _battle, spDefMult|
        spDefMult *= 2
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcUserAbility.add(:ASSAULTSPINES,
    proc { |ability, _user, _battle, spDefMult|
        spDefMult *= 2
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcUserAbility.add(:PARANOID,
    proc { |ability, _user, _battle, spDefMult|
        spDefMult *= 2
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcUserAbility.add(:HEATVEIL,
    proc { |ability, _user, battle, spDefMult|
        spDefMult *= 2 if battle.sunny?
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcUserAbility.add(:WARPINGEFFECT,
    proc { |ability, _user, battle, spDefMult|
        spDefMult *= 2 if battle.eclipsed?
        next spDefMult
    }
)

BattleHandlers::SpecialDefenseCalcUserAbility.add(:ICEMIRROR,
    proc { |ability, _user, battle, spDefMult|
        spDefMult *= 2 if battle.icy?
        next spDefMult
    }
)