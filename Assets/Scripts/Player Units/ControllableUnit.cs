using UnityEngine;

[RequireComponent (typeof (ControllableUnitMovement))]
public class ControllableUnit : InteractableObject, IPauseable {
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


    public override void Click () {
        if (IsSelected) DeselectUnit ();
        else SelectUnit ();
    }


    public override void EnterHover () {
        IsHovered = true;
        selectionRing.EnterMouseHover ();
    }


    public override void ExitHover () {
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
}