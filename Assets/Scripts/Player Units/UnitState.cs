using UnityEngine;

public abstract class UnitState : ControllableUnit {

	protected ControllableUnit controllableUnit;

	public abstract void UpdateState ();

	public virtual void EnterState (ControllableUnit controllableUnit) {
		this.controllableUnit = controllableUnit;
	}

	public virtual void ExitState () { }
}


public class IdleUnitState : UnitState {

	public override void UpdateState () {
	}


	public override void EnterState (ControllableUnit controllableUnit) {
		base.EnterState (controllableUnit);

		controllableUnit.Move (Vector3.zero);

	}
}