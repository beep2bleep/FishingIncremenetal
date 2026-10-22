// Explicit engine substitutions: no rendering, native physics, disk saves or Steam.
// Gameplay classes linked by prepare_reference.py remain byte-for-byte original.
using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
namespace UnityEngine {
 public class PropertyAttribute:Attribute {}
 public class SerializeField:Attribute {} public class Header:Attribute {public Header(string s){}}
 public class Object {public static void Destroy(object o){}public static void DontDestroyOnLoad(object o){} }
 public class Component:Object {
  public GameObject gameObject; public Transform transform => gameObject.transform;
  public Component(){gameObject = new GameObject(false);gameObject.component=this;}
  public T GetComponent<T>() where T:class,new()=>gameObject.GetComponent<T>();
  public T GetComponentInParent<T>() where T:class,new()=>GetComponent<T>();
  public T GetComponentInChildren<T>(bool includeInactive=false) where T:class,new()=>GetComponent<T>();
  public bool TryGetComponent<T>(out T x) where T:class,new(){x=GetComponent<T>();return x!=null;}
 }
 public class MonoBehaviour:Component {
  public Coroutine StartCoroutine(IEnumerator routine)=>SimClock.Start(routine);
  public void StopCoroutine(Coroutine c){if(c!=null)c.done=true;}
 }
 public class GameObject:Object {
  public Component component; public Dictionary<Type,object> components=new Dictionary<Type,object>(); public Transform transform; public bool activeSelf=true;
  public bool activeInHierarchy=>activeSelf;
  public GameObject(bool create=true){transform=new Transform(this);}
  public GameObject(string name):this(){}
  public static GameObject Find(string name)=>new GameObject();
  public void SetActive(bool value){activeSelf=value;}
  public T GetComponent<T>() where T:class,new(){if(component is T v)return v;if(components.TryGetValue(typeof(T),out var existing))return (T)existing;var created=new T();if(created is Component c)c.gameObject=this;components[typeof(T)]=created;return created;}
  public T GetComponentInChildren<T>(bool includeInactive=false) where T:class,new()=>GetComponent<T>();
  public T AddComponent<T>() where T:class,new()=>new T();
  public bool TryGetComponent<T>(out T v) where T:class,new(){v=component as T;return v!=null;}
 }
 public class Transform {
  public GameObject gameObject; public Vector3 position,localPosition;public Quaternion rotation;
  public Vector3 forward=>Vector3.forward;public Transform transform=>this;public int childCount=>3;public Transform GetChild(int i)=>new GameObject().transform;public Transform Find(string name)=>new GameObject().transform;
  public Transform(GameObject g){gameObject=g;}
  public void Rotate(Vector3 v,Space s){} public void SetPositionAndRotation(Vector3 p,Quaternion q){position=p;rotation=q;}
  public T GetComponent<T>() where T:class,new()=>gameObject.GetComponent<T>();
  public Vector3 InverseTransformPoint(Vector3 p)=>p-position;public bool TryGetComponent<T>(out T v) where T:class,new()=>gameObject.TryGetComponent(out v);
 }
 public enum Space {Self} public struct Quaternion {public static Quaternion identity=>new Quaternion();}
 public struct Vector3 {
  public float x,y,z;public Vector3(float x,float y,float z){this.x=x;this.y=y;this.z=z;}
  public static Vector3 zero=>new Vector3();public static Vector3 forward=>new Vector3(0,0,1);public static Vector3 right=>new Vector3(1,0,0);
  public float sqrMagnitude=>x*x+y*y+z*z;public float magnitude=>(float)Math.Sqrt(sqrMagnitude);
  public Vector3 normalized=>magnitude==0?zero:this*(1/magnitude);
  public static Vector3 operator +(Vector3 a,Vector3 b)=>new Vector3(a.x+b.x,a.y+b.y,a.z+b.z);
  public static Vector3 operator -(Vector3 a,Vector3 b)=>new Vector3(a.x-b.x,a.y-b.y,a.z-b.z);
  public static Vector3 operator -(Vector3 a)=>zero-a;public static Vector3 operator *(Vector3 a,float b)=>new Vector3(a.x*b,a.y*b,a.z*b);
  public static Vector3 MoveTowards(Vector3 a,Vector3 b,float d)=>a+(b-a).normalized*Math.Min(d,(b-a).magnitude);
  public static Vector3 Lerp(Vector3 a,Vector3 b,float t)=>a+(b-a)*Math.Clamp(t,0,1);
 }
 public struct Color {public static Color yellow,red;}
 public struct LayerMask {public int value;public static implicit operator int(LayerMask v)=>v.value;}
 public class Collider:Component {public Entity target;public new T GetComponentInParent<T>() where T:class,new()=>target as T;
  public new bool TryGetComponent<T>(out T v) where T:class,new(){v=target as T;return v!=null;}public Vector3 ClosestPoint(Vector3 v)=>transform.position;}
 public struct RaycastHit {public Collider collider;public Vector3 point;public Transform transform=>collider.transform;}
 public struct Ray {public Vector3 origin,direction;public Ray(Vector3 a,Vector3 b){origin=a;direction=b;}}
 public static class Screen {public static int width=1920,height=1080;}
 public class Camera:Component {public Ray ScreenPointToRay(Vector3 p)=>new Ray(transform.position,Vector3.forward);}
 public class Animator:Component {public void SetBool(string k,bool b){}}
 public class LineRenderer:Component {public void SetPosition(int i,Vector3 p){}}
 public class WaitForEndOfFrame {}
 public static class Physics {public static int RaycastNonAlloc(Ray r,RaycastHit[] hits,float range,LayerMask mask)=>0;public static int OverlapSphereNonAlloc(Vector3 p,float r,Collider[] b,LayerMask l)=>0;public static RaycastHit[] RaycastAll(Vector3 s,Vector3 d,float m,LayerMask l)=>Array.Empty<RaycastHit>();}
 public static class Time {public static float deltaTime=1f/60,fixedDeltaTime=1f/60,time;}
 public static class Random {public static Queue<float> Tape=new Queue<float>();public static float Range(float a,float b)=>a+(b-a)*value;public static float value=>Tape.Count>0?Tape.Dequeue():0.5f;}
 public static class Mathf {public static float Pow(float a,float b)=>(float)Math.Pow(a,b);public static int Clamp(int a,int b,int c)=>Math.Clamp(a,b,c);public static float InverseLerp(float a,float b,float t)=>Math.Clamp((t-a)/(b-a),0,1);public static float Lerp(float a,float b,float t)=>a+(b-a)*t;}
 public static class Input {public static HashSet<KeyCode> keys=new HashSet<KeyCode>();public static float horizontal;public static Vector3 mousePosition;public static bool anyKeyDown=false;public static bool GetKeyDown(KeyCode k)=>keys.Contains(k);public static float GetAxis(string a)=>horizontal;}
 public enum KeyCode {LeftShift,RightShift,Alpha3,Keypad3,Alpha4,Keypad4,Alpha5,Keypad5,Alpha6,Keypad6}
 public class Rigidbody:Component {public bool useGravity;public RigidbodyConstraints constraints;public float linearDamping,angularDamping;public Vector3 linearVelocity;}
 public enum RigidbodyConstraints {} public class Sprite {} public class Renderer:Component {public void GetPropertyBlock(MaterialPropertyBlock b){}public void SetPropertyBlock(MaterialPropertyBlock b){}}
 public class MaterialPropertyBlock {public void SetFloat(int id,float v){}} public static class Shader {public static int PropertyToID(string s)=>0;}
 public static class Debug {public static void LogWarning(string text){}}
 public static class Gizmos {public static Color color;public static void DrawWireSphere(Vector3 p,float r){}public static void DrawRay(Vector3 p,Vector3 d){}}
 public class Coroutine {public Stack<IEnumerator> stack=new Stack<IEnumerator>();public double wait;public bool done;}
 public class WaitForSeconds {public float seconds;public WaitForSeconds(float s){seconds=s;}}
}
namespace UnityEngine.UI {public class Button:Component {public ClickEvent onClick=new ClickEvent();}public class ClickEvent {public void AddListener(Action a){}}public class Slider:Component {public float maxValue,value;}public class Image:Component {public Color color;public Sprite sprite;}}
namespace TMPro {public class TextMeshProUGUI:Component {public string text;}}
namespace CameraShake {public class PerlinShake {public PerlinShake(object o){}}public static class CameraShaker {public static void Shake(PerlinShake p){}}}
public static class SimClock {
 public static List<Coroutine> routines=new List<Coroutine>();
 public static Coroutine Start(IEnumerator e){var c=new Coroutine();c.stack.Push(e);routines.Add(c);Advance(c);return c;}
 static void Advance(Coroutine c){while(c.stack.Count>0){var e=c.stack.Peek();if(!e.MoveNext()){c.stack.Pop();continue;}if(e.Current is IEnumerator nested){c.stack.Push(nested);continue;}c.wait=e.Current is WaitForSeconds w?w.seconds:0;return;}c.done=true;}
 public static void Tick(float dt){Time.deltaTime=Time.fixedDeltaTime=dt;Time.time+=dt;foreach(var c in routines.ToArray()){if(c.done)continue;c.wait-=dt;if(c.wait<=0)Advance(c);}routines.RemoveAll(c=>c.done);}
 public static void Reset(){routines.Clear();Time.time=0;}
}
public partial class GameManager {public static GameManager Instance=new GameManager();public bool paused,ended;public Dictionary<string,object> memory=new Dictionary<string,object>();public bool IsGamePaused()=>paused;public T GetVariable<T>(SaveSystem.FileType fileType,string key,T defaultValue)=>memory.ContainsKey(key)?(T)memory[key]:defaultValue;public void SetVariable<T>(SaveSystem.FileType fileType,string key,T v){memory[key]=v;}public void GameOver(){ended=true;}}
public class SaveSystem {public enum FileType {GeneralSave,Settings}}
public class AudioManager {public static AudioManager Instance=new AudioManager();public enum Sound {Ability,Pop,Footstep,EnemyExplosion,MiniEnemyScream,EnemyScream,Rocket,BarDecrease,Success,Dagger,LaserBeamShort,LaserBeamLoop}public void PlaySound(Sound s,Vector3 p=default,float timerMax=0){}public void PlayLoopingSound(Sound s){}public void StopLoopingSound(Sound s){}public void PlayTrack(Sound s){}public Sound GetCreditsMusic()=>Sound.Ability;public Sound GetRandomMainMenuMusic()=>Sound.Ability;}
public class UICharacter {public static UICharacter Instance;public void SetMaxHealth(double a,double b){}public void SetHealth(double a,double b){}public void SetMaxShield(double a,double b){}public void SetShield(double a,double b){}public void Poisoned(bool isPoisoned){}public void ShakeShieldBar(){}public void ShakeHealthBar(){}}
public class UIEnemy {public void UpdateHealthText(double n){}}
public class Effects {public static Effects Instance=new Effects();public object damageShake;}
public class DamageEffect {public static DamageEffect Instance;public void TriggerDamageEffect(){}}

