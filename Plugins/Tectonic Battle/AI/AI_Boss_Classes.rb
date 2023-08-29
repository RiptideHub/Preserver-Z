##################################################
# Legendary Beasts
##################################################
class PokeBattle_AI_Entei < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:INCINERATE, {
            :condition => proc { |_move, _user, target, _battle|
                next target.hasAnyBerry? || target.hasAnyGem?
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} notices a flammable item amongst your Pokémon!")
            },
        })
    end
end

class PokeBattle_AI_Suicune < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:PURIFYINGWATER, {
            :condition => proc { |_move, user, _target, _battle|
                next user.pbHasAnyStatus?
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} inspects it's status conditions.")
            },
        })
    end
end

class PokeBattle_AI_Raikou < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:LIGHTNINGSHRIEK, {
            :condition => proc { |_move, user, _target, _battle|
                next user.steps[:SPEED] < 2
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} opens its mouth up wide!")
            },
        })
    end
end

##################################################
# Swords of Justice
##################################################
class PokeBattle_AI_Keldeo < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        rejectPoisonMovesIfBelched
    end
end

class PokeBattle_AI_Cobalion < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:NOBLEROAR)
    end
end

##################################################
# Weather Trio
##################################################
class PokeBattle_AI_Groudon < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @wholeRound += %i[ERUPTION PRECIPICEBLADES WARPINGCORE]

        @warnedIFFMove.add(:ERUPTION, {
            :condition => proc { |_move, _user, _target, battle|
                next battle.turnCount == 0
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} is gathering energy for a massive attack!")
            },
        })

        @warnedIFFMove.add(:PRECIPICEBLADES, {
            :condition => proc { |_move, _user, _target, battle|
                next battle.turnCount % 3 == 0
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} is gathering energy for an attack!")
            },
        })

        @warnedIFFMove.add(:WARPINGCORE, {
            :condition => proc { |_move, user, _target, _battle|
                next true
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("You feel the ground begin to bend towards #{user.pbThis(true)}.")
            },
        })
    end
end

class PokeBattle_AI_Kyogre < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @wholeRound += %i[WATERSPOUT ORIGINPULSE SEVENSEASEDICT]

        @warnedIFFMove.add(:WATERSPOUT, {
            :condition => proc { |_move, _user, _target, battle|
                next battle.turnCount == 0
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} is gathering energy for a massive attack!")
            },
        })

        @warnedIFFMove.add(:ORIGINPULSE, {
            :condition => proc { |_move, _user, _target, battle|
                next battle.turnCount % 3 == 0
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} is gathering energy for an attack!")
            },
        })

        @warnedIFFMove.add(:SEVENSEASEDICT, {
            :condition => proc { |_move, _user, _target, battle|
                next true
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("An air of authority surrounds #{user.pbThis(true)}.")
            },
        })
    end
end

class PokeBattle_AI_Rayquaza < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @beginBattle.push(proc { |user, _battle|
            user.battle.pbMegaEvolve(user.index)
        })

        @wholeRound += %i[STRATOSPHERESCREAM]

        @warnedIFFMove.add(:DRAGONASCENT, {
            :condition => proc { |_move, _user, _target, battle|
                next battle.turnCount == 0
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} looks to the Ozone Layer above!")
            },
        })

        @warnedIFFMove.add(:STRATOSPHERESCREAM, {
            :condition => proc { |_move, _user, _target, battle|
                next battle.turnCount > 0 && battle.turnCount % 3 == 0
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis}'s rage is at at its peak!")
            },
        })
    end
end

##################################################
# Chamber Avatars
##################################################
class PokeBattle_AI_Meloetta < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @useMoveIFF.add(:RELICSONG, proc { |_move, user, _target, battle|
            next battle.turnCount % 2 == 1 && user.lastTurnThisRound?
        })
        @rejectMovesIf.push( proc { |move, user, _target, battle|
            if user.form == 0
                next true if %i[DOUBLEHIT CAPOEIRA].include?(move.id)
            else
                next true if %i[PSYBEAM ROUND].include?(move.id)
            end
            next false
        }
        )
    end
end

class PokeBattle_AI_Xerneas < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @useMoveIFF.add(:GEOMANCY, proc { |_move, user, _target, battle|
            next battle.turnCount == 0 && user.lastTurnThisRound?
        })
    end
end

