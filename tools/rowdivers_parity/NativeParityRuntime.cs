#if UNITY_EDITOR
// Only copied into the isolated reference project. No original installation writes.
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;
public static class NativeParityInput {
 public static float Horizontal;public static Vector3 mousePosition=new Vector3(-10000,-10000,0);
 public static readonly HashSet<KeyCode> Keys=new HashSet<KeyCode>();
 public static bool GetKeyDown(KeyCode k)=>Keys.Contains(k);
 public static bool GetMouseButtonDown(int b)=>false;
 public static bool GetMouseButton(int b)=>false;
}
[DefaultExecutionOrder(-10000)]
public class NativeParityRuntime:MonoBehaviour {
 StreamWriter writer;int frame,run;float start,timeout;bool ready,transition;int exceptions;
 [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
 static void Boot(){if(SessionState.GetBool("RailwayParity.NativeRun",false)){var go=new GameObject("PARITY_NATIVE_INSTRUMENTATION");DontDestroyOnLoad(go);go.AddComponent<NativeParityRuntime>();}}
 IEnumerator Start(){
  writer=new StreamWriter(Path.Combine(Directory.GetCurrentDirectory(),"native-frames.jsonl"));
  timeout=Time.realtimeSinceStartup+180;
  Application.logMessageReceived+=(message,stack,type)=>{if(type==LogType.Exception){writer.WriteLine(JsonConvert.SerializeObject(new{error=message,stack}));writer.Flush();exceptions++;}};
  QualitySettings.vSyncCount=0;Application.targetFrameRate=-1;Time.captureDeltaTime=1f/60;UnityEngine.Random.InitState(5400);
  yield return null;
  var fixture=JObject.Parse(File.ReadAllText(Path.Combine(Directory.GetCurrentDirectory(),"fixture.json")));
  var catalog=JObject.Parse(File.ReadAllText(Path.Combine(Directory.GetCurrentDirectory(),"catalog.json")));
  foreach(var stat in (JObject)fixture["stats"])GameManager.Instance.SetVariable(SaveSystem.FileType.GeneralSave,stat.Key,(double)stat.Value);
  foreach(var unlock in (JObject)fixture["unlocks"])if((bool)unlock.Value)GameManager.Instance.SetVariable(SaveSystem.FileType.GeneralSave,unlock.Key+" unlocked",true);
  foreach(JObject node in (JArray)catalog["upgrades"]){string name=(string)node["upgradeName"];GameManager.Instance.SetVariable(SaveSystem.FileType.GeneralSave,name+" level",(int)node["maxLevel"]);GameManager.Instance.SetVariable(SaveSystem.FileType.GeneralSave,name+" Visible",true);GameManager.Instance.SetVariable(SaveSystem.FileType.GeneralSave,name+" Unlocked",true);}
  GameManager.Instance.SetVariable(SaveSystem.FileType.GeneralSave,"UpgradesMaxed",112.0);
  GameManager.Instance.SetVariable(SaveSystem.FileType.GeneralSave,"Controls",true);
  GameManager.Instance.SetVariable(SaveSystem.FileType.GeneralSave,"ShowedStartGameDialog",true);
  ready=true;StartCoroutine(NextDive());
 }
 IEnumerator NextDive(){
  transition=true;NativeParityInput.Keys.Clear();NativeParityInput.Horizontal=0;
  GameManager.Instance.GoHome();
  while(SceneManager.GetActiveScene().name!="HomeScene")yield return null;
  yield return null;yield return null;
  int prestige=Math.Min(run,3);PrestigeSystem.Instance.SetCurrentSelectedPrestige(prestige);
  typeof(PanelManager).GetMethod("PlayGame",BindingFlags.NonPublic|BindingFlags.Instance).Invoke(PanelManager.Instance,null);
  while(SceneManager.GetActiveScene().name!="GameScene")yield return null;
  yield return null;yield return null;
  start=Time.time;frame=0;transition=false;
  Debug.Log("PARITY_NATIVE_DIVE "+prestige);
 }
 void Update(){
  if(writer!=null&&(exceptions>10||Time.realtimeSinceStartup>timeout)){Finish("native errors or watchdog timeout",2);return;}
  if(!ready)return;
  if(transition||SceneManager.GetActiveScene().name!="GameScene"||Player.Instance==null)return;
  NativeParityInput.Keys.Clear();
  if(GameManager.Instance.IsGameOver()||GameManager.Instance.IsGameSucceeded()){
   writer.WriteLine(JsonConvert.SerializeObject(new{result=true,run,prestige=PrestigeSystem.Instance.GetCurrentSelectedPrestige(),won=GameManager.Instance.IsGameSucceeded(),elapsed=Time.time-start,hp=Player.Instance.GetCurrentHealth(),armor=Player.Instance.GetCurrentShield(),x=Player.Instance.transform.position.x,z=Player.Instance.transform.position.z}));writer.Flush();
   if(!GameManager.Instance.IsGameSucceeded()){Finish("original run died; input trace retained");return;}
   if(++run>=4){Finish("four native rows complete");return;}
   StartCoroutine(NextDive());return;
  }
  var player=Player.Instance.transform.position;Enemy nearest=null;float closest=1000;bool bossClose=false;
  foreach(var enemy in FindObjectsByType<Enemy>(FindObjectsSortMode.None)){
   if(enemy.IsDead()||!enemy.gameObject.activeInHierarchy)continue;
   float ahead=enemy.transform.position.z-player.z;if((enemy is Boss||enemy is MiniBoss)&&ahead>0&&ahead<7)bossClose=true;
   if(ahead>0&&ahead<closest){closest=ahead;nearest=enemy;}
  }
  var pc=Player.Instance.GetComponent<PlayerController>();bool running=!bossClose;
  if(pc.IsRunning()!=running)NativeParityInput.Keys.Add(KeyCode.LeftShift);
  float desired=2.5f;
  if(nearest!=null){desired=nearest.transform.position.x;if(closest<((nearest is Boss||nearest is MiniBoss)?4:1))desired=nearest.transform.position.x>=2.5f?1:4;}
  NativeParityInput.Horizontal=Mathf.Clamp((desired-player.x)*12,-1,1);
  Camera camera=Camera.main;
  if(camera==null){var weapon=FindObjectsByType<ShootingWeapon>(FindObjectsSortMode.None).FirstOrDefault();if(weapon!=null)camera=(Camera)typeof(ShootingWeapon).GetField("playerCamera",BindingFlags.NonPublic|BindingFlags.Instance).GetValue(weapon);}
  var collider=nearest!=null?nearest.GetComponentInChildren<Collider>():null;
  NativeParityInput.mousePosition=nearest!=null&&(nearest is Boss||nearest is MiniBoss)&&camera!=null?camera.WorldToScreenPoint(collider!=null?collider.bounds.center:nearest.transform.position+Vector3.up*0.5f):new Vector3(-10000,-10000,0);
  foreach(var a in new Ability[]{Harvester.Instance,ArrowShield.Instance,Shuriken.Instance,SlowDown.Instance}){
   if(a==null||(!bossClose&&a.abilityType!=AbilityType.Harvester))continue;
   bool cooldown=(bool)typeof(Ability).GetField("isOnCooldown",BindingFlags.NonPublic|BindingFlags.Instance).GetValue(a);
   if(!a.IsActive()&&!cooldown)NativeParityInput.Keys.Add(a.abilityType==AbilityType.Harvester?KeyCode.Alpha4:a.abilityType==AbilityType.ArrowShield?KeyCode.Alpha3:a.abilityType==AbilityType.Shuriken?KeyCode.Alpha5:KeyCode.Alpha6);
  }
 }
 Camera ResolveCamera(){
  Camera camera=Camera.main;
  if(camera==null){var weapon=FindObjectsByType<ShootingWeapon>(FindObjectsSortMode.None).FirstOrDefault();if(weapon!=null)camera=(Camera)typeof(ShootingWeapon).GetField("playerCamera",BindingFlags.NonPublic|BindingFlags.Instance).GetValue(weapon);}
  return camera;
 }
 void LateUpdate(){
  if(!ready||transition||Player.Instance==null||SceneManager.GetActiveScene().name!="GameScene")return;
  var p=Player.Instance.transform.position;
  if(frame==0){var c=ResolveCamera();writer.WriteLine(JsonConvert.SerializeObject(new{meta=true,run,engine=Application.unityVersion,level_time=Time.timeSinceLevelLoad,fixed_dt=Time.fixedDeltaTime,screen=new[]{Screen.width,Screen.height},viewport=c!=null?new[]{c.pixelWidth,c.pixelHeight}:new[]{0,0},fov=c!=null?c.fieldOfView:0,origin=new[]{2.5f,0.87f,-28.474f}}));}
  writer.WriteLine(JsonConvert.SerializeObject(new{run,frame=frame++,t=Time.time-start,dt=Time.deltaTime,axis=NativeParityInput.Horizontal,keys=NativeParityInput.Keys.Select(k=>k.ToString()).ToArray(),mouse=new[]{NativeParityInput.mousePosition.x,NativeParityInput.mousePosition.y},hp=Player.Instance.GetCurrentHealth(),armor=Player.Instance.GetCurrentShield(),pos=new[]{p.x,p.y,p.z},section=ProgressionManager.Instance.GetCurrentSectionNumber(),groups=ProgressionManager.Instance.GetSpawnedEnemyGroups(),running=Player.Instance.GetComponent<PlayerController>().IsRunning()}));
  if(frame%120==0)writer.Flush();
 }
 void Finish(string reason,int code=0){ready=false;writer.WriteLine(JsonConvert.SerializeObject(new{finished=reason,exit_code=code}));writer.Flush();SessionState.SetBool("RailwayParity.NativeRun",false);Debug.Log("PARITY_NATIVE_FINISHED "+reason);EditorApplication.Exit(code);}
}
#endif
