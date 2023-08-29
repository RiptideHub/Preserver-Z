def sharpenAlloyedLump?
    pbMessage(_INTL("A smooth but tough metallic surface."))
    if pbHasItem?(:ALLOYEDLUMP)
        if pbConfirmMessage(_INTL("Use it to sharpen an alloyed lump?"))
            pbMessage(_INTL("You sharpen the alloyed lump, transforming it into a useful tool!"))
            pbDeleteItem(:ALLOYEDLUMP)
            pbReceiveItem(:ALLOYEDBLADE)
            return true
        else
            pbMessage(_INTL("You decide to do nothing with the strange surface."))
            return false
        end
    else
        pbMessage(_INTL("It'd be good at sharpening other metal."))
        return false
    end
end

def cutDownAlloyedSapling?
    pbMessage(_INTL("A metal sapling. It appears rather tough."))
    if pbHasItem?(:ALLOYEDBLADE)
        if pbConfirmMessage(_INTL("Use an alloyed blade to chop it down?"))
            pbMessage(_INTL("You take a swing at the sapling!"))
            pbDeleteItem(:ALLOYEDBLADE)
            return true
        else
            pbMessage(_INTL("You decide to leave the sapling alone."))
            return false
        end
    else
        pbMessage(_INTL("You'd need a tool made of a strong material to cut it."))
        return false
    end
end

def cutAlloyedVines
    pbMessage(_INTL("Strands of a strangely tough metal hang from the wall."))
    if pbConfirmMessage(_INTL("Harvest the metallic vines?"))
        pbMessage(_INTL("You slash through the metallic vines!"))
        pbSEPlay('Cut') # Other SE
        setMySwitch('A')
        pbWait(40)
        pbReceiveItem(:ALLOYEDWIRE)
    else
        pbMessage(_INTL("You leave the strands alone."))
    end
end

def strikeAlloyedBell?
    pbMessage(_INTL("A metal plant with a golden orb. You feel the urge to strike it."))
    if pbConfirmMessage(_INTL("Hit the golden orb?"))
        pbMessage(_INTL("With your strike, a noise emanates through the thicket!"))
        pbSEPlay('Anim/PRSFX- Heal Order2',120,70)
        pbWait(80)
        return true
    else
        pbMessage(_INTL("You refrain from striking the orb."))
        return false
    end
end

def cutDownAlloyedTree(eventID)
    pbMessage(_INTL("A tall metal tree. One side has been notched by something sharp."))
    if pbHasItem?(:ALLOYEDBLADE)
        if pbConfirmMessage(_INTL("Finish chopping it down?"))
            pbMessage(_INTL("You take a swing at the tree with an alloyed blade."))
            pbSEPlay('Cut') # Other SE
            pbWait(20)
            blackFadeOutIn {
                setMySwitch('A')
                pbSetSelfSwitch(eventID, 'A')
            }
            pbDeleteItem(:ALLOYEDBLADE)
            pbMessage(_INTL("The alloyed blade crumbles into pieces."))
        else
            pbMessage(_INTL("You refrain from chopping the tree."))
        end
    else
        pbMessage(_INTL("You could probably cut it down, with the right tool."))
    end
end

def placeAlloyedTripWire
    pbMessage(_INTL("A pair of metal posts are stuck into the ground."))
    if pbHasItem?(:ALLOYEDWIRE)
        if pbConfirmMessage(_INTL("String an alloyed wire between the posts?"))
            pbMessage(_INTL("You place a trip wire!"))
            setMySwitch('A')
            pbDeleteItem(:ALLOYEDWIRE)
        else
            pbMessage(_INTL("You leave the posts alone."))
        end
    else
        pbMessage(_INTL("It'd be a good place to set a trip wire."))
    end
end

def fadeFlee(switchName = 'A')
    blackFadeOutIn {
        pbSEPlay('Battle flee')
        setMySwitch(switchName)
    }
end

def playMetallicGrinding
    pbSEPlay('Anim/PRSFX- Gear Grind',120,60)
end