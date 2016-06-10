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
		public float effectWeight = 2.0f;
		public float saturationWeight = 1.0f;
		public float brightness = 1.0f;
		public bool hdr;

		void OnRenderImage(RenderTexture source, RenderTexture destination) {
			material.SetTexture("_NCTex", nCorrection);
			material.SetFloat("_Weight", effectWeight);
			material.SetFloat("_SWeight", saturationWeight);
			material.SetFloat("_Brightness", brightness);
			if (hdr) {
				material.EnableKeyword("NC_HDR");
			} else {
				material.DisableKeyword("NC_HDR");
			}
            Graphics.Blit(source, destination, material);
		}
	}
}