public class EnemySpawnController {public static EnemySpawnController Instance=new EnemySpawnController();public NumberPrefab NumberPrefab=new NumberPrefab(),HealNumberPrefab=new NumberPrefab();public GameObject GetDeathEffect()=>new GameObject();public void RecycleEnemy(Enemy e){}}
public class NumberPrefab {public NumberPrefab Spawn(Vector3 p,string s)=>this;public void SetColor(Color c){}}
public class EnemyHitEffectManager {public static void RegisterHit(Enemy e){}}
public class ItemSpawner {public static ItemSpawner Instance;public void SpawnItem(Transform t,Enemy e){}}
public class MiniBossEntrance {public void OpenMiniBossGate(){}}
public class ProgressionManager {public static ProgressionManager Instance=new ProgressionManager();public int GetSpawnedEnemyGroups()=>0;}
public enum ItemID {None} 

public class ShootingWeapon {public void ReturnProjectileToPool(GameObject g){g.SetActive(false);}}
public class EnemyWeapon {public GameObject GetHitEffect(Vector3 p)=>new GameObject();}
public static class Utils {public static (string,Color) FormatAbbreviatedNumber(double n)=>(n.ToString(),new Color());}


public class UIAchievementManager {public static UIAchievementManager Instance;public void UpdateUIAchievementsData(){}}
public class ItemData {public int level;public List<Pair<Stat,double>> statsToIncrease=new List<Pair<Stat,double>>();}
public class Currency {public double balance;public double GetBalance()=>balance;public void AddBalance(double v){balance+=v;}}
public class CurrencyManager {public static CurrencyManager Instance=new CurrencyManager();public Dictionary<CurrencyType,Currency> balances=new Dictionary<CurrencyType,Currency>();public Dictionary<CurrencyType,Currency> Currencies()=>balances;}
public class ResourceManager {public static ResourceManager Instance=new ResourceManager();public bool CanPay(double a,CurrencyType c)=>CurrencyManager.Instance.balances[c].balance>=a;public void Pay(double a,CurrencyType c){CurrencyManager.Instance.balances[c].balance-=a;}}

public class SceneController {public static SceneController Instance;public void SwitchScene(string scene){}}

namespace UnityEngine.Events {public class UnityEvent<T,U> {readonly List<Action<T,U>> listeners=new List<Action<T,U>>();public void AddListener(Action<T,U> a){listeners.Add(a);}public void RemoveListener(Action<T,U> a){listeners.Remove(a);}public void Invoke(T a,U b){foreach(var f in listeners.ToArray())f(a,b);}}}
namespace UnityEngine.SceneManagement {public struct Scene {}public enum LoadSceneMode {}public static class SceneManager {public static event Action<Scene,LoadSceneMode> sceneLoaded;}}
