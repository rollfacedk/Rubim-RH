local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item

RubimRH.Spell[266] = {
    -- Racials
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    Fireblood = Spell(265221),

       -- Abilities
    DrainLife = Spell(234153),
    SummonTyrant = Spell(265187),
    SummonImp = Spell(688),
    SummonFelguard = Spell(30146),
    SummonDemonicTyrant = Spell(265187),
    DemonicPowerBuff = (265273),
    HandOfGuldan = Spell(105174),
    ShadowBolt = Spell(686),
    Demonbolt = Spell(264178),
    CallDreadStalkers = Spell(104316),
    Fear = Spell(5782),
    Implosion = Spell(196277),
    Shadowfury = Spell(30283),

    -- Pet abilities
    CauterizeMaster = Spell(119905), --imp
    Suffering = Spell(119907), --voidwalker
    SpellLock = Spell(119910), --Dogi
    Whiplash = Spell(119909), --Bitch
    AxeToss = Spell(119914), --FelGuard
    FelStorm = Spell(89751), --FelGuard

    -- Talents
    Dreadlash = Spell(264078),
    DemonicStrength = Spell(267171),
    BilescourgeBombers = Spell(267211),

    DemonicCalling = Spell(205145),
    PowerSiphon = Spell(264130),
    Doom = Spell(265412),

    DemonSkin = Spell(219272),
    BurningRush = Spell(111400),
    DarkPact = Spell(108416),

    FromTheShadows = Spell(267170),
    SoulStrike = Spell(264057),
    SummonVilefiend = Spell(264119),

    Darkfury = Spell(264874),
    MortalCoil = Spell(6789),
    DemonicCircle = Spell(268358),

    InnerDemons = Spell(267216),
    SoulConduit = Spell(215941),
    GrimoireFelguard = Spell(111898),

    SacrificedSouls = Spell(267214),
    DemonicConsumption = Spell(267215),
    NetherPortal = Spell(267217),
    NetherPortalBuff = Spell(267218),

    -- Defensive
    UnendingResolve = Spell(104773),

    -- Azerite
    ForbiddenKnowledge = Spell(279666),

    -- Utility

    -- Misc
    DemonicCallingBuff = Spell(205146),
    DemonicCoreBuff = Spell(264173)

}
local S = RubimRH.Spell[266]

-- Get if the pet are invoked. Parameter = true if you also want to test big pets
local function IsPetInvoked (testBigPets)
    testBigPets = testBigPets or false
    return S.Suffering:IsLearned() or S.SpellLock:IsLearned() or S.Whiplash:IsLearned() or S.CauterizeMaster:IsLearned() or S.AxeToss:IsLearned() or (testBigPets and (S.ShadowLock:IsLearned() or S.MeteorStrike:IsLearned()))
end

-- Calculate future shard count
local function FutureShard()
    local Shard = Player:SoulShards()
    if not Player:IsCasting() then
        return Shard
    else
        if Player:IsCasting(S.NetherPortal) then
            return Shard - 3
        elseif Player:IsCasting(S.CallDreadStalkers) and Player:BuffRemainsP(S.DemonicCallingBuff) == 0 then
            return Shard - 2
        elseif Player:IsCasting(S.CallDreadStalkers) and Player:BuffRemainsP(S.DemonicCallingBuff) > 0 then
            return Shard - 1
        elseif Player:IsCasting(S.SummonVilefiend) then
            return Shard - 1
        elseif Player:IsCasting(S.SummonFelguard) then
            return Shard - 1
        elseif Player:IsCasting(S.HandOfGuldan) then
            if Shard > 3 then
                return Shard - 3
            else
                return 0
            end
        elseif Player:IsCasting(S.Demonbolt) then
            if Shard >= 4 then
                return 5
            else
                return Shard + 2
            end
        elseif Player:IsCasting(S.Shadowbolt) then
            if Shard == 5 then
                return Shard
            else
                return Shard + 1
            end
        else
            return Shard
        end
    end
end

