using UnityEngine;

public class UnitCollisionManager : Singleton<UnitCollisionManager> {

    public void HandleUnitCollision (ControllableUnit unit, Collision collision) {
        Debug.Log (unit.name + " collided with " + collision.collider.name);
        ControllableUnit collidedUnit = collision.collider.GetComponent<ControllableUnit> ();
        if (unit.state == ControllableUnit.UnitStateEnum.MovingToDestination && collidedUnit.state == ControllableUnit.UnitStateEnum.MovingToDestination) {
            //GameManager.Instance.ToggleActivePause ();
        }
    }
}