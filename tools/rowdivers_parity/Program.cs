using System;
using System.IO;
using System.Text.Json;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
class Program {
 static JsonElement catalog;
 static object Call(object target,string name,params object[] args){for(Type t=target.GetType();t!=null;t=t.BaseType){var m=t.GetMethod(name,BindingFlags.Public|BindingFlags.NonPublic|BindingFlags.Instance|BindingFlags.DeclaredOnly);if(m!=null)return m.Invoke(target,args);}throw new Exception(name);}
 static void Set(object target,string name,object v){for(Type t=target.GetType();t!=null;t=t.BaseType){var f=t.GetField(name,BindingFlags.Public|BindingFlags.NonPublic|BindingFlags.Instance|BindingFlags.DeclaredOnly);if(f!=null){if(f.FieldType.IsEnum)v=Enum.ToObject(f.FieldType,v);f.SetValue(target,v);return;}}throw new Exception(name);}
 static T Get<T>(object target,string name){for(Type t=target.GetType();t!=null;t=t.BaseType){var f=t.GetField(name,BindingFlags.Public|BindingFlags.NonPublic|BindingFlags.Instance|BindingFlags.DeclaredOnly);if(f!=null)return (T)f.GetValue(target);}throw new Exception(name);}
 static double Num(JsonElement j,string k,double d=0)=>j.TryGetProperty(k,out var v)?v.GetDouble():d;
 static string Str(JsonElement j,string k,string d="")=>j.TryGetProperty(k,out var v)?v.GetString():d;
 static Dictionary<string,object> Abilities(Dictionary<string,Ability> abs)=>abs.ToDictionary(k=>k.Key,v=>(object)new{active=v.Value.IsActive(),cooldown=Get<bool>(v.Value,"isOnCooldown")});
 static Dictionary<string,Ability> InitAbilities(){var result=new Dictionary<string,Ability>();foreach(var spec in catalog.GetProperty("settings").GetProperty("abilities").EnumerateArray()){
  var name=((AbilityType)spec.GetProperty("abilityType").GetInt32()).ToString();var ability=(Ability)Activator.CreateInstance(Type.GetType(name));
  ability.abilityDuration=(float)Num(spec,"abilityDuration");ability.cooldownDuration=(float)Num(spec,"cooldownDuration");ability.slider=new Slider();ability.sliderFill=new Image();ability.abilitySelected=new GameObject();ability.stateText=new TextMeshProUGUI();Call(ability,"Awake");Call(ability,"Start");result[name]=ability;
 }return result;}
 static void Reset(JsonElement c){SimClock.Reset();Player.Instance=null;((System.Collections.IList)typeof(EnemyEffectManager).GetField("effectEnemies",BindingFlags.NonPublic|BindingFlags.Static).GetValue(null)).Clear();GameManager.Instance.memory.Clear();GameManager.Instance.paused=GameManager.Instance.ended=false;Stats.Instance.currentStats.Clear();Stats.Instance.OnStatUpdated=new UnityEngine.Events.UnityEvent<Stat,double>();foreach(Stat stat in Enum.GetValues<Stat>())Stats.Instance.currentStats.Add(stat,0);
  foreach(var s in catalog.GetProperty("base_stats").EnumerateObject())Stats.Instance.currentStats[Enum.Parse<Stat>(s.Name)]=s.Value.GetDouble();
  if(c.TryGetProperty("stats",out var stats))foreach(var s in stats.EnumerateObject())Stats.Instance.currentStats[Enum.Parse<Stat>(s.Name)]=s.Value.GetDouble();
  PrestigeSystem.Instance=new PrestigeSystem();Set(PrestigeSystem.Instance,"currentSelectedPrestige",(int)Num(c,"prestige"));GameManager.Instance.isGameOver=false;UnityEngine.Random.Tape.Clear();UpgradesTreeManager.Instance=new UpgradesTreeManager();CurrencyManager.Instance.balances.Clear();
  foreach(CurrencyType currency in Enum.GetValues<CurrencyType>())CurrencyManager.Instance.balances[currency]=new Currency();
 }
 static object ProgressCase(JsonElement c){
  var controls=new Dictionary<string,UpgradeController>();var specs=catalog.GetProperty("upgrades").EnumerateArray().ToArray();
  foreach(var spec in specs){var u=new UpgradeData{upgradeName=Str(spec,"upgradeName"),maxLevel=(int)Num(spec,"maxLevel"),level=(int)Num(spec,"level"),isVisible=(spec.GetProperty("isVisible").ValueKind==JsonValueKind.True || spec.GetProperty("isVisible").ToString()=="1"),baseUpgradeCost=Num(spec,"baseUpgradeCost"),unlockAtParentLevel=(int)Num(spec,"unlockAtParentLevel"),weaponType=WeaponType.None,fireType=FireType.None,tabType=TabType.None,abilityType=AbilityType.None,statsToIncrease=new List<Pair<Stat,Pair<StatType,double>>>()};u.cost=new CurrencyCost(u.baseUpgradeCost,(CurrencyType)spec.GetProperty("cost").GetProperty("currencyType").GetInt32());
   foreach(var e in spec.GetProperty("effects").EnumerateArray())u.statsToIncrease.Add(new Pair<Stat,Pair<StatType,double>>(Enum.Parse<Stat>(Str(e,"stat")),new Pair<StatType,double>(e.GetProperty("percentage").GetBoolean()?StatType.Percentage:StatType.Amount,Num(e,"amount"))));
   foreach(var unlock in spec.GetProperty("unlocks").EnumerateObject()){var f=typeof(UpgradeData).GetField(unlock.Name);f.SetValue(u,Enum.Parse(f.FieldType,unlock.Value.GetString()));}controls[Str(spec,"id")]=new UpgradeController{_upgradeData=u};
  }
  foreach(var spec in specs)controls[Str(spec,"id")].childUpgrades=spec.GetProperty("children").EnumerateArray().Select(id=>controls[id.GetString()]).ToArray();
  AchievementManager.Instance.achievements.Clear();
  foreach(var spec in catalog.GetProperty("settings").GetProperty("achievements").EnumerateArray()){
   var a=new Achievement();Set(a,"achievementType",(int)Num(spec,"achievementType"));Set(a,"currencyType",(int)Num(spec,"currencyType"));Set(a,"reward",Num(spec,"reward"));AchievementManager.Instance.achievements[(AchievementType)(int)Num(spec,"achievementType")]=a;
  }
  var snapshots=new List<object>();var results=new List<bool>();
  foreach(var action in c.GetProperty("actions").EnumerateArray()){
   string op=Str(action,"op");if(op=="grant"){int i=0;foreach(var v in action.GetProperty("wallet").EnumerateArray())CurrencyManager.Instance.balances[(CurrencyType)i++].AddBalance(v.GetDouble());}
   if(op=="buy"){var ctrl=controls[Str(action,"id")];var u=ctrl._upgradeData;bool allowed=u.isVisible&&!u.IsMaxed()&&ResourceManager.Instance.CanPay(u.cost.amount,u.cost.currencyType);results.Add(allowed);if(allowed){ctrl.Buy();for(int f=0;f<30;f++)SimClock.Tick(1f/60);}}
   if(op=="set_wallet"){int i=0;foreach(var v in action.GetProperty("wallet").EnumerateArray())CurrencyManager.Instance.balances[(CurrencyType)i++].balance=v.GetDouble();}
   if(op=="claim"){var type=Enum.Parse<AchievementType>(Str(action,"name"));var a=AchievementManager.Instance.achievements[type];bool allowed=AchievementManager.Instance.IsAchievementUnlocked(type)&&!a.Claimed();results.Add(allowed);if(allowed)a.ClaimReward();}
   if(op=="open_final"&&GameManager.Instance.GetVariable(SaveSystem.FileType.GeneralSave,"GodTab unlocked",false))new PanelManager().UnlockGodButton();
   if(op=="ending"&&GameManager.Instance.GetVariable(SaveSystem.FileType.GeneralSave,"GodPanelUnlocked",false)){var panel=new EndGamePanel();foreach(var field in new[]{"benevolentGodContent","evilGodContent","thanksForPlaying"})Set(panel,field,new GameObject());Call(panel,"Start");Call(panel,Str(action,"name"));}
   if(op=="win"){GameManager.Instance.StartGame();GameManager.Instance.ended=false;new MiniBoss().Die(default,default);Set(PrestigeSystem.Instance,"currentSelectedPrestige",(int)Num(action,"prestige"));bool dropped=GameManager.Instance.GetVariable(SaveSystem.FileType.GeneralSave,$"Prestige {(int)Num(action,"prestige")} crown dropped",false);GameManager.Instance.BossDefeated(dropped);UpgradesTreeManager.Instance.CheckMaxed();}
   if(op=="prestige3"){GameManager.Instance.memory["Prestige3"]=true;UpgradesTreeManager.Instance.CheckMaxed();}
   var achievements=new Dictionary<string,bool>();foreach(AchievementType a in Enum.GetValues<AchievementType>())if(GameManager.Instance.memory.GetValueOrDefault(a.ToString()) is true)achievements[a.ToString()]=true;
   var unlocks=new Dictionary<string,bool>{{"Bow",true}};foreach(var kv in GameManager.Instance.memory)if(kv.Key.EndsWith(" unlocked")&&kv.Value is true)unlocks[kv.Key.Replace(" unlocked","")]=true;
   snapshots.Add(new{god_panel_unlocked=GameManager.Instance.GetVariable(SaveSystem.FileType.GeneralSave,"GodPanelUnlocked",false),claimed=AchievementManager.Instance.achievements.Where(x=>x.Value.Claimed()).ToDictionary(x=>x.Key.ToString(),x=>true),max_prestige=PrestigeSystem.Instance.GetCurrentMaxPrestige(),crowns=Enumerable.Range(0,4).Where(i=>GameManager.Instance.GetVariable(SaveSystem.FileType.GeneralSave,$"Prestige {i} crown dropped",false)).Select(i=>i.ToString()).ToArray(),stats=Stats.Instance.currentStats.Where(k=>k.Value!=0).ToDictionary(k=>k.Key.ToString(),k=>k.Value),levels=controls.Where(x=>x.Value._upgradeData.level>0).ToDictionary(x=>x.Key,x=>x.Value._upgradeData.level),visible=controls.Where(x=>x.Value._upgradeData.isVisible).Select(x=>x.Key).Order().ToArray(),unlocks,achievements,wallet=Enumerable.Range(0,3).Select(i=>CurrencyManager.Instance.balances[(CurrencyType)i].balance).ToArray(),costs=controls.ToDictionary(x=>x.Key,x=>x.Value._upgradeData.cost.amount)});
  }return new{id=Str(c,"id"),snapshots,results};
 }
 static object CombatCase(JsonElement c){
  var abs=InitAbilities();var player=new Player();Call(player,"Awake");var pc=player.GetComponent<PlayerController>();Set(pc,"runningTextGameObject",new GameObject());Set(pc,"forwardSpeed",1.3f);Call(pc,"Start");Call(player,"Start");
  player.SetCurrentHealth(Num(c,"hp",Stats.Instance.GetCurrentStat(Stat.MaxHP)));player.SetCurrentShield(Num(c,"armor",Stats.Instance.GetCurrentStat(Stat.Armor)));
  var enemies=new Dictionary<string,Enemy>();var projectiles=new Dictionary<string,Projectile>();var snapshots=new List<object>();
  foreach(var action in c.GetProperty("actions").EnumerateArray()){
   var op=Str(action,"op");if(op=="spawn"){int kind=(int)Num(action,"kind");Enemy e=kind==6?new Boss():kind>=4?new MiniBoss():new Enemy();foreach(var icon in new[]{"burnIcon","curseIcon","bleedIcon"})Set(e,icon,new GameObject());e.SetBaseHealth(Num(action,"base_hp",1e9));e.zombieType=(ZombieType)kind;e.SetEnemyIndex((int)Num(action,"index"));e.Initialize();if(action.TryGetProperty("hp",out var hp))e.SetCurrentHealth(hp.GetDouble());enemies[Str(action,"id")]=e;}
   if(op=="expire")enemies[Str(action,"enemy")].TickEffect(100000f);
   if(op=="effect"){var e=enemies[Str(action,"enemy")];e.ApplyEffect(Enum.Parse<Enemy.EffectType>(Str(action,"effect")),(float)Num(action,"duration",5));}
   if(op=="hit"){
    var kind=Str(action,"kind","Arrow");string key=Str(action,"pool",kind);if(!projectiles.ContainsKey(key)){var p=(Projectile)Activator.CreateInstance(Type.GetType(kind));p.SetShooter(player,new ShootingWeapon());Call(p,"Start");projectiles[key]=p;}
    UnityEngine.Random.Tape=new Queue<float>(action.GetProperty("random").EnumerateArray().Select(v=>(float)v.GetDouble()));
    projectiles[key].HandleHit(new Collider{target=enemies[Str(action,"enemy")]},default,default);
   }
   if(op=="dagger"){var melee=new MeleeWeapon();Set(melee,"currentDamage",Stats.Instance.GetCurrentStat(Stat.Dagger_Damage));Set(melee,"_duration",(float)Stats.Instance.GetCurrentStat(Stat.Burn_Duration));UnityEngine.Random.Tape=new Queue<float>(new[]{0.5f});SimClock.Start((System.Collections.IEnumerator)Call(melee,"PerformAttack",Vector3.zero,enemies[Str(action,"enemy")]));}
   if(op=="beam"){var beam=new ThirdEye();Call(beam,"Start");Set(beam,"isBeamActive",true);UnityEngine.Random.Tape=new Queue<float>(new[]{0.5f});var routine=SimClock.Start((System.Collections.IEnumerator)Call(beam,"DamageLoopCoroutine",enemies[Str(action,"enemy")],enemies[Str(action,"enemy")].transform));routine.done=true;}
   if(op=="loot"){var item=new CurrencyItem();item.itemData=new ItemData();item.SetAmount(Num(action,"amount"));Set(item,"currencyType",(int)Num(action,"currency"));item.CollectItem(new Collider{target=player});}
   if(op=="enemy_arrow"){var arrow=new EnemyArrow();Set(arrow,"enemyArrowType",(int)Num(action,"kind",3));Call(arrow,"OnEnable");arrow.HandleHit(new Collider{target=player},default,default);}
   if(op=="damage")player.TakeDamage(Num(action,"amount"),default,default,false,action.TryGetProperty("ignore_armor",out var ign)&&ign.GetBoolean());
   if(op=="ability")abs[Str(action,"name")].ActivateAbility();
   if(op=="pause")GameManager.Instance.paused=action.GetProperty("value").GetBoolean();
   if(op=="running"){Input.keys.Add(KeyCode.LeftShift);Call(pc,"Update");Input.keys.Clear();}
   if(op=="tick"){for(int f=0;f<(int)Num(action,"frames",1);f++){Input.horizontal=(float)Num(action,"horizontal");Call(pc,"FixedUpdate");if(!GameManager.Instance.paused){player.transform.position+=pc.GetComponent<Rigidbody>().linearVelocity*(1f/60);EnemyEffectManager.Update();}SimClock.Tick(1f/60);}}
   snapshots.Add(new{max_prestige=PrestigeSystem.Instance.GetCurrentMaxPrestige(),wallet=Enumerable.Range(0,3).Select(i=>CurrencyManager.Instance.balances[(CurrencyType)i].balance).ToArray(),hp=player.GetCurrentHealth(),armor=player.GetCurrentShield(),z=(double)player.transform.position.z,x=(double)player.transform.position.x,running=pc.IsRunning(),abilities=Abilities(abs),enemies=enemies.ToDictionary(x=>x.Key,x=>(object)new{hp=x.Value.GetCurrentHealth(),effect=Get<Enemy.EffectType>(x.Value,"activeEffect")==Enemy.EffectType.None?"":Get<Enemy.EffectType>(x.Value,"activeEffect").ToString(),effects=new{Burning=x.Value.IsBurning(),Cursed=x.Value.IsCursed(),Bleeding=x.Value.IsBleeding()}})});
  }return new{id=Str(c,"id"),snapshots};
 }
 static void Main(string[] args){Stats.Instance=new Stats();catalog=JsonDocument.Parse(File.ReadAllText(args[0])).RootElement;var cases=JsonDocument.Parse(File.ReadAllText(args[1])).RootElement;var output=new List<object>();foreach(var c in cases.EnumerateArray()){Reset(c);output.Add(Str(c,"type")=="progress"?ProgressCase(c):CombatCase(c));}File.WriteAllText(args[2],JsonSerializer.Serialize(output));}
}
