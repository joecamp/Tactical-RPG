Shader "VacuumShaders/Advanced Dissolve/Physically Based/Metallic" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGBA)", 2D) = "white" {}
		_BumpMap("Normalmap", 2D) = "bump" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		[Enum(Main Map Alpha,0,Mettalic Map Alpha,1)] _MetallicAlpha("   Source", Float) = 0
		_MetallicTex("   Metallic Map (A)", 2D) = "black"{}



		[MaterialEnum(Off,0,Front,1,Back,2)] _Cull("Face Cull", Int) = 0

		[HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.500000
		
			 
		[HideInInspector][KeywordEnum(None, Axis Local, Axis Global, Plane, Sphere)]  _DissolveMask("", Float) = 0
		[HideInInspector][Enum(X,0,Y,1,Z,2)]  _DissolveCutoffAxis("Axis", Float) = 0
		[HideInInspector]_DissolveAxisInvert("Axis Invert", Float) = 1
		[HideInInspector]_DissolveMaskOffset("Mask Offset", Float) = 0
		[HideInInspector]_DissolveEdgeSize("Edge Size", Range(0,1)) = 0.15
		[HideInInspector][HDR]  _DissolveEdgeColor("Edge Color", Color) = (1,1,1,1)
		[HideInInspector][NoScaleOffset]  _DissolveEdgeRamp("Ramp", 2D) = "white" { }
		[HideInInspector]_DissolveGIStrength("GI Strength", Float) = 1
		[HideInInspector][KeywordEnum(Main Map Alpha, Custom Map, Two Custom Maps, Three Custom Maps)]  _DissolveAlphaSource("", Float) = 0
		[HideInInspector]_DissolveMap1("", 2D) = "white" { }
		[HideInInspector][UVScroll]  _DissolveMap1_Scroll("", Vector) = (0,0,0,0)
		[HideInInspector]_DissolveMap2("", 2D) = "white" { }
		[HideInInspector][UVScroll]  _DissolveMap2_Scroll("", Vector) = (0,0,0,0)
		[HideInInspector]_DissolveMap3("", 2D) = "white" { }
		[HideInInspector][UVScroll]  _DissolveMap3_Scroll("", Vector) = (0,0,0,0)
		[HideInInspector]_DissolveNoiseStrength("", Range(0,1)) = 0.100000
		[HideInInspector][KeywordEnum(Multiply, Add)]  _DissolveAlphaTextureBlend("", Float) = 0
		[HideInInspector][Enum(UV0,0,UV1,1)] _DissolveUVSet("UV Set", Float) = 0

		[HideInInspector]  _DissolveMaskPosition("", Vector) = (0,0,0,0)
		[HideInInspector]  _DissolveMaskPlaneNormal("", Vector) = (1,0,0,0)
		[HideInInspector]  _DissolveMaskSphereRadius("", Float) = 1
		[HideInInspector]  _Dissolve_ObjectWorldPos("wPos", Vector) = (0,0,0,0)


		[HideInInspector][Toggle] _DissolveTriplanar("Triplanar?", Float) = 0
		[HideInInspector][Enum(World Space, 0, Object Space, 1)]  _DissolveTriplanarMapping("", Float) = 0
		[HideInInspector] _DissolveTriplanarTiling("", Float) = 1

			[HideInInspector][Toggle] _DissolveTriplanar("Triplanar?", Float) = 0
			[HideInInspector][Enum(World Space, 0, Object Space, 1)]  _DissolveTriplanarMapping("", Float) = 0
			[HideInInspector] _DissolveTriplanarTiling("", Float) = 1
	}
	
	SubShader 
	{
		Tags{ "RenderType" = "AdvancedDissolveCutout" "DisableBatching" = "True" }
		Cull[_Cull]

		LOD 200

		
	// ------------------------------------------------------------
	// Surface shader code generated out of a CGPROGRAM block:
	

	// ---- forward rendering base pass:
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }

CGPROGRAM
// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma target 3.0
#pragma multi_compile_instancing
#pragma multi_compile_fog
#pragma multi_compile_fwdbase
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityShaderUtilities.cginc"
// -------- variant for: <when no other keywords are defined>

// -------- variant for: INSTANCING_ON 
// Surface shader code generated based on:
// writes to per-pixel normal: YES
// writes to emission: no
// writes to occlusion: no
// needs world space reflection vector: no
// needs world space normal vector: no
// needs screen space position: no
// needs world space position: no
// needs view direction: no
// needs world space view direction: no
// needs world space position for lighting: YES
// needs world space view direction for lighting: YES
// needs world space view direction for lightmaps: no
// needs vertex color: no
// needs VFACE: no
// passes tangent-to-world matrix to pixel shader: YES
// reads from normal: no
// 3 texcoords actually used
//   float2 _MainTex
//   float2 _MetallicTex
//   float2 _BumpMap
#define UNITY_PASS_FORWARDBASE
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))

