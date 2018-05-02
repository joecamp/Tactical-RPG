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
            InteractableObject o;
            if (o = hit.collider.gameObject.GetComponent<InteractableObject> ()) {
                GameManager.Instance.HandleHoverOnInteractableObject (o);
            }
            else {
                GameManager.Instance.ClearHoveredObject ();
            }
        }
    }
}