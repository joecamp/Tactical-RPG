Shader "VacuumShaders/Advanced Dissolve/VertexLit" 
{
	Properties 
	{
		 _Color ("Main Color", Color) = (1,1,1,1)
		 _SpecColor ("Spec Color", Color) = (1,1,1,0)
		 _Shininess ("Shininess", Range(0.100000,1)) = 0.700000
		 _MainTex ("Base (RGB) Trans (A)", 2D) = "white" { }


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
	}

	SubShader 
	{ 
		 LOD 100
		 Tags { "IGNOREPROJECTOR"="true" "RenderType"="AdvancedDissolveCutout" "DisableBatching" = "True" }
			Cull[_Cull]

		 Pass 
		 {
		  Tags { "LIGHTMODE"="Vertex"  "IGNOREPROJECTOR"="true" }
		  AlphaToMask On
		  ColorMask RGB


		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma target 2.0
		#include "UnityCG.cginc"
		#pragma multi_compile_fog
		#define USING_FOG (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))

		// ES2.0/WebGL/3DS can not do loops with non-constant-expression iteration counts :(
		#if defined(SHADER_API_GLES)
		  #define LIGHT_LOOP_LIMIT 8
		#elif defined(SHADER_API_N3DS)
		  #define LIGHT_LOOP_LIMIT 4
		#else
		  #define LIGHT_LOOP_LIMIT unity_VertexLightParams.x
		#endif
		#define ENABLE_SPECULAR (!defined(SHADER_API_N3DS))

		// Compile specialized variants for when positional (point/spot) and spot lights are present
		#pragma multi_compile __ POINT SPOT

		// Compute illumination from one light, given attenuation
		half3 computeLighting (int idx, half3 dirToLight, half3 eyeNormal, half3 viewDir, half4 diffuseColor, half shininess, half atten, inout half3 specColor) {
		  half NdotL = max(dot(eyeNormal, dirToLight), 0.0);
		  // diffuse
		  half3 color = NdotL * diffuseColor.rgb * unity_LightColor[idx].rgb;
		  // specular
		  if (NdotL > 0.0) {
			half3 h = normalize(dirToLight + viewDir);
			half HdotN = max(dot(eyeNormal, h), 0.0);
			half sp = saturate(pow(HdotN, shininess));
			specColor += (atten * sp) * unity_LightColor[idx].rgb;
		  }
		  return color * atten;
		}

		// Compute attenuation & illumination from one light
		half3 computeOneLight(int idx, float3 eyePosition, half3 eyeNormal, half3 viewDir, half4 diffuseColor, half shininess, inout half3 specColor) {
		  float3 dirToLight = unity_LightPosition[idx].xyz;
		  half att = 1.0;
		  #if defined(POINT) || defined(SPOT)
			dirToLight -= eyePosition * unity_LightPosition[idx].w;
			// distance attenuation
			float distSqr = dot(dirToLight, dirToLight);
			att /= (1.0 + unity_LightAtten[idx].z * distSqr);
			if (unity_LightPosition[idx].w != 0 && distSqr > unity_LightAtten[idx].w) att = 0.0; // set to 0 if outside of range
			distSqr = max(distSqr, 0.000001); // don't produce NaNs if some vertex position overlaps with the light
			dirToLight *= rsqrt(distSqr);
			#if defined(SPOT)
			  // spot angle attenuation
			  half rho = max(dot(dirToLight, unity_SpotDirection[idx].xyz), 0.0);
			  half spotAtt = (rho - unity_LightAtten[idx].x) * unity_LightAtten[idx].y;
			  att *= saturate(spotAtt);
			#endif
		  #endif
		  att *= 0.5; // passed in light colors are 2x brighter than what used to be in FFP
		  return min (computeLighting (idx, dirToLight, eyeNormal, viewDir, diffuseColor, shininess, att, specColor), 1.0);
		}

		// uniforms
		half4 _Color;
		half4 _SpecColor;
		half _Shininess;
		int4 unity_VertexLightParams; // x: light count, y: zero, z: one (y/z needed by d3d9 vs loop instruction)
		float4 _MainTex_ST;
		sampler2D _MainTex;
		fixed _Cutoff;

#pragma shader_feature _ _DISSOLVETRIPLANAR_ON
#pragma shader_feature _DISSOLVEALPHASOURCE_MAIN_MAP_ALPHA _DISSOLVEALPHASOURCE_CUSTOM_MAP _DISSOLVEALPHASOURCE_TWO_CUSTOM_MAPS _DISSOLVEALPHASOURCE_THREE_CUSTOM_MAPS
#pragma shader_feature _DISSOLVEMASK_NONE _DISSOLVEMASK_AXIS_LOCAL _DISSOLVEMASK_AXIS_GLOBAL _DISSOLVEMASK_PLANE _DISSOLVEMASK_SPHERE
#pragma shader_feature _DISSOLVEALPHATEXTUREBLEND_MULTIPLY _DISSOLVEALPHATEXTUREBLEND_ADD
#include "Assets/VacuumShaders/Advanced Dissolve/Shaders/cginc/AdvancedDissolve.cginc"

		// vertex shader input data
		struct appdata {
		  float3 pos : POSITION;
		  float3 normal : NORMAL;
		  float3 uv0 : TEXCOORD0;
		  float3 uv1 : TEXCOORD1;
		  UNITY_VERTEX_INPUT_INSTANCE_ID
		};

		// vertex-to-fragment interpolators
		struct v2f {
		  fixed4 color : COLOR0;

		  float2 uv0 : TEXCOORD0;

		  #if ENABLE_SPECULAR
			fixed3 specColor : COLOR1;
		  #endif
		 
		  #if USING_FOG
			fixed fog : TEXCOORD2;
		  #endif
		  float4 pos : SV_POSITION;

		  float3 worldPos : TEXCOORD3;

#ifdef _DISSOLVETRIPLANAR_ON		  
		  half3 objNormal : TEXCOORD4;
		  float3 coords : TEXCOORD5;
#else
		  float4 dissolveUV : TEXCOORD4;
#endif

		  UNITY_VERTEX_OUTPUT_STEREO
		};

		// vertex shader
		v2f vert (appdata IN) 
		{
		  v2f o;
		  UNITY_SETUP_INSTANCE_ID(IN);
		  UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
		  half4 color = half4(0,0,0,1.1);

		  //float3 eyePos = mul (UNITY_MATRIX_MV, float4(IN.pos,1)).xyz;
		  float3 eyePos = UnityObjectToViewPos(float4(IN.pos, 1)).xyz;

		  half3 eyeNormal = normalize (mul ((float3x3)UNITY_MATRIX_IT_MV, IN.normal).xyz);
		  half3 viewDir = 0.0;
		  viewDir = -normalize (eyePos);
		  // lighting
		  half3 lcolor = _Color.rgb * glstate_lightmodel_ambient.rgb;
		  half3 specColor = 0.0;
		  half shininess = _Shininess * 128.0;
		  for (int il = 0; il < LIGHT_LOOP_LIMIT; ++il) {
			lcolor += computeOneLight(il, eyePos, eyeNormal, viewDir, _Color, shininess, specColor);
		  }
		  color.rgb = lcolor.rgb;
		  color.a = _Color.a;
		  specColor *= _SpecColor.rgb;
		  o.color = saturate(color);
		  #if ENABLE_SPECULAR
		  o.specColor = saturate(specColor);
		  #endif
		  // compute texture coordinates
		  o.uv0 = IN.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
		  // fog
		  #if USING_FOG
			float fogCoord = length(eyePos.xyz); // radial fog distance
			UNITY_CALC_FOG_FACTOR_RAW(fogCoord);
			o.fog = saturate(unityFogFactor);
		  #endif
		  // transform position
		  o.pos = UnityObjectToClipPos(IN.pos);



		  //VacuumShaders
		  o.worldPos = mul(unity_ObjectToWorld, float4(IN.pos.xyz, 1)).xyz;

#ifdef _DISSOLVETRIPLANAR_ON
		  o.coords = float4(IN.pos.xyz, 1);
		  o.objNormal = lerp(UnityObjectToWorldNormal(IN.normal), IN.normal, _DissolveTriplanarMapping);
#else
		  DissolveVertex2Fragment(IN.uv0, IN.uv1, o.dissolveUV);
#endif
		  return o;
		}


		// fragment shader
		fixed4 frag (v2f IN) : SV_Target 
		{

#ifdef _DISSOLVETRIPLANAR_ON
			float alpha = ReadDissolveAlpha_Triplanar(IN.coords, IN.objNormal, IN.worldPos);
#else
			float alpha = ReadDissolveAlpha(IN.uv0.xy, IN.dissolveUV, IN.worldPos);
#endif
			DoDissolveClip(alpha);


		  fixed4 col;
		  fixed4 tex, tmp0, tmp1, tmp2;
		  // SetTexture #0
		  tex = tex2D (_MainTex, IN.uv0.xy);
		  col.rgb = tex * IN.color;
		  col *= 2;
		  col.a = 1;
		  #if ENABLE_SPECULAR
		  // add specular color
		  col.rgb += IN.specColor;
		  #endif


		  col.rgb += DoDissolveEmission(alpha, 0);

		  // fog
		  #if USING_FOG
			col.rgb = lerp (unity_FogColor.rgb, col.rgb, IN.fog);
		  #endif
		  return col;
		}

		// texenvs
		//! TexEnv0: 02010103 01050107 [_MainTex]
		ENDCG
		 }

		 Pass {
		  Tags { "LIGHTMODE"="VertexLM" "IGNOREPROJECTOR"="true"  }
		  AlphaToMask On
		  ColorMask RGB
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma target 2.0
		#include "UnityCG.cginc"
		#pragma multi_compile_fog
		#define USING_FOG (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))

		// uniforms
		float4 _MainTex_ST;
		 sampler2D _MainTex;
		 fixed4 _Color;
		 fixed _Cutoff;


#pragma shader_feature _ _DISSOLVETRIPLANAR_ON
#pragma shader_feature _DISSOLVEALPHASOURCE_MAIN_MAP_ALPHA _DISSOLVEALPHASOURCE_CUSTOM_MAP _DISSOLVEALPHASOURCE_TWO_CUSTOM_MAPS _DISSOLVEALPHASOURCE_THREE_CUSTOM_MAPS
#pragma shader_feature _DISSOLVEMASK_NONE _DISSOLVEMASK_AXIS_LOCAL _DISSOLVEMASK_AXIS_GLOBAL _DISSOLVEMASK_PLANE _DISSOLVEMASK_SPHERE
#pragma shader_feature _DISSOLVEALPHATEXTUREBLEND_MULTIPLY _DISSOLVEALPHATEXTUREBLEND_ADD
#include "Assets/VacuumShaders/Advanced Dissolve/Shaders/cginc/AdvancedDissolve.cginc"


		// vertex shader input data
		struct appdata {
		  float3 pos : POSITION;
		  half4 color : COLOR;
		  float3 uv1 : TEXCOORD1;
		  float3 uv0 : TEXCOORD0;
		  float3 normal : NORMAL;
		  UNITY_VERTEX_INPUT_INSTANCE_ID
		};

		// vertex-to-fragment interpolators
		struct v2f {
		  fixed4 color : COLOR0;
		  float2 uv0 : TEXCOORD0;
		  float2 uv1 : TEXCOORD1;
		  #if USING_FOG
			fixed fog : TEXCOORD2;
		  #endif
		  float4 pos : SV_POSITION;

		  float3 worldPos : TEXCOORD3;

#ifdef _DISSOLVETRIPLANAR_ON
		  half3 objNormal : TEXCOORD4;
		  float3 coords : TEXCOORD5;
#else
		  float4 dissolveUV : TEXCOORD4;
#endif

		  UNITY_VERTEX_OUTPUT_STEREO
		};

		// vertex shader
		v2f vert (appdata IN) {
		  v2f o;
		  UNITY_SETUP_INSTANCE_ID(IN);
		  UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
		  half4 color = IN.color;

		  //float3 eyePos = mul (UNITY_MATRIX_MV, float4(IN.pos,1)).xyz;
		  float3 eyePos = UnityObjectToViewPos(float4(IN.pos, 1)).xyz;

		  half3 viewDir = 0.0;
		  o.color = saturate(color);
		  // compute texture coordinates
		  o.uv0 = IN.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
		  o.uv1 = IN.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
		  // fog
		  #if USING_FOG
			float fogCoord = length(eyePos.xyz); // radial fog distance
			UNITY_CALC_FOG_FACTOR_RAW(fogCoord);
			o.fog = saturate(unityFogFactor);
		  #endif
		  // transform position
		  o.pos = UnityObjectToClipPos(IN.pos);


		  //VacuumShaders
		  o.worldPos = mul(unity_ObjectToWorld, float4(IN.pos.xyz, 1)).xyz;

#ifdef _DISSOLVETRIPLANAR_ON
		  o.coords = float4(IN.pos.xyz, 1);
		  o.objNormal = lerp(UnityObjectToWorldNormal(IN.normal), IN.normal, _DissolveTriplanarMapping);
#else
		  DissolveVertex2Fragment(IN.uv0.xy, IN.uv1.xy, o.dissolveUV);
#endif
		  return o;
		}
				

		// fragment shader
		fixed4 frag (v2f IN) : SV_Target 
		{
#ifdef _DISSOLVETRIPLANAR_ON
			float alpha = ReadDissolveAlpha_Triplanar(IN.coords, IN.objNormal, IN.worldPos);
#else
			float alpha = ReadDissolveAlpha(IN.uv0.xy, IN.dissolveUV, IN.worldPos);
#endif
			
		DoDissolveClip(alpha);

		  fixed4 col;
		  fixed4 tex, tmp0, tmp1, tmp2;
		  // SetTexture #0
		  tex = UNITY_SAMPLE_TEX2D (unity_Lightmap, IN.uv0.xy);
		  col = tex * _Color;
		  // SetTexture #1
		  tex = tex2D (_MainTex, IN.uv1.xy);
		  col.rgb = tex * col;
		  col *= 2;
		  col.a = 1;
		 

		  col.rgb += DoDissolveEmission(alpha, 0);


		  // fog
		  #if USING_FOG
			col.rgb = lerp (unity_FogColor.rgb, col.rgb, IN.fog);
		  #endif
		  return col;
		}

		// texenvs
		//! TexEnv0: 01010102 01010102 [unity_Lightmap] [_Color] usesLightmapST
		//! TexEnv1: 02010100 01050107 [_MainTex]
		ENDCG
		 }

		 Pass {
		  Tags { "LIGHTMODE"="VertexLMRGBM" "IGNOREPROJECTOR"="true"  }
		  AlphaToMask On
		  ColorMask RGB
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma target 2.0
		#include "UnityCG.cginc"
		#pragma multi_compile_fog
		#define USING_FOG (defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2))

		// uniforms
		float4 unity_Lightmap_ST;
		float4 _MainTex_ST;
		sampler2D _MainTex;
		fixed4 _Color;
		fixed _Cutoff;

		#pragma shader_feature _ _DISSOLVETRIPLANAR_ON
		#pragma shader_feature _DISSOLVEALPHASOURCE_MAIN_MAP_ALPHA _DISSOLVEALPHASOURCE_CUSTOM_MAP _DISSOLVEALPHASOURCE_TWO_CUSTOM_MAPS _DISSOLVEALPHASOURCE_THREE_CUSTOM_MAPS
		#pragma shader_feature _DISSOLVEMASK_NONE _DISSOLVEMASK_AXIS_LOCAL _DISSOLVEMASK_AXIS_GLOBAL _DISSOLVEMASK_PLANE _DISSOLVEMASK_SPHERE
		#pragma shader_feature _DISSOLVEALPHATEXTUREBLEND_MULTIPLY _DISSOLVEALPHATEXTUREBLEND_ADD
		#include "Assets/VacuumShaders/Advanced Dissolve/Shaders/cginc/AdvancedDissolve.cginc"


		// vertex shader input data
		struct appdata {
		  float3 pos : POSITION;
		  half4 color : COLOR;
		  float3 uv1 : TEXCOORD1;
		  float3 uv0 : TEXCOORD0;
		  float3 normal : NORMAL;
		  UNITY_VERTEX_INPUT_INSTANCE_ID
		};

		// vertex-to-fragment interpolators
		struct v2f {
		  fixed4 color : COLOR0;
		  float2 uv0 : TEXCOORD0;
		  float2 uv1 : TEXCOORD1;
		  float2 uv2 : TEXCOORD2;
		  #if USING_FOG
			fixed fog : TEXCOORD3;
		  #endif
		  float4 pos : SV_POSITION;

		  float3 worldPos : TEXCOORD4;
#ifdef _DISSOLVETRIPLANAR_ON
		  half3 objNormal : TEXCOORD5;
		  float3 coords : TEXCOORD6;
#else
		  float4 dissolveUV : TEXCOORD5;
#endif
		  UNITY_VERTEX_OUTPUT_STEREO
		};

		// vertex shader
		v2f vert (appdata IN) {
		  v2f o;
		  UNITY_SETUP_INSTANCE_ID(IN);
		  UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
		  half4 color = IN.color;

		  //float3 eyePos = mul (UNITY_MATRIX_MV, float4(IN.pos,1)).xyz;
		  float3 eyePos = UnityObjectToViewPos(float4(IN.pos, 1)).xyz;

		  half3 viewDir = 0.0;
		  o.color = saturate(color);
		  // compute texture coordinates
		  o.uv0 = IN.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
		  o.uv1 = IN.uv1.xy * unity_Lightmap_ST.xy + unity_Lightmap_ST.zw;
		  o.uv2 = IN.uv0.xy * _MainTex_ST.xy + _MainTex_ST.zw;
		  // fog
		  #if USING_FOG
			float fogCoord = length(eyePos.xyz); // radial fog distance
			UNITY_CALC_FOG_FACTOR_RAW(fogCoord);
			o.fog = saturate(unityFogFactor);
		  #endif
		  // transform position
		  o.pos = UnityObjectToClipPos(IN.pos);



		  //VacuumShaders
		  o.worldPos = mul(unity_ObjectToWorld, float4(IN.pos.xyz, 1)).xyz;

#ifdef _DISSOLVETRIPLANAR_ON
		  o.coords = float4(IN.pos.xyz, 1);
		  o.objNormal = lerp(UnityObjectToWorldNormal(IN.normal), IN.normal, _DissolveTriplanarMapping);
#else
		  DissolveVertex2Fragment(IN.uv0.xy, IN.uv1.xy, o.dissolveUV);
#endif

		  return o;
		}

		

		// fragment shader
		fixed4 frag (v2f IN) : SV_Target 
		{
#ifdef _DISSOLVETRIPLANAR_ON
			float alpha = ReadDissolveAlpha_Triplanar(IN.coords, IN.objNormal, IN.worldPos);
#else
			float alpha = ReadDissolveAlpha(IN.uv0.xy, IN.dissolveUV, IN.worldPos);
#endif
			DoDissolveClip(alpha);


		  fixed4 col;
		  fixed4 tex, tmp0, tmp1, tmp2;
		  // SetTexture #0
		  tex = UNITY_SAMPLE_TEX2D (unity_Lightmap, IN.uv0.xy);
		  col = tex * tex.a;
		  col *= 2;
		  // SetTexture #1
		  tex = UNITY_SAMPLE_TEX2D (unity_Lightmap, IN.uv1.xy);
		  col = col * _Color;
		  // SetTexture #2
		  tex = tex2D (_MainTex, IN.uv2.xy);
		  col.rgb = tex * col;
		  col *= 4;
		  col.a = 1;
		  

		  col.rgb += DoDissolveEmission(alpha, 0);


		  // fog
		  #if USING_FOG
			col.rgb = lerp (unity_FogColor.rgb, col.rgb, IN.fog);
		  #endif
		  return col;
		}

		// texenvs
		//! TexEnv0: 02010105 02010105 [unity_Lightmap] usesLightmapST
		//! TexEnv1: 01000102 01000102 [unity_Lightmap] [_Color]
		//! TexEnv2: 04010100 01050107 [_MainTex]
		ENDCG
		 }

		 Pass {
		  Name "ShadowCaster"
		  Tags { "LIGHTMODE"="SHADOWCASTER" "IGNOREPROJECTOR"="true" "SHADOWSUPPORT"="true" }

			 ZWrite On ZTest LEqual

		CGPROGRAM
		#line 120 ""
		#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
		#endif

		#include "HLSLSupport.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityShaderUtilities.cginc"
		#line 120 ""
		#ifdef DUMMY_PREPROCESSOR_TO_WORK_AROUND_HLSL_COMPILER_LINE_HANDLING
		#endif
		/* UNITY: Original start of shader */
		#pragma vertex vert
		#pragma fragment frag
		#pragma target 2.0
		#pragma multi_compile_shadowcaster
		#pragma multi_compile_instancing // allow instanced shadow pass for most of the shaders
		#include "UnityCG.cginc"


		 uniform float4 _MainTex_ST;
		 uniform sampler2D _MainTex;
		 uniform fixed _Cutoff;
		 uniform fixed4 _Color;

#pragma shader_feature _ _DISSOLVETRIPLANAR_ON
#pragma shader_feature _DISSOLVEALPHASOURCE_MAIN_MAP_ALPHA _DISSOLVEALPHASOURCE_CUSTOM_MAP _DISSOLVEALPHASOURCE_TWO_CUSTOM_MAPS _DISSOLVEALPHASOURCE_THREE_CUSTOM_MAPS
#pragma shader_feature _DISSOLVEMASK_NONE _DISSOLVEMASK_AXIS_LOCAL _DISSOLVEMASK_AXIS_GLOBAL _DISSOLVEMASK_PLANE _DISSOLVEMASK_SPHERE
#pragma shader_feature _DISSOLVEALPHATEXTUREBLEND_MULTIPLY _DISSOLVEALPHATEXTUREBLEND_ADD
#include "Assets/VacuumShaders/Advanced Dissolve/Shaders/cginc/AdvancedDissolve.cginc"


		struct v2f {
			V2F_SHADOW_CASTER;
			float2  uv : TEXCOORD1;

			float3 worldPos : TEXCOORD2;

#ifdef _DISSOLVETRIPLANAR_ON
			half3 objNormal : TEXCOORD3;
			float3 coords : TEXCOORD4;
#else
			float4 dissolveUV : TEXCOORD3;			
#endif

			UNITY_VERTEX_OUTPUT_STEREO
		};

		

		

		v2f vert(appdata_full v )
		{
			v2f o;
			UNITY_SETUP_INSTANCE_ID(v);
			UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
			TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);


			//VacuumShaders
			o.worldPos = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1)).xyz;

#ifdef _DISSOLVETRIPLANAR_ON
			o.coords = v.vertex;
			o.objNormal = lerp(UnityObjectToWorldNormal(v.normal), v.normal, _DissolveTriplanarMapping);
#else
			DissolveVertex2Fragment(v.texcoord, v.texcoord1, o.dissolveUV);
#endif
			

			return o;
		}

		

		float4 frag( v2f i ) : SV_Target
		{
#ifdef _DISSOLVETRIPLANAR_ON
			float alpha = ReadDissolveAlpha_Triplanar(i.coords, i.objNormal, i.worldPos);
#else
			float alpha = ReadDissolveAlpha(i.uv.xy, i.dissolveUV, i.worldPos);
#endif

			DoDissolveClip(alpha);

			SHADOW_CASTER_FRAGMENT(i)
		}
		ENDCG
		 }
	}
CustomEditor "AdvancedDissolveGUI"
}