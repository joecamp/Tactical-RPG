using UnityEngine.UI;
using UnityEngine;

public class FPSViewer : MonoBehaviour {

    public int targetFPS = 60;
    public Color acceptableColor = Color.green;
    public Color warningColor = Color.yellow;
    public Color dangerColor = Color.red;
    public int warningThreshold = 5;
    public int dangerThreshold = 30;

    protected const float updateInterval = 0.5f;
    protected int framesCount;
    protected float framesTime;
    protected Text text;

    protected void Awake () {
        text = GetComponent<Text> ();
        if (text == null)
            Debug.LogError ("Error: No Text component attached to FPSViewer object.");
    }


    protected void Update () {
        framesCount++;
        framesTime += Time.unscaledDeltaTime;

        if (framesTime > updateInterval) {
            if (text == null) {
                return;
            }

            float fps = framesCount / framesTime;
            text.text = string.Format ("{0:F2} FPS", fps);
            text.color = (fps > (targetFPS - warningThreshold) ? acceptableColor :
                         (fps > (targetFPS - dangerThreshold) ? warningColor :
                         dangerColor));

            framesCount = 0;
            framesTime = 0;
        }
    }
}