using DG.Tweening;
using UnityEngine;

public class SelectionRing : MonoBehaviour {

    [SerializeField] Color activeColor;
    [SerializeField] Color inactiveColor;

    private MeshRenderer ringMeshRenderer;
    private DOTweenAnimation hoverAnim;

    protected void Awake () {
        ringMeshRenderer = GetComponent<MeshRenderer> ();
        hoverAnim = GetComponent<DOTweenAnimation> ();
    }


    public void SetActive () {
        ringMeshRenderer.material.color = activeColor;
    }


    public void SetInactive () {
        ringMeshRenderer.material.color = inactiveColor;
    }


    public void EnterMouseHover () {
        hoverAnim.DOPlay ();
    }


    public void ExitMouseHover () {
        hoverAnim.DORestart ();
        hoverAnim.DOPause ();
    }
}