// Original surface shader snippet:
#line 49 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif
/* UNITY: Original start of shader */
		// Physically based Standard lighting model, and enable shadows on all light types
		//#pragma surface surf Standard fullforwardshadows addshadow

		// Use shader model 3.0 target, to get nicer looking lighting
		//#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _MetallicTex;
		sampler2D _BumpMap;
		fixed _Cutoff;

#pragma shader_feature _ _DISSOLVETRIPLANAR_ON
#pragma shader_feature _DISSOLVEALPHASOURCE_MAIN_MAP_ALPHA _DISSOLVEALPHASOURCE_CUSTOM_MAP _DISSOLVEALPHASOURCE_TWO_CUSTOM_MAPS _DISSOLVEALPHASOURCE_THREE_CUSTOM_MAPS
#pragma shader_feature _DISSOLVEMASK_NONE _DISSOLVEMASK_AXIS_LOCAL _DISSOLVEMASK_AXIS_GLOBAL _DISSOLVEMASK_PLANE _DISSOLVEMASK_SPHERE
#pragma shader_feature _DISSOLVEALPHATEXTUREBLEND_MULTIPLY _DISSOLVEALPHATEXTUREBLEND_ADD
#include "Assets/VacuumShaders/Advanced Dissolve/Shaders/cginc/AdvancedDissolve.cginc"

		struct Input {
			float2 uv_MainTex;
			float2 uv_MetallicTex;
			float2 uv_BumpMap;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _MetallicAlpha;


		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = lerp(c.a, tex2D(_MetallicTex, IN.uv_MetallicTex).a, _MetallicAlpha) * _Metallic;
			o.Smoothness = _Glossiness;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			o.Alpha = c.a;
		}
		

// vertex-to-fragment interpolation data
// no lightmaps:
#ifndef LIGHTMAP_ON
struct v2f_surf {
  UNITY_POSITION(pos);
  float4 pack0 : TEXCOORD0; // _MainTex _MetallicTex
  float2 pack1 : TEXCOORD1; // _BumpMap
  float4 tSpace0 : TEXCOORD2;
  float4 tSpace1 : TEXCOORD3;
  float4 tSpace2 : TEXCOORD4;
  #if UNITY_SHOULD_SAMPLE_SH
  half3 sh : TEXCOORD5; // SH
  #endif
  UNITY_SHADOW_COORDS(6)
  UNITY_FOG_COORDS(7)
  #if SHADER_TARGET >= 30
  float4 lmap : TEXCOORD8;
  #endif
  UNITY_VERTEX_INPUT_INSTANCE_ID
  UNITY_VERTEX_OUTPUT_STEREO

#ifdef _DISSOLVETRIPLANAR_ON
	  half3 objNormal : TEXCOORD9;
  float3 coords : TEXCOORD10;
#else
	  float4 dissolveUV : TEXCOORD9;
#endif
};
#endif
// with lightmaps:
#ifdef LIGHTMAP_ON
struct v2f_surf {
  UNITY_POSITION(pos);
  float4 pack0 : TEXCOORD0; // _MainTex _MetallicTex
  float2 pack1 : TEXCOORD1; // _BumpMap
  float4 tSpace0 : TEXCOORD2;
  float4 tSpace1 : TEXCOORD3;
  float4 tSpace2 : TEXCOORD4;
  float4 lmap : TEXCOORD5;
  UNITY_SHADOW_COORDS(6)
  UNITY_FOG_COORDS(7)
  UNITY_VERTEX_INPUT_INSTANCE_ID
  UNITY_VERTEX_OUTPUT_STEREO

#ifdef _DISSOLVETRIPLANAR_ON
  half3 objNormal : TEXCOORD8;
  float3 coords : TEXCOORD9;
#else
  float4 dissolveUV : TEXCOORD8;
#endif

};
#endif
float4 _MainTex_ST;
float4 _MetallicTex_ST;
float4 _BumpMap_ST;

// vertex shader
v2f_surf vert_surf (appdata_full v) {
  UNITY_SETUP_INSTANCE_ID(v);
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
  UNITY_TRANSFER_INSTANCE_ID(v,o);
  UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
  o.pos = UnityObjectToClipPos(v.vertex);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
  o.pack0.zw = TRANSFORM_TEX(v.texcoord, _MetallicTex);
  o.pack1.xy = TRANSFORM_TEX(v.texcoord, _BumpMap);
  float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
  fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
  fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
  fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
  fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
  o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
  o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
  o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
  #ifdef DYNAMICLIGHTMAP_ON
  o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
  #endif
  #ifdef LIGHTMAP_ON
  o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
  #endif

  // SH/ambient and vertex lights
  #ifndef LIGHTMAP_ON
    #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
      o.sh = 0;
      // Approximated illumination from non-important point lights
      #ifdef VERTEXLIGHT_ON
        o.sh += Shade4PointLights (
          unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
          unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
          unity_4LightAtten0, worldPos, worldNormal);
      #endif
      o.sh = ShadeSHPerVertex (worldNormal, o.sh);
    #endif
  #endif // !LIGHTMAP_ON

  UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy); // pass shadow coordinates to pixel shader
  UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader


   //VacuumShaders
