using System.Linq;
using System.Collections.Generic;
using System.Collections;
using UnityEngine;

// Attach to base parent
public class ShaderAnimations : MonoBehaviour {

    public float disappearTime = 1f;
    public float reappearTime = 1f;

    List<Renderer> renderers;

    void Awake () {
        renderers = GetComponentsInChildren<Renderer> ().ToList ();
    }


    public void Dissolve () {
        StopAllCoroutines ();
        StartCoroutine (PerformDissolve ());
    }


    public void Reappear () {
        StopAllCoroutines ();
        StartCoroutine (PerformReappear ());
    }


    IEnumerator PerformDissolve () {
        float i = 0;
        float speed = 1 / disappearTime;

        while (i < 1) {
            foreach (Renderer r in renderers) {
                foreach (Material m in r.materials) {
                    m.SetFloat ("_Cutoff", Mathf.Lerp (0, 1, i));
                    m.SetVector ("_Dissolve_ObjectWorldPos", transform.position);
                }
                RendererExtensions.UpdateGIMaterials (r);
            }

            i += Time.deltaTime * speed;
            yield return 0;
        }

        // Ensure that materials are set to final value
        foreach (Renderer r in renderers) {
            foreach (Material m in r.materials) {
                m.SetFloat ("_Cutoff", 1f);
                m.SetVector ("_Dissolve_ObjectWorldPos", transform.position);
            }
            RendererExtensions.UpdateGIMaterials (r);
        }
    }


    IEnumerator PerformReappear () {
        float i = 1;
        float speed = 1 / reappearTime;

        while (i > 0) {
            foreach (Renderer r in renderers) {
                foreach (Material m in r.materials) {
                    m.SetFloat ("_Cutoff", Mathf.Lerp (0, 1, i));
                    m.SetVector ("_Dissolve_ObjectWorldPos", transform.position);
                }
                RendererExtensions.UpdateGIMaterials (r);
            }

            i -= Time.deltaTime * speed;
            yield return 0;
        }

        // Ensure that materials are set to final value
        foreach (Renderer r in renderers) {
            foreach (Material m in r.materials) {
                m.SetFloat ("_Cutoff", 0f);
                m.SetVector ("_Dissolve_ObjectWorldPos", transform.position);
            }
            RendererExtensions.UpdateGIMaterials (r);
        }
    }
}