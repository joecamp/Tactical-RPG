using System.Collections;
using System.Collections.Generic;
using UnityEngine.Events;
using UnityEngine;

// TODO: Implement an activation position and unit behavior (animation?).
public class InteractableToggleObject : MonoBehaviour, IInteractable {
    [SerializeField] bool isToggled;
    public Transform interactTransform;
    [SerializeField] UnityEvent OnToggleOn;
    [SerializeField] UnityEvent OnToggleOff;

    public void Click () {
        Toggle (!isToggled);
    }

    public void Toggle (bool value) {
        if (value) OnToggleOn.Invoke ();
        else OnToggleOff.Invoke ();
        isToggled = value;
    }

    public void EnterHover () {
        //throw new System.NotImplementedException ();
    }

    public void ExitHover () {
        //throw new System.NotImplementedException ();
    }
}