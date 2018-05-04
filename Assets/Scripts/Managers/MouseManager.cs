using UnityEngine;
using UnityEngine.EventSystems;

public class MouseManager : MonoBehaviour {

    void Update () {
        CheckMouseHover ();
    }


    protected void CheckMouseHover () {
        if (EventSystem.current.IsPointerOverGameObject ())
            return;

        Ray ray = Camera.main.ScreenPointToRay (Input.mousePosition);
        RaycastHit hit;

        if (Physics.Raycast (ray, out hit)) {
            IInteractable o;
            if ((o = hit.collider.gameObject.GetComponentInParent<IInteractable> ()) != null) {
                GameManager.Instance.HandleHoverOnInteractableObject (o);
            }
            else {
                GameManager.Instance.ClearHoveredObject ();
            }
        }
    }
}