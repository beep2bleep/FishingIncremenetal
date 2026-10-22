// Optional native inspection. Installed only in the isolated reference project.
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
public static class NativeParityEditor {
 public static void Run() {
  SessionState.SetBool("RailwayParity.NativeRun",true);
  EditorSceneManager.OpenScene("Assets/Scenes/MainMenuScene.unity");
  EditorApplication.EnterPlaymode();
 }
 public static void Probe() {
  var scene=EditorSceneManager.OpenScene("Assets/Scenes/GameScene.unity");
  var roots=scene.GetRootGameObjects();
  var colliders=roots.SelectMany(r=>r.GetComponentsInChildren<Collider>(true)).ToArray();
  var text="Native Unity "+Application.unityVersion+"\nScene "+scene.name+"\nColliders "+colliders.Length+"\nFixed delta "+Time.fixedDeltaTime+"\n";
  File.WriteAllText(Path.Combine(Directory.GetCurrentDirectory(),"native-probe.txt"),text);
  Debug.Log("PARITY_NATIVE_PROBE_COMPLETE\n"+text);
 }
}
