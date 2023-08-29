# Trainer dialogue events!

class TrainerDialogueHandlerHash < HandlerHash2
end

class PokeBattle_AI
    TrainerChoseMoveDialogue                    = TrainerDialogueHandlerHash.new
    PlayerChoseMoveDialogue	                    = TrainerDialogueHandlerHash.new
    TrainerIsUsingMoveDialogue	                = TrainerDialogueHandlerHash.new
    PlayerIsUsingMoveDialogue	                = TrainerDialogueHandlerHash.new
    TrainerPokemonFaintedDialogue	            = TrainerDialogueHandlerHash.new
    PlayerPokemonFaintedDialogue	            = TrainerDialogueHandlerHash.new
    TrainerSendsOutPokemonDialogue	            = TrainerDialogueHandlerHash.new
    PlayerSendsOutPokemonDialogue	            = TrainerDialogueHandlerHash.new
    TrainerPokemonTookMoveDamageDialogue		= TrainerDialogueHandlerHash.new
    PlayerPokemonTookMoveDamageDialogue			= TrainerDialogueHandlerHash.new
    TrainerPokemonImmuneDialogue				= TrainerDialogueHandlerHash.new
    PlayerPokemonImmuneDialogue					= TrainerDialogueHandlerHash.new
    TrainerPokemonDiesToDOTDialogue	            = TrainerDialogueHandlerHash.new
    PlayerPokemonDiesToDOTDialogue	            = TrainerDialogueHandlerHash.new
    WeatherChangeDialogue						= TrainerDialogueHandlerHash.new
    TerrainChangeDialogue						= TrainerDialogueHandlerHash.new
    BattleSurvivedDialogue	                    = TrainerDialogueHandlerHash.new
    TrainerPokemonConsumesItemDialogue	        = TrainerDialogueHandlerHash.new
    PlayerPokemonConsumesItemDialogue	        = TrainerDialogueHandlerHash.new
    TrainerAbilityTriggeredDialogue	            = TrainerDialogueHandlerHash.new
    PlayerAbilityTriggeredDialogue	            = TrainerDialogueHandlerHash.new

    def self.triggerTrainerChoseMoveDialogue(policy, battler, move, target, trainer_speaking, dialogue_array)
        ret = TrainerChoseMoveDialogue.trigger(policy, battler, move, target, trainer_speaking, dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end

    def self.triggerPlayerChoseMoveDialogue(policy, battler, move, target, trainer_speaking, dialogue_array)
        ret = PlayerChoseMoveDialogue.trigger(policy, battler, move, target, trainer_speaking, dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end

    def self.triggerTrainerIsUsingMoveDialogue(policy, battler, move, target, trainer_speaking, dialogue_array)
        ret = TrainerIsUsingMoveDialogue.trigger(policy, battler, move, target, trainer_speaking, dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end

    def self.triggerPlayerIsUsingMoveDialogue(policy, battler, move, target, trainer_speaking, dialogue_array)
        ret = PlayerIsUsingMoveDialogue.trigger(policy, battler, move, target, trainer_speaking, dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end

    def self.triggerTrainerPokemonFaintedDialogue(policy, battler, trainer_speaking, dialogue_array)
        ret = TrainerPokemonFaintedDialogue.trigger(policy, battler, trainer_speaking, dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end

    def self.triggerPlayerPokemonFaintedDialogue(policy, battler, trainer_speaking, dialogue_array)
        ret = PlayerPokemonFaintedDialogue.trigger(policy, battler, trainer_speaking, dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end

    def self.triggerTrainerSendsOutPokemonDialogue(policy, battler, trainer_speaking, dialogue_array)
        ret = TrainerSendsOutPokemonDialogue.trigger(policy, battler, trainer_speaking, dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end

    def self.triggerPlayerSendsOutPokemonDialogue(policy, battler, trainer_speaking, dialogue_array)
        ret = PlayerSendsOutPokemonDialogue.trigger(policy, battler, trainer_speaking, dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end

    def self.triggerTrainerPokemonTookMoveDamageDialogue(policy, dealer, taker, move, trainer_speaking, dialogue_array)
        ret = TrainerPokemonTookMoveDamageDialogue.trigger(policy, dealer, taker, move, trainer_speaking,
dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end

    def self.triggerPlayerPokemonTookMoveDamageDialogue(policy, dealer, taker, move, trainer_speaking, dialogue_array)
        ret = PlayerPokemonTookMoveDamageDialogue.trigger(policy, dealer, taker, move, trainer_speaking,
dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end

    def self.triggerTrainerPokemonImmuneDialogue(policy, attacker, target, isImmunityAbility, trainer_speaking, dialogue_array)
        ret = TrainerPokemonImmuneDialogue.trigger(policy, attacker, target, isImmunityAbility, trainer_speaking,
dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end

    def self.triggerPlayerPokemonImmuneDialogue(policy, attacker, target, isImmunityAbility, trainer_speaking, dialogue_array)
        ret = PlayerPokemonImmuneDialogue.trigger(policy, attacker, target, isImmunityAbility, trainer_speaking,
dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end

    def self.triggerTrainerPokemonDiesToDOTDialogue(policy, pokemon, trainer_speaking, dialogue_array)
        ret = TrainerPokemonDiesToDOTDialogue.trigger(policy, pokemon, trainer_speaking, dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end

    def self.triggerPlayerPokemonDiesToDOTDialogue(policy, pokemon, trainer_speaking, dialogue_array)
        ret = PlayerPokemonDiesToDOTDialogue.trigger(policy, pokemon, trainer_speaking, dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end

    def self.triggerWeatherChangeDialogue(policy, old_weather, new_weather, trainer_speaking, dialogue_array)
        ret = WeatherChangeDialogue.trigger(policy, old_weather, new_weather, trainer_speaking, dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end

    def self.triggerTerrainChangeDialogue(policy, old_terrain, new_terrain, trainer_speaking, dialogue_array)
        ret = TerrainChangeDialogue.trigger(policy, old_terrain, new_terrain, trainer_speaking, dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end

    def self.triggerBattleSurvivedDialogue(policy, trainer_speaking, dialogue_array)
        ret = BattleSurvivedDialogue.trigger(policy, trainer_speaking, dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end

    def self.triggerTrainerPokemonConsumesItemDialogue(policy, battler, item, trainer_speaking, dialogue_array)
        ret = TrainerChoseMoveDialogue.trigger(policy, battler, item, trainer_speaking, dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end

    def self.triggerPlayerPokemonConsumesItemDialogue(policy, battler, item, trainer_speaking, dialogue_array)
        ret = PlayerChoseMoveDialogue.trigger(policy, battler, item, trainer_speaking, dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end

    def self.triggerTrainerAbilityTriggeredDialogue(policy, battler, ability, trainer_speaking, dialogue_array)
        ret = TrainerAbilityTriggeredDialogue.trigger(policy, battler, ability, trainer_speaking, dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end

    def self.triggerPlayerAbilityTriggeredDialogue(policy, battler, ability, trainer_speaking, dialogue_array)
        ret = PlayerAbilityTriggeredDialogue.trigger(policy, battler, ability, trainer_speaking, dialogue_array)
        return !ret.nil? ? ret : dialogue_array
    end
end

class PokeBattle_Battle
    #####################################################
    ## Dialogue triggering helper method helper methods (yo dawg)
    #####################################################
    def triggerDialogueOnBattlerAction(battler)
        unless @opponent.nil?
            if pbOwnedByPlayer?(battler.index)
                @opponent.each_with_index do |trainer_speaking, idxTrainer|
                    @scene.showTrainerDialogue(idxTrainer) do |policy, dialogue|
                        yield false, policy, trainer_speaking, dialogue
                    end
                end
            else
                triggerDialogueForOwner(battler) do |policy, trainer_speaking, dialogue|
                    yield true, policy, trainer_speaking, dialogue
                end
            end
        end
    end

    def triggerDialogueForEachOpponent
        unless @opponent.nil?
            @opponent.each_with_index do |trainer_speaking, idxTrainer|
                @scene.showTrainerDialogue(idxTrainer) do |policy, dialogue|
                    yield policy, trainer_speaking, dialogue
                end
            end
        end
    end

    def triggerDialogueForOwner(battler)
        unless @opponent.nil?
            idxTrainer = pbGetOwnerIndexFromBattlerIndex(battler.index)
            trainer_speaking = @opponent[idxTrainer]
            @scene.showTrainerDialogue(idxTrainer) do |policy, dialogue|
                yield policy, trainer_speaking, dialogue
            end
        end
    end

    #####################################################
    ## Dialogue triggering helper methods
    #####################################################
    def triggerTerrainChangeDialogue(old_terrain, new_terrain)
        triggerDialogueForEachOpponent do |policy, trainer_speaking, dialogue|
            PokeBattle_AI.triggerTerrainChangeDialogue(policy, old_terrain, new_terrain, trainer_speaking,
dialogue)
        end
    end

    def triggerWeatherChangeDialogue(old_weather, new_weather)
        triggerDialogueForEachOpponent do |policy, trainer_speaking, dialogue|
            PokeBattle_AI.triggerWeatherChangeDialogue(policy, old_weather, new_weather, trainer_speaking,
dialogue)
        end
    end

    # Enemy dialogue for when the battle ends due to rounds survived
    def triggerBattleSurvivedDialogue
        triggerDialogueForEachOpponent do |policy, trainer_speaking, dialogue|
            PokeBattle_AI.triggerBattleSurvivedDialogue(policy, trainer_speaking, dialogue)
        end
    end

    def triggerBattlerChoiceDialogue(battler, choice)
        triggerDialogueOnBattlerAction(battler) do |isTrainerOwned, policy, trainer_speaking, dialogue|
            case choice[0]
            when :UseMove
                move = choice[2]
                target = choice[3] == -1 ? nil : @battlers[choice[3]]
                if isTrainerOwned
                    PokeBattle_AI.triggerTrainerChoseMoveDialogue(policy, battler, move, target,
trainer_speaking, dialogue)
                else
                    PokeBattle_AI.triggerTrainerChoseMoveDialogue(policy, battler, move, target,
trainer_speaking, dialogue)
                end
            end
        end
    end

    def triggerBattlerConsumedItemDialogue(battler, item)
        triggerDialogueOnBattlerAction(battler) do |isTrainerOwned, policy, trainer_speaking, dialogue|
            if isTrainerOwned
                PokeBattle_AI.triggerTrainerPokemonConsumesItemDialogue(policy, battler, item, trainer_speaking,
dialogue)
            else
                PokeBattle_AI.triggerPlayerPokemonConsumesItemDialogue(policy, battler, item, trainer_speaking,
dialogue)
            end
        end
    end

    def triggerAbilityTriggeredDialogue(battler, ability)
        triggerDialogueOnBattlerAction(battler) do |isTrainerOwned, policy, trainer_speaking, dialogue|
            if isTrainerOwned
                PokeBattle_AI.triggerTrainerAbilityTriggeredDialogue(policy, battler, ability, trainer_speaking,
dialogue)
            else
                PokeBattle_AI.triggerPlayerAbilityTriggeredDialogue(policy, battler, ability, trainer_speaking,
dialogue)
            end
        end
    end

    def triggerBattlerEnterDialogue(battler)
        triggerDialogueOnBattlerAction(battler) do |isTrainerOwned, policy, trainer_speaking, dialogue|
            if isTrainerOwned
                PokeBattle_AI.triggerTrainerSendsOutPokemonDialogue(policy, battler, trainer_speaking, dialogue)
            else
                PokeBattle_AI.triggerPlayerSendsOutPokemonDialogue(policy, battler, trainer_speaking, dialogue)
            end
        end
    end

    def triggerBattlerTookMoveDamageDialogue(dealer, taker, move)
        triggerDialogueOnBattlerAction(taker) do |isTrainerOwned, policy, trainer_speaking, dialogue|
            if isTrainerOwned
                PokeBattle_AI.triggerTrainerPokemonTookMoveDamageDialogue(policy, dealer, taker, move, trainer_speaking,
dialogue)
            else
                PokeBattle_AI.triggerPlayerPokemonTookMoveDamageDialogue(policy, dealer, taker, move,
trainer_speaking, dialogue)
            end
        end
    end

    def triggerBattlerIsUsingMoveDialogue(user, targets, move)
        triggerDialogueOnBattlerAction(user) do |isTrainerOwned, policy, trainer_speaking, dialogue|
            if isTrainerOwned
                PokeBattle_AI.triggerTrainerIsUsingMoveDialogue(policy, user, move, targets, trainer_speaking,
dialogue)
            else
                PokeBattle_AI.triggerPlayerIsUsingMoveDialogue(policy, user, move, targets, trainer_speaking,
dialogue)
            end
        end
    end

    def triggerBattlerFaintedDialogue(battler)
        triggerDialogueOnBattlerAction(battler) do |isTrainerOwned, policy, trainer_speaking, dialogue|
            if isTrainerOwned
                PokeBattle_AI.triggerTrainerPokemonFaintedDialogue(policy, battler, trainer_speaking, dialogue)
            else
                PokeBattle_AI.triggerPlayerPokemonFaintedDialogue(policy, battler, trainer_speaking, dialogue)
            end
        end
    end

    # Enemy dialogue for victims of poison/burn
    def triggerDOTDeathDialogue(battler)
        triggerDialogueOnBattlerAction(battler) do |isTrainerOwned, policy, trainer_speaking, dialogue|
            if isTrainerOwned
                PokeBattle_AI.triggerTrainerPokemonDiesToDOTDialogue(policy, battler, trainer_speaking, dialogue)
            else
                PokeBattle_AI.triggerPlayerPokemonDiesToDOTDialogue(policy, battler, trainer_speaking, dialogue)
            end
        end
    end

    def triggerImmunityDialogue(user, target, isImmunityAbility)
        triggerDialogueOnBattlerAction(user) do |isTrainerOwned, policy, trainer_speaking, dialogue|
            if isTrainerOwned
                PokeBattle_AI.triggerTrainerPokemonImmuneDialogue(policy, user, target, isImmunityAbility, trainer_speaking,
dialogue)
            else
                PokeBattle_AI.triggerPlayerPokemonImmuneDialogue(policy, user, target, isImmunityAbility, trainer_speaking,
dialogue)
            end
        end
    end
end

def dialogueStateBased(dialogue_array, trainer_speaking, state_id)
    unless trainer_speaking.policyStates[state_id]
        newDialogue = yield
        if newDialogue.is_a?(Array)
            newDialogue.each do |newDialogueLine|
                dialogue_array.push(newDialogueLine)
            end
        else
            dialogue_array.push(newDialogue)
        end
    end
end
