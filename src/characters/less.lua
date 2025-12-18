local mod = _G.xMasMod
local LESS_VARIANT = Isaac.Get:-1 -- create new character
local LESS_PLAYER_TYPE = Isaac.GetPlayerTypeByName("Alessandro il Goat") -- obtain ch id
local PROCIONE_ID = Isaac.getCollectibleTypeByName("Storia del procione") -- obtain item id
local PROCIONE_SFX = Isaac.getSoundIDByNamw("Racoon") -- obtain sfx id


-- function to initialize the character on run start
function mod:OnGameStarted()
    if Game():GetPlayer(0):GetPlayerType() == LESS_PLAYER_TYPE then
        -- Imposta le statistiche di base di Isaac
        local player = Game():GetPlayer(0)
        player:SetMaxHearts(6) -- 3 cuori rossi
        player:SetHearts(8)
        player:SetDamage(4.5)
        player:SetFireDelay(10)
        player:SetShotSpeed(1.1)
        player:SetRange(23)
        player:SetSpeed(1)

        -- Aggiunge la "Storia del Procione" come oggetto tascabile
        player:AddCollectible(PROCIONE_ID, 0, true) -- 0 è il variant, true per non visualizzare il pop-up
        player:SetActiveCharge(6) -- Imposta la carica iniziale a 6
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.OnGameStarted)

-- stats and initial item
function mod:OnLessInit(player)
    if player:GetPlayerType() ==LESS_PLAYER_TYPE then
        if not player:HasCollectible(PROCIONE_ID) then
        player:AddCollectible(PROCIONE_ID, 0, false, ActiveSlot.SLOT_POCKET)
        end

        player.SpriteScale = Vector(0.8, 0.8)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.onLessInit)

-- item utilization
function mod:UseProcione(_, _, player, flags, slot)
    -- Controllo per evitare problemi con Car Battery o usi multipli nello stesso frame
    local enemies = Isaac.FindInRadius(player.Position, 1000, EntityPartition.ENEMY)
    
    -- Effetto sonoro (opzionale, usa uno di base se non ne hai uno custom)
    SFXManager():Play(SoundEffect.PROCIONE_SFX, 1, 0, false, 1)

    for _, entity in ipairs(enemies) do
        if entity:IsVulnerableEnemy() and not entity:IsFriendly() then
            entity:TakeDamage(30, 0, EntityRef(player), 0)
            -- Cast a NPC to use AddFear
            local npc = entity:ToNPC()
            if npc then
                npc:AddFear(EntityRef(player), 90) -- 90 frame = 3 seconds
            end
        end
    end
    
    -- utilization animation
    player:AnimateCollectible(PROCIONE_ID, "UseItem", "Idle")
    
    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UseProcione, PROCIONE_ID)