class PokeBattle_AI_Deoxys < PokeBattle_AI_Boss
    ATTACK_FORM_MOVESET = %i[PSYCHOBOOST INFINITEFORCE]
    DEFENSE_FORM_MOVESET = %i[COSMICPOWER RECOVER]
    SPEED_FORM_MOVESET = %i[ZENHEADBUTT ELECTROBALL]

    def initialize(user, battle)
        super
        @beginTurn.push(proc { |user, _battle, turnCount|
            if turnCount != 0
                if user.hp < user.totalhp * 0.25
                    if user.form != 1
                        formChangeMessage = _INTL("The avatar of Deoxys turns to Attack Form!")
                        user.pbChangeForm(1, formChangeMessage)
                        user.assignMoveset(ATTACK_FORM_MOVESET)
                    end
                elsif user.hp < user.totalhp * 0.5
                    if user.form != 2
                        formChangeMessage = _INTL("The avatar of Deoxys turns to Defense Form!")
                        user.pbChangeForm(2, formChangeMessage)
                        user.assignMoveset(DEFENSE_FORM_MOVESET)
                    end
                elsif user.hp < user.totalhp * 0.75
                    if user.form != 3
                        formChangeMessage = _INTL("The avatar of Deoxys turns to Speed Form!")
                        user.pbChangeForm(3, formChangeMessage)
                        user.assignMoveset(SPEED_FORM_MOVESET)
                    end
                end
            end
        })
    end
end

##################################################
# Other Legends
##################################################
class PokeBattle_AI_Genesect < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:FELLSTINGER, {
            :condition => proc { |move, user, target, _battle|
                ai = user.battle.battleAI
                next ai.getDamagePercentageAI(move, user, target, 100) >= 100
            },
            :warning => proc { |_move, user, targets, _battle|
                target = targets[0]
                _INTL("#{user.pbThis} aims its stinger at #{target.pbThis(true)}!")
            },
        })

        @wholeRound.push(:FELLSTINGER)

        @beginBattle.push(proc { |user, battle|
            battle.pbDisplayBossNarration(_INTL("The avatar of Genesect is analyzing your whole team for weaknesses..."))
            weakToElectric	= 0
            weakToFire	= 0
            weakToIce	= 0
            weakToWater	= 0
            maxValue = 0

            $Trainer.party.each do |b|
                next unless b
                type1 = b.type1
                type2 = b.type2
                weakToElectric += 1 if Effectiveness.super_effective?(Effectiveness.calculate(:ELECTRIC, type1,
type2))
                maxValue = weakToElectric if weakToElectric > maxValue
                weakToFire += 1 if Effectiveness.super_effective?(Effectiveness.calculate(:FIRE, type1, type2))
                maxValue = weakToFire if weakToFire > maxValue
                weakToIce += 1 if Effectiveness.super_effective?(Effectiveness.calculate(:ICE, type1, type2))
                maxValue = weakToIce if weakToIce > maxValue
                weakToWater += 1 if Effectiveness.super_effective?(Effectiveness.calculate(:WATER, type1, type2))
                maxValue = weakToWater if weakToWater > maxValue
            end

            chosenItem = nil
            if maxValue > 0
                results = { SHOCKDRIVE: weakToElectric, BURNDRIVE: weakToFire, CHILLDRIVE: weakToIce,
DOUSEDRIVE: weakToWater, }
                results = results.sort_by { |_k, v| v }.to_h
                results.delete_if { |_k, v| v < maxValue }
                chosenItem = results.keys.sample
            end

            if !chosenItem
                battle.pbDisplayBossNarration(_INTL("#{user.pbThis} can't find any!"))
            else
                battle.pbDisplayBossNarration(_INTL("#{user.pbThis} loads a {1}!",
GameData::Item.get(chosenItem).real_name))
                user.giveItem(chosenItem)
            end
        })
    end
end

class PokeBattle_AI_Cresselia < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @beginTurn.push(proc { |user, battle, turnsunt|
            if turnCount == 4
                battle.pbDisplayBossNarration(_INTL("A Shadow creeps into the dream..."))
                battle.summonAvatarBattler(:DARKRAI, user.level)
            end
        })
    end
end

##################################################
# Route Avatars
##################################################

class PokeBattle_AI_Donster < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        rejectPoisonMovesIfBelched
    end
end

class PokeBattle_AI_Deceat < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        prioritizeFling
    end
end

class PokeBattle_AI_Gourgeist < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:TRICKORTREAT)
        secondMoveEveryTurn(:YAWN)
    end
end

class PokeBattle_AI_Zoroark < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:VENOMDRENCH)
    end
end


