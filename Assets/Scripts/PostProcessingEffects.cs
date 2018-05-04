using DG.Tweening;
using UnityEngine.PostProcessing;
using UnityEngine;

[RequireComponent (typeof (PostProcessingBehaviour))]
public class PostProcessingEffects : MonoBehaviour {
    PostProcessingBehaviour pp;
    PostProcessingProfile profile;

    protected void Awake () {
        pp = GetComponent<PostProcessingBehaviour> ();
        profile = pp.profile;
    }


    // Vignette
    [Header ("Vignette Settings")]
    [SerializeField] float maxVignIntensity = .45f;
    [SerializeField] float vignDuration = .5f;
    float vignIntensity = 0;
    Tween vignTween;

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


    // DoF
    [Header ("DoF Settings")]
    [SerializeField] float maxDofFocalLength = .45f;
    [SerializeField] float dofDuration = .5f;
    float dofFocalLength = 1;
    Tween dofTween;

    public void AnimateDoF (bool value) {
        dofTween = DOTween.To (() => dofFocalLength,
            x => dofFocalLength = x, value ? maxDofFocalLength : 1, dofDuration).OnUpdate (UpdateDoFAnimation);
        dofTween.OnComplete (OnDoFAnimationEnd);
    }


    void UpdateDoFAnimation () {
        DepthOfFieldModel.Settings dof = profile.depthOfField.settings;
        dof.focalLength = dofFocalLength;
        profile.depthOfField.settings = dof;
    }


    void OnDoFAnimationEnd () {
        dofTween = null;
    }
}