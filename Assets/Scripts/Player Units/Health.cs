using System.Collections;
using UnityEngine;
using UnityEngine.UI;

public class Health : MonoBehaviour {

    [SerializeField] Slider healthBarSlider;
    [SerializeField] float currentHealth;
    [SerializeField] float maxHealth;

    protected void Awake () {
        AdjustHealthBar ();
    }


    protected void Update () {
        if (Input.GetKeyDown (KeyCode.G)) {
            StartCoroutine (AdjustHealthBarOverTime (.9f));
        }
    }


    protected void AdjustHealthBar () {
        healthBarSlider.value = Utilities.Normalize (currentHealth, 0f, maxHealth);
    }


    // Visual Only
    protected IEnumerator AdjustHealthBarOverTime (float newValue) {
        float startingValue = healthBarSlider.value;
        float runningTime = 0f;

        while (runningTime < 2f) {
            healthBarSlider.value = Mathf.Lerp (startingValue, newValue, runningTime / 2f);
            runningTime += Time.deltaTime;
            yield return null;
        }
    }
}