using UnityEngine;
using UnityEngine.EventSystems;

public class CameraMouseInteractions : MonoBehaviour {

    [SerializeField] Color selectionRectColor;
    [SerializeField] Color selectionRectBorderColor;
    [SerializeField] float selectionRectBorderThickness = 2f;
    [SerializeField] float maxMouseDistanceForDrag = 10f;

    bool isRectSelecting = false;
    Vector3 dragStartPosition;

    protected void Update () {
        CheckClick ();
    }


    /// <summary>
    /// Handle mouse input
    /// </summary>
    protected void CheckClick () {
        // Mouse initial press
        if (Input.GetMouseButtonDown (0)) {
            // Set start drag position
            dragStartPosition = Input.mousePosition;
        }
        // Mouse held down
        if (Input.GetMouseButton (0)) {
            // Enough distance, start drawing rectangle
            if (!isRectSelecting && CheckMouseMovementDistance ()) {
                isRectSelecting = true;
            }
        }
        // Mouse let go
        if (Input.GetMouseButtonUp (0)) {
            // Stop drawing rectangle
            if (isRectSelecting) {
                isRectSelecting = false;
            }
            // Input is a click, raycast
            else {
                ClickRaycast ();
            }
        }

        if (isRectSelecting) {
            SelectControllableEntitiesInRectangle ();
        }
    }


    /// <summary>
    /// Check all ControllableEntities in the GameManager's list,
    /// and toggle the selection of entities in the selection rectangle
    /// </summary>
    protected void SelectControllableEntitiesInRectangle () {
        if (isRectSelecting) {
            foreach (ControllableUnit cu in GameManager.Instance.playerUnits) {
                if (IsWithinSelectionBounds (cu.gameObject)) {
                    if (!cu.IsSelected) {
                        cu.SelectUnit ();
                    }
                }
                else {
                    cu.DeselectUnit ();
                }
            }
        }
    }


    /// <summary>
    /// Check if the given GameObject is within the selection rectangle
    /// </summary>
    protected bool IsWithinSelectionBounds (GameObject gameObject) {
        if (!isRectSelecting)
            return false;

        var camera = Camera.main;
        var viewportBounds = SelectionRectUtils.GetViewportBounds (camera, dragStartPosition, Input.mousePosition);
        return viewportBounds.Contains (camera.WorldToViewportPoint (gameObject.transform.position));
    }


    /// <summary>
    /// Raycast from screen-space to worldspace using the mouse position
    /// Send click information to the GameManager
    /// </summary>
    protected void ClickRaycast () {
        if (EventSystem.current.IsPointerOverGameObject ())
            return;

        Ray ray = Camera.main.ScreenPointToRay (Input.mousePosition);
        RaycastHit hit;

        if (Physics.Raycast (ray, out hit)) {
            Debug.DrawLine (ray.origin, hit.point);
            GameObject g = hit.collider.gameObject;

            GameManager.Instance.HandleClickOnGameObject (g, hit.point);
        }
    }


    /// <summary>
    /// Determines whether or not the mouse has moved enough distance to begin
    /// drawing the selection rectangle
    /// </summary>
    protected bool CheckMouseMovementDistance () {
        float d = Vector3.Distance (dragStartPosition, Input.mousePosition);
        if (d > maxMouseDistanceForDrag) return true;
        else return false;
    }


    /// <summary>
    /// Handle the drawing of the selection rectangle
    /// </summary>
    protected void OnGUI () {
        if (isRectSelecting) {
            var rect = SelectionRectUtils.GetScreenRect (dragStartPosition, Input.mousePosition);
            SelectionRectUtils.DrawScreenRect (rect, selectionRectColor);
            SelectionRectUtils.DrawScreenRectBorder (rect, selectionRectBorderThickness, selectionRectBorderColor);
        }
    }
}