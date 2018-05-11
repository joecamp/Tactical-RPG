using UnityEngine;

// TODO: Will this stuff be modified by the unit's equipped weapon?
[CreateAssetMenu (fileName = "New StatSheet", menuName = "Unit/Unit StatSheet", order = 1)]
public class UnitStatSheet : ScriptableObject {
	[Tooltip ("How many damage points this unit can take before it perishes")]
	public int health = 20;
	[Tooltip ("Base damage points applied per attack")]
	public int attackPower = 2;
	[Tooltip ("How quickly this unit attacks; 1 second / attackSpeed = time it takes for a single attack")]
	public float attackSpeed = 1f;
	[Tooltip ("The minimum distance from a hostile that this unit can attack from")]
	public float attackRange = 1f;
}