PokeBattle_AI::TrainerPokemonFaintedDialogue.add(:YEZERA6,
  proc { |_policy, battler, trainer_speaking, dialogue_array|
    battle = battler.battle
    if battle.pbAllFainted?(battler.index) && !battle.pbAllFainted?(battler.index + 2) &&
        !trainer_speaking.policyStates[:RelyOnMavisComment]
        dialogue_array.push("Don't give me that look! Don’t do it! Mavis – please, just end this.")
        trainer_speaking.policyStates[:RelyOnMavisComment] = true
    elsif battler.species == :TOGEKISS && !trainer_speaking.policyStates[:TogekissDeathComment]
        dialogue_array.push("Sleep. Rest, and awake in a new world.")
        trainer_speaking.policyStates[:TogekissDeathComment] = true
    end
    next dialogue_array
  }
)

PokeBattle_AI::TrainerPokemonTookMoveDamageDialogue.add(:YEZERA6,
    proc { |_policy, _dealer, taker, _move, trainer_speaking, dialogue_array|
        next dialogue_array if trainer_speaking.policyStates[:PivotComment]
        next dialogue_array unless taker.species == :TOGEKISS && taker.turnCount == 0
        if Effectiveness.resistant?(taker.damageState.typeMod)
            dialogue_array.push("The same simple pivot, again and again...I'm bored.")
        elsif Effectiveness.super_effective?(taker.damageState.typeMod)
            dialogue_array.push("I suppose it would never work on you, would it? Speak my language, read me like a book.")
        end
        trainer_speaking.policyStates[:PivotComment] = true
        next dialogue_array
    }
)

PokeBattle_AI::TrainerPokemonImmuneDialogue.add(:YEZERA6,
    proc { |_policy, _attacker, _target, _isImmunityAbility, trainer_speaking, dialogue_array|
        next dialogue_array if trainer_speaking.policyStates[:PivotComment]
        next dialogue_array unless taker.species == :TOGEKISS && taker.turnCount == 0
        dialogue_array.push("The same simple pivot, again and again...I'm bored.")
        trainer_speaking.policyStates[:PivotComment] = true
        next dialogue_array
    }
)
