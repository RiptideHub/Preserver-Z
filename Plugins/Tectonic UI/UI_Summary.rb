#===============================================================================
#
#===============================================================================
class MoveSelectionSprite < SpriteWrapper
    attr_reader :preselected
    attr_reader :index

    def initialize(viewport = nil, fifthmove = false)
        super(viewport)
        @movesel = AnimatedBitmap.new("Graphics/Pictures/Summary/cursor_move")
        @frame = 0
        @index = 0
        @fifthmove = fifthmove
        @preselected = false
        @updating = false
        refresh
    end

    def dispose
        @movesel.dispose
        super
    end

    def index=(value)
        @index = value
        refresh
    end

    def preselected=(value)
        @preselected = value
        refresh
    end

    def refresh
        w = @movesel.width
        h = @movesel.height / 2
        self.x = 240
        self.y = 92 + (index * 64)
        self.y -= 76 if @fifthmove
        self.y += 20 if @fifthmove && index == Pokemon::MAX_MOVES # Add a gap
        self.bitmap = @movesel.bitmap
        if preselected
            src_rect.set(0, h, w, h)
        else
            src_rect.set(0, 0, w, h)
        end
    end

    def update
        @updating = true
        super
        @movesel.update
        @updating = false
        refresh
    end
end

#===============================================================================
#
#===============================================================================
class RibbonSelectionSprite < MoveSelectionSprite
    def initialize(viewport = nil)
        super(viewport)
        @movesel = AnimatedBitmap.new("Graphics/Pictures/Summary/cursor_ribbon")
        @frame = 0
        @index = 0
        @preselected = false
        @updating = false
        @spriteVisible = true
        refresh
    end

    def visible=(value)
        super
        @spriteVisible = value unless @updating
    end

    def refresh
        w = @movesel.width
        h = @movesel.height / 2
        self.x = 228 + (index % 4) * 68
        self.y = 76 + ((index / 4).floor * 68)
        self.bitmap = @movesel.bitmap
        if preselected
            src_rect.set(0, h, w, h)
        else
            src_rect.set(0, 0, w, h)
        end
    end

    def update
        @updating = true
        super
        self.visible = @spriteVisible && @index >= 0 && @index < 12
        @movesel.update
        @updating = false
        refresh
    end
end