#ifdef _DISSOLVETRIPLANAR_ON
  o.coords = v.vertex;
  o.objNormal = lerp(worldNormal, v.normal, _DissolveTriplanarMapping);
#else
  DissolveVertex2Fragment(v.texcoord.xy, v.texcoord1.xy, o.dissolveUV);
#endif

  return o;
}

// fragment shader
fixed4 frag_surf (v2f_surf IN) : SV_Target {
  UNITY_SETUP_INSTANCE_ID(IN);

float3 worldPos = float3(IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w);
#ifdef _DISSOLVETRIPLANAR_ON
	float alpha = ReadDissolveAlpha_Triplanar(IN.coords, IN.objNormal, worldPos);
#else
	float alpha = ReadDissolveAlpha(IN.pack0.xy, IN.dissolveUV, worldPos);
#endif
DoDissolveClip(alpha);


  // prepare and unpack data
  Input surfIN;
  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
  surfIN.uv_MainTex.x = 1.0;
  surfIN.uv_MetallicTex.x = 1.0;
  surfIN.uv_BumpMap.x = 1.0;
  surfIN.uv_MainTex = IN.pack0.xy;
  surfIN.uv_MetallicTex = IN.pack0.zw;
  surfIN.uv_BumpMap = IN.pack1.xy;
 
  #ifndef USING_DIRECTIONAL_LIGHT
    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
  #else
    fixed3 lightDir = _WorldSpaceLightPos0.xyz;
  #endif
  fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutputStandard o = (SurfaceOutputStandard)0;
  #else
  SurfaceOutputStandard o;
  #endif
  o.Albedo = 0.0;
  o.Emission = 0.0;
  o.Alpha = 0.0;
  o.Occlusion = 1.0;
  fixed3 normalWorldVertex = fixed3(0,0,1);
  o.Normal = fixed3(0,0,1);

  // call surface function
  surf (surfIN, o);

  // compute lighting & shadowing factor
  UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
  fixed4 c = 0;
  fixed3 worldN;
  worldN.x = dot(IN.tSpace0.xyz, o.Normal);
  worldN.y = dot(IN.tSpace1.xyz, o.Normal);
  worldN.z = dot(IN.tSpace2.xyz, o.Normal);
  worldN = normalize(worldN);
  o.Normal = worldN;

  // Setup lighting environment
  UnityGI gi;
  UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
  gi.indirect.diffuse = 0;
  gi.indirect.specular = 0;
  gi.light.color = _LightColor0.rgb;
  gi.light.dir = lightDir;
  // Call GI (lightmaps/SH/reflections) lighting function
  UnityGIInput giInput;
  UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
  giInput.light = gi.light;
  giInput.worldPos = worldPos;
  giInput.worldViewDir = worldViewDir;
  giInput.atten = atten;
  #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
    giInput.lightmapUV = IN.lmap;
  #else
    giInput.lightmapUV = 0.0;
  #endif
  #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
    giInput.ambient = IN.sh;
  #else
    giInput.ambient.rgb = 0.0;
  #endif
  giInput.probeHDR[0] = unity_SpecCube0_HDR;
  giInput.probeHDR[1] = unity_SpecCube1_HDR;
  #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
    giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
  #endif
  #ifdef UNITY_SPECCUBE_BOX_PROJECTION
    giInput.boxMax[0] = unity_SpecCube0_BoxMax;
    giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
    giInput.boxMax[1] = unity_SpecCube1_BoxMax;
    giInput.boxMin[1] = unity_SpecCube1_BoxMin;
    giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
  #endif
  LightingStandard_GI(o, giInput, gi);

  // realtime lighting: call lighting function
  c += LightingStandard (o, worldViewDir, gi);

  c.rgb += DoDissolveEmission(alpha, o.Emission);


  UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
  UNITY_OPAQUE_ALPHA(c.a);
  return c;
}




ENDCG

}

	// ---- forward rendering additive lights pass:
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardAdd" }
		ZWrite Off Blend One One

CGPROGRAM
// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma target 3.0
#pragma multi_compile_instancing
#pragma multi_compile_fog
#pragma skip_variants INSTANCING_ON
#pragma multi_compile_fwdadd_fullshadows
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityShaderUtilities.cginc"
// -------- variant for: <when no other keywords are defined>
// Surface shader code generated based on:
// writes to per-pixel normal: YES
// writes to emission: no
// writes to occlusion: no
// needs world space reflection vector: no
// needs world space normal vector: no
// needs screen space position: no
// needs world space position: no
// needs view direction: no
// needs world space view direction: no
// needs world space position for lighting: YES
// needs world space view direction for lighting: YES
// needs world space view direction for lightmaps: no
// needs vertex color: no
// needs VFACE: no
// passes tangent-to-world matrix to pixel shader: YES
// reads from normal: no
// 3 texcoords actually used
//   float2 _MainTex
//   float2 _MetallicTex
//   float2 _BumpMap
#define UNITY_PASS_FORWARDADD
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"

