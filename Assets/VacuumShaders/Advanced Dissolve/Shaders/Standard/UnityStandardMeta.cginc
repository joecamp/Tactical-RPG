// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef UNITY_STANDARD_META_INCLUDED
#define UNITY_STANDARD_META_INCLUDED

// Functionality for Standard shader "meta" pass
// (extracts albedo/emission for lightmapper etc.)

// define meta pass before including other files; they have conditions
// on that in some places
#define UNITY_PASS_META 1

#include "UnityCG.cginc"
#include "UnityStandardInput.cginc"
#include "UnityMetaPass.cginc"
#include "UnityStandardCore.cginc"



//VacuumShaders
#include "UnityShaderVariables.cginc"
#include "Assets/VacuumShaders/Advanced Dissolve/Shaders/cginc/AdvancedDissolve.cginc"



struct v2f_meta
{
    float4 uv       : TEXCOORD0;
    float4 pos      : SV_POSITION;

	//VacuumShaders
	float4 dissolveUV : TEXCOORD1;
	float3 worldPos   : TEXCOORD2;
};

v2f_meta vert_meta (VertexInput v)
{
    v2f_meta o;
	

    o.pos = UnityMetaVertexPosition(v.vertex, v.uv1.xy, v.uv2.xy, unity_LightmapST, unity_DynamicLightmapST);
    o.uv = TexCoords(v);

	//VacuumShaders
	DissolveVertex2Fragment(v.uv0.xy, v.uv1.xy, o.dissolveUV);
	o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

	#if defined(_DISSOLVEMASK_AXIS_GLOBAL) || defined(_DISSOLVEMASK_PLANE) || defined(_DISSOLVEMASK_SPHERE)
		o.worldPos += _Dissolve_ObjectWorldPos;
	#endif


    return o;
}

// Albedo for lightmapping should basically be diffuse color.
// But rough metals (black diffuse) still scatter quite a lot of light around, so
// we want to take some of that into account too.
half3 UnityLightmappingAlbedo (half3 diffuse, half3 specular, half smoothness)
{
    half roughness = SmoothnessToRoughness(smoothness);
    half3 res = diffuse; 
    res += specular * roughness * 0.5;
    return res;
}

float4 frag_meta (v2f_meta i) : SV_Target
{
    // we're interested in diffuse & specular colors,
    // and surface roughness to produce final albedo.
	FragmentCommonData data = UNITY_SETUP_BRDF_INPUT(i.uv, i.dissolveUV, i.worldPos);

    UnityMetaInput o;
    UNITY_INITIALIZE_OUTPUT(UnityMetaInput, o);

#if defined(EDITOR_VISUALIZATION) 
    o.Albedo = data.diffColor;
#else
    o.Albedo = UnityLightmappingAlbedo (data.diffColor, data.specColor, data.smoothness);
#endif
    o.SpecularColor = data.specColor;

    //o.Emission = Emission(i.uv.xy);

	   
	//VacuumShaders
	o.Emission = DoDissolveEmission(data.alpha, Emission(i.uv.xy).rgb);


    return UnityMetaFragment(o);
	//return data.alpha;
}

#endif // UNITY_STANDARD_META_INCLUDED
