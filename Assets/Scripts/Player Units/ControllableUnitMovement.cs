using UnityEngine;
using UnityEngine.AI;

[RequireComponent (typeof (Rigidbody))]
[RequireComponent (typeof (CapsuleCollider))]
[RequireComponent (typeof (Animator))]
[RequireComponent (typeof (NavMeshAgent))]
[RequireComponent (typeof (NavMeshObstacle))]
public class ControllableUnitMovement : MonoBehaviour {

#pragma warning disable 414
    [SerializeField] NavMeshPathStatus pathStatus;
#pragma warning restore 414

    [SerializeField] float movingTurnSpeed = 360;
    [SerializeField] float stationaryTurnSpeed = 180;
    [SerializeField] float moveSpeedMultiplier = 1f;

    // References
    new Rigidbody rigidbody;
    Animator animator;
    NavMeshAgent agent;
    NavMeshObstacle obstacle;
    ControllableUnit controllableUnit;

    float turnAmount;
    float forwardAmount;

    void Start () {
        // get the components on the object we need (should not be null due to require component so no need to check)
        agent = GetComponentInChildren<NavMeshAgent> ();
        agent.updateRotation = false;
        agent.updatePosition = true;

        obstacle = GetComponent<NavMeshObstacle> ();

        animator = GetComponent<Animator> ();
        rigidbody = GetComponent<Rigidbody> ();
        controllableUnit = GetComponent<ControllableUnit> ();
    }


    private void Update () {
        pathStatus = agent.pathStatus;

        if (controllableUnit.state == ControllableUnit.UnitState.Idle) {
            Move (Vector3.zero);
            agent.updatePosition = false;
        }
        else if (controllableUnit.state == ControllableUnit.UnitState.Moving) {
            if (agent.hasPath && agent.remainingDistance > agent.stoppingDistance) {
                agent.updatePosition = true;

                if (agent.remainingDistance < 2f) {
                    Move (agent.desiredVelocity / 2f);
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

                controllableUnit.ReachedDestination ();
                Move (Vector3.zero);
                agent.updatePosition = false;
            }
        }

        /*if (Input.GetKeyDown (KeyCode.A)) {
            animator.SetTrigger ("EnterCode");
        }*/
    }


    public void Move (Vector3 move) {
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


    void UpdateAnimator (Vector3 move) {
        // update the animator parameters
        animator.SetFloat ("Forward", forwardAmount, 0.1f, Time.deltaTime);
        animator.SetFloat ("Turn", turnAmount, 0.1f, Time.deltaTime);
    }


    void ApplyExtraTurnRotation () {
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


    public void SetDestination (Vector3 target) {
        // become an agent
        obstacle.enabled = false;
        agent.enabled = true;

        // only make kinematic if we aren't currently paused
        if (controllableUnit.state != ControllableUnit.UnitState.Paused) {
            rigidbody.isKinematic = false;
        }

        agent.SetDestination (target);
    }


    public Vector3 FindClosestValidPosition (Vector3 targetPosition) {
        NavMeshHit hit;
        NavMesh.SamplePosition (targetPosition, out hit, 5f, 1);

        return hit.position;
    }


    public void PauseMovement (bool value) {
        animator.speed = value ? 0 : 1;
        agent.updatePosition = !value;

        // if the unit isn't moving, it will already be kinematic, 
        // so don't mess with it
        if (controllableUnit.state != ControllableUnit.UnitState.Idle) {
            rigidbody.isKinematic = value;
        }
    }


    private void OnDrawGizmos () {
        if (agent != null && agent.isOnNavMesh && agent.hasPath) {
            NavMeshPath path = agent.path;

            for (int i = 0; i < path.corners.Length - 1; i++) {
                Debug.DrawLine (path.corners[i], path.corners[i + 1], Color.blue);
            }
        }
    }
}