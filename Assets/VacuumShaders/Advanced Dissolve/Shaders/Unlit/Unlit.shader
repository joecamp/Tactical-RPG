
Shader "VacuumShaders/Advanced Dissolve/Unlit" 
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Base (RGB) Trans (A)", 2D) = "white" { }
		[NoScaleOffset]_OcclusionMap("Occlusion", 2D) = "white" {}

		[MaterialEnum(Off,0,Front,1,Back,2)] _Cull("Face Cull", Int) = 0

		[HideInInspector]_Cutoff("Alpha cutoff", Range(0,1)) = 0.500000


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
	}
		     
	SubShader
	{
		Tags { "RenderType" = "AdvancedDissolveCutout" "DisableBatching" = "True" }
		LOD 100

			Cull[_Cull]

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#pragma multi_compile_fog

			#include "UnityCG.cginc"


			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _OcclusionMap;
			fixed4 _Color;
			fixed _Cutoff;

#pragma shader_feature _ _DISSOLVETRIPLANAR_ON
#pragma shader_feature _DISSOLVEALPHASOURCE_MAIN_MAP_ALPHA _DISSOLVEALPHASOURCE_CUSTOM_MAP _DISSOLVEALPHASOURCE_TWO_CUSTOM_MAPS _DISSOLVEALPHASOURCE_THREE_CUSTOM_MAPS
#pragma shader_feature _DISSOLVEMASK_NONE _DISSOLVEMASK_AXIS_LOCAL _DISSOLVEMASK_AXIS_GLOBAL _DISSOLVEMASK_PLANE _DISSOLVEMASK_SPHERE
#pragma shader_feature _DISSOLVEALPHATEXTUREBLEND_MULTIPLY _DISSOLVEALPHATEXTUREBLEND_ADD
#include "Assets/VacuumShaders/Advanced Dissolve/Shaders/cginc/AdvancedDissolve.cginc"

			struct appdata_t
			{
				float4 vertex : POSITION;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;

#ifdef _DISSOLVETRIPLANAR_ON
				float3 normal : NORMAL;
#endif

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv0 : TEXCOORD0;
				UNITY_FOG_COORDS(1)

				float3 worldPos : TEXCOORD2;

#ifdef _DISSOLVETRIPLANAR_ON
				half3 objNormal : TEXCOORD3;
				float3 coords : TEXCOORD4;
#else
				float4 dissolveUV : TEXCOORD3;
#endif			

				UNITY_VERTEX_OUTPUT_STEREO
			};

			

			v2f vert(appdata_t v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv0.xy = TRANSFORM_TEX(v.uv0, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);


				//VacuumShaders
				o.worldPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1)).xyz;
#ifdef _DISSOLVETRIPLANAR_ON
				o.coords = float4(v.vertex.xyz, 1);
				o.objNormal = lerp(UnityObjectToWorldNormal(v.normal), v.normal, _DissolveTriplanarMapping);
#else
				DissolveVertex2Fragment(v.uv0, v.uv1, o.dissolveUV);
#endif
				

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
#ifdef _DISSOLVETRIPLANAR_ON
				float alpha = ReadDissolveAlpha_Triplanar(i.coords, i.objNormal, i.worldPos);
#else
				float alpha = ReadDissolveAlpha(i.uv0.xy, i.dissolveUV, i.worldPos);
#endif				
				DoDissolveClip(alpha);


				fixed4 col = tex2D(_MainTex, i.uv0) * _Color;
				col.rgb *= tex2D(_OcclusionMap, i.uv0).rgb;

				col.rgb += DoDissolveEmission(alpha, 0);


				UNITY_APPLY_FOG(i.fogCoord, col);
				UNITY_OPAQUE_ALPHA(col.a);
				return col;
			}
			ENDCG
		}
	}

	CustomEditor "AdvancedDissolveGUI"
}