#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))

// Original surface shader snippet:
#line 49 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif
/* UNITY: Original start of shader */
		// Physically based Standard lighting model, and enable shadows on all light types
		//#pragma surface surf Standard fullforwardshadows addshadow

		// Use shader model 3.0 target, to get nicer looking lighting
		//#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _MetallicTex;
		sampler2D _BumpMap;
		fixed _Cutoff;

#pragma shader_feature _ _DISSOLVETRIPLANAR_ON
#pragma shader_feature _DISSOLVEALPHASOURCE_MAIN_MAP_ALPHA _DISSOLVEALPHASOURCE_CUSTOM_MAP _DISSOLVEALPHASOURCE_TWO_CUSTOM_MAPS _DISSOLVEALPHASOURCE_THREE_CUSTOM_MAPS
#pragma shader_feature _DISSOLVEMASK_NONE _DISSOLVEMASK_AXIS_LOCAL _DISSOLVEMASK_AXIS_GLOBAL _DISSOLVEMASK_PLANE _DISSOLVEMASK_SPHERE
#pragma shader_feature _DISSOLVEALPHATEXTUREBLEND_MULTIPLY _DISSOLVEALPHATEXTUREBLEND_ADD
#include "Assets/VacuumShaders/Advanced Dissolve/Shaders/cginc/AdvancedDissolve.cginc"

		struct Input {
			float2 uv_MainTex;
			float2 uv_MetallicTex;
			float2 uv_BumpMap;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _MetallicAlpha;


		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = lerp(c.a, tex2D(_MetallicTex, IN.uv_MetallicTex).a, _MetallicAlpha) * _Metallic;
			o.Smoothness = _Glossiness;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			o.Alpha = c.a;
		}
		

// vertex-to-fragment interpolation data
struct v2f_surf {
  UNITY_POSITION(pos);
  float4 pack0 : TEXCOORD0; // _MainTex _MetallicTex
  float2 pack1 : TEXCOORD1; // _BumpMap
  fixed3 tSpace0 : TEXCOORD2;
  fixed3 tSpace1 : TEXCOORD3;
  fixed3 tSpace2 : TEXCOORD4;
  float3 worldPos : TEXCOORD5;
  UNITY_SHADOW_COORDS(6)
  UNITY_FOG_COORDS(7)
  UNITY_VERTEX_INPUT_INSTANCE_ID
  UNITY_VERTEX_OUTPUT_STEREO

#ifdef _DISSOLVETRIPLANAR_ON
	  half3 objNormal : TEXCOORD8;
  float3 coords : TEXCOORD9;
#else
	  float4 dissolveUV : TEXCOORD8;
#endif
};
float4 _MainTex_ST;
float4 _MetallicTex_ST;
float4 _BumpMap_ST;

// vertex shader
v2f_surf vert_surf (appdata_full v) {
  UNITY_SETUP_INSTANCE_ID(v);
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
  UNITY_TRANSFER_INSTANCE_ID(v,o);
  UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
  o.pos = UnityObjectToClipPos(v.vertex);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
  o.pack0.zw = TRANSFORM_TEX(v.texcoord, _MetallicTex);
  o.pack1.xy = TRANSFORM_TEX(v.texcoord, _BumpMap);
  float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
  fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
  fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
  fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
  fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
  o.tSpace0 = fixed3(worldTangent.x, worldBinormal.x, worldNormal.x);
  o.tSpace1 = fixed3(worldTangent.y, worldBinormal.y, worldNormal.y);
  o.tSpace2 = fixed3(worldTangent.z, worldBinormal.z, worldNormal.z);
  o.worldPos = worldPos;

  UNITY_TRANSFER_SHADOW(o,v.texcoord1.xy); // pass shadow coordinates to pixel shader
  UNITY_TRANSFER_FOG(o,o.pos); // pass fog coordinates to pixel shader

  //VacuumShaders
#ifdef _DISSOLVETRIPLANAR_ON
  o.coords = v.vertex;
  o.objNormal = lerp(worldNormal, v.normal, _DissolveTriplanarMapping);
#else
  DissolveVertex2Fragment(v.texcoord, v.texcoord1.xy, o.dissolveUV);
#endif

  return o;
}

