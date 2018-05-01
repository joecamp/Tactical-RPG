using UnityEngine;

public class PistolFlash : MonoBehaviour {

    public ParticleSystem flash;

    public void InstantiateMuzzleFlash () {
        flash.Play ();
    }
}