local function CDs ()
    -- Demonic Tyrant
    -- Remove once pet tracking is fixed
    if S.SummonTyrant:IsCastable(40) then
        --if RubimRH.Cast(S.SummonTyrant, Settings.Demonology.GCDasOffGCD.SummonTyrant) then return ""; end
    end

    -- actions+=/berserking
    if S.Berserking:IsAvailable() and S.Berserking:IsCastable() then

    end
end

local EnemyRanges = { 40 }
local function UpdateRanges()
    for _, i in ipairs(EnemyRanges) do
        HL.GetEnemies(i);
    end
end

local function APL()
    local Precombat, BuildAShard, Implosion, NetherPortal, NetherPortalActive, NetherPortalBuilding
    UpdateRanges()
    Precombat = function()
        -- flask
        -- food
        -- augmentation
        -- summon_pet
        if S.SummonPet:IsCastableP() then
            return S.SummonPet:Cast()
        end
        -- inner_demons,if=talent.inner_demons.enabled
        if S.InnerDemons:IsCastableP() and (S.InnerDemons:IsAvailable()) then
            return S.InnerDemons:Cast()
        end
        -- snapshot_stats
        -- potion
        -- demonbolt
        if S.Demonbolt:IsCastableP() then
            return S.Demonbolt:Cast()
        end
    end
    BuildAShard = function()
        -- demonbolt,if=azerite.forbidden_knowledge.enabled&buff.forbidden_knowledge.react&!buff.demonic_core.react&cooldown.summon_demonic_tyrant.remains>20
        if S.Demonbolt:IsCastableP() and (S.ForbiddenKnowledge:AzeriteEnabled() and (Player:Buff(S.ForbiddenKnowledgeBuff)) and not (Player:Buff(S.DemonicCoreBuff)) and S.SummonDemonicTyrant:CooldownRemainsP() > 20) then
            return S.Demonbolt:Cast()
        end
        -- soul_strike
        if S.SoulStrike:IsCastableP() then
            return S.SoulStrike:Cast()
        end
        -- shadow_bolt
        if S.ShadowBolt:IsCastableP() then
            return S.ShadowBolt:Cast()
        end
    end
    Implosion = function()
        -- implosion,if=(buff.wild_imps.stack>=6&(soul_shard<3|prev_gcd.1.call_dreadstalkers|buff.wild_imps.stack>=9|prev_gcd.1.bilescourge_bombers|(!prev_gcd.1.hand_of_guldan&!prev_gcd.2.hand_of_guldan))&!prev_gcd.1.hand_of_guldan&!prev_gcd.2.hand_of_guldan&buff.demonic_power.down)|(time_to_die<3&buff.wild_imps.stack>0)|(prev_gcd.2.call_dreadstalkers&buff.wild_imps.stack>2&!talent.demonic_calling.enabled)
        if S.Implosion:IsCastableP() and ((Player:BuffStackP(S.WildImpsBuff) >= 6 and (Player:SoulShardsP() < 3 or Player:PrevGCDP(1, S.CallDreadstalkers) or Player:BuffStackP(S.WildImpsBuff) >= 9 or Player:PrevGCDP(1, S.BilescourgeBombers) or (not Player:PrevGCDP(1, S.HandofGuldan) and not Player:PrevGCDP(2, S.HandofGuldan))) and not Player:PrevGCDP(1, S.HandofGuldan) and not Player:PrevGCDP(2, S.HandofGuldan) and Player:BuffDownP(S.DemonicPowerBuff)) or (Target:TimeToDie() < 3 and Player:BuffStackP(S.WildImpsBuff) > 0) or (Player:PrevGCDP(2, S.CallDreadstalkers) and Player:BuffStackP(S.WildImpsBuff) > 2 and not S.DemonicCalling:IsAvailable())) then
            return S.Implosion:Cast()
        end
        -- grimoire_felguard,if=cooldown.summon_demonic_tyrant.remains<13|!equipped.132369
        if S.GrimoireFelguard:IsCastableP() and (S.SummonDemonicTyrant:CooldownRemainsP() < 13) then
            return S.GrimoireFelguard:Cast()
        end
        -- call_dreadstalkers,if=(cooldown.summon_demonic_tyrant.remains<9&buff.demonic_calling.remains)|(cooldown.summon_demonic_tyrant.remains<11&!buff.demonic_calling.remains)|cooldown.summon_demonic_tyrant.remains>14
        if S.CallDreadstalkers:IsCastableP() and ((S.SummonDemonicTyrant:CooldownRemainsP() < 9 and (Player:Buff(S.DemonicCallingBuff))) or (S.SummonDemonicTyrant:CooldownRemainsP() < 11 and not (Player:Buff(S.DemonicCallingBuff))) or S.SummonDemonicTyrant:CooldownRemainsP() > 14) then
            return S.CallDreadstalkers:Cast()
        end
        -- summon_demonic_tyrant
        if S.SummonDemonicTyrant:IsCastableP() then
            return S.SummonDemonicTyrant:Cast()
        end
        -- hand_of_guldan,if=soul_shard>=5
        if S.HandofGuldan:IsCastableP() and (Player:SoulShardsP() >= 5) then
            return S.HandofGuldan:Cast()
        end
        -- hand_of_guldan,if=soul_shard>=3&(((prev_gcd.2.hand_of_guldan|buff.wild_imps.stack>=3)&buff.wild_imps.stack<9)|cooldown.summon_demonic_tyrant.remains<=gcd*2|buff.demonic_power.remains>gcd*2)
        if S.HandofGuldan:IsCastableP() and (Player:SoulShardsP() >= 3 and (((Player:PrevGCDP(2, S.HandofGuldan) or Player:BuffStackP(S.WildImpsBuff) >= 3) and Player:BuffStackP(S.WildImpsBuff) < 9) or S.SummonDemonicTyrant:CooldownRemainsP() <= Player:GCD() * 2 or Player:BuffRemainsP(S.DemonicPowerBuff) > Player:GCD() * 2)) then
            return S.HandofGuldan:Cast()
        end
        -- demonbolt,if=prev_gcd.1.hand_of_guldan&soul_shard>=1&(buff.wild_imps.stack<=3|prev_gcd.3.hand_of_guldan)&soul_shard<4&buff.demonic_core.up
        if S.Demonbolt:IsCastableP() and (Player:PrevGCDP(1, S.HandofGuldan) and Player:SoulShardsP() >= 1 and (Player:BuffStackP(S.WildImpsBuff) <= 3 or Player:PrevGCDP(3, S.HandofGuldan)) and Player:SoulShardsP() < 4 and Player:BuffP(S.DemonicCoreBuff)) then
            return S.Demonbolt:Cast()
        end
        -- summon_vilefiend,if=(cooldown.summon_demonic_tyrant.remains>40&spell_targets.implosion<=2)|cooldown.summon_demonic_tyrant.remains<12
        if S.SummonVilefiend:IsCastableP() and ((S.SummonDemonicTyrant:CooldownRemainsP() > 40 and Cache.EnemiesCount[40] <= 2) or S.SummonDemonicTyrant:CooldownRemainsP() < 12) then
            return S.SummonVilefiend:Cast()
        end
        -- bilescourge_bombers,if=cooldown.summon_demonic_tyrant.remains>9
        if S.BilescourgeBombers:IsCastableP() and (S.SummonDemonicTyrant:CooldownRemainsP() > 9) then
            return S.BilescourgeBombers:Cast()
        end
        -- soul_strike,if=soul_shard<5&buff.demonic_core.stack<=2
        if S.SoulStrike:IsCastableP() and (Player:SoulShardsP() < 5 and Player:BuffStackP(S.DemonicCoreBuff) <= 2) then
            return S.SoulStrike:Cast()
        end
        -- demonbolt,if=soul_shard<=3&buff.demonic_core.up&(buff.demonic_core.stack>=3|buff.demonic_core.remains<=gcd*5.7)
        if S.Demonbolt:IsCastableP() and (Player:SoulShardsP() <= 3 and Player:BuffP(S.DemonicCoreBuff) and (Player:BuffStackP(S.DemonicCoreBuff) >= 3 or Player:BuffRemainsP(S.DemonicCoreBuff) <= Player:GCD() * 5.7)) then
            return S.Demonbolt:Cast()
        end
        -- doom,cycle_targets=1,max_cycle_targets=7,if=refreshable
        if S.Doom:IsCastableP() and (Target:DebuffRefreshableCP(S.DoomDebuff)) then
            return S.Doom:Cast()
        end
        -- call_action_list,name=build_a_shard
        if (true) then
            if BuildAShard() ~= nil then
                return BuildAShard()
            end
        end
    end
    NetherPortal = function()
        -- call_action_list,name=nether_portal_building,if=cooldown.nether_portal.remains<20
        if (S.NetherPortal:CooldownRemainsP() < 20) then
            if NetherPortalBuilding() ~= nil then
                return NetherPortalBuilding()
            end
        end
        -- call_action_list,name=nether_portal_active,if=cooldown.nether_portal.remains>160
        if (S.NetherPortal:CooldownRemainsP() > 160) then
            if NetherPortalActive() ~= nil then
                return NetherPortalActive()
            end
        end
    end
    NetherPortalActive = function()
        -- grimoire_felguard,if=cooldown.summon_demonic_tyrant.remains<13|!equipped.132369
        if S.GrimoireFelguard:IsCastableP() and (S.SummonDemonicTyrant:CooldownRemainsP() < 13) then
            return S.GrimoireFelguard:Cast()
        end
        -- summon_vilefiend,if=cooldown.summon_demonic_tyrant.remains>40|cooldown.summon_demonic_tyrant.remains<12
        if S.SummonVilefiend:IsCastableP() and (S.SummonDemonicTyrant:CooldownRemainsP() > 40 or S.SummonDemonicTyrant:CooldownRemainsP() < 12) then
            return S.SummonVilefiend:Cast()
        end
        -- call_dreadstalkers,if=(cooldown.summon_demonic_tyrant.remains<9&buff.demonic_calling.remains)|(cooldown.summon_demonic_tyrant.remains<11&!buff.demonic_calling.remains)|cooldown.summon_demonic_tyrant.remains>14
        if S.CallDreadstalkers:IsCastableP() and ((S.SummonDemonicTyrant:CooldownRemainsP() < 9 and (Player:Buff(S.DemonicCallingBuff))) or (S.SummonDemonicTyrant:CooldownRemainsP() < 11 and not (Player:Buff(S.DemonicCallingBuff))) or S.SummonDemonicTyrant:CooldownRemainsP() > 14) then
            return S.CallDreadstalkers:Cast()
        end
        -- call_action_list,name=build_a_shard,if=soul_shard=1&(cooldown.call_dreadstalkers.remains<action.shadow_bolt.cast_time|(talent.bilescourge_bombers.enabled&cooldown.bilescourge_bombers.remains<action.shadow_bolt.cast_time))
        if (Player:SoulShardsP() == 1 and (S.CallDreadstalkers:CooldownRemainsP() < S.ShadowBolt:CastTime() or (S.BilescourgeBombers:IsAvailable() and S.BilescourgeBombers:CooldownRemainsP() < S.ShadowBolt:CastTime()))) then
            if BuildAShard() ~= nil then
                return BuildAShard()
            end
        end
        -- hand_of_guldan,if=((cooldown.call_dreadstalkers.remains>action.demonbolt.cast_time)&(cooldown.call_dreadstalkers.remains>action.shadow_bolt.cast_time))&cooldown.nether_portal.remains>(160+action.hand_of_guldan.cast_time)
        if S.HandofGuldan:IsCastableP() and (((S.CallDreadstalkers:CooldownRemainsP() > S.Demonbolt:CastTime()) and (S.CallDreadstalkers:CooldownRemainsP() > S.ShadowBolt:CastTime())) and S.NetherPortal:CooldownRemainsP() > (160 + S.HandofGuldan:CastTime())) then
            return S.HandofGuldan:Cast()
        end
        -- summon_demonic_tyrant,if=buff.nether_portal.remains<10&soul_shard=0
        if S.SummonDemonicTyrant:IsCastableP() and (Player:BuffRemainsP(S.NetherPortalBuff) < 10 and Player:SoulShardsP() == 0) then
            return S.SummonDemonicTyrant:Cast()
        end
        -- summon_demonic_tyrant,if=buff.nether_portal.remains<action.summon_demonic_tyrant.cast_time+5.5
        if S.SummonDemonicTyrant:IsCastableP() and (Player:BuffRemainsP(S.NetherPortalBuff) < S.SummonDemonicTyrant:CastTime() + 5.5) then
            return S.SummonDemonicTyrant:Cast()
        end
        -- demonbolt,if=buff.demonic_core.up
        if S.Demonbolt:IsCastableP() and (Player:BuffP(S.DemonicCoreBuff)) then
            return S.Demonbolt:Cast()
        end
        -- call_action_list,name=build_a_shard
        if (true) then
            if BuildAShard() ~= nil then
                return BuildAShard()
            end
        end
    end
    NetherPortalBuilding = function()
        -- nether_portal,if=soul_shard>=5&(!talent.power_siphon.enabled|buff.demonic_core.up)
        if S.NetherPortal:IsCastableP() and (Player:SoulShardsP() >= 5 and (not S.PowerSiphon:IsAvailable() or Player:BuffP(S.DemonicCoreBuff))) then
            return S.NetherPortal:Cast()
        end
        -- call_dreadstalkers
        if S.CallDreadstalkers:IsCastableP() then
            return S.CallDreadstalkers:Cast()
        end
        -- hand_of_guldan,if=cooldown.call_dreadstalkers.remains>18&soul_shard>=3
        if S.HandofGuldan:IsCastableP() and (S.CallDreadstalkers:CooldownRemainsP() > 18 and Player:SoulShardsP() >= 3) then
            return S.HandofGuldan:Cast()
        end
        -- power_siphon,if=buff.wild_imps.stack>=2&buff.demonic_core.stack<=2&buff.demonic_power.down&soul_shard>=3
        if S.PowerSiphon:IsCastableP() and (Player:BuffStackP(S.WildImpsBuff) >= 2 and Player:BuffStackP(S.DemonicCoreBuff) <= 2 and Player:BuffDownP(S.DemonicPowerBuff) and Player:SoulShardsP() >= 3) then
            return S.PowerSiphon:Cast()
        end
        -- hand_of_guldan,if=soul_shard>=5
        if S.HandofGuldan:IsCastableP() and (Player:SoulShardsP() >= 5) then
            return S.HandofGuldan:Cast()
        end
        -- call_action_list,name=build_a_shard
        if (true) then
            if BuildAShard() ~= nil then
                return BuildAShard()
            end
        end
    end
    -- call precombat
    if not Player:AffectingCombat() and not Player:IsCasting() then
        if Precombat() ~= nil then
            return Precombat()
        end
    end
    if RubimRH.TargetIsValid() then
        -- potion,if=pet.demonic_tyrant.active|target.time_to_die<30
        -- use_items,if=pet.demonic_tyrant.active|target.time_to_die<=15
        -- berserking,if=pet.demonic_tyrant.active|target.time_to_die<=15
        if S.Berserking:IsCastableP() and RubimRH.CDsON() and Player:Buff(S.DemonicPowerBuff) or Target:TimeToDie() <= 15 then
            return S.Berserking:Cast()
        end
        -- blood_fury,if=pet.demonic_tyrant.active|target.time_to_die<=15
        if S.BloodFury:IsCastableP() and RubimRH.CDsON() and Player:Buff(S.DemonicPowerBuff) or Target:TimeToDie() <= 15 then
            return S.BloodFury:Cast()
        end
        -- fireblood,if=pet.demonic_tyrant.active|target.time_to_die<=15
        if S.Fireblood:IsCastableP() and RubimRH.CDsON() and Player:Buff(S.DemonicPowerBuff) or Target:TimeToDie() <= 15 then
            return S.Fireblood:Cast()
        end
        -- doom,if=!ticking&time_to_die>30&spell_targets.implosion<2
        if S.Doom:IsCastableP() and (not Target:DebuffP(S.DoomDebuff) and Target:TimeToDie() > 30 and Cache.EnemiesCount[40] < 2) then
            return S.Doom:Cast()
        end
        -- demonic_strength,if=(buff.wild_imps.stack<6|buff.demonic_power.up)|spell_targets.implosion<2
        if S.DemonicStrength:IsCastableP() and ((Player:BuffStackP(S.WildImpsBuff) < 6 or Player:BuffP(S.DemonicPowerBuff)) or Cache.EnemiesCount[40] < 2) then
            return S.DemonicStrength:Cast()
        end
        -- call_action_list,name=nether_portal,if=talent.nether_portal.enabled&spell_targets.implosion<=2
        if (S.NetherPortal:IsAvailable() and Cache.EnemiesCount[40] <= 2) then
            if NetherPortal() ~= nil then
                return NetherPortal()
            end
        end
        -- call_action_list,name=implosion,if=spell_targets.implosion>1
        if (Cache.EnemiesCount[40] > 1) then
            if Implosion() ~= nil then
                return Implosion()
            end
        end
        -- grimoire_felguard,if=cooldown.summon_demonic_tyrant.remains<13|!equipped.132369
        if S.GrimoireFelguard:IsCastableP() and (S.SummonDemonicTyrant:CooldownRemainsP() < 13) then
            return S.GrimoireFelguard:Cast()
        end
        -- summon_vilefiend,if=equipped.132369|cooldown.summon_demonic_tyrant.remains>40|cooldown.summon_demonic_tyrant.remains<12
        if S.SummonVilefiend:IsCastableP() and (S.SummonDemonicTyrant:CooldownRemainsP() > 40 or S.SummonDemonicTyrant:CooldownRemainsP() < 12) then
            return S.SummonVilefiend:Cast()
        end
        -- call_dreadstalkers,if=equipped.132369|(cooldown.summon_demonic_tyrant.remains<9&buff.demonic_calling.remains)|(cooldown.summon_demonic_tyrant.remains<11&!buff.demonic_calling.remains)|cooldown.summon_demonic_tyrant.remains>14
        if S.CallDreadstalkers:IsCastableP() and ((S.SummonDemonicTyrant:CooldownRemainsP() < 9 and bool(Player:BuffRemainsP(S.DemonicCallingBuff))) or (S.SummonDemonicTyrant:CooldownRemainsP() < 11 and not bool(Player:BuffRemainsP(S.DemonicCallingBuff))) or S.SummonDemonicTyrant:CooldownRemainsP() > 14) then
            return S.CallDreadstalkers:Cast()
        end
        -- summon_demonic_tyrant,if=ptr=0&(equipped.132369|(buff.dreadstalkers.remains>cast_time&(buff.wild_imps.stack>=3|prev_gcd.1.hand_of_guldan)&(soul_shard<3|buff.dreadstalkers.remains<gcd*2.7|buff.grimoire_felguard.remains<gcd*2.7)))
        if S.SummonDemonicTyrant:IsCastableP() and (ptr == 0 and ((Player:BuffRemainsP(S.DreadstalkersBuff) > S.SummonDemonicTyrant:CastTime() and (Player:BuffStackP(S.WildImpsBuff) >= 3 or Player:PrevGCDP(1, S.HandofGuldan)) and (Player:SoulShardsP() < 3 or Player:BuffRemainsP(S.DreadstalkersBuff) < Player:GCD() * 2.7 or Player:BuffRemainsP(S.GrimoireFelguardBuff) < Player:GCD() * 2.7)))) then
            return S.SummonDemonicTyrant:Cast()
        end
        -- summon_demonic_tyrant,if=ptr=1&(equipped.132369|(buff.dreadstalkers.remains>cast_time&(buff.wild_imps.stack>=3+talent.inner_demons.enabled+talent.demonic_consumption.enabled*3|prev_gcd.1.hand_of_guldan&(!talent.demonic_consumption.enabled|buff.wild_imps.stack>=3+talent.inner_demons.enabled))&(soul_shard<3|buff.dreadstalkers.remains<gcd*2.7|buff.grimoire_felguard.remains<gcd*2.7)))
        if S.SummonDemonicTyrant:IsCastableP() and (ptr == 1 and ((Player:BuffRemainsP(S.DreadstalkersBuff) > S.SummonDemonicTyrant:CastTime() and (Player:BuffStackP(S.WildImpsBuff) >= 3 + num(S.InnerDemons:IsAvailable()) + num(S.DemonicConsumption:IsAvailable()) * 3 or Player:PrevGCDP(1, S.HandofGuldan) and (not S.DemonicConsumption:IsAvailable() or Player:BuffStackP(S.WildImpsBuff) >= 3 + num(S.InnerDemons:IsAvailable()))) and (Player:SoulShardsP() < 3 or Player:BuffRemainsP(S.DreadstalkersBuff) < Player:GCD() * 2.7 or Player:BuffRemainsP(S.GrimoireFelguardBuff) < Player:GCD() * 2.7)))) then
            return S.SummonDemonicTyrant:Cast()
        end
        -- power_siphon,if=buff.wild_imps.stack>=2&buff.demonic_core.stack<=2&buff.demonic_power.down&spell_targets.implosion<2
        if S.PowerSiphon:IsCastableP() and (Player:BuffStackP(S.WildImpsBuff) >= 2 and Player:BuffStackP(S.DemonicCoreBuff) <= 2 and Player:BuffDownP(S.DemonicPowerBuff) and Cache.EnemiesCount[40] < 2) then
            return S.PowerSiphon:Cast()
        end
        -- doom,if=talent.doom.enabled&refreshable&time_to_die>(dot.doom.remains+30)
        if S.Doom:IsCastableP() and (S.Doom:IsAvailable() and Target:DebuffRefreshableCP(S.DoomDebuff) and Target:TimeToDie() > (Target:DebuffRemainsP(S.DoomDebuff) + 30)) then
            return S.Doom:Cast()
        end
        -- hand_of_guldan,if=soul_shard>=5|(soul_shard>=3&cooldown.call_dreadstalkers.remains>4&(!talent.summon_vilefiend.enabled|cooldown.summon_vilefiend.remains>3))
        if S.HandofGuldan:IsCastableP() and (Player:SoulShardsP() >= 5 or (Player:SoulShardsP() >= 3 and S.CallDreadstalkers:CooldownRemainsP() > 4 and (not S.SummonVilefiend:IsAvailable() or S.SummonVilefiend:CooldownRemainsP() > 3))) then
            return S.HandofGuldan:Cast()
        end
        -- soul_strike,if=soul_shard<5&buff.demonic_core.stack<=2
        if S.SoulStrike:IsCastableP() and (Player:SoulShardsP() < 5 and Player:BuffStackP(S.DemonicCoreBuff) <= 2) then
            return S.SoulStrike:Cast()
        end
        -- demonbolt,if=soul_shard<=3&buff.demonic_core.up&((cooldown.summon_demonic_tyrant.remains<10|cooldown.summon_demonic_tyrant.remains>22)|buff.demonic_core.stack>=3|buff.demonic_core.remains<5|time_to_die<25)
        if S.Demonbolt:IsCastableP() and (Player:SoulShardsP() <= 3 and Player:BuffP(S.DemonicCoreBuff) and ((S.SummonDemonicTyrant:CooldownRemainsP() < 10 or S.SummonDemonicTyrant:CooldownRemainsP() > 22) or Player:BuffStackP(S.DemonicCoreBuff) >= 3 or Player:BuffRemainsP(S.DemonicCoreBuff) < 5 or Target:TimeToDie() < 25)) then
            return S.Demonbolt:Cast()
        end
        -- bilescourge_bombers,if=ptr=1
        if S.BilescourgeBombers:IsCastableP() and (ptr == 1) then
            return S.BilescourgeBombers:Cast()
        end
        -- call_action_list,name=build_a_shard
        if (true) then
            if BuildAShard() ~= nil then
                return BuildAShard()
            end
        end
    end
end

RubimRH.Rotation.SetAPL(266, APL)

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(266, PASSIVE)