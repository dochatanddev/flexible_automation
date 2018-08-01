flexible_automation = {
  ref = {
    itemId = 'flexible_automation:ref',
    itemDefinition = {
      description = 'Reference Node for %s',
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

flexible_automation.ref.register()
flexible_automation.refTaker.register()