class PokeBattle_AI_Electrode < PokeBattle_AI_Boss
    TURNS_TO_EXPLODE = 3

    def initialize(user, battle)
        super
        @warnedIFFMove.add(:EXPLOSION, {
            :condition => proc { |_move, _user, _target, battle|
                next battle.turnCount >= TURNS_TO_EXPLODE
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} is fully charged. Its about to explode!")
            },
        })

        @beginTurn.push(proc { |user, battle, _turnCount|
            turnsRemaining = TURNS_TO_EXPLODE - battle.turnCount
            if turnsRemaining > 0
                battle.pbDisplayBossNarration(_INTL("#{user.pbThis} is charging up."))
                battle.pbDisplayBossNarration(_INTL("#{turnsRemaining} turns remain!"))
            end
        })

        @dangerMoves.push(:EXPLOSION)
        @wholeRound.push(:EXPLOSION)
    end
end

class PokeBattle_AI_Incineroar < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @lastTurnOnly += %i[SWAGGER TAUNT]
    end
end

class PokeBattle_AI_Linoone < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:COVET, {
            :condition => proc { |_move, user, target, _battle|
                next target.hasAnyItem?
            },
            :warning => proc { |_move, user, targets, _battle|
                target = targets[0]
                _INTL("#{user.pbThis} eyes #{target.pbThis(true)}'s #{target.itemCountD} with jealousy!")
            },
        })
    end
end

class PokeBattle_AI_Parasect < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:SPORE, {
            :condition => proc { |_move, user, _target, _battle|
                anyAsleep = false
                user.battle.battlers.each do |b|
                    next if !b || !user.opposes?(b)
                    anyAsleep = true if b.asleep?
                end
                next !anyAsleep
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis}'s shroom stalks perk up!")
            },
        })
    end
end

class PokeBattle_AI_Magnezone < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @useMoveIFF.add(:ZAPCANNON, proc { |_move, user, target, _battle|
            next user.battle.commandPhasesThisRound == 0 && user.pointsAt?(:LockOnPos, target)
        })

        @lastTurnOnly.push(:LOCKON)
    end
end

class PokeBattle_AI_Porygonz < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @firstTurnOnly += %i[CONVERSION CONVERSION2]
    end
end

class PokeBattle_AI_Greedent < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @nonFirstTurnOnly += [:STOCKPILE]
        @fallback.push(:STOCKPILE)

        @lastUsedMove = :SWALLOW
        @decidedOnMove[:SWALLOW] = proc { |_move, _user, _targets, _battle|
            @lastUsedMove = :SWALLOW
        }
        @decidedOnMove[:SPITUP] = proc { |_move, _user, _targets, _battle|
            @lastUsedMove = :SPITUP
        }

        @useMoveIFF.add(:SPITUP, proc { |_move, user, _target, _battle|
            next @lastUsedMove == :SWALLOW && user.firstTurnThisRound? &&
                user.countEffect(:Stockpile) >= 2 && user.empoweredTimer < 3
        })

        @useMoveIFF.add(:SWALLOW, proc { |_move, user, _target, _battle|
            next @lastUsedMove == :SPITUP && user.firstTurnThisRound? &&
                user.countEffect(:Stockpile) >= 2 && user.empoweredTimer < 3
        })
    end
end

class PokeBattle_AI_Wailord < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:SELFDESTRUCT, {
            :condition => proc { |_move, _user, _target, _battle|
                next true
            },
            :warning => proc { |_move, user, _targets, _battle|
                _INTL("#{user.pbThis} is flying erratically. It looks unstable!")
            },
        })

        @wholeRound.push(:SELFDESTRUCT)
        @dangerMoves.push(:SELFDESTRUCT)
    end
end

class PokeBattle_AI_Sawsbuck < PokeBattle_AI_Boss
    FORM_0_MOVESET = %i[PLAYROUGH SEASONSEND]
    FORM_1_MOVESET = %i[HORNDRAIN SEASONSEND]
    FORM_2_MOVESET = %i[TRAMPLE SEASONSEND]
    FORM_3_MOVESET = %i[CRYSTALCRUSH SEASONSEND]
    MOVESETS = [FORM_0_MOVESET,FORM_1_MOVESET,FORM_2_MOVESET,FORM_3_MOVESET]

    def initialize(user, battle)
        super
        secondMoveEveryOtherTurn(:SEASONSEND)
        @beginTurn.push(proc { |user, _battle, turnCount|
            # Make sure it has the right moveset for its form
            newMoveset = MOVESETS[user.form].clone
            newMoveset.push(:PRIMEVALGROWL) if user.avatarPhase == 1
            user.assignMoveset(newMoveset)
        })
    end
end

