using UnityEngine;

[CreateAssetMenu (menuName = "Skill/CloakSkill")]
public class CloakSkill : Skill {

    public ParticleSystem activationParticlePrefab;
    public ParticleSystem deactivationParticlePrefab;

    public override void Activate (ControllableUnit cu) {
        base.Activate (cu);

        Instantiate (activationParticlePrefab, cu.transform.position, cu.transform.rotation);
    }


    public override void Deactivate (ControllableUnit cu) {
        base.Activate (cu);
        Instantiate (activationParticlePrefab, cu.transform.position, cu.transform.rotation);
    }
}