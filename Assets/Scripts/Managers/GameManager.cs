using System.Linq;
using System.Collections.Generic;
using UnityEngine.AI;
using UnityEngine;

public class GameManager : Singleton<GameManager> {
	public bool verbose;
	[SerializeField] PostProcessingEffects postProcessingEffects;
	[SerializeField] UIManager UIManager;
	[SerializeField] IInteractable hoveredObject;
	public bool isPaused { get; private set; }
	public bool isMenuPaused { get; private set; }
	public List<ControllableUnit> playerUnits { get; private set; }
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
			ToggleActivePause (true);
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
			case "Interactable":
				HandleClickOnInteractableObject (g);
				break;
			case "Hostile":
				HandleClickOnHostile (g);
				break;
		}
	}


	public void HandleHoverOnInteractableObject (IInteractable o) {
		if (o != hoveredObject) {
			if (hoveredObject != null) hoveredObject.ExitHover ();
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
		if (verbose) Debug.Log ("Clicked on floor (" + g.name + ") at point " + clickPoint);

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
		if (verbose) Debug.Log ("Clicked on ControllableUnit (" + g.name + ")");

		// Grab a reference to the GameObject's ControllableUnit component
		ControllableUnit cu = g.GetComponentInParent<ControllableUnit> ();
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
	/// Handle a click on an InteractableObject
	/// </summary>
	protected void HandleClickOnInteractableObject (GameObject g) {
		if (verbose) Debug.Log ("Clicked on InteractableObject (" + g.name + ")");

		IInteractable interactable = g.GetComponent<IInteractable> ();

		if (selectedUnits.Count > 0)
			selectedUnits[0].SetTarget (g);
	}


	/// <summary>
	/// Handle a click on a Hostile Unit
	/// </summary>
	/// <param name="g"></param>
	protected void HandleClickOnHostile (GameObject g) {
		if (verbose) Debug.Log ("Clicked on Hostile (" + g.name + ")");

		HostileUnit hostileUnit = g.GetComponent<HostileUnit> ();

		foreach (ControllableUnit u in selectedUnits) {
			u.SetTarget (hostileUnit);
		}
	}


	public static Vector3 FindClosestValidPosition (Vector3 targetPosition) {
		NavMeshHit hit;
		NavMesh.SamplePosition (targetPosition, out hit, 5f, 1);

		return hit.position;
	}


	/// <summary>
	/// Toggle the game menu
	/// </summary>
	public void ToggleGameMenu () {
		isMenuPaused = !isMenuPaused;
		ToggleActivePause (false);
		UIManager.ToggleGameMenu ();
		postProcessingEffects.AnimateDoF (isMenuPaused);
	}


	/// <summary>
	/// Pause/unpause the game by editing the scene's timescale
	/// </summary>
	public void ToggleActivePause (bool shouldAnimate) {
		isPaused = !isPaused;

		foreach (IPauseable pauseableObject in FindObjectsOfType<MonoBehaviour> ().OfType<IPauseable> ()) {
			pauseableObject.Pause (isPaused);
		}

		if (shouldAnimate) {
			UIManager.TogglePauseIndicator ();
			postProcessingEffects.AnimateVignette (isPaused);
		}
	}
}