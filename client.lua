-- Context Menu(s)
lib.registerContext({
  id = 'main_menu',
  title = 'Main Menu',
  options = {
    {
      title = ' ', -- act as a separator.
      readOnly = true
    },
    {
      title = 'Button 2',
      description = 'Button should be disabled',
      icon = 'xmark',
      disabled = true
    },
    {
      title = ' ', -- act as a separator.
      readOnly = true
    },
    {
      title = 'button with metadata',
      description = 'This button should have some extra information.',
      icon = 'stop',
      onSelect = function()
        print('selected button with metadata')
      end,
      metadata = {
        {label = 'Charge', value = '$300'},
        {label = 'Sentence', value = '3 months'}
      }
    },
    {
      title = 'Menu button',
      description = 'Click to go into the submenu',
      menu = 'submenu',
      icon = 'bars'
    },
    {
      title = 'Event Button',
      description = 'clicking this will trigger an event.',
      icon = 'check',
      event = 'JaxEvent',
      args = {
        firstname = 'John',
        lastname = 'Doe'
      }
    }
  }
})

lib.registerContext({
  id = 'submenu',
  title = 'Submenu',
  menu = 'main_menu',
  onBack = function()
    print('Back button pressed. Returning to main menu.')
  end,
  options = {
    {
      title = 'Come back later.'
    }
  }

})

RegisterNetEvent('JaxEvent', function(args)
  print(args.firstname, args.lastname)
  lib.registerContext({
    id = 'event_menu',
    title = 'Menu from event button',
    menu = 'main_menu',
    options = {
      {
        title = 'Args.option: '..args.firstname.. ' '..args.lastname
      }
    }
  })

  lib.showContext('event_menu')
end)

RegisterCommand('contextmenu',function()
  lib.showContext('main_menu')
end)

RegisterCommand('input', function()
  local input = lib.inputDialog('Input REQUIRED!', {
    {type = 'input', label = 'First name', description = 'Enter first name', min = 3, max = 20},
    {type = 'checkbox', label = 'Requirements to be on server.', description = 'Are you allowed to play on this server?'}
  })
  if not input then return end
  print(json.encode(input), input[1], input[2])
  if input[1] == "" then print("Player did not have any input!") end

  local isChecked = input[2]
  if isChecked then 
    lib.notify({
      title = 'Server',
      description = 'Looks like you are allowed on the server.',
      type = 'inform',
      position = 'center-right',
      showDuration = true,
      iconAnimation = 'beatFade',
      duration = 5000,
      icon = 'check'
    })
    print('Player is allowed on the server!')
  else
    print('Player is not allowed on this server! Contacting admin to kick out player.')

    local alert = lib.alertDialog({
      header = 'Alert!',
      content = 'You are not allowed on this server! An Admin has been contacted to remove you.',
      centered = true,
      cancel = false,
      size = 'md',
      labels = {
        confirm = 'OK',
      }
    })

    print(alert)
    if alert == 'confirm' then 
      print('alert is ok.')
    end
    lib.notify({
      title = 'Server',
      description = 'Admin has been contacted. Please wait for your demise...',
      type = 'error',
      position = 'center-right',
      showDuration = true,
      duration = 8000,
      iconAnimation = 'spin',
      icon = 'stop',
      iconColor = 'aliceblue',
      style = {
        backgroundColor = 'darkred',
        color = 'gray',
        ['.description'] = {
          color = 'black'
        }
      }
    })
  end
end)

RegisterCommand('progbar', function() -- /progbar 5
  local isComplete = lib.skillCheck({'easy','medium',{ areaSize = 100, speedMultiplier = 1 }, 'medium', { '1', '2', '3'}})
  print(isComplete)
  if not isComplete then 
    lib.notify({
      title = 'Server',
      description = 'Failed the skillcheck. No interest calculation for you.',
      type = 'inform',
      position = 'center-right',
      duration = 5000,
    }) 
    return
  end
  
  
  local duration = 5000

  if lib.progressBar({
    duration = duration,
    label = 'Calculating interest...',
    useWhileDead = false,
    canCancel = true,
    disable = {
      car = true,
      combat = true,
      sprint = true
    },
    anim = {
      dict = 'mp_player_intdrink',
      clip = 'loop_bottle'
    },
  }) then 
    print('interest is now calculated.')
  else
    print('canceled progress bar for interest.')
  end

end)


-- Radial menu
exports('myMenuHandler', function(menu, item)
    print(menu, item)
 
    if menu == 'police_menu' and item == 1 then
        print('Handcuffs')
    end
end)
 
lib.registerRadial({
  id = 'police_menu',
  items = {
    {
      label = 'Handcuff',
      icon = 'handcuffs',
      onSelect = 'myMenuHandler'
    },
    {
      label = 'Frisk',
      icon = 'hand'
    },
    {
      label = 'Fingerprint',
      icon = 'fingerprint'
    },
    {
      label = 'Jail',
      icon = 'bus'
    },
    {
      label = 'Search',
      icon = 'magnifying-glass',
      onSelect = function()
        print('Search')
      end
    }
  }
})
 
lib.addRadialItem({
  {
    id = 'police',
    label = 'Police',
    icon = 'shield-halved',
    menu = 'police_menu'
  },
  {
    id = 'business_stuff',
    label = 'Business',
    icon = 'briefcase',
    onSelect = function()
      print("Business")
    end
  }
})
 
local coords = GetEntityCoords(cache.ped)
local point = lib.points.new(coords, 5)
 
function point:onEnter()
  lib.addRadialItem({
    id = 'garage_access',
    icon = 'warehouse',
    label = 'Garage',
    onSelect = function()
      print('Garage')
    end
  })
end
 
function point:onExit()
  lib.removeRadialItem('garage_access')
end


RegisterCommand('textui', function()
  lib.showTextUI('/input - shows input', {
    position = 'right-center',
    icon = 'comment',
    iconAnimation = 'spinReverse',
    style = {
      borderRadius = 2,
      backgroundColor = 'gray',
      color = 'white'
    }
  })
end)

RegisterCommand('forceclose', function()
  local isOpen = lib.isTextUIOpen()
  if isOpen then
    lib.hideTextUI()
  end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
  if(GetCurrentResourceName() ~= resourceName) then
    return
  end
  
  lib.hideTextUI()
  local contextMenus = lib.getOpenContextMenu()
  if contextMenus ~= nil then 
    lib.hideContext(contextMenus)
  end
  lib.hideRadial()
end)