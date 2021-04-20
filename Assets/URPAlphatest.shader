Shader "URPTraining/URPAlphatest"
{
	Properties
	{
		_SampleAlpha("Sample Alpha", Range(0, 1)) = 1
		_SampleIntensity("Sample Intensity", Range(0, 1)) = 0.5
		_SampleTexture01("Sample Texture 01", 2D) = "white" {}
	}

		SubShader
	{
		Tags
		{
			"RenderPipeline" = "UniversalPipeline"
			"RenderType" = "TransparentCutout"
			"Queue" = "Alphatest"
		}

		Pass
		{
			Name "Universal Forward"
			Tags { "LightMode" = "UniversalForward" }

			HLSLPROGRAM

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			float _SampleAlpha;
			float _SampleIntensity;
			float4 _SampleTexture01_ST;
			Texture2D _SampleTexture01;
			SamplerState sampler_SampleTexture01;

			struct VertexInput
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct VertexOutput
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			VertexOutput vert(VertexInput v)
			{
				VertexOutput o;
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				o.uv = v.uv.xy * _SampleTexture01_ST.xy + _SampleTexture01_ST.zw;

				return o;
			}

			half4 frag(VertexOutput i) : SV_Target
			{
				half4 color01 = _SampleTexture01.Sample(sampler_SampleTexture01, i.uv) * _SampleIntensity;
				clip(color01.a - (1 - _SampleAlpha));
				return color01;
			}

			ENDHLSL
		}
	}
}
