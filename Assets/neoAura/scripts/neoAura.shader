/* by neoliang */
Shader "neo/neoAura"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }
		LOD 100
		Cull Back
		ZWrite Off
		Fog{ Mode Off }

		//0-高斯模糊|Gaussian Blur
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_blur
			#pragma fragment frag_blur
			#include "neoAuraInclude.cginc"
			ENDCG
		}

		//1-提取边缘|Edge extraction
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_min
			#pragma fragment frag_edgeExtraction
			#include "neoAuraInclude.cginc"
			ENDCG
		}

		//2-提取整块内部|inner extraction
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_min
			#pragma fragment frag_innerExtraction
			#include "neoAuraInclude.cginc"
			ENDCG
		}

		//3-内向模糊|inner blur
		Pass
		{

			CGPROGRAM
			#pragma vertex vert_blur
			#pragma fragment frag_innerBlur
			#include "neoAuraInclude.cginc"
			ENDCG
		}

		//4-增强|enhance
		Pass
		{

			CGPROGRAM
			#pragma vertex vert_min
			#pragma fragment frag_enhance
			#include "neoAuraInclude.cginc"
			ENDCG
		}

		//5-图片叠加|superposition
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_min
			#pragma fragment frag_overlap
			#include "neoAuraInclude.cginc"
			ENDCG
		}

		
	}
}
