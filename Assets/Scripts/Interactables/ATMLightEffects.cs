using DG.Tweening;
using UnityEngine;

public class ATMLightEffects : MonoBehaviour {

    [ColorUsageAttribute (false, true, 0f, 8f, 0.125f, 3f)]
    [SerializeField] Color enabledColor;
    [ColorUsageAttribute (false, true, 0f, 8f, 0.125f, 3f)]
    [SerializeField] Color disabledColor;
    [SerializeField] float animationSpeed = .3f;

    Material material;
    Color tempColor;

    private void Awake () {
        material = GetComponent<MeshRenderer> ().material;
        tempColor = material.GetColor ("_EmissionColor");
    }


    public void AnimateLights (bool value) {
        DOTween.To (() => tempColor,
        x => tempColor = x, value ? enabledColor : disabledColor, animationSpeed).OnUpdate (UpdateEmissionColor);
    }


    private void UpdateEmissionColor () {
        material.SetColor ("_EmissionColor", tempColor);
    }
}