class PokeBattle_AI_Rotom < PokeBattle_AI_Boss
    FORM_1_MOVESET = %i[HEATWAVE DISCHARGE]
    FORM_2_MOVESET = %i[SURF DISCHARGE]
    FORM_3_MOVESET = %i[FROSTBREATH THUNDERBOLT]
    FORM_4_MOVESET = %i[AIRSLASH THUNDERBOLT]
    FORM_5_MOVESET = %i[PETALTEMPEST DISCHARGE]
    MOVESETS = [FORM_1_MOVESET,FORM_2_MOVESET,FORM_3_MOVESET,FORM_4_MOVESET,FORM_5_MOVESET]

    def initialize(user, battle)
        super
        @beginTurn.push(proc { |user, _battle, turnCount|
            if turnCount != 0 && turnCount % 2 == 1
                newForm = user.form + 1
                newForm = 1 if newForm > 5
                formChangeMessage = _INTL("The avatar swaps machines!")
                user.pbChangeForm(newForm, formChangeMessage)
                newMoveset = MOVESETS[newForm-1].clone
                newMoveset.push(:PRIMEVALDAZZLE) if user.avatarPhase == 1
                user.assignMoveset(newMoveset)
            end
        })
    end
end

class PokeBattle_AI_Sunflora < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryOtherTurn(:GROWTH)
    end
end

class PokeBattle_AI_Honchkrow < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:SCHEME)
    end
end

class PokeBattle_AI_Togekiss < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryOtherTurn(:TAKESHELTER)
    end
end

class PokeBattle_AI_Crobat < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:ECHOLOCATE)
    end
end

class PokeBattle_AI_Slurpuff < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:AROMATICMIST)
    end
end

class PokeBattle_AI_Donster < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:TRASHTREASURE)
    end
end

class PokeBattle_AI_Rapidash < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:IGNITE, {
            :condition => proc { |_move, user, target, _battle|
                next target.pbAttack(true) > target.pbSpAtk(true)
            },
            :warning => proc { |_move, user, targets, _battle|
                _INTL("#{user.pbThis} aims to burn #{targets[0].pbThis(true)}!")
            },
        })
    end
end

class PokeBattle_AI_Rubarior < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:CURSE, {
            :condition => proc { |_move, user, target, _battle|
                next target.hasRaisedStatSteps?
            },
            :warning => proc { |_move, user, targets, _battle|
                _INTL("#{user.pbThis} is jealous of #{targets[0]}'s good fortune!")
            },
        })
    end
end

class PokeBattle_AI_Boldore < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:SUNSHINE, {
            :condition => proc { |_move, _user, _target, battle|
                next !battle.sunny?
            },
            :warning => proc { |_move, user, targets, _battle|
                _INTL("#{user.pbThis} shuns the cave's darkness!")
            },
        })
    end
end

class PokeBattle_AI_Maractus < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:SANDSTORM, {
            :condition => proc { |_move, _user, _target, battle|
                next battle.pbWeather != :Sandstorm
            },
            :warning => proc { |_move, user, targets, _battle|
                _INTL("#{user.pbThis} is feeling exposed!")
            },
        })
        secondMoveEveryTurn(:LEECHSEED)
    end
end

class PokeBattle_AI_Watchog < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:GLARE)

        @warnedIFFMove.add(:FLATTER, {
            :condition => proc { |_move, _user, target, battle|
                next target.fullHealth?
            },
            :warning => proc { |_move, user, targets, _battle|
                _INTL("#{user.pbThis} is looking to butter up #{targets[0].pbThis(true)}!")
            },
        })
    end
end

class PokeBattle_AI_Grimmsnarl < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:TEARFULLOOK)

        @warnedIFFMove.add(:SWAGGER, {
            :condition => proc { |_move, _user, target, battle|
                next target.fullHealth?
            },
            :warning => proc { |_move, user, targets, _battle|
                _INTL("#{user.pbThis} is studying #{targets[0].pbThis(true)}'s personality!")
            },
        })
    end
end

class PokeBattle_AI_Skarmory < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:FEATHERWARD)

        @warnedIFFMove.add(:WHIRLWIND, {
            :condition => proc { |_move, user, target, battle|
                next target.aboveHalfHealth? && user.turnCount % 2 == 1
            },
            :warning => proc { |_move, user, targets, _battle|
                _INTL("#{user.pbThis}'s wind whips in #{targets[0].pbThis(true)}'s direction!")
            },
        })
    end
end

class PokeBattle_AI_Ariados < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:TOXICTHREAD)
    end
end

class PokeBattle_AI_Archeops < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:METALSOUND)
    end
end

class PokeBattle_AI_Stonjourner < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:PRANK)
    end
end

class PokeBattle_AI_Gstunfisk < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:SHELLSHELTER)
    end