// fragment shader
fixed4 frag_surf (v2f_surf IN) : SV_Target {
  UNITY_SETUP_INSTANCE_ID(IN);
  // prepare and unpack data

#ifdef _DISSOLVETRIPLANAR_ON
float alpha = ReadDissolveAlpha_Triplanar(IN.coords, IN.objNormal, IN.worldPos);
#else
float alpha = ReadDissolveAlpha(IN.pack0.xy, IN.dissolveUV, IN.worldPos);
#endif
DoDissolveClip(alpha);


  Input surfIN;
  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
  surfIN.uv_MainTex.x = 1.0;
  surfIN.uv_MetallicTex.x = 1.0;
  surfIN.uv_BumpMap.x = 1.0;
  surfIN.uv_MainTex = IN.pack0.xy;
  surfIN.uv_MetallicTex = IN.pack0.zw;
  surfIN.uv_BumpMap = IN.pack1.xy;
  float3 worldPos = IN.worldPos;
  #ifndef USING_DIRECTIONAL_LIGHT
    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
  #else
    fixed3 lightDir = _WorldSpaceLightPos0.xyz;
  #endif
  fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutputStandard o = (SurfaceOutputStandard)0;
  #else
  SurfaceOutputStandard o;
  #endif
  o.Albedo = 0.0;
  o.Emission = 0.0;
  o.Alpha = 0.0;
  o.Occlusion = 1.0;
  fixed3 normalWorldVertex = fixed3(0,0,1);
  o.Normal = fixed3(0,0,1);

  // call surface function
  surf (surfIN, o);
  UNITY_LIGHT_ATTENUATION(atten, IN, worldPos)
  fixed4 c = 0;
  fixed3 worldN;
  worldN.x = dot(IN.tSpace0.xyz, o.Normal);
  worldN.y = dot(IN.tSpace1.xyz, o.Normal);
  worldN.z = dot(IN.tSpace2.xyz, o.Normal);
  worldN = normalize(worldN);
  o.Normal = worldN;

  // Setup lighting environment
  UnityGI gi;
  UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
  gi.indirect.diffuse = 0;
  gi.indirect.specular = 0;
  gi.light.color = _LightColor0.rgb;
  gi.light.dir = lightDir;
  gi.light.color *= atten;
  c += LightingStandard (o, worldViewDir, gi);
  c.a = 0.0;
  UNITY_APPLY_FOG(IN.fogCoord, c); // apply fog
  UNITY_OPAQUE_ALPHA(c.a);
  return c;
}




