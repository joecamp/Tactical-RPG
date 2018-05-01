using UnityEngine;

public class UnitCollisionManager : Singleton<UnitCollisionManager> {

    public void HandleUnitCollision (ControllableUnit unit, Collision collision) {
        Debug.Log (unit.name + " collided with " + collision.collider.name);
        ControllableUnit collidedUnit = collision.collider.GetComponent<ControllableUnit> ();
        if (unit.state == ControllableUnit.UnitState.Moving && collidedUnit.state == ControllableUnit.UnitState.Moving) {
            //GameManager.Instance.ToggleActivePause ();
        }
    }
}