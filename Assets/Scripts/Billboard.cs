using UnityEngine;

/// <summary>
/// Used to make UI elements face the main camera
/// </summary>
public class Billboard : MonoBehaviour {

    protected void Update () {
        transform.LookAt (Camera.main.transform);
    }
}