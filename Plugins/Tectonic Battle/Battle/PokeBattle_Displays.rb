class PokeBattle_Battle
    def showMessages?
        return !@messagesBlocked && !@autoTesting
    end

    def pbDisplay(msg, &block)
        @scene.pbDisplayMessage(msg, &block) if showMessages?
    end

    def pbDisplayBrief(msg)
        @scene.pbDisplayMessage(msg, true) if showMessages?
    end

    def pbDisplayPaused(msg, &block)
        @scene.pbDisplayPausedMessage(msg, &block) if showMessages?
    end

    def pbDisplayConfirm(msg)
        return @scene.pbDisplayConfirmMessage(msg) if showMessages?
    end

    def pbDisplayConfirmSerious(msg)
        return @scene.pbDisplayConfirmMessageSerious(msg) if showMessages?
    end

    def pbDisplayWithFormatting(msg)
        @scene.pbShowWindow(PokeBattle_Scene::MESSAGE_BOX)
        if $PokemonSystem.dark_mode == 0
            msg = "\\c[12]#{msg}"
        else
            msg = "\\c[11]#{msg}"
        end
        pbMessageDisplay(@scene.getMessageWindow, msg) # Global display method
        @scene.resetMessageTextColor
    end

    def pbDisplaySlower(msg)
        pbDisplayWithFormatting(_INTL("\\ss#{msg}\\1")) if showMessages?
    end

    def pbDisplayBossNarration(msg)
        pbDisplaySlower(_INTL("\\w[speech avatar]#{msg}"))
    end

    def pbShowCommands(msg, commands, canCancel = true)
        @scene.pbShowCommands(msg, commands, canCancel)
    end

    def pbAnimation(move, user, targets, hitNum = 0)
        return unless showMessages?
        @scene.pbAnimation(move, user, targets, hitNum) if @showAnims
    end

    def pbCommonAnimation(name, user = nil, targets = nil)
        return unless showMessages?
        @scene.pbCommonAnimation(name, user, targets) if @showAnims
    end

    def pbShowAbilitySplash(battler, ability, delay = false, logTrigger = true)
        aiLearnsAbility(battler, ability)
        triggerAbilityTriggeredDialogue(battler, ability)
        return unless showMessages?
        @scene.pbShowAbilitySplash(battler, ability)
        if delay
            frames = Graphics.frame_rate # Default 1 second
            frames /= 2 if fastTransitions?
            frames.times { @scene.pbUpdate }
        end
    end

    def pbHideAbilitySplash(battler)
        return unless showMessages?
        @scene.pbHideAbilitySplash(battler)
    end

    def pbReplaceAbilitySplash(battler, ability, delay = false, logTrigger = true)
        return unless showMessages?
        pbShowAbilitySplash(battler, ability, delay, logTrigger)
    end

    def pbShowTribeSplash(side, tribe, delay = false, trainerName: nil)
        return unless showMessages?
        tribe = TribalBonus.getTribeName(tribe) if tribe.is_a?(Symbol)
        @scene.pbShowTribeSplash(side, tribe, trainerName)
        if delay
            frames = Graphics.frame_rate # Default 1 second
            frames /= 2 if fastTransitions?
            frames.times { @scene.pbUpdate }
        end
    end

    def pbHideTribeSplash(side)
        return unless showMessages?
        @scene.pbHideTribeSplash(side)
    end
end
