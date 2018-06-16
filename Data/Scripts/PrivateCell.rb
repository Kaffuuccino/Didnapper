

class PC_main
  def initialize
    $game_system.ums_mode = NORMAL_MODE
    $game_system.window_height = 110
    $game_system.window_width = 430
    $game_system.window_width = 485
    $game_system.opacity = 200
    $game_system.text_justification = CENTER
    $game_system.text_mode = WRITE_ALL
    $game_system.text_mode = WRITE_FASTER
    $game_system.text_skip = true
    
    $game_switches[276] = true # PC occupied
    $game_switches[561] = true # Custom window position
    
    $game_variables[407] = 0
    $game_variables[408] = 370
    
    $game_variables[467] = 2
    $game_variables[468] = 3 + rand(1) # 3 - 4
    $game_variables[41] = 0
    
    $game_variables[481] = 0
    $game_variables[482] = -20
    
    $game_variables[483] = 498
    $game_variables[484] = 12
    
    #$currentPrivateCellDamsel = "suki"
    
    damsel = $privateCellDamsels[$currentPrivateCellDamsel]
    
    @menuTalk = [
     {"name" => "speak", "action" => "speak"},
     {"name" => "charm", "action" => "charm"},
     {"name" => "compliment", "action" => "complient"},
     {"name" => "insult", "action" => "insult"},
     {"name" => "threaten", "action" => "threaten"},
    ]
    
    @menuAction = [
      {"name" => "slap", "action" => "slap"},
      {"name" => "tickle", "action" => "tickle"},
      {"name" => "kiss", "action" => "kiss"},
      {"name" => "grope", "action" => "grope"},
    ]
    
    @menuOutfit = [
      "name" => "outfit",
      "array" => damsel.getOutfits(),
    ]
    
    @menuPosition = [
      {"name" => "behind back", "action" => "outfitdefault"},
      {"name" => "overhead", "action" => "outfitdefault2"},
      {"name" => "in front", "action" => "outfitdefault3"},
    ]
    
    @menuGag = [
      {"name" => "cloth", "action" => "clothgag"},
      {"name" => "otn", "action" => "otngag"},
      {"name" => "cleave", "action" => "cleavegag"},
      {"name" => "knotted cleave", "action" => "knotgag"},
      {"name" => "ball", "action" => "ballgag"},
      {"name" => "bit", "action" => "bitgag"},
      {"name" => "special", "array" => damsel.getSpecialGags()},
      {"name" => "ungag", "action" => "ungag"},
    ]
    
    @menuMain = [
      {
        "name" => "talk",
        "sub" => @menuTalk,
      },
      {
        "name" => "action",
        "sub" => @menuAction,
      },
      {
        "name" => "outfit",
        "sub" => @menuOutfit,
      },
      {
        "name" => "position",
        "sub" => @menuPosition,
      },
      {
        "name" => "gag",
        "sub" => @menuGag,
      },
      {
        "name" => "blindfold",
        "action" => "blindfold",
      },
      {
        "name" => "remove",
        "action" => "cancel",
      },
      {
        "name" => "quit",
        "action" => "quit",
      },
    ]
    
    @menu = @menuMain
    @menuLength = 0
    
    @background = Sprite.new()
    @background.bitmap = Bitmap.new(640, 480)
    @background.bitmap.fill_rect(0, 0, 640, 480, Color.new(0,0,0, 150))
    
    @sidebar = Sprite.new()
    @sidebar.x = 520
    @sidebar.bitmap = Bitmap.new(120, 320)
    
    @pointer = Sprite.new()
    @pointer.bitmap = Bitmap.new(20, 20)
    @pointer.bitmap.fill_rect(0, 0, 20, 20, Color.new(255,255,255))
    @pointer.x = 520
    @pointer.y = 10
    
    @breadcrumbs = [];
    @select = 0
    @selectH = 0
    
    pc_action("outfitdefault")
    pc_action("intro")
    pc_regen()
    redraw_menu()
  end
  
  def step
    loop do
      pc_regen()
      Graphics.update()
      Input.update()
      
      if $game_variables[425] == 1
        if Input.trigger?(Input::C)
          pc_action("")
          end
        next
      end
      
      if Input.trigger?(Input::UP)
        @select -= 1
        if @select < 0
          @select = @menuLength - 1
        end
      end
      
      if Input.trigger?(Input::DOWN)
        @select += 1
        if @select >= @menuLength
          @select = 0
        end
      end
      
      if Input.trigger?(Input::LEFT)
        if @select < @menu.length && @menu[@select].has_key?("array")
          @selectH -= 1
          if @selectH < 0
            @selectH = @menu[@select]["array"].length - 1
          end
        end
        redraw_menu()
      end
      
      if Input.trigger?(Input::RIGHT)
        if @select < @menu.length && @menu[@select].has_key?("array")
          @selectH += 1
          if @selectH >= @menu[@select]["array"].length
            @selectH = 0
          end
        end
        redraw_menu()
      end
      
      if Input.trigger?(Input::C)
        if @select < @menu.length
          item = @menu[@select]
        else 
          item = @menuExtra[@select - @menu.length]
        end
        if item.has_key?("sub")
          @menu = item["sub"]
          @breadcrumbs.push(@select)
          @select = 0
          @selectH = 0
          redraw_menu()
        elsif item["action"] == "quit"
          break
        elsif item.has_key?("action")
          if item["action"].kind_of?(Array)
            item["action"].each do |action|
              pc_action(action)
            end
          else
            pc_action(item["action"])
            if item["action"] == "cancel"
              $game_switches[276] = false
              break
            end
          end
        elsif item.has_key?("array") && item["array"].length > 0
          pc_action(item["array"][@selectH]["action"])
        end
      end
      
      if Input.trigger?(Input::B)
        @menu = @menuMain
        if @breadcrumbs.length > 0
          @select = @breadcrumbs.pop()
          @selectH = 0
        end
        redraw_menu()
      end
      
      @pointer.y = 10 + @select * 40
    end
    
    unload()
  end
  
  def unload
    @background.dispose
    @sidebar.dispose
    @pointer.dispose
    
    pc_action("cancel")
    
    $override_pic['pc_canvas'].clear()
  
    $game_system.ums_mode = FIT_WINDOW_TO_TEXT
    $game_system.text_mode = WRITE_FASTER
    $game_system.text_justification = LEFT
    $game_system.text_skip = true
    $game_system.opacity = 160
    $game_system.opacity = 255
    $game_system.message_event = -1
    $game_system.name = ""
    
    #$game_switches[276] = false # This set the PC as unoccupied
    $game_switches[561] = false
  end
    

  def redraw_menu
    @sidebar.bitmap.clear()
    @sidebar.bitmap.fill_rect(0, 0, 120, 320, Color.new(0,0,0, 200))
    
    if @select < @menu.length
      @menuExtra = []
      item = @menu[@select]
      if item.has_key?("array") && item["array"].length > 0 && item["array"][@selectH].has_key?("acc")
        @menuExtra = item["array"][@selectH]["acc"]
      end
    end
    
    counter = 0
    @menu.each do |value|
      text = value["name"]
      if value.has_key?("array") && value["array"].length > 0
        text = value["array"][@selectH]["name"]
      end
      @sidebar.bitmap.draw_text(0, counter * 40, 120, 40, text, 1)
      counter += 1
    end
    @menuExtra.each do |value|
      @sidebar.bitmap.draw_text(0, counter * 40, 120, 40, value["name"], 1)
      counter += 1
    end
    
    @menuLength = @menu.length + @menuExtra.length
  end
  
end