#ifndef ADVANCED_DISSOLVE_INCLUDED
#define ADVANCED_DISSOLVE_INCLUDED


float _DissolveCutoffAxis;
float _DissolveMaskOffset;
float _DissolveAxisInvert;

float _DissolveEdgeSize;
fixed4 _DissolveEdgeColor;
sampler2D _DissolveEdgeRamp;
float _DissolveGIStrength;

sampler2D _DissolveMap1;
float4 _DissolveMap1_ST;
float2 _DissolveMap1_Scroll;

sampler2D _DissolveMap2;
float4 _DissolveMap2_ST;
float2 _DissolveMap2_Scroll;

sampler2D _DissolveMap3;
float4 _DissolveMap3_ST;
float2 _DissolveMap3_Scroll;

float _DissolveUVSet;
float _DissolveNoiseStrength;

float3 _DissolveMaskPosition;
float3 _DissolveMaskPlaneNormal;
float _DissolveMaskSphereRadius;

float3 _Dissolve_ObjectWorldPos;

float _DissolveTriplanarTiling;
float _DissolveTriplanarMapping;


#ifndef _EMISSION
	#define _EMISSION
#endif


#define TIME _Time.x


#if (SHADER_TARGET <= 30)
	#if defined(_DISSOLVEALPHASOURCE_TWO_CUSTOM_MAPS) && defined(_PARALLAXMAP)
		#undef _PARALLAXMAP
	#endif

	#if defined(_DISSOLVEALPHASOURCE_THREE_CUSTOM_MAPS) && defined(_PARALLAXMAP)
		#undef _PARALLAXMAP

		//Also disable OcclusionMap sampler!!!
	#endif


	#if (_DETAIL_MULX2 || _DETAIL_MUL || _DETAIL_ADD || _DETAIL_LERP)
		#define _DETAIL 0
	#endif
	#if defined(_DETAIL_MULX2)
		#undef _DETAIL_MULX2
	#endif	
#endif


#if defined(_DISSOLVEALPHASOURCE_THREE_CUSTOM_MAPS)
	#define TRANSFORM_TEX_DISSOLVE(texUV,texName) texUV.xy
#else
	#define TRANSFORM_TEX_DISSOLVE(texUV,texName) (texUV.xy * texName##_ST.xy + texName##_ST.zw + texName##_Scroll * TIME)
#endif


inline void DissolveVertex2Fragment(float2 vertexUV0, float2 vertexUV1, inout float4 dissolveMapUV)
{
	dissolveMapUV.xy = TRANSFORM_TEX_DISSOLVE((_DissolveUVSet == 0 ? vertexUV0 : vertexUV1), _DissolveMap1);
	dissolveMapUV.zw = TRANSFORM_TEX_DISSOLVE((_DissolveUVSet == 0 ? vertexUV0 : vertexUV1), _DissolveMap2);
}


inline float ReadMaskValue(float3 vertexPos, float noise)
{
	float cutout = -1;

	#if defined(_DISSOLVEMASK_AXIS_LOCAL) || defined(_DISSOLVEMASK_AXIS_GLOBAL)

		#if defined(_DISSOLVEMASK_AXIS_LOCAL)
			vertexPos = mul(unity_WorldToObject, float4(vertexPos, 1));
		#endif

		cutout = (vertexPos - _DissolveMaskOffset)[(int)_DissolveCutoffAxis] * _DissolveAxisInvert;

		cutout += noise;

	#elif defined(_DISSOLVEMASK_PLANE)

		cutout = dot(_DissolveMaskPlaneNormal * _DissolveAxisInvert, vertexPos - _DissolveMaskPosition);
		
		cutout += noise;
		

	#elif defined(_DISSOLVEMASK_SPHERE)

		noise *= (_DissolveMaskSphereRadius < 1 ? _DissolveMaskSphereRadius : 1);

		float d = distance(vertexPos, _DissolveMaskPosition);		

		//_DissolveMaskSphereRadius += abs(noise) * (1 - _DissolveAxisInvert * 2);
		_DissolveMaskSphereRadius -= noise;

		float a = max(0, d - _DissolveMaskSphereRadius);
		float b = _DissolveMaskSphereRadius - min(d, _DissolveMaskSphereRadius);		

		cutout = lerp(a, b, _DissolveAxisInvert);

	#endif

	

	if (cutout > 0)
		return (cutout);
	else 
		return -1;
}


inline float ReadDissolveAlpha(float2 mainTexUV, float4 dissolveMapUV, float3 vertexPos)
{
	float alphaSource = 1;
	#if defined(_DISSOLVEALPHASOURCE_CUSTOM_MAP)

		alphaSource = tex2D(_DissolveMap1, dissolveMapUV.xy).a;

	#elif defined(_DISSOLVEALPHASOURCE_TWO_CUSTOM_MAPS)

		#ifdef _DISSOLVEALPHATEXTUREBLEND_ADD
			alphaSource = (tex2D(_DissolveMap1, dissolveMapUV.xy).a + tex2D(_DissolveMap2, dissolveMapUV.zw).a) * 0.5;
		#else
			alphaSource = (tex2D(_DissolveMap1, dissolveMapUV.xy).a * tex2D(_DissolveMap2, dissolveMapUV.zw).a);
		#endif

	#elif defined(_DISSOLVEALPHASOURCE_THREE_CUSTOM_MAPS)

		float2 uv1 = dissolveMapUV.xy * _DissolveMap1_ST.xy + _DissolveMap1_ST.zw + _DissolveMap1_Scroll * TIME;
		float2 uv2 = dissolveMapUV.xy * _DissolveMap2_ST.xy + _DissolveMap2_ST.zw + _DissolveMap2_Scroll * TIME;
		float2 uv3 = dissolveMapUV.xy * _DissolveMap3_ST.xy + _DissolveMap3_ST.zw + _DissolveMap3_Scroll * TIME;

		#ifdef _DISSOLVEALPHATEXTUREBLEND_ADD
			alphaSource = (tex2D(_DissolveMap1, uv1).a + tex2D(_DissolveMap2, uv2).a + tex2D(_DissolveMap3, uv3).a) / 3.0;
		#else
			alphaSource = (tex2D(_DissolveMap1, uv1).a * tex2D(_DissolveMap2, uv2).a * tex2D(_DissolveMap3, uv3).a);
		#endif

	#else

		alphaSource = tex2D(_MainTex, mainTexUV).a;
	 
	#endif


	
	#if defined(_DISSOLVEMASK_AXIS_LOCAL) || defined(_DISSOLVEMASK_AXIS_GLOBAL) || defined(_DISSOLVEMASK_PLANE) || defined(_DISSOLVEMASK_SPHERE)
	
		float noise = ((alphaSource - 0.5) * 2) * _DissolveNoiseStrength;

		return ReadMaskValue(vertexPos, noise);

	#else

		return alphaSource;

	#endif	
}



inline float4 ReadTriplanarTexture(sampler2D _texture, float3 coords, float3 blend)
{
	fixed4 cx = tex2D(_texture, coords.yz);
	fixed4 cy = tex2D(_texture, coords.xz);
	fixed4 cz = tex2D(_texture, coords.xy);

	return (cx * blend.x + cy * blend.y + cz * blend.z);
}

inline float ReadDissolveAlpha_Triplanar(float3 coords, float3 normal, float3 vertexPos)
{	
	half3 blend = abs(normal);
	blend /= dot(blend, 1.0);

	float alphaSource = 1;
	#if defined(_DISSOLVEALPHASOURCE_CUSTOM_MAP)

		alphaSource = ReadTriplanarTexture(_DissolveMap1, coords * _DissolveMap1_ST.x, blend).a;

	#elif defined(_DISSOLVEALPHASOURCE_TWO_CUSTOM_MAPS)

		float t1 = ReadTriplanarTexture(_DissolveMap1, coords * _DissolveMap1_ST.x, blend).a;
		float t2 = ReadTriplanarTexture(_DissolveMap2, coords * _DissolveMap2_ST.x, blend).a;

		#ifdef _DISSOLVEALPHATEXTUREBLEND_ADD
			alphaSource = (t1 + t2) * 0.5;
		#else
			alphaSource = t1 * t2;
		#endif

	#elif defined(_DISSOLVEALPHASOURCE_THREE_CUSTOM_MAPS)

		float t1 = ReadTriplanarTexture(_DissolveMap1, coords * _DissolveMap1_ST.x, blend).a;
		float t2 = ReadTriplanarTexture(_DissolveMap2, coords * _DissolveMap2_ST.x, blend).a;
		float t3 = ReadTriplanarTexture(_DissolveMap3, coords * _DissolveMap3_ST.x, blend).a;

		#ifdef _DISSOLVEALPHATEXTUREBLEND_ADD
			alphaSource = (t1 + t2 + t3) / 3.0;
		#else
			alphaSource = (t1 * t2 * t3);
		#endif

	#else		

		alphaSource = ReadTriplanarTexture(_MainTex, coords * _DissolveTriplanarTiling, blend).a;

	#endif



	#if defined(_DISSOLVEMASK_AXIS_LOCAL) || defined(_DISSOLVEMASK_AXIS_GLOBAL) || defined(_DISSOLVEMASK_PLANE) || defined(_DISSOLVEMASK_SPHERE)

		float noise = ((alphaSource - 0.5) * 2) * _DissolveNoiseStrength;

		return ReadMaskValue(vertexPos, noise);

	#else

		return alphaSource;

	#endif	
}

inline void DoDissolveClip(float alpha)
{
	#if defined(_DISSOLVEMASK_AXIS_LOCAL) || defined(_DISSOLVEMASK_AXIS_GLOBAL) || defined(_DISSOLVEMASK_PLANE) || defined(_DISSOLVEMASK_SPHERE)
		clip(alpha);
	#else
		clip(alpha - _Cutoff * 1.01);
	#endif
}


float3 DoDissolveEmission(float alpha, float3 emission)
{
	float3 dissolve = emission;

#ifdef UNITY_PASS_META
	_DissolveEdgeSize *= _DissolveGIStrength;
	_DissolveEdgeColor *= _DissolveGIStrength;
#endif


	#if defined(_DISSOLVEMASK_AXIS_LOCAL) || defined(_DISSOLVEMASK_AXIS_GLOBAL) || defined(_DISSOLVEMASK_PLANE) || defined(_DISSOLVEMASK_SPHERE)

		if (_DissolveEdgeSize > 0 && _DissolveEdgeSize > alpha)
		{
			float4 edgeColor = tex2D(_DissolveEdgeRamp, float2(saturate(alpha) * (1.0 / _DissolveEdgeSize), 0.5)) * _DissolveEdgeColor;

			dissolve = lerp(emission, edgeColor.rgb, edgeColor.a);
		}
	#else
		if (_Cutoff < 0.1)
		{
			_DissolveEdgeSize *= _Cutoff * 10;
		}

		//if (_Cutoff > 0.9)
		//{
		//	_DissolveEdgeSize *= 10 * (1 - _Cutoff);
		//}

		alpha -= _Cutoff;

		if (_DissolveEdgeSize > 0 && _DissolveEdgeSize > alpha && alpha >= 0)
		{
			float4 edgeColor = tex2D(_DissolveEdgeRamp, float2(alpha * (1.0 / _DissolveEdgeSize), 0.5)) * _DissolveEdgeColor;
			
			dissolve = lerp(emission, edgeColor.rgb, edgeColor.a);
		}
	#endif	

	#ifdef UNITY_PASS_META
		if (alpha <= 0)
			dissolve = float3(0, 0, 0);
	#endif



	return dissolve;
}


#endif // STANDARD_DISSOLVE_PRO_INCLUDED
