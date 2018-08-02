flexible_automation = {
  mover = {
    itemId = 'flexible_automation:mover',
    generateFormspec = function(x,y,z, preparedSrcOptions, preparedTargetOptions, selectedSrcOption, selectedTargetOption)
      return string.format ( [[
size[10,10]
label[0,0;Source
ref here]
label[4,0;Filter
by block]
label[8,0;Target
ref here]
list[nodemeta:%s,%s,%s;srcRef;0,1;1,1]
list[nodemeta:%s,%s,%s;filterBlock;4,1;1,1]
list[nodemeta:%s,%s,%s;targetRef;8,1;1,1]
label[0,3;Select source inventory
     (down)]
label[5,3;Select target inventory
     (down)]
dropdown[0,4;5;srcOptions;%s;%s]
dropdown[5,4;5;targetOptions;%s;%s]
list[current_player;main;0,6;8,4;]
      ]],
      x,y,z,
      x,y,z,
      x,y,z,
      preparedSrcOptions, selectedSrcOption,
      preparedTargetOptions, selectedTargetOption
      )
    end,
    showFormspec = function(pos, player)
      local preparedSrcOptions = "source ref empty"
      local preparedTargetOptions = "target ref empty"
      local selectedSrcOption = 1
      local selectedTargetOption = 1
      
      local formspec = flexible_automation.mover.generateFormspec(
        pos.x, pos.y, pos.z,
        preparedSrcOptions,
        preparedTargetOptions,
        selectedSrcOption,
        selectedTargetOption
      )
      
      --minetest.debug(dump2(formspec))
      minetest.show_formspec(player:get_player_name(), 
        flexible_automation.mover.itemId .. 'GUI ' .. minetest.pos_to_string(pos),
        formspec
      )
    end,
    itemDefinition = {
      description = 'Item Mover',
      tiles = {
        "flexible_automation_mover.png",
        "flexible_automation_mover.png",
        "flexible_automation_mover.png",
        "flexible_automation_mover.png",
        "flexible_automation_mover.png",
        "flexible_automation_mover.png",
      },
      on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        inv:set_size("srcRef", 1)
        inv:set_size("targetRef", 1)
        inv:set_size("filterBlock", 1)
      end,
      on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        if not clicker then return end
        if not clicker:is_player() then return end
        
        flexible_automation.mover.showFormspec(pos, clicker)
      end,
      on_metadata_inventory_put = function(pos, listname, index, stack, player)
        --minetest.debug("InvPut")
        flexible_automation.mover.showFormspec(pos, player)
      end,
      on_metadata_inventory_take = function(pos, listname, index, stack, player)
        --minetest.debug("InvTake")
        flexible_automation.mover.showFormspec(pos, player)
      end,
      on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        --minetest.debug("InvMove")
        flexible_automation.mover.showFormspec(pos, player)
      end,
      on_receive_fields = function(pos, formname, fields, sender)
        --minetest.debug("Fields gotten!")
        flexible_automation.mover.showFormspec(pos, sender)
      end,
    },
    register = function()
      minetest.register_node(flexible_automation.mover.itemId, flexible_automation.mover.itemDefinition)
    end,
  },
  ref = {
    itemId = 'flexible_automation:ref',
    itemDefinition = {
      description = 'Reference Node for %s',
      inventory_image = 'flexible_automation_ref.png',
      stack_max = 1,
    },
    register = function()
      minetest.register_craftitem(flexible_automation.ref.itemId, flexible_automation.ref.itemDefinition)
    end,
  },
  refTaker = {
    itemId = 'flexible_automation:reftaker',
    itemDefinition = {
      description = 'Reference Taker Tool',
      inventory_image = 'flexible_automation_reftaker.png',
      on_use = function(itemstack, placer, pointed_thing)
        local pos = pointed_thing.under
        local player_name = user and user:get_player_name() or ""

        if minetest.is_protected(pos, player_name) then
          minetest.record_protection_violation(pos, player_name)
          return
        end
  
        if pointed_thing.type == 'node' then
          flexible_automation.refTaker.takeRef(itemstack, placer, pos)
        end
      end,
    },
    takeRef = function(itemstack, placer, pos)
      local ref = ItemStack(flexible_automation.ref.itemId)
      local meta = ref:get_meta()
      local desc = flexible_automation.ref.itemDefinition.description
      local posString = minetest.pos_to_string(pos)
      meta:set_string('description', string.format(desc, posString)) 
      meta:set_string('stored_pos', posString)
      
      local playerInventory = placer:get_inventory()
      playerInventory:add_item('main', ref)
    end,
    register = function()
      minetest.register_tool(flexible_automation.refTaker.itemId, flexible_automation.refTaker.itemDefinition)
    end,
  },
}

flexible_automation.mover.register()
flexible_automation.ref.register()
flexible_automation.refTaker.register()
