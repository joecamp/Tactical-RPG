using UnityEngine;
using UnityEngine.AI;

// TODO: Refactor into generic Unit that can be inherited for ControllableUnit and AI
[RequireComponent (typeof (Rigidbody))]
[RequireComponent (typeof (NavMeshAgent))]
[RequireComponent (typeof (NavMeshObstacle))]
[RequireComponent (typeof (Animator))]
public class ControllableUnit : MonoBehaviour, IInteractable, IPauseable {
	public enum UnitStateEnum {
		Paused,
		Idle,
		MovingToDestination,
		MovingToInteract,
		Interacting,
		MovingToAttack,
		Attacking
	};
	public enum CombatType {
		OHMelee,
		Pistol
	};
	public UnitStatSheet statSheet;
	public UnitStateEnum state;
	public CombatType combatType;
	public bool IsSelected { get; private set; }
	public bool IsHovered { get; private set; }

	[SerializeField] GameObject targetMarker;
	UnitStateEnum prevState;

	[SerializeField] NavMeshPathStatus pathStatus;
	[SerializeField] float movingTurnSpeed = 360;
	[SerializeField] float stationaryTurnSpeed = 180;
	[SerializeField] float moveSpeedMultiplier = 1f;
	[SerializeField] float slowdownDistance = 2f;
	[SerializeField] float slowedPercentage = .5f;

	// References
	new Rigidbody rigidbody;
	Animator animator;
	NavMeshAgent agent;
	NavMeshObstacle obstacle;
	SelectionRing selectionRing;

	float turnAmount;
	float forwardAmount;

	[SerializeField] InteractableToggleObject targetInteractableObject;

	protected void Awake () {
		selectionRing = GetComponentInChildren<SelectionRing> ();
		agent = GetComponentInChildren<NavMeshAgent> ();
		obstacle = GetComponent<NavMeshObstacle> ();
		animator = GetComponent<Animator> ();
		rigidbody = GetComponent<Rigidbody> ();
	}


	protected void Start () {
		IsSelected = false;
		state = UnitStateEnum.Idle;

		if (combatType == CombatType.OHMelee)
			animator.SetBool ("IsOHMelee", true);
		else if (combatType == CombatType.Pistol)
			animator.SetBool ("IsPistol", true);

		agent.updateRotation = false;
		agent.updatePosition = true;
	}