ENDCG

}

	// ---- deferred shading pass:
	Pass {
		Name "DEFERRED"
		Tags { "LightMode" = "Deferred" }

CGPROGRAM
// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma target 3.0
#pragma multi_compile_instancing
#pragma exclude_renderers nomrt
#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
#pragma multi_compile_prepassfinal
#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityShaderUtilities.cginc"
// -------- variant for: <when no other keywords are defined>
// Surface shader code generated based on:
// writes to per-pixel normal: YES
// writes to emission: no
// writes to occlusion: no
// needs world space reflection vector: no
// needs world space normal vector: no
// needs screen space position: no
// needs world space position: no
// needs view direction: no
// needs world space view direction: no
// needs world space position for lighting: YES
// needs world space view direction for lighting: YES
// needs world space view direction for lightmaps: no
// needs vertex color: no
// needs VFACE: no
// passes tangent-to-world matrix to pixel shader: YES
// reads from normal: no
// 3 texcoords actually used
//   float2 _MainTex
//   float2 _MetallicTex
//   float2 _BumpMap
#define UNITY_PASS_DEFERRED
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityPBSLighting.cginc"

#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))

// Original surface shader snippet:
#line 49 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif
/* UNITY: Original start of shader */
		// Physically based Standard lighting model, and enable shadows on all light types
		//#pragma surface surf Standard fullforwardshadows addshadow

		// Use shader model 3.0 target, to get nicer looking lighting
		//#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _MetallicTex;
		sampler2D _BumpMap;
		fixed _Cutoff;

#pragma shader_feature _ _DISSOLVETRIPLANAR_ON
#pragma shader_feature _DISSOLVEALPHASOURCE_MAIN_MAP_ALPHA _DISSOLVEALPHASOURCE_CUSTOM_MAP _DISSOLVEALPHASOURCE_TWO_CUSTOM_MAPS _DISSOLVEALPHASOURCE_THREE_CUSTOM_MAPS
#pragma shader_feature _DISSOLVEMASK_NONE _DISSOLVEMASK_AXIS_LOCAL _DISSOLVEMASK_AXIS_GLOBAL _DISSOLVEMASK_PLANE _DISSOLVEMASK_SPHERE
#pragma shader_feature _DISSOLVEALPHATEXTUREBLEND_MULTIPLY _DISSOLVEALPHATEXTUREBLEND_ADD
#include "Assets/VacuumShaders/Advanced Dissolve/Shaders/cginc/AdvancedDissolve.cginc"

		struct Input {
			float2 uv_MainTex;
			float2 uv_MetallicTex;
			float2 uv_BumpMap;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _MetallicAlpha;


		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = lerp(c.a, tex2D(_MetallicTex, IN.uv_MetallicTex).a, _MetallicAlpha) * _Metallic;
			o.Smoothness = _Glossiness;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			o.Alpha = c.a;
		}
		

// vertex-to-fragment interpolation data
struct v2f_surf {
  UNITY_POSITION(pos);
  float4 pack0 : TEXCOORD0; // _MainTex _MetallicTex
  float2 pack1 : TEXCOORD1; // _BumpMap
  float4 tSpace0 : TEXCOORD2;
  float4 tSpace1 : TEXCOORD3;
  float4 tSpace2 : TEXCOORD4;
#ifndef DIRLIGHTMAP_OFF
  half3 viewDir : TEXCOORD5;
#endif
  float4 lmap : TEXCOORD6;
#ifndef LIGHTMAP_ON
  #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
    half3 sh : TEXCOORD7; // SH
  #endif
#else
  #ifdef DIRLIGHTMAP_OFF
    float4 lmapFadePos : TEXCOORD7;
  #endif
#endif
  UNITY_VERTEX_INPUT_INSTANCE_ID
  UNITY_VERTEX_OUTPUT_STEREO

#ifdef _DISSOLVETRIPLANAR_ON
	  half3 objNormal : TEXCOORD8;
  float3 coords : TEXCOORD9;
#else
	  float4 dissolveUV : TEXCOORD8;
#endif
};
float4 _MainTex_ST;
float4 _MetallicTex_ST;
float4 _BumpMap_ST;

// vertex shader
v2f_surf vert_surf (appdata_full v) {
  UNITY_SETUP_INSTANCE_ID(v);
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
  UNITY_TRANSFER_INSTANCE_ID(v,o);
  UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
  o.pos = UnityObjectToClipPos(v.vertex);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
  o.pack0.zw = TRANSFORM_TEX(v.texcoord, _MetallicTex);
  o.pack1.xy = TRANSFORM_TEX(v.texcoord, _BumpMap);
  float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
  fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
  fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
  fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
  fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
  o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
  o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
  o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
  float3 viewDirForLight = UnityWorldSpaceViewDir(worldPos);
  #ifndef DIRLIGHTMAP_OFF
  o.viewDir.x = dot(viewDirForLight, worldTangent);
  o.viewDir.y = dot(viewDirForLight, worldBinormal);
  o.viewDir.z = dot(viewDirForLight, worldNormal);
  #endif
#ifdef DYNAMICLIGHTMAP_ON
  o.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#else
  o.lmap.zw = 0;
#endif
#ifdef LIGHTMAP_ON
  o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
  #ifdef DIRLIGHTMAP_OFF
    o.lmapFadePos.xyz = (mul(unity_ObjectToWorld, v.vertex).xyz - unity_ShadowFadeCenterAndType.xyz) * unity_ShadowFadeCenterAndType.w;
    o.lmapFadePos.w = (-UnityObjectToViewPos(v.vertex).z) * (1.0 - unity_ShadowFadeCenterAndType.w);
  #endif
#else
  o.lmap.xy = 0;
    #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
      o.sh = 0;
      o.sh = ShadeSHPerVertex (worldNormal, o.sh);
    #endif
#endif



	  //VacuumShaders
#ifdef _DISSOLVETRIPLANAR_ON
	  o.coords = v.vertex;
	  o.objNormal = lerp(worldNormal, v.normal, _DissolveTriplanarMapping);
#else
	  DissolveVertex2Fragment(v.texcoord.xy, v.texcoord1.xy, o.dissolveUV);
#endif

  return o;
}
#ifdef LIGHTMAP_ON
float4 unity_LightmapFade;
#endif
fixed4 unity_Ambient;

// fragment shader
void frag_surf (v2f_surf IN,
    out half4 outGBuffer0 : SV_Target0,
    out half4 outGBuffer1 : SV_Target1,
    out half4 outGBuffer2 : SV_Target2,
    out half4 outEmission : SV_Target3
#if defined(SHADOWS_SHADOWMASK) && (UNITY_ALLOWED_MRT_COUNT > 4)
    , out half4 outShadowMask : SV_Target4
#endif
) {
  UNITY_SETUP_INSTANCE_ID(IN);
  // prepare and unpack data

  float3 worldPos = float3(IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w);
#ifdef _DISSOLVETRIPLANAR_ON
  float alpha = ReadDissolveAlpha_Triplanar(IN.coords, IN.objNormal, worldPos);
#else
  float alpha = ReadDissolveAlpha(IN.pack0.xy, IN.dissolveUV, worldPos);
#endif
  DoDissolveClip(alpha);


  Input surfIN;
  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
  surfIN.uv_MainTex.x = 1.0;
  surfIN.uv_MetallicTex.x = 1.0;
  surfIN.uv_BumpMap.x = 1.0;
  surfIN.uv_MainTex = IN.pack0.xy;
  surfIN.uv_MetallicTex = IN.pack0.zw;
  surfIN.uv_BumpMap = IN.pack1.xy;
 
  #ifndef USING_DIRECTIONAL_LIGHT
    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
  #else
    fixed3 lightDir = _WorldSpaceLightPos0.xyz;
  #endif
  fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutputStandard o = (SurfaceOutputStandard)0;
  #else
  SurfaceOutputStandard o;
  #endif
  o.Albedo = 0.0;
  o.Emission = 0.0;
  o.Alpha = 0.0;
  o.Occlusion = 1.0;
  fixed3 normalWorldVertex = fixed3(0,0,1);
  o.Normal = fixed3(0,0,1);

  // call surface function
  surf (surfIN, o);
fixed3 originalNormal = o.Normal;
  fixed3 worldN;
  worldN.x = dot(IN.tSpace0.xyz, o.Normal);
  worldN.y = dot(IN.tSpace1.xyz, o.Normal);
  worldN.z = dot(IN.tSpace2.xyz, o.Normal);
  worldN = normalize(worldN);
  o.Normal = worldN;
  half atten = 1;

  // Setup lighting environment
  UnityGI gi;
  UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
  gi.indirect.diffuse = 0;
  gi.indirect.specular = 0;
  gi.light.color = 0;
  gi.light.dir = half3(0,1,0);
  // Call GI (lightmaps/SH/reflections) lighting function
  UnityGIInput giInput;
  UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
  giInput.light = gi.light;
  giInput.worldPos = worldPos;
  giInput.worldViewDir = worldViewDir;
  giInput.atten = atten;
  #if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
    giInput.lightmapUV = IN.lmap;
  #else
    giInput.lightmapUV = 0.0;
  #endif
  #if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
    giInput.ambient = IN.sh;
  #else
    giInput.ambient.rgb = 0.0;
  #endif
  giInput.probeHDR[0] = unity_SpecCube0_HDR;
  giInput.probeHDR[1] = unity_SpecCube1_HDR;
  #if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
    giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
  #endif
  #ifdef UNITY_SPECCUBE_BOX_PROJECTION
    giInput.boxMax[0] = unity_SpecCube0_BoxMax;
    giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
    giInput.boxMax[1] = unity_SpecCube1_BoxMax;
    giInput.boxMin[1] = unity_SpecCube1_BoxMin;
    giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
  #endif
  LightingStandard_GI(o, giInput, gi);

  // call lighting function to output g-buffer
  outEmission = LightingStandard_Deferred (o, worldViewDir, gi, outGBuffer0, outGBuffer1, outGBuffer2);


  //VacuumShaders
  outEmission.rgb = DoDissolveEmission(alpha, outEmission).rgb;


  #if defined(SHADOWS_SHADOWMASK) && (UNITY_ALLOWED_MRT_COUNT > 4)
    outShadowMask = UnityGetRawBakedOcclusions (IN.lmap.xy, float3(0, 0, 0));
  #endif
  #ifndef UNITY_HDR_ON
  outEmission.rgb = exp2(-outEmission.rgb);
  #endif
}





ENDCG

}


	// ---- meta information extraction pass:
	Pass {
		Name "Meta"
		Tags { "LightMode" = "Meta" }
		Cull Off

CGPROGRAM
// compile directives
#pragma vertex vert_surf
#pragma fragment frag_surf
#pragma target 3.0
#pragma multi_compile_instancing
#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
#pragma skip_variants INSTANCING_ON
#pragma shader_feature EDITOR_VISUALIZATION

#include "HLSLSupport.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityShaderUtilities.cginc"
// -------- variant for: <when no other keywords are defined>
// Surface shader code generated based on:
// writes to per-pixel normal: YES
// writes to emission: no
// writes to occlusion: no
// needs world space reflection vector: no
// needs world space normal vector: no
// needs screen space position: no
// needs world space position: no
// needs view direction: no
// needs world space view direction: no
// needs world space position for lighting: YES
// needs world space view direction for lighting: YES
// needs world space view direction for lightmaps: no
// needs vertex color: no
// needs VFACE: no
// passes tangent-to-world matrix to pixel shader: YES
// reads from normal: no
// 1 texcoords actually used
//   float2 _MainTex
#define UNITY_PASS_META
#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityPBSLighting.cginc"

#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))

// Original surface shader snippet:
#line 49 ""
#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
#endif
/* UNITY: Original start of shader */
		// Physically based Standard lighting model, and enable shadows on all light types
		//#pragma surface surf Standard fullforwardshadows addshadow

		// Use shader model 3.0 target, to get nicer looking lighting
		//#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _MetallicTex;
		sampler2D _BumpMap;
		fixed _Cutoff;

#pragma shader_feature _ _DISSOLVETRIPLANAR_ON
#pragma shader_feature _DISSOLVEALPHASOURCE_MAIN_MAP_ALPHA _DISSOLVEALPHASOURCE_CUSTOM_MAP _DISSOLVEALPHASOURCE_TWO_CUSTOM_MAPS _DISSOLVEALPHASOURCE_THREE_CUSTOM_MAPS
#pragma shader_feature _DISSOLVEMASK_NONE _DISSOLVEMASK_AXIS_LOCAL _DISSOLVEMASK_AXIS_GLOBAL _DISSOLVEMASK_PLANE _DISSOLVEMASK_SPHERE
#pragma shader_feature _DISSOLVEALPHATEXTUREBLEND_MULTIPLY _DISSOLVEALPHATEXTUREBLEND_ADD
#include "Assets/VacuumShaders/Advanced Dissolve/Shaders/cginc/AdvancedDissolve.cginc"


		struct Input {
			float2 uv_MainTex;
			float2 uv_MetallicTex;
			float2 uv_BumpMap;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		float _MetallicAlpha;


		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = lerp(c.a, tex2D(_MetallicTex, IN.uv_MetallicTex).a, _MetallicAlpha) * _Metallic;
			o.Smoothness = _Glossiness;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			o.Alpha = c.a;
		}
		
#include "UnityMetaPass.cginc"

// vertex-to-fragment interpolation data
struct v2f_surf {
  UNITY_POSITION(pos);
  float2 pack0 : TEXCOORD0; // _MainTex
  float4 tSpace0 : TEXCOORD1;
  float4 tSpace1 : TEXCOORD2;
  float4 tSpace2 : TEXCOORD3;
  UNITY_VERTEX_INPUT_INSTANCE_ID
  UNITY_VERTEX_OUTPUT_STEREO

	 
  float3 worldPos : TEXCOORD4;
#ifdef _DISSOLVETRIPLANAR_ON
  half3 objNormal : TEXCOORD5;
  float3 coords : TEXCOORD6;
#else
  float4 dissolveUV : TEXCOORD5;
#endif
};
float4 _MainTex_ST;

// vertex shader
v2f_surf vert_surf (appdata_full v) {
  UNITY_SETUP_INSTANCE_ID(v);
  v2f_surf o;
  UNITY_INITIALIZE_OUTPUT(v2f_surf,o);
  UNITY_TRANSFER_INSTANCE_ID(v,o);
  UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
  o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST);
  o.pack0.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
  float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
  fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
  fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
  fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
  fixed3 worldBinormal = cross(worldNormal, worldTangent) * tangentSign;
  o.tSpace0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
  o.tSpace1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
  o.tSpace2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);



  //VacuumShaders
