class PokeBattle_Battler
    #=============================================================================
    # Decide whether the trainer is allowed to tell the Pokémon to use the given
    # move. Called when choosing a command for the round.
    # Also called when processing the Pokémon's action, because these effects also
    # prevent Pokémon action. Relevant because these effects can become active
    # earlier in the same round (after choosing the command but before using the
    # move) or an unusable move may be called by another move such as Metronome.
    #=============================================================================
    def pbCanChooseMove?(move, commandPhase, showMessages = true, specialUsage = false)
        return true if move.empoweredMove? && boss?
        # Disable
        if @effects[:DisableMove] == move.id && !specialUsage
            msg = _INTL("{1}'s {2} is disabled!", pbThis, move.name)
            if showMessages
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            echoln(msg)
            return false
        end
        # Heal Block
        if effectActive?(:HealBlock) && move.healingMove?
            msg = _INTL("{1} can't use {2} because of Heal Block!", pbThis, move.name)
            if showMessages
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            echoln(msg)
            return false
        end
        # Gravity
        if @battle.field.effectActive?(:Gravity) && move.unusableInGravity?
            msg = _INTL("{1} can't use {2} because of gravity!", pbThis, move.name)
            if showMessages
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            echoln(msg)
            return false
        end
        # Throat Chop
        if effectActive?(:ThroatChop) && move.soundMove?
            if showMessages
                msg = _INTL("{1} can't use {2} because of Throat Chop!", pbThis, move.name)
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            echoln(msg)
            return false
        end
        # Choice Items
        if effectActive?(:ChoiceBand)
            choiceItem = nil
            CHOICE_LOCKING_ITEMS.each do |choiceLockItem|
                next unless hasActiveItem?(choiceLockItem)
                choiceItem = choiceLockItem
                break
            end
            if choiceItem && pbHasMove?(@effects[:ChoiceBand])
                if move.id != @effects[:ChoiceBand] && move.id != :STRUGGLE
                    msg = _INTL("{1} allows the use of only {2}!", getItemName(choiceItem),
GameData::Move.get(@effects[:ChoiceBand]).name)
                    if showMessages
                        commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
                    end
                    echoln(msg)
                    return false
                end
            else
                disableEffect(:ChoiceBand)
            end
        end
        # Gorilla Tactics
        if effectActive?(:GorillaTactics)
            choiceLockingAbility = hasActiveAbility?(CHOICE_LOCKING_ABILITIES)
            if choiceLockingAbility
                if move.id != @effects[:GorillaTactics]
                    msg = _INTL("{1} allows the use of only {2}!", getAbilityName(choiceLockingAbility),
GameData::Move.get(@effects[:GorillaTactics]).name)
                    if showMessages
                        commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
                    end
                    echoln(msg)
                    return false
                end
            else
                disableEffect(:GorillaTactics)
            end
        end
        # Taunt
        if effectActive?(:Taunt) && move.statusMove?
            msg = _INTL("{1} can't use {2} after the taunt!", pbThis, move.name)
            if showMessages
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            echoln(msg)
            return false
        end
        # Torment
        if effectActive?(:Torment) && !effectActive?(:Instructed) &&
           @lastMoveUsed && move.id == @lastMoveUsed && move.id != @battle.struggle.id
            msg = _INTL("{1} can't use the same move twice in a row due to the torment!", pbThis)
            if showMessages
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            echoln(msg)
            return false
        end
        # Imprison
        @battle.eachOtherSideBattler(@index) do |b|
            next if !b.effectActive?(:Imprison) || !b.pbHasMove?(move.id)
            msg = _INTL("{1} can't use its sealed {2}!", pbThis, move.name)
            if showMessages
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            echoln(msg)
            return false
        end
        # Barred
        if effectActive?(:Barred) && move.id != :STRUGGLE && !pbHasType?(move.pbCalcType(self))
            msg = _INTL("{1} can't use {2} after being barred!", pbThis, move.name)
            if showMessages
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            echoln(msg)
            return false
        end
        # Assault Vest and Strike Vest (prevents choosing status moves but doesn't prevent
        # executing them)
        if move.statusMove? && commandPhase
            statusPreventingItem = hasActiveItem?(STATUS_PREVENTING_ITEMS)
            if statusPreventingItem
                msg = _INTL("The effects of the {1} prevent status moves from being used!", getItemName(statusPreventingItem))
                if showMessages
                    commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
                end
                echoln(msg)
                return false
            end
            statusPreventingAbility = hasActiveAbility?(%i[ASSAULTSPINES])
            if statusPreventingAbility
                msg = _INTL("The effects of the {1} prevent status moves from being used!", getAbilityName(statusPreventingAbility))
                if showMessages
                    commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
                end
                echoln(msg)
                return false
            end
        end
        if hasActiveAbility?(:AURORAPRISM) && pbHasType?(move.type) && move.damagingMove?
            msg = _INTL("{1} cannot use moves of their own types!", pbThis)
            if showMessages
                commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
            end
            echoln(msg)
            return false
        end
        # Belch
        return false unless move.pbCanChooseMove?(self, commandPhase, showMessages)
        # Turbulent Sky
        if pbOwnSide.effectActive?(:TurbulentSky) && !effectActive?(:Instructed) &&
            @lastMoveUsedType && move.calcType == @lastMoveUsedType && move.id != @battle.struggle.id
             msg = _INTL("{1} can't use the same type twice in a row due to the turbulent sky!", pbThis)
             if showMessages
                 commandPhase ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
             end
             echoln(msg)
             return false
         end
        return true
    end

    #=============================================================================
    # Obedience check
    #=============================================================================
    # Return true if Pokémon continues attacking (although it may have chosen to
    # use a different move in disobedience), or false if attack stops.
    def pbObedienceCheck?(_choice)
        return true
    end

    def pbDisobey(choice, badgeLevel)
        move = choice[2]
        PBDebug.log("[Disobedience] #{pbThis} disobeyed")
        disableEffect(:Rage)
        # Do nothing if using Snore/Sleep Talk
        if @status == :SLEEP && move.usableWhenAsleep?
            @battle.pbDisplay(_INTL("{1} ignored orders and kept sleeping!", pbThis))
            return false
        end
        b = ((@level + badgeLevel) * @battle.pbRandom(256) / 256).floor
        # Use another move
        if b < badgeLevel
            @battle.pbDisplay(_INTL("{1} ignored orders!", pbThis))
            return false unless @battle.pbCanShowFightMenu?(@index)
            otherMoves = []
            eachMoveWithIndex do |_m, i|
                next if i == choice[1]
                otherMoves.push(i) if @battle.pbCanChooseMove?(@index, i, false)
            end
            return false if otherMoves.length == 0 # No other move to use; do nothing
            newChoice = otherMoves[@battle.pbRandom(otherMoves.length)]
            choice[1] = newChoice
            choice[2] = @moves[newChoice]
            choice[3] = -1
            return true
        end
        c = @level - badgeLevel
        r = @battle.pbRandom(256)
        # Fall asleep
        if r < c && canSleep?(self, false)
            applySleepSelf(_INTL("{1} began to nap!", pbThis))
            return false
        end
        # Hurt self in confusion
        r -= c
        if r < c && @status != :SLEEP
            pbConfusionDamage(_INTL("{1} won't obey! It hurt itself in its confusion!", pbThis))
            return false
        end
        # Show refusal message and do nothing
        case @battle.pbRandom(4)
        when 0 then @battle.pbDisplay(_INTL("{1} won't obey!", pbThis))
        when 1 then @battle.pbDisplay(_INTL("{1} turned away!", pbThis))
        when 2 then @battle.pbDisplay(_INTL("{1} is loafing around!", pbThis))
        when 3 then @battle.pbDisplay(_INTL("{1} pretended not to notice!", pbThis))
        end
        return false
    end

    #=============================================================================
    # Check whether the user (self) is able to take action at all.
    # If this returns true, and if PP isn't a problem, the move will be considered
    # to have been used (even if it then fails for whatever reason).
    #=============================================================================
    def pbTryUseMove(choice, move, specialUsage, skipAccuracyCheck)
        return true if move.empoweredMove? && boss? && move.statusMove?
        
        # Check whether it's possible for self to use the given move
        # NOTE: Encore has already changed the move being used, no need to have a
        #       check for it here.
        unless pbCanChooseMove?(move, false, true, specialUsage)
            @lastMoveFailed = true
            return false
        end

        # Check whether it's possible for self to do anything at all
        if effectActive?(:SkyDrop) # Intentionally no message here
            PBDebug.log("[Move failed] #{pbThis} can't use #{move.name} because of being Sky Dropped")
            return false
        end
        if effectActive?(:HyperBeam) # Intentionally before Truant
            @battle.pbDisplay(_INTL("{1} must recharge!", pbThis))
            return false
        end
        if choice[1] == -2 # Battle Palace
            @battle.pbDisplay(_INTL("{1} appears incapable of using its power!", pbThis))
            return false
        end

        # Skip checking all applied effects that could make self fail doing something
        return true if skipAccuracyCheck

        # Check status problems and continue their effects/cure them
        if pbHasStatus?(:SLEEP)
            reduceStatusCount(:SLEEP)
            if getStatusCount(:SLEEP) <= 0
                pbCureStatus(true, :SLEEP)
            else
                pbContinueStatus(:SLEEP)
                unless move.usableWhenAsleep? # Snore/Sleep Talk
                    @lastMoveFailed = true
                    return false
                end
            end
        end

        # Truant
        if hasActiveAbility?(:TRUANT)
            if effectActive?(:Truant)
                disableEffect(:Truant)
            else
                applyEffect(:Truant)
            end
            if !effectActive?(:Truant) && move.id != :SLACKOFF # True means loafing, but was just inverted
                @battle.pbShowAbilitySplash(self, :TRUANT)
                @battle.pbDisplay(_INTL("{1} is loafing around!", pbThis))
                @lastMoveFailed = true
                @battle.pbHideAbilitySplash(self)
                return false
            end
        end

        # Flinching
        if effectActive?(:Flinch)
            if effectActive?(:FlinchImmunity)
                @battle.pbDisplay("#{pbThis} would have flinched, but it's immune now!")
                disableEffect(:Flinch)
            elsif hasTribeBonus?(:TYRANNICAL) && !pbOwnSide.effectActive?(:TyrannicalImmunity)
                @battle.pbShowTribeSplash(self,:TYRANNICAL)
                @battle.pbDisplay(_INTL("{1} refuses to flinch!", pbThis))
                @battle.pbHideTribeSplash(self)
                pbOwnSide.applyEffect(:TyrannicalImmunity)
            else
                @battle.pbDisplay(_INTL("{1} flinched and couldn't move!", pbThis))
                eachActiveAbility do |ability|
                    BattleHandlers.triggerAbilityOnFlinch(ability, self, @battle)
                end
                @lastMoveFailed = true
                applyEffect(:FlinchImmunity,4)
                return false
            end
        end
        return true
    end

    def doesProtectionEffectNegateThisMove?(effectDisplayName, move, user, target, protectionIgnoredByAbility, animationName = nil, showMessages = true)
        if move.canProtectAgainst? && !protectionIgnoredByAbility
            @battle.pbCommonAnimation(animationName, target) unless animationName.nil?
            @battle.pbDisplay(_INTL("{1} protected {2}!", effectDisplayName, target.pbThis(true))) if showMessages
            if user.boss? && (move.empoweredMove? || AVATARS_REGULAR_ATTACKS_PIERCE_PROTECT)
                target.damageState.partiallyProtected = true
                yield if block_given?
                if showMessages
                    if move.empoweredMove? && !AVATARS_REGULAR_ATTACKS_PIERCE_PROTECT
                        @battle.pbDisplay(_INTL("But the empowered attack pierces through!", user.pbThis(true)))
                    else
                        @battle.pbDisplay(_INTL("Actually, {1} partially pierces through!", user.pbThis(true)))
                    end
                end
            else
                target.damageState.protected = true
                @battle.successStates[user.index].protected = true
                yield if block_given?
                return true
            end
        elsif move.pbTarget(user).targets_foe
            if showMessages
                @battle.pbDisplay(_INTL("{1} was ignored, and failed to protect {2}!", effectDisplayName,
target.pbThis(true)))
            end
        end
        return false
    end

    #=============================================================================
    # Initial success check against the target. Done once before the first hit.
    # Includes move-specific failure conditions, protections and type immunities.
    #=============================================================================
    def pbSuccessCheckAgainstTarget(move, user, target, typeMod, show_message = true, ai_check = false)
        # Two-turn attacks can't fail here in the charging turn
        return true if user.effectActive?(:TwoTurnAttack)

        # Move-specific failures

        if ai_check
            return false if move.pbFailsAgainstTargetAI?(user, target)
        elsif move.pbFailsAgainstTarget?(user, target, show_message)
            return false
        end

        # Immunity to priority moves because of Psychic Terrain
        if @battle.field.terrain == :Psychic && target.affectedByTerrain? && target.opposes?(user)
            if ai_check
                return false if move.priority > 0
            elsif @battle.choices[user.index][4] > 0
                if show_message
                    @battle.pbDisplay(_INTL("{1} surrounds itself with psychic terrain!",
target.pbThis))
                end
                return false
            end
        end

        ###	Protect Style Moves
        # Ability effects that ignore protection
        protectionIgnoredByAbility = false
        protectionIgnoredByAbility = true if user.shouldAbilityApply?(:UNSEENFIST, ai_check) && move.physicalMove?

        # Only check the target's side if the target is not the self
        holdersToCheck = [target]
        holdersToCheck.push(target.pbOwnSide) if target.index != user.index
        holdersToCheck.each do |effectHolder|
            effectHolder.eachEffect(true) do |effect, _value, data|
                next unless data.is_protection?
                if data.protection_info&.has_key?(:does_negate_proc) && !data.protection_info[:does_negate_proc].call(
                    user, target, move, @battle)
                    next
                end
                effectName = data.real_name
                animationName = data.protection_info ? data.protection_info[:animation_name] : effect.to_s
                negated = doesProtectionEffectNegateThisMove?(effectName, move, user, target, protectionIgnoredByAbility,
animationName, show_message) do
                    if data.protection_info&.has_key?(:hit_proc) && !ai_check
                        data.protection_info[:hit_proc].call(user, target, move, @battle)
                    end
                end
                return false if negated
            end
        end

        # Magic Coat/Magic Bounce/Magic Shield
        if move.canMagicCoat? && !target.semiInvulnerable? && target.opposes?(user)
            if target.effectActive?(:MagicCoat)
                unless ai_check
                    target.damageState.magicCoat = true
                    target.disableEffect(:MagicCoat)
                end
                return false
            end
            if target.hasActiveAbility?(:MAGICBOUNCE) && !@battle.moldBreaker
                unless ai_check
                    target.damageState.magicBounce = true
                    target.applyEffect(:MagicBounce)
                end
                return false
            end
            if target.hasActiveAbility?(:MAGICSHIELD) && !@battle.moldBreaker
                unless ai_check
                    target.damageState.protected = true
                    if show_message
                        @battle.pbShowAbilitySplash(target, :MAGICSHIELD)
                        @battle.pbDisplay(_INTL("{1} shielded itself from the {2}!", target.pbThis, move.name))
                        @battle.pbHideAbilitySplash(target)
                    end
                end
                return false
            end
        end

        # Move fails due to type immunity ability
        # Skipped for bosses using damaging moves so that it can be calculated properly later
        if move.inherentImmunitiesPierced?(user, target)
            # Do nothing
        elsif targetInherentlyImmune?(user, target, move, show_message, ai_check)
            return false
        elsif targetTypeModImmune?(user, target, move, typeMod, show_message)
            if !ai_check && target.effectActive?(:Illusion)
                target.aiLearnsAbility(:ILLUSION)
            end
            return false
        end

        # Substitute immunity to status moves
        if target.substituted? && move.statusMove? &&
           !move.ignoresSubstitute?(user) && user.index != target.index
            PBDebug.log("[Target immune] #{target.pbThis} is protected by its Substitute")
            @battle.pbDisplay(_INTL("{1} avoided the attack!", target.pbThis(true))) if show_message
            return false
        end
        return true
    end

    def targetTypeModImmune?(user, target, move, typeMod, showMessages = true)
        # Type immunity
        if move.damagingMove? && Effectiveness.ineffective?(typeMod)
            PBDebug.log("[Target immune] #{target.pbThis}'s type immunity")
            if showMessages
                @battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
                @battle.triggerImmunityDialogue(user, target, false)
            end
            return true
        end
        return false
    end

    def targetInherentlyImmune?(user, target, move, showMessages = true, aiChecking = false)
        if move.pbImmunityByAbility(user, target, showMessages, aiChecking)
            @battle.triggerImmunityDialogue(user, target, true) if showMessages
            return true
        end
        if airborneImmunity?(user, target, move, showMessages)
            PBDebug.log("[Target immune] #{target.pbThis}'s immunity due to being airborne")
            return true
        end
        # Dark-type immunity to moves made faster by Prankster
        pranksterInEffect = false
        if aiChecking
            pranksterInEffect = true if user.hasActiveAbilityAI?(:PRANKSTER) && move.statusMove?
        else
            pranksterInEffect = true if user.effectActive?(:Prankster)
        end
        if pranksterInEffect && target.pbHasType?(:DARK) && target.opposes?(user)
            PBDebug.log("[Target immune] #{target.pbThis} is Dark-type and immune to Prankster-boosted moves")
            if showMessages
                @battle.pbDisplay(_INTL("It doesn't affect {1} since Dark-types are immune to pranks...",
target.pbThis(true)))
                @battle.triggerImmunityDialogue(user, target, false)
            end
            return true
        end
        return false
    end

    def airborneImmunity?(user, target, move, showMessages = true)
        # Airborne-based immunity to Ground moves
        if move.damagingMove? && move.calcType == :GROUND && target.airborne? && !move.hitsFlyingTargets?
            levitationAbility = target.hasLevitate?
            if levitationAbility && !@battle.moldBreaker
                if showMessages
                    @battle.pbShowAbilitySplash(target, levitationAbility)
                    @battle.pbDisplay(_INTL("{1} avoided the attack!", target.pbThis))
                    @battle.pbHideAbilitySplash(target)
                    @battle.triggerImmunityDialogue(user, target, true)
                end
                return true
            end
            LEVITATION_ITEMS.each do |levitationItem|
                if target.hasActiveItem?(levitationItem)
                    if showMessages
                        @battle.pbDisplay(_INTL("{1}'s {2} makes Ground moves miss!", target.pbThis, getItemName(levitationItem)))
                        @battle.triggerImmunityDialogue(user, target, false)
                    end
                    return true
                end
            end
            if target.effectActive?(:MagnetRise)
                if showMessages
                    @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Magnet Rise!", target.pbThis))
                    @battle.triggerImmunityDialogue(user, target, false)
                end
                return true
            end
            if target.effectActive?(:Telekinesis)
                if showMessages
                    @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Telekinesis!", target.pbThis))
                    @battle.triggerImmunityDialogue(user, target, false)
                end
                return true
            end
        end
        return false
    end

    #=============================================================================
    # Per-hit success check against the target.
    # Includes semi-invulnerable move use and accuracy calculation.
    #=============================================================================
    def pbSuccessCheckPerHit(move, user, target, skipAccuracyCheck)
        # Two-turn attacks can't fail here in the charging turn
        return true if user.effectActive?(:TwoTurnAttack)
        # Lock-On
        return true if user.effectActive?(:LockOn) && user.effects[:LockOnPos] == target.index
        # Toxic
        return true if move.pbOverrideSuccessCheckPerHit(user, target)
        miss = false
        hitsInvul = false
        # No Guard
        hitsInvul = true if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
        # Future Sight
        hitsInvul = true if @battle.futureSight
        # Helping Hand
        hitsInvul = true if move.hitsInvulnerable?
        unless hitsInvul
            # Semi-invulnerable moves
            if target.effectActive?(:TwoTurnAttack)
                if target.inTwoTurnAttack?("0C9", "0CC", "0CE") # Fly, Bounce, Sky Drop
                    miss = true unless move.hitsFlyingTargets?
                elsif target.inTwoTurnAttack?("0CA")            # Dig
                    miss = true unless move.hitsDiggingTargets?
                elsif target.inTwoTurnAttack?("0CB")            # Dive
                    miss = true unless move.hitsDivingTargets?
                elsif target.inTwoTurnAttack?("0CD", "14D", "5C5") # Shadow Force, Phantom Force
                    miss = true
                end
            end
            if target.effectActive?(:SkyDrop) && target.effects[:SkyDrop] != user.index && !move.hitsFlyingTargets?
                miss = true
            end
        end
        unless miss
            # Called by another move
            return true if skipAccuracyCheck
            # Accuracy check
            return true if move.pbAccuracyCheck(user, target) # Includes Counter/Mirror Coat
        end
        # Missed
        PBDebug.log("[Move failed] Failed pbAccuracyCheck or target is semi-invulnerable")
        return false
    end

    #=============================================================================
    # Message shown when a move fails the per-hit success check above.
    #=============================================================================
    def pbMissMessage(move, user, target)
        if move.pbTarget(user).num_targets > 1
            @battle.pbDisplay(_INTL("{1} avoided the attack!", target.pbThis))
        elsif target.effectActive?(:TwoTurnAttack)
            @battle.pbDisplay(_INTL("{1} avoided the attack!", target.pbThis))
        elsif !move.pbMissMessage(user, target)
            @battle.pbDisplay(_INTL("{1}'s attack missed!", user.pbThis))
        end
    end
end
