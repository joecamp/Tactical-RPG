using UnityEngine;

[CreateAssetMenu (fileName = "New Skill", menuName = "Skill", order = 1)]
public abstract class Skill : ScriptableObject {
    protected new string name;
    public string description;
    public Sprite artwork;
    public float cooldownTime;

    public virtual void Activate (ControllableUnit cu) {
        Debug.Log ("Activated skill: " + name);
    }

    public virtual void Deactivate (ControllableUnit cu) {
        Debug.Log ("Deactivated skill: " + name);
    }
}