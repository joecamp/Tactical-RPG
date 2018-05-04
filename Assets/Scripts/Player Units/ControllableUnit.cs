using UnityEngine;

// TODO: Refactor into generic Unit that can be inherited for ControllableUnit and AI
[RequireComponent (typeof (ControllableUnitMovement))]
public class ControllableUnit : MonoBehaviour, IInteractable, IPauseable {
    public enum UnitState { Paused, Idle, Moving };
    public UnitState state;
    public bool IsSelected {
        get; private set;
    }
    public bool IsHovered {
        get; private set;
    }

    [SerializeField] private GameObject targetMarker;
    private SelectionRing selectionRing;
    private ControllableUnitMovement movement;

    private UnitState prevState;

    protected void Awake () {
        IsSelected = false;
        movement = GetComponent<ControllableUnitMovement> ();
        selectionRing = GetComponentInChildren<SelectionRing> ();
        state = UnitState.Idle;
    }


    public void Click () {
        if (IsSelected) DeselectUnit ();
        else SelectUnit ();
    }


    public void EnterHover () {
        IsHovered = true;
        selectionRing.EnterMouseHover ();
    }


    public void ExitHover () {
        IsHovered = false;
        selectionRing.ExitMouseHover ();
    }


    public void SelectUnit () {
        GameManager.Instance.AddToSelectedUnits (this);
        IsSelected = true;
        selectionRing.SetActive ();
    }


    public void DeselectUnit () {
        GameManager.Instance.RemoveFromSelectedUnits (this);
        IsSelected = false;
        selectionRing.SetInactive ();
    }


    public void SetDestination (Vector3 point) {
        if (state != UnitState.Paused) {
            state = UnitState.Moving;
        }
        else {
            prevState = UnitState.Moving;
        }

        Vector3 newDestination = movement.FindClosestValidPosition (point);

        targetMarker.SetActive (true);

        Vector3 newMarkerPosition = newDestination;
        newMarkerPosition.y = targetMarker.transform.position.y;
        targetMarker.transform.position = newMarkerPosition;

        movement.SetDestination (newDestination);
    }


    public void ReachedDestination () {
        state = UnitState.Idle;
        targetMarker.SetActive (false);
    }


    public void Pause (bool value) {
        if (value) {
            prevState = state;
            state = UnitState.Paused;
        }
        else {
            state = prevState;
        }
        movement.PauseMovement (value);
    }


    protected void OnCollisionEnter (Collision collision) {
        if (collision.collider.tag == "ControllableUnit")
            UnitCollisionManager.Instance.HandleUnitCollision (this, collision);
    }
}