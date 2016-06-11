//SelectiveNCorrShader.shader
//
//Copyright (c) 2016 Tatsuro Matsubara
//Released under the MIT license
//http://opensource.org/licenses/mit-license.php
//
Shader "Hidden/SelectiveNCorrection"
{
	Properties
	{
		_MainTex ("Base(RGB)", 2D) = "white" {}
		_NCTex("NCTexture", 2D) = "white" {}
		_Weight("Effect Weight", Range(0, 2)) = 1.0
		_SWeight("Saturation", Range(0, 2)) = 1.0
		_Brightness("Brightness", Range(0, 2)) = 1.0

		_ToneWeight("Tone Weight", Range(0, 2)) = 1.0
		_ToneCoeff("Tone Coefficient", Range(0, 1)) = 1.0

	}
	SubShader
	{
		//Cull Off ZWrite Off ZTest Always
		ZTest Always Cull Off ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma shader_feature NC_HDR
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			sampler2D _NCTex;
			float _Weight;
			float _SWeight;
			float _Brightness;

			float _ToneWeight;

			float3 rgb2hsv(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
				float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

				float d = q.x - min(q.w, q.y);
				float e = 1.0e-10;
				return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}

			#ifdef NC_HDR
			float4 frag(v2f_img i) : SV_Target
			#else 
			fixed4 frag(v2f_img i) : SV_Target
			#endif
			{
				float4 col = tex2D(_MainTex, i.uv);

				float l = max(max(col.r, col.g), col.b);
				col.rgb = col.rgb / l;

				float3 hi  = col.rgb;
				float3 hue = rgb2hsv(col.rgb);
				float3 low = tex2D(_NCTex, float2(hue.r, 0.5));

				float v = hue.b*l*max(_ToneWeight, 0.2);

				float3 lp1 = lerp(low, hi, saturate(v / (_Weight + 1.0)));
				float3 lp2 = lerp(float3(1.0, 1.0, 1.0), lp1, saturate(hue.g * _SWeight));
				float3 res = lerp(lp2, hi, saturate(1.0 / (_Weight + 1.0)));

				#ifdef NC_HDR
				return float4(res * max(_Brightness, 0.0) * l, col.a);
				#else
				return fixed4(res * max(_Brightness, 0.0) * l, col.a);
				#endif

			}
			ENDCG
		}
	}
	Fallback off
}
