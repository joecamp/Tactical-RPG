using System.Collections;
using UnityEngine;

public class LaserBeamWall : MonoBehaviour {

    [SerializeField] float animationTime;
    Material material;

    private void Awake () {
        material = GetComponent<MeshRenderer> ().material;
    }


    public void ActivateLasers (bool value) {
        StartCoroutine (PerformLaserWallAnimation (value));
    }


    IEnumerator PerformLaserWallAnimation (bool value) {
        float i = 0;
        float rate = 1 / animationTime;

        Vector2 startingTextureScale = material.mainTextureScale;
        Vector2 newTextureScale;
        if (value) newTextureScale = new Vector2 (0, 1);
        else newTextureScale = new Vector2 (0, 0);

        while (i < 1) {
            material.mainTextureScale = Vector2.Lerp (startingTextureScale, newTextureScale, i);
            i += Time.deltaTime * rate;
            yield return 0;
        }

        // Ensure that we've reached the final value
        material.mainTextureScale = newTextureScale;
    }
}