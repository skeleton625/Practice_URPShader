Shader "URPTraining/URPBasic"
{
	// Material�� ���� �ܺο��� ������ �� �ִ� ����(�Ӽ�)�� 
	Properties
	{
		// �÷� �ȷ�Ʈ ����
		_SampleColor("Sample Color", Color) = (1, 1, 1, 1)
		// ���� ������ ���ǵ� ����
		_SampleIntensity("Sample Range", Range(0, 1)) = 0.5
		// x, y, z, w, 4���� ���� ���� ���� ����
		_SampleVector("Sample Vector", Vector) = (0, 0, 0, 0)
		// �Ǽ��� ���� (int, float �ڷ��� Ÿ�� ��� ����)
		_SampleFloat("Sample Float", Float) = 0
		// Texture Sampler Ÿ���� ����
		_SampleTexture01("Sample Texture 01", 2D) = "white"{}
	// Texture Sampler Ÿ���� ����
	_SampleTexture02("Sample Texture 02", 2D) = "white"{}
	}

		// �޽ø� ������ �� ��, ������ ������ �����ϴ� �κ�
		SubShader
	{
		// SubShader�� Ÿ���� ����
		Tags
		{
			"RenderPipeline" = "UniversalPipeline"
			"RenderType" = "Opeque"
			"Queue" = "Geometry"
		}

		// SubShader���� ����� ���� �н��� ����
		// ���� �н� : �޽ø� ������ �� ��, ��, ȿ������ �����ϴ� ������ ����
		Pass
		{
			Name "Universal Forward"
			Tags { "LightMode" = "UniversalForward" }

			// HSLS ����
			HLSLPROGRAM

			#pragma prefer_hlslcc gles			// �ȵ���̵忡�� ���̴� ������, ũ�ν� �������� ���� SRP���� HLSLcc�� ���
			#pragma exclude_renderers d3d11_9x	// Direct3D 9 ����� ����
			#pragma vertex vert					// Vertex Shading ������ 'vert' �Լ��� ����
			#pragma fragment frag				// Fragment Shading ������ 'frag' �Լ��� ����

			// URP ��Ű���� �����ϴ� Lighting hlsl ���� ����
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			// Properties ���� ������ �������� SubShader���� ����ϱ� ���� ����
			half4 _SampleColor;
			float _SampleFloat;
			float _SampleIntensity;
			float4 _SampleVector;
			float4 _SampleTexture01_ST;			// _SampleTexture�� Tile, Offset �� -> "[�ؽ�ó ������]_ST"
			float4 _SampleTexture02_ST;
			Texture2D _SampleTexture01;
			Texture2D _SampleTexture02;
			SamplerState sampler_SampleTexture01; // _SampleTexture01 Texture2D�� ������

			// vertex buffer���� �о�� ���� ����ü ����
			struct VertexInput
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			/*
			* ������(���� ���� ��ü)�� ���� Vertex Shading���� Pixel Shading(Fragment Shading)��
			* ���޵Ǵ� ���� ����ü
			*/
			struct VertexOutput
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			// Rendering Pipeline�� Vertex Shading ���� �Լ� -> �޽��� ���� ��� ����
			VertexOutput vert(VertexInput v)
			{
				VertexOutput o;
				// ���� ��ǥ�踦 ����� ��ǥ��� ��ġ ����
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				o.uv = v.uv;
				// _SampleTexture_ST�� xy�� Tile Size, zw�� Offset ���� �ǹ�
				// o.uv = v.uv.xy * _SampleTexture01_ST.xy + _SampleTexture01_ST.zw;

				return o;
			}

			// Vertex Shader, Fragment Shader �߰��� ���� ��ǥ��(3D)���� ����� ��ǥ��(2D)�� �����ϴ� ����(Rasterization)�� ����

			// Rendering Pipeline�� Pixel Shading(Fragment Shading) ���� �Լ� -> ����� Pixel�� ��� ����
			half4 frag(VertexOutput i) : SV_Target
			{
				float2 uv01 = i.uv.xy * _SampleTexture01_ST.xy + _SampleTexture01_ST.zw;
				float2 uv02 = i.uv.xy * _SampleTexture02_ST.xy + _SampleTexture02_ST.zw;

				// ���ø��� ���� SampleTexture Tile, offset ����
				// half4 color01 = tex2D(_SampleTexture01, uv01) -> �� �� ������ ������ �� ������ ��� ( ������ ������ ��⿡ ���� ���ѵǾ� ����)
				half4 color01 = _SampleTexture01.Sample(sampler_SampleTexture01, uv01) * _SampleColor * _SampleIntensity;
				half4 color02 = _SampleTexture02.Sample(sampler_SampleTexture01, uv02) * _SampleColor * _SampleIntensity;

				half4 color = color01 * color02;
				return color;
			}

			// HSLS ��
			ENDHLSL
		}
	}
}