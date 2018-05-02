using System.Linq;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : Singleton<GameManager> {

    [SerializeField] PostProcessingEffects postProcessingEffects;
    [SerializeField] UIManager UIManager;
    [SerializeField] InteractableObject hoveredObject;
    public bool isPaused {
        get; private set;
    }
    public List<ControllableUnit> playerUnits {
        get; private set;
    }
    public List<ControllableUnit> selectedUnits;

    protected void Awake () {
        selectedUnits = new List<ControllableUnit> ();
        ControllableUnit[] cu = FindObjectsOfType (typeof (ControllableUnit)) as ControllableUnit[];
        playerUnits = new List<ControllableUnit> (cu);
    }


    protected void Update () {
        if (Input.GetKeyDown (KeyCode.Escape)) {
            ToggleGameMenu ();
        }
        if (Input.GetKeyDown (KeyCode.Space)) {
            ToggleActivePause ();
        }
    }


    public void HandleClickOnGameObject (GameObject g, Vector3 clickPoint) {
        string tag = g.tag;

        switch (tag) {
            case "Floor":
                HandleClickOnFloor (g, clickPoint);
                break;
            case "ControllableUnit":
                HandleClickOnControllableUnit (g, clickPoint);
                break;
        }
    }


    public void HandleHoverOnInteractableObject (InteractableObject o) {
        if (o != hoveredObject) {
            if (hoveredObject) hoveredObject.ExitHover ();
            hoveredObject = o;
            hoveredObject.EnterHover ();
        }
    }


    public void ClearHoveredObject () {
        if (hoveredObject == null) {
            return;
        }
        else {
            hoveredObject.ExitHover ();
            hoveredObject = null;
        }
    }


    public void AddToSelectedUnits (ControllableUnit unit) {
        if (!selectedUnits.Contains (unit)) {
            selectedUnits.Add (unit);
        }
    }


    public void RemoveFromSelectedUnits (ControllableUnit unit) {
        selectedUnits.Remove (unit);
    }


    /// <summary>
    /// Handle a click on a Floor GameObject
    /// </summary>
    protected void HandleClickOnFloor (GameObject g, Vector3 clickPoint) {
        if (selectedUnits.Count == 0) {
            return;
        }
        if (selectedUnits.Count == 1) {
            selectedUnits[0].SetDestination (clickPoint);
        }
        else {
            PartyFormations.PartyCircleMove (selectedUnits, clickPoint);
        }
    }


    /// <summary>
    /// Handle a click on a ControllableUnit
    /// </summary>
    protected void HandleClickOnControllableUnit (GameObject g, Vector3 clickPoint) {
        // Grab a reference to the GameObject's ControllableUnit component
        ControllableUnit cu = g.GetComponent<ControllableUnit> ();
        if (cu == null) return;

        // Deselect all currently selected units and select the clicked unit
        foreach (ControllableUnit u in playerUnits) {
            if (u.IsSelected) {
                u.DeselectUnit ();
            }
        }
        cu.SelectUnit ();
    }


    /// <summary>
    /// Toggle the game menu
    /// </summary>
    public void ToggleGameMenu () {
        UIManager.ToggleGameMenu ();
    }


    /// <summary>
    /// Pause/unpause the game by editing the scene's timescale
    /// </summary>
    public void ToggleActivePause () {
        isPaused = !isPaused;
        UIManager.TogglePauseIndicator ();

        foreach (IPauseable pauseableObject in FindObjectsOfType<MonoBehaviour> ().OfType<IPauseable> ()) {
            pauseableObject.Pause (isPaused);
        }

        postProcessingEffects.AnimateVignette (isPaused);
    }
}