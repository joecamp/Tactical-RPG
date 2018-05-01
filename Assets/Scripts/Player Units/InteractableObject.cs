using UnityEngine;

public abstract class InteractableObject : MonoBehaviour {
    abstract public void Click ();
    abstract public void EnterHover ();
    abstract public void ExitHover ();
}