#ifdef _DISSOLVETRIPLANAR_ON
  o.coords = v.vertex;
  o.objNormal = lerp(worldNormal, v.normal, _DissolveTriplanarMapping);
#else
  DissolveVertex2Fragment(v.texcoord.xy, v.texcoord1.xy, o.dissolveUV);
#endif
  o.worldPos = worldPos;

#if defined(_DISSOLVEMASK_AXIS_GLOBAL) || defined(_DISSOLVEMASK_PLANE) || defined(_DISSOLVEMASK_SPHERE)
  o.worldPos = worldPos + _Dissolve_ObjectWorldPos;
#endif


  return o;
}

// fragment shader
fixed4 frag_surf (v2f_surf IN) : SV_Target {
  UNITY_SETUP_INSTANCE_ID(IN);
  // prepare and unpack data

#ifdef _DISSOLVETRIPLANAR_ON
float alpha = ReadDissolveAlpha_Triplanar(IN.coords, IN.objNormal, IN.worldPos);
#else
float alpha = ReadDissolveAlpha(IN.pack0.xy, IN.dissolveUV, IN.worldPos);
#endif

  Input surfIN;
  UNITY_INITIALIZE_OUTPUT(Input,surfIN);
  surfIN.uv_MainTex.x = 1.0;
  surfIN.uv_MetallicTex.x = 1.0;
  surfIN.uv_BumpMap.x = 1.0;
  surfIN.uv_MainTex = IN.pack0.xy;
  float3 worldPos = float3(IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w);
  #ifndef USING_DIRECTIONAL_LIGHT
    fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
  #else
    fixed3 lightDir = _WorldSpaceLightPos0.xyz;
  #endif
  #ifdef UNITY_COMPILER_HLSL
  SurfaceOutputStandard o = (SurfaceOutputStandard)0;
  #else
  SurfaceOutputStandard o;
  #endif
  o.Albedo = 0.0;
  o.Emission = 0.0;
  o.Alpha = 0.0;
  o.Occlusion = 1.0;
  fixed3 normalWorldVertex = fixed3(0,0,1);

  // call surface function
  surf (surfIN, o);
  UnityMetaInput metaIN;
  UNITY_INITIALIZE_OUTPUT(UnityMetaInput, metaIN);
  metaIN.Albedo = o.Albedo;


  metaIN.Emission += DoDissolveEmission(alpha, 0);


  return UnityMetaFragment(metaIN);
}





ENDCG

}


	}
	
	Fallback "VacuumShaders/Advanced Dissolve/VertexLit"
	CustomEditor "AdvancedDissolveGUI"
}
