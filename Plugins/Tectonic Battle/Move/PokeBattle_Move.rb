RAIN_DEBUFF_ACTIVE = true
SUN_DEBUFF_ACTIVE = true

class PokeBattle_Move
    attr_reader   :battle
    attr_reader   :realMove
    attr_accessor :id
    attr_reader   :name
    attr_reader   :function
    attr_reader   :baseDamage
    attr_reader   :type
    attr_reader   :category
    attr_reader   :accuracy
    attr_accessor :pp
    attr_writer   :total_pp
    attr_reader   :effectChance
    attr_reader   :target
    attr_reader   :priority
    attr_reader   :flags
    attr_accessor :calcType
    attr_accessor :powerBoost
    attr_accessor :snatched
    attr_accessor :calculated_category
  
    def to_int; return @id; end
  
    #=============================================================================
    # Creating a move
    #=============================================================================
    def initialize(battle, move)
      @battle     = battle
      @realMove   = move
      @id         = move.id
      @name       = move.name   # Get the move's name
      # Get data on the move
      @function   = move.function_code
      @baseDamage = move.base_damage
      @type       = move.type
      @category   = move.category
      @calculated_category = -1 # By default, won't overwrite @category
      @accuracy   = move.accuracy
      @pp         = move.pp   # Can be changed with Mimic/Transform
      @effectChance = move.effect_chance
      @target     = move.target
      @priority   = move.priority
      @flags      = move.flags
      @calcType   = nil
      @powerBoost = false   # For Aerilate, Pixilate, Refrigerate, Galvanize
      @snatched   = false
    end
  
    # This is the code actually used to generate a PokeBattle_Move object. The
    # object generated is a subclass of this one which depends on the move's
    # function code (found in the script section PokeBattle_MoveEffect).
    def PokeBattle_Move.from_pokemon_move(battle, move)
      validate move => Pokemon::Move
      moveFunction = move.function_code || "000"
      className = sprintf("PokeBattle_Move_%s", moveFunction)
      if Object.const_defined?(className)
        begin
          return Object.const_get(className).new(battle, move)
        rescue StandardError
          puts "Error while trying to create a move of class #{className}"
        end
      end
      return PokeBattle_UnimplementedMove.new(battle, move)
    end
  
    #=============================================================================
    # About the move
    #=============================================================================
    def pbTarget(user)
        targetData = GameData::Target.get(@target)
        if damagingMove? && targetData.can_target_one_foe? && user.effectActive?(:FlareWitch)
          return GameData::Target.get(:AllNearFoes)
        else
          return targetData
        end
    end
  
    def total_pp
      return @total_pp if @total_pp && @total_pp>0   # Usually undefined
      return @realMove.total_pp if @realMove
      return 0
    end
  
    # NOTE: This method is only ever called while using a move (and also by the
    #       AI), so using @calcType here is acceptable.
    def physicalMove?(thisType=nil)
      return true if @calculated_category == 0
      return true if @category == 0
      return false
    end
  
    def specialMove?(thisType=nil)
      return true if @calculated_category == 1
      return true if @category == 1
      return false
    end

    def calculatedCategory
      return @calculated_category if @calculated_category != -1
      return @category
    end
  
    def damagingMove?(aiChecking = false); return @category != 2; end
    def statusMove?;   return @category == 2; end
  
    def usableWhenAsleep?;       return false; end
    def unusableInGravity?;      return false; end
    def healingMove?;            return false; end
    def recoilMove?;             return false; end
    def flinchingMove?;          return false; end
    def callsAnotherMove?;       return false; end
    # Whether the move can/will hit more than once in the same turn (including
    # Beat Up which may instead hit just once). Not the same as pbNumHits>1.
    def multiHitMove?;           return false; end
    def chargingTurnMove?;       return false; end
    def successCheckPerHit?;     return false; end
    def hitsFlyingTargets?;      return false; end
    def hitsDiggingTargets?;     return false; end
    def hitsDivingTargets?;      return false; end
    def ignoresReflect?;         return false; end   # For Brick Break
    def cannotRedirect?;         return false; end   # For Future Sight/Doom Desire
    def worksWithNoTargets?;     return false; end   # For Explosion
    def damageReducedByBurn?;    return true;  end   # For Facade
    def triggersHyperMode?;      return false; end
    def immuneToRainDebuff?;     return false; end
    def immuneToSunDebuff?;      return false; end
    def setsARoom?;              return false; end

    def canProtectAgainst?;     return @flags[/b/]; end
    def canMagicCoat?;          return @flags[/c/]; end
    def canSnatch?;             return @flags[/d/]; end
    def canMirrorMove?;         return @flags[/e/]; end
    def canKingsRock?;          return @flags[/f/]; end
    def thawsUser?;             return @flags[/g/]; end
    def highCriticalRate?;      return @flags[/h/]; end
    def bitingMove?;            return @flags[/i/]; end
    def punchingMove?;          return @flags[/j/]; end
    def soundMove?;             return @flags[/k/]; end
    def powderMove?;            return @flags[/l/]; end
    def pulseMove?;             return @flags[/m/]; end
    def bombMove?;              return @flags[/n/]; end
    def danceMove?;             return @flags[/o/]; end
    def bladeMove?;             return @flags[/p/]; end
    def windMove?;              return @flags[/q/]; end
    def veryHighCriticalRate?;  return @flags[/r/]; end
    def empoweredMove?;         return @flags[/y/]; end

    def turnsBetweenUses(); return 0; end
    def aiAutoKnows?(pokemon); return false; end
    def statUp; return []; end
  
    def nonLethal?(user,_target); return false; end   # For False Swipe
    def switchOutMove?; return false; end
    def forceSwitchMove?; return false; end
    def hazardMove?; return false; end
    def statStepStealingMove?; return false; end
  
    def ignoresSubstitute?(user)   # user is the Pokémon using this move
      return true if soundMove?
      return true if user && user.hasActiveAbility?(:INFILTRATOR)
      return true if user && user.hasActiveAbility?(:CLEAVING)
      return false
    end

    def hitsInvulnerable?; return false; end

    def randomEffect?
      return @effectChance > 0 && @effectChance < 100
    end

    def guaranteedEffect?
      return @effectChance >= 100
    end
  end
  