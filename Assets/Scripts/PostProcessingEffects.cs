using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine.PostProcessing;
using UnityEngine;

[RequireComponent (typeof (PostProcessingBehaviour))]
public class PostProcessingEffects : MonoBehaviour {

    PostProcessingBehaviour pp;
    PostProcessingProfile profile;

    // Vignette
    float vignIntensity = 0;
    Tween vignTween;
    [SerializeField] float maxVignIntensity = .45f;
    [SerializeField] float vignDuration = .5f;

    protected void Awake () {
        pp = GetComponent<PostProcessingBehaviour> ();
        profile = pp.profile;
    }


    public void AnimateVignette (bool value) {
        vignTween = DOTween.To (() => vignIntensity,
            x => vignIntensity = x, value ? maxVignIntensity : 0, vignDuration).OnUpdate (UpdateVignetteAnimation);
        vignTween.OnComplete (OnVignetteAnimationEnd);

    }


    void UpdateVignetteAnimation () {
        VignetteModel.Settings vign = profile.vignette.settings;
        vign.intensity = vignIntensity;
        profile.vignette.settings = vign;
    }


    void OnVignetteAnimationEnd () {
        vignTween = null;
    }
}