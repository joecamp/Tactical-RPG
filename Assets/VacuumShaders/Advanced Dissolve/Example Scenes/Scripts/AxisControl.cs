using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AxisControl : MonoBehaviour
{
    public Material material;

    int axis;
    bool isGlobal;


    // Use this for initialization
    void Start()
    {
        ResetMaterial();
    }

    void OnDisable()
    {
        ResetMaterial();
    }



    void ResetMaterial()
    {
        UIToogleGlobal(true);
        UIAxisChanged(1);
        UIOffsetChanged(0.5f);
        UINoiseChanged(0);
        UIToggleInvert(true);
    }

    public void UIToogleGlobal(bool value)
    {
        isGlobal = value;

        if (material != null)
        {
            //Just for safety reasons dissable all keywords
            material.DisableKeyword("_DISSOLVEMASK_NONE");
            material.DisableKeyword("_DISSOLVEMASK_AXIS_LOCAL");
            material.DisableKeyword("_DISSOLVEMASK_AXIS_GLOBAL");
            material.DisableKeyword("_DISSOLVEMASK_PLANE");
            material.DisableKeyword("_DISSOLVEMASK_SPHERE");


            //Enable Local or Global
            if (isGlobal)
                material.EnableKeyword("_DISSOLVEMASK_AXIS_GLOBAL");
            else
                material.EnableKeyword("_DISSOLVEMASK_AXIS_LOCAL");
        }
    }

    public void UIAxisChanged(int value)
    {
        //X - 0
        //Y - 1
        //Z - 2

        axis = value;

        if (material != null)
            material.SetFloat("_DissolveCutoffAxis", axis);
    }    

    public void UIOffsetChanged(float value)
    {
        if(material != null)
             material.SetFloat("_DissolveMaskOffset", RemapSliderValue(value));
    }

    public void UINoiseChanged(float value)
    {
        if (material != null)
            material.SetFloat("_DissolveNoiseStrength", value);
    }

    public void UIToggleInvert(bool value)
    {
        if (material != null)
            material.SetFloat("_DissolveAxisInvert", value ? -1 : 1);
    }



    //UI slider value changes from 0 to 1
    //We adjust those value to make cutout effect more precision
    float RemapSliderValue(float value)
    {
        switch(axis)
        {
            case 0: //X
                if(isGlobal)
                    return Mathf.Lerp(-7f, 7.4f, value);
                else
                    return Mathf.Lerp(-1f, 1.5f, value);

            case 1: //Y
                if (isGlobal)
                    return Mathf.Lerp(-1f, 4f, value);
                else
                    return Mathf.Lerp(-1f, 4.2f, value);

            case 2: //Z
                if (isGlobal)
                    return Mathf.Lerp(-7.4f, 8f, value);
                else
                    return Mathf.Lerp(-1.2f, 1.2f, value);

            default:
                return 0.5f;
        }
        
    }
}