	protected void Update () {
		pathStatus = agent.pathStatus;

		switch (state) {
			case (UnitStateEnum.Idle):
				UpdateIdle ();
				break;

			case (UnitStateEnum.MovingToDestination):
				UpdateMovingToDestination ();
				break;

			case (UnitStateEnum.MovingToInteract):
				UpdateMovingToInteract ();
				break;

			case (UnitStateEnum.Interacting):
				break;

			case (UnitStateEnum.MovingToAttack):
				break;

			case (UnitStateEnum.Attacking):
				break;

			case (UnitStateEnum.Paused):
				break;
		}
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


	public void Pause (bool value) {
		if (value) {
			prevState = state;
			state = UnitStateEnum.Paused;
		}
		else {
			state = prevState;
		}

		animator.speed = value ? 0 : 1;
		agent.updatePosition = !value;

		// if the unit isn't moving, it will already be kinematic, 
		// so don't mess with it
		if (state != UnitStateEnum.Idle) {
			rigidbody.isKinematic = value;
		}
	}


	public void SetDestination (Vector3 point) {
		if (state == UnitStateEnum.Interacting) {
			return;
		}
		else if (state != UnitStateEnum.Paused) {
			state = UnitStateEnum.MovingToDestination;
		}
		else {
			prevState = UnitStateEnum.MovingToDestination;
		}

		Vector3 newDestination = GameManager.FindClosestValidPosition (point);

		targetMarker.SetActive (true);

		Vector3 newMarkerPosition = newDestination;
		newMarkerPosition.y = targetMarker.transform.position.y;
		targetMarker.transform.position = newMarkerPosition;

		// become an agent
		obstacle.enabled = false;
		agent.enabled = true;

		// only make kinematic if we aren't currently paused
		if (state != UnitStateEnum.Paused) {
			rigidbody.isKinematic = false;
		}

		agent.SetDestination (newDestination);
	}


	public void SetTarget (GameObject interactableObject) {
		InteractableToggleObject toggleObject;
		if (toggleObject = interactableObject.GetComponent<InteractableToggleObject> ()) {
			if (toggleObject.isBeingUsed)
				return;

			targetInteractableObject = toggleObject;
			toggleObject.isBeingUsed = true;
			state = UnitStateEnum.MovingToInteract;

			Vector3 newDestination = toggleObject.GetInteractTransform ().position;// GameManager.FindClosestValidPosition (toggleObject.GetInteractTransform ().position);

			targetMarker.SetActive (true);

			Vector3 newMarkerPosition = newDestination;
			newMarkerPosition.y = targetMarker.transform.position.y;
			targetMarker.transform.position = newMarkerPosition;

			// become an agent
			obstacle.enabled = false;
			agent.enabled = true;

			// only make kinematic if we aren't currently paused
			if (state != UnitStateEnum.Paused) {
				rigidbody.isKinematic = false;
			}

			agent.SetDestination (newDestination);
		}
	}


	public void SetTarget (HostileUnit hostileUnit) {

	}


	protected void UpdateIdle () {
		Move (Vector3.zero);
		agent.updatePosition = false;
	}


	protected void UpdateMovingToDestination () {
		if (agent.hasPath && agent.remainingDistance > agent.stoppingDistance) {
			agent.updatePosition = true;

			if (agent.remainingDistance < slowdownDistance) {
				Move (agent.desiredVelocity * slowedPercentage);
			}
			else {
				Move (agent.desiredVelocity);
			}
		}
		else {
			// Become an obstacle
			agent.enabled = false;
			obstacle.enabled = true;
			rigidbody.isKinematic = true;

			state = UnitStateEnum.Idle;
			targetMarker.SetActive (false);
			Move (Vector3.zero);
			agent.updatePosition = false;
		}
	}


	protected void UpdateMovingToInteract () {
		if (agent.hasPath && agent.remainingDistance > agent.stoppingDistance) {
			agent.updatePosition = true;

			if (agent.remainingDistance < slowdownDistance) {
				Move (agent.desiredVelocity * slowedPercentage);
			}
			else {
				Move (agent.desiredVelocity);
			}
		}
		else {
			// Become an obstacle
			agent.enabled = false;
			obstacle.enabled = true;
			rigidbody.isKinematic = true;

			transform.LookAt (targetInteractableObject.transform.position);

			state = UnitStateEnum.Interacting;
			targetMarker.SetActive (false);
			agent.updatePosition = false;

			animator.SetTrigger ("EnterCode");
		}
	}


	protected void UpdateInteracting () {

	}


	protected internal void Move (Vector3 move) {
		if (move == Vector3.zero) {
			forwardAmount = 0f;
			turnAmount = 0f;
			UpdateAnimator (move);
			return;
		}
		else {
			// convert the world relative move vector into a local-relative
			// turn amount and forward amount required to head in the desired direction
			if (move.magnitude > 1f) move.Normalize ();
			move = transform.InverseTransformDirection (move);
			turnAmount = Mathf.Atan2 (move.x, move.z);
			forwardAmount = move.z;

			ApplyExtraTurnRotation ();

			// send input and other state parameters to the animator
			UpdateAnimator (move);
		}
	}


	protected void UpdateAnimator (Vector3 move) {
		// update the animator parameters
		animator.SetFloat ("Forward", forwardAmount, 0.1f, Time.deltaTime);
		animator.SetFloat ("Turn", turnAmount, 0.1f, Time.deltaTime);
	}


	protected void ApplyExtraTurnRotation () {
		// help the character turn faster (this is in addition to root rotation in the animation)
		float turnSpeed = Mathf.Lerp (stationaryTurnSpeed, movingTurnSpeed, forwardAmount);
		transform.Rotate (0, turnAmount * turnSpeed * Time.deltaTime, 0);
	}


	public void OnAnimatorMove () {
		// we implement this function to override the default root motion
		// this allows us to modify the positional speed before it's applied
		Vector3 v = (animator.deltaPosition * moveSpeedMultiplier) / Time.deltaTime;

		if (float.IsNaN (v.x)) return;
		// we preserve the existing y part of the current velocity
		//v.y = rigidbody.velocity.y;
		v.y = 0f;
		rigidbody.velocity = v;
	}


	protected void OnCollisionEnter (Collision collision) {
		if (collision.collider.tag == "ControllableUnit")
			UnitCollisionManager.Instance.HandleUnitCollision (this, collision);
	}


	public void TriggerInteraction () {
		targetInteractableObject.isBeingUsed = false;
		targetInteractableObject.Click ();
		targetInteractableObject = null;
		state = UnitStateEnum.Idle;
	}


	// Callback method for equip weapon animations.
	// Without this, the combat layer overrides the base layer before the
	// unit has their weapon drawn.
	public void DoneEquippingWeapon () {
		animator.SetBool ("InCombat", true);
	}


	// draw the unit's path in editor for debugging
	private void OnDrawGizmos () {
		if (agent != null && agent.isOnNavMesh && agent.hasPath) {
			NavMeshPath path = agent.path;

			for (int i = 0; i < path.corners.Length - 1; i++) {
				Debug.DrawLine (path.corners[i], path.corners[i + 1], Color.blue);
			}
		}
	}
}