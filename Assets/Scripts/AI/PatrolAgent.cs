using UnityEngine.AI;
using UnityEngine;

[RequireComponent (typeof (NavMeshAgent))]
public class PatrolAgent : MonoBehaviour, IPauseable {
    public enum PatrolBehavior { Loop, PingPong, Random };

    public PatrolBehavior patrolBehavior = PatrolBehavior.Loop;
    public Transform[] waypoints;

    NavMeshAgent agent;
    public int nextWaypointIdx;
    System.Random prng;

    // flag for PingPong behavior
    bool ascending = true;

    protected void Awake () {
        agent = GetComponent<NavMeshAgent> ();

        if (patrolBehavior == PatrolBehavior.Random)
            prng = new System.Random ();
    }


    protected void Update () {
        Patrol ();
    }


    protected void Patrol () {
        if (!agent.enabled) {
            return;
        }

        agent.destination = waypoints[nextWaypointIdx].position;

        if (agent.remainingDistance <= agent.stoppingDistance && !agent.pathPending) {
            switch (patrolBehavior) {
                case PatrolBehavior.Loop:
                    nextWaypointIdx = (nextWaypointIdx + 1) % waypoints.Length;
                    break;

                case PatrolBehavior.PingPong:
                    if (ascending) {
                        if (nextWaypointIdx != waypoints.Length - 1)
                            nextWaypointIdx++;
                        else {
                            nextWaypointIdx--;
                            ascending = false;
                        }
                    }
                    else {
                        if (nextWaypointIdx != 0) {
                            nextWaypointIdx--;
                        }
                        else {
                            nextWaypointIdx++;
                            ascending = true;
                        }
                    }
                    break;

                case PatrolBehavior.Random:
                    nextWaypointIdx = prng.Next (0, waypoints.Length);
                    break;
            }
        }
    }


    public void Pause (bool value) {
        //agent.updatePosition = !value;
        //agent.isStopped = value;
        agent.enabled = !value;
    }
}