#===============================================================================
#
#===============================================================================
class PokemonSummary_Scene
    def pbUpdate
        pbUpdateSpriteHash(@sprites)
    end

    def pbStartScene(party, partyindex, battle = nil)
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99_999
        @party      = party
        @partyindex = partyindex
        @pokemon    = @party[@partyindex]
        @battle     = battle
        @page = 1
        @forget = false
        @typebitmap    = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
        @markingbitmap = AnimatedBitmap.new("Graphics/Pictures/Summary/markings")
        @sprites = {}
        @sprites["background"] = IconSprite.new(0, 0, @viewport)
        @sprites["pokemon"] = PokemonSprite.new(@viewport)
        @sprites["pokemon"].setOffset(PictureOrigin::Center)
        @sprites["pokemon"].x = 104
        @sprites["pokemon"].y = 206
        @sprites["pokemon"].setPokemonBitmap(@pokemon)
        @sprites["pokeicon"] = PokemonIconSprite.new(@pokemon, @viewport)
        @sprites["pokeicon"].setOffset(PictureOrigin::Center)
        @sprites["pokeicon"].x       = 46
        @sprites["pokeicon"].y       = 92
        @sprites["pokeicon"].visible = false
        createItemIcons
        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        pbSetSystemFont(@sprites["overlay"].bitmap)
        @sprites["movepresel"] = MoveSelectionSprite.new(@viewport)
        @sprites["movepresel"].visible     = false
        @sprites["movepresel"].preselected = true
        @sprites["movesel"] = MoveSelectionSprite.new(@viewport)
        @sprites["movesel"].visible = false
        @sprites["ribbonpresel"] = RibbonSelectionSprite.new(@viewport)
        @sprites["ribbonpresel"].visible     = false
        @sprites["ribbonpresel"].preselected = true
        @sprites["ribbonsel"] = RibbonSelectionSprite.new(@viewport)
        @sprites["ribbonsel"].visible = false
        @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow", 8, 28, 40, 2, @viewport)
        @sprites["uparrow"].x = 350
        @sprites["uparrow"].y = 56
        @sprites["uparrow"].play
        @sprites["uparrow"].visible = false
        @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow", 8, 28, 40, 2, @viewport)
        @sprites["downarrow"].x = 350
        @sprites["downarrow"].y = 260
        @sprites["downarrow"].play
        @sprites["downarrow"].visible = false
        @sprites["markingbg"] = IconSprite.new(260, 88, @viewport)
        @sprites["markingbg"].setBitmap("Graphics/Pictures/Summary/overlay_marking")
        @sprites["markingbg"].visible = false
        @sprites["markingoverlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        @sprites["markingoverlay"].visible = false
        pbSetSystemFont(@sprites["markingoverlay"].bitmap)
        @sprites["markingsel"] = IconSprite.new(0, 0, @viewport)
        @sprites["markingsel"].setBitmap("Graphics/Pictures/Summary/cursor_marking")
        @sprites["markingsel"].src_rect.height = @sprites["markingsel"].bitmap.height / 2
        @sprites["markingsel"].visible = false
        @sprites["messagebox"] = Window_AdvancedTextPokemon.new("")
        @sprites["messagebox"].viewport       = @viewport
        @sprites["messagebox"].visible        = false
        @sprites["messagebox"].letterbyletter = true
        pbBottomLeftLines(@sprites["messagebox"], 2)
        drawPage(@page)
        pbFadeInAndShow(@sprites) { pbUpdate }
    end

    def pbStartForgetScene(party, partyindex, move_to_learn)
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99_999
        @party      = party
        @partyindex = partyindex
        @pokemon    = @party[@partyindex]
        @page = 4
        @forget = true
        @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
        @extraReminderBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/extra_info_reminder"))
        @sprites = {}
        @sprites["background"] = IconSprite.new(0, 0, @viewport)
        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        pbSetSystemFont(@sprites["overlay"].bitmap)
        @sprites["pokemon"] = PokemonSprite.new(@viewport)
        @sprites["pokemon"].setOffset(PictureOrigin::Center)
        @sprites["pokemon"].x = 104
        @sprites["pokemon"].y = 206
        @sprites["pokemon"].setPokemonBitmap(@pokemon)
        @sprites["pokeicon"] = PokemonIconSprite.new(@pokemon, @viewport)
        @sprites["pokeicon"].setOffset(PictureOrigin::Center)
        @sprites["pokeicon"].x       = 46
        @sprites["pokeicon"].y       = 92
        @sprites["pokeicon"].visible = false
        createItemIcons
        @sprites["movesel"] = MoveSelectionSprite.new(@viewport, !move_to_learn.nil?)
        @sprites["movesel"].visible = false
        @sprites["movesel"].visible = true
        @sprites["movesel"].index   = 0
        @sprites["extraReminder"] = SpriteWrapper.new(@viewport)
        @sprites["extraReminder"].bitmap = @extraReminderBitmap.bitmap
        @sprites["extraReminder"].x = 34
        @sprites["extraReminder"].y = 64
        new_move = move_to_learn ? Pokemon::Move.new(move_to_learn) : nil
        drawSelectedMove(new_move, @pokemon.moves[0])
        pbFadeInAndShow(@sprites)
    end

    def pbStartSingleScene(pokemon)
        @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
        @viewport.z = 99_999
        @party      = nil
        @partyindex = -1
        @pokemon    = pokemon
        @battle     = nil
        @page = 1
        @typebitmap    = AnimatedBitmap.new("Graphics/Pictures/types")
        @markingbitmap = AnimatedBitmap.new("Graphics/Pictures/Summary/markings")
        @sprites = {}
        @sprites["background"] = IconSprite.new(0, 0, @viewport)
        @sprites["pokemon"] = PokemonSprite.new(@viewport)
        @sprites["pokemon"].setOffset(PictureOrigin::Center)
        @sprites["pokemon"].x = 104
        @sprites["pokemon"].y = 206
        @sprites["pokemon"].setPokemonBitmap(@pokemon)
        @sprites["pokeicon"] = PokemonIconSprite.new(@pokemon, @viewport)
        @sprites["pokeicon"].setOffset(PictureOrigin::Center)
        @sprites["pokeicon"].x       = 46
        @sprites["pokeicon"].y       = 92
        @sprites["pokeicon"].visible = false
        createItemIcons
        @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        pbSetSystemFont(@sprites["overlay"].bitmap)
        @sprites["movepresel"] = MoveSelectionSprite.new(@viewport)
        @sprites["movepresel"].visible     = false
        @sprites["movepresel"].preselected = true
        @sprites["movesel"] = MoveSelectionSprite.new(@viewport)
        @sprites["movesel"].visible = false
        @sprites["ribbonpresel"] = RibbonSelectionSprite.new(@viewport)
        @sprites["ribbonpresel"].visible     = false
        @sprites["ribbonpresel"].preselected = true
        @sprites["ribbonsel"] = RibbonSelectionSprite.new(@viewport)
        @sprites["ribbonsel"].visible = false
        @sprites["uparrow"] = AnimatedSprite.new("Graphics/Pictures/uparrow", 8, 28, 40, 2, @viewport)
        @sprites["uparrow"].x = 350
        @sprites["uparrow"].y = 56
        @sprites["uparrow"].play
        @sprites["uparrow"].visible = false
        @sprites["downarrow"] = AnimatedSprite.new("Graphics/Pictures/downarrow", 8, 28, 40, 2, @viewport)
        @sprites["downarrow"].x = 350
        @sprites["downarrow"].y = 260
        @sprites["downarrow"].play
        @sprites["downarrow"].visible = false
        @sprites["markingbg"] = IconSprite.new(260, 88, @viewport)
        @sprites["markingbg"].setBitmap("Graphics/Pictures/Summary/overlay_marking")
        @sprites["markingbg"].visible = false
        @sprites["markingoverlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
        @sprites["markingoverlay"].visible = false
        pbSetSystemFont(@sprites["markingoverlay"].bitmap)
        @sprites["markingsel"] = IconSprite.new(0, 0, @viewport)
        @sprites["markingsel"].setBitmap("Graphics/Pictures/Summary/cursor_marking")
        @sprites["markingsel"].src_rect.height = @sprites["markingsel"].bitmap.height / 2
        @sprites["markingsel"].visible = false
        @sprites["messagebox"] = Window_AdvancedTextPokemon.new("")
        @sprites["messagebox"].viewport       = @viewport
        @sprites["messagebox"].visible        = false
        @sprites["messagebox"].letterbyletter = true
        pbBottomLeftLines(@sprites["messagebox"], 2)
        drawPage(@page)
        pbFadeInAndShow(@sprites) { pbUpdate }
    end

    def createItemIcons
        @itemBackground = AnimatedBitmap.new("Graphics/Pictures/Summary/item_bg")
        @itemBackground2 = AnimatedBitmap.new("Graphics/Pictures/Summary/item_bg2")
        @sprites["itembackground"] = IconSprite.new(0, 0, @viewport)
        @sprites["itembackground"].bitmap = @itemBackground.bitmap
        @sprites["itembackground"].y = Graphics.height - @itemBackground.bitmap.height
        @sprites["itembackground"].visible = true
        @sprites["itemicon"] = ItemIconSprite.new(30, 320, @pokemon.items[0], @viewport)
        @sprites["itemicon"].type = @pokemon.itemTypeChosen
        @sprites["itemicon"].blankzero = true
        @sprites["itemicon2"] = ItemIconSprite.new(166, 320, @pokemon.items[1], @viewport)
        @sprites["itemicon2"].type = @pokemon.itemTypeChosen
        @sprites["itemicon2"].blankzero = true
    end

    def pbEndScene
        pbFadeOutAndHide(@sprites) { pbUpdate }
        pbDisposeSpriteHash(@sprites)
        @typebitmap.dispose
        @extraReminderBitmap.dispose if @extraReminderBitmap
        @markingbitmap.dispose if @markingbitmap
        @viewport.dispose
        @itemBackground.dispose if @itemBackground
        @itemBackground2.dispose if @itemBackground2
    end

    def pbDisplay(text)
        @sprites["messagebox"].text = text
        @sprites["messagebox"].visible = true
        pbPlayDecisionSE
        loop do
            Graphics.update
            Input.update
            pbUpdate
            if @sprites["messagebox"].busy?
                if Input.trigger?(Input::USE)
                    pbPlayDecisionSE if @sprites["messagebox"].pausing?
                    @sprites["messagebox"].resume
                end
            elsif Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
                break
            end
        end
        @sprites["messagebox"].visible = false
    end

    def pbConfirm(text)
        ret = -1
        @sprites["messagebox"].text    = text
        @sprites["messagebox"].visible = true
        using(cmdwindow = Window_CommandPokemon.new([_INTL("Yes"), _INTL("No")])) do
            cmdwindow.z = @viewport.z + 1
            cmdwindow.visible = false
            pbBottomRight(cmdwindow)
            cmdwindow.y -= @sprites["messagebox"].height
            loop do
                Graphics.update
                Input.update
                cmdwindow.visible = true unless @sprites["messagebox"].busy?
                cmdwindow.update
                pbUpdate
                unless @sprites["messagebox"].busy?
                    if Input.trigger?(Input::BACK)
                        ret = false
                        break
                    elsif Input.trigger?(Input::USE) && @sprites["messagebox"].resume
                        ret = (cmdwindow.index == 0)
                        break
                    end
                end
            end
        end
        @sprites["messagebox"].visible = false
        return ret
    end

    def pbShowCommands(commands, index = 0)
        ret = -1
        using(cmdwindow = Window_CommandPokemon.new(commands)) do
            cmdwindow.z = @viewport.z + 1
            cmdwindow.index = index
            pbBottomRight(cmdwindow)
            loop do
                Graphics.update
                Input.update
                cmdwindow.update
                pbUpdate
                if Input.trigger?(Input::BACK)
                    pbPlayCancelSE
                    ret = -1
                    break
                elsif Input.trigger?(Input::USE)
                    pbPlayDecisionSE
                    ret = cmdwindow.index
                    break
                end
            end
        end
        return ret
    end

    def drawMarkings(bitmap, x, y)
        markings = @pokemon.markings
        markrect = Rect.new(0, 0, 16, 16)
        for i in 0...6
            markrect.x = i * 16
            markrect.y = (markings & (1 << i) != 0) ? 16 : 0
            bitmap.blt(x + i * 16, y, @markingbitmap.bitmap, markrect)
        end
    end

    def refreshItemIcons(setVisible = true)
        @sprites["itemicon"].visible = true if setVisible
        @sprites["itemicon"].item = @pokemon.items[0]
        @sprites["itemicon"].type = @pokemon.itemTypeChosen

        @sprites["itemicon2"].visible = true if setVisible
        @sprites["itemicon2"].item = @pokemon.items[1]
        @sprites["itemicon2"].type = @pokemon.itemTypeChosen

        @sprites["itembackground"].visible = true if setVisible
        if @pokemon.hasMultipleItems?
            @sprites["itembackground"].bitmap = @itemBackground2.bitmap
        else
            @sprites["itembackground"].bitmap = @itemBackground.bitmap
        end
    end

    def showItems
        @sprites["itemicon"]&.visible = true
        @sprites["itemicon2"]&.visible = true
        @sprites["itembackground"]&.visible = true
    end

    def hideItems
        @sprites["itemicon"]&.visible = false
        @sprites["itemicon2"]&.visible = false
        @sprites["itembackground"]&.visible = false
    end

    def drawPage(page)
        if @pokemon.egg?
            drawPageOneEgg
            return
        end
        refreshItemIcons
        overlay = @sprites["overlay"].bitmap
        overlay.clear
        base   = Color.new(248, 248, 248)
        shadow = Color.new(104, 104, 104)
        # Set background image
        @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_#{page}")
        imagepos = []
        # Show the Poké Ball containing the Pokémon
        ballimage = format("Graphics/Pictures/Summary/icon_ball_%s", @pokemon.poke_ball)
        unless pbResolveBitmap(ballimage)
            ballimage = format("Graphics/Pictures/Summary/icon_ball_%02d", pbGetBallType(@pokemon.poke_ball))
        end
        imagepos.push([ballimage, 14, 60])
        # Show status/fainted/Pokérus infected icon
        status = 0
        if @pokemon.afraid?
            status = GameData::Status::DATA.keys.length / 2 + 1
        elsif @pokemon.fainted?
            status = GameData::Status::DATA.keys.length / 2
        elsif @pokemon.status != :NONE
            status = GameData::Status.get(@pokemon.status).id_number
        end
        status -= 1
        imagepos.push(["Graphics/Pictures/statuses", 124, 100, 0, 16 * status, 44, 16]) if status >= 0
        # Show hot streak icon
        imagepos.push([sprintf("Graphics/Pictures/Summary/hot_streak"), 176, 100]) if @pokemon.onHotStreak?
        # Show shininess star
        if @pokemon.shiny?
            shinyIconFileName = @pokemon.shiny_variant? ? "Graphics/Pictures/shiny_variant" : "Graphics/Pictures/shiny"
            imagepos.push([sprintf(shinyIconFileName), 2, 134])
        end
        # Draw all images
        pbDrawImagePositions(overlay, imagepos)
        # Write various bits of text
        pagename = [_INTL("INFO"),
                    _INTL("PERSONALITY"),
                    _INTL("SKILLS"),
                    _INTL("MOVES"),
                    _INTL("RIBBONS"),][page - 1]
        textpos = [
            [pagename, 26, 10, 0, base, shadow],
            [@pokemon.name, 46, 56, 0, base, shadow],
            [@pokemon.level.to_s, 46, 86, 0, Color.new(64, 64, 64), Color.new(176, 176, 176)],
        ]
        itemLabel = @pokemon.hasMultipleItems? ? _INTL("Items") : _INTL("Item")
        textpos.push([itemLabel, 66, 312, 0, base, shadow]) if page != 3
        # Write the gender symbol
        if @pokemon.male?
            textpos.push([_INTL("♂"), 178, 56, 0, Color.new(24, 112, 216), Color.new(136, 168, 208)])
        elsif @pokemon.female?
            textpos.push([_INTL("♀"), 178, 56, 0, Color.new(248, 56, 32), Color.new(224, 152, 144)])
        end
        # Draw all text
        pbDrawTextPositions(overlay, textpos)
		# Write the held item's name
        unless page == 3
			itemText = []
            if @pokemon.hasItem?  
                itemName = @pokemon.itemsName
                itemNameX = 16
				itemNameY = 346
                if @pokemon.hasMultipleItems?
				    itemNameY += 2
                    itemNameX -= 8
                end
                itemText.push([itemName, itemNameX, itemNameY, 0, Color.new(64, 64, 64), Color.new(176, 176, 176)])
            else
                itemText.push([_INTL("None"), 16, 346, 0, Color.new(192, 200, 208), Color.new(208, 216, 224)])
            end
			overlay.font.name = MessageConfig.pbGetNarrowFontName
			overlay.font.size = 20 if @pokemon.hasMultipleItems?
			pbDrawTextPositions(overlay, itemText)
			pbSetSystemFont(overlay)
        end
        # Draw page-specific information
        case page
        when 1 then drawPageOne
        when 2 then drawPageTwo
        when 3 then drawPageThree
        when 4 then drawPageFour
        when 5 then drawPageFive
        end
    end

    def drawPageOne
        overlay = @sprites["overlay"].bitmap
        base   = Color.new(248, 248, 248)
        shadow = Color.new(104, 104, 104)
        dexNumBase   = @pokemon.shiny? ? Color.new(248, 56, 32) : Color.new(64, 64, 64)
        dexNumShadow = @pokemon.shiny? ? Color.new(224, 152, 144) : Color.new(176, 176, 176)
        # Write various bits of text
        infoTextLabelX = 238
        infoTextInsertedX = 435
        infoLabelBaseY = 74
        textpos = [
            [_INTL("Species"), infoTextLabelX, infoLabelBaseY, 0, base, shadow],
            [@pokemon.speciesName, infoTextInsertedX, infoLabelBaseY, 2, Color.new(64, 64, 64), Color.new(176, 176, 176)],
            [_INTL("Type"), infoTextLabelX, infoLabelBaseY + 32, 0, base, shadow],
            [_INTL("OT"), infoTextLabelX, infoLabelBaseY + 32 * 2, 0, base, shadow],
            [_INTL("ID No."), infoTextLabelX, infoLabelBaseY + 32 * 3, 0, base, shadow],
            [_INTL("Obtain Lv."), infoTextLabelX, infoLabelBaseY + 32 * 4, 0, base, shadow],
        ]
        # Write Original Trainer's name and ID number
        if @pokemon.owner.name.empty?
            textpos.push([_INTL("RENTAL"), infoTextInsertedX, infoLabelBaseY + 32 * 2, 2, Color.new(64, 64, 64), Color.new(176, 176, 176)])
            textpos.push(["?????", infoTextInsertedX, infoLabelBaseY + 32 * 3, 2, Color.new(64, 64, 64), Color.new(176, 176, 176)])
        else
            ownerbase   = Color.new(64, 64, 64)
            ownershadow = Color.new(176, 176, 176)
            case @pokemon.owner.gender
            when 0
                ownerbase = Color.new(24, 112, 216)
                ownershadow = Color.new(136, 168, 208)
            when 1
                ownerbase = Color.new(248, 56, 32)
                ownershadow = Color.new(224, 152, 144)
            end
            textpos.push([@pokemon.owner.name, infoTextInsertedX, infoLabelBaseY + 32 * 2, 2, ownerbase, ownershadow])
            textpos.push([format("%05d", @pokemon.owner.public_id), infoTextInsertedX, infoLabelBaseY + 32 * 3, 2, Color.new(64, 64, 64),
                          Color.new(176, 176, 176),])
        end
        # Write the Pokemon's original level of obtaining
        textpos.push([@pokemon.obtain_level.to_s, infoTextInsertedX, infoLabelBaseY + 32 * 4, 1, Color.new(64, 64, 64),
            Color.new(176, 176, 176),])
        # Write experience point info
        endexp = @pokemon.growth_rate.minimum_exp_for_level(@pokemon.level + 1)
        textpos.push([_INTL("Exp. Points"), 238, 234, 0, base, shadow])
        textpos.push([@pokemon.exp.to_s_formatted, 488, 266, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)])
        textpos.push([_INTL("To Next Lv."), 238, 298, 0, base, shadow])
        textpos.push([(endexp - @pokemon.exp).to_s_formatted, 488, 330, 1, Color.new(64, 64, 64),
                      Color.new(176, 176, 176),])
        # Draw all text
        pbDrawTextPositions(overlay, textpos)
        # Draw Pokémon type(s)
        type1_number = GameData::Type.get(@pokemon.type1).id_number
        type2_number = GameData::Type.get(@pokemon.type2).id_number
        type1rect = Rect.new(0, type1_number * 28, 64, 28)
        type2rect = Rect.new(0, type2_number * 28, 64, 28)
        if @pokemon.type1 == @pokemon.type2
            overlay.blt(402, infoLabelBaseY + 32 + 8, @typebitmap.bitmap, type1rect)
        else
            overlay.blt(370, infoLabelBaseY + 32 + 8, @typebitmap.bitmap, type1rect)
            overlay.blt(436, infoLabelBaseY + 32 + 8, @typebitmap.bitmap, type2rect)
        end
        # Draw Exp bar
        if @pokemon.level < GameData::GrowthRate.max_level
            w = @pokemon.exp_fraction * 128
            w = (w / 2).round * 2
            pbDrawImagePositions(overlay, [
                                     ["Graphics/Pictures/Summary/overlay_exp", 362, 372, 0, 0, w, 6],
                                 ])
        end
        # Draw the Pokémon's markings
        drawMarkings(overlay,104,24)
    end

    def drawPageOneEgg
        refreshItemIcons
        overlay = @sprites["overlay"].bitmap
        overlay.clear
        base   = Color.new(248, 248, 248)
        shadow = Color.new(104, 104, 104)
        # Set background image
        @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_egg")
        imagepos = []
        # Show the Poké Ball containing the Pokémon
        ballimage = format("Graphics/Pictures/Summary/icon_ball_%s", @pokemon.poke_ball)
        unless pbResolveBitmap(ballimage)
            ballimage = format("Graphics/Pictures/Summary/icon_ball_%02d", pbGetBallType(@pokemon.poke_ball))
        end
        imagepos.push([ballimage, 14, 60])
        # Draw all images
        pbDrawImagePositions(overlay, imagepos)
        # Write various bits of text
        textpos = [
            [_INTL("STORY"), 26, 10, 0, base, shadow],
            [@pokemon.name, 46, 56, 0, base, shadow],
            [_INTL("Item"), 66, 312, 0, base, shadow],
        ]
        # Write the held item's name
        if @pokemon.hasItem?
            textpos.push([@pokemon.item.name, 16, 346, 0, Color.new(64, 64, 64), Color.new(176, 176, 176)])
        else
            textpos.push([_INTL("None"), 16, 346, 0, Color.new(192, 200, 208), Color.new(208, 216, 224)])
        end
        # Draw all text
        pbDrawTextPositions(overlay, textpos)
        memo = ""
        # Write date received
        if @pokemon.timeReceived
            date  = @pokemon.timeReceived.day
            month = pbGetMonthName(@pokemon.timeReceived.mon)
            year  = @pokemon.timeReceived.year
            memo += _INTL("<c3=404040,B0B0B0>{1} {2}, {3}\n", date, month, year)
        end
        # Write map name egg was received on
        mapname = pbGetMapNameFromId(@pokemon.obtain_map)
        mapname = @pokemon.obtain_text if @pokemon.obtain_text && !@pokemon.obtain_text.empty?
        if mapname && mapname != ""
            memo += _INTL(
                "<c3=404040,B0B0B0>A mysterious Pokémon Egg received from <c3=F83820,E09890>{1}<c3=404040,B0B0B0>.\n", mapname)
        else
            memo += _INTL("<c3=404040,B0B0B0>A mysterious Pokémon Egg.\n", mapname)
        end
        memo += "\n" # Empty line
        # Write Egg Watch blurb
        memo += _INTL("<c3=404040,B0B0B0>\"The Egg Watch\"\n")
        eggstate = _INTL("It looks like this Egg will take a long time to hatch.")
        if @pokemon.steps_to_hatch < 10_200
            eggstate = _INTL("What will hatch from this? It doesn't seem close to hatching.")
        end
        if @pokemon.steps_to_hatch < 2550
            eggstate = _INTL("It appears to move occasionally. It may be close to hatching.")
        end
        if @pokemon.steps_to_hatch < 1275
            eggstate = _INTL("Sounds can be heard coming from inside! It will hatch soon!")
        end
        memo += format("<c3=404040,B0B0B0>%s\n", eggstate)
        # Draw all text
        drawFormattedTextEx(overlay, 232, 82, 268, memo)
        # Draw the Pokémon's markings
        drawMarkings(overlay, 84, 292)
    end

    def drawPageTwo
        overlay = @sprites["overlay"].bitmap
        memo = ""

        # Traits
        memo += _INTL("<c3=F83820,E09890>Traits:<c3=404040,B0B0B0>")
        memo += "\n"
        memo += _INTL("<c3=404040{2},B0B0B0>{1}", @pokemon.trait1 || "Unknown", @pokemon.trait1 ? "FF" : "77")
        memo += "\n"
        memo += _INTL("<c3=404040{2},B0B0B0>{1}", @pokemon.trait2 || "Unknown", @pokemon.trait2 ? "FF" : "77")
        memo += "\n"
        memo += _INTL("<c3=404040{2},B0B0B0>{1}", @pokemon.trait3 || "Unknown", @pokemon.trait3 ? "FF" : "77")
        memo += "\n"
        memo += "\n"
        memo += _INTL("<c3=F83820,E09890>Likes:<c3=404040,B0B0B0>")
        memo += "\n"
        memo += _INTL("<c3=404040{2},B0B0B0>{1}", @pokemon.like || "Unknown", @pokemon.like ? "FF" : "77")
        memo += "\n"
        memo += _INTL("<c3=F83820,E09890>Dislikes:<c3=404040,B0B0B0>")
        memo += "\n"
        memo += _INTL("<c3=404040{2},B0B0B0>{1}", @pokemon.dislike || "Unknown", @pokemon.dislike ? "FF" : "77")
        memo += "\n"

        # # Write date received
        # if @pokemon.timeReceived
        #     date  = @pokemon.timeReceived.day
        #     month = pbGetMonthName(@pokemon.timeReceived.mon)
        #     year  = @pokemon.timeReceived.year
        #     memo += _INTL("<c3=404040,B0B0B0>{1} {2}, {3}\n", date, month, year)
        # end

        # Write map name Pokémon was received on
        # mapname = pbGetMapNameFromId(@pokemon.obtain_map)
        # mapname = @pokemon.obtain_text if @pokemon.obtain_text && !@pokemon.obtain_text.empty?
        # mapname = _INTL("Faraway place") if !mapname || mapname == ""
        # memo += format("<c3=F83820,E09890>%s\n", mapname)

        # Write how Pokémon was obtained
        # mettext = [_INTL("Met at Lv. {1}.", @pokemon.obtain_level),
        #            _INTL("Egg received."),
        #            _INTL("Traded at Lv. {1}.", @pokemon.obtain_level),
        #            "",
        #            _INTL("Had a fateful encounter at Lv. {1}.", @pokemon.obtain_level),][@pokemon.obtain_method]
        # memo += format("<c3=404040,B0B0B0>%s\n", mettext) if mettext && mettext != ""

        # # If Pokémon was hatched, write when and where it hatched
        # if @pokemon.obtain_method == 1
        #     if @pokemon.timeEggHatched
        #         date  = @pokemon.timeEggHatched.day
        #         month = pbGetMonthName(@pokemon.timeEggHatched.mon)
        #         year  = @pokemon.timeEggHatched.year
        #         memo += _INTL("<c3=404040,B0B0B0>{1} {2}, {3}\n", date, month, year)
        #     end
        #     mapname = pbGetMapNameFromId(@pokemon.hatched_map)
        #     mapname = _INTL("Faraway place") if !mapname || mapname == ""
        #     memo += format("<c3=F83820,E09890>%s\n", mapname)
        #     memo += _INTL("<c3=404040,B0B0B0>Egg hatched.\n")
        # else
        #     memo += "\n" # Empty line
        # end

        # Write all text
        drawFormattedTextEx(overlay, 232, 82, 268, memo)

        playTraitsTutorial unless $PokemonGlobal.traitsTutorialized
    end

    def drawPageThree
        hideItems
        overlay = @sprites["overlay"].bitmap
        base   = Color.new(248, 248, 248)
        shadow = Color.new(104, 104, 104)
        # Determine which stats are boosted and lowered by the Pokémon's nature
        statshadows = {}
        GameData::Stat.each_main { |s| statshadows[s.id] = shadow }
        # Write various bits of text
        statTotalX = 472
        evAmountX  = 372
        stat_value_color_base = Color.new(64, 64, 64)
        stat_value_color_shadow = Color.new(176, 176, 176)
        ev_color_base = Color.new(128, 128, 200)
        ev_color_shadow = Color.new(220, 220, 220)
        textpos = [
            [_INTL("HP"), 292, 70, 2, base, statshadows[:HP]],
            [format("%d/%d", @pokemon.hp, @pokemon.totalhp), statTotalX, 70, 1, stat_value_color_base],
            [_INTL("Attack"), 248, 114, 0, base, statshadows[:ATTACK]],
            [format("%d", @pokemon.attack), statTotalX, 114, 1, stat_value_color_base, stat_value_color_shadow],
            [_INTL("Defense"), 248, 146, 0, base, statshadows[:DEFENSE]],
            [format("%d", @pokemon.defense), statTotalX, 146, 1, stat_value_color_base, stat_value_color_shadow],
            [_INTL("Sp. Atk"), 248, 178, 0, base, statshadows[:SPECIAL_ATTACK]],
            [format("%d", @pokemon.spatk), statTotalX, 178, 1, stat_value_color_base, stat_value_color_shadow],
            [_INTL("Sp. Def"), 248, 210, 0, base, statshadows[:SPECIAL_DEFENSE]],
            [format("%d", @pokemon.spdef), statTotalX, 210, 1, stat_value_color_base, stat_value_color_shadow],
            [_INTL("Speed"), 248, 242, 0, base, statshadows[:SPEED]],
            [format("%d", @pokemon.speed), statTotalX, 242, 1, stat_value_color_base, stat_value_color_shadow],
            [_INTL("Ability"), 16, 278, 0, base, shadow],
        ]
        if @pokemon.ev[:HP] != 0
            textpos.push([format("%d", @pokemon.ev[:HP]), evAmountX, 70, 2, ev_color_base,
                          ev_color_shadow,])
        end
        if @pokemon.ev[:ATTACK] != 0
            textpos.push([format("%d", @pokemon.ev[:ATTACK]), evAmountX, 114, 2, ev_color_base,
                          ev_color_shadow,])
        end
        if @pokemon.ev[:DEFENSE] != 0
            textpos.push([format("%d", @pokemon.ev[:DEFENSE]), evAmountX, 146, 2, ev_color_base,
                          ev_color_shadow,])
        end
        if @pokemon.ev[:SPECIAL_ATTACK] != 0
            textpos.push([format("%d", @pokemon.ev[:SPECIAL_ATTACK]), evAmountX, 178, 2, ev_color_base,
                          ev_color_shadow,])
        end
        if @pokemon.ev[:SPECIAL_DEFENSE] != 0
            textpos.push([format("%d", @pokemon.ev[:SPECIAL_DEFENSE]), evAmountX, 210, 2, ev_color_base,
                          ev_color_shadow,])
        end
        if @pokemon.ev[:SPEED] != 0
            textpos.push([format("%d", @pokemon.ev[:SPEED]), evAmountX, 242, 2, ev_color_base,
                          ev_color_shadow,])
        end

        # Draw ability name and description
        ability = @pokemon.ability
        if ability
            textpos.push([ability.name, 138, 278, 0, Color.new(64, 64, 64), Color.new(176, 176, 176)])
            drawTextEx(overlay, 8, 320, Graphics.width, 2, ability.description, Color.new(64, 64, 64),
  Color.new(176, 176, 176))
        end
        # Draw all text
        pbDrawTextPositions(overlay, textpos)
        # Draw HP bar
        if @pokemon.hp > 0
            w = @pokemon.hp * 96 * 1.0 / @pokemon.totalhp
            w = 1 if w < 1
            w = (w / 2).round * 2
            hpzone = 0
            hpzone = 1 if @pokemon.hp <= (@pokemon.totalhp / 2).floor
            hpzone = 2 if @pokemon.hp <= (@pokemon.totalhp / 4).floor
            imagepos = [
                ["Graphics/Pictures/Summary/overlay_hp", 360, 110, 0, hpzone * 6, w, 6],
            ]
            pbDrawImagePositions(overlay, imagepos)
        end
    end

    def drawPageFour
        overlay = @sprites["overlay"].bitmap
        moveBase   = Color.new(64, 64, 64)
        moveShadow = Color.new(176, 176, 176)
        ppBase   = [moveBase, # More than 1/2 of total PP
                    Color.new(248, 192, 0),    # 1/2 of total PP or less
                    Color.new(248, 136, 32),   # 1/4 of total PP or less
                    Color.new(248, 72, 72),] # Zero PP
        ppShadow = [moveShadow, # More than 1/2 of total PP
                    Color.new(144, 104, 0),   # 1/2 of total PP or less
                    Color.new(144, 72, 24),   # 1/4 of total PP or less
                    Color.new(136, 48, 48),] # Zero PP
        @sprites["pokemon"].visible = true
        @sprites["pokeicon"].visible = false
        showItems
        textpos  = []
        imagepos = []
        # Write move names, types and PP amounts for each known move
        yPos = 92
        for i in 0...Pokemon::MAX_MOVES
            move = @pokemon.moves[i]
            if move
                type_number = GameData::Type.get(move.type).id_number
                imagepos.push(["Graphics/Pictures/types", 248, yPos + 8, 0, type_number * 28, 64, 28])
                textpos.push([move.name, 316, yPos, 0, moveBase, moveShadow])
                if move.total_pp > 0
                    textpos.push([_INTL("PP"), 342, yPos + 32, 0, moveBase, moveShadow])
                    ppfraction = 0
                    if move.pp == 0
                        ppfraction = 3
                    elsif move.pp * 4 <= move.total_pp
                        ppfraction = 2
                    elsif move.pp * 2 <= move.total_pp
                        ppfraction = 1
                    end
                    textpos.push([format("%d/%d", move.pp, move.total_pp), 460, yPos + 32, 1, ppBase[ppfraction],
                                  ppShadow[ppfraction],])
                end
            else
                textpos.push(["-", 316, yPos, 0, moveBase, moveShadow])
                textpos.push(["--", 442, yPos + 32, 1, moveBase, moveShadow])
            end
            yPos += 64
        end
        # Draw all text and images
        pbDrawTextPositions(overlay, textpos)
        pbDrawImagePositions(overlay, imagepos)
    end

    def drawPageFourSelecting(move_to_learn)
        overlay = @sprites["overlay"].bitmap
        overlay.clear
        base   = Color.new(248, 248, 248)
        shadow = Color.new(104, 104, 104)
        moveBase   = Color.new(64, 64, 64)
        moveShadow = Color.new(176, 176, 176)
        ppBase   = [moveBase, # More than 1/2 of total PP
                    Color.new(248, 192, 0),    # 1/2 of total PP or less
                    Color.new(248, 136, 32),   # 1/4 of total PP or less
                    Color.new(248, 72, 72),] # Zero PP
        ppShadow = [moveShadow, # More than 1/2 of total PP
                    Color.new(144, 104, 0),   # 1/2 of total PP or less
                    Color.new(144, 72, 24),   # 1/4 of total PP or less
                    Color.new(136, 48, 48),] # Zero PP
        # Set background image
        if move_to_learn
            @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_learnmove")
        else
            @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_movedetail")
        end
        # Write various bits of text
        textpos = [
            [_INTL("MOVES"), 26, 10, 0, base, shadow],
            [_INTL("CATEGORY"), 20, 116, 0, base, shadow],
            [_INTL("POWER"), 20, 148, 0, base, shadow],
            [_INTL("ACCURACY"), 20, 180, 0, base, shadow],
        ]
        imagepos = []
        # Write move names, types and PP amounts for each known move
        yPos = 92
        yPos -= 76 if move_to_learn
        limit = move_to_learn ? Pokemon::MAX_MOVES + 1 : Pokemon::MAX_MOVES
        for i in 0...limit
            move = @pokemon.moves[i]
            if i == Pokemon::MAX_MOVES
                move = move_to_learn
                yPos += 20
            end
            if move
                type_number = GameData::Type.get(move.type).id_number
                imagepos.push(["Graphics/Pictures/types", 248, yPos + 8, 0, type_number * 28, 64, 28])
                textpos.push([move.name, 316, yPos, 0, moveBase, moveShadow])
                if move.total_pp > 0
                    textpos.push([_INTL("PP"), 342, yPos + 32, 0, moveBase, moveShadow])
                    ppfraction = 0
                    if move.pp == 0
                        ppfraction = 3
                    elsif move.pp * 4 <= move.total_pp
                        ppfraction = 2
                    elsif move.pp * 2 <= move.total_pp
                        ppfraction = 1
                    end
                    textpos.push([format("%d/%d", move.pp, move.total_pp), 460, yPos + 32, 1, ppBase[ppfraction],
                                  ppShadow[ppfraction],])
                end
            else
                textpos.push(["-", 316, yPos, 0, moveBase, moveShadow])
                textpos.push(["--", 442, yPos + 32, 1, moveBase, moveShadow])
            end
            yPos += 64
        end
        # Draw all text and images
        pbDrawTextPositions(overlay, textpos)
        pbDrawImagePositions(overlay, imagepos)
        unless @forget
            # Draw Pokémon's type icon(s)
            type1_number = GameData::Type.get(@pokemon.type1).id_number
            type2_number = GameData::Type.get(@pokemon.type2).id_number
            type1rect = Rect.new(0, type1_number * 28, 64, 28)
            type2rect = Rect.new(0, type2_number * 28, 64, 28)
            if @pokemon.type1 == @pokemon.type2
                overlay.blt(130, 78, @typebitmap.bitmap, type1rect)
            else
                overlay.blt(96, 78, @typebitmap.bitmap, type1rect)
                overlay.blt(166, 78, @typebitmap.bitmap, type2rect)
            end
        end
    end

    def drawSelectedMove(move_to_learn, selected_move)
        # Draw all of page four, except selected move's details
        drawPageFourSelecting(move_to_learn)
        # Set various values
        overlay = @sprites["overlay"].bitmap
        base = Color.new(64, 64, 64)
        shadow = Color.new(176, 176, 176)
        @sprites["pokemon"].visible = false if @sprites["pokemon"]
        @sprites["pokeicon"].pokemon = @pokemon
        @sprites["pokeicon"].visible = true
        @sprites["pokeicon"].visible = false if @forget
        hideItems
        textpos = []
        # Write power and accuracy values for selected move
        case selected_move.base_damage
        when 0 then textpos.push(["---", 216, 148, 1, base, shadow])   # Status move
        when 1 then textpos.push(["???", 216, 148, 1, base, shadow])   # Variable power move
        else        textpos.push([selected_move.base_damage.to_s, 216, 148, 1, base, shadow])
        end
        if selected_move.accuracy == 0
            textpos.push(["---", 216, 180, 1, base, shadow])
        else
            textpos.push(["#{selected_move.accuracy}%", 216 + overlay.text_size("%").width, 180, 1, base, shadow])
        end
        # Draw all text
        pbDrawTextPositions(overlay, textpos)
        # Draw selected move's damage category icon
        imagepos = [["Graphics/Pictures/category", 166, 124, 0, selected_move.category * 28, 64, 28]]
        pbDrawImagePositions(overlay, imagepos)
        # Draw selected move's description
        drawTextEx(overlay, 4, 222, 230, 5, selected_move.description, base, shadow)

        if @battle&.pokemonIsActiveBattler?(@pokemon) && !$PokemonGlobal.moveInfoPanelTutorialized
            playMoveInfoPanelTutorial
        end
    end

    def drawPageFive
        overlay = @sprites["overlay"].bitmap
        @sprites["uparrow"].visible   = false
        @sprites["downarrow"].visible = false
        # Write various bits of text
        textpos = [
            [_INTL("No. of Ribbons:"), 234, 326, 0, Color.new(64, 64, 64), Color.new(176, 176, 176)],
            [@pokemon.numRibbons.to_s, 450, 326, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
        ]
        # Draw all text
        pbDrawTextPositions(overlay, textpos)
        # Show all ribbons
        imagepos = []
        coord = 0
        for i in @ribbonOffset * 4...@ribbonOffset * 4 + 12
            break unless @pokemon.ribbons[i]
            ribbon_data = GameData::Ribbon.get(@pokemon.ribbons[i])
            ribn = ribbon_data.id_number - 1
            imagepos.push(["Graphics/Pictures/ribbons",
                           230 + 68 * (coord % 4), 78 + 68 * (coord / 4).floor,
                           64 * (ribn % 8), 64 * (ribn / 8).floor, 64, 64,])
            coord += 1
        end
        # Draw all images
        pbDrawImagePositions(overlay, imagepos)
    end

    def drawSelectedRibbon(ribbonid)
        # Draw all of page five
        drawPage(5)
        # Set various values
        overlay = @sprites["overlay"].bitmap
        base   = Color.new(64, 64, 64)
        shadow = Color.new(176, 176, 176)
        nameBase   = Color.new(248, 248, 248)
        nameShadow = Color.new(104, 104, 104)
        # Get data for selected ribbon
        name = ribbonid ? GameData::Ribbon.get(ribbonid).name : ""
        desc = ribbonid ? GameData::Ribbon.get(ribbonid).description : ""
        # Draw the description box
        imagepos = [
            ["Graphics/Pictures/Summary/overlay_ribbon", 8, 280],
        ]
        pbDrawImagePositions(overlay, imagepos)
        # Draw name of selected ribbon
        textpos = [
            [name, 18, 280, 0, nameBase, nameShadow],
        ]
        pbDrawTextPositions(overlay, textpos)
        # Draw selected ribbon's description
        drawTextEx(overlay, 18, 322, 480, 2, desc, base, shadow)
    end

    def pbGoToPrevious
        newindex = @partyindex
        while newindex > 0
            newindex -= 1
            if @party[newindex] && (@page == 1 || !@party[newindex].egg?)
                @partyindex = newindex
                break
            end
        end
    end

    def pbGoToNext
        newindex = @partyindex
        while newindex < @party.length - 1
            newindex += 1
            if @party[newindex] && (@page == 1 || !@party[newindex].egg?)
                @partyindex = newindex
                break
            end
        end
    end

    def pbChangePokemon
        @pokemon = @party[@partyindex]
        @sprites["pokemon"].setPokemonBitmap(@pokemon)
        refreshItemIcons(false)
        pbSEStop
        @pokemon.play_cry
    end

    def pbMoveSelection
        @sprites["movesel"].visible = true
        @sprites["movesel"].index = 0
        selmove    = 0
        oldselmove = 0
        switching = false
        drawSelectedMove(nil, @pokemon.moves[selmove])
        loop do
            Graphics.update
            Input.update
            pbUpdate
            if @sprites["movepresel"].index == @sprites["movesel"].index
                @sprites["movepresel"].z = @sprites["movesel"].z + 1
            else
                @sprites["movepresel"].z = @sprites["movesel"].z
            end
            if Input.trigger?(Input::BACK)
                switching ? pbPlayCancelSE : pbPlayCloseMenuSE
                break unless switching
                @sprites["movepresel"].visible = false
                switching = false
            elsif Input.trigger?(Input::USE)
                pbPlayDecisionSE
                if selmove == Pokemon::MAX_MOVES
                    break unless switching
                    @sprites["movepresel"].visible = false
                    switching = false
                elsif !switching
                    @sprites["movepresel"].index = selmove
                    @sprites["movepresel"].visible = true
                    oldselmove = selmove
                    switching = true
                else
                    tmpmove = @pokemon.moves[oldselmove]
                    @pokemon.moves[oldselmove] = @pokemon.moves[selmove]
                    @pokemon.moves[selmove]    = tmpmove
                    @sprites["movepresel"].visible = false
                    switching = false
                    drawSelectedMove(nil, @pokemon.moves[selmove])
                end
            elsif Input.trigger?(Input::UP)
                selmove -= 1
                selmove = @pokemon.numMoves - 1 if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
                selmove = 0 if selmove >= Pokemon::MAX_MOVES
                selmove = @pokemon.numMoves - 1 if selmove < 0
                @sprites["movesel"].index = selmove
                pbPlayCursorSE
                drawSelectedMove(nil, @pokemon.moves[selmove])
            elsif Input.trigger?(Input::DOWN)
                selmove += 1
                selmove = 0 if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
                selmove = 0 if selmove >= Pokemon::MAX_MOVES
                selmove = Pokemon::MAX_MOVES if selmove < 0
                @sprites["movesel"].index = selmove
                pbPlayCursorSE
                drawSelectedMove(nil, @pokemon.moves[selmove])
            end
        end
        @sprites["movesel"].visible = false
    end

    def pbRibbonSelection
        @sprites["ribbonsel"].visible = true
        @sprites["ribbonsel"].index = 0
        selribbon    = @ribbonOffset * 4
        oldselribbon = selribbon
        switching = false
        numRibbons = @pokemon.ribbons.length
        numRows    = [((numRibbons + 3) / 4).floor, 3].max
        drawSelectedRibbon(@pokemon.ribbons[selribbon])
        loop do
            @sprites["uparrow"].visible = (@ribbonOffset > 0)
            @sprites["downarrow"].visible = (@ribbonOffset < numRows - 3)
            Graphics.update
            Input.update
            pbUpdate
            if @sprites["ribbonpresel"].index == @sprites["ribbonsel"].index
                @sprites["ribbonpresel"].z = @sprites["ribbonsel"].z + 1
            else
                @sprites["ribbonpresel"].z = @sprites["ribbonsel"].z
            end
            hasMovedCursor = false
            if Input.trigger?(Input::BACK)
                switching ? pbPlayCancelSE : pbPlayCloseMenuSE
                break unless switching
                @sprites["ribbonpresel"].visible = false
                switching = false
            elsif Input.trigger?(Input::USE)
                if !switching
                    if @pokemon.ribbons[selribbon]
                        pbPlayDecisionSE
                        @sprites["ribbonpresel"].index = selribbon - @ribbonOffset * 4
                        oldselribbon = selribbon
                        @sprites["ribbonpresel"].visible = true
                        switching = true
                    end
                else
                    pbPlayDecisionSE
                    tmpribbon                      = @pokemon.ribbons[oldselribbon]
                    @pokemon.ribbons[oldselribbon] = @pokemon.ribbons[selribbon]
                    @pokemon.ribbons[selribbon]    = tmpribbon
                    if @pokemon.ribbons[oldselribbon] || @pokemon.ribbons[selribbon]
                        @pokemon.ribbons.compact!
                        if selribbon >= numRibbons
                            selribbon = numRibbons - 1
                            hasMovedCursor = true
                        end
                    end
                    @sprites["ribbonpresel"].visible = false
                    switching = false
                    drawSelectedRibbon(@pokemon.ribbons[selribbon])
                end
            elsif Input.trigger?(Input::UP)
                selribbon -= 4
                selribbon += numRows * 4 if selribbon < 0
                hasMovedCursor = true
                pbPlayCursorSE
            elsif Input.trigger?(Input::DOWN)
                selribbon += 4
                selribbon -= numRows * 4 if selribbon >= numRows * 4
                hasMovedCursor = true
                pbPlayCursorSE
            elsif Input.trigger?(Input::LEFT)
                selribbon -= 1
                selribbon += 4 if selribbon % 4 == 3
                hasMovedCursor = true
                pbPlayCursorSE
            elsif Input.trigger?(Input::RIGHT)
                selribbon += 1
                selribbon -= 4 if selribbon % 4 == 0
                hasMovedCursor = true
                pbPlayCursorSE
            end
            next unless hasMovedCursor
            @ribbonOffset = (selribbon / 4).floor if selribbon < @ribbonOffset * 4
            @ribbonOffset = (selribbon / 4).floor - 2 if selribbon >= (@ribbonOffset + 3) * 4
            @ribbonOffset = 0 if @ribbonOffset < 0
            @ribbonOffset = numRows - 3 if @ribbonOffset > numRows - 3
            @sprites["ribbonsel"].index    = selribbon - @ribbonOffset * 4
            @sprites["ribbonpresel"].index = oldselribbon - @ribbonOffset * 4
            drawSelectedRibbon(@pokemon.ribbons[selribbon])
        end
        @sprites["ribbonsel"].visible = false
    end

    def pbMarking(pokemon)
        @sprites["markingbg"].visible = true
        @sprites["markingoverlay"].visible = true
        @sprites["markingsel"].visible     = true
        base   = Color.new(248, 248, 248)
        shadow = Color.new(104, 104, 104)
        ret = pokemon.markings
        markings = pokemon.markings
        index = 0
        redraw = true
        markrect = Rect.new(0, 0, 16, 16)
        loop do
            # Redraw the markings and text
            if redraw
                @sprites["markingoverlay"].bitmap.clear
                for i in 0...6
                    markrect.x = i * 16
                    markrect.y = (markings & (1 << i) != 0) ? 16 : 0
                    @sprites["markingoverlay"].bitmap.blt(300 + 58 * (i % 3), 154 + 50 * (i / 3), @markingbitmap.bitmap,
    markrect)
                end
                textpos = [
                    [_INTL("Mark {1}", pokemon.name), 366, 90, 2, base, shadow],
                    [_INTL("OK"), 366, 242, 2, base, shadow],
                    [_INTL("Cancel"), 366, 292, 2, base, shadow],
                ]
                pbDrawTextPositions(@sprites["markingoverlay"].bitmap, textpos)
                redraw = false
            end
            # Reposition the cursor
            @sprites["markingsel"].x = 284 + 58 * (index % 3)
            @sprites["markingsel"].y = 144 + 50 * (index / 3)
            if index == 6 # OK
                @sprites["markingsel"].x = 284
                @sprites["markingsel"].y = 244
                @sprites["markingsel"].src_rect.y = @sprites["markingsel"].bitmap.height / 2
            elsif index == 7 # Cancel
                @sprites["markingsel"].x = 284
                @sprites["markingsel"].y = 294
                @sprites["markingsel"].src_rect.y = @sprites["markingsel"].bitmap.height / 2
            else
                @sprites["markingsel"].src_rect.y = 0
            end
            Graphics.update
            Input.update
            pbUpdate
            if Input.trigger?(Input::BACK)
                pbPlayCloseMenuSE
                break
            elsif Input.trigger?(Input::USE)
                pbPlayDecisionSE
                if index == 6 # OK
                    ret = markings
                    break
                elsif index == 7 # Cancel
                    break
                else
                    mask = (1 << index)
                    if (markings & mask) == 0
                        markings |= mask
                    else
                        markings &= ~mask
                    end
                    redraw = true
                end
            elsif Input.trigger?(Input::UP)
                if index == 7
                    index = 6
                elsif index == 6
                    index = 4
                elsif index < 3
                    index = 7
                else
                    index -= 3
                end
                pbPlayCursorSE
            elsif Input.trigger?(Input::DOWN)
                if index == 7
                    index = 1
                elsif index == 6
                    index = 7
                elsif index >= 3
                    index = 6
                else
                    index += 3
                end
                pbPlayCursorSE
            elsif Input.trigger?(Input::LEFT)
                if index < 6
                    index -= 1
                    index += 3 if index % 3 == 2
                    pbPlayCursorSE
                end
            elsif Input.trigger?(Input::RIGHT)
                if index < 6
                    index += 1
                    index -= 3 if index % 3 == 0
                    pbPlayCursorSE
                end
            end
        end
        @sprites["markingbg"].visible      = false
        @sprites["markingoverlay"].visible = false
        @sprites["markingsel"].visible     = false
        if pokemon.markings != ret
            pokemon.markings = ret
            return true
        end
        return false
    end

    def pbOptions
        canEditTeam = teamEditingAllowed?
        loop do
            dorefresh = false
            commands = []
            cmdGiveItem = -1
            cmdTakeItem = -1
            cmdPokedex  = -1
            cmdMark     = -1
            unless @pokemon.egg?
                commands[cmdGiveItem = commands.length] = _INTL("Give item")
                commands[cmdTakeItem = commands.length] = _INTL("Take item") if @pokemon.hasItem?
                commands[cmdPokedex = commands.length]  = _INTL("View MasterDex") if $Trainer.has_pokedex
            end
            commands[cmdMark = commands.length]       = _INTL("Mark")
            commands[commands.length]                 = _INTL("Cancel")
            command = pbShowCommands(commands)
            if cmdGiveItem >= 0 && command == cmdGiveItem
                unless canEditTeam
                    showNoTeamEditingMessage
                    next
                end
                item = nil
                pbFadeOutIn do
                    scene = PokemonBag_Scene.new
                    screen = PokemonBagScreen.new(scene, $PokemonBag)
                    item = screen.pbChooseItemScreen(proc { |itm| GameData::Item.get(itm).can_hold? })
                end
                dorefresh = pbGiveItemToPokemon(item, @pokemon, self) if item
            elsif cmdTakeItem >= 0 && command == cmdTakeItem
                unless canEditTeam
                    showNoTeamEditingMessage
                    next
                end
                dorefresh = pbTakeItemsFromPokemon(@pokemon) > 0
            elsif cmdPokedex >= 0 && command == cmdPokedex
                openSingleDexScreen(@pokemon)
                dorefresh = true
            elsif cmdMark >= 0 && command == cmdMark
                dorefresh = pbMarking(@pokemon)
            end
            return dorefresh
        end
    end

    def pbChooseMoveToForget(move_to_learn)
        new_move = move_to_learn ? Pokemon::Move.new(move_to_learn) : nil
        selmove = 0
        maxmove = new_move ? Pokemon::MAX_MOVES : Pokemon::MAX_MOVES - 1
        @sprites["pokemon"].visible = true unless @forget
        hideItems
        loop do
            Graphics.update
            Input.update
            pbUpdate
            if Input.trigger?(Input::BACK)
                selmove = Pokemon::MAX_MOVES
                pbPlayCloseMenuSE if new_move
                break
            elsif Input.trigger?(Input::USE)
                pbPlayDecisionSE
                break
            elsif Input.trigger?(Input::UP)
                selmove -= 1
                selmove = maxmove if selmove < 0
                selmove = @pokemon.numMoves - 1 if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
                @sprites["movesel"].index = selmove
                selected_move = (selmove == Pokemon::MAX_MOVES) ? new_move : @pokemon.moves[selmove]
                drawSelectedMove(new_move, selected_move)
            elsif Input.trigger?(Input::DOWN)
                selmove += 1
                selmove = 0 if selmove > maxmove
                if selmove < Pokemon::MAX_MOVES && selmove >= @pokemon.numMoves
                    selmove = new_move ? maxmove : 0
                end
                @sprites["movesel"].index = selmove
                selected_move = (selmove == Pokemon::MAX_MOVES) ? new_move : @pokemon.moves[selmove]
                drawSelectedMove(new_move, selected_move)
            elsif Input.trigger?(Input::ACTION)
                pbFadeOutIn do
                    @sprites["overlay"].bitmap.clear
                    pbTemporaryStatsScreen
                    @sprites["movesel"].visible = false
                    hideItems
                    @sprites["extraReminder"].visible = false
                    @sprites["pokemon"].visible = true
                end
                loop do
                    Graphics.update
                    Input.update
                    if Input.trigger?(Input::BACK)
                        pbPlayCancelSE
                        break
                    end
                end
                @sprites["movesel"].visible = true
                showItems
                @sprites["extraReminder"].visible = true
                @sprites["pokemon"].visible = false
                drawSelectedMove(new_move, @pokemon.moves[0])
                pbFadeInAndShow(@sprites)
            end
        end
        return (selmove == Pokemon::MAX_MOVES) ? -1 : selmove
    end

    def pbTemporaryStatsScreen
        refreshItemIcons
        overlay = @sprites["overlay"].bitmap
        overlay.clear
        base   = Color.new(248, 248, 248)
        shadow = Color.new(104, 104, 104)
        # Set background image
        @sprites["background"].setBitmap("Graphics/Pictures/Summary/bg_3z")
        imagepos = []
        # Show the Poké Ball containing the Pokémon
        ballimage = format("Graphics/Pictures/Summary/icon_ball_%s", @pokemon.poke_ball)
        unless pbResolveBitmap(ballimage)
            ballimage = format("Graphics/Pictures/Summary/icon_ball_%02d", pbGetBallType(@pokemon.poke_ball))
        end
        imagepos.push([ballimage, 14, 60])
        # Draw all images
        pbDrawImagePositions(overlay, imagepos)
        # Write various bits of text
        pagename = _INTL("SKILLS")
        textpos = [
            [pagename, 26, 10, 0, base, shadow],
            [@pokemon.name, 46, 56, 0, base, shadow],
            [@pokemon.level.to_s, 46, 86, 0, Color.new(64, 64, 64), Color.new(176, 176, 176)],
        ]
        # Write the gender symbol
        if @pokemon.male?
            textpos.push([_INTL("♂"), 178, 56, 0, Color.new(24, 112, 216), Color.new(136, 168, 208)])
        elsif @pokemon.female?
            textpos.push([_INTL("♀"), 178, 56, 0, Color.new(248, 56, 32), Color.new(224, 152, 144)])
        end
        # Draw all text
        pbDrawTextPositions(overlay, textpos)
        # Draw page-specific information
        base   = Color.new(248, 248, 248)
        shadow = Color.new(104, 104, 104)
        # Write various bits of text
        textpos = [
            [_INTL("HP"), 292, 70, 2, base, shadow],
            [format("%d/%d", @pokemon.hp, @pokemon.totalhp), 462, 70, 1, Color.new(64, 64, 64),
             Color.new(176, 176, 176),],
            [_INTL("Attack"), 248, 114, 0, base, shadow],
            [format("%d", @pokemon.attack), 456, 114, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
            [_INTL("Defense"), 248, 146, 0, base, shadow],
            [format("%d", @pokemon.defense), 456, 146, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
            [_INTL("Sp. Atk"), 248, 178, 0, base, shadow],
            [format("%d", @pokemon.spatk), 456, 178, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
            [_INTL("Sp. Def"), 248, 210, 0, base, shadow],
            [format("%d", @pokemon.spdef), 456, 210, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
            [_INTL("Speed"), 248, 242, 0, base, shadow],
            [format("%d", @pokemon.speed), 456, 242, 1, Color.new(64, 64, 64), Color.new(176, 176, 176)],
            [_INTL("Ability"), 16, 278, 0, base, shadow],
        ]
        # Draw ability name and description
        ability = @pokemon.ability
        if ability
            textpos.push([ability.name, 138, 278, 0, Color.new(64, 64, 64), Color.new(176, 176, 176)])
            drawTextEx(overlay, 8, 320, Graphics.width - 12, 2, ability.description, Color.new(64, 64, 64),
  Color.new(176, 176, 176))
        end
        # Draw Pokémon's type icon(s)
        type1_number = GameData::Type.get(@pokemon.type1).id_number
        type2_number = GameData::Type.get(@pokemon.type2).id_number
        type1rect = Rect.new(0, type1_number * 28, 64, 28)
        type2rect = Rect.new(0, type2_number * 28, 64, 28)
        if @pokemon.type1 == @pokemon.type2
            overlay.blt(310, 18, @typebitmap.bitmap, type1rect)
        else
            overlay.blt(276, 18, @typebitmap.bitmap, type1rect)
            overlay.blt(346, 18, @typebitmap.bitmap, type2rect)
        end
        # Draw all text
        pbDrawTextPositions(overlay, textpos)
    end

    def pbScene
        @pokemon.play_cry
        loop do
            Graphics.update
            Input.update
            pbUpdate
            dorefresh = false
            if Input.trigger?(Input::ACTION)
                pbSEStop
                @pokemon.play_cry
            elsif Input.trigger?(Input::BACK)
                pbPlayCloseMenuSE
                break
            elsif Input.trigger?(Input::USE)
                if @page == 4
                    pbPlayDecisionSE
                    pbMoveSelection
                    dorefresh = true
                elsif @page == 5
                    pbPlayDecisionSE
                    pbRibbonSelection
                    dorefresh = true
                elsif @battle.nil?
                    pbPlayDecisionSE
                    dorefresh = pbOptions
                end
            elsif Input.trigger?(Input::UP) && !@party.nil? && @partyindex > 0
                oldindex = @partyindex
                pbGoToPrevious
                if @partyindex != oldindex
                    pbChangePokemon
                    @ribbonOffset = 0
                    dorefresh = true
                end
            elsif Input.trigger?(Input::DOWN) && !@party.nil? && @partyindex < @party.length - 1
                oldindex = @partyindex
                pbGoToNext
                if @partyindex != oldindex
                    pbChangePokemon
                    @ribbonOffset = 0
                    dorefresh = true
                end
            elsif Input.trigger?(Input::LEFT) && !@pokemon.egg?
                oldpage = @page
                @page -= 1
                @page = 1 if @page < 1
                @page = 5 if @page > 5
                if @page != oldpage   # Move to next page
                    pbSEPlay("GUI summary change page")
                    @ribbonOffset = 0
                    dorefresh = true
                end
            elsif Input.trigger?(Input::RIGHT) && !@pokemon.egg?
                oldpage = @page
                @page += 1
                @page = 1 if @page < 1
                @page = 5 if @page > 5
                if @page != oldpage   # Move to next page
                    pbSEPlay("GUI summary change page")
                    @ribbonOffset = 0
                    dorefresh = true
                end
            end
            drawPage(@page) if dorefresh
        end
        return @partyindex
    end
end

#===============================================================================
#
#===============================================================================
class PokemonSummaryScreen
    def initialize(scene, battle = nil)
        @scene = scene
        @battle = battle
    end

    def pbStartScreen(party, partyindex)
        @scene.pbStartScene(party, partyindex, @battle)
        ret = @scene.pbScene
        @scene.pbEndScene
        return ret
    end

    def pbStartForgetScreen(party, partyindex, move_to_learn)
        ret = -1
        @scene.pbStartForgetScene(party, partyindex, move_to_learn)
        loop do
            ret = @scene.pbChooseMoveToForget(move_to_learn)
            break if ret < 0 || !move_to_learn
            break if $DEBUG || !party[partyindex].moves[ret].hidden_move?
            pbMessage(_INTL("HM moves can't be forgotten now.")) { @scene.pbUpdate }
        end
        @scene.pbEndScene
        return ret
    end

    def pbStartChooseMoveScreen(party, partyindex, message)
        ret = -1
        @scene.pbStartForgetScene(party, partyindex, nil)
        pbMessage(message) { @scene.pbUpdate }
        loop do
            ret = @scene.pbChooseMoveToForget(nil)
            break if ret >= 0
            pbMessage(_INTL("You must choose a move!")) { @scene.pbUpdate }
        end
        @scene.pbEndScene
        return ret
    end

    def pbStartSingleScreen(pokemon)
        @scene.pbStartSingleScene(pokemon)
        ret = @scene.pbScene
        @scene.pbEndScene
        return ret
    end
end

#===============================================================================
#
#===============================================================================
def pbChooseMove(pokemon, variableNumber, nameVarNumber)
    return unless pokemon
    ret = -1
    pbFadeOutIn do
        scene = PokemonSummary_Scene.new
        screen = PokemonSummaryScreen.new(scene)
        ret = screen.pbStartForgetScreen([pokemon], 0, nil)
    end
    $game_variables[variableNumber] = ret
    if ret >= 0
        $game_variables[nameVarNumber] = pokemon.moves[ret].name
    else
        $game_variables[nameVarNumber] = ""
    end
    $game_map.need_refresh = true if $game_map
end
