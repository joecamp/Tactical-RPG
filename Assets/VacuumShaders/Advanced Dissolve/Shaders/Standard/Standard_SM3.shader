Shader "VacuumShaders/Advanced Dissolve/Standard"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo", 2D) = "white" {}
	 
        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5  
			 
        _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
        _GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0
        [Enum(Metallic Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel ("Smoothness texture channel", Float) = 0
			 
        [Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0  
        _MetallicGlossMap("Metallic", 2D) = "white" {}

        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0 

        _BumpScale("Scale", Float) = 1.0
        _BumpMap("Normal Map", 2D) = "bump" {} 
		  
        _Parallax ("Height Scale", Range (0.005, 0.08)) = 0.02
        _ParallaxMap ("Height Map", 2D) = "black" {}
		 
        _OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
        _OcclusionMap("Occlusion", 2D) = "white" {} 

        _EmissionColor("Color", Color) = (0,0,0)
        _EmissionMap("Emission", 2D) = "white" {}

        _DetailMask("Detail Mask", 2D) = "white" {}    

        _DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
        _DetailNormalMapScale("Scale", Float) = 1.0
        _DetailNormalMap("Normal Map", 2D) = "bump" {}

        [Enum(UV0,0,UV1,1)] _UVSec ("UV Set for secondary textures", Float) = 0


        // Blending state
        [HideInInspector] _Mode ("__mode", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0


		[MaterialEnum(Off,0,Front,1,Back,2)] _Cull("Face Cull", Int) = 0

		//VacuumShaders
		[KeywordEnum(None, Axis Local, Axis Global, Plane, Sphere)] _DissolveMask("", Float) = 0
		[Enum(X,0,Y,1,Z,2)] _DissolveCutoffAxis("Axis", int) = 0
		_DissolveAxisInvert("Axis Invert", Float) = 1
		_DissolveMaskOffset("Mask Offset", Float) = 0
		_DissolveEdgeSize("Edge Size", Range(0.0, 1.0)) = 0.15
		[HDR]_DissolveEdgeColor("Edge Color", Color) = (1, 1, 1, 1)		
		[NoScaleOffset]_DissolveEdgeRamp("Ramp", 2D) = "white" {}
		_DissolveGIStrength("GI Strength", Float) = 1
		[KeywordEnum(Main Map Alpha, Custom Map, Two Custom Maps, Three Custom Maps)] _DissolveAlphaSource("", Float) = 0
		_DissolveMap1("", 2D) = "white"{}
		[UVScroll] _DissolveMap1_Scroll("", vector) = (0, 0, 0, 0)
		_DissolveMap2("", 2D) = "white"{}
		[UVScroll] _DissolveMap2_Scroll("", vector) = (0, 0, 0, 0)
		_DissolveMap3("", 2D) = "white"{}
		[UVScroll] _DissolveMap3_Scroll("", vector) = (0, 0, 0, 0)
		_DissolveNoiseStrength("", Range(0, 1)) = 0.1
		[KeywordEnum(Multiply, Add)] _DissolveAlphaTextureBlend("", Float) = 0
		[Enum(UV0,0,UV1,1)] _DissolveUVSet("UV Set", Float) = 0

		[HideInInspector][V3]_DissolveMaskPosition("", Vector) = (0, 0, 0, 0)
		[HideInInspector][V3]_DissolveMaskPlaneNormal("", Vector) = (1, 0, 0, 0)
		[HideInInspector][Positive]_DissolveMaskSphereRadius("", Float) = 1
		
		[HideInInspector]_Dissolve_ObjectWorldPos("wPos", vector) = (0, 0, 0, 0)

    }

    CGINCLUDE
        #define UNITY_SETUP_BRDF_INPUT MetallicSetup
    ENDCG

    SubShader
    {
			Tags{ "RenderType" = "AdvancedDissolveCutout" "PerformanceChecks" = "False" "DisableBatching" = "True" }
			LOD 300
		
			Cull[_Cull]


        // ------------------------------------------------------------------
        //  Base forward pass (directional light, emission, lightmaps, ...)
        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }

			//VacuumShaders
			//Blend mode and ZWrite are adjusted for 'Cutout'
            Blend One Zero
            ZWrite On		
			


            CGPROGRAM
            #pragma target 3.0

            // -------------------------------------

            #pragma shader_feature _NORMALMAP
        
			//VacuumShaders
			#define UNITY_STANDARD
			#pragma shader_feature _DISSOLVEALPHASOURCE_MAIN_MAP_ALPHA _DISSOLVEALPHASOURCE_CUSTOM_MAP _DISSOLVEALPHASOURCE_TWO_CUSTOM_MAPS _DISSOLVEALPHASOURCE_THREE_CUSTOM_MAPS
		    #pragma shader_feature _DISSOLVEMASK_NONE _DISSOLVEMASK_AXIS_LOCAL _DISSOLVEMASK_AXIS_GLOBAL _DISSOLVEMASK_PLANE _DISSOLVEMASK_SPHERE
			#pragma shader_feature _DISSOLVEALPHATEXTUREBLEND_MULTIPLY _DISSOLVEALPHATEXTUREBLEND_ADD
			//#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON	//Shader is always with _ALPHATEST_ON enabled!
			#define _ALPHATEST_ON
			 
            //#pragma shader_feature _EMISSION	//Shader is always with _EMISSION enabled!
			#define _EMISSION

            #pragma shader_feature _METALLICGLOSSMAP
            //#pragma shader_feature ___ _DETAIL_MULX2	 //SM 3.0 Not Supported feature
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
            #pragma shader_feature _PARALLAXMAP

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #pragma vertex vertBase
            #pragma fragment fragBase
            #include "UnityStandardCoreForward.cginc"

            ENDCG
        }
        // ------------------------------------------------------------------
        //  Additive forward pass (one light per pass)
        Pass
        {
            Name "FORWARD_DELTA"
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One
            Fog { Color (0,0,0,0) } // in additive pass fog should be black
            ZWrite Off
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.0

            // -------------------------------------


            #pragma shader_feature _NORMALMAP

			//VacuumShaders
			#define UNITY_STANDARD
			#pragma shader_feature _DISSOLVEALPHASOURCE_MAIN_MAP_ALPHA _DISSOLVEALPHASOURCE_CUSTOM_MAP _DISSOLVEALPHASOURCE_TWO_CUSTOM_MAPS _DISSOLVEALPHASOURCE_THREE_CUSTOM_MAPS
		    #pragma shader_feature _DISSOLVEMASK_NONE _DISSOLVEMASK_AXIS_LOCAL _DISSOLVEMASK_AXIS_GLOBAL _DISSOLVEMASK_PLANE _DISSOLVEMASK_SPHERE
			#pragma shader_feature _DISSOLVEALPHATEXTUREBLEND_MULTIPLY _DISSOLVEALPHATEXTUREBLEND_ADD
			//#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON	//Shader is always with _ALPHATEST_ON enabled!
			#define _ALPHATEST_ON

            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
            //#pragma shader_feature ___ _DETAIL_MULX2  //SM 3.0 Not Supported feature
            #pragma shader_feature _PARALLAXMAP

            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog

            #pragma vertex vertAdd
            #pragma fragment fragAdd
            #include "UnityStandardCoreForward.cginc"

            ENDCG
        }
        // ------------------------------------------------------------------
        //  Shadow rendering pass
        Pass {
            Name "ShadowCaster" 
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On ZTest LEqual
			  
            CGPROGRAM
            #pragma target 3.0 

            // -------------------------------------


			//VacuumShaders
			#pragma shader_feature _DISSOLVEALPHASOURCE_MAIN_MAP_ALPHA _DISSOLVEALPHASOURCE_CUSTOM_MAP _DISSOLVEALPHASOURCE_TWO_CUSTOM_MAPS _DISSOLVEALPHASOURCE_THREE_CUSTOM_MAPS
			#pragma shader_feature _DISSOLVEMASK_NONE _DISSOLVEMASK_AXIS_LOCAL _DISSOLVEMASK_AXIS_GLOBAL _DISSOLVEMASK_PLANE _DISSOLVEMASK_SPHERE
			#pragma shader_feature _DISSOLVEALPHATEXTUREBLEND_MULTIPLY _DISSOLVEALPHATEXTUREBLEND_ADD
			//#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON	//Shader is always with _ALPHATEST_ON enabled! 
			#define _ALPHATEST_ON

            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _PARALLAXMAP
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing

            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster

            #include "UnityStandardShadow.cginc"

            ENDCG
        }
        // ------------------------------------------------------------------
        //  Deferred pass
        Pass
        {
            Name "DEFERRED"
            Tags { "LightMode" = "Deferred" }

            CGPROGRAM
            #pragma target 3.0
            #pragma exclude_renderers nomrt


            // -------------------------------------

            #pragma shader_feature _NORMALMAP

			//VacuumShaders
			#define UNITY_STANDARD
			#pragma shader_feature _DISSOLVEALPHASOURCE_MAIN_MAP_ALPHA _DISSOLVEALPHASOURCE_CUSTOM_MAP _DISSOLVEALPHASOURCE_TWO_CUSTOM_MAPS _DISSOLVEALPHASOURCE_THREE_CUSTOM_MAPS
			#pragma shader_feature _DISSOLVEMASK_NONE _DISSOLVEMASK_AXIS_LOCAL _DISSOLVEMASK_AXIS_GLOBAL _DISSOLVEMASK_PLANE _DISSOLVEMASK_SPHERE
			#pragma shader_feature _DISSOLVEALPHATEXTUREBLEND_MULTIPLY _DISSOLVEALPHATEXTUREBLEND_ADD
			//#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON	//Shader is always with _ALPHATEST_ON enabled!
			#define _ALPHATEST_ON

			#pragma shader_feature _EMISSION	//Shader is always with _EMISSION enabled!
			//#define _EMISSION


            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
            //#pragma shader_feature ___ _DETAIL_MULX2   //SM 3.0 Not Supported feature
            #pragma shader_feature _PARALLAXMAP 

            #pragma multi_compile_prepassfinal
            #pragma multi_compile_instancing

            #pragma vertex vertDeferred
            #pragma fragment fragDeferred

            #include "UnityStandardCore.cginc"

            ENDCG
        }

         //------------------------------------------------------------------
         //Extracts information for lightmapping, GI (emission, albedo, ...)
         //This pass it not used during regular rendering.
        Pass
        {
            Name "META"
            Tags { "LightMode"="Meta" }
			 
            Cull Off

            CGPROGRAM
			#pragma target 3.0

            #pragma vertex vert_meta
            #pragma fragment frag_meta 

			//VacuumShaders
			#pragma shader_feature _DISSOLVEALPHASOURCE_MAIN_MAP_ALPHA _DISSOLVEALPHASOURCE_CUSTOM_MAP _DISSOLVEALPHASOURCE_TWO_CUSTOM_MAPS _DISSOLVEALPHASOURCE_THREE_CUSTOM_MAPS
			#pragma shader_feature _DISSOLVEMASK_NONE _DISSOLVEMASK_AXIS_LOCAL _DISSOLVEMASK_AXIS_GLOBAL _DISSOLVEMASK_PLANE _DISSOLVEMASK_SPHERE
			#pragma shader_feature _DISSOLVEALPHATEXTUREBLEND_MULTIPLY _DISSOLVEALPHATEXTUREBLEND_ADD

			//#pragma shader_feature _EMISSION	//Shader is always with _EMISSION enabled!
			#define _EMISSION

            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            //#pragma shader_feature ___ _DETAIL_MULX2	 //SM 3.0 Not Supported feature
            #pragma shader_feature EDITOR_VISUALIZATION

            #include "UnityStandardMeta.cginc"
            ENDCG
        }
    }

    FallBack "VacuumShaders/Advanced Dissolve/VertexLit"
    CustomEditor "AdvancedDissolveShaderGUI"
}
