using UnityEngine;

[RequireComponent (typeof (ParticleSystem))]
public class PauseableParticleSystem : MonoBehaviour, IPauseable {

    new ParticleSystem particleSystem;

    protected void Awake () {
        particleSystem = GetComponent<ParticleSystem> ();
    }

    public void Pause (bool value) {
        if (value) particleSystem.Pause ();
        else particleSystem.Play ();
    }
}