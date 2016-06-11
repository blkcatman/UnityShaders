//SelectiveNCorrection.cs
//
//Copyright (c) 2016 Tatsuro Matsubara
//Released under the MIT license
//http://opensource.org/licenses/mit-license.php
//
using System;
using UnityEngine;

namespace UnityStandardAssets.ImageEffects
{
	[ExecuteInEditMode]
	[AddComponentMenu("Image Effects/Color Adjustments/Selective N Correction")]
	public class SelectiveNCorrection : ImageEffectBase {

		public Texture nCorrection;
		[Range(0, 2)]
		public float effectWeight = 1.0f;
		[Range(0, 2)]
		public float saturation = 1.0f;
		[Range(0, 2)]
		public float brightness = 1.0f;
		[Range(0, 2)]
		public float toneWeight = 1.0f;
		public bool hdr;

		void OnRenderImage(RenderTexture source, RenderTexture destination) {
			material.SetTexture("_NCTex", nCorrection);
			material.SetFloat("_Weight", effectWeight);
			material.SetFloat("_SWeight", saturation);
			material.SetFloat("_Brightness", brightness);
			material.SetFloat("_ToneWeight", toneWeight);
			if (hdr) {
				material.EnableKeyword("NC_HDR");
			} else {
				material.DisableKeyword("NC_HDR");
			}
            Graphics.Blit(source, destination, material);
		}
	}
}
