class PokemonPartyShowcase_Scene
    POKEMON_ICON_SIZE = 64
    BASE_COLOR   = Color.new(80, 80, 88)
    SHADOW_COLOR = Color.new(160, 160, 168)

    def initialize(party,snapshot = false,snapShotName=nil)
        @sprites = {}
        @party = party
        @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
        @viewport.z = 99999

        backgroundFileName = "Party/showcase_bg"
        backgroundFileName += "_postgame" if $game_switches[68]
        addBackgroundPlane(@sprites, "bg", backgroundFileName, @viewport)

        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        @overlay = @sprites["overlay"].bitmap
        pbSetSmallFont(@overlay)

        # Add party Pokémon sprites
        for i in 0...Settings::MAX_PARTY_SIZE
            next unless @party[i]
            renderShowcaseInfo(i,@party[i])
        end

        # Draw tribal bonus info at the bottom
        playerTribalBonus().updateTribeCount
        fullDescription = ""
        $Trainer.tribalBonus.getActiveBonusesList(false).each_with_index do |label,index|
            fullDescription += "," unless index == 0
            fullDescription += label
        end
        if fullDescription.blank?
            fullDescription = "No Tribal Bonuses"
        else
            fullDescription = "Tribes: " + fullDescription
        end
        drawFormattedTextEx(@overlay, 8, Graphics.height - 20, Graphics.width, fullDescription, BASE_COLOR, SHADOW_COLOR)

        # Show player name
        playerName = "<ar>#{$Trainer.name}</ar>"
        drawFormattedTextEx(@overlay, Graphics.width - 168, Graphics.height - 20, 160, playerName, BASE_COLOR, SHADOW_COLOR)

        # Show player name
        settingsLabel = "v#{Settings::GAME_VERSION}"
        drawFormattedTextEx(@overlay, Graphics.width / 2 + 64, Graphics.height - 20, 160, settingsLabel, BASE_COLOR, SHADOW_COLOR)

        pbFadeInAndShow(@sprites) { pbUpdate }

        pbScreenCapture(snapShotName) if snapshot

        loop do
            Graphics.update
            Input.update
            pbUpdate
            if Input.trigger?(Input::BACK)
                pbEndScene
                pbPlayCloseMenuSE
                return
            end
        end
    end

    def renderShowcaseInfo(index,pokemon)
        displayX =  ((index % 2) * (Graphics.width / 2)) + 6
        displayY = (index / 2) * (Graphics.height / 3 - 8) + 6

        mainIconY = displayY + 20
        newPokemonIcon = PokemonIconSprite.new(pokemon,@viewport)
        newPokemonIcon.x = displayX
        newPokemonIcon.y = mainIconY
        @sprites["pokemon#{index}"] = newPokemonIcon

        # Display pokemon name
        nameAndLevel = pokemon.name + " Lv. " + pokemon.level.to_s
        drawTextEx(@overlay, displayX + 14, displayY, 200, 1, nameAndLevel, BASE_COLOR, SHADOW_COLOR)

        # Display item icon
        if pokemon.hasItem?
            pixelsBetweenItems = 20
            itemX = displayX + POKEMON_ICON_SIZE - 8 - pixelsBetweenItems * (pokemon.items.length - 1)
            itemY = mainIconY + POKEMON_ICON_SIZE - 8
            pokemon.items.each_with_index do |item, itemIndex|
                newItemIcon = ItemIconSprite.new(itemX,itemY,item,@viewport)
                newItemIcon.zoom_x = 0.5
                newItemIcon.zoom_y = 0.5
                newItemIcon.type = pokemon.itemTypeChosen
                @sprites["item_#{index}_#{itemIndex}"] = newItemIcon

                itemX += pixelsBetweenItems
            end
        end

        # Display ball caught in icon
        newItemIcon = ItemIconSprite.new(displayX + 200,mainIconY + POKEMON_ICON_SIZE + 16,pokemon.poke_ball,@viewport)
        newItemIcon.zoom_x = 0.5
        newItemIcon.zoom_y = 0.5
        @sprites["ball_#{index}"] = newItemIcon

        # Display gender
        #genderX = displayX + 2
        #genderY = itemY - 6
        genderX = displayX + 196
        genderY = displayY
        if pokemon.male?
            drawTextEx(@overlay, genderX, genderY, 80, 1, _INTL("♂"), Color.new(0,112,248), Color.new(120,184,232))
        elsif pokemon.female?
            drawTextEx(@overlay, genderX, genderY, 80, 1, _INTL("♀"), Color.new(232,32,16), Color.new(248,168,184))
        end

        # Draw shiny icon
        if pokemon.shiny?
            shinyIconFileName = pokemon.shiny_variant? ? "Graphics/Pictures/shiny_variant" : "Graphics/Pictures/shiny"
            pbDrawImagePositions(@overlay,[[shinyIconFileName,displayX,mainIconY,0,0,16,16]])
        end

        # Display moves
        pokemon.moves.each_with_index do |pokemonMove,moveIndex|
            moveName = GameData::Move.get(pokemonMove.id).real_name
            drawTextEx(@overlay, displayX + POKEMON_ICON_SIZE + 8, mainIconY + 2 + moveIndex * 16, 200, 1, moveName, BASE_COLOR, SHADOW_COLOR)
        end

        # Display ability name
        abilityName = pokemon.ability&.real_name || "No Ability"
        drawTextEx(@overlay, displayX + 4, mainIconY + POKEMON_ICON_SIZE + 8, 200, 1, abilityName, BASE_COLOR, SHADOW_COLOR)
    
        # Display Style Points
        styleValueX = displayX + 222
        styleHash = pokemon.ev
        styleValues = [styleHash[:HP],styleHash[:ATTACK],styleHash[:DEFENSE],styleHash[:SPECIAL_ATTACK],styleHash[:SPECIAL_DEFENSE],styleHash[:SPEED]]
        styleValues.each_with_index do |styleValue,styleIndex|
            #styleOpacity = (0.5 + styleValue / 40.0) * 255
            thisColor = BASE_COLOR.clone
            thisColor.alpha = 120 if styleValue == 0
            thisShadow = SHADOW_COLOR.clone
            thisShadow.alpha = 120 if styleValue == 0
            drawTextEx(@overlay, styleValueX, 2 + displayY + 18 * styleIndex, 80, 1, styleValue.to_s, thisColor, thisShadow)
        end
    end

    # End the scene here
    def pbEndScene
        pbFadeOutAndHide(@sprites) { pbUpdate }
        pbDisposeSpriteHash(@sprites)
        # DISPOSE OF BITMAPS HERE #
    end

    def pbUpdate
        pbUpdateSpriteHash(@sprites)
    end
end