end

class PokeBattle_AI_Klang < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:METALSOUND)
    end
end

class PokeBattle_AI_Absolus < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:NOBLEROAR)
    end
end

class PokeBattle_AI_Eldegoss < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @useMoveIFF.add(:SWAGGER, proc { |_move, user, target, _battle|
            next target.pbAttack(true) > target.pbDefense(true)
        })
        @useMoveIFF.add(:FLATTER, proc { |_move, user, target, _battle|
            next target.pbSpAtk(true) > target.pbSpDef(true)
        })
    end
end

class PokeBattle_AI_Dubwool < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @firstTurnOnly.push(:SKULLBASH)
    end
end

class PokeBattle_AI_Claydol < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:REFLECT, {
            :condition => proc { |_move, user, _target, _battle|
                physicalAttacker = false
                user.lastFoeAttacker.each do |attacker|
                    next unless attacker.lastRoundMoveCategory == 0
                    physicalAttacker = true
                    break
                end
                next physicalAttacker
            },
            :warning => proc { |_move, user, targets, _battle|
                _INTL("#{user.pbThis} is molding its clay for physical defense!")
            },
        })

        @warnedIFFMove.add(:LIGHTSCREEN, {
            :condition => proc { |_move, user, _target, _battle|
                physicalAttacker = false
                user.lastFoeAttacker.each do |attacker|
                    next unless attacker.lastRoundMoveCategory == 1
                    physicalAttacker = true
                    break
                end
                next physicalAttacker
            },
            :warning => proc { |_move, user, targets, _battle|
                _INTL("#{user.pbThis} is molding its clay for special defense!")
            },
        })
    end
end

class PokeBattle_AI_Sensibelle < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:HEALPULSE)
    end
end

class PokeBattle_AI_Bronzong < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        
        @warnedIFFMove.add(:PACIFY, {
            :condition => proc { |_move, user, _target, _battle|
                next true
            },
            :warning => proc { |_move, user, targets, _battle|
                _INTL("#{user.pbThis} detects weakened mental defenses!")
            },
        })

        @warnedIFFMove.add(:CONFUSERAY, {
            :condition => proc { |_move, user, target, _battle|
                next !target.pbCanLowerStatStep?(:SPECIAL_DEFENSE,user)
            },
            :warning => proc { |_move, user, targets, _battle|
                _INTL("#{user.pbThis} aims to eliminate sound protection!")
            },
        })

        @warnedIFFMove.add(:METALSOUND, {
            :condition => proc { |_move, user, target, _battle|
                next target.steps[:SPECIAL_DEFENSE] >= 0
            },
            :warning => proc { |_move, user, targets, _battle|
                _INTL("#{user.pbThis} positions itself to make a terrible noise!")
            },
        })
    end
end

class PokeBattle_AI_Mimikyu < PokeBattle_AI_Boss
    def initialize(user, battle)
        super

        @warnedIFFMove.add(:SPOOKYSNUGGLING, {
            :condition => proc { |_move, user, target, _battle|
                next target.hasHealingMove?
            },
            :warning => proc { |_move, user, targets, _battle|
                _INTL("#{user.pbThis} wants a hug from someone healthy!")
            },
        })
    end
end

class PokeBattle_AI_Reavor < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:BUGBITE, {
            :condition => proc { |_move, _user, target, _battle|
                next target.hasAnyBerry? || target.hasAnyGem?
            },
            :warning => proc { |_move, user, targets, _battle|
                target = targets[0]
                _INTL("#{user.pbThis} locks onto #{target.pbThis(true)}'s item!")
            },
        })
    end
end

class PokeBattle_AI_Sudowoodo < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        @warnedIFFMove.add(:BUGBITE, {
            :condition => proc { |_move, _user, target, _battle|
                next target.lastRoundMoveCategory == 2
            },
            :warning => proc { |_move, user, targets, _battle|
                target = targets[0]
                _INTL("#{user.pbThis} is a big fan of #{target.pbThis(true)}'s last used move!")
            },
        })

        @warnedIFFMove.add(:STRENGTHSAP, {
            :condition => proc { |_move, _user, target, _battle|
                next target.steps[:ATTACK] > 1
            },
            :warning => proc { |_move, user, targets, _battle|
                target = targets[0]
                _INTL("#{user.pbThis} envies #{target.pbThis(true)}'s Attack!")
            },
        })
    end
end

class PokeBattle_AI_Slowking < PokeBattle_AI_Boss
    def initialize(user, battle)
        super
        secondMoveEveryTurn(:COSMICPOWER)
        secondMoveEveryTurn(:WORKUP)
    end
end