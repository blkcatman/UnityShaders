Shader "Custom/FigureShader_Bump" {
	Properties {
		_Color ("Main Color", Color) = (1, 1, 1, 1)
		_ShadowColor ("Shadow Color", Color) = (0.8, 0.8, 0.8, 1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		Cull Off
		LOD 200
Pass{
Tags {"LightMode" = "ForwardBase"}
CGPROGRAM
#pragma target 3.0
#pragma vertex vert
#pragma fragment frag

#pragma multi_compile_fwdbase
#pragma fragmentoption ARB_precision_hint_fastest

#include "UnityCG.cginc"
#include "AutoLight.cginc"

// Material parameters
float4 _Color;
float4 _ShadowColor;
float4 _LightColor0;
float4 _MainTex_ST;
float4 _BumpMap_ST;

// Textures
sampler2D _MainTex;
sampler2D _BumpMap;
		
struct v2f
{
	float4 pos    : SV_POSITION;
	LIGHTING_COORDS( 0, 1 )
	float3 normal : TEXCOORD2;
	float2 uv     : TEXCOORD3;
	float3 eyeDir : TEXCOORD4;
	float3 lightDir : TEXCOORD5;
	float3 tangent : TEXCOORD6;
	float3 binormal : TEXCOORD7;
};

float3 rgb2hsv(float3 c)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
float3 hsv2rgb(float3 c)
{
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

v2f vert( appdata_tan v )
{
	v2f o;
	o.pos = mul( UNITY_MATRIX_MVP, v.vertex );
	o.uv = TRANSFORM_TEX( v.texcoord.xy, _MainTex );
	o.normal = normalize( mul( _Object2World, float4( v.normal, 0 ) ).xyz );
	
	// Eye direction vector
	float4 worldPos =  mul( _Object2World, v.vertex );
	o.eyeDir = normalize( _WorldSpaceCameraPos - worldPos );

	o.lightDir = WorldSpaceLightDir( v.vertex );
	
	o.tangent = normalize(mul(_Object2World, v.tangent));
	o.binormal = normalize(cross(o.normal, o.tangent));
	
	TRANSFER_VERTEX_TO_FRAGMENT( o );
	return o;
}
float4 frag( v2f i ) : COLOR
{
	float4 texcol = tex2D(_MainTex, i.uv);
	float3 hue = rgb2hsv(texcol.rgb);
	
	float4 en = tex2D(_BumpMap, _BumpMap_ST.xy * i.uv + _BumpMap_ST.zw);
	float3 lc = float3(2.0*en.a - 1.0, 2.0*en.g - 1.0, 0.0);
	lc.z = sqrt(1.0 - dot(lc, lc));
	
	float3x3 local2world = float3x3(
		i.tangent,
		i.binormal,
		i.normal
	);
	float3 rn = normalize(mul(lc, local2world));
	
	float3 n = normalize(i.lightDir + rn * 1.5);
	float at = dot(i.lightDir, n);
	if(hue.x <= 1.0/6.0) {
		hue.x = hue.x - pow(acos(at),2.0) * 1.0 / 18.0; // acos(at) -> color cycle shift
	} else if(hue.x <= 2.0/3.0) {
		hue.x = hue.x + pow(acos(at),2.0) * 1.0 / 18.0; // acos(at) -> color cycle shift
	}
	
	hue.z = hue.z * sqrt(max(sqrt(at),0.01));
	texcol.rgb = hsv2rgb(hue) * _LightColor0.xyz;
	//return DiffuseLight(i.lightDir, i.normal, texcol, LIGHT_ATTENUATION(i));

	float3 shadowColor = _ShadowColor.rgb * texcol;
	float attenuation = saturate( 2.0 * LIGHT_ATTENUATION( i ) - 1.0 );
	texcol.rgb = lerp( shadowColor, texcol.rgb, attenuation );
	return texcol;
}
ENDCG
}

Pass{
Tags {"LightMode" = "ForwardAdd"}
BlendOp Max
Blend OneMinusDstColor One

CGPROGRAM
#pragma target 3.0
#pragma vertex vert
#pragma fragment frag

#pragma multi_compile_fwdbase
#pragma fragmentoption ARB_precision_hint_fastest

#include "UnityCG.cginc"
#include "AutoLight.cginc"

// Material parameters
float4 _Color;
float4 _ShadowColor;
float4 _LightColor0;
float4 _MainTex_ST;
float4 _BumpMap_ST;

// Textures
sampler2D _MainTex;
sampler2D _BumpMap;
		
struct v2f
{
	float4 pos    : SV_POSITION;
	LIGHTING_COORDS( 0, 1 )
	float3 normal : TEXCOORD2;
	float2 uv     : TEXCOORD3;
	float3 eyeDir : TEXCOORD4;
	float3 lightDir : TEXCOORD5;
	float3 tangent : TEXCOORD6;
	float3 binormal : TEXCOORD7;
};

float3 rgb2hsv(float3 c)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
float3 hsv2rgb(float3 c)
{
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

v2f vert( appdata_tan v )
{
	v2f o;
	o.pos = mul( UNITY_MATRIX_MVP, v.vertex );
	o.uv = TRANSFORM_TEX( v.texcoord.xy, _MainTex );
	o.normal = normalize( mul( _Object2World, float4( v.normal, 0 ) ).xyz );
	
	// Eye direction vector
	float4 worldPos =  mul( _Object2World, v.vertex );
	o.eyeDir = normalize( _WorldSpaceCameraPos - worldPos );

	o.lightDir = WorldSpaceLightDir( v.vertex );
	
	o.tangent = normalize(mul(_Object2World, v.tangent));
	o.binormal = normalize(cross(o.normal, o.tangent));
	
	TRANSFER_VERTEX_TO_FRAGMENT( o );
	return o;
}
float4 frag( v2f i ) : COLOR
{
	float4 texcol = tex2D(_MainTex, i.uv);
	float3 hue = rgb2hsv(texcol.rgb);
	
	float4 en = tex2D(_BumpMap, _BumpMap_ST.xy * i.uv + _BumpMap_ST.zw);
	float3 lc = float3(2.0*en.a - 1.0, 2.0*en.g - 1.0, 0.0);
	lc.z = sqrt(1.0 - dot(lc, lc));
	
	float3x3 local2world = float3x3(
		i.tangent,
		i.binormal,
		i.normal
	);
	float3 rn = normalize(mul(lc, local2world));
	
	float3 n = normalize(i.lightDir + rn * 1.5);
	float at = dot(i.lightDir, n);
	if(hue.x <= 1.0/6.0) {
		hue.x = hue.x - pow(acos(at),2.0) * 1.0 / 18.0; // acos(at) -> color cycle shift
	} else if(hue.x <= 2.0/3.0) {
		hue.x = hue.x + pow(acos(at),2.0) * 1.0 / 18.0; // acos(at) -> color cycle shift
	}
	
	hue.z = hue.z * sqrt(max(sqrt(at),0.01));
	texcol.rgb = hsv2rgb(hue) * _LightColor0.xyz;
	//return DiffuseLight(i.lightDir, i.normal, texcol, LIGHT_ATTENUATION(i));

	float3 shadowColor = _ShadowColor.rgb * texcol;
	float attenuation = saturate( 2.0 * LIGHT_ATTENUATION( i ) - 1.0 );
	texcol.rgb = lerp( shadowColor, texcol.rgb, attenuation );
	return texcol;
}
ENDCG
}

	}
	FallBack "Diffuse"
}
