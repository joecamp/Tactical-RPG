using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class UpdateWorldPos : MonoBehaviour
{

    Material material;
    // Use this for initialization
    void Start()
    {
        material = GetComponent<Renderer>().sharedMaterial;
    }

    // Update is called once per frame
    void Update()
    {
        material.SetVector("_Dissolve_ObjectWorldPos", transform